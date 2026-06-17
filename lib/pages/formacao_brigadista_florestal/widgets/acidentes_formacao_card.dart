import 'package:fortivus_app/pages/formacao_brigadista_florestal/formacao_brigadista_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';

class AcidentesFormacaoCard extends StatelessWidget {
  const AcidentesFormacaoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FormacaoBrigadistaState>(
      builder: (context, state, _) {
        return TacticalTheme.buildCard(
          title: "Acidentes/Incidentes",
          icon: Icons.warning_amber,
          iconColor: Colors.red,
          child: Column(
            children: [
              // ✅ Checkbox
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: state.acidentesIncidentesOcorridos,
                          onChanged: (value) {
                            state.setAcidentesIncidentes(value ?? false);
                          },
                        ),
                        Expanded(
                          child: Text(
                            'Houve acidentes ou incidentes? *',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.red[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (state.acidentesIncidentesOcorridos) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: state.descricaoAcidenteIncidente ?? '',
                        decoration: TacticalTheme.buildInputDecoration(
                          'Descrição do Acidente/Incidente *',
                          Icons.description_outlined,
                          helperText: 'Detalhe o acidente ou incidente ocorrido',
                        ),
                        maxLines: 3,
                        maxLength: 500,
                        validator: (v) {
                          if (state.acidentesIncidentesOcorridos && (v == null || v.trim().isEmpty)) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          state.descricaoAcidenteIncidente = value.trim();
                        },
                      ),
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