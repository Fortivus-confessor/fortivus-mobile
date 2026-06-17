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
import '../model/registro.dart';
import 'sync_service.dart';

class RegistroServiceException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  RegistroServiceException(
    this.message, {
    this.code,
    this.statusCode,
  });

  @override
  String toString() => 'RegistroServiceException: $message';
}

class RegistroService {
  static final RegistroService _instance = RegistroService._internal();
  factory RegistroService() => _instance;
  RegistroService._internal();

  String get baseUrl => "${EnvironmentConfig.apiBaseUrl}/registro_ocorrencia";

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
    if (_isCacheValid()) {
      return _cachedUserSub;
    }
    await _refreshUserSubCache();
    return _cachedUserSub;
  }

  bool _isCacheValid() {
    if (_cachedUserSub == null || _lastCacheTime == null) {
      return false;
    }
    return DateTime.now().difference(_lastCacheTime!) < _cacheValidityTime;
  }

  Future<void> _refreshUserSubCache() async {
    try {
      final user = await LocalDbService.getLoggedUser();
      if (user?.token != null) {
        _cachedUserSub = _extractSubFromToken(user!.token!);
      } else {
        _cachedUserSub = user?.sub;
      }
      _lastCacheTime = DateTime.now();

      _log('Cache atualizado: $_cachedUserSub');
    } catch (e) {
      _log('Erro ao atualizar cache: $e');
    }
  }

  String? _extractSubFromToken(String token) {
    try {
      final decoded = JwtDecoder.decode(token);
      return decoded['sub'] as String?;
    } catch (e) {
      _log('Erro ao extrair sub do token: $e');
      return null;
    }
  }

  void clearUserCache() {
    _cachedUserSub = null;
    _lastCacheTime = null;
    _log('Cache de usuário limpo');
  }

  /// Sincronizar todos os registros
  void syncAllRegistros({bool forceSync = false}) {
    _syncDebounceTimer?.cancel();
    _syncDebounceTimer = Timer(_debounceTime, () {
      _executeSyncAll(forceSync: forceSync);
    });
  }

  Future<void> _executeSyncAll({bool forceSync = false}) async {
    if (_isSyncInProgress) {
      _log('⚠️ Sincronização já em progresso');
      return;
    }

    final now = DateTime.now();
    if (!forceSync && _shouldSkipSync(now)) {
      _log('Aguardando intervalo mínimo entre sincronizações');
      return;
    }

    _isSyncInProgress = true;
    _lastSyncTime = now;

    try {
      _log('🔄 Iniciando sincronização completa');

      final userSub = await _getLoggedUserSub();
      if (userSub == null) {
        _log('❌ Nenhum usuário logado');
        return;
      }

      await _syncResponses();

      final registros = await _fetchAllRegistros();
      if (registros.isEmpty) {
        _log('ℹ️ Nenhum registro no servidor');
        return;
      }

      final List<int> ids = registros.map((r) => r.id).toList();
      await LocalDbService.apagarRegistrosOrfaos(ids, userSub);
      await LocalDbService.saveRegistros(registros, userSub);

      _log('✅ Sincronização de registros concluída');

    } catch (e) {
      _log('❌ Erro na sincronização: $e');
    } finally {
      _isSyncInProgress = false;
    }
  }

  bool _shouldSkipSync(DateTime now) {
    return _lastSyncTime != null &&
        now.difference(_lastSyncTime!) < _minSyncInterval;
  }

  /// Buscar todos os registros do servidor
  Future<List<Registro>> _fetchAllRegistros() async {
    try {
      final countPage = await _fetchPage(size: 1, page: 0);
      final totalItems = countPage.totalItems;

      _log('Usuário tem $totalItems registros no servidor');

      if (totalItems <= 0) {
        return [];
      }

      final allPage = await _fetchPage(size: totalItems, page: 0);
      return allPage.content;
    } catch (e) {
      _log('❌ Erro ao buscar todos os registros: $e');
      return [];
    }
  }

  Future<void> _syncResponses() async {
    try {
      SyncService().forceSyncNow();
    } catch (e) {
      _log('⚠️ Erro ao sincronizar respostas: $e');
    }
  }

  Future<Registro?> getRegistro(int id) async {
    try {
      final uri = Uri.parse("$baseUrl/$id");
      final response = await AuthHttpHelper.get(uri).timeout(_requestTimeout);

      if (response.statusCode == 200) {
        return Registro.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      _log('Erro ao buscar registro: $e');
      return await LocalDbService.getRegistroById(id);
    }
  }

  Future<RegistroPage> consultarRegistros({
    int? registroId,
    int? ordemServicoId,
    String? categoria,
    String? situacao,
    int page = 0,
    int size = 10,
    String sort = "desc",
    String? cacheBuster,
    bool skipSync = false,
  }) async {
    final userSub = await _getLoggedUserSub();
    if (userSub == null) {
      throw RegistroServiceException('Nenhum usuário logado');
    }

    if (!await _hasConnection()) {
      _log('Modo offline');
      return await _getOfflineRegistros(
        userId: userSub,
        registroId: registroId,
        ordemServicoId: ordemServicoId,
        categoria: categoria,
        situacao: situacao,
        page: page,
        size: size,
        sort: sort,
      );
    }

    try {
      final resultPage = await _fetchPage(
        registroId: registroId,
        ordemServicoId: ordemServicoId,
        categoria: categoria,
        situacao: situacao,
        page: page,
        size: size,
        sort: sort,
        cacheBuster: cacheBuster,
      );

      // Salvar em cache local
      await LocalDbService.saveRegistros(resultPage.content, userSub);

      // Agendar sincronização completa se necessário
      if (!skipSync && situacao == "ABERTA" && size < 30) {
        syncAllRegistros();
      }

      return resultPage;
    } catch (e) {
      _log('Erro online, usando cache offline: $e');
      return await _getOfflineRegistros(
        userId: userSub,
        registroId: registroId,
        ordemServicoId: ordemServicoId,
        categoria: categoria,
        situacao: situacao,
        page: page,
        size: size,
        sort: sort,
      );
    }
  }

  /// Buscar uma página específica
  Future<RegistroPage> _fetchPage({
    int? registroId,
    int? ordemServicoId,
    String? categoria,
    String? situacao,
    required int page,
    required int size,
    String sort = "desc",
    String? cacheBuster,
  }) async {
    final params = _buildQueryParams(
      registroId: registroId,
      ordemServicoId: ordemServicoId,
      categoria: categoria,
      situacao: situacao,
      page: page,
      size: size,
      sort: sort,
      cacheBuster: cacheBuster,
    );

    final uri = Uri.parse("$baseUrl/consultar").replace(queryParameters: params);
    final response = await AuthHttpHelper.get(uri).timeout(_requestTimeout);

    if (response.statusCode != 200) {
      throw RegistroServiceException(
        'Erro HTTP ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    return RegistroPage.fromJson(jsonDecode(response.body));
  }

   Future<int> getTotalPendentes({bool quickCheck = false}) async {
    final userSub = await _getLoggedUserSub();
    if (userSub == null) return 0;

    try {
      if (!await _hasConnection()) {
        return await _getOfflinePendentesCount(userSub);
      }

      final resultPage = await _fetchPage(
        situacao: "ABERTA",
        page: 0,
        size: 1,
        cacheBuster: quickCheck ? _getCacheBuster() : null,
      );

      // Verificar discrepância se não for quick check
      if (!quickCheck) {
        await _checkDiscrepancy(userSub, resultPage.totalItems);
      }

      return resultPage.totalItems;
    } catch (e) {
      _log('Erro ao buscar pendentes online: $e');
      return await _getOfflinePendentesCount(userSub);
    }
  }

   Future<int> getTotalEncerrados() async {
    final userSub = await _getLoggedUserSub();
    if (userSub == null) return 0;

    try {
      if (!await _hasConnection()) {
        return await _getOfflineEncerradosCount(userSub);
      }

      final resultPage = await _fetchPage(
        situacao: "ENCERRADA",
        page: 0,
        size: 1,
      );

      return resultPage.totalItems;
    } catch (e) {
      _log('Erro ao buscar encerrados online: $e');
      return await _getOfflineEncerradosCount(userSub);
    }
  }

  Future<void> _checkDiscrepancy(String userSub, int onlineCount) async {
    try {
      final localPage = await LocalDbService.getOfflineRegistrosPaginated(
        userId: userSub,
        situacao: "ABERTA",
        size: 1,
      );

      final respostasPendentes = await LocalDbService.getRespostasPendentes();

      // Se os números forem diferentes OU se tiver algo na fila de envio, force a sincronização!
      if (onlineCount != localPage.totalItems || respostasPendentes.isNotEmpty) {

        _log('⚠️ Gatilho ativado! (Online: $onlineCount, Local: ${localPage.totalItems}, Pendentes: ${respostasPendentes.length})');

        Future.delayed(const Duration(seconds: 3), () {
          syncAllRegistros(forceSync: true);
        });
      }
    } catch (e) {
      _log('Erro ao verificar discrepância: $e');
    }
  }

  Future<int> _getOfflinePendentesCount(String userSub) async {
    final page = await LocalDbService.getOfflineRegistrosPaginated(
      userId: userSub,
      situacao: "ABERTA",
      size: 1,
    );
    return page.totalItems;
  }

  Future<int> _getOfflineEncerradosCount(String userSub) async {
    final page = await LocalDbService.getOfflineRegistrosPaginated(
      userId: userSub,
      situacao: "ENCERRADA",
      size: 1,
    );
    return page.totalItems;
  }

  Future<Registro?> criarRegistroAvulsoOnline(
    String categoria,
    double lat,
    double long,
    String descricao,
  ) async {
    try {
      final url = Uri.parse("$baseUrl/mobile/criar-avulso");
      final payload = {
        'categoria': categoria,
        'latitude': lat,
        'longitude': long,
        'descricao': descricao,
      };

      _log('📤 Criando avulso: $categoria');

      final response = await AuthHttpHelper.post(url, body: payload)
          .timeout(_requestTimeout);

      // Se a API não retornar sucesso (200 ou 201), lança a exceção
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw RegistroServiceException(
          'HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      if (response.body.isEmpty) {
        throw RegistroServiceException('Response vazio');
      }

      try {
        final json = jsonDecode(response.body);
        final registro = Registro.fromJson(json);
        _log('✅ Avulso criado: ${registro.id}');
        return registro;
      } catch (parseError) {
        _log('❌ Erro ao fazer parse JSON: $parseError');
        return null;
      }
    } catch (e) {
      _log('❌ Erro ao criar avulso: $e');

      if (e is RegistroServiceException) {
        rethrow;
      }

      return null;
    }
  }

  Future<RegistroPage> _getOfflineRegistros({
    required String userId,
    int? registroId,
    int? ordemServicoId,
    String? categoria,
    String? situacao,
    required int page,
    required int size,
    required String sort,
  }) async {
    try {
      return await LocalDbService.getOfflineRegistrosPaginated(
        userId: userId,
        registroId: registroId,
        ordemServicoId: ordemServicoId,
        categoria: categoria,
        situacao: situacao,
        page: page,
        size: size,
        sort: sort,
      );
    } catch (e) {
      throw RegistroServiceException('Erro ao buscar offline: $e');
    }
  }

  Map<String, String> _buildQueryParams({
    int? registroId,
    int? ordemServicoId,
    String? categoria,
    String? situacao,
    required int page,
    required int size,
    required String sort,
    String? cacheBuster,
  }) {
    final params = <String, String>{
      "page": page.toString(),
      "size": size.toString(),
      "sort": sort,
    };

    if (registroId != null) {
      params["registroId"] = registroId.toString();
    }

    if (ordemServicoId != null) {
      params["ordemServicoId"] = ordemServicoId.toString();
    }

    if (categoria?.isNotEmpty ?? false) {
      params["categoriaRegistroOcorrencia"] = categoria!;
    }

    if (situacao?.isNotEmpty ?? false) {
      params["situacaoRegistroOcorrencia"] = situacao!;
    }

    if (cacheBuster != null) params["_t"] = cacheBuster;

    return params;
  }

  String _getCacheBuster() => DateTime.now().millisecondsSinceEpoch.toString();

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

  KeycloakException(
    this.message, {
    this.errorCode,
    this.statusCode,
  });

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
