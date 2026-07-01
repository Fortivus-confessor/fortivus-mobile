import 'package:fortivus_app/config/environment_config.dart';
import 'package:fortivus_app/pages/splash_page.dart';
import 'package:fortivus_app/services/sync_service.dart';
import 'package:fortivus_app/config/timezone_config.dart';
import 'package:fortivus_app/config/keycloak_config.dart';
import 'package:fortivus_app/config/app_initializer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fortivus_app/util/app_restart_notifier.dart';
import 'package:fortivus_app/services/background_service.dart';
import 'package:fortivus_app/theme/app_theme.dart';
import 'package:fortivus_app/theme/theme_controller.dart';
import 'package:fortivus_app/services/gps_tracking_service.dart';

/// Controlador global de tema (claro/escuro/sistema), carregado no boot.
final ThemeController themeController = ThemeController.instance;

void _logBootSequence() {
  if (!kDebugMode) return;

  debugPrint('[Main] ========================================');
  debugPrint('[Main] 🚀 FORTIVUS APP - Sequência de Inicialização');
  debugPrint('[Main] ========================================');
  
  TimezoneConfig.debugTimezoneInfo();
  KeycloakConfig.logConfig();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EnvironmentConfig.init();
  await themeController.load();

  _logBootSequence();
  
  await GpsTrackingService.initForegroundTask();

  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final SyncService _syncService;

  @override
  void initState() {
    super.initState();
    _syncService = SyncService();
    _setupAppRestartListener();
  }

  @override
  void dispose() {
    _syncService.stopSync();
    
    try {
      BackgroundSyncService.stopSync();
    } catch (e) {
      if (kDebugMode) debugPrint('[MyApp] Erro ao parar Background Sync: $e');
    }

    appRestartNotifier.removeListener(_onAppRestart);
    super.dispose();
  }

  void _setupAppRestartListener() {
    appRestartNotifier.addListener(_onAppRestart);
  }

  void _onAppRestart() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Key>(
      valueListenable: appRestartNotifier,
      builder: (context, key, _) {
        return ListenableBuilder(
          listenable: themeController,
          builder: (context, _) {
            return MaterialApp(
              key: key,
              debugShowCheckedModeBanner: false,
              title: AppConstants.appName,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('pt', 'BR')],
              locale: const Locale('pt', 'BR'),
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeController.mode,
              home: const SplashPage(),
            );
          },
        );
      },
    );
  }
}