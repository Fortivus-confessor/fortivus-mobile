import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fortivus_app/services/auth_service.dart';
import 'package:fortivus_app/services/local_db_service.dart';
import 'package:fortivus_app/services/sync_service.dart';
import 'package:fortivus_app/services/background_service.dart';
import 'package:fortivus_app/services/gps_tracking_service.dart';

// ============================================================================
// ABSTRAÇÃO: Service Locator / DI Container
// ============================================================================

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late SyncService _syncService;
  
  SyncService get syncService => _syncService;
  
  Future<void> initialize() async {
    _syncService = SyncService();
  }
  
  void dispose() {
    _syncService.stopSync();
  }
}

// ============================================================================
// CONSTANTS
// ============================================================================

class AppConstants {
  static const String appName = 'Fortivus App';
  static const int currentDbVersion = 11;
  static const String dbVersionKey = 'db_version';
  static const Duration backgroundSyncDelay = Duration(seconds: 5);
}

// ============================================================================
// INICIALIZADORES
// ============================================================================

/// Responsável por inicializar todas as dependências
class AppInitializer {
  static Future<void> initializeAll({required bool isLoggedIn}) async {
    await _initializeFirebase();
    await _initializeDatabase();
    
    if (isLoggedIn) {
      await _initializeSyncServices();
    }
  }

  /// Inicializa Firebase
  static Future<void> _initializeFirebase() async {
    try {
      _log('🔥 Inicializando Firebase...');
      await Firebase.initializeApp();
      _log('✅ Firebase inicializado');
    } catch (e) {
      _log('⚠️ Firebase falhou (Push não funcionará): $e');
      // Continuar sem Firebase (offline first)
    }
  }

  /// Inicializa banco de dados
  static Future<void> _initializeDatabase() async {
    try {
      _log('🗄️ Inicializando banco de dados...');
      final prefs = await SharedPreferences.getInstance();
      final dbVersion = prefs.getInt(AppConstants.dbVersionKey) ?? 0;

      if (dbVersion < AppConstants.currentDbVersion) {
        _log('🔄 Atualizando DB de v$dbVersion → v${AppConstants.currentDbVersion}');
        
        if (dbVersion < 10) {
          await LocalDbService.instance.resetarBancoDados();
        }
        await prefs.setInt(AppConstants.dbVersionKey, AppConstants.currentDbVersion);
      }
      
      _log('✅ Banco de dados pronto');
    } catch (e) {
      _log('❌ Erro ao inicializar DB: $e');
      rethrow;
    }
  }

  /// Inicializa serviços de sincronização
  static Future<void> _initializeSyncServices() async {
    try {
      _log('🔧 Inicializando serviços de sincronização...');
      
      final authService = AuthService();
      final isOffline = await authService.isOfflineSession();

      if (isOffline) {
        _log('📴 Sessão offline - sincronização desativada');
        return;
      }

      // Inicializar Background Sync
      await _initializeBackgroundSync();

      // Iniciar Tracking GPS tático (NOVO OFFLINE-FIRST)
      await GpsTrackingService.startTracking();

      // Inicializar Foreground Sync
      await _initializeForegroundSync();

      // Verificar e sincronizar respostas pendentes
      await _syncPendingResponses();

      _log('✅ Serviços de sincronização prontos');
    } catch (e) {
      _log('⚠️ Erro ao inicializar sincronização: $e');
      // Não falhar - permitir offline
    }
  }

  /// Inicializa sincronização em background
  static Future<void> _initializeBackgroundSync() async {
    try {
      _log('🔌 Inicializando Background Sync...');
      await BackgroundSyncService.initialize();
      
      // Registrar tarefa com delay para não bloquear UI
      Future.delayed(AppConstants.backgroundSyncDelay, () async {
        try {
          await BackgroundSyncService.registerPeriodicTask();
          _log('✅ Tarefa periódica registrada');
        } catch (e) {
          _log('⚠️ Erro ao registrar tarefa: $e');
        }
      });
    } catch (e) {
      _log('⚠️ Erro em Background Sync: $e');
    }
  }

  /// Inicializa sincronização em foreground
  static Future<void> _initializeForegroundSync() async {
    try {
      _log('🔄 Inicializando Foreground Sync...');
      
      final syncService = SyncService();
      syncService.iniciarSincronizacao();
      
      _log('✅ Sync Service iniciado');
    } catch (e) {
      _log('⚠️ Erro em Foreground Sync: $e');
      rethrow;
    }
  }

  /// Sincroniza respostas pendentes
  static Future<void> _syncPendingResponses() async {
    try {
      final pendentes = await LocalDbService.instance.getRespostasPendentes();
      
      if (pendentes.isEmpty) {
        _log('ℹ️ Nenhuma resposta pendente');
        return;
      }

      _log('📤 ${pendentes.length} resposta(s) pendente(s) - sincronizando...');
      
      final syncService = SyncService();
      await syncService.forceSyncNow();
      
      _log('✅ Respostas pendentes sincronizadas');
    } catch (e) {
      _log('⚠️ Erro ao sincronizar pendentes: $e');
    }
  }

  static void _log(String msg) {
    if (kDebugMode) {
      debugPrint('[AppInitializer] $msg');
    }
  }
}
