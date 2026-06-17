import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:fortivus_app/theme/tactical_theme.dart';

/// Botão de salvamento genérico para formulários
/// 
/// Uso:
/// ```dart
/// FormularioSalvarButton(
///   isLoading: state.isLoading,
///   onSalvar: ({onSucessoAntesDeFechar}) => state.salvar(
///     onSucessoAntesDeFechar: onSucessoAntesDeFechar,
///   ),
///   labelSalvar: 'SALVAR REGISTRO',
/// )
/// ```
class FormularioSalvarButton extends StatelessWidget {
  /// Se está em processo de salvamento
  final bool isLoading;

  /// Callback assíncrono que executa o salvamento
  /// - Retorna `null` em caso de sucesso
  /// - Retorna `String` com mensagem de erro em caso de falha
  /// - Aceita callback opcional para executar ANTES de desligar loading
  final Future<String?> Function({VoidCallback? onSucessoAntesDeFechar}) onSalvar;

  /// Texto do botão quando está salvando
  final String labelSalvando;

  /// Texto do botão quando está pronto para salvar
  final String labelSalvar;

  /// Ícone do botão
  final IconData icon;

  /// Mensagem de sucesso customizada
  final String? mensagemSucesso;

  /// Função customizada para determinar mensagem de sucesso
  final Future<String> Function()? getMensagemSucesso;

  const FormularioSalvarButton({
    super.key,
    required this.isLoading,
    required this.onSalvar,
    this.labelSalvando = 'SALVANDO...',
    this.labelSalvar = 'SALVAR REGISTRO',
    this.icon = Icons.check_circle,
    this.mensagemSucesso,
    this.getMensagemSucesso,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : () => _handleSalvar(context),
        icon: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon, size: 24),
        label: Text(
          isLoading ? labelSalvando : labelSalvar,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: TacticalTheme.accentGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Future<void> _handleSalvar(BuildContext context) async {
    debugPrint('🔘 [SALVAR BUTTON] Botão pressionado');
    
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    debugPrint('📤 [SALVAR BUTTON] Iniciando salvamento...');
    
    // Esperamos o salvamento completo.
    // erro será nulo se deu tudo certo.
    final String? erro = await onSalvar(); 
    
    debugPrint('📥 [SALVAR BUTTON] Salvamento concluído. Erro: ${erro ?? "nenhum"}');

    if (erro == null) {
      // ✅ SUCESSO! 
      debugPrint('✅ [SALVAR BUTTON] Salvamento bem-sucedido. Fechando tela...');
      
      // Mostra a mensagem primeiro
      await _mostrarMensagemSucesso(scaffoldMessenger);
      
      // E fecha a tela UMA ÚNICA VEZ. 
      // Como o onSalvar já terminou, a View não está mais em `isLoading=true` presa.
      navigator.pop(true);
      
    } else {
      // ❌ ERRO! A tela NÃO fecha, apenas mostra o aviso.
      debugPrint('❌ [SALVAR BUTTON] Erro ao salvar: $erro');
      _mostrarMensagemErro(scaffoldMessenger, erro);
    }
  }

  Future<void> _mostrarMensagemSucesso(ScaffoldMessengerState scaffoldMessenger) async {
    String mensagem;

    // Determina mensagem de sucesso
    if (getMensagemSucesso != null) {
      mensagem = await getMensagemSucesso!();
    } else if (mensagemSucesso != null) {
      mensagem = mensagemSucesso!;
    } else {
      // Mensagem padrão baseada em conectividade
      final connectivity = await Connectivity().checkConnectivity();
      final isOffline = connectivity.contains(ConnectivityResult.none);

      mensagem = isOffline
          ? 'Salvo offline! Será sincronizado quando houver internet.'
          : 'Registro salvo com sucesso!';
    }

    debugPrint('📢 [SALVAR BUTTON] Mostrando SnackBar de sucesso');
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(mensagem)),
          ],
        ),
        backgroundColor: TacticalTheme.accentGreen,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarMensagemErro(ScaffoldMessengerState scaffoldMessenger, String mensagemErro) {
    debugPrint('📢 [SALVAR BUTTON] Mostrando SnackBar de erro');
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(mensagemErro)),
          ],
        ),
        backgroundColor: TacticalTheme.accentRed,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}