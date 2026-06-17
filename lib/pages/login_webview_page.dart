import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

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
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Inicialização simplificada e robusta para evitar erros de versão de API
    final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params);

    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (kDebugMode) debugPrint('[WebView] progresso: $progress%');
          },
          onPageStarted: (String url) {
            if (kDebugMode) debugPrint('[WebView] iniciando: $url');
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (kDebugMode) debugPrint('[WebView] finalizada: $url');
            setState(() => _isLoading = false);
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
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authorizationUrl));

    // Configurações nativas adicionais
    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(kDebugMode);
      
      // Nota: A confiança SSL é gerenciada via network_security_config.xml 
      // na camada nativa do Android, o que afeta esta WebView automaticamente.
    }
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
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
