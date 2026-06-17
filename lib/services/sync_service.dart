
import 'dart:async';
import 'package:fortivus_app/enums/tipo_categoria_formulario.dart';
import 'package:fortivus_app/services/responder/responder_base_service.dart';
import 'package:fortivus_app/services/responder/responder_terrestre_service.dart';
import 'package:fortivus_app/services/responder/responder_maquinario_service.dart';
import 'package:fortivus_app/services/responder/responder_aereo_service.dart';
import 'package:fortivus_app/services/responder/responder_ronda_service.dart';
import 'package:fortivus_app/services/responder/responder_conscientizacao_service.dart';
import 'package:fortivus_app/services/responder/responder_formacao_brigadista_service.dart';
import 'package:fortivus_app/services/auth_service.dart';
import 'package:fortivus_app/services/local_db_service.dart';
import 'package:fortivus_app/services/file_upload_queue_service.dart';
import 'package:fortivus_app/config/environment_config.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../model/registro.dart';

// ============================================================================
// ENUMS E CONSTANTS
// ============================================================================

enum SyncMode { complete, rapid }

class SyncConstants {
  static const Duration syncInterval = Duration(minutes: 15);
  static const Duration debounceDelay = Duration(seconds: 2);
  static const Duration uploadTimeout = Duration(seconds: 60);
  static const Duration fetchTimeout = Duration(seconds: 30);
  static const int maxErrorCount = 3;
  static const int maxRegistrosPerPage = 100;
  
  static const String imageOriginLabel = 'IMAGEM_ORIGEM';
  static const String attachmentLabel = 'ARQUIVO_ANEXO';

  SyncConstants._();
}

// ============================================================================
// VALUE OBJECTS (IMUTÁVEIS)
// ============================================================================

class SyncResult {
  final bool success;
  final int successCount;
  final int failureCount;
  final String? error;

  const SyncResult({
    required this.success,
    required this.successCount,
    required this.failureCount,
    this.error,
  });

  bool get hasFailed => failureCount > 0;
  int get total => successCount + failureCount;

  @override
  String toString() => 'SyncResult(success: $success, total: $total, errors: $failureCount)';
}

class UploadResult {
  final bool success;
  final String? error;

  const UploadResult({required this.success, this.error});

  @override
  String toString() => 'UploadResult(success: $success, error: $error)';
}

class FetchResult {
  final bool success;
  final int registrosSincronizados;
  final String? error;

  const FetchResult({
    required this.success,
    required this.registrosSincronizados,
    this.error,
  });

  @override
  String toString() => 'FetchResult(success: $success, registros: $registrosSincronizados)';
}

// ============================================================================
// ABSTRAÇÕES (DIP - Dependency Inversion Principle)
// ============================================================================

abstract class IConnectivityProvider {
  Future<bool> hasConnection();
  Stream<List<ConnectivityResult>> get onConnectivityChanged;
}

class ConnectivityProvider implements IConnectivityProvider {
  final Connectivity _connectivity = Connectivity();

  @override
  Future<bool> hasConnection() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
}

abstract class IPreferencesProvider {
  Future<String?> getUserSub();
  Future<void> setLastSyncTime(DateTime time);
  Future<DateTime?> getLastSyncTime();
}

class PreferencesProvider implements IPreferencesProvider {
  static const String _lastSyncKey = 'last_sync_timestamp';

  @override
  Future<String?> getUserSub() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AuthService.keyCurrentUserSub);
  }

  @override
  Future<void> setLastSyncTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, time.toUtc().toIso8601String());
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeStr = prefs.getString(_lastSyncKey);
    return timeStr != null ? DateTime.parse(timeStr) : null;
  }
}

// ============================================================================
// LOGGER (SRP - Single Responsibility)
// ============================================================================

class _SyncLogger {
  static const String _prefix = '[SyncService]';

  _SyncLogger._(); // ✅ Private constructor

  static void debug(String message) {
    if (kDebugMode) debugPrint('$_prefix 🔍 $message');
  }

  static void info(String message) {
    debugPrint('$_prefix ℹ️ $message');
  }

  static void success(String message) {
    debugPrint('$_prefix ✅ $message');
  }

  static void warning(String message) {
    debugPrint('$_prefix ⚠️ $message');
  }

  static void error(String message) {
    debugPrint('$_prefix ❌ $message');
  }
}

// ============================================================================
// REPOSITÓRIO DE SERVICES (FACTORY + STRATEGY)
// ============================================================================

class _ResponderServiceRepository {
  static final Map<TipoCategoriaFormulario, ResponderBaseService> _cache = {};

