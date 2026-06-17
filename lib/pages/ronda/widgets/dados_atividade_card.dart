import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:fortivus_app/theme/tactical_theme.dart';
import 'package:fortivus_app/enums/tipo_acao_ronda.dart';
import 'package:fortivus_app/enums/tipo_assuntos_abordados.dart';
import 'package:fortivus_app/components/chip_field.dart';

import '../ronda_state.dart';

/// Card para dados da atividade de ronda
/// 
/// Contém:
/// - Ações realizadas
/// - Assuntos abordados
/// - Quantidade de pessoas atingidas
class DadosAtividadeCard extends StatelessWidget {
  const DadosAtividadeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RondaState>(
      builder: (context, state, _) {
        return TacticalTheme.buildCard(
          title: "Dados da Atividade",
          icon: Icons.security,
          iconColor: TacticalTheme.accentBlue,
          child: Column(
            children: [
              // AÇÕES REALIZADAS
              ChipField<TipoAcaoRonda>(
                label: 'Ação Realizada',
                options: TipoAcaoRonda.values,
                selectedValues: state.acoesSelecionadas,
                onChanged: state.setAcoesSelecionadas,
                required: true,
              ),

              // Campo adicional se selecionou "OUTRO"
              if (state.acoesSelecionadas.contains(TipoAcaoRonda.OUTRO)) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: state.acaoOutroController,
                  decoration: TacticalTheme.buildInputDecoration(
                    'Descreva a outra ação *',
                    Icons.edit_note,
                    helperText: 'Especifique qual foi a ação realizada',
                  ),
                  maxLines: 2,
                  maxLength: 200,
                  validator: (v) {
                    if (state.acoesSelecionadas.contains(TipoAcaoRonda.OUTRO) &&
                        (v == null || v.trim().isEmpty)) {
                      return 'Campo obrigatório quando "Outro" é selecionado';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 16),

              // ASSUNTOS ABORDADOS
              ChipField<TipoAssuntosAbordados>(
                label: 'Assuntos Abordados',
                options: TipoAssuntosAbordados.values,
                selectedValues: state.assuntosSelecionados,
                onChanged: state.setAssuntosSelecionados,
                required: false,
              ),

              const SizedBox(height: 16),

              // QUANTIDADE DE PESSOAS ATINGIDAS
              TextFormField(
                controller: state.pessoasAtingidasController,
                decoration: TacticalTheme.buildInputDecoration(
                  'Qtd. Pessoas Atingidas *',
                  Icons.groups,
                  helperText: 'Número de pessoas impactadas pela ronda',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  if (int.tryParse(v) == null) {
                    return 'Digite um número válido';
                  }
                  if (int.parse(v) < 0) {
                    return 'Não pode ser negativo';
                  }
                  return null;
                },
              ),
            ],
          ),
        );
      },
    );
  }
}