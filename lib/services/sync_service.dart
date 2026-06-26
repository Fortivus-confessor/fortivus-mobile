import 'dart:async';
import 'package:fortivus_app/services/outbox_sync_service.dart';
import 'package:fortivus_app/services/responder/responder_base_service.dart';
import 'package:fortivus_app/services/responder/responder_terrestre_service.dart';
import 'package:fortivus_app/services/responder/responder_maquinario_service.dart';
import 'package:fortivus_app/services/responder/responder_aereo_service.dart';
import 'package:fortivus_app/services/auth_service.dart';
import 'package:fortivus_app/services/local_db_service.dart';
import 'package:fortivus_app/services/registro_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SyncMode { complete, rapid }

class SyncConstants {
  static const Duration syncInterval = Duration(minutes: 15);
  static const Duration debounceDelay = Duration(seconds: 2);
  static const int maxErrorCount = 3;
  SyncConstants._();
}

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
  String toString() =>
      'SyncResult(success: $success, total: $total, errors: $failureCount)';
}

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

class _SyncLogger {
  static const String _prefix = '[SyncService]';
  _SyncLogger._();
  static void debug(String message) {
    if (kDebugMode) debugPrint('$_prefix 🔍 $message');
  }

  static void info(String message) => debugPrint('$_prefix ℹ️ $message');
  static void success(String message) => debugPrint('$_prefix ✅ $message');
  static void warning(String message) => debugPrint('$_prefix ⚠️ $message');
  static void error(String message) => debugPrint('$_prefix ❌ $message');
}

class _ResponderServiceRepository {
  static final Map<String, ResponderBaseService> _cache = {};

  static ResponderBaseService getService(String categoria) {
    return _cache.putIfAbsent(categoria, () => _createService(categoria));
  }

  static ResponderBaseService _createService(String categoria) {
    switch (categoria.toUpperCase()) {
      case 'AEREO':
        return ResponderAereoService();
      case 'MAQUINARIO':
        return ResponderMaquinarioService();
      default:
        return ResponderTerrestreService();
    }
  }
}

class _SyncValidator {
  final IConnectivityProvider _connectivityProvider;

  _SyncValidator({required IConnectivityProvider connectivityProvider})
      : _connectivityProvider = connectivityProvider;

  Future<bool> canSync() async => _connectivityProvider.hasConnection();

  Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(AuthService.keyIsLoggedIn) ?? false;
      final isOffline = prefs.getBool(AuthService.keyIsOfflineSession) ?? false;
      return isLoggedIn && !isOffline;
    } catch (e) {
      return false;
    }
  }

  Future<bool> validatePreconditions() async {
    if (!await canSync()) {
      _SyncLogger.warning('Sem conexão');
      return false;
    }
    if (!await isAuthenticated()) {
      _SyncLogger.warning('Não autenticado');
      return false;
    }
    return true;
  }
}

class _SyncOrchestrator {
  final _SyncValidator _validator;
  final IPreferencesProvider _preferencesProvider;

  _SyncOrchestrator({
    required _SyncValidator validator,
    required IPreferencesProvider preferencesProvider,
  })  : _validator = validator,
        _preferencesProvider = preferencesProvider;

  Future<SyncResult> execute(SyncMode mode) async {
    try {
      if (!await _validator.validatePreconditions()) {
        return _failResult('Validação falhou');
      }

      final respResult = await _syncResponses();

      if (mode == SyncMode.complete) {
        RegistroService().syncAllRegistros(forceSync: true);
      }

      await OutboxSyncService.syncEvidencias();
      await LocalDbService.instance.limparConcluidosSincronizados();
      await _preferencesProvider.setLastSyncTime(DateTime.now());

      return SyncResult(
        success: respResult.failureCount == 0,
        successCount: respResult.successCount,
        failureCount: respResult.failureCount,
      );
    } catch (e, st) {
      _SyncLogger.error('Erro crítico: $e\n$st');
      return _failResult(e.toString());
    }
  }

