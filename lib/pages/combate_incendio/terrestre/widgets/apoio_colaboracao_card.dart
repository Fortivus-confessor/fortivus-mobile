import 'package:fortivus_app/components/tactical_card.dart';
import 'package:fortivus_app/pages/combate_incendio/terrestre/dialogs/propriedades_dialogs.dart';
import 'package:fortivus_app/pages/combate_incendio/terrestre/widgets/propriedades_list_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../combate_terrestre_state.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';

class ApoioColaboracaoCard extends StatelessWidget {
  const ApoioColaboracaoCard({super.key});

  void _abrirDialog(BuildContext context, {int? index}) async {
    final state = context.read<CombateTerrestreState>();
    final resultado = await showDialog(
      context: context,
      builder: (ctx) => PropriedadeDialog(
        existente: index != null ? state.propriedades[index] : null,
        localizacaoInicial: state.localizacao,
        eventoFogoGeoJson: state.eventoFogoGeoJson,
      ),
    );
    if (resultado != null) {
      if (index != null) {
        state.atualizarPropriedade(index, resultado);
      } else {
        state.adicionarPropriedade(resultado);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CombateTerrestreState>(
      builder: (context, state, _) {
        return TacticalCard(
          title: "Apoio e Colaboração",
          icon: Icons.handshake,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Propriedades Rurais",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _abrirDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Adicionar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TacticalTheme.accentBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (state.propriedades.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Nenhuma propriedade registrada.",
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.propriedades.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, index) {
                    return PropriedadeListItem(
                      key: ValueKey(state.propriedades[index].id ?? index),
                      propriedade: state.propriedades[index],
                      onEdit: () => _abrirDialog(context, index: index),
                      onDelete: () => state.removerPropriedade(index),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
