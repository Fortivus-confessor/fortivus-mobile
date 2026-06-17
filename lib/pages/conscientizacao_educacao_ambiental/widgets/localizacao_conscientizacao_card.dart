import 'package:fortivus_app/enums/tipo_acao_coscientizacao.dart';
import 'package:fortivus_app/util/dropdown_util.dart';
import 'package:fortivus_app/widgets/combate_map_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';
import '../conscientizacao_state.dart';
import '../../combate_incendio/aereo/dialogs/datetime_picker_dialog.dart';

class LocalizacaoConscientizacaoCard extends StatelessWidget {
  const LocalizacaoConscientizacaoCard({super.key});

  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    return Consumer<ConscientizacaoState>(
      builder: (context, state, _) {
        return TacticalTheme.buildCard(
          title: "Localização e Execução",
          icon: Icons.location_on,
          iconColor: TacticalTheme.accentOrange,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MAPA
              Container(
                height: 250,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: CombateMapWidget(
                  initialLocation: state.localizacaoNotifier.value,
                  onLocationSelected: (ponto) {
                    state.setLocalizacao(ponto);
                  },
                ),
              ),
              const SizedBox(height: 16),

              // DATAS DE EXECUÇÃO
              Row(
                children: [
                  Expanded(
                    child: _buildSeletorData(
                      context: context,
                      label: 'Deslocamento Inicial',
                      icon: Icons.departure_board,
                      value: state.deslocamentoInicial,
                      onChanged: state.setDeslocamentoInicial,
                      required: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSeletorData(
                      context: context,
                      label: 'Deslocamento Final',
                      icon: Icons.flag,
                      value: state.deslocamentoFinal,
                      onChanged: state.setDeslocamentoFinal,
                      required: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // TIPO DE AÇÃO (DROPDOWN)
              const Text(
                'Tipo de Ação Realizada *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<TipoAcaoConscientizacao>(
                isExpanded: true, 
                value: state.acaoSelecionada,
                itemHeight: null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.school),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: DropdownUtil.buildItems<TipoAcaoConscientizacao>(
                  TipoAcaoConscientizacao.values,
                  (e) => e.descricao,
                ),
                selectedItemBuilder: (context) => DropdownUtil.buildSelectedItems<TipoAcaoConscientizacao>(
                  TipoAcaoConscientizacao.values,
                  (e) => e.descricao,
                ),
                onChanged: state.setAcaoSelecionada,
                validator: (v) => v == null ? 'Campo obrigatório' : null,
              ),

              // CAMPO "OUTRO" PARA AÇÃO
              if (state.acaoSelecionada == TipoAcaoConscientizacao.OUTRO) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: state.acaoOutroController,
                  decoration: TacticalTheme.buildInputDecoration(
                    'Especifique a ação *',
                    Icons.edit_note,
                  ),
                  validator: (v) {
                    if (state.acaoSelecionada == TipoAcaoConscientizacao.OUTRO && (v == null || v.trim().isEmpty)) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
        );
      },
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
          borderRadius: BorderRadius.circular(8),
          onTap: () async {
            final resultado = await showDateTimePickerDialog(
              context: context,
              initialDateTime: value,
            );

            if (resultado != null) {
              onChanged(resultado);
              fieldState.didChange(resultado);
            }
          },
          child: InputDecorator(
            decoration: TacticalTheme.buildInputDecoration(
              label,
              icon,
              errorText: fieldState.errorText,
              suffixIcon: const Icon(Icons.calendar_today, size: 18),
            ),
            child: Text(
              value != null ? _dateTimeFormat.format(value) : 'Definir',
              style: TextStyle(
                color: value != null ? Colors.black87 : Colors.grey[600],
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }
}
