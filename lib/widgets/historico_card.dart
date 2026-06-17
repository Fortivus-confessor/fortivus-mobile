import 'package:flutter/material.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';

/// Um Card genérico e padronizado focado apenas no Histórico Descritivo.
///
/// Campo de texto expansível sem limites, ideal para relatórios detalhados.
class HistoricoDescritivoCard extends StatelessWidget {
  // ✅ Controllers
  final TextEditingController historicoController;
  
  // ✅ Configurações Genéricas
  final String title;
  final IconData icon;

  // ✅ Descrições (Labels e Hints)
  final String labelHistorico;
  final String helperHistorico;

  const HistoricoDescritivoCard({
    super.key,
    required this.historicoController,
    this.title = "Histórico da Operação",
    this.icon = Icons.history_edu,
    this.labelHistorico = 'Histórico Descritivo *',
    this.helperHistorico = 'Descreva detalhadamente as ações realizadas durante a operação',
  });

  @override
  Widget build(BuildContext context) {
    return TacticalTheme.buildCard(
      title: title,
      icon: icon,
      iconColor: TacticalTheme.accentBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ HISTÓRICO - LIMPO, INFINITO E REATIVO
          TextFormField(
            controller: historicoController,
            // ❌ Limites removidos!
            minLines: 5,
            maxLines: null, // Cresce infinitamente conforme a digitação
            maxLength: null, // Sem limite de escrita (banco TEXT aguenta)
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences, // ✅ UX: Começa com maiúscula
            decoration: TacticalTheme.buildInputDecoration(
              labelHistorico,
              Icons.edit_note,
              helperText: helperHistorico,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'O preenchimento do histórico é obrigatório';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}