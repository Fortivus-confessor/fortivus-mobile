import 'package:fortivus_app/enums/enums.dart';
import 'package:fortivus_app/model/relatorio_maquinario.dart';
import 'package:fortivus_app/services/responder/responder_maquinario_service.dart';
import 'package:fortivus_app/util/map_launcher_util.dart';
import 'package:flutter/material.dart';

class VisualizarCombateMaquinarioPage extends StatefulWidget {
  final int registroId;
  const VisualizarCombateMaquinarioPage({super.key, required this.registroId});

  @override
  State<VisualizarCombateMaquinarioPage> createState() =>
      _VisualizarCombateMaquinarioPageState();
}

class _VisualizarCombateMaquinarioPageState
    extends State<VisualizarCombateMaquinarioPage> {
  final ResponderMaquinarioService _service = ResponderMaquinarioService();
  late final Future<RelatorioMaquinario> _futureRelatorio;

  @override
  void initState() {
    super.initState();
    _futureRelatorio = _service.getResposta<RelatorioMaquinario>(
      despachoId: widget.registroId,
      fromJson: (json) => RelatorioMaquinario.fromJson(json),
      emptyFactory: (id) => RelatorioMaquinario(despachoId: id),
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

  String _resolveEmprego(List<String> tiposEmprego) {
    if (tiposEmprego.isEmpty) return 'Não informado';
    return tiposEmprego.map((name) {
      try {
        return TipoEmpregoMaquinario.values
            .firstWhere((e) => e.name == name)
            .descricao;
      } catch (_) {
        return name;
      }
    }).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RO Maquinário: ${widget.registroId}'),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<RelatorioMaquinario>(
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
            final relatorio = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLocalizacaoCard(context, relatorio),
                  const SizedBox(height: 16),
                  _buildOperacionalCard(relatorio),
                  const SizedBox(height: 16),
                  _buildMaquinarioCard(relatorio),
                  const SizedBox(height: 16),
                  _buildRelatorioCard(relatorio),
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

  Widget _buildLocalizacaoCard(BuildContext context, RelatorioMaquinario r) {
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
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () => MapLauncherUtil.openMapsDialog(
                context, r.areaAtuacaoLat!, r.areaAtuacaoLng!),
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildOperacionalCard(RelatorioMaquinario r) {
    return _buildCardBase(
      title: 'Dados Operacionais',
      icon: Icons.settings,
      iconColor: Colors.blue,
      children: [
        Row(
          children: [
            Expanded(child: _buildInfoTile('Efetividade', _getDescricao(r.efetividadeCombate))),
            Expanded(child: _buildInfoTile('Necessidade de Reforço', r.necessidadeReforco ? 'Sim' : 'Não')),
          ],
        ),
        const SizedBox(height: 12),
        _buildInfoTile('Horário de Chegada', _formatDate(r.dataInicio)),
        const SizedBox(height: 12),
        _buildInfoTile('Tipo de Emprego', _resolveEmprego(r.tiposEmprego)),
      ],
    );
  }

  Widget _buildMaquinarioCard(RelatorioMaquinario r) {
    return _buildCardBase(
      title: 'Dados do Maquinário',
      icon: Icons.agriculture,
      iconColor: Colors.amber[800],
      children: [
        Row(
          children: [
            Expanded(child: _buildInfoTile('Horímetro Inicial', r.horimetroInicial?.toString() ?? '--')),
            Expanded(child: _buildInfoTile('Horímetro Final', r.horimetroFinal?.toString() ?? '--')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildInfoTile('Início Operação', r.horaInicioOperacao ?? '--')),
            Expanded(child: _buildInfoTile('Fim Operação', r.horaFimOperacao ?? '--')),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tempo Total de Operação:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(
                    r.tempoLiquido ?? '--',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[900],
                    ),
                  ),
                ],
              ),
              if (r.comprimentoAceiros != null) ...[
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Comprimento do Aceiro:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(
                      '${r.comprimentoAceiros!.toStringAsFixed(2)} m',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[900],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRelatorioCard(RelatorioMaquinario r) {
    final textoResultado = r.resultadoOcorrencia == ResultadoOcorrencia.OUTRO
        ? (r.outroResultadoDescricao ?? 'Não informado')
        : _getDescricao(r.resultadoOcorrencia);

    return _buildCardBase(
      title: 'Relatório',
      icon: Icons.assignment,
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
                  Icon(icon, color: iconColor ?? Colors.amber[800], size: 20),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
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
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 15, color: Colors.black87)),
      ],
    );
  }
}
