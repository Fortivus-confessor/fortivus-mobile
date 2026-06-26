import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';
import 'package:fortivus_app/enums/enums.dart';
import 'package:fortivus_app/util/dropdown_util.dart';
import '../combate_aereo_state.dart';
import '../../aereo/dialogs/datetime_picker_dialog.dart';

class DadosOperacionaisCard extends StatelessWidget {
  const DadosOperacionaisCard({super.key});

  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    return Consumer<CombateAereoState>(
      builder: (context, state, _) {
        return TacticalTheme.buildCard(
          title: "Dados Operacionais e Aeronave",
          icon: Icons.airplanemode_active,
          iconColor: TacticalTheme.accentBlue,
          child: Column(
            children: [
              _buildHorimetros(state),
              const SizedBox(height: 16),
              _buildDurationField(context, state),
              const SizedBox(height: 16),
              _buildHorarioChegadaField(context, state),
              const SizedBox(height: 16),
              _buildTipoEmprego(state),
              const SizedBox(height: 16),
              _buildVolumes(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHorimetros(CombateAereoState state) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: state.horimetroInicialController,
            decoration: TacticalTheme.buildInputDecoration('Horímetro Inicial', Icons.timer),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: state.horimetroFinalController,
            decoration: TacticalTheme.buildInputDecoration('Horímetro Final', Icons.timer_off),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationField(BuildContext context, CombateAereoState state) {
    return FormField<Duration>(
      initialValue: state.tempoOperacaoMinutos,
      validator: (value) => value == null ? 'Campo obrigatório' : null,
      builder: (fieldState) {
        return InkWell(
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: const TimeOfDay(hour: 0, minute: 0),
              helpText: 'Duração da Operação',
            );
            if (time != null) {
              final duration = Duration(hours: time.hour, minutes: time.minute);
              state.setTempoOperacao(duration);
              fieldState.didChange(duration);
            }
          },
          child: InputDecorator(
            decoration: TacticalTheme.buildInputDecoration(
              'Tempo de Operação *',
              Icons.access_time,
              suffixIcon: const Icon(Icons.edit, size: 20),
              errorText: fieldState.errorText,
            ),
            child: Text(
              state.tempoOperacaoMinutos != null
                  ? '${(state.tempoOperacaoMinutos!.inMinutes ~/ 60).toString().padLeft(2, '0')}:${(state.tempoOperacaoMinutos!.inMinutes % 60).toString().padLeft(2, '0')}'
                  : 'Toque para definir',
              style: TextStyle(
                color: state.tempoOperacaoMinutos != null ? Colors.black87 : Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHorarioChegadaField(BuildContext context, CombateAereoState state) {
    return FormField<DateTime>(
      initialValue: state.horarioChegada,
      validator: (v) => v == null ? 'Campo obrigatório' : null,
      builder: (fieldState) {
        return InkWell(
          onTap: () async {
            final resultado = await showDateTimePickerDialog(
              context: context,
              initialDateTime: state.horarioChegada,
            );
            if (resultado != null) {
              state.setHorarioChegada(resultado);
              fieldState.didChange(resultado);
            }
          },
          child: InputDecorator(
            decoration: TacticalTheme.buildInputDecoration(
              'Horário de Chegada *',
              Icons.calendar_today,
              suffixIcon: const Icon(Icons.edit, size: 20),
              errorText: fieldState.errorText,
            ),
            child: Text(
              state.horarioChegada != null
                  ? _dateTimeFormat.format(state.horarioChegada!)
                  : 'Toque para definir',
              style: TextStyle(
                color: state.horarioChegada != null ? Colors.black87 : Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTipoEmprego(CombateAereoState state) {
    return DropdownButtonFormField<TipoEmpregoAereo>(
      value: state.tipoEmprego,
      isExpanded: true,
      itemHeight: null,
      decoration: TacticalTheme.buildInputDecoration('Tipo de Emprego *', Icons.category),
      items: DropdownUtil.buildItems<TipoEmpregoAereo>(
        TipoEmpregoAereo.values,
        (e) => e.descricao,
      ),
      selectedItemBuilder: (context) => DropdownUtil.buildSelectedItems<TipoEmpregoAereo>(
        TipoEmpregoAereo.values,
        (e) => e.descricao,
      ),
      onChanged: state.setTipoEmprego,
      validator: (v) => v == null ? 'Campo obrigatório' : null,
    );
  }

  Widget _buildVolumes(CombateAereoState state) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: state.litrosAguaController,
            decoration: TacticalTheme.buildInputDecoration('Litros de Água', Icons.water_drop),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: state.alijamentosController,
            decoration: TacticalTheme.buildInputDecoration('Lançamentos', Icons.file_upload_outlined),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
      ],
    );
  }
}
