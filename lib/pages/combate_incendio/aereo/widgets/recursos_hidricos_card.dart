import 'package:fortivus_app/components/chip_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';
import 'package:fortivus_app/enums/enums.dart';
import '../combate_aereo_state.dart';

class RecursosHidricosCard extends StatelessWidget {
  const RecursosHidricosCard({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('💧 [RECURSOS HÍDRICOS CARD] build() chamado');
    return Consumer<CombateAereoState>(
      builder: (context, state, _) {
        debugPrint('💧 [RECURSOS HÍDRICOS] litrosAgua: ${state.litrosAguaController.text}');
        debugPrint('💧 [RECURSOS HÍDRICOS] origensAgua: ${state.origensAgua}');
        return TacticalTheme.buildCard(
          title: "Recursos Hídricos",
          icon: Icons.water_drop,
          iconColor: TacticalTheme.accentBlue,
          child: Column(
            children: [
              TextFormField(
                controller: state.litrosAguaController,
                decoration: TacticalTheme.buildInputDecoration(
                  'Litros de Água *',
                  Icons.opacity,
                  helperText: 'Quantidade total de água utilizada',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  final valor = int.tryParse(v);
                  if (valor == null || valor <= 0) {
                    return 'Informe um valor válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ChipField<OrigemAgua>(
                label: 'Origem da Água',
                options: OrigemAgua.values,
                selectedValues: state.origensAgua,
                onChanged: state.setOrigensAgua,
                required: true,
              ),
            ],
          ),
        );
      },
    );
  }
}
