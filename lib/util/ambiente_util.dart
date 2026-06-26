import 'package:fortivus_app/config/environment_config.dart';
import 'package:fortivus_app/pages/login_page.dart';
import 'package:fortivus_app/services/auth_service.dart';
import 'package:fortivus_app/services/local_db_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AmbienteUtil {
  static Future<void> mostrarDialogoTroca(BuildContext context) async {
    final bool indoParaHomologacao = !EnvironmentConfig.isHomologacao;
    final String nomeNovoAmbiente = indoParaHomologacao ? 'HOMOLOGAÇÃO' : 'PRODUÇÃO';

    final parentContext = context;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('⚠️ ATENÇÃO - Troca de Ambiente'),
          content: Text(
            'Você está prestes a mudar para o ambiente de $nomeNovoAmbiente.\n\n'
            'ISSO APAGARÁ TODOS OS DADOS LOCAIS DO SEU APARELHO, '
            'incluindo rascunhos de ocorrências offline não enviados.\n\n'
            'Deseja continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                // Fecha o alerta usando o contexto do pop-up
                Navigator.of(dialogContext).pop(); 
                
                // Executa a troca usando o contexto da HomePage!
                await _executarTrocaDeAmbiente(parentContext, indoParaHomologacao);
              },
              child: const Text(
                'SIM, APAGAR E TROCAR', 
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _executarTrocaDeAmbiente(BuildContext context, bool isHomologacao) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Salva a nova preferência
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_hml_env', isHomologacao);

      // Faz logout para matar o token atual
      await AuthService().logout();

      // Limpa arquivos e banco de dados
      await LocalDbService.instance.limparTodasAsPastasDeArquivos();
      await LocalDbService.instance.resetarBancoDados();

      // Atualiza as URLs em memória
      await EnvironmentConfig.init();

      // Fecha o Loading e Redireciona para o Login
      if (context.mounted) {
        Navigator.of(context).pop(); // Tira a rodinha da tela
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()), 
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao trocar de ambiente: $e')),
        );
      }
    }
  }
}