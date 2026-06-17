import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';
import '../combate_maquinario_state.dart';

class ProducaoCard extends StatelessWidget {
  const ProducaoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CombateMaquinarioState>(
      builder: (context, state, _) {
        return TacticalTheme.buildCard(
          title: "Produção",
          icon: Icons.straighten,
          iconColor: TacticalTheme.accentGreen,
          child: Column(
            children: [
              TacticalTheme.buildInfoBox(
                'Informe o comprimento total do aceiro construído',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: state.comprimentoAceiroController,
                decoration: TacticalTheme.buildInputDecoration(
                  'Comprimento do Aceiro (metros)',
                  Icons.architecture,
                  helperText: 'Exemplo: 1500 ou 1500.50',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
