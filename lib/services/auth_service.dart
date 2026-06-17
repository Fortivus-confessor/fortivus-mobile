import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:fortivus_app/pages/login_webview_page.dart';
import 'package:fortivus_app/services/fcm_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'local_db_service.dart';
import 'registro_service.dart';
import '../model/user.dart';
import '../config/keycloak_config.dart';
import '../config/environment_config.dart';

class AuthService {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final FlutterAppAuth appAuth = const FlutterAppAuth();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyIdToken = 'id_token';
  static const String keyCurrentUserSub = 'current_user_sub';
  static const String keyIsOfflineSession = 'is_offline_session';

  static String get apiBaseUrl => EnvironmentConfig.apiBaseUrl;

  bool _isLoginInProgress = false;
  bool _isTokenRenewalInProgress = false;
  DateTime? _lastTokenRenewal;
  static const Duration _minRenewalInterval = Duration(seconds: 30);

  final _authErrorController = StreamController<void>.broadcast();
  Stream<void> get onAuthError => _authErrorController.stream;

  void reportAuthenticationError() {
    if (!_authErrorController.isClosed) {
      _authErrorController.add(null);
    }
  }

  bool _canAttemptRenewal() {
    if (_lastTokenRenewal == null) return true;
    return DateTime.now().difference(_lastTokenRenewal!) > _minRenewalInterval;
  }

  void _markRenewalAttempt() {
    _lastTokenRenewal = DateTime.now();
  }

