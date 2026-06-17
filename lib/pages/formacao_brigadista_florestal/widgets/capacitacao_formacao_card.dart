import 'package:fortivus_app/pages/formacao_brigadista_florestal/formacao_brigadista_state.dart';
import 'package:fortivus_app/widgets/combate_map_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';

class CapacitacaoFormacaoCard extends StatelessWidget {
  const CapacitacaoFormacaoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FormacaoBrigadistaState>(
      builder: (context, state, _) {
        return TacticalTheme.buildCard(
          title: "Queima de Instrução",
          icon: Icons.fire_extinguisher,
          iconColor: TacticalTheme.accentRed,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Checkbox para queima
                    Row(
                      children: [
                        Checkbox(
                          value: state.queimaInstrucaoRealizada,
                          onChanged: (value) {
                            state.setQueimaInstrucao(value ?? false);
                          },
                          activeColor: TacticalTheme.primary,
                        ),
                        Expanded(
                          child: Text(
                            'Houve queima de instrução?',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ✅ Se ATIVADO: Mostrar mapa
                    if (state.queimaInstrucaoRealizada) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      // ✅ MAPA
                      Text(
                        'Localização da Queima de Instrução',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),

                      CombateMapWidget(
                        initialLocation: state.localizacaoQueimaNotifier.value,
                        mtBorderPoints: const [],
                        isOfflineExterno: state.isOffline,
                        enableManualInput: true,
                        enableDmsConverter: true,
                        onLocationSelected: (latLng) {
                          state.setLocalizacaoQueima(latLng);
                        },
                      ),

                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}