  static ResponderBaseService getService(TipoCategoriaFormulario categoria) {
    return _cache.putIfAbsent(
      categoria,
      () => _createService(categoria),
    );
  }

  static ResponderBaseService _createService(TipoCategoriaFormulario categoria) {
    return switch (categoria) {
      TipoCategoriaFormulario.terrestre => ResponderTerrestreService(),
      TipoCategoriaFormulario.maquinario => ResponderMaquinarioService(),
      TipoCategoriaFormulario.aereo => ResponderAereoService(),
      TipoCategoriaFormulario.ronda => ResponderRondaService(),
      TipoCategoriaFormulario.conscientizacao => ResponderConscientizacaoService(),
      TipoCategoriaFormulario.formacao => ResponderFormacaoService(), 
    };
  }
}

// ============================================================================
// VALIDADOR (SRP - Single Responsibility)
// ============================================================================

class _SyncValidator {
  final IConnectivityProvider _connectivityProvider;

  _SyncValidator({
    required IConnectivityProvider connectivityProvider,
  }) : _connectivityProvider = connectivityProvider;

  Future<bool> canSync() async {
    return await _connectivityProvider.hasConnection();
  }

  Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(AuthService.keyIsLoggedIn) ?? false;
      final isOffline = prefs.getBool(AuthService.keyIsOfflineSession) ?? false;
      return isLoggedIn && !isOffline;
    } catch (e) {
      _SyncLogger.error('Erro ao validar autenticação: $e');
      return false;
    }
  }

  Future<bool> validatePreconditions() async {
    if (!await canSync()) {
      _SyncLogger.warning('Sem conexão de internet');
      return false;
    }

    if (!await isAuthenticated()) {
      _SyncLogger.warning('Usuário não autenticado');
      return false;
    }

    return true;
  }
}

// ============================================================================
// ORCHESTRADOR (SRP - Orquestra o fluxo de sync)
// ============================================================================

class _SyncOrchestrator {
  final _SyncValidator _validator;
  final FileUploadQueueService _uploadQueueService;
  final IPreferencesProvider _preferencesProvider;
  final AuthService _authService;

  _SyncOrchestrator({
    required _SyncValidator validator,
    required FileUploadQueueService uploadQueueService,
    required IPreferencesProvider preferencesProvider,
    required AuthService authService,
  })  : _validator = validator,
        _uploadQueueService = uploadQueueService,
        _preferencesProvider = preferencesProvider,
        _authService = authService;

  Future<SyncResult> execute(SyncMode mode) async {
    try {
      _SyncLogger.info('Iniciando sincronização (modo: ${mode.name})');

      if (!await _validator.validatePreconditions()) {
        return _failResult('Validação falhou');
      }

      int totalSuccess = 0;
      int totalFailures = 0;

      final respResult = await _syncResponses();
      totalSuccess += respResult.successCount; 
      totalFailures += respResult.failureCount;  

      final uploadResult = await _processUploads();
      totalSuccess += uploadResult.successCount; 
      totalFailures += uploadResult.failureCount;  
      if (mode == SyncMode.complete) {
        final fetchResult = await _fetchNewRegistrosWithCount();
        totalSuccess += fetchResult.registrosSincronizados;  
        if (!fetchResult.success) {
          totalFailures += 1;  
        }
      }

      await LocalDbService.limparRegistrosEncerradosESincronizados();
      await _preferencesProvider.setLastSyncTime(DateTime.now());

      final result = SyncResult(
        success: totalFailures == 0,
        successCount: totalSuccess, 
        failureCount: totalFailures,  
      );

      _SyncLogger.success('Sincronização concluída: $result');
      return result;
    } catch (e, st) {
      _SyncLogger.error('Erro crítico: $e\n$st');
      return _failResult(e.toString());
    }
  }

  Future<SyncResult> _syncResponses() async {
    try {
      final respostas = await LocalDbService.getRespostasPendentes();

      if (respostas.isEmpty) {
        _SyncLogger.debug('Nenhuma resposta pendente');
        return _successResult(0);
      }
      _SyncLogger.info('Sincronizando ${respostas.length} resposta(s)');
      await _syncRespostasByCategoria(respostas);
      return _successResult(respostas.length);
    } catch (e) {
      _SyncLogger.error('Erro ao sincronizar respostas: $e');
      return _failResult(e.toString());
    }
  }

