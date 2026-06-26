import 'package:fortivus_app/enums/enums.dart';
import 'package:fortivus_app/model/relatorio_terrestre.dart';
import 'package:fortivus_app/model/propriedade_apoio.dart';
import 'package:fortivus_app/services/responder/responder_terrestre_service.dart';
import 'package:fortivus_app/util/map_launcher_util.dart';
import 'package:flutter/material.dart';

class VisualizarCombateTerrestrePage extends StatefulWidget {
  final int registroId;
  const VisualizarCombateTerrestrePage({super.key, required this.registroId});

  @override
  State<VisualizarCombateTerrestrePage> createState() =>
      _VisualizarCombateTerrestrePageState();
}

class _VisualizarCombateTerrestrePageState
    extends State<VisualizarCombateTerrestrePage> {
  final ResponderTerrestreService _service = ResponderTerrestreService();
  late final Future<RelatorioTerrestre> _futureRelatorio;

  @override
  void initState() {
    super.initState();
    _futureRelatorio = _service.getResposta<RelatorioTerrestre>(
      despachoId: widget.registroId,
      fromJson: (json) => RelatorioTerrestre.fromJson(json),
      emptyFactory: (id) => RelatorioTerrestre(despachoId: id),
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
    if (date == null) return 'Não informado';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RO Terrestre: ${widget.registroId}'),
        backgroundColor: Colors.brown[800],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<RelatorioTerrestre>(
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
                  _buildLocalizacaoCard(context, r),
                  const SizedBox(height: 16),
                  _buildOperacionalCard(r),
                  const SizedBox(height: 16),
                  _buildRecursosCard(r),
                  const SizedBox(height: 16),
                  _buildPropriedadesCard(r.propriedades),
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

  Widget _buildLocalizacaoCard(BuildContext context, RelatorioTerrestre r) {
    final temCoordenadas = r.areaAtuacaoLat != null && r.areaAtuacaoLng != null;
    String fmt(double? v) => v != null ? v.toStringAsFixed(6) : '--';
    return _buildCardBase(
      title: 'Localização',
      icon: Icons.location_on,
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
              onPressed: () => MapLauncherUtil.openMapsDialog(
                  context, r.areaAtuacaoLat!, r.areaAtuacaoLng!),
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildOperacionalCard(RelatorioTerrestre r) {
    return _buildCardBase(
      title: 'Dados Operacionais',
      icon: Icons.settings,
      children: [
        Row(
          children: [
            Expanded(child: _buildInfoTile('Efetividade', _getDescricao(r.efetividadeCombate))),
            Expanded(child: _buildInfoTile('Necessidade de Reforço', r.necessidadeReforco ? 'Sim' : 'Não')),
          ],
        ),
        const SizedBox(height: 12),
        _buildInfoTile('Horário Chegada', _formatDate(r.dataInicio)),
      ],
    );
  }

  Widget _buildRecursosCard(RelatorioTerrestre r) {
    return _buildCardBase(
      title: 'Recursos e Ações',
      icon: Icons.construction,
      children: [
        _buildEnumListTile('Ações Realizadas', r.acoesRealizadas),
        _buildEnumListTile('Apoio de Órgãos', r.orgaosApoio),
        if (r.outrosOrgaosDescricao != null && r.outrosOrgaosDescricao!.isNotEmpty)
          _buildInfoTile('Outro Órgão', r.outrosOrgaosDescricao!),
        const Divider(),
        _buildEnumListTile('Origem da Água', r.origensAgua),
        if (r.volumeAguaLitros != null)
          _buildInfoTile('Qtd. Água', '${r.volumeAguaLitros} Litros'),
      ],
    );
  }

  Widget _buildPropriedadesCard(List<PropriedadeApoio> propriedades) {
    if (propriedades.isEmpty) {
      return _buildCardBase(
        title: 'Propriedades Rurais',
        icon: Icons.agriculture,
        children: [
          const Text(
            'Nenhum registro de apoio/recusa.',
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          )
        ],
      );
    }
    return _buildCardBase(
      title: 'Propriedades Rurais (${propriedades.length})',
      icon: Icons.agriculture,
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: propriedades.length,
          separatorBuilder: (ctx, index) => const SizedBox(height: 10),
          itemBuilder: (ctx, index) {
            final prop = propriedades[index];
            final isApoio = prop.tipoRegistro == TipoRegistro.APOIO;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isApoio
                      ? Colors.green.withValues(alpha: 0.5)
                      : Colors.red.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isApoio ? Icons.check_circle : Icons.cancel,
                        color: isApoio ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          prop.nomePropriedade ?? 'Sem nome',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isApoio ? Colors.green[800] : Colors.red[800],
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  _buildInfoRow('Responsável', prop.responsavel),
                  _buildInfoRow('Telefone', prop.telefone),
                ],
              ),
            );
          },
        )
      ],
    );
  }

  Widget _buildRelatorioCard(RelatorioTerrestre r) {
    final textoResultado = r.resultadoOcorrencia == ResultadoOcorrencia.OUTRO
        ? (r.outroResultadoDescricao ?? 'Não informado')
        : _getDescricao(r.resultadoOcorrencia);

    return _buildCardBase(
      title: 'Relatório',
      icon: Icons.assignment,
      children: [
        _buildInfoTile('Causa Provável', _getDescricao(r.possivelOrigemIncendio)),
        const Divider(height: 24),
        _buildInfoTile('Descrição da Operação', r.historicoDescritivo ?? 'Não informado'),
        const SizedBox(height: 12),
        _buildInfoTile('Resultado da Ocorrência', textoResultado),
      ],
    );
  }

  Widget _buildCardBase({
    required String title,
    required List<Widget> children,
    IconData? icon,
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
                if (icon != null) ...[
                  Icon(icon, color: iconColor ?? Colors.brown[800], size: 20),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
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

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text('$label:',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
              child: Text(value ?? '-', style: const TextStyle(fontSize: 13))),
        ],
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
        Text(value, style: const TextStyle(fontSize: 15, color: Colors.black87)),
      ],
    );
  }

  Widget _buildEnumListTile(String title, List<Enum> items) {
    if (items.isEmpty) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
        const Text('--', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 8),
      ]);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: items
                .map((item) => Chip(
                      label: Text(_getDescricao(item),
                          style: const TextStyle(fontSize: 12)),
                      backgroundColor: Colors.grey[100],
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ))
                .toList(),
          )
        ],
      ),
    );
  }
}
