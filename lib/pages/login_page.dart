import 'dart:async';
import 'package:fortivus_app/services/fcm_service.dart';
import 'package:fortivus_app/services/auth_service.dart';
import 'package:fortivus_app/services/sync_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'main_page.dart';

// ============================================================================
// CONSTANTS
// ============================================================================

class LoginConstants {
  static const Duration connectivityCheckDelay = Duration(milliseconds: 500);
  static const Duration navigationDelay = Duration(milliseconds: 300);
  static const Duration authCheckDelay = Duration(milliseconds: 1500);
  static const Duration fcmTimeout = Duration(seconds: 5);
  static const Duration syncTimeout = Duration(seconds: 10);
  static const int passwordMinLength = 6;
  
  // Mensagens
  static const String loginWelcomeMessage = 'Bem-vindo ao FORTIVUS';
  static const String offlineAccessMessage = 'Acesso Offline';
  static const String connectedStatus = 'Sistema Conectado';
  static const String offlineStatus = 'Modo Operação Offline';
  static const String authenticatingMessage = 'Autenticando...';
  
  // Erros
  static const String loginFailureMessage =
      'Falha no login. Verifique sua conexão ou credenciais.';
  static const String invalidCredentialsMessage =
      'Credenciais offline inválidas ou expiradas.';
  static const String identifierRequiredError = 'E-mail ou Matrícula obrigatório';
  static const String passwordRequiredError = 'Senha obrigatória';
  static const String passwordTooShortError =
      'Senha deve ter no mínimo $passwordMinLength caracteres';
}

// ============================================================================
// MODELS
// ============================================================================

class AuthUser {
  final String identifier;
  final String? token;

  AuthUser({required this.identifier, this.token});
}

// ============================================================================
// ABSTRAÇÃO: Authentication Provider (DIP)
// ============================================================================

abstract class IAuthenticationProvider {
  Future<bool> login(BuildContext context);
  Future<AuthUser?> loginOffline(String identifier, String password);
  Future<bool> isAuthenticated();
  Future<void> logout();
}

class AuthenticationProvider implements IAuthenticationProvider {
  final AuthService _authService = AuthService();

  @override
  Future<bool> login(BuildContext context) => _authService.login(context);

  @override
  Future<AuthUser?> loginOffline(String identifier, String password) async {
    final user = await _authService.loginOffline(identifier, password);
    if (user == null) return null;
    
    return AuthUser(
      identifier: identifier,
      token: null, // AuthService.loginOffline retorna User, não token
    );
  }

  @override
  Future<bool> isAuthenticated() => _authService.isAuthenticated();

  @override
  Future<void> logout() => _authService.logout();
}

// ============================================================================
// ABSTRAÇÃO: Connectivity Provider (DIP)
// ============================================================================
abstract class IConnectivityProvider {
  Future<bool> hasConnection();
  Stream<bool> onConnectivityChanged();
}

class ConnectivityProvider implements IConnectivityProvider {
  final Connectivity _connectivity = Connectivity();

  @override
  Future<bool> hasConnection() async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  @override
  Stream<bool> onConnectivityChanged() =>
      _connectivity.onConnectivityChanged.map(
        (results) => !results.contains(ConnectivityResult.none),
      );
}

// ============================================================================
// ABSTRAÇÃO: Post-Login Service (DIP)
// ============================================================================

abstract class IPostLoginService {
  Future<void> registerDevice();
  Future<void> syncPendingData();
}

class PostLoginService implements IPostLoginService {
  @override
  Future<void> registerDevice() async {
    try {
      await FcmService().registerDevice().timeout(
        LoginConstants.fcmTimeout,
        onTimeout: () => throw TimeoutException('FCM registration timeout'),
      );
    } catch (e) {
      _log('⚠️ FCM registration failed: $e');
      // Não falhar - continuar mesmo sem FCM
    }
  }

