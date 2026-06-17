
import 'dart:io';
import 'package:fortivus_app/components/auth_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:fortivus_app/model/conscientizacao_educacao_ambiental.dart';
import 'package:fortivus_app/services/responder/responder_conscientizacao_service.dart';  
import 'package:fortivus_app/util/map_launcher_util.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';

class VisualizarConscientizacaoPage extends StatefulWidget {
  final int registroId;

  const VisualizarConscientizacaoPage({super.key, required this.registroId});

  @override
  State<VisualizarConscientizacaoPage> createState() => _VisualizarConscientizacaoPageState();
}

class _VisualizarConscientizacaoPageState extends State<VisualizarConscientizacaoPage> {
  final ResponderConscientizacaoService _service = ResponderConscientizacaoService();  
  late final Future<ConscientizacaoEducacaoAmbiental> _futureConscientizacao;

  @override
  void initState() {
    super.initState();
    // ✅ REMOVIDO: categoria (não é parâmetro)
    _futureConscientizacao = _service.getResposta<ConscientizacaoEducacaoAmbiental>(
      registroId: widget.registroId,
      fromJson: (json) {
        if (json['arquivosLocais'] == null && json['arquivos'] != null) {
          json['arquivosLocais'] = json['arquivos'];
        }
        return ConscientizacaoEducacaoAmbiental.fromJson(json);
      },
      emptyFactory: (id) => ConscientizacaoEducacaoAmbiental(id: id),
    );
  }

