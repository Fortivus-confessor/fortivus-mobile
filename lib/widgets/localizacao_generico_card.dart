import 'package:flutter/material.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';
import 'package:fortivus_app/theme/fortivus_colors.dart';
import 'package:fortivus_app/widgets/combate_map_widget.dart';
import 'package:latlong2/latlong.dart';

class LocalizacaoGenericoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool mostrarVerificacaoDespacho;
  final ValueNotifier<LatLng?> localizacaoNotifier;
  final bool isOffline;
  final Function(LatLng) onLocationSelected;
  final bool? verificacaoDespacho;
  final Function(bool)? onVerificacaoDespachoChanged;
  
  // ✅ NOVO: Parâmetros para datas de deslocamento (para avulso)
  final DateTime? deslocamentoInicial;
  final DateTime? deslocamentoFinal;
  final Function(DateTime)? onDeslocamentoInicialChanged;
  final Function(DateTime)? onDeslocamentoFinalChanged;

  const LocalizacaoGenericoCard({
    super.key,
    this.title = 'Localização da Atividade',
    this.subtitle = 'Selecione a localização onde a atividade foi realizada',
    this.mostrarVerificacaoDespacho = true,
    required this.localizacaoNotifier,
    required this.isOffline,
    required this.onLocationSelected,
    this.verificacaoDespacho,
    this.onVerificacaoDespachoChanged,
    this.deslocamentoInicial,
    this.deslocamentoFinal,
    this.onDeslocamentoInicialChanged,
    this.onDeslocamentoFinalChanged,
  });

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Não definido';
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return TacticalTheme.buildCard(
      title: title,
      icon: Icons.location_on,
      iconColor: TacticalTheme.accentRed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: context.fx.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // ✅ MAPA
          CombateMapWidget(
            initialLocation: localizacaoNotifier.value,
            mtBorderPoints: const [],
            isOfflineExterno: isOffline,
            enableManualInput: true,
            enableDmsConverter: true,
            onLocationSelected: onLocationSelected,
          ),

          // ✅ VERIFICAÇÃO DESPACHO (CONDICIONAL)
          if (mostrarVerificacaoDespacho) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.fx.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.fx.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status da Execução',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: context.fx.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: verificacaoDespacho ?? true,
                    onChanged: (value) {
                      onVerificacaoDespachoChanged?.call(value ?? true);
                    },
                    title: const Text(
                      'A atividade seguiu os dados previstos no despacho',
                      style: TextStyle(fontSize: 13),
                    ),
                    subtitle: const Text(
                      'Selecione se a execução ocorreu conforme planejado',
                      style: TextStyle(fontSize: 11),
                    ),
                    activeColor: TacticalTheme.accentOrange,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ],

          // ✅ NOVO: SELETORES DE DATA (SEM PERGUNTA DE DESPACHO)
          if (!mostrarVerificacaoDespacho && 
              onDeslocamentoInicialChanged != null && 
              onDeslocamentoFinalChanged != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            _buildSeletorData(
              context: context,
              label: 'Deslocamento Inicial',
              icon: Icons.departure_board,
              value: deslocamentoInicial,
              onChanged: onDeslocamentoInicialChanged!,
              required: true,
            ),
            const SizedBox(height: 12),
            _buildSeletorData(
              context: context,
              label: 'Deslocamento Final',
              icon: Icons.flag,
              value: deslocamentoFinal,
              onChanged: onDeslocamentoFinalChanged!,
              required: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSeletorData({
    required BuildContext context,
    required String label,
    required IconData icon,
    required DateTime? value,
    required Function(DateTime) onChanged,
    bool required = false,
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
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 1)),
            );

            if (date != null && context.mounted) {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(value ?? DateTime.now()),
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
}