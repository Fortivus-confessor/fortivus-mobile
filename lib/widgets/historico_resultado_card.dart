import 'package:fortivus_app/util/dropdown_util.dart';
import 'package:flutter/material.dart';
import '../theme/tactical_theme.dart';

/// Card genérico para exibir histórico e resultado da ocorrência.
/// Utilizado em múltiplos formulários de resposta.
class HistoricoResultadoCard<T extends Enum> extends StatelessWidget {
  final List<T> enumValues;
  final T? resultadoSelecionado;
  final Function(T?) onResultadoChanged;
  final TextEditingController historicoController;
  final String title;
  final String labelHistorico;
  final String labelResultado;
  final bool showResultadoOutro;
  final TextEditingController? resultadoOutroController;

  const HistoricoResultadoCard({
    super.key,
    required this.enumValues,
    required this.resultadoSelecionado,
    required this.onResultadoChanged,
    required this.historicoController,
    this.title = 'Resultado e Histórico',
    this.labelHistorico = 'Histórico Descritivo *',
    this.labelResultado = 'Resultado da Ocorrência *',
    this.showResultadoOutro = false,
    this.resultadoOutroController,
  });

  String _getEnumDescription(T value) {
    try {
      return (value as dynamic).descricao;
    } catch (_) {
      return value.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TacticalTheme.buildCard(
      title: title,
      icon: Icons.assignment_turned_in,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo de Resultado
          DropdownButtonFormField<T>(
            value: resultadoSelecionado,
            isExpanded: true,
            itemHeight: null,
            decoration: TacticalTheme.buildInputDecoration(
              labelResultado,
              Icons.check_circle_outline,
            ),
            items: DropdownUtil.buildItems<T>(
              enumValues,
              (e) => _getEnumDescription(e),
            ),
            selectedItemBuilder: (context) => DropdownUtil.buildSelectedItems<T>(
              enumValues,
              (e) => _getEnumDescription(e),
            ),
            onChanged: onResultadoChanged,
            validator: (v) => v == null ? 'Campo obrigatório' : null,
          ),
          
          if (showResultadoOutro && resultadoOutroController != null) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: resultadoOutroController,
              textCapitalization: TextCapitalization.sentences,
              decoration: TacticalTheme.buildInputDecoration(
                'Especifique o resultado *',
                Icons.edit_note,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Campo obrigatório quando "Outro" é selecionado';
                }
                return null;
              },
            ),
          ],

          const SizedBox(height: 16),
          
          // Campo de Histórico
          TextFormField(
            controller: historicoController,
            maxLines: 5,
            minLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: TacticalTheme.buildInputDecoration(
              labelHistorico,
              Icons.history_edu,
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o histórico' : null,
          ),
        ],
      ),
    );
  }
}