  Future<void> _syncRespostasByCategoria(List<Map<String, dynamic>> respostas) async {
    final Map<TipoCategoriaFormulario, List<Map<String, dynamic>>> porCategoria = {};

    // TRADUTOR SEGURO
    TipoCategoriaFormulario parseCategoriaSeguro(String? catStr) {
      if (catStr == null) return TipoCategoriaFormulario.terrestre;
      final upper = catStr.toUpperCase();
      
      if (upper.contains('MAQUINARIO')) return TipoCategoriaFormulario.maquinario;
      if (upper.contains('AEREO')) return TipoCategoriaFormulario.aereo;
      if (upper.contains('RONDA')) return TipoCategoriaFormulario.ronda;
      if (upper.contains('CONSCIENTIZACAO')) return TipoCategoriaFormulario.conscientizacao;
      if (upper.contains('FORMACAO')) return TipoCategoriaFormulario.formacao;
      
      return TipoCategoriaFormulario.terrestre;
    }

    for (var resposta in respostas) {
      try {
        String? categStr;
        final String? dadosJson = resposta['dados'];
        
        if (dadosJson != null && dadosJson.isNotEmpty) {
          final Map<String, dynamic> dadosDecoded = json.decode(dadosJson);
          categStr = dadosDecoded['metadata_categoria'] as String? ?? dadosDecoded['categoria'] as String?;
        }

        final categ = parseCategoriaSeguro(categStr);
        porCategoria.putIfAbsent(categ, () => []).add(resposta);
      } catch (e) {
        _SyncLogger.warning('Erro ao agrupar resposta: $e');
      }
    }

    for (var entry in porCategoria.entries) {
      try {
        final service = _ResponderServiceRepository.getService(entry.key);
        await service.sincronizarRespostasPendentes();
        _SyncLogger.success('${entry.key.name.toUpperCase()} sincronizado');
      } catch (e) {
        _SyncLogger.error('Erro ao sincronizar ${entry.key.name}: $e');
      }
    }
  }

  Future<SyncResult> _processUploads() async {
    try {
      final fila = await _uploadQueueService.getQueue();

      if (fila.isEmpty) {
        _SyncLogger.debug('Nenhum upload pendente');
        return _successResult(0);
      }

      _SyncLogger.info('Processando ${fila.length} upload(s)');

      int sucessos = 0;
      int falhas = 0;

      for (final upload in fila) {
        try {
          final arquivo = XFile(upload.filePath);

          if (!await _fileExists(arquivo)) {
            _SyncLogger.warning('Arquivo não encontrado: ${arquivo.path}');
            await _uploadQueueService.removeUpload(upload);
            falhas++;
            continue;
          }

          final result = await _uploadFile(
            registroId: upload.registroId,
            arquivo: arquivo,
            fileType: upload.fileType.label,
            categoria: upload.categoria,
          );

          if (result.success) {
            await _uploadQueueService.removeUpload(upload);
            sucessos++;
          } else {
            falhas++;
          }
        } catch (e) {
          _SyncLogger.error('Erro ao processar upload: $e');
          falhas++;
        }
      }

      return SyncResult(
        success: falhas == 0,
        successCount: sucessos,
        failureCount: falhas,
      );
    } catch (e) {
      _SyncLogger.error('Erro crítico em uploads: $e');
      return _failResult(e.toString());
    }
  }

  Future<UploadResult> _uploadFile({
    required int registroId,
    required XFile arquivo,
    required String fileType,
    required String categoria,
  }) async {
    try {
      final url = _buildUploadUrl(registroId, fileType);
      final request = http.MultipartRequest('POST', url);

      await _addAuthHeader(request);

      final bytes = await arquivo.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          _getFieldName(fileType),
          bytes,
          filename: arquivo.name,
        ),
      );

      final response = await http.Response.fromStream(
        await request.send().timeout(SyncConstants.uploadTimeout),
      );

      if (_isSuccessStatus(response.statusCode)) {
        _SyncLogger.success('Upload concluído: ${arquivo.name}');
        return const UploadResult(success: true);
      } else {
        return UploadResult(
          success: false,
          error: 'HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      return UploadResult(success: false, error: e.toString());
    }
  }

