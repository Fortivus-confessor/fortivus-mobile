import 'package:fortivus_app/theme/tactical_theme.dart';
import 'package:flutter/material.dart';
import 'package:fortivus_app/model/despacho.dart' as model;
import '../util/map_launcher_util.dart';

class DetalhesRegistroPage extends StatelessWidget {
  final model.Despacho despacho;

  const DetalhesRegistroPage({super.key, required this.despacho});

  String _formatData(DateTime? dt) {
    if (dt == null) return '--';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final hasCoordinates = despacho.latitude != null && despacho.longitude != null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Despacho: ${despacho.id}'),
        backgroundColor: TacticalTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Informações do Despacho', [
              _buildInfoRow('ID Despacho', despacho.id.toString()),
              _buildInfoRow('Ordem de Serviço', despacho.ordemServicoId.toString()),
              _buildInfoRow('Categoria', despacho.categoriaDescricao),
              _buildInfoRow('Situação', despacho.status.label),
              _buildInfoRow('Data de Início', _formatData(despacho.dataInicio)),
              if (despacho.dataFim != null)
                _buildInfoRow('Data de Encerramento', _formatData(despacho.dataFim)),
              if (despacho.escalaId != null)
                _buildInfoRow('Escala', despacho.escalaId!),
              if (despacho.responsavelId != null)
                _buildInfoRow('Responsável', despacho.responsavelId!),
            ]),

            if (despacho.descricaoTarefa != null && despacho.descricaoTarefa!.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildSection('Descrição da Tarefa', [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(despacho.descricaoTarefa!, style: const TextStyle(height: 1.5)),
                ),
              ]),
            ],

            if (hasCoordinates) ...[
              const SizedBox(height: 20),
              _buildSection('Localização', [
                _buildInfoRow('Latitude', despacho.latitude.toString()),
                _buildInfoRow('Longitude', despacho.longitude.toString()),
                const SizedBox(height: 8),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.map),
                    label: const Text('Abrir no Mapa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () {
                      MapLauncherUtil.openMapsDialog(context, despacho.latitude, despacho.longitude);
                    },
                  ),
                ),
              ]),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: TacticalTheme.primary, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TacticalTheme.primary)),
            const Divider(),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    final displayValue = (value == null || value.trim().isEmpty) ? '--' : value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(displayValue)),
        ],
      ),
    );
  }
}
