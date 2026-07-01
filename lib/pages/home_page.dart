import 'dart:async';
import 'package:fortivus_app/services/fcm_service.dart';
import 'package:flutter/material.dart';
import 'package:fortivus_app/pages/consulta_registros_page.dart';
import 'package:fortivus_app/pages/consulta_registros_encerrados_page.dart';
import 'package:fortivus_app/services/registro_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fortivus_app/theme/fortivus_colors.dart';
import 'package:fortivus_app/theme/theme_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int pendentesCount = 0;
  int encerradosCount = 0;
  final RegistroService _registroService = RegistroService();
  bool _isLoading = false;
  Timer? _refreshTimer;
  Timer? _quickRefreshTimer;
  StreamSubscription? _connectivitySubscription;
  bool _isConnected = true;
  final AuthService _authService = AuthService();
  bool _showLoginNotification = false;
  StreamSubscription? _authErrorSubscription; 
  bool _isFirstLoad = true; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       FcmService().registerDevice();
       _verificarOtimizacaoBateria();
    });
    _initConnectivity();
    _startTimers();
    _authErrorSubscription = _authService.onAuthError.listen((_) {
      debugPrint('[HomePage] Evento de erro de autenticação recebido via Stream. Exibindo notificação.');
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mostrarNotificacaoLogin();
        });
      }
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _carregarContadores(forceRefresh: true);
    });
  }

  Future<void> _verificarOtimizacaoBateria() async {
    if (!mounted) return;
    
    var isGranted = await Permission.ignoreBatteryOptimizations.isGranted;
    if (!isGranted && mounted) {
      debugPrint('[HomePage] Otimização de bateria ativa. Solicitando liberação ao usuário.');
      showDialog(
        context: context,
        barrierDismissible: false, 
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.battery_alert, color: Colors.orange, size: 28),
                SizedBox(width: 8),
                Expanded(child: Text('Atenção à Sincronização', style: TextStyle(fontSize: 18))),
              ],
            ),
            content: const Text(
              "Para a sua comodidade, ocorrências preenchidas offline são sincronizadas automaticamente quando a internet volta. Você não precisa reabrir o app; o envio ocorre sozinho, mesmo com o celular/tablet no porta-luvas ou no bolso.\n\nPara habilitar essa função e evitar a perda de dados, o aplicativo precisa de permissão para rodar sem restrições de energia. Na próxima tela, selecione 'Permitir'.",
              style: TextStyle(fontSize: 15, height: 1.3),
              textAlign: TextAlign.justify,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  debugPrint('[HomePage] Usuário optou por configurar depois.');
                },
                child: const Text('DEPOIS', style: TextStyle(color: Colors.grey)),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.blue.shade800),
                onPressed: () async {
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  final status = await Permission.ignoreBatteryOptimizations.request();
                  
                  if (status.isGranted && mounted) {
                     if (!context.mounted) return;
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(
                         content: Text('Perfeito! Sincronização em segundo plano ativada.'),
                         backgroundColor: Colors.green,
                         duration: Duration(seconds: 4),
                       ),
                     );
                  }
                },
                child: const Text('CONFIGURAR AGORA'),
              ),
            ],
          );
        },
      );
    }
  }
  
  void _startTimers() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      debugPrint('[HomePage] Timer principal disparado para atualizar contadores');
      _carregarContadores(forceRefresh: true);
    });
  }

  Future<void> _initConnectivity() async {
    final initialResult = await Connectivity().checkConnectivity();
    _updateConnectionStatus(initialResult);
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) async {
    if (!mounted) return;
    final bool isOnlineNow = !results.contains(ConnectivityResult.none);
    final bool wasConnected = _isConnected;
    if (isOnlineNow != wasConnected) {
      debugPrint('[HomePage] Mudança de conexão: de ${wasConnected ? 'Online' : 'Offline'} para ${isOnlineNow ? 'Online' : 'Offline'}');
      if (isOnlineNow) {
        bool isOfflineSession = await _authService.isOfflineSession();
        if (!mounted) return;
        if (isOfflineSession) {
          debugPrint('[HomePage] Sessão offline detectada com conexão. Exibindo notificação de login.');
          setState(() {
            _isConnected = true;
          });
        } else {
          debugPrint('[HomePage] Sessão online e conexão restaurada. Sincronizando...');
          setState(() {
            _isConnected = true;
            _showLoginNotification = false;
          });
          _carregarContadores(forceRefresh: true);
        }
      } else {
        debugPrint('[HomePage] Conexão perdida.');
        setState(() {
          _isConnected = false;
          _showLoginNotification = false;
        });
      }
    }
  }

  void _redirectToLogin() {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginPage(
            alertMessage: 'Por favor, autentique-se online para sincronizar seus dados.',
            alertType: 'success',
          ),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _quickRefreshTimer?.cancel();
    _connectivitySubscription?.cancel();
    _authErrorSubscription?.cancel(); 
    super.dispose();
  }

  Future<void> _logout() async {
     if (!context.mounted) return;
     showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
    try {
      await AuthService().logout();
      if (mounted) {
        Navigator.of(context).pop(); 
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout realizado com sucesso!'),
            duration: Duration(seconds: 4), 
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer logout: $e'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _carregarContadores({bool forceRefresh = false}) async {
    if (!mounted) return;
    
    if (_showLoginNotification) {
      debugPrint('[HomePage] Login online necessário. Carregamento de contadores ignorado.');
      return;
    }
    if (_isLoading && !forceRefresh) {
      debugPrint('[HomePage] Ignorando chamada para carregarContadores pois já está carregando');
      return;
    }
    if (mounted) setState(() => _isLoading = true);
    
    try {
      final results = await Future.wait([
        _registroService.getTotalPendentes(),
        _registroService.getTotalEncerrados(), 
      ]);
      if (!mounted) return;
      final novosPendentes = results[0];
      final novosEncerrados = results[1];
      if (!_isFirstLoad && novosPendentes > pendentesCount) {
        _mostrarNotificacaoNovoRegistro(novosPendentes - pendentesCount);
      }
      setState(() {
        pendentesCount = novosPendentes;
        encerradosCount = novosEncerrados;
        _showLoginNotification = false;
        _isFirstLoad = false; 
      });
      debugPrint('[HomePage] Contadores atualizados: Pendentes=$pendentesCount, Encerrados=$encerradosCount');
    } catch (e) {
      debugPrint('[HomePage] Erro ao buscar contadores: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _mostrarNotificacaoNovoRegistro(int quantidade) {
    if (!mounted) return;
    
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars(); 
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                quantidade == 1 
                  ? 'Nova ocorrência recebida!' 
                  : '$quantidade novas ocorrências recebidas!',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade800,
        duration: const Duration(seconds: 4), 
        behavior: SnackBarBehavior.floating, 
        margin: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 80.0),
      ),
    );
  }

  void _mostrarNotificacaoLogin() {
    if (!mounted) return;
    
    if (_showLoginNotification) return;
    setState(() {
      _showLoginNotification = true;
    });
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: const Text(
          'Sua sessão expirou. Clique para autenticar.',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange.shade800,
        duration: const Duration(seconds: 4), 
        behavior: SnackBarBehavior.floating, 
        margin: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 80.0),
        action: SnackBarAction(
          label: 'LOGIN',
          textColor: Colors.white,
          onPressed: _redirectToLogin, 
        ),
      ),
    ).closed.then((reason) {
      if (mounted) {
        setState(() {
          _showLoginNotification = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        toolbarHeight: 72,
        title: Row(
          children: [
            Image.asset('assets/images/logo-fortivus.png', height: 38),
            const SizedBox(width: 12),
            const Text('FORTIVUS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
        actions: [
          ListenableBuilder(
            listenable: ThemeController.instance,
            builder: (context, _) => IconButton(
              tooltip: 'Alternar tema',
              icon: Icon(Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined),
              onPressed: () => ThemeController.instance.toggle(context),
            ),
          ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: FortivusBrand.orange,
        onRefresh: () => _carregarContadores(forceRefresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
            Text('Painel operacional',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: fx.textPrimary)),
            const SizedBox(height: 4),
            Text('Selecione uma categoria para ver as ocorrências.',
                style: TextStyle(fontSize: 14, color: fx.textSecondary)),
            const SizedBox(height: 20),
            _DashboardCard(
              label: 'Pendentes',
              subtitle: 'Ocorrências aguardando resposta',
              icon: Icons.local_fire_department_rounded,
              accent: FortivusBrand.orange,
              count: pendentesCount,
              isLoading: _isLoading,
              onTap: () {
                Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ConsultaRegistrosPage()))
                    .then((_) {
                  if (mounted) _carregarContadores(forceRefresh: true);
                });
              },
            ),
            const SizedBox(height: 16),
            _DashboardCard(
              label: 'Encerrados',
              subtitle: 'Histórico de ocorrências concluídas',
              icon: Icons.verified_rounded,
              accent: FortivusBrand.green,
              count: encerradosCount,
              isLoading: _isLoading,
              onTap: () {
                Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ConsultaRegistrosEncerradosPage()))
                    .then((_) {
                  if (mounted) _carregarContadores(forceRefresh: true);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final int count;
  final bool isLoading;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.count,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Material(
      color: fx.cardFill,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: fx.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold, color: fx.textPrimary)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 13, color: fx.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (isLoading)
                SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: accent))
              else
                Container(
                  constraints: const BoxConstraints(minWidth: 34),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: count > 0 ? accent : fx.surfaceAlt,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: count > 0 ? Colors.white : fx.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: fx.textDisabled),
            ],
          ),
        ),
      ),
    );
  }
}