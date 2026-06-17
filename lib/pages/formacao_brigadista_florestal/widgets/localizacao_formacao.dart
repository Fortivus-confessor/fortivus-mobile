import 'package:fortivus_app/pages/formacao_brigadista_florestal/formacao_brigadista_state.dart';
import 'package:fortivus_app/widgets/combate_map_widget.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';

class LocalizacaoFormacaoCard extends StatefulWidget {
  const LocalizacaoFormacaoCard({super.key});

  @override
  State<LocalizacaoFormacaoCard> createState() =>
      _LocalizacaoFormacaoCardState();
}

class _LocalizacaoFormacaoCardState extends State<LocalizacaoFormacaoCard> {
  bool? _formacaoConforme;

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Não definido';
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FormacaoBrigadistaState>(
      builder: (context, state, _) {
        _formacaoConforme ??= state.formacaoConforme;

        return TacticalTheme.buildCard(
          title: "Localização e Período de Atuação",
          icon: Icons.location_on,
          iconColor: TacticalTheme.accentRed,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPerguntaConfirmacao(context, state),
              const SizedBox(height: 16),

              if (_formacaoConforme == true) ...[
                _buildResumoDespacho(state),
              ],

              if (_formacaoConforme == false) ...[
                _buildMapaSection(state),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Horários de Execução',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                _buildSeletorData(
                  context: context,
                  label: 'Deslocamento Inicial',
                  icon: Icons.departure_board,
                  value: state.deslocamentoInicialGuarnicao,
                  onChanged: state.setDeslocamentoInicial,
                  required: true,
                ),
                const SizedBox(height: 12),
                _buildSeletorData(
                  context: context,
                  label: 'Deslocamento Final',
                  icon: Icons.flag,
                  value: state.deslocamentoFinalGuarnicao,
                  minDate: state.deslocamentoInicialGuarnicao, // Trava a data mínima
                  onChanged: state.setDeslocamentoFinal,
                  required: true,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildSeletorData({
    required BuildContext context,
    required String label,
    required IconData icon,
    required DateTime? value,
    required Function(DateTime) onChanged,
    bool required = false,
    DateTime? minDate, // ✅ Usado para não travar o calendário ao clicar
  }) {
    return FormField<DateTime>(
      initialValue: value,
      validator: (v) {
        if (required && v == null) {
          return 'Campo obrigatório';
        }
        return null;
      },
      builder: (fieldState) {
        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () async {
            DateTime now = DateTime.now();
            DateTime primeiraDataPermitida = minDate ?? DateTime(2020);

            DateTime dataAberturaCalendario = value ?? now;
            if (dataAberturaCalendario.isBefore(primeiraDataPermitida)) {
              dataAberturaCalendario = primeiraDataPermitida;
            }

            final date = await showDatePicker(
              context: context,
              initialDate: dataAberturaCalendario,
              firstDate: primeiraDataPermitida,
              lastDate: now.add(const Duration(
                  days: 365)), // Evita travar se o usuário tentar colocar uma data futura
            );

            if (date != null && context.mounted) {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(value ?? now),
              );

              if (time != null) {
                final newValue = DateTime(
                    date.year, date.month, date.day, time.hour, time.minute);
                onChanged(newValue);
                fieldState.didChange(newValue);
              }
            }
          },
          child: InputDecorator(
            decoration: TacticalTheme.buildInputDecoration(
              label + (required ? ' *' : ''),
              icon,
              suffixIcon: const Icon(Icons.calendar_today, size: 16),
              errorText: fieldState.errorText,
            ),
            child: Text(
              _formatDateTime(value),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: value == null ? Colors.grey : Colors.black87,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerguntaConfirmacao(BuildContext context, FormacaoBrigadistaState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: Colors.blue[700]),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'A formação seguiu os dados previstos no despacho?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildBtnCheck(
                label: 'Sim',
                icon: Icons.check,
                activeColor: Colors.green,
                isSelected: _formacaoConforme == true,
                onPressed: () {
                  setState(() => _formacaoConforme = true);
                  state.setFormacaoConforme(true);

                  if (state.deslocamentoInicialDespacho != null) {
                    state.setDeslocamentoInicial(state.deslocamentoInicialDespacho);
                  }
                  if (state.deslocamentoFinalDespacho != null) {
                    state.setDeslocamentoFinal(state.deslocamentoFinalDespacho);
                  }
                  if (state.latitudeDespacho != null && state.longitudeDespacho != null) {
                    state.localizacaoNotifier.value = LatLng(
                      state.latitudeDespacho!,
                      state.longitudeDespacho!,
                    );
                  }
                },
              ),
              const SizedBox(width: 12),
              _buildBtnCheck(
                label: 'Não',
                icon: Icons.edit,
                activeColor: Colors.orange,
                isSelected: _formacaoConforme == false,
                onPressed: () {
                  setState(() => _formacaoConforme = false);
                  state.setFormacaoConforme(false);

                  // ✅ CORREÇÃO: Não reseta para null. 
                  // Mantém os dados originais do despacho nos campos como sugestão para o usuário editar.
                  if (state.deslocamentoInicialDespacho != null && state.deslocamentoInicialGuarnicao == null) {
                    state.setDeslocamentoInicial(state.deslocamentoInicialDespacho);
                  }
                  if (state.deslocamentoFinalDespacho != null && state.deslocamentoFinalGuarnicao == null) {
                    state.setDeslocamentoFinal(state.deslocamentoFinalDespacho);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBtnCheck({
    required String label,
    required IconData icon,
    required Color activeColor,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? activeColor : Colors.grey[300],
          foregroundColor: isSelected ? Colors.white : Colors.grey[700],
          elevation: isSelected ? 2 : 0,
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildResumoDespacho(FormacaoBrigadistaState state) {
    return ValueListenableBuilder<LatLng?>(
      valueListenable: state.localizacaoNotifier,
      builder: (context, localizacao, _) {
        final lat = localizacao?.latitude.toStringAsFixed(6) ??
            state.latitudeDespacho?.toStringAsFixed(6) ?? "--";
        final lon = localizacao?.longitude.toStringAsFixed(6) ??
            state.longitudeDespacho?.toStringAsFixed(6) ?? "--";

        final dataInicialExibida = state.deslocamentoInicialDespacho ?? state.deslocamentoInicialGuarnicao;
        final dataFinalExibida = state.deslocamentoFinalDespacho ?? state.deslocamentoFinalGuarnicao;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Dados do Despacho Original',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildInfoRow('📍 Localização', 'Lat: $lat | Lon: $lon'),
              const SizedBox(height: 6),
              _buildInfoRow('📅 Saída (Despacho)', _formatDateTime(dataInicialExibida)),
              const SizedBox(height: 6),
              _buildInfoRow('🏁 Retorno (Despacho)', _formatDateTime(dataFinalExibida)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_outline, size: 16, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Campos bloqueados (Preenchimento automático)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapaSection(FormacaoBrigadistaState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CombateMapWidget(
          initialLocation: state.localizacaoNotifier.value,
          mtBorderPoints: const [],
          isOfflineExterno: state.isOffline,
          enableManualInput: true,
          enableDmsConverter: true,
          onLocationSelected: (latLng) {
            state.setLocalizacao(latLng);
          },
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}