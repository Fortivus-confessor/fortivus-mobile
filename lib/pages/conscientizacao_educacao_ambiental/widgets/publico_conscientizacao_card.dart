import 'package:fortivus_app/pages/conscientizacao_educacao_ambiental/conscientizacao_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';
/// Card para quantidade de público atingido
class PublicoConscientizacaoCard extends StatelessWidget {
  const PublicoConscientizacaoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConscientizacaoState>(
      builder: (context, state, _) {
        return TacticalTheme.buildCard(
          title: "Público Atingido",
          icon: Icons.people,
          iconColor: TacticalTheme.accentRed,
          child: Column(
            children: [
              TextFormField(
                controller: state.publicoEstimadoController,
                decoration: TacticalTheme.buildInputDecoration(
                  'Qtd. Público Atingido/Orientado *',
                  Icons.people_outline,
                  helperText: 'Número de pessoas impactadas pela atividade',
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