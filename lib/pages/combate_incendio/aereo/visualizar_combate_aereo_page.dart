
import 'package:fortivus_app/components/auth_image_widget.dart';
import 'package:fortivus_app/model/combate_incendio_aereo.dart';
import 'package:fortivus_app/services/responder/responder_aereo_service.dart';  
import 'package:fortivus_app/util/map_launcher_util.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class VisualizarCombateAereoPage extends StatefulWidget {
  final int registroId;

  const VisualizarCombateAereoPage({super.key, required this.registroId});

  @override
  State<VisualizarCombateAereoPage> createState() => _VisualizarCombateAereoPageState();
}

class _VisualizarCombateAereoPageState extends State<VisualizarCombateAereoPage> {
  final ResponderAereoService _service = ResponderAereoService();  
  late final Future<CombateIncendioAereo> _futureCombate;

  @override
  void initState() {
    super.initState();
    // ✅ REMOVIDO: categoria (não é parâmetro)
    _futureCombate = _service.getResposta<CombateIncendioAereo>(
      registroId: widget.registroId,
      fromJson: (json) => CombateIncendioAereo.fromJson(json),
      emptyFactory: (id) => CombateIncendioAereo(id: id),
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
    return '${date.day.toString().padLeft(2,'0')}/${date.month.toString().padLeft(2,'0')}/${date.year} ${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}';
  }

  Widget _buildImagemAdaptavel(String path, {BoxFit fit = BoxFit.cover, double? width, double? height}) {
    bool isLocal = path.startsWith('/') || path.startsWith('file://');
    if (isLocal) {
      return Image.file(
        File(path),
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    } else {
      return AuthImageWidget(
        fileName: path,
        fit: fit,
        width: width,
        height: height,
      );
    }
  }

  void _abrirImagemFullScreen(BuildContext context, String nomeArquivo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text("Visualização", style: TextStyle(color: Colors.white)),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: _buildImagemAdaptavel(nomeArquivo, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RO Aéreo: ${widget.registroId}'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<CombateIncendioAereo>(
        future: _futureCombate,
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
            final combate = snapshot.data!;
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dados de Voo
                  _buildDadosVooCard(combate),
                  const SizedBox(height: 16),

                  // Localização
                  _buildLocalizacaoCard(context, combate),
                  const SizedBox(height: 16),

                  // Recursos e Emprego
                  _buildRecursosCard(combate),
                  const SizedBox(height: 16),

                  // Operacional Geral
                  _buildOperacionalCard(combate),
                  const SizedBox(height: 16),

                  // Relatório e Resultados
                  _buildRelatorioCard(combate),
                  const SizedBox(height: 16),

                  // Anexos gerais
                  _buildGaleriaCard(context, combate.arquivosLocais),
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

  Widget _buildDadosVooCard(CombateIncendioAereo combate) {
    return _buildCardBase(
      title: 'Dados de Voo',
      icon: Icons.airplanemode_active,
      children: [
        Row(
          children: [
            Expanded(child: _buildInfoTile('Horímetro Inicial', combate.horimetroInicial ?? '--')),
            Expanded(child: _buildInfoTile('Horímetro Final', combate.horimetroFinal ?? '--')),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 8),
        _buildInfoTile('Tempo da Operação', combate.tempoOperacaoMinutos != null ? '${combate.tempoOperacaoMinutos! ~/ 60}h ${combate.tempoOperacaoMinutos! % 60}m' : '--'),
      ],
    );
  }

  Widget _buildLocalizacaoCard(BuildContext context, CombateIncendioAereo combate) {
    bool temCoordenadas = combate.latitudeAreaAtuacao != null && combate.longitudeAreaAtuacao != null;
    
    String formatCoord(double? valor) {
      if (valor == null) return '--';
      return valor.toStringAsFixed(6);
    }

    return _buildCardBase(
      title: 'Localização',
      icon: Icons.location_on,
      iconColor: Colors.red,
      children: [
        Row(
          children: [
            Expanded(child: _buildInfoTile('Latitude', formatCoord(combate.latitudeAreaAtuacao))),
            Expanded(child: _buildInfoTile('Longitude', formatCoord(combate.longitudeAreaAtuacao))),
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
                foregroundColor: Colors.white
              ),
              onPressed: () {
                MapLauncherUtil.openMapsDialog(
                  context, 
                  combate.latitudeAreaAtuacao!, 
                  combate.longitudeAreaAtuacao!
                );
              },
            ),
          )
        ]
      ],
    );
  }

  Widget _buildRecursosCard(CombateIncendioAereo combate) {
    return _buildCardBase(
      title: 'Recursos e Emprego',
      icon: Icons.water_drop,
      children: [
        _buildInfoTile('Tipo de Emprego', _getDescricao(combate.tipoEmprego)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildInfoTile('Qtd. Alijamentos', combate.quantidadeAlijamento?.toString() ?? '--')),
            Expanded(child: _buildInfoTile('Litros de Água', combate.quantidadeLitrosAgua != null ? '${combate.quantidadeLitrosAgua} L' : '--')),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(),
        _buildStringListTile('Origem da Água', combate.origemAgua),
      ],
    );
  }

  Widget _buildOperacionalCard(CombateIncendioAereo combate) {
    return _buildCardBase(
      title: 'Operacional',
      icon: Icons.settings,
      iconColor: Colors.blue,
      children: [
        Row(
          children: [
            Expanded(child: _buildInfoTile('Efetividade', _getDescricao(combate.efetividadeCombate))),
            Expanded(child: _buildInfoTile('Reforço', _getDescricao(combate.reforco))),
          ],
        ),
        const SizedBox(height: 12),
        _buildInfoTile('Chegada no Local', _formatDate(combate.horarioChegada)),
      ],
    );
  }

  Widget _buildRelatorioCard(CombateIncendioAereo combate) {
    return _buildCardBase(
      title: 'Relatório',
      icon: Icons.description,
      iconColor: Colors.green[700],
      children: [
        _buildInfoTile('Descrição da Operação', combate.historicoDescritivo ?? 'Não informado'),
        const SizedBox(height: 12),
        _buildInfoTile('Resultado do Dia', combate.resultadoOcorrencia ?? 'Não informado'),
      ],
    );
  }

  Widget _buildGaleriaCard(BuildContext context, List<String> arquivos) {
    if (arquivos.isEmpty) return const SizedBox.shrink();

    return _buildCardBase(
      title: 'Anexos',
      icon: Icons.attach_file,
      children: [
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: arquivos.length,
            itemBuilder: (context, index) {
              final nomeArquivo = arquivos[index];
              final isImage = nomeArquivo.toLowerCase().endsWith('.jpg') || 
                              nomeArquivo.toLowerCase().endsWith('.png') ||
                              nomeArquivo.toLowerCase().endsWith('.jpeg');

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    if (isImage) _abrirImagemFullScreen(context, nomeArquivo);
                  },
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: isImage
                        ? _buildImagemAdaptavel(nomeArquivo, width: 120, height: 120)
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.insert_drive_file, color: Colors.grey, size: 30),
                              SizedBox(height: 4),
                              Text("Arquivo", style: TextStyle(fontSize: 10))
                            ],
                          ),
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value.isEmpty ? '--' : value, style: const TextStyle(fontSize: 15, color: Colors.black87)),
      ],
    );
  }

  Widget _buildStringListTile(String title, List<String>? items) {
    if (items == null || items.isEmpty) {
       return _buildInfoTile(title, '--');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items.map((item) => Chip(
            label: Text(item, style: const TextStyle(fontSize: 12)),
            backgroundColor: Colors.grey[100],
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          )).toList(),
        )
      ],
    );
  }
}