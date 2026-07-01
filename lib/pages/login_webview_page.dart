import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// Fallback de login via WebView usado exclusivamente no Android 13/14
/// (bug conhecido do AppAuth/Custom Tabs nessas versões). Usar WebView embutida
/// para OAuth é um desvio da RFC 8252 (que exige um user-agent externo) — o app
/// controla o WebView e poderia, em tese, injetar JS para capturar credenciais
/// digitadas no formulário do Keycloak. Mitigamos restringindo a navegação
/// estritamente ao host do Keycloak (ou ao redirect URI) e isolando a sessão
/// (sem cookies/cache reaproveitados entre logins).
class LoginWebViewPage extends StatefulWidget {
  final String authorizationUrl;
  final String redirectUri;

  const LoginWebViewPage({
    super.key,
    required this.authorizationUrl,
    required this.redirectUri,
  });

  @override
  State<LoginWebViewPage> createState() => _LoginWebViewPageState();
}

class _LoginWebViewPageState extends State<LoginWebViewPage> {
  WebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    // Isola a sessão: nenhum cookie/cache de um login anterior deve influenciar este.
    await WebViewCookieManager().clearCookies();

    // Inicialização simplificada e robusta para evitar erros de versão de API
    final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params);
    final authHost = Uri.parse(widget.authorizationUrl).host;

    controller
      ..clearCache()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (kDebugMode) debugPrint('[WebView] progresso: $progress%');
          },
          onPageStarted: (String url) {
            if (kDebugMode) debugPrint('[WebView] iniciando: $url');
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (kDebugMode) debugPrint('[WebView] finalizada: $url');
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            if (kDebugMode) debugPrint('[WebView] erro: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            // Intercepta o redirect URI do Keycloak para fechar a WebView e retornar o código
            if (request.url.startsWith(widget.redirectUri)) {
              if (kDebugMode) debugPrint('[WebView] Redirect detectado: ${request.url}');
              final uri = Uri.parse(request.url);
              Navigator.pop(context, uri);
              return NavigationDecision.prevent;
            }
            // Só navega dentro do host do Keycloak; qualquer outro destino
            // (redirecionamento externo, phishing, link injetado) é bloqueado.
            final requestHost = Uri.tryParse(request.url)?.host;
            if (requestHost != authHost) {
              if (kDebugMode) {
                debugPrint('[WebView] Navegação bloqueada (host fora do Keycloak): ${request.url}');
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authorizationUrl));

    // Configurações nativas adicionais
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(kDebugMode);

      // Nota: A confiança SSL é gerenciada via network_security_config.xml
      // na camada nativa do Android, o que afeta esta WebView automaticamente.
    }

    if (mounted) setState(() => _controller = controller);
  }

  @override
  void dispose() {
    // Não deixa cookies/tokens de sessão do Keycloak residentes na WebView após o login.
    WebViewCookieManager().clearCookies();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Fortivus'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          if (_controller != null) WebViewWidget(controller: _controller!),
          if (_isLoading || _controller == null)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
