import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../config/app_initializer.dart';
import 'login_page.dart';
import 'main_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    try {
      // 1. Verificar se o usuário já havia logado
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(AuthService.keyIsLoggedIn) ?? false;

      // 2. Executar inicialização pesada (Firebase, DB, Sync)
      // Como já estamos dentro de um Widget, a UI não trava (o loading aparece)
      await AppInitializer.initializeAll(isLoggedIn: isLoggedIn);

      // 3. Verificar validade da sessão atual
      bool authenticated = await AuthService().isAuthenticated();

      // 4. Pequeno delay apenas para garantir uma transição suave visualmente
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      // 5. Navegação final
      if (authenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } catch (e) {
      debugPrint('[SplashPage] Erro fatal na inicialização: $e');
      if (mounted) {
        _showError(e.toString());
      }
    }
  }

  void _showError(String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Erro de Inicialização'),
        content: Text('Não foi possível iniciar o aplicativo:\n\n$error'),
        actions: [
          TextButton(
            onPressed: () => _startInitialization(),
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cores baseadas no TacticalTheme (Color(0xFF263238))
    const primaryColor = Color(0xFF263238);

    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo do Fortivus (esperado em assets/images/logo-fortivus.png)
            Image.asset(
              'assets/images/logo-fortivus.png',
              width: 180,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.shield,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            const Text(
              'Inicializando Sistema...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
