
import 'dart:io';
import 'package:fortivus_app/components/auth_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:fortivus_app/model/ronda.dart';
import 'package:fortivus_app/services/responder/responder_ronda_service.dart'; 
import 'package:fortivus_app/util/map_launcher_util.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';

class VisualizarRondaPage extends StatefulWidget {
  final int registroId;

  const VisualizarRondaPage({super.key, required this.registroId});

  @override
  State<VisualizarRondaPage> createState() => _VisualizarRondaPageState();
}

class _VisualizarRondaPageState extends State<VisualizarRondaPage> {
  final ResponderRondaService _service = ResponderRondaService();  
  late final Future<Ronda> _futureRonda;

  @override
  void initState() {
    super.initState();
    // ✅ REMOVIDO: categoria (não é parâmetro)
    _futureRonda = _service.getResposta<Ronda>(
      registroId: widget.registroId,
      fromJson: (json) {
        // Garantia de mapeamento de arquivos offline/online
        if (json['arquivosLocais'] == null && json['arquivos'] != null) {
          json['arquivosLocais'] = json['arquivos'];
        }
        return Ronda.fromJson(json);
      },
      emptyFactory: (id) => Ronda(id: id),
    );
  }

  // --- Helpers de Formatação ---
  String _getDescricao(Enum? item) {
    if (item == null) return 'Não informado';
    try {
      return (item as dynamic).descricao;
    } catch (_) {
      return item.name.replaceAll('_', ' ');
    }
  }

  // --- Helpers de Imagem ---
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
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: TacticalTheme.primary,
          primary: TacticalTheme.primary,
          surface: Colors.white,
        ),
      ),
      child: Scaffold(
        backgroundColor: TacticalTheme.background,
        appBar: AppBar(
          title: Text('RO Ronda: ${widget.registroId}', style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: TacticalTheme.primary,
          foregroundColor: Colors.white,
        ),
        body: FutureBuilder<Ronda>(
          future: _futureRonda,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: TacticalTheme.primary));
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
              final ronda = snapshot.data!;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. LOCALIZAÇÃO
                    _buildLocalizacaoCard(context, ronda),
                    
                    // 2. DADOS DA ATIVIDADE
                    _buildAtividadeCard(ronda),
                    
                    // 3. ANEXOS / GALERIA
                    _buildGaleriaCard(context, ronda),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              );
            }
            return const Center(child: Text('Nenhum dado encontrado.'));
          },
        ),
      ),
    );
  }

  // --- CARDS DE SESSÃO ---

  Widget _buildLocalizacaoCard(BuildContext context, Ronda ronda) {
    bool temCoordenadas = ronda.latitudeAreaAtuacao != null && ronda.longitudeAreaAtuacao != null;
    String formatCoord(double? valor) {
      if (valor == null) return '--';
      return valor.toStringAsFixed(6);
    }

    return _buildTacticalCardBase(
      title: 'Localização',
      icon: Icons.location_on,
      children: [
        Row(
          children: [
            Expanded(child: _buildInfoTile('Latitude', formatCoord(ronda.latitudeAreaAtuacao))),
            Expanded(child: _buildInfoTile('Longitude', formatCoord(ronda.longitudeAreaAtuacao))),
          ],
        ),
        if (temCoordenadas) ...[
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.gps_fixed),
              label: const Text('Ver no Mapa Externo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TacticalTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
              ),
              onPressed: () {
                MapLauncherUtil.openMapsDialog(
                  context,
                  ronda.latitudeAreaAtuacao!,
                  ronda.longitudeAreaAtuacao!,
                );
              },
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildAtividadeCard(Ronda ronda) {
    return _buildTacticalCardBase(
      title: 'Atividade Realizada',
      icon: Icons.security,
      children: [
        _buildEnumListTile('Ações Realizadas', ronda.acaoRonda ?? []),
        if (ronda.acaoRondaOutro != null && ronda.acaoRondaOutro!.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildInfoTile('Descrição (Outra Ação)', ronda.acaoRondaOutro!),
        ],
        const Divider(height: 24),
        _buildEnumListTile('Assuntos Abordados', ronda.assuntosAbordados ?? []),
        const Divider(height: 24),
        _buildInfoTile(
          'Pessoas Atingidas / Orientadas', 
          ronda.quantidadePessoasAtingidas?.toString() ?? '0'
        ),
      ],
    );
  }

  Widget _buildGaleriaCard(BuildContext context, Ronda ronda) {
    List<String> arquivosUrls = ronda.arquivosLocais;

    if (arquivosUrls.isEmpty) return const SizedBox.shrink();

    return _buildTacticalCardBase(
      title: 'Anexos',
      icon: Icons.camera_alt,
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

  // --- WIDGETS BASE (Estilizados com TacticalTheme) ---

  Widget _buildTacticalCardBase({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: TacticalTheme.cardFill,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cabeçalho escuro do Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: TacticalTheme.primary,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Text(
                  title.toUpperCase(), 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)
                ),
              ],
            ),
          ),
          // Corpo do Card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)
        ),
        const SizedBox(height: 4),
        Text(
          value, 
          style: const TextStyle(fontSize: 15, color: Colors.black87)
        ),
      ],
    );
  }

  Widget _buildEnumListTile(String title, List<Enum> items) {
    if (items.isEmpty) {
       return Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
           const SizedBox(height: 4),
           const Text('--', style: TextStyle(fontSize: 14)),
         ]
       );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) => Chip(
            label: Text(
              _getDescricao(item), 
              style: const TextStyle(fontSize: 12, color: TacticalTheme.primary, fontWeight: FontWeight.bold)
            ),
            backgroundColor: TacticalTheme.primary.withValues(alpha: 0.08),
            side: BorderSide(color: TacticalTheme.primary.withValues(alpha: 0.2)),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          )).toList(),
        )
      ]
    );
  }
}