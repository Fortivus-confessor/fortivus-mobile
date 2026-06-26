import 'package:fortivus_app/enums/enums.dart';
import 'package:fortivus_app/model/relatorio_aereo.dart';
import 'package:fortivus_app/services/responder/responder_aereo_service.dart';
import 'package:fortivus_app/util/map_launcher_util.dart';
import 'package:flutter/material.dart';

class VisualizarCombateAereoPage extends StatefulWidget {
  final int registroId;

  const VisualizarCombateAereoPage({super.key, required this.registroId});

  @override
  State<VisualizarCombateAereoPage> createState() =>
      _VisualizarCombateAereoPageState();
}

class _VisualizarCombateAereoPageState
    extends State<VisualizarCombateAereoPage> {
  final ResponderAereoService _service = ResponderAereoService();
  late final Future<RelatorioAereo> _futureRelatorio;

  @override
  void initState() {
    super.initState();
    _futureRelatorio = _service.getResposta<RelatorioAereo>(
      despachoId: widget.registroId,
      fromJson: (json) => RelatorioAereo.fromJson(json),
      emptyFactory: (id) => RelatorioAereo(despachoId: id),
    );
  }

  String _getDescricao(Enum? item) {
    if (item == null) return 'Não informado';
    try {
      return (item as dynamic).descricao;
    } catch (_) {
      return item.name;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _resolveEmprego(List<String> tiposEmprego) {
    if (tiposEmprego.isEmpty) return 'Não informado';
    return tiposEmprego.map((name) {
      try {
        return TipoEmpregoAereo.values
            .firstWhere((e) => e.name == name)
            .descricao;
      } catch (_) {
        return name;
      }
    }).join(', ');
  }

  String _resolveOrigensAgua(List<String> origens) {
    if (origens.isEmpty) return '--';
    return origens.map((name) {
      try {
        return OrigemAgua.values.firstWhere((e) => e.name == name).descricao;
      } catch (_) {
        return name;
      }
    }).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RO Aéreo: ${widget.registroId}'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<RelatorioAereo>(
        future: _futureRelatorio,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Erro ao carregar dados:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }
          if (snapshot.hasData) {
            final r = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDadosVooCard(r),
                  const SizedBox(height: 16),
                  _buildLocalizacaoCard(context, r),
                  const SizedBox(height: 16),
                  _buildRecursosCard(r),
                  const SizedBox(height: 16),
                  _buildOperacionalCard(r),
                  const SizedBox(height: 16),
                  _buildRelatorioCard(r),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }
          return const Center(child: Text('Nenhum dado encontrado.'));
        },
      ),
    );
  }

  Widget _buildDadosVooCard(RelatorioAereo r) {
    return _buildCardBase(
      title: 'Dados de Voo',
      icon: Icons.airplanemode_active,
      children: [
        Row(
          children: [
            Expanded(child: _buildInfoTile('Horímetro Inicial', r.horimetroInicial?.toString() ?? '--')),
            Expanded(child: _buildInfoTile('Horímetro Final', r.horimetroFinal?.toString() ?? '--')),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 8),
        _buildInfoTile('Tempo de Operação', r.horasLiquidas ?? '--'),
        const SizedBox(height: 8),
        _buildInfoTile('Horário de Chegada', _formatDate(r.dataInicio)),
      ],
    );
  }

  Widget _buildLocalizacaoCard(BuildContext context, RelatorioAereo r) {
    final temCoordenadas = r.areaAtuacaoLat != null && r.areaAtuacaoLng != null;
    String fmt(double? v) => v != null ? v.toStringAsFixed(6) : '--';

    return _buildCardBase(
      title: 'Localização',
      icon: Icons.location_on,
      iconColor: Colors.red,
      children: [
        Row(
          children: [
            Expanded(child: _buildInfoTile('Latitude', fmt(r.areaAtuacaoLat))),
            Expanded(child: _buildInfoTile('Longitude', fmt(r.areaAtuacaoLng))),
          ],
        ),
        if (temCoordenadas) ...[
          const SizedBox(height: 12),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.map),
              label: const Text('Ver no Mapa'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () =>
                  MapLauncherUtil.openMapsDialog(context, r.areaAtuacaoLat!, r.areaAtuacaoLng!),
            ),
          )
        ]
      ],
    );
  }

  Widget _buildRecursosCard(RelatorioAereo r) {
    return _buildCardBase(
      title: 'Recursos e Emprego',
      icon: Icons.water_drop,
      children: [
        _buildInfoTile('Tipo de Emprego', _resolveEmprego(r.tiposEmprego)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildInfoTile('Qtd. Lançamentos', r.qtdeLancamentos?.toString() ?? '--')),
            Expanded(child: _buildInfoTile('Litros de Água', r.volumeAguaLitros != null ? '${r.volumeAguaLitros} L' : '--')),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(),
        _buildInfoTile('Origem da Água', _resolveOrigensAgua(r.origensAgua)),
      ],
    );
  }

  Widget _buildOperacionalCard(RelatorioAereo r) {
    return _buildCardBase(
      title: 'Operacional',
      icon: Icons.settings,
      iconColor: Colors.blue,
      children: [
        Row(
          children: [
            Expanded(child: _buildInfoTile('Efetividade', _getDescricao(r.efetividadeCombate))),
            Expanded(child: _buildInfoTile('Necessidade de Reforço', r.necessidadeReforco ? 'Sim' : 'Não')),
          ],
        ),
      ],
    );
  }

  Widget _buildRelatorioCard(RelatorioAereo r) {
    final textoResultado = r.resultadoOcorrencia == ResultadoOcorrencia.OUTRO
        ? (r.outroResultadoDescricao ?? 'Não informado')
        : _getDescricao(r.resultadoOcorrencia);

    return _buildCardBase(
      title: 'Relatório',
      icon: Icons.description,
      iconColor: Colors.green[700],
      children: [
        _buildInfoTile('Descrição da Operação', r.historicoDescritivo ?? 'Não informado'),
        const SizedBox(height: 12),
        _buildInfoTile('Resultado da Ocorrência', textoResultado),
      ],
    );
  }

  Widget _buildCardBase({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color? iconColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor ?? Colors.blue[800], size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value.isEmpty ? '--' : value,
            style: const TextStyle(fontSize: 15, color: Colors.black87)),
      ],
    );
  }
}
