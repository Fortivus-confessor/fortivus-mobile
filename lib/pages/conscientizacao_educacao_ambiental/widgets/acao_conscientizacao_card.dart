import 'package:fortivus_app/util/dropdown_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';
import 'package:fortivus_app/enums/tipo_acao_coscientizacao.dart';
import '../conscientizacao_state.dart';

class AcaoConscientizacaoCard extends StatelessWidget {
  const AcaoConscientizacaoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConscientizacaoState>(
      builder: (context, state, _) {
        return TacticalTheme.buildCard(
          title: "Detalhes da Ação",
          icon: Icons.info_outline,
          iconColor: TacticalTheme.accentGreen,
          child: Column(
            children: [
              // Público Estimado
              TextFormField(
                controller: state.publicoEstimadoController,
                decoration: TacticalTheme.buildInputDecoration(
                  'Público Estimado *',
                  Icons.groups,
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Informe o público';
                  }
                  if (int.tryParse(v) == null) {
                    return 'Número inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tipo de Ação
              DropdownButtonFormField<TipoAcaoConscientizacao>(
                value: state.acaoSelecionada,
                isExpanded: true,
                itemHeight: null,
                decoration: TacticalTheme.buildInputDecoration(
                  'Tipo de Ação *',
                  Icons.select_all,
                ),
                items: DropdownUtil.buildItems<TipoAcaoConscientizacao>(
                  TipoAcaoConscientizacao.values,
                  (e) => e.descricao,
                ),
                selectedItemBuilder: (context) => DropdownUtil.buildSelectedItems<TipoAcaoConscientizacao>(
                  TipoAcaoConscientizacao.values,
                  (e) => e.descricao,
                ),
                onChanged: state.setAcaoSelecionada,
                validator: (v) => v == null ? 'Campo obrigatório' : null,
              ),

              if (state.acaoSelecionada == TipoAcaoConscientizacao.OUTRO) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: state.acaoOutroController,
                  decoration: TacticalTheme.buildInputDecoration(
                    'Especifique a ação *',
                    Icons.edit_note,
                  ),
                  validator: (v) {
                    if (state.acaoSelecionada == TipoAcaoConscientizacao.OUTRO && (v == null || v.trim().isEmpty)) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
