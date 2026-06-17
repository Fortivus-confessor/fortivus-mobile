import 'package:fortivus_app/components/chip_field.dart';
import 'package:fortivus_app/components/tactical_card.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../combate_terrestre_state.dart';
import 'package:fortivus_app/enums/enums.dart';
import '../../maquinario/dialogs/datetime_picker_dialog.dart';

class InformacoesCombateCard extends StatefulWidget {
  const InformacoesCombateCard({super.key});

  @override
  State<InformacoesCombateCard> createState() => _InformacoesCombateCardState();
}

class _InformacoesCombateCardState extends State<InformacoesCombateCard>
    with AutomaticKeepAliveClientMixin {
  
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  bool get wantKeepAlive => true;

  Widget _buildHorarioChegada(BuildContext context, CombateTerrestreState state) {
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Consumer<CombateTerrestreState>(
      builder: (context, state, _) {
        return TacticalCard(
          title: "Informações de Combate",
          icon: Icons.local_fire_department,
          child: Column(
            children: [
              _buildHorarioChegada(context, state),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              ChipField<TipoAcaoCombate>(
                label: 'Ações de Combate',
                options: TipoAcaoCombate.values,
                selectedValues: state.acoes,
                onChanged: state.setAcoes,
                required: true,
                exclusiveValue: TipoAcaoCombate.NENHUM,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              ChipField<TipoApoioOrgao>(
                label: 'Órgãos de Apoio',
                options: TipoApoioOrgao.values,
                selectedValues: state.apoios,
                onChanged: state.setApoios,
                required: true,
                exclusiveValue: TipoApoioOrgao.NENHUM,
              ),
              if (state.apoios.contains(TipoApoioOrgao.OUTRO)) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: state.apoioOutroController,
                  decoration: const InputDecoration(
                    labelText: 'Descreva o órgão de apoio *',
                    prefixIcon: Icon(Icons.edit),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
                ),
              ],
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              ChipField<TipoMaterialUtilizado>(
                label: 'Materiais Utilizados',
                options: TipoMaterialUtilizado.values,
                selectedValues: state.materiais,
                onChanged: state.setMateriais,
                required: true,
                exclusiveValue: TipoMaterialUtilizado.NENHUM,
              ),
            ],
          ),
        );
      },
    );
  }
}