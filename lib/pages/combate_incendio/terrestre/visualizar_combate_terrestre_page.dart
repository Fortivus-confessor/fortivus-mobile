import 'package:fortivus_app/components/auth_image_widget.dart';
import 'package:fortivus_app/enums/enums.dart';
import 'package:fortivus_app/model/combate_incendio_terrestre.dart';
import 'package:fortivus_app/model/propriedade_apoio.dart';
import 'package:fortivus_app/services/responder/responder_terrestre_service.dart'; 
import 'package:fortivus_app/util/map_launcher_util.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:fortivus_app/enums/tipo_resultado_incendio_terrestre.dart';

class VisualizarCombateTerrestrePage extends StatefulWidget {
  final int registroId;
  const VisualizarCombateTerrestrePage({super.key, required this.registroId});
  
  @override
  State<VisualizarCombateTerrestrePage> createState() => _VisualizarCombateTerrestrePageState();
}

class _VisualizarCombateTerrestrePageState extends State<VisualizarCombateTerrestrePage> {
  final ResponderTerrestreService _service = ResponderTerrestreService();
  late final Future<CombateIncendioTerrestre> _futureCombate;

  @override
  void initState() {
    super.initState();
    // ✅ REMOVER: categoria (não é parâmetro)
    _futureCombate = _service.getResposta<CombateIncendioTerrestre>(
      registroId: widget.registroId,
      fromJson: (json) {
        if (json['propriedadesApoio'] == null && json['propriedades'] != null) {
          json['propriedadesApoio'] = json['propriedades'];
        }
        return CombateIncendioTerrestre.fromJson(json);
      },
      emptyFactory: (id) => CombateIncendioTerrestre(id: id),
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
        title: Text('RO Terrestre: ${widget.registroId}'),
        backgroundColor: Colors.brown[800],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<CombateIncendioTerrestre>(
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
                  // 1. LOCALIZAÇÃO
                  _buildLocalizacaoCard(context, combate),
                  const SizedBox(height: 16),

                  // 2. DADOS OPERACIONAIS
                  _buildOperacionalCard(combate),
                  const SizedBox(height: 16),

                  // 3. RECURSOS E AÇÕES
                  _buildRecursosCard(combate),
                  const SizedBox(height: 16),

                  // 4. PROPRIEDADES RURAIS
                  _buildPropriedadesCard(combate.propriedadesApoio),
                  const SizedBox(height: 16),

                  // 5. ✅ IMAGEM DA ORIGEM DO INCÊNDIO (SEPARADA)
                  if (combate.imagemOrigemIncendio != null && combate.imagemOrigemIncendio!.isNotEmpty)
                    _buildImagemOrigemCard(context, combate.imagemOrigemIncendio!),
                  
                  if (combate.imagemOrigemIncendio != null && combate.imagemOrigemIncendio!.isNotEmpty)
                    const SizedBox(height: 16),

                  // 6. RELATÓRIO (sem a imagem)
                  _buildRelatorioCard(combate),
                  const SizedBox(height: 16),

                  // 7. ANEXOS GERAIS (excluindo a imagem da origem)
                  _buildGaleriaCard(context, combate),
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

  Widget _buildImagemOrigemCard(BuildContext context, String imagemPath) {
    return _buildCardBase(
      title: 'Imagem da Origem do Incêndio',
      icon: Icons.photo_camera,
      iconColor: Colors.orange,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Evidência fotográfica da possível origem do incêndio',
                  style: TextStyle(fontSize: 12, color: Colors.black87, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _abrirImagemFullScreen(context, imagemPath),
          child: Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.orange.shade300, width: 2),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildImagemAdaptavel(
                imagemPath,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Toque para ampliar',
            style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  Widget _buildLocalizacaoCard(BuildContext context, CombateIncendioTerrestre combate) {
    bool temCoordenadas = combate.latitudeAreaAtuacao != null && combate.longitudeAreaAtuacao != null;
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
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                MapLauncherUtil.openMapsDialog(
                  context,
                  combate.latitudeAreaAtuacao!,
                  combate.longitudeAreaAtuacao!,
                );
              },
            ),
          ),
        ]
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
            final isApoio = prop.tipoInteracao == TipoInteracaoPropriedade.APOIO;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isApoio ? Colors.green.withValues(alpha: 0.5) : Colors.red.withValues(alpha: 0.5),
                  width: 1.5
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
                        size: 20
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          prop.nomePropriedade ?? 'Sem nome',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isApoio ? Colors.green[800] : Colors.red[800],
                            fontSize: 15
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  _buildInfoRow('Responsável', prop.nomeProprietario),
                  _buildInfoRow('Telefone', prop.contato),
                  if (isApoio) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Recursos Disponibilizados:",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green)
                          ),
                          const SizedBox(height: 4),
                          if (prop.quantidadeMaquinario != null && prop.quantidadeMaquinario! > 0)
                            Text("• Maquinário: ${prop.quantidadeMaquinario}", style: const TextStyle(fontSize: 12)),
                          if (prop.quantidadeMaoObra != null && prop.quantidadeMaoObra! > 0)
                            Text("• Mão de Obra: ${prop.quantidadeMaoObra}", style: const TextStyle(fontSize: 12)),
                          if (prop.apoioOutro != null && prop.apoioOutro!.isNotEmpty)
                            Text("• Outro: ${prop.apoioOutro}", style: const TextStyle(fontSize: 12)),
                          if ((prop.quantidadeMaquinario == null || prop.quantidadeMaquinario == 0) &&
                              (prop.quantidadeMaoObra == null || prop.quantidadeMaoObra == 0) &&
                              (prop.apoioOutro == null || prop.apoioOutro!.isEmpty))
                            const Text(
                              "• Nenhum recurso específico detalhado.",
                              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)
                            ),
                        ],
                      ),
                    )
                  ],
                  if (!isApoio && prop.motivoRecusa != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Motivo: ${prop.motivoRecusa?.descricao ?? prop.motivoRecusa}',
                              style: TextStyle(color: Colors.red[900], fontSize: 12, fontWeight: FontWeight.bold)
                            ),
                            if (prop.motivoOutro != null && prop.motivoOutro!.isNotEmpty)
                              Text(
                                'Detalhe: ${prop.motivoOutro}',
                                style: TextStyle(color: Colors.red[900], fontSize: 12)
                              ),
                          ],
                        ),
                      ),
                    )
                ],
              ),
            );
          },
        )
      ],
    );
  }

  Widget _buildOperacionalCard(CombateIncendioTerrestre combate) {
    return _buildCardBase(
      title: 'Dados Operacionais',
      icon: Icons.settings,
      children: [
        _buildInfoTile('Quilometragem', combate.quilometragem != null ? '${combate.quilometragem} Km' : '--'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildInfoTile('Efetividade', _getDescricao(combate.efetividadeCombate))),
            Expanded(child: _buildInfoTile('Reforço', _getDescricao(combate.reforco))),
          ],
        ),
        const SizedBox(height: 12),
        _buildInfoTile('Horário Chegada', _formatDate(combate.horarioChegada)),
      ],
    );
  }

  Widget _buildRecursosCard(CombateIncendioTerrestre combate) {
    return _buildCardBase(
      title: 'Recursos e Ações',
      icon: Icons.construction,
      children: [
        _buildEnumListTile('Ações Realizadas', combate.tipoAcaoCombateIncendio),
        _buildEnumListTile('Apoio de Órgãos', combate.tipoApoioOrgao),
        if (combate.tipoApoioOutro != null && combate.tipoApoioOutro!.isNotEmpty)
          _buildInfoTile('Outro Órgão', combate.tipoApoioOutro!),
        _buildEnumListTile('Materiais Utilizados', combate.tipoMateriaisUtilizados),
        const Divider(),
        _buildEnumListTile('Origem da Água', combate.origemAgua),
        if (combate.quantidadeLitrosAgua != null)
          _buildInfoTile('Qtd. Água', '${combate.quantidadeLitrosAgua} Litros'),
      ],
    );
  }

  Widget _buildRelatorioCard(CombateIncendioTerrestre combate) {
    String textoResultado;
    if (combate.tipoResultado == TipoResultadoIncendioTerrestre.OUTRO) {
      textoResultado = combate.resultadoOcorrencia ?? 'Não informado';
    } else {
      textoResultado = _getDescricao(combate.tipoResultado);
    }
    return _buildCardBase(
      title: 'Relatório',
      icon: Icons.assignment,
      children: [
        _buildInfoTile('Causa Provável', _getDescricao(combate.origemIncendio)),
        const Divider(height: 24),
        _buildInfoTile('Descrição da Operação', combate.historicoDescritivo ?? 'Não informado'),
        const SizedBox(height: 12),
        _buildInfoTile('Resultado do Dia', textoResultado),
      ],
    );
  }

  Widget _buildGaleriaCard(BuildContext context, CombateIncendioTerrestre combate) {
    // ✅ FILTRAR: Remove a imagem da origem dos anexos gerais
    List<String> anexosGerais = combate.arquivosLocais.where((arquivo) {
      return arquivo != combate.imagemOrigemIncendio;
    }).toList();

    if (anexosGerais.isEmpty) return const SizedBox.shrink();

    return _buildCardBase(
      title: 'Anexos Gerais',
      icon: Icons.attach_file,
      children: [
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: anexosGerais.length,
            itemBuilder: (context, index) {
              final nomeArquivo = anexosGerais[index];
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
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87
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

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey, fontSize: 13)
            )
          ),
          Expanded(child: Text(value ?? '-', style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 15, color: Colors.black87)),
      ],
    );
  }

  Widget _buildEnumListTile(String title, List<Enum> items) {
    if (items.isEmpty) {
       return Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
           const Text('--', style: TextStyle(fontSize: 14)),
           const SizedBox(height: 8),
         ]
       );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: items.map((item) => Chip(
              label: Text(_getDescricao(item), style: const TextStyle(fontSize: 12)),
              backgroundColor: Colors.grey[100],
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )).toList(),
          )
        ]
      ),
    );
  }
}