  Future<SyncResult> _syncResponses() async {
    try {
      final respostas = await LocalDbService.instance.getRespostasPendentes();
      if (respostas.isEmpty) return _successResult(0);

      _SyncLogger.info('Sincronizando ${respostas.length} resposta(s)');

      final Map<String, List<dynamic>> porCategoria = {};
      for (final r in respostas) {
        porCategoria.putIfAbsent(r.categoria, () => []).add(r);
      }

      int falhas = 0;
      for (final entry in porCategoria.entries) {
        try {
          final service = _ResponderServiceRepository.getService(entry.key);
          await service.sincronizarRespostasPendentes();
          _SyncLogger.success('${entry.key} sincronizado');
        } catch (e) {
          _SyncLogger.error('Erro ao sincronizar ${entry.key}: $e');
          falhas++;
        }
      }

      return SyncResult(
        success: falhas == 0,
        successCount: respostas.length - falhas,
        failureCount: falhas,
      );
    } catch (e) {
      return _failResult(e.toString());
    }
  }

  SyncResult _successResult(int count) =>
      SyncResult(success: true, successCount: count, failureCount: 0);

  SyncResult _failResult(String error) =>
      SyncResult(success: false, successCount: 0, failureCount: 1, error: error);
}

class SyncService with WidgetsBindingObserver {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;

  final IConnectivityProvider _connectivityProvider;
  final IPreferencesProvider _preferencesProvider;

  late final _SyncValidator _validator = _SyncValidator(
    connectivityProvider: _connectivityProvider,
  );
  late final _SyncOrchestrator _orchestrator = _SyncOrchestrator(
    validator: _validator,
    preferencesProvider: _preferencesProvider,
  );

  SyncService._internal({
    IConnectivityProvider? connectivityProvider,
    IPreferencesProvider? preferencesProvider,
  })  : _connectivityProvider = connectivityProvider ?? ConnectivityProvider(),
        _preferencesProvider = preferencesProvider ?? PreferencesProvider();

  bool _isRunning = false;
  bool _isSyncInProgress = false;
  int _syncErrorCount = 0;
  DateTime? _lastSuccessfulSync;

  Timer? _timer;
  Timer? _syncDebounceTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  void iniciarSincronizacao() {
    if (_isRunning) return;
    _isRunning = true;
    WidgetsBinding.instance.addObserver(this);
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
      if (_isRunning) _debounceSync();
    });
  }

  void _executeInitialSync() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_isRunning) _debounceSync();
    });
  }

  void stopSync() {
    _isRunning = false;
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _syncDebounceTimer?.cancel();
    _connectivitySubscription?.cancel();
    _timer = null;
    _syncDebounceTimer = null;
    _connectivitySubscription = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isRunning) _debounceSync();
  }

  void _debounceSync() {
    _syncDebounceTimer?.cancel();
    _syncDebounceTimer = Timer(SyncConstants.debounceDelay, () async {
      if (await _validator.canSync() && !_isSyncInProgress) {
        await _executeSyncMode(SyncMode.complete);
      }
    });
  }

  Future<SyncResult> _executeSyncMode(SyncMode mode) async {
    if (_isSyncInProgress) {
      return const SyncResult(
          success: false, successCount: 0, failureCount: 0, error: 'Sync em progresso');
    }
    _isSyncInProgress = true;
    try {
      final result = await _orchestrator.execute(mode);
      if (result.success) _lastSuccessfulSync = DateTime.now();
      return result;
    } catch (e) {
      _syncErrorCount++;
      if (_syncErrorCount >= SyncConstants.maxErrorCount) stopSync();
      return SyncResult(
          success: false, successCount: 0, failureCount: 1, error: e.toString());
    } finally {
      _isSyncInProgress = false;
    }
  }

  Future<SyncResult> syncComplete() => _executeSyncMode(SyncMode.complete);
  Future<SyncResult> syncRapid() => _executeSyncMode(SyncMode.rapid);

  Future<void> forceSyncNow() async {
    if (await _validator.canSync()) await syncComplete();
  }

  Map<String, dynamic> getStatus() => {
        'running': _isRunning,
        'syncing': _isSyncInProgress,
        'lastSync': _lastSuccessfulSync?.toIso8601String(),
        'errors': '$_syncErrorCount/${SyncConstants.maxErrorCount}',
      };

  void resetErrorCount() => _syncErrorCount = 0;
}
