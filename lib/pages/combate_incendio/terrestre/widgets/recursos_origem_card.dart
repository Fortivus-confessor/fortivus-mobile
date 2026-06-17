import 'package:fortivus_app/components/chip_field.dart';
import 'package:fortivus_app/components/tactical_card.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';
import 'package:fortivus_app/util/dropdown_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fortivus_app/pages/combate_incendio/terrestre/combate_terrestre_state.dart' as state_module;
import 'package:fortivus_app/enums/enums.dart';
import 'package:intl/intl.dart';

// ✅ IMPORT DO NOVO COMPONENTE GENÉRICO
import 'package:fortivus_app/widgets/anexo_unico_card.dart'; 

class RecursosOrigemCard extends StatefulWidget {
  const RecursosOrigemCard({super.key});

  @override
  State<RecursosOrigemCard> createState() => _RecursosOrigemCardState();
}

class _RecursosOrigemCardState extends State<RecursosOrigemCard> {
  // ============================================================================
  // HELPERS
  // ============================================================================
  String _formatarKm(String valor) {
    if (valor.isEmpty) return '';
    final numero = int.tryParse(valor.replaceAll('.', ''));
    if (numero == null) return valor;
    final formatter = NumberFormat('#,##0', 'pt_BR');
    return formatter.format(numero).replaceAll(',', '.');
  }

  // ============================================================================
  // BUILD
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    return Consumer<state_module.CombateTerrestreState>(
      builder: (context, state, _) {
        return TacticalCard(
          title: "Recursos e Origem",
          icon: Icons.water_drop,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ ÁGUA E KM
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: state.litrosAguaController,
                      decoration: const InputDecoration(
                        labelText: 'Água (L) *',
                        prefixIcon: Icon(Icons.opacity),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: state.quilometragemController,
                      decoration: const InputDecoration(
                        labelText: 'KM da Viatura*',
                        prefixIcon: Icon(Icons.speed),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          if (newValue.text.isEmpty) return newValue;
                          final formatted = _formatarKm(newValue.text);
                          return TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(
                              offset: formatted.length,
                            ),
                          );
                        }),
                      ],
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Obrigatório' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ✅ ORIGEM DA ÁGUA
              ChipField<OrigemAgua>(
                label: 'Origem da Água',
                options: OrigemAgua.values,
                selectedValues: state.origensAgua,
                onChanged: state.setOrigensAgua,
                required: true,
                exclusiveValue: OrigemAgua.NENHUM,
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // ✅ TÍTULO DA SEÇÃO
              const Row(
                children: [
                  Icon(Icons.local_fire_department,
                      color: TacticalTheme.accentBlue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Possível Causa do Incêndio',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: TacticalTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<TipoCausaIncendio>(
                value: state.origemIncendio,
                isExpanded: true,
                itemHeight: null,
                decoration: const InputDecoration(
                  labelText: 'Selecione a causa *',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                items: DropdownUtil.buildItems<TipoCausaIncendio>(
                  TipoCausaIncendio.values,
                  (e) => e.descricao,
                ),
                selectedItemBuilder: (context) => DropdownUtil.buildSelectedItems<TipoCausaIncendio>(
                  TipoCausaIncendio.values,
                  (e) => e.descricao,
                ),
                onChanged: state.setOrigemIncendio,
                validator: (v) => v == null ? 'Obrigatório' : null,
              ),

              const SizedBox(height: 16),

              // ✅ O NOVO WIDGET GENÉRICO DE ANEXO ÚNICO
              AnexoUnicoCard(
                title: 'Imagem da Causa/Origem',
                infoText: 'Anexe ou tire uma foto que evidencie a provável origem ou causa do incêndio.',
                icon: Icons.camera_alt_outlined,
                picker: state.picker,
                arquivoSelecionado: state.imagemOrigem, 
                onArquivoChanged: (novoArquivo) {
                  state.setImagemOrigem(novoArquivo);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}