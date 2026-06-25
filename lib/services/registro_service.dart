import 'dart:convert';
import 'dart:async';
import 'package:fortivus_app/config/environment_config.dart';
import 'package:fortivus_app/pages/registro_page.dart';
import 'package:fortivus_app/util/auth_http_helper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'local_db_service.dart';
import '../database/app_database.dart' as db;
import '../enums/enums.dart';
import '../model/despacho.dart' as model;
import 'sync_service.dart';

class RegistroServiceException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  RegistroServiceException(this.message, {this.code, this.statusCode});

  @override
  String toString() => 'RegistroServiceException: $message';
}

class RegistroService {
  static final RegistroService _instance = RegistroService._internal();
  factory RegistroService() => _instance;
  RegistroService._internal();

  String get baseUrl =>
      '${EnvironmentConfig.apiBaseUrl}/v1/operacional/despachos';

  bool _isSyncInProgress = false;
  DateTime? _lastSyncTime;
  Timer? _syncDebounceTimer;

  String? _cachedUserSub;
  DateTime? _lastCacheTime;

  static const Duration _minSyncInterval = Duration(seconds: 10);
  static const Duration _debounceTime = Duration(seconds: 2);
  static const Duration _cacheValidityTime = Duration(minutes: 5);
  static const Duration _requestTimeout = Duration(seconds: 30);

