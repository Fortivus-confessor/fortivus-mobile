
import 'package:fortivus_app/components/auth_image_widget.dart';
import 'package:fortivus_app/model/combate_incendio_maquinario.dart';
import 'package:fortivus_app/services/responder/responder_maquinario_service.dart';  
import 'package:fortivus_app/util/map_launcher_util.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:fortivus_app/enums/tipo_resultado_incendio.dart';

class VisualizarCombateMaquinarioPage extends StatefulWidget {
  final int registroId;
  const VisualizarCombateMaquinarioPage({super.key, required this.registroId});
  
  @override
  State<VisualizarCombateMaquinarioPage> createState() => _VisualizarCombateMaquinarioPageState();
}

class _VisualizarCombateMaquinarioPageState extends State<VisualizarCombateMaquinarioPage> {
  final ResponderMaquinarioService _service = ResponderMaquinarioService();  // ✅ MUDADO
  late final Future<CombateIncendioMaquinario> _futureCombate;

  @override
  void initState() {
    super.initState();
    // ✅ REMOVIDO: categoria (não é parâmetro)
    _futureCombate = _service.getResposta<CombateIncendioMaquinario>(
      registroId: widget.registroId,
      fromJson: (json) => CombateIncendioMaquinario.fromJson(json),
      emptyFactory: (id) => CombateIncendioMaquinario(id: id),
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

  String _formatTime(DateTime? time) {
    if (time == null) return '--:--';
    return '${time.hour.toString().padLeft(2,'0')}:${time.minute.toString().padLeft(2,'0')}';
  }

  String _calcularTempoOperacao(DateTime? inicio, DateTime? fim) {
    if (inicio == null || fim == null) return 'Não calculado';
    final duracao = fim.difference(inicio);
    final horas = duracao.inHours;
    final minutos = duracao.inMinutes.remainder(60);
    return '$horas h $minutos min';
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
        title: Text('RO Maquinário: ${widget.registroId}'),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<CombateIncendioMaquinario>(
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

                  // 3. DADOS DO MAQUINÁRIO
                  _buildMaquinarioCard(combate),
                  const SizedBox(height: 16),

                  // 4. RELATÓRIO
                  _buildRelatorioCard(combate),
                  const SizedBox(height: 16),

                  // 5. ANEXOS GERAIS
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

  Widget _buildLocalizacaoCard(BuildContext context, CombateIncendioMaquinario combate) {
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

  Widget _buildOperacionalCard(CombateIncendioMaquinario combate) {
    return _buildCardBase(
      title: 'Dados Operacionais',
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
        _buildInfoTile('Horário Chegada', _formatDate(combate.horarioChegada)),
        const SizedBox(height: 12),
        _buildInfoTile('Tipo de Emprego', _getDescricao(combate.tipoEmprego)),
      ],
    );
  }

  Widget _buildMaquinarioCard(CombateIncendioMaquinario combate) {
    return _buildCardBase(
      title: 'Dados do Maquinário',
      icon: Icons.agriculture,
      iconColor: Colors.amber[800],
      children: [
        // Horímetro
        Row(
          children: [
            Expanded(
              child: _buildInfoTile(
                'Horímetro Inicial',
                combate.horimetroInicial ?? '--'
              )
            ),
            Expanded(
              child: _buildInfoTile(
                'Horímetro Final',
                combate.horimetroFinal ?? '--'
              )
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Horários de Operação
        Row(
          children: [
            Expanded(
              child: _buildInfoTile(
                'Início Operação',
                _formatTime(combate.horaInicioOperacao)
              )
            ),
            Expanded(
              child: _buildInfoTile(
                'Fim Operação',
                _formatTime(combate.horaFinalOperacao)
              )
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Tempo Total e Comprimento
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
                  const Text(
                    'Tempo Total de Operação:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)
                  ),
                  Text(
                    _calcularTempoOperacao(combate.horaInicioOperacao, combate.horaFinalOperacao),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[900]
                    )
                  ),
                ],
              ),
              if (combate.comprimentoAceiro != null) ...[
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Comprimento do Aceiro:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)
                    ),
                    Text(
                      '${combate.comprimentoAceiro!.toStringAsFixed(2)} m',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[900]
                      )
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

  Widget _buildRelatorioCard(CombateIncendioMaquinario combate) {
    String textoResultado;
    if (combate.tipoResultado == TipoResultadoIncendio.OUTRO) {
      textoResultado = combate.resultadoOcorrencia ?? 'Não informado';
    } else {
      textoResultado = _getDescricao(combate.tipoResultado);
    }
    
    return _buildCardBase(
      title: 'Relatório',
      icon: Icons.assignment,
      iconColor: Colors.green[700],
      children: [
        _buildInfoTile('Descrição da Operação', combate.historicoDescritivo ?? 'Não informado'),
        const SizedBox(height: 12),
        _buildInfoTile('Resultado do Dia', textoResultado),
      ],
    );
  }
  
  Widget _buildGaleriaCard(BuildContext context, CombateIncendioMaquinario combate) {
    if (combate.arquivosLocais.isEmpty) return const SizedBox.shrink();
    return _buildCardBase(
      title: 'Anexos',
      icon: Icons.attach_file,
      children: [
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: combate.arquivosLocais.length,
            itemBuilder: (context, index) {
              final nomeArquivo = combate.arquivosLocais[index];
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
                  Icon(icon, color: iconColor ?? Colors.amber[800], size: 20),
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
}