import 'package:shared_preferences/shared_preferences.dart';

class EnvironmentConfig {
  static late String issuer;
  static late String apiBaseUrl;
  
  static bool isHomologacao = false;

  static const String _prdIssuer = 'https://auth.fortivus.cbm.mt.gov.br/realms/fortivus';
  static const String _prdApi = 'https://combate.fortivus.cbm.mt.gov.br/api';
  
  // Utilizar 10.0.2.2 para emuladores Android ou localhost para Web/Windows
  static const String _hmlIssuer = 'http://10.0.2.2:9000/realms/fortivus';
  static const String _hmlApi = 'http://10.0.2.2:8080/api';

  // Este método será chamado sempre que o app abrir ou trocar de ambiente
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Lê a escolha do usuário (o padrão é false -> Produção)
    isHomologacao = prefs.getBool('is_hml_env') ?? true;

    if (isHomologacao) {
      issuer = _hmlIssuer;
      apiBaseUrl = _hmlApi;
    } else {
      issuer = _prdIssuer;
      apiBaseUrl = _prdApi;
    }
  }
}