  @override
  Future<void> syncPendingData() async {
    try {
      final syncService = SyncService();
      await syncService.forceSyncNow().timeout(
        LoginConstants.syncTimeout,
        onTimeout: () => throw TimeoutException('Sync timeout'),
      );
    } catch (e) {
      _log('⚠️ Sync failed: $e');
    }
  }

  static void _log(String msg) {
    if (kDebugMode) debugPrint('[PostLoginService] $msg');
  }
}

// ============================================================================
// VALIDATOR: Email e Senha
// ============================================================================

class FormValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return LoginConstants.identifierRequiredError;
    }

    if (!_isValidEmail(value)) {
      return LoginConstants.identifierRequiredError;
    }

    return null;
  }

  static String? validateIdentifier(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LoginConstants.identifierRequiredError;
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return LoginConstants.passwordRequiredError;
    }

    if (value.length < LoginConstants.passwordMinLength) {
      return LoginConstants.passwordTooShortError;
    }

    return null;
  }

  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}

// ============================================================================
// LOGIN PAGE
// ============================================================================

class LoginPage extends StatefulWidget {
  final String? alertMessage;
  final String? alertType;

  const LoginPage({
    super.key,
    this.alertMessage,
    this.alertType,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ============================================================================
  // STATE
  // ============================================================================
  bool _isLoading = false;
  bool _hasInternet = true;
  bool _obscurePassword = true;

  // ============================================================================
  // CONTROLLERS
  // ============================================================================
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final GlobalKey<FormState> _formKey;

  // ============================================================================
  // DEPENDÊNCIAS (DI)
  // ============================================================================
  late final IAuthenticationProvider _authProvider;
  late final IConnectivityProvider _connectivityProvider;
  late final IPostLoginService _postLoginService;

  // ============================================================================
  // STREAMS E TIMERS
  // ============================================================================
  late StreamSubscription<bool> _connectivitySubscription;
  Timer? _authCheckTimer;

  @override
  void initState() {
    super.initState();
    _initializeDependencies();
    _initializeControllers();
    _setupConnectivityListener();
    _checkInitialState();
  }

  void _initializeDependencies() {
    _authProvider = AuthenticationProvider();
    _connectivityProvider = ConnectivityProvider();
    _postLoginService = PostLoginService();
  }

  void _initializeControllers() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivityProvider
        .onConnectivityChanged()
        .listen(_onConnectivityChanged);
  }

  Future<void> _checkInitialState() async {
    final hasConnection = await _connectivityProvider.hasConnection();
    _updateConnectivityStatus(hasConnection);

    if (hasConnection) {
      _authCheckTimer = Timer(
        LoginConstants.authCheckDelay,
        _checkAuthenticationStatus,
      );
    }
  }

  void _onConnectivityChanged(bool hasConnection) {
    if (!mounted) return;
    _updateConnectivityStatus(hasConnection);
  }

  void _updateConnectivityStatus(bool hasConnection) {
    if (!mounted) return;

    setState(() => _hasInternet = hasConnection);
    _log('📶 Conectividade: ${hasConnection ? 'Online' : 'Offline'}');

    if (hasConnection) {
      _authCheckTimer?.cancel();
      _authCheckTimer = Timer(
        LoginConstants.authCheckDelay,
        _checkAuthenticationStatus,
      );
    }
  }

  Future<void> _checkAuthenticationStatus() async {
    if (!mounted || !_hasInternet) return;

    try {
      final isAuth = await _authProvider.isAuthenticated();

      if (isAuth && mounted) {
        _navigateToMainPage();
      }
    } catch (e) {
      _log('❌ Auth check failed: $e');
    }
  }

  // ============================================================================
  // LOGIN HANDLERS
  // ============================================================================

  Future<void> _handleOnlineLogin() async {
    if (_isLoading) return;

    _setLoading(true);
    try {
      final success = await _authProvider.login(context);

      if (!mounted) return;

      if (success) {
        await _postLoginService.registerDevice();
        await _postLoginService.syncPendingData();

        if (mounted) {
          _navigateToMainPage();
        }
      } else {
        _showErrorSnackbar(LoginConstants.loginFailureMessage);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Erro no login: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _handleOfflineLogin() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    _setLoading(true);
    try {
      final identifier = _emailController.text.trim();
      final password = _passwordController.text;

      final user = await _authProvider.loginOffline(identifier, password);

      if (!mounted) return;

      if (user != null) {
        _navigateToMainPage();
      } else {
        _showErrorSnackbar(LoginConstants.invalidCredentialsMessage);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Erro no login offline: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================================
  // NAVIGATION
  // ============================================================================

  void _navigateToMainPage() {
    if (!mounted) return;

    Future.delayed(LoginConstants.navigationDelay, () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      }
    });
  }

  // ============================================================================
  // FEEDBACK
  // ============================================================================

  void _showErrorSnackbar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  void _setLoading(bool value) {
    if (!mounted) return;
    setState(() => _isLoading = value);
  }

  void _togglePasswordVisibility() {
    if (!mounted) return;
    setState(() => _obscurePassword = !_obscurePassword);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _authCheckTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================================
  // BUILD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildLoginCard(),
                    const SizedBox(height: 32),
                    _buildStatusIndicator(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Hero(
          tag: 'logo-fortivus',
          child: Image.asset(
            'assets/images/logo-fortivus.png',
            width: 220,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.shield,
              size: 100,
            ),
          ),
        ),
        if (widget.alertMessage != null) ...[
          const SizedBox(height: 24),
          _buildAlertBanner(),
        ],
      ],
    );
  }

  Widget _buildAlertBanner() {
    final isSuccess = widget.alertType == 'success';
    final color = isSuccess
        ? Colors.green
        : Theme.of(context).colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess
                ? Icons.check_circle_outline
                : Icons.error_outline,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.alertMessage!,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard() {
    return Card(
      elevation: 6,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          child: _hasInternet
              ? _buildOnlineLoginForm()
              : _buildOfflineLoginForm(),
        ),
      ),
    );
  }

  Widget _buildOnlineLoginForm() {
    return Column(
      key: const ValueKey('online_form'),
      children: [
        Text(
          LoginConstants.loginWelcomeMessage,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 32),
        _buildSubmitButton(
          label: 'Entrar',
          icon: Icons.security,
          onPressed: _isLoading ? null : _handleOnlineLogin,
        ),
      ],
    );
  }

  Widget _buildOfflineLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('offline_form'),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                LoginConstants.offlineAccessMessage,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _emailController,
            label: 'E-mail ou Matrícula',
            icon: Icons.person_outline,
            keyboardType: TextInputType.text,
            autofillHints: const [AutofillHints.email, AutofillHints.username],
            validator: FormValidators.validateIdentifier,
          ),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 24),
          _buildSubmitButton(
            label: 'Entrar Offline',
            icon: Icons.login,
            onPressed: _isLoading ? null : _handleOfflineLogin,
            backgroundColor: Colors.blueGrey[800],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    Iterable<String>? autofillHints,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField() {
    final theme = Theme.of(context);

    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Senha',
        prefixIcon: Icon(
          Icons.lock_outline,
          color: theme.colorScheme.primary,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: _togglePasswordVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
      ),
      validator: FormValidators.validatePassword,
    );
  }

  Widget _buildSubmitButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    Color? backgroundColor,
  }) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        icon: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon, size: 22),
        label: Text(
          _isLoading
              ? LoginConstants.authenticatingMessage
              : label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    final color = _hasInternet
        ? Colors.green
        : Theme.of(context).colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _hasInternet ? Icons.wifi : Icons.wifi_off,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            _hasInternet
                ? LoginConstants.connectedStatus
                : LoginConstants.offlineStatus,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static void _log(String msg) {
    if (kDebugMode) debugPrint('[LoginPage] $msg');
  }
}
