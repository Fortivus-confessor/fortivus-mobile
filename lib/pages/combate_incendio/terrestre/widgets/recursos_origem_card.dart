import 'package:fortivus_app/components/chip_field.dart';
import 'package:fortivus_app/components/tactical_card.dart';
import 'package:fortivus_app/util/dropdown_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fortivus_app/pages/combate_incendio/terrestre/combate_terrestre_state.dart' as state_module;
import 'package:fortivus_app/enums/enums.dart';

class RecursosOrigemCard extends StatelessWidget {
  const RecursosOrigemCard({super.key});

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
              TextFormField(
                controller: state.litrosAguaController,
                decoration: const InputDecoration(
                  labelText: 'Água (L) *',
                  prefixIcon: Icon(Icons.opacity),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => v?.isEmpty ?? true ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              ChipField<OrigemAgua>(
                label: 'Origem da Água',
                options: OrigemAgua.values,
                selectedValues: state.origensAgua,
                onChanged: state.setOrigensAgua,
                required: true,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.local_fire_department, color: Colors.deepOrange, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Possível Causa do Incêndio',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<OrigemIncendio>(
                value: state.possivelOrigemIncendio,
                isExpanded: true,
                itemHeight: null,
                decoration: const InputDecoration(
                  labelText: 'Selecione a causa *',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                items: DropdownUtil.buildItems<OrigemIncendio>(
                  OrigemIncendio.values,
                  (e) => e.descricao,
                ),
                selectedItemBuilder: (context) =>
                    DropdownUtil.buildSelectedItems<OrigemIncendio>(
                  OrigemIncendio.values,
                  (e) => e.descricao,
                ),
                onChanged: state.setPossivelOrigemIncendio,
                validator: (v) => v == null ? 'Obrigatório' : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
