import 'package:workmanager/workmanager.dart';
import 'package:fortivus_app/services/responder/responder_base_service.dart';
import 'package:fortivus_app/services/responder/responder_terrestre_service.dart';
import 'package:fortivus_app/services/responder/responder_maquinario_service.dart';
import 'package:fortivus_app/services/responder/responder_aereo_service.dart';
import 'package:fortivus_app/services/auth_service.dart';
import 'package:fortivus_app/services/local_db_service.dart';
import 'package:fortivus_app/config/environment_config.dart';
import 'package:fortivus_app/services/outbox_sync_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SyncLogger {
  static const String _prefix = '[BackgroundSync]';
  _SyncLogger._();
  static void debug(String msg) { if (kDebugMode) debugPrint('$_prefix 🔍 $msg'); }
  static void info(String msg) { debugPrint('$_prefix ℹ️ $msg'); }
  static void success(String msg) { debugPrint('$_prefix ✅ $msg'); }
  static void warning(String msg) { debugPrint('$_prefix ⚠️ $msg'); }
  static void error(String msg) { debugPrint('$_prefix ❌ $msg'); }
}

ResponderBaseService _createResponderService(String categoria) {
  switch (categoria.toUpperCase()) {
    case 'TERRESTRE': return ResponderTerrestreService();
    case 'AEREO': return ResponderAereoService();
    case 'MAQUINARIO': return ResponderMaquinarioService();
    default: return ResponderTerrestreService();
  }
}

class BackgroundSyncService {
  static const String _syncTaskName = 'syncTask';
  static const String _uniqueTaskName =
      'com.beaifmt.fortivus.${kDebugMode ? 'hom' : 'prod'}.sync';
  static const Duration _syncFrequency = Duration(minutes: 15);
  static const Duration _initialDelay = Duration(minutes: 1);

  BackgroundSyncService._();

  static Future<void> initialize() async {
    try {
      await Workmanager().initialize(callbackDispatcher);
      _SyncLogger.success('Inicializado com sucesso');
    } catch (e) {
      _SyncLogger.error('Erro ao inicializar: $e');
      rethrow;
    }
  }

  static Future<void> registerPeriodicTask() async {
    try {
      await Workmanager().cancelAll();
      await Workmanager().registerPeriodicTask(
        _uniqueTaskName,
        _syncTaskName,
        frequency: _syncFrequency,
        initialDelay: _initialDelay,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
          requiresDeviceIdle: false,
        ),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
        tag: 'sync_${kDebugMode ? 'hom' : 'prod'}',
        inputData: {'apiBaseUrl': EnvironmentConfig.apiBaseUrl},
      );
      _SyncLogger.success('Tarefa periódica registada');
    } catch (e) {
      _SyncLogger.error('Erro ao registar tarefa periódica: $e');
      rethrow;
    }
  }

  static Future<void> stopSync() async {
    try {
      await Workmanager().cancelAll();
    } catch (e) {
      _SyncLogger.error('Erro ao parar sincronização: $e');
    }
  }
}

class _SyncOrchestrator {
  Future<bool> executarSincronizacao() async {
    try {
      if (!await _verificarConectividade()) return false;
      if (!await _verificarAutenticacao()) return true;

      final respostas = await LocalDbService.instance.getRespostasPendentes();
      if (respostas.isEmpty) {
        _SyncLogger.info('Nenhuma resposta pendente');
        return true;
      }

      _SyncLogger.debug('Encontradas ${respostas.length} respostas pendentes');

      final Map<String, List<dynamic>> porCategoria = {};
      for (final r in respostas) {
        porCategoria.putIfAbsent(r.categoria, () => []).add(r);
      }

      for (final entry in porCategoria.entries) {
        try {
          final service = _createResponderService(entry.key);
          await service.sincronizarRespostasPendentes();
          _SyncLogger.success('${entry.key} sincronizado');
        } catch (e) {
          _SyncLogger.error('Erro ao sincronizar ${entry.key}: $e');
        }
      }

      await OutboxSyncService.syncOutbox();
      await OutboxSyncService.syncEvidencias();

      _SyncLogger.success('Ciclo de sincronização concluído');
      return true;
    } catch (e, st) {
      _SyncLogger.error('Erro crítico: $e\n$st');
      return false;
    }
  }

  Future<bool> _verificarConectividade() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  Future<bool> _verificarAutenticacao() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(AuthService.keyIsLoggedIn) ?? false;
      final isOffline = prefs.getBool(AuthService.keyIsOfflineSession) ?? false;
      return isLoggedIn && !isOffline;
    } catch (e) {
      return false;
    }
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    if (taskName != 'syncTask') return false;
    return await _SyncOrchestrator().executarSincronizacao();
  });
}
