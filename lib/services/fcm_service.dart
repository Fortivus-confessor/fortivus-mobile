import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import '../config/environment_config.dart';
import 'auth_service.dart';

class FcmService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final AuthService _authService = AuthService();

  /// Método principal chamado no Login e na Home
  Future<void> registerDevice() async {
    debugPrint('[FCM] 🚀 Iniciando processo de registro de dispositivo...');
    
    try {
      // 1. Solicita permissão
      debugPrint('[FCM] 🔐 Solicitando permissões de notificação...');
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('[FCM] ℹ️ Status da autorização: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('[FCM] ❌ Permissão TOTALMENTE negada pelo usuário.');
        return;
      }

      // 2. Obtém o Token FCM
      debugPrint('[FCM] 📡 Buscando Token FCM no Google Services...');
      String? fcmToken;
      
      try {
        fcmToken = await _firebaseMessaging.getToken();
      } catch (e) {
        debugPrint('[FCM] 🚨 Erro específico ao obter token: $e');
        debugPrint('[FCM] 💡 Dica: Verifique se o google-services.json está correto e se o Google Play Services está atualizado.');
      }
      
      if (fcmToken != null) {
        debugPrint('[FCM] 🎫 Token obtido com sucesso: ${fcmToken.substring(0, 15)}...');

        await _sendTokenToBackend(fcmToken);
      } else {
        debugPrint('[FCM] ⚠️ Falha crítica: O Google retornou um token NULO.');
      }

      // 3. Ouvinte de atualização
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        debugPrint('[FCM] 🔄 O Google atualizou o token. Re-enviando ao backend...');
        _sendTokenToBackend(newToken);
      });

    } catch (e, stacktrace) {
      debugPrint('[FCM] 💥 EXCEÇÃO NÃO TRATADA no registerDevice: $e');
      debugPrint('[FCM] 📂 Stacktrace: $stacktrace');
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      debugPrint('[FCM] 🔑 Recuperando Access Token (JWT) do AuthService...');
      final String? jwt = await _authService.getAccessToken();
      
      if (jwt == null) {
        debugPrint('[FCM] ⚠️ JWT NULO. O usuário pode estar em sessão offline ou deslogado. Abortando envio.');
        return;
      }

      debugPrint('[FCM] 📱 Coletando informações do hardware...');
      String modelo = await _getDeviceModel();
      String plataforma = Platform.isAndroid ? 'android' : 'ios';
      
      final url = Uri.parse('${EnvironmentConfig.apiBaseUrl}/devices/register');
      debugPrint('[FCM] 🌐 URL de destino: $url');

      debugPrint('[FCM] 📤 Enviando POST para o backend...');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
        body: jsonEncode({
          'token': token,
          'plataforma': plataforma,
          'modelo': modelo,
        }),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Tempo de conexão esgotado ao falar com o backend.');
      });

      debugPrint('[FCM] 📥 Resposta recebida. Status Code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[FCM] ✅ SUCESSO! Dispositivo registrado na tabela combate.usuario_device_tokens');
      } else if (response.statusCode == 401) {
        debugPrint('[FCM] ❌ ERRO 401: Token JWT recusado pelo Spring Security.');
      } else if (response.statusCode == 404) {
        debugPrint('[FCM] ❌ ERRO 404: Endpoint /devices/register não encontrado. Verifique o Controller Java.');
      } else {
        debugPrint('[FCM] ⚠️ Erro inesperado: ${response.body}');
      }
      
    } catch (e) {
      debugPrint('[FCM] ❌ FALHA na comunicação com o backend: $e');
    }
  }

  Future<String> _getDeviceModel() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        debugPrint('[FCM] 🤖 Hardware Android detectado: ${androidInfo.model}');
        return '${androidInfo.manufacturer} ${androidInfo.model}';
      } else {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.utsname.machine;
      }
    } catch (e) {
      debugPrint('[FCM] Erro ao ler modelo: $e');
      return 'Desconhecido';
    }
  }

  Future<void> unregisterDevice() async {
    try {
      if (kDebugMode) debugPrint('[FCM] 🗑️ Solicitando desregistro do dispositivo no backend...');
      String? token = await FirebaseMessaging.instance.getToken();
      if (token == null) {
        if (kDebugMode) debugPrint('[FCM] Nenhum token encontrado para desregistrar.');
        return;
      }
      final accessToken = await AuthService().getAccessToken();
      if (accessToken == null) return; 
      final response = await http.delete(
        Uri.parse('${EnvironmentConfig.apiBaseUrl}/devices/unregister?token=$token'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (kDebugMode) debugPrint('[FCM] ✅ Dispositivo desvinculado do usuário com sucesso.');
      } else {
        if (kDebugMode) debugPrint('[FCM] ⚠️ Falha ao desvincular. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] ❌ Erro ao desregistrar dispositivo: $e');
    }
  }

}