  Future<bool> isOfflineSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsOfflineSession) ?? false;
  }

  Future<User?> loginOffline(String identifier, String password) async {
    if (kDebugMode) {
      debugPrint('[AuthService] 🔒 Tentando login offline unificado para: $identifier');
    }

    try {
      // 1. Delega a validação segura para o LocalDbService (suporta E-mail ou Matrícula)
      final user = await LocalDbService.authenticateUserOffline(identifier, password);

      if (user == null) {
        if (kDebugMode) {
          debugPrint('[AuthService] ❌ Credenciais inválidas ou usuário não encontrado.');
        }
        return null;
      }

      // 2. Autenticação validada! Configura a sessão local.
      final prefs = await SharedPreferences.getInstance();
      
      // Salva o sub do Keycloak (fallback para o ID caso o sub não esteja preenchido)
      final userIdentifier = user.sub ?? user.id;
      if (userIdentifier != null) {
        await prefs.setString(keyCurrentUserSub, userIdentifier);
      }
      
      await prefs.setBool(keyIsOfflineSession, true);
      await prefs.setBool(keyIsLoggedIn, true);

      if (kDebugMode) {
        debugPrint('[AuthService] ✅ Login offline bem-sucedido para: ${user.nome}');
      }

      return user;
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AuthService] ❌ Erro estrutural durante o login offline: $e');
      }
      return null;
    }
  }

  String _generateCodeVerifier() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64UrlEncode(values).replaceAll('=', '').replaceAll('+', '-').replaceAll('/', '_');
  }

  String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '').replaceAll('+', '-').replaceAll('/', '_');
  }

  // ✅ LOGIN ONLINE (sem gerar credenciais offline automaticamente)
  Future<bool> login(BuildContext context) async {
    if (_isLoginInProgress) {
      if (kDebugMode) {
        debugPrint('[AuthService] Login online já está em progresso.');
      }
      return false;
    }

    _isLoginInProgress = true;

    try {
      if (kDebugMode) {
        debugPrint('[AuthService] 🌐 Iniciando processo de login online via Keycloak...');
      }

      await _clearSessionData();

      String? accessToken;
      String? refreshToken;
      String? idToken;

      bool useWebView = false;
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        final sdkInt = androidInfo.version.sdkInt;
        if (sdkInt == 33 || sdkInt == 34) {
          useWebView = true;
        }
      }

      if (useWebView) {
        if (kDebugMode) debugPrint('[AuthService] 📱 Android 13/14 detectado. Usando LoginWebViewPage com PKCE manual.');
        
        final codeVerifier = _generateCodeVerifier();
        final codeChallenge = _generateCodeChallenge(codeVerifier);
        final state = _generateCodeVerifier(); // Usando a mesma lógica para o state

        final authorizationUrl = Uri.parse(KeycloakConfig.authorizationEndpoint).replace(queryParameters: {
          'client_id': KeycloakConfig.clientId,
          'redirect_uri': KeycloakConfig.redirectUri,
          'response_type': 'code',
          'scope': KeycloakConfig.scopes.join(' '),
          'state': state,
          'code_challenge': codeChallenge,
          'code_challenge_method': 'S256',
          'prompt': 'login',
        }).toString();

        if (!context.mounted) return false;

        final resultUri = await Navigator.push<Uri>(
          context,
          MaterialPageRoute(
            builder: (context) => LoginWebViewPage(
              authorizationUrl: authorizationUrl,
              redirectUri: KeycloakConfig.redirectUri,
            ),
          ),
        );

        if (resultUri != null && resultUri.queryParameters.containsKey('code')) {
          final code = resultUri.queryParameters['code']!;
          
          // Troca o código pelo token
          final tokenResponse = await http.post(
            Uri.parse(KeycloakConfig.tokenEndpoint),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {
              'grant_type': 'authorization_code',
              'client_id': KeycloakConfig.clientId,
              'redirect_uri': KeycloakConfig.redirectUri,
              'code': code,
              'code_verifier': codeVerifier,
            },
          ).timeout(const Duration(seconds: 30));

          if (tokenResponse.statusCode == 200) {
            final data = json.decode(tokenResponse.body);
            accessToken = data['access_token'];
            refreshToken = data['refresh_token'];
            idToken = data['id_token'];
          } else {
            if (kDebugMode) debugPrint('[AuthService] ❌ Falha na troca do código: ${tokenResponse.body}');
            return false;
          }
        } else {
          if (kDebugMode) debugPrint('[AuthService] ❌ Login cancelado ou falhou na WebView.');
          return false;
        }
      } else {
        final result = await appAuth.authorizeAndExchangeCode(
          AuthorizationTokenRequest(
            KeycloakConfig.clientId,
            KeycloakConfig.redirectUri,
            serviceConfiguration: AuthorizationServiceConfiguration(
              authorizationEndpoint: KeycloakConfig.authorizationEndpoint,
              tokenEndpoint: KeycloakConfig.tokenEndpoint,
              endSessionEndpoint: KeycloakConfig.endSessionEndpoint,
            ),
            scopes: KeycloakConfig.scopes,
            promptValues: ['login'],
            allowInsecureConnections: KeycloakConfig.allowInsecureConnections,
            additionalParameters: {
              'clock_skew_leeway': KeycloakConfig.clockSkewLeeway,
              'max_age': '0',
            },
          ),
        );
        accessToken = result.accessToken;
        refreshToken = result.refreshToken;
        idToken = result.idToken;
      }

      if (accessToken == null) {
        if (kDebugMode) {
          debugPrint('[AuthService] ❌ Login online falhou: Nenhum access token recebido.');
        }
        return false;
      }

      // ✅ SALVAR NO FlutterSecureStorage
      await Future.wait([
        secureStorage.write(key: keyAccessToken, value: accessToken),
        if (refreshToken != null)
          secureStorage.write(key: keyRefreshToken, value: refreshToken),
        if (idToken != null)
          secureStorage.write(key: keyIdToken, value: idToken),
      ]);
      
      if (kDebugMode) {
        debugPrint('[AuthService] 💾 Tokens de sessão online salvos com sucesso no SecureStorage.');
      }

      return await _fetchAndSaveUserInfo(accessToken);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AuthService] ❌ Erro durante o login online: $e');
      }
      return false;
    } finally {
      _isLoginInProgress = false;
    }
  }

  Future<bool> _fetchAndSaveUserInfo(String accessToken) async {
      try {
        if (kDebugMode) {
          debugPrint('[AuthService] 📥 Iniciando fetch de informações do usuário');
        }
        
        final apiResponse = await http.get(
          Uri.parse('$apiBaseUrl/auth/me'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 30));
        if (apiResponse.statusCode == 200) {
          final Map<String, dynamic> apiUserData = json.decode(apiResponse.body);
          final decodedToken = JwtDecoder.decode(accessToken);
          apiUserData['token'] = accessToken;
          apiUserData['sub'] = decodedToken['sub'];
          if (kDebugMode) {
            debugPrint('[AuthService] 📄 Dados recebidos para: ${apiUserData['email']}');
          }
          final user = User.fromJson(apiUserData);
          await LocalDbService.saveUser(user);
          if (kDebugMode) {
            debugPrint('[AuthService] ✅ Usuário e credencial offline (Hash) salvos com sucesso.');
          }
          final prefs = await SharedPreferences.getInstance();
          final userIdentifier = user.sub ?? user.id;
          if (userIdentifier != null) {
            await prefs.setString(keyCurrentUserSub, userIdentifier);
          }
          await prefs.setBool(keyIsOfflineSession, false);
          await prefs.setBool(keyIsLoggedIn, true);
          if (kDebugMode) debugPrint('[AuthService] ✅ Sessão online ativa.');
          return true;
        } else {
          if (kDebugMode) {
            debugPrint('[AuthService] ❌ Erro na API: ${apiResponse.statusCode}');
          }
          return false;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[AuthService] ❌ Erro ao buscar e salvar dados do usuário: $e');
        }
        return false;
      }
    }

  Future<void> logout() async {
    try {
      if (kDebugMode) debugPrint('[AuthService] 🚪 Logout: Iniciando encerramento da sessão...');
      final prefs = await SharedPreferences.getInstance();
      final isOfflineSession = prefs.getBool(keyIsOfflineSession) ?? false;
      
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasInternet = !connectivityResult.contains(ConnectivityResult.none);
      
      // 1. Tenta avisar o backend que o token do usuario deve ser descontinuado (se houver internet)
      if (!isOfflineSession && hasInternet) {
        try {
          await FcmService().unregisterDevice();
        } catch (e) {
          if (kDebugMode) debugPrint('[AuthService] ⚠️ Erro ao notificar backend: $e');
        }
      }

      // 2. Destrói o token FCM no aparelho caso o usuario tenha feito logout offline. Isso é para garantir que o próximo usuário que logar não receba notificações do militar anterior. O FCM irá gerar um token novo automaticamente no próximo login.
      try {
        if (kDebugMode) debugPrint('[AuthService] 🔥 Destruindo token FCM localmente...');
        await FirebaseMessaging.instance.deleteToken();
        // Nota: Quando o próximo militar iniciar sessão, o FCM gerará um Token totalmente novo.
      } catch (e) {
        if (kDebugMode) debugPrint('[AuthService] ⚠️ Não foi possível destruir o token FCM: $e');
      }

      // 3. Limpa os dados locais do utilizador
      await _clearSessionData();
      if (kDebugMode) debugPrint('[AuthService] ✅ Logout concluído. Aparelho livre e seguro.');
    } catch (e) {
      if (kDebugMode) debugPrint('[AuthService] ❌ Erro durante logout: $e');
    }
  }

  Future<void> _clearSessionData() async {
    if (kDebugMode) {
      debugPrint('[AuthService] 🧹 Limpando dados da sessão...');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(keyCurrentUserSub),
        prefs.remove(keyIsOfflineSession),
        prefs.remove(keyAccessToken),
        prefs.remove(keyRefreshToken),
        prefs.setBool(keyIsLoggedIn, false),
        secureStorage.deleteAll(),
      ]);

      RegistroService().clearUserCache();

      if (kDebugMode) {
        debugPrint('[AuthService] ✅ Dados da sessão limpos');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AuthService] ❌ Erro ao limpar dados da sessão: $e');
      }
    }
  }

  Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isOfflineSession = prefs.getBool(keyIsOfflineSession) ?? false;
      final isLoggedIn = prefs.getBool(keyIsLoggedIn) ?? false;

      // Se o usuário logou offline via banco de dados, ele ESTÁ autenticado.
      if (isOfflineSession && isLoggedIn) {
        if (kDebugMode) debugPrint('[AuthService] ✅ Autenticado via Sessão Offline.');
        return true;
      }

      final accessToken = await secureStorage.read(key: keyAccessToken);

      if (accessToken == null) {
        return false;
      }

      try {
        final decodedToken = JwtDecoder.decode(accessToken);
        final expirationDate = DateTime.fromMillisecondsSinceEpoch(
          decodedToken['exp'] * 1000,
        );
        final now = DateTime.now();

        if (now.add(const Duration(minutes: 5)).isBefore(expirationDate)) {
          return true;
        }

        return await renewToken();
      } catch (e) {
        return await renewToken();
      }
    } catch (e) {
      return false;
    }
  }

  Future<String?> getUserSub() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyCurrentUserSub);
  }

  // ✅ RENOVAÇÃO DE TOKEN SÍNCRONA
  Future<bool> renewToken() async {
    final prefs = await SharedPreferences.getInstance();
    final isOfflineSession = prefs.getBool(keyIsOfflineSession) ?? false;
    if (isOfflineSession) {
      if (kDebugMode) debugPrint('[AuthService] 🛑 Renovação bloqueada: Sessão Offline não possui Token Keycloak.');
      return false; 
    }
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (kDebugMode) debugPrint('[AuthService] 🛑 Renovação bloqueada: Sem internet.');
      return false;
    }

    if (_isTokenRenewalInProgress) {
      while (_isTokenRenewalInProgress) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      final token = await secureStorage.read(key: keyAccessToken);
      return token != null && !JwtDecoder.isExpired(token);
    }

    if (!_canAttemptRenewal()) return false;

    _isTokenRenewalInProgress = true;
    _markRenewalAttempt();

    try {
      final refreshToken = await secureStorage.read(key: keyRefreshToken);

      if (refreshToken == null) {
        await logout();
        return false;
      }

      if (kDebugMode) debugPrint('[AuthService] 🔄 Renovando token...');

      final result = await appAuth.token(
        TokenRequest(
          KeycloakConfig.clientId,
          KeycloakConfig.redirectUri,
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: KeycloakConfig.authorizationEndpoint,
            tokenEndpoint: KeycloakConfig.tokenEndpoint,
            endSessionEndpoint: KeycloakConfig.endSessionEndpoint,
          ),
          refreshToken: refreshToken,
          allowInsecureConnections: KeycloakConfig.allowInsecureConnections,
          scopes: KeycloakConfig.scopes,
        ),
      ).timeout(const Duration(seconds: 30));

      if (result.accessToken != null) {
        
        await Future.wait([
          secureStorage.write(key: keyAccessToken, value: result.accessToken!),
          if (result.refreshToken != null)
            secureStorage.write(key: keyRefreshToken, value: result.refreshToken!),
          if (result.idToken != null)
            secureStorage.write(key: keyIdToken, value: result.idToken!),
        ]);

        if (kDebugMode) debugPrint('[AuthService] ✅ Token renovado com sucesso no SecureStorage');
        return true;
      }

      await logout();
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('[AuthService] ❌ Erro ao renovar token: $e. Forçando logout.');
      await logout();
      return false;
    } finally {
      _isTokenRenewalInProgress = false;
    }
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final isOfflineSession = prefs.getBool(keyIsOfflineSession) ?? false;
    if (isOfflineSession) {
      return null; // Sessões offline não possuem nem precisam de tokens JWT
    }

    try {
      final token = await secureStorage.read(key: keyAccessToken);

      if (token == null) return null;

      try {
        final isExpired = JwtDecoder.isExpired(token);
        final remainingTime = JwtDecoder.getRemainingTime(token);

        if (isExpired) {
          final renewed = await renewToken();
          return renewed ? await secureStorage.read(key: keyAccessToken) : null;
        }

        if (remainingTime.inMinutes < 5) {
          final renewed = await renewToken();
          return renewed ? await secureStorage.read(key: keyAccessToken) : token;
        }

        return token;
      } catch (e) {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}