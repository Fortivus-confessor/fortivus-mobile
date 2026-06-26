import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';
import 'package:fortivus_app/enums/enums.dart';
import 'package:fortivus_app/util/dropdown_util.dart';
import '../combate_maquinario_state.dart';
import '../dialogs/datetime_picker_dialog.dart';

class DadosOperacionaisCard extends StatelessWidget {
  const DadosOperacionaisCard({super.key});

  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    return Consumer<CombateMaquinarioState>(
      builder: (context, state, _) {
        return TacticalTheme.buildCard(
          title: "Dados Operacionais e Maquinário",
          icon: Icons.settings,
          iconColor: TacticalTheme.accentBlue,
          child: Column(
            children: [
              _buildHorariosOperacao(context, state),
              const SizedBox(height: 12),
              _buildTempoLiquido(state),
              const SizedBox(height: 16),
              _buildHorarioChegada(context, state),
              const SizedBox(height: 16),
              _buildHorimetros(state),
              const SizedBox(height: 16),
              _buildTipoEmprego(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHorariosOperacao(BuildContext context, CombateMaquinarioState state) {
    return Row(
      children: [
        Expanded(
          child: FormField<DateTime>(
            initialValue: state.horaInicioOperacao,
            validator: (v) => v == null ? 'Obrigatório' : null,
            builder: (fieldState) {
              return InkWell(
                onTap: () async {
                  final resultado = await showDateTimePickerDialog(
                    context: context,
                    initialDateTime: state.horaInicioOperacao,
                  );
                  if (resultado != null) {
                    state.setHoraInicioOperacao(resultado);
                    fieldState.didChange(resultado);
                  }
                },
                child: InputDecorator(
                  decoration: TacticalTheme.buildInputDecoration(
                    'Início Operação *',
                    Icons.play_circle,
                    suffixIcon: const Icon(Icons.edit, size: 20),
                    errorText: fieldState.errorText,
                  ),
                  child: Text(
                    state.horaInicioOperacao != null
                        ? _timeFormat.format(state.horaInicioOperacao!)
                        : 'Definir',
                    style: TextStyle(
                      color: state.horaInicioOperacao != null ? Colors.black87 : Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FormField<DateTime>(
            initialValue: state.horaFinalOperacao,
            validator: (v) => v == null ? 'Obrigatório' : null,
            builder: (fieldState) {
              return InkWell(
                onTap: () async {
                  final resultado = await showDateTimePickerDialog(
                    context: context,
                    initialDateTime: state.horaFinalOperacao,
                  );
                  if (resultado != null) {
                    state.setHoraFinalOperacao(resultado);
                    fieldState.didChange(resultado);
                  }
                },
                child: InputDecorator(
                  decoration: TacticalTheme.buildInputDecoration(
                    'Fim Operação *',
                    Icons.stop_circle,
                    suffixIcon: const Icon(Icons.edit, size: 20),
                    errorText: fieldState.errorText,
                  ),
                  child: Text(
                    state.horaFinalOperacao != null
                        ? _timeFormat.format(state.horaFinalOperacao!)
                        : 'Definir',
                    style: TextStyle(
                      color: state.horaFinalOperacao != null ? Colors.black87 : Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTempoLiquido(CombateMaquinarioState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 10),
          const Text(
            'Tempo Líquido: ',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(
            state.tempoLiquido,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorarioChegada(BuildContext context, CombateMaquinarioState state) {
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
              Icons.access_time,
              suffixIcon: const Icon(Icons.calendar_today, size: 20),
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

  Widget _buildHorimetros(CombateMaquinarioState state) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: state.horimetroInicialController,
            decoration: TacticalTheme.buildInputDecoration('Horímetro Inicial', Icons.timer),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: state.horimetroFinalController,
            decoration: TacticalTheme.buildInputDecoration('Horímetro Final', Icons.timer_off),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
      ],
    );
  }

  Widget _buildTipoEmprego(CombateMaquinarioState state) {
    return DropdownButtonFormField<TipoEmpregoMaquinario>(
      value: state.tipoEmprego,
      isExpanded: true,
      itemHeight: null,
      decoration: TacticalTheme.buildInputDecoration('Tipo de Emprego *', Icons.category),
      items: DropdownUtil.buildItems<TipoEmpregoMaquinario>(
        TipoEmpregoMaquinario.values,
        (e) => e.descricao,
      ),
      selectedItemBuilder: (context) => DropdownUtil.buildSelectedItems<TipoEmpregoMaquinario>(
        TipoEmpregoMaquinario.values,
        (e) => e.descricao,
      ),
      onChanged: state.setTipoEmprego,
      validator: (v) => v == null ? 'Campo obrigatório' : null,
    );
  }
}