  Future<bool> _hasConnection() async {
    try {
      final results = await Connectivity().checkConnectivity();
      return !results.contains(ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  Future<String?> _getLoggedUserSub() async {
    if (_isCacheValid()) return _cachedUserSub;
    await _refreshUserSubCache();
    return _cachedUserSub;
  }

  bool _isCacheValid() {
    if (_cachedUserSub == null || _lastCacheTime == null) return false;
    return DateTime.now().difference(_lastCacheTime!) < _cacheValidityTime;
  }

  Future<void> _refreshUserSubCache() async {
    try {
      final userMap = await LocalDbService.instance.getUserAsMap();
      if (userMap != null) {
        final token = userMap['token'] as String?;
        if (token != null) {
          _cachedUserSub = _extractSubFromToken(token);
        }
        _cachedUserSub ??= userMap['sub'] as String?;
      }
      _lastCacheTime = DateTime.now();
    } catch (e) {
      _log('Erro ao atualizar cache: $e');
    }
  }

  String? _extractSubFromToken(String token) {
    try {
      final decoded = JwtDecoder.decode(token);
      return decoded['sub'] as String?;
    } catch (_) {
      return null;
    }
  }

  void clearUserCache() {
    _cachedUserSub = null;
    _lastCacheTime = null;
  }

  model.Despacho _driftToModel(db.Despacho d) => model.Despacho(
        id: d.id,
        ordemServicoId: d.ordemServicoId,
        escalaId: d.escalaId,
        responsavelId: d.responsavelId,
        categoria: CategoriaOperacao.fromString(d.categoria),
        descricaoTarefa: d.descricaoTarefa,
        status: SituacaoDespacho.fromString(d.status),
        dataInicio:
            d.dataInicio != null ? DateTime.tryParse(d.dataInicio!) : null,
        dataFim: d.dataFim != null ? DateTime.tryParse(d.dataFim!) : null,
        latitude: d.latitude,
        longitude: d.longitude,
        isSynced: d.isSynced,
        userId: d.userId,
      );

  void syncAllRegistros({bool forceSync = false}) {
    _syncDebounceTimer?.cancel();
    _syncDebounceTimer = Timer(_debounceTime, () {
      _executeSyncAll(forceSync: forceSync);
    });
  }

  Future<void> _executeSyncAll({bool forceSync = false}) async {
    if (_isSyncInProgress) return;

    final now = DateTime.now();
    if (!forceSync &&
        _lastSyncTime != null &&
        now.difference(_lastSyncTime!) < _minSyncInterval) return;

    _isSyncInProgress = true;
    _lastSyncTime = now;

    try {
      final userSub = await _getLoggedUserSub();
      if (userSub == null) return;

      await _syncResponses();

      final despachos = await _fetchAllDespachos();
      if (despachos.isEmpty) return;

      final ids = despachos.map((d) => d.id).toList();
      await LocalDbService.instance.apagarDespachosOrfaos(ids, userSub);
      await LocalDbService.instance.saveDespachos(
        despachos.map((d) => {...d.toMap(), 'userId': userSub}).toList(),
      );
    } catch (e) {
      _log('Erro na sincronização: $e');
    } finally {
      _isSyncInProgress = false;
    }
  }

  Future<void> _syncResponses() async {
    try {
      SyncService().forceSyncNow();
    } catch (e) {
      _log('Erro ao sincronizar respostas: $e');
    }
  }

  Future<List<model.Despacho>> _fetchAllDespachos() async {
    try {
      final countPage = await _fetchPage(size: 1, page: 0);
      final total = countPage.totalItems;
      if (total <= 0) return [];
      final allPage = await _fetchPage(size: total, page: 0);
      return allPage.content;
    } catch (e) {
      _log('Erro ao buscar todos os despachos: $e');
      return [];
    }
  }

  Future<model.Despacho?> getRegistro(int id) async {
    try {
      final d = await LocalDbService.instance.getDespachoById(id);
      if (d == null) return null;
      return _driftToModel(d);
    } catch (e) {
      _log('Erro ao buscar despacho local: $e');
      return null;
    }
  }

  Future<RegistroPage> consultarRegistros({
    int? registroId,
    int? ordemServicoId,
    String? categoria,
    String? situacao,
    int page = 0,
    int size = 10,
    String sort = 'desc',
    String? cacheBuster,
    bool skipSync = false,
  }) async {
    final userSub = await _getLoggedUserSub();
    if (userSub == null) {
      throw RegistroServiceException('Nenhum usuário logado');
    }

    if (!await _hasConnection()) {
      return await _getOfflineDespachos(
        userId: userSub,
        despachoId: registroId,
        ordemServicoId: ordemServicoId,
        categoria: categoria,
        status: situacao,
        page: page,
        size: size,
        sort: sort,
      );
    }

    try {
      final resultPage = await _fetchPage(
        despachoId: registroId,
        ordemServicoId: ordemServicoId,
        categoria: categoria,
        situacao: situacao,
        page: page,
        size: size,
        sort: sort,
        cacheBuster: cacheBuster,
      );

      await LocalDbService.instance.saveDespachos(
        resultPage.content
            .map((d) => {...d.toMap(), 'userId': userSub})
            .toList(),
      );

      if (!skipSync && situacao == 'ABERTA' && size < 30) {
        syncAllRegistros();
      }

      return resultPage;
    } catch (e) {
      _log('Erro online, usando cache: $e');
      return await _getOfflineDespachos(
        userId: userSub,
        despachoId: registroId,
        ordemServicoId: ordemServicoId,
        categoria: categoria,
        status: situacao,
        page: page,
        size: size,
        sort: sort,
      );
    }
  }

  Future<RegistroPage> _fetchPage({
    int? despachoId,
    int? ordemServicoId,
    String? categoria,
    String? situacao,
    required int page,
    required int size,
    String sort = 'desc',
    String? cacheBuster,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      'sort': sort,
    };
    if (cacheBuster != null) params['_t'] = cacheBuster;

    final uri =
        Uri.parse('$baseUrl/paged').replace(queryParameters: params);
    final response =
        await AuthHttpHelper.get(uri).timeout(_requestTimeout);

    if (response.statusCode != 200) {
      throw RegistroServiceException(
        'Erro HTTP ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    final fullPage = RegistroPage.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);

    if (situacao != null && situacao.isNotEmpty) {
      final filtered = fullPage.content.where((d) {
        if (situacao == 'ABERTA') return d.status.isAberta;
        if (situacao == 'ENCERRADA') return d.status.isConcluido;
        return d.status.name == situacao;
      }).toList();
      return RegistroPage(
        content: filtered,
        currentPage: fullPage.currentPage,
        totalPages: fullPage.totalPages,
        totalItems: filtered.length,
      );
    }

    return fullPage;
  }

  Future<int> getTotalPendentes({bool quickCheck = false}) async {
    final userSub = await _getLoggedUserSub();
    if (userSub == null) return 0;

    try {
      if (!await _hasConnection()) {
        return await LocalDbService.instance.countAbertos(userId: userSub);
      }

      final resultPage = await _fetchPage(
        situacao: 'ABERTA',
        page: 0,
        size: 1,
        cacheBuster: quickCheck ? _getCacheBuster() : null,
      );

      if (!quickCheck) {
        await _checkDiscrepancy(userSub, resultPage.totalItems);
      }

      return resultPage.totalItems;
    } catch (e) {
      _log('Erro ao buscar pendentes: $e');
      return await LocalDbService.instance.countAbertos(userId: userSub);
    }
  }

  Future<int> getTotalEncerrados() async {
    final userSub = await _getLoggedUserSub();
    if (userSub == null) return 0;

    try {
      if (!await _hasConnection()) {
        return await LocalDbService.instance.countConcluidos(userId: userSub);
      }

      final resultPage = await _fetchPage(
        situacao: 'ENCERRADA',
        page: 0,
        size: 1,
      );

      return resultPage.totalItems;
    } catch (e) {
      _log('Erro ao buscar encerrados: $e');
      return await LocalDbService.instance.countConcluidos(userId: userSub);
    }
  }

  Future<void> _checkDiscrepancy(String userSub, int onlineCount) async {
    try {
      final localCount =
          await LocalDbService.instance.countAbertos(userId: userSub);
      final pendentes =
          await LocalDbService.instance.getRespostasPendentes();

      if (onlineCount != localCount || pendentes.isNotEmpty) {
        Future.delayed(const Duration(seconds: 3), () {
          syncAllRegistros(forceSync: true);
        });
      }
    } catch (e) {
      _log('Erro ao verificar discrepância: $e');
    }
  }

  Future<RegistroPage> _getOfflineDespachos({
    required String userId,
    int? despachoId,
    int? ordemServicoId,
    String? categoria,
    String? status,
    required int page,
    required int size,
    required String sort,
  }) async {
    try {
      final dbPage =
          await LocalDbService.instance.getOfflineDespachosPaginated(
        userId: userId,
        despachoId: despachoId,
        ordemServicoId: ordemServicoId,
        categoria: categoria,
        status: status,
        page: page,
        size: size,
        sort: sort,
      );

      final modelDespachos = dbPage.content.map(_driftToModel).toList();

      return RegistroPage(
        content: modelDespachos,
        currentPage: dbPage.currentPage,
        totalPages: dbPage.totalPages,
        totalItems: dbPage.totalItems,
      );
    } catch (e) {
      throw RegistroServiceException('Erro ao buscar offline: $e');
    }
  }

  String _getCacheBuster() =>
      DateTime.now().millisecondsSinceEpoch.toString();

  void _log(String message) {
    if (kDebugMode) debugPrint('[RegistroService] $message');
  }

  void dispose() {
    _syncDebounceTimer?.cancel();
    clearUserCache();
  }
}

class KeycloakException implements Exception {
  final String message;
  final String? errorCode;
  final int? statusCode;

  KeycloakException(this.message, {this.errorCode, this.statusCode});

  @override
  String toString() => 'KeycloakException: $message';
}

Future<void> handleKeycloakError(dynamic error) async {
  if (error is PlatformException) {
    switch (error.code) {
      case 'unauthorized_client':
        throw KeycloakException('Cliente não autorizado');
      case 'access_denied':
        throw KeycloakException('Acesso negado');
      case 'invalid_grant':
        throw KeycloakException('Credenciais inválidas');
      default:
        throw KeycloakException('Erro do Keycloak: ${error.message}');
    }
  }
}
