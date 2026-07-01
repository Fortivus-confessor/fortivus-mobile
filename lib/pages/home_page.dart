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
    final menuItems = [
      _MenuItem(
        label: 'PENDENTES', 
        icon: Icons.warning, 
        color: Colors.white, 
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ConsultaRegistrosPage())).then((_) {
            if (mounted) {
              _carregarContadores(forceRefresh: true);
            }
          });
        }, 
        badgeCount: pendentesCount, 
        isLoading: _isLoading, 
        badgeColor: Colors.red
      ),
      _MenuItem(
        label: 'ENCERRADOS', 
        icon: Icons.check_box, 
        color: Colors.white, 
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ConsultaRegistrosEncerradosPage())).then((_) {
            if (mounted) {
              _carregarContadores(forceRefresh: true);
            }
          });
        }, 
        badgeCount: encerradosCount, 
        isLoading: _isLoading, 
        badgeColor: Colors.green.shade600
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        toolbarHeight: 100,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo-fortivus.png', height: 50),
            const SizedBox(height: 4),
            const Text('FORTIVUS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: _logout)],
      ),
      body: Column(
        children: menuItems.map((item) => Expanded(
          child: InkWell(
            onTap: item.onTap, 
            child: Container(
              width: double.infinity, 
              decoration: BoxDecoration(
                color: item.color, 
                border: const Border(
                  top: BorderSide(color: Colors.black26, width: 1), 
                  bottom: BorderSide(color: Colors.black26, width: 1)
                )
              ), 
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, 
                  children: [
                    Stack(
                      clipBehavior: Clip.none, 
                      children: [
                        Icon(item.icon, color: Colors.black, size: 40), 
                        Positioned(
                          right: -20, 
                          top: -12, 
                          child: Builder(builder: (context) { 
                            if (item.isLoading == true) {
                              return SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(item.badgeColor)));
                            }
                            if (item.badgeCount != null && item.badgeCount! > 0) {
                              return _Badge(count: item.badgeCount!, color: item.badgeColor);
                            }
                            return const SizedBox.shrink(); 
                          })
                        )
                      ]
                    ), 
                    const SizedBox(height: 8), 
                    Text(item.label, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold))
                  ]
                )
              )
            )
          )
        )).toList()
      ),
    );
  }
}

class _MenuItem {
  final String label; final IconData icon; final Color color; final VoidCallback onTap; final int? badgeCount; final bool? isLoading; final Color badgeColor;
  const _MenuItem({required this.label, required this.icon, required this.color, required this.onTap, this.badgeCount, this.isLoading, this.badgeColor = Colors.red});
}

class _Badge extends StatelessWidget {
  final int count; final Color color;
  const _Badge({required this.count, this.color = Colors.red});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Colors.black38, spreadRadius: 0.5, blurRadius: 3, offset: Offset(0, 1))]), constraints: const BoxConstraints(minWidth: 28, minHeight: 28), child: Center(child: Text(count > 99 ? '99+' : '$count', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))));
  }
}