
class EnvironmentConfig {
  static late String issuer;
  static late String apiBaseUrl;
  static late String attachmentsBaseUrl;

  static const String _prdIssuer = 'https://auth.fortivus.xyz/realms/fortivus';
  static const String _prdApi = 'https://fortivus.xyz/combate/api';
  // Roteado pelo Traefik via PathPrefix('/api/v1/attachments') direto para o attachment-service —
  // não leva o prefixo /combate (esse vai para o fortivus-v2).
  static const String _prdAttachments = 'https://fortivus.xyz/api/v1/attachments';

  // Este método será chamado sempre que o app abrir
  static Future<void> init() async {
    issuer = _prdIssuer;
    apiBaseUrl = _prdApi;
    attachmentsBaseUrl = _prdAttachments;
  }
}