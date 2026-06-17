import 'package:fortivus_app/config/environment_config.dart';
import 'package:flutter/foundation.dart';

class KeycloakConfig {
  static String get issuer => EnvironmentConfig.issuer;
  static const String clientId = 'fortivus-app';
  
  static const List<String> scopes = [
    'openid',
    'profile',
    'email',
    'roles',
    'offline_access'
  ];
  
  static const String redirectUri = 'com.fortivus.app:/oauth2/callback';
  static const String callbackUrlScheme = 'com.fortivus.app';
  static const String clockSkewLeeway = '120';
  static bool get allowInsecureConnections {
    return kDebugMode && 
           const bool.fromEnvironment('ALLOW_INSECURE', defaultValue: false);
  }
  static String get authorizationEndpoint => '$issuer/protocol/openid-connect/auth';
  
  static String get tokenEndpoint => '$issuer/protocol/openid-connect/token';
  
  static String get endSessionEndpoint => '$issuer/protocol/openid-connect/logout';
  
  static String get revokeEndpoint => '$issuer/protocol/openid-connect/revoke';
  
  static String get userInfoEndpoint => '$issuer/protocol/openid-connect/userinfo';

  static void logConfig() {
    if (kDebugMode) {
      debugPrint('[KeycloakConfig] ===== CONFIGURAÇÃO =====');
      debugPrint('[KeycloakConfig] Issuer: $issuer');
      debugPrint('[KeycloakConfig] Client ID: $clientId');
      debugPrint('[KeycloakConfig] Redirect URI: $redirectUri');
      debugPrint('[KeycloakConfig] Clock Skew: ${clockSkewLeeway}s');
       debugPrint('[KeycloakConfig] Allow Insecure: $allowInsecureConnections');      debugPrint('[KeycloakConfig] ===========================');
    }
  }
}
