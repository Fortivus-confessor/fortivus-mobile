import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fortivus_app/services/local_db_service.dart';
import 'package:fortivus_app/config/environment_config.dart';
import 'dart:convert';
import 'dart:isolate';

// O isolado do Foreground Task
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(GpsTaskHandler());
}

class GpsTaskHandler extends TaskHandler {
  StreamSubscription<Position>? _positionStream;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    debugPrint('[GpsTracking] Serviço em foreground iniciado');
    
    // Configuração do fluxo de localização
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Notifica a cada 10 metros
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) async {
      if (position != null) {
        debugPrint('[GpsTracking] Nova localização: ${position.latitude}, ${position.longitude}');
        
        // Salva na Outbox para sincronização
        try {
          final db = await LocalDbService.database;
          final payload = jsonEncode({
            'latitude': position.latitude,
            'longitude': position.longitude,
            'timestamp': position.timestamp.toIso8601String(),
            'speed': position.speed,
            'heading': position.heading,
          });

          await db.insert('outbox_table', {
            'metodo': 'POST',
            'endpoint': '${EnvironmentConfig.apiBaseUrl}/tracking/location',
            'payload': payload,
            'dataCriacao': DateTime.now().toIso8601String(),
            'status': 'PENDENTE'
          });
          
          FlutterForegroundTask.updateService(
            notificationTitle: 'Fortivus Rastreamento Ativo',
            notificationText: 'Última coord: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
          );
        } catch (e) {
          debugPrint('[GpsTracking] Erro ao salvar localização: $e');
        }
      }
    });
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    // Evento periódico (opcional)
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    await _positionStream?.cancel();
    debugPrint('[GpsTracking] Serviço em foreground encerrado');
  }

  @override
  void onButtonPressed(String id) {
    debugPrint('[GpsTracking] Botão da notificação pressionado: $id');
  }

  @override
  void onNotificationPressed() {
    debugPrint('[GpsTracking] Notificação pressionada');
  }
}

class GpsTrackingService {
  static Future<void> initForegroundTask() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        id: 500,
        channelId: 'fortivus_tracking_channel',
        channelName: 'Rastreamento Tático',
        channelDescription: 'Esta notificação mantem o envio do GPS em segundo plano.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  static Future<void> startTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('[GpsTracking] Serviços de localização desabilitados.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    if (await FlutterForegroundTask.isRunningService) {
      debugPrint('[GpsTracking] Serviço já está rodando');
      return;
    }

    await FlutterForegroundTask.startService(
      notificationTitle: 'Fortivus Rastreamento Ativo',
      notificationText: 'Capturando coordenadas em tempo real...',
      callback: startCallback,
    );
  }

  static Future<void> stopTracking() async {
    await FlutterForegroundTask.stopService();
  }
}
