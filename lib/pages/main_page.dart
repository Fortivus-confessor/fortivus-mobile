import 'package:fortivus_app/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  @override
  State<MainPage> createState() => _MainPageState();
}
class _MainPageState extends State<MainPage> {
  final List<Widget> _pages = [const HomePage(), const LoginPage()];
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, 
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sair do aplicativo?'),
            content: const Text('Você realmente deseja sair?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Não'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Sim'),
              ),
            ],
          ),
        ).then((value) {
          if (value == true) {
          }
        });
      },
      child: Scaffold(
        body: _pages[0], 
      ),
    );
  }
}
