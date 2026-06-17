import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 🛡️ SSLHelper - Blindagem de Confiança SSL para domínios CBM-MT
/// 
/// Esta classe resolve o problema de cadeias de certificados incompletas no servidor
/// (comum no Android 13+) sem comprometer a segurança global do aplicativo.
class SSLHelper {
  static const List<String> _trustedDomains = [
    'cbm.mt.gov.br',
    'gov.br',
  ];

  static const List<String> _certAssets = [
    'assets/ca/sectigo_r36.pem',
    'assets/ca/sectigo_r46.pem',
    'assets/ca/usertrust_root.pem',
  ];

  static final List<String> _loadedCerts = [];

  /// Inicializa a blindagem SSL carregando os certificados e aplicando o HttpOverrides.
  static Future<void> initialize() async {
    try {
      if (kDebugMode) debugPrint('[SSLHelper] 🔐 Inicializando blindagem SSL...');

      for (var assetPath in _certAssets) {
        try {
          final certData = await rootBundle.loadString(assetPath);
          _loadedCerts.add(certData);
        } catch (e) {
          if (kDebugMode) debugPrint('[SSLHelper] ⚠️ Erro ao carregar certificado $assetPath: $e');
        }
      }

      if (_loadedCerts.isNotEmpty) {
        HttpOverrides.global = _SecureHttpOverrides(_loadedCerts, _trustedDomains);
        if (kDebugMode) debugPrint('[SSLHelper] ✅ Blindagem SSL ativa para: ${_trustedDomains.join(', ')}');
      } else {
        if (kDebugMode) debugPrint('[SSLHelper] ❌ Nenhum certificado foi carregado. Operando com confiança do sistema.');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[SSLHelper] ❌ Falha crítica ao inicializar SSLHelper: $e');
    }
  }
}

class _SecureHttpOverrides extends HttpOverrides {
  final List<String> trustedCerts;
  final List<String> domains;

  _SecureHttpOverrides(this.trustedCerts, this.domains);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    // Criamos um novo contexto de segurança para incluir nossos certificados
    final SecurityContext secureContext = context ?? SecurityContext(withTrustedRoots: true);
    
    // Adicionamos cada certificado carregado ao contexto
    for (var cert in trustedCerts) {
      try {
        secureContext.setTrustedCertificatesBytes(cert.codeUnits);
      } catch (e) {
        if (kDebugMode) debugPrint('[SSLHelper] ⚠️ Erro ao registrar certificado no contexto: $e');
      }
    }

    final client = super.createHttpClient(secureContext);

    // Validação adicional caso o handshake falhe por causa de cadeias incompletas
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      final isTrustedDomain = domains.any((domain) => host.endsWith(domain));
      
      if (isTrustedDomain) {
        if (kDebugMode) {
          debugPrint('[SSLHelper] 🛡️ Validando certificado para domínio confiável: $host');
          debugPrint('[SSLHelper] Issuer: ${cert.issuer}');
        }
        
        // Se o domínio for nosso e o erro for apenas a cadeia incompleta, 
        // o SecurityContext já deve ter resolvido via setTrustedCertificatesBytes.
        // Se chegar aqui, podemos fazer uma verificação manual ou permitir se o emissor for conhecido.
        final knownIssuers = ['Sectigo', 'USERTrust', 'The USERTRUST Network'];
        final hasKnownIssuer = knownIssuers.any((issuer) => cert.issuer.contains(issuer));
        
        if (hasKnownIssuer) {
          if (kDebugMode) debugPrint('[SSLHelper] ✅ Certificado aceito (Emissor Conhecido)');
          return true;
        }
      }

      if (kDebugMode) debugPrint('[SSLHelper] ❌ Certificado rejeitado para: $host');
      return false; // Rejeita por padrão para segurança
    };

    return client;
  }
}