  String _getDescricao(Enum? item) {
    if (item == null) return 'Não informado';
    try {
      return (item as dynamic).descricao;
    } catch (_) {
      return item.name.replaceAll('_', ' ');
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '--';
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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
        title: Text('RO Conscientização: ${widget.registroId}'),
        backgroundColor: TacticalTheme.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: TacticalTheme.background,
      body: FutureBuilder<ConscientizacaoEducacaoAmbiental>(
        future: _futureConscientizacao,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: TacticalTheme.primary),
            );
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
            final conscientizacao = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ 1. ATIVIDADE NO DESPACHO (Status)
                  _buildStatusAtividadeCard(conscientizacao),
                  const SizedBox(height: 16),

                  // ✅ 2. LOCALIZAÇÃO
                  _buildLocalizacaoCard(context, conscientizacao),
                  const SizedBox(height: 16),

                  // ✅ 3. ATIVIDADE REALIZADA
                  _buildAtividadeCard(conscientizacao),
                  const SizedBox(height: 16),

                  // ✅ 4. PERÍODO DA ATIVIDADE
                  _buildPeriodoCard(conscientizacao),
                  const SizedBox(height: 16),

                  // ✅ 5. PÚBLICO ATINGIDO
                  _buildPublicoCard(conscientizacao),
                  const SizedBox(height: 16),

                  // ✅ 6. HISTÓRICO/DESCRIÇÃO
                  _buildHistoricoCard(conscientizacao),
                  const SizedBox(height: 16),

                  // ✅ 7. ANEXOS
                  _buildGaleriaCard(context, conscientizacao),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }
          return const Center(child: Text('Nenhum dado encontrado.'));
        },
      ),
    );
  }

  // ✅ NOVO: Status da Atividade (Sim/Não no despacho)
  Widget _buildStatusAtividadeCard(ConscientizacaoEducacaoAmbiental conscientizacao) {
    final noDespacho = conscientizacao.atividadeNoLocal == true;
    final statusColor = noDespacho ? Colors.green : Colors.orange;
    final statusIcon = noDespacho ? Icons.check_circle : Icons.edit;
    final statusText = noDespacho ? 'Atividade no Local do Despacho' : 'Atividade Modificada';

    return _buildCardBase(
      title: 'Status da Atividade',
      icon: Icons.info,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: statusColor, width: 1),
          ),
          child: Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocalizacaoCard(BuildContext context, ConscientizacaoEducacaoAmbiental conscientizacao) {
    bool temCoordenadas = conscientizacao.latitudeAreaAtuacao != null &&
        conscientizacao.longitudeAreaAtuacao != null;

    String formatCoord(double? valor) {
      if (valor == null) return '--';
      return valor.toStringAsFixed(6);
    }

    return _buildCardBase(
      title: 'Localização',
      icon: Icons.location_on,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoTile('Latitude', formatCoord(conscientizacao.latitudeAreaAtuacao)),
            ),
            Expanded(
              child: _buildInfoTile('Longitude', formatCoord(conscientizacao.longitudeAreaAtuacao)),
            ),
          ],
        ),
        if (temCoordenadas) ...[
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.map),
              label: const Text('Ver no Mapa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                MapLauncherUtil.openMapsDialog(
                  context,
                  conscientizacao.latitudeAreaAtuacao!,
                  conscientizacao.longitudeAreaAtuacao!,
                );
              },
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildAtividadeCard(ConscientizacaoEducacaoAmbiental conscientizacao) {
    return _buildCardBase(
      title: 'Atividade Realizada',
      icon: Icons.school,
      children: [
        _buildInfoTile(
          'Tipo de Ação',
          _getDescricao(conscientizacao.acaoConscientizacao),
        ),
        if (conscientizacao.acaoOutro != null && conscientizacao.acaoOutro!.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          _buildInfoTile('Descrição (Outra Ação)', conscientizacao.acaoOutro!),
        ],
      ],
    );
  }

  Widget _buildPeriodoCard(ConscientizacaoEducacaoAmbiental conscientizacao) {
    return _buildCardBase(
      title: 'Período da Atividade',
      icon: Icons.schedule,
      children: [
        _buildInfoTile(
          'Deslocamento Inicial',
          _formatDateTime(conscientizacao.deslocamentoInicial),
        ),
        const SizedBox(height: 12),
        _buildInfoTile(
          'Deslocamento Final',
          _formatDateTime(conscientizacao.deslocamentoFinal),
        ),
      ],
    );
  }

  Widget _buildPublicoCard(ConscientizacaoEducacaoAmbiental conscientizacao) {
    return _buildCardBase(
      title: 'Público',
      icon: Icons.people,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoTile(
                'Pessoas Atingidas',
                conscientizacao.publicoEstimado?.toString() ?? '--',
              ),
            ),
            if (conscientizacao.publicoEstimado != null &&
                conscientizacao.publicoEstimado! > 0) ...[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Center(
                    child: Text(
                      '${conscientizacao.publicoEstimado} pessoas',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ]
          ],
        ),
      ],
    );
  }

  Widget _buildHistoricoCard(ConscientizacaoEducacaoAmbiental conscientizacao) {
    if (conscientizacao.historico == null || conscientizacao.historico!.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildCardBase(
      title: 'Histórico da Atividade',
      icon: Icons.description,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: _buildInfoTile(
            'Descrição',
            conscientizacao.historico ?? 'Não informado',
          ),
        ),
      ],
    );
  }

  Widget _buildGaleriaCard(BuildContext context, ConscientizacaoEducacaoAmbiental conscientizacao) {
    List<String> arquivosUrls = [];
    try {
      arquivosUrls = conscientizacao.arquivosLocais;
    } catch (_) {
      debugPrint('Erro ao acessar arquivos');
    }

    if (arquivosUrls.isEmpty) return const SizedBox.shrink();

    return _buildCardBase(
      title: 'Anexos',
      icon: Icons.attach_file,
      children: [
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: arquivosUrls.length,
            itemBuilder: (context, index) {
              final nomeArquivo = arquivosUrls[index];
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
                          ? _buildImagemAdaptavel(nomeArquivo)
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

  // ✅ CARD BASE
  Widget _buildCardBase({
    required String title,
    required IconData icon,
    required List<Widget> children,
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
                Icon(icon, color: TacticalTheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
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

  // ✅ INFO TILE
  Widget _buildInfoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value.isEmpty ? '--' : value,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        ),
      ],
    );
  }
}