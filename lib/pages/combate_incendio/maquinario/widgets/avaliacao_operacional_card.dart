import 'package:fortivus_app/pages/combate_incendio/maquinario/combate_maquinario_state.dart';
import 'package:fortivus_app/util/dropdown_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fortivus_app/theme/tactical_theme.dart';
import 'package:fortivus_app/enums/enums.dart';

class AvaliacaoOperacionalCard extends StatelessWidget {
  const AvaliacaoOperacionalCard({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('📊 [AVALIAÇÃO OPERACIONAL CARD] build() chamado');
    
    return Consumer<CombateMaquinarioState>(
      builder: (context, state, _) {
        debugPrint('📊 [AVALIAÇÃO OPERACIONAL] efetividade: ${state.efetividade}');
        debugPrint('📊 [AVALIAÇÃO OPERACIONAL] reforco: ${state.reforco}');
        return TacticalTheme.buildCard(
          title: "Avaliação Operacional",
          icon: Icons.analytics,
          iconColor: TacticalTheme.accentBlue,
          child: Column(
            children: [
              // Efetividade do combate
              DropdownButtonFormField<TipoEfetividadeCombate>(
                value: state.efetividade,
                isExpanded: true,
                itemHeight: null,
                decoration: TacticalTheme.buildInputDecoration(
                  'Efetividade do Combate *',
                  Icons.trending_up,
                  helperText: 'Avalie a eficácia da operação',
                ),
                items: DropdownUtil.buildItems<TipoEfetividadeCombate>(
                  TipoEfetividadeCombate.values,
                  (e) => e.descricao,
                ),
                selectedItemBuilder: (context) => DropdownUtil.buildSelectedItems<TipoEfetividadeCombate>(
                  TipoEfetividadeCombate.values,
                  (e) => e.descricao,
                ),
                onChanged: state.setEfetividade,
                validator: (v) => v == null ? 'Campo obrigatório' : null,
              ),

              const SizedBox(height: 16),

              // Necessidade de reforço
              DropdownButtonFormField<Reforco>(
                value: state.reforco,
                isExpanded: true,
                itemHeight: null,
                decoration: TacticalTheme.buildInputDecoration(
                  'Necessidade de Reforço *',
                  Icons.add_moderator,
                  helperText: 'Recursos adicionais necessários',
                ),
                items: DropdownUtil.buildItems<Reforco>(
                  Reforco.values,
                  (e) {
                    try {
                      return (e as dynamic).descricao;
                    } catch (_) {
                      return e.name;
                    }
                  },
                ),
                selectedItemBuilder: (context) => DropdownUtil.buildSelectedItems<Reforco>(
                  Reforco.values,
                  (e) {
                    try {
                      return (e as dynamic).descricao;
                    } catch (_) {
                      return e.name;
                    }
                  },
                ),
                onChanged: state.setReforco,
                validator: (v) => v == null ? 'Campo obrigatório' : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