  Future<FetchResult> _fetchNewRegistrosWithCount() async {
    try {
      _SyncLogger.debug('Buscando novos registros');

      final userSub = await _preferencesProvider.getUserSub();
      if (userSub == null) {
        _SyncLogger.warning('Usuário não encontrado');
        return const FetchResult(
          success: false,
          registrosSincronizados: 0,
        );
      }

      final token = await _authService.getAccessToken();
      if (token == null) {
        _SyncLogger.warning('Token não disponível');
        return const FetchResult(
          success: false,
          registrosSincronizados: 0,
        );
      }

      final response = await http.get(
        _buildFetchUrl(),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(SyncConstants.fetchTimeout);

      if (response.statusCode == 200) {
        final count = await _processFetchResponse(response, userSub);
        return FetchResult(
          success: true,
          registrosSincronizados: count, 
        );
      } else if (response.statusCode == 401) {
        _SyncLogger.warning('Token expirado, fazendo logout');
        await _authService.logout();
        return const FetchResult(
          success: false,
          registrosSincronizados: 0,
        );
      }

      _SyncLogger.warning('Erro HTTP ${response.statusCode}');
      return const FetchResult(
        success: false,
        registrosSincronizados: 0,
      );
    } catch (e) {
      _SyncLogger.error('Erro ao buscar registros: $e');
      return FetchResult(
        success: false,
        registrosSincronizados: 0,
        error: e.toString(),
      );
    }
  }

  Future<int> _processFetchResponse(
    http.Response response,
    String userSub,
  ) async {
    try {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final registrosData = data['content'] as List<dynamic>? ?? [];

      if (registrosData.isEmpty) {
        _SyncLogger.debug('Nenhum novo registro');
        return 0;  
      }

      final novosRegistros = registrosData
          .whereType<Map<String, dynamic>>()
          .map(Registro.fromMap)
          .toList();

      final registrosNovos = await _filterNewRegistros(novosRegistros);

      if (registrosNovos.isNotEmpty) {
        await LocalDbService.saveRegistros(registrosNovos, userSub);
        _SyncLogger.success('${registrosNovos.length} registro(s) salvado(s)');
        return registrosNovos.length; 
      }

      return 0;  
    } catch (e) {
      _SyncLogger.error('Erro ao processar resposta: $e');
      return 0; 
    }
  }

  Future<List<Registro>> _filterNewRegistros(List<Registro> registros) async {
    try {
      final allLocal = await LocalDbService.getAllRegistros(userId: '');
      final localIds = allLocal.map((r) => r.id).toSet();

      return registros.where((r) => !localIds.contains(r.id)).toList();
    } catch (e) {
      _SyncLogger.error('Erro ao filtrar registros: $e');
      return [];
    }
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  Uri _buildUploadUrl(int registroId, String fileType) {
    final baseUrl = EnvironmentConfig.apiBaseUrl;

    if (fileType == SyncConstants.imageOriginLabel) {
      return Uri.parse(
        '$baseUrl/combate-incendio/terrestre/mobile/$registroId/imagem-origem',
      );
    }
    return Uri.parse(
      '$baseUrl/combate-incendio/mobile/arquivos/$registroId',
    );
  }

  Uri _buildFetchUrl() {
    return Uri.parse(
      '${EnvironmentConfig.apiBaseUrl}/registro_ocorrencia/consultar',
    ).replace(
      queryParameters: {
        'page': '0',
        'size': SyncConstants.maxRegistrosPerPage.toString(),
        'sort': 'desc',
      },
    );
  }

  String _getFieldName(String fileType) {
    return fileType == SyncConstants.imageOriginLabel ? 'file' : 'files';
  }

  bool _isSuccessStatus(int statusCode) =>
      statusCode == 200 || statusCode == 201;

  Future<void> _addAuthHeader(http.BaseRequest request) async {
    final token = await _authService.getAccessToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
  }

  // ✅ CORRIGIDO: Retorna bool, não casting errado
  Future<bool> _fileExists(XFile arquivo) async {
    try {
      final length = await arquivo.length();  // ✅ length retorna int
      return length > 0;  // ✅ int > 0 = bool
    } catch (_) {
      return false;
    }
  }

  SyncResult _successResult(int count) => SyncResult(
    success: true,
    successCount: count,  // ✅ int
    failureCount: 0,
  );

  SyncResult _failResult(String error) => SyncResult(
    success: false,
    successCount: 0,
    failureCount: 1,
    error: error,
  );
}

// ============================================================================
// SERVICE PRINCIPAL (SINGLETON + LIFECYCLE MANAGEMENT)
// ============================================================================

class SyncService with WidgetsBindingObserver {
  static final SyncService _instance = SyncService._internal();

  factory SyncService() => _instance;

  final IConnectivityProvider _connectivityProvider;
  final IPreferencesProvider _preferencesProvider;
  final AuthService _authService = AuthService();

  // ✅ AQUI ESTÁ A MÁGICA: Atribuindo o valor direto na declaração
  late final _SyncValidator _validator = _SyncValidator(
    connectivityProvider: _connectivityProvider,
  );

  late final _SyncOrchestrator _orchestrator = _SyncOrchestrator(
    validator: _validator,
    uploadQueueService: FileUploadQueueService(),
    preferencesProvider: _preferencesProvider,
    authService: _authService,
  );

  SyncService._internal({
    IConnectivityProvider? connectivityProvider,
    IPreferencesProvider? preferencesProvider,
  })  : _connectivityProvider = connectivityProvider ?? ConnectivityProvider(),
        _preferencesProvider = preferencesProvider ?? PreferencesProvider();

  // ============================================================================
  // ESTADO
  // ============================================================================
  bool _isRunning = false;
  bool _isSyncInProgress = false;
  int _syncErrorCount = 0;
  DateTime? _lastSuccessfulSync;

  Timer? _timer;
  Timer? _syncDebounceTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // ============================================================================
  // INICIALIZAÇÃO
  // ============================================================================
  void iniciarSincronizacao() {
    if (_isRunning) {
      _SyncLogger.warning('Sincronização já está em execução');
      return;
    }

    _isRunning = true;

    WidgetsBinding.instance.addObserver(this);

    _SyncLogger.info('========================================');
    _SyncLogger.info('🚀 Sincronização iniciada');
    _SyncLogger.info('⏱️ Intervalo: ${SyncConstants.syncInterval}');
    _SyncLogger.info('========================================');

    _setupConnectivityListener();
    _setupPeriodicSync();
    _executeInitialSync();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription =
        _connectivityProvider.onConnectivityChanged.listen((_) {
      if (_isRunning) _debounceSync();
    });
  }

  void _setupPeriodicSync() {
    _timer?.cancel();
    _timer = Timer.periodic(SyncConstants.syncInterval, (_) {
      if (_isRunning) {
        _SyncLogger.debug('⏰ Timer periódico acionado');
        _debounceSync();
      }
    });
  }

  void _executeInitialSync() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_isRunning) _debounceSync();
    });
  }

  void stopSync() {
    _SyncLogger.info('🛑 Parando sincronização');
    _isRunning = false;
    WidgetsBinding.instance.removeObserver(this);
    _cancelAllTimers();
  }

  void _cancelAllTimers() {
    _timer?.cancel();
    _syncDebounceTimer?.cancel();
    _connectivitySubscription?.cancel();
    _timer = null;
    _syncDebounceTimer = null;
    _connectivitySubscription = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isRunning) {
      _SyncLogger.debug('📱 App em Foreground');
      _debounceSync();
    }
  }

  // ============================================================================
  // DEBOUNCE
  // ============================================================================
  void _debounceSync() {
    _syncDebounceTimer?.cancel();
    _syncDebounceTimer = Timer(SyncConstants.debounceDelay, () async {
      if (await _validator.canSync() && !_isSyncInProgress) {
        await _executeSyncMode(SyncMode.complete);
      }
    });
  }

  // ============================================================================
  // EXECUÇÃO
  // ============================================================================
  Future<SyncResult> _executeSyncMode(SyncMode mode) async {
    if (_isSyncInProgress) {
      _SyncLogger.warning('Sincronização já em progresso');
      return const SyncResult(
        success: false,
        successCount: 0,
        failureCount: 0,
        error: 'Sync em progresso',
      );
    }

    _isSyncInProgress = true;
    try {
      return await _orchestrator.execute(mode);
    } catch (e) {
      _syncErrorCount++;
      _SyncLogger.error('Tentativa $_syncErrorCount: $e');

      if (_syncErrorCount >= SyncConstants.maxErrorCount) {
        _SyncLogger.error('Limite de erros atingido, parando sincronização');
        stopSync();
      }

      return SyncResult(
        success: false,
        successCount: 0,
        failureCount: 1,
        error: e.toString(),
      );
    } finally {
      _isSyncInProgress = false;
      if (_lastSuccessfulSync == null) _syncErrorCount = 0;
    }
  }

  // ============================================================================
  // API PÚBLICA
  // ============================================================================
  Future<SyncResult> syncComplete() => _executeSyncMode(SyncMode.complete);

  Future<SyncResult> syncRapid() => _executeSyncMode(SyncMode.rapid);

  Future<void> forceSyncNow() async {
    if (await _validator.canSync()) {
      await syncComplete();
    } else {
      _SyncLogger.warning('Sem conexão para sincronizar');
    }
  }

  Map<String, dynamic> getStatus() => {
    'running': _isRunning,
    'syncing': _isSyncInProgress,
    'lastSync': _lastSuccessfulSync?.toIso8601String(),
    'errors': '$_syncErrorCount/${SyncConstants.maxErrorCount}',
  };

  void resetErrorCount() {
    _syncErrorCount = 0;
    _SyncLogger.debug('Contador de erros resetado');
  }
}