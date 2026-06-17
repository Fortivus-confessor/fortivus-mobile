import 'dart:io';

import 'package:fortivus_app/components/auth_image_widget.dart';
import 'package:fortivus_app/config/environment_config.dart';
import 'package:fortivus_app/enums/tipo_publico_alvo_formacao.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../model/registro.dart';
import '../../util/map_launcher_util.dart';

class DetalhesFormacaoPage extends StatelessWidget {
  final Registro registro;

  const DetalhesFormacaoPage({super.key, required this.registro});

  // Helper para formatar as datas ISO que vêm do banco/API
  String _formatarDataIso(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '--';
    try {
      final d = DateTime.parse(isoString);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} às ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoString;
    }
  }

  // Helper para formatar listas de enums para texto legível
  String _formatarListaEnum(List<String> lista, String? outroDesc) {
    if (lista.isEmpty) return '--';
    
    List<String> formatados = lista.map((strBanco) {
      if (strBanco == 'OUTRO' && outroDesc != null && outroDesc.isNotEmpty) {
        return outroDesc;
      }
      
      try {
        final enumValue = TipoPublicoAlvoFormacao.values.firstWhere((e) => e.name == strBanco);
        return enumValue.descricao;
      } catch (_) {
        return strBanco.replaceAll('_', ' ');
      }
    }).toList();

    return formatados.join(', ');
  }

  Future<void> _baixarEAbrirDocumento(BuildContext context, String nomeArquivo) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abrindo $nomeArquivo...'),
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String offlinePath = '${appDir.path}/offline_images/$nomeArquivo';
      final File offlineFile = File(offlinePath);

      if (await offlineFile.exists()) {
        final result = await OpenFilex.open(offlinePath);
        if (result.type == ResultType.done) return;
      }

      String baseUrl = EnvironmentConfig.apiBaseUrl;
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }
      
      final String urlArquivo = baseUrl.endsWith('api') 
          ? '$baseUrl/registro_ocorrencia/arquivos/$nomeArquivo'
          : '$baseUrl/api/registro_ocorrencia/arquivos/$nomeArquivo';

      final response = await http.get(Uri.parse(urlArquivo));

      if (response.statusCode == 200) {
        final Directory tempDir = await getTemporaryDirectory();
        final String tempPath = '${tempDir.path}/$nomeArquivo';
        final File tempFile = File(tempPath);

        await tempFile.writeAsBytes(response.bodyBytes);

        final result = await OpenFilex.open(tempPath);
        
        if (result.type != ResultType.done && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nenhum aplicativo encontrado para abrir este arquivo.')),
          );
        }
      } else {
        throw Exception('Erro ${response.statusCode}: Arquivo não encontrado ou não autorizado.');
      }

    } catch (e) {
      debugPrint('Erro ao abrir documento: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha ao abrir: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isOffline = registro.situacao == 'RESPONDIDO_OFFLINE';

    return Scaffold(
      appBar: AppBar(
        title: Text('RO Formação: ${registro.id}'),
        backgroundColor: isOffline ? Colors.amber[800] : TacticalTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            if (isOffline) 
              _buildOfflineBanner(),
              
            _buildSection(
              'Informações Básicas',
              [
                _buildInfoRow('Ordem de Serviço', registro.ordemServico.toString()),
                _buildInfoRow('Data de Criação', registro.dataCriacaoFormatada),
                _buildInfoRow('Categoria', registro.categoriaDescricao),
                _buildInfoRow('Situação', registro.situacao),
              ],
            ),
            const SizedBox(height: 20),
            
            _buildDespachoFormacaoSection(context),
            const SizedBox(height: 20),

            _buildSection(
              'Detalhes da Ocorrência',
              [
                _buildInfoRow('Usuário Responsável', _formatUsuarioResponsavel(registro)),
    
                if (registro.hasValidCoordinates()) ...[
                  _buildInfoRow('Coordenadas Atuação', registro.getCoordinatesForUrl()),
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
                        MapLauncherUtil.openMapsDialog(
                          context,
                          registro.latitudeRo,
                          registro.longitudeRo,
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Descrição da Ocorrência:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    registro.descricao,
                    style: const TextStyle(height: 1.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildSection(
              'Informações da Guarnição',
              [
                _buildInfoRow('Nome da Guarnição', registro.cicloGuarnicaoGuarnicao),
                _buildInfoRow('Comando Regional', registro.comandoRegionalNome ?? 'Não informado'),
                const SizedBox(height: 12),
                const Text(
                  'Informações da Viatura:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        _buildInfoRow('Identificador', registro.viaturaIdentificador ?? registro.cicloGuarnicaoVeiculo),
                        if (registro.viaturaModelo != null)
                          _buildInfoRow('Modelo', registro.viaturaModelo!),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Militares da Guarnição:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (registro.militares.isNotEmpty) ...[
                  ...registro.militares
                      .where((m) => m.postoDescricao.toLowerCase() == registro.cicloGuarnicaoPostoComandante.toLowerCase() &&
                          m.nome.toLowerCase() == registro.cicloGuarnicaoComandante.toLowerCase())
                      .map((militar) => _buildMilitarExpandido(militar, isComandante: true, isCondutor: false, backgroundColor: Colors.red.shade50)),
                  ...registro.militares
                      .where((m) => m.postoDescricao.toLowerCase() == registro.cicloGuarnicaoPostoCondutor.toLowerCase() &&
                          m.nome.toLowerCase() == registro.cicloGuarnicaoCondutor.toLowerCase())
                      .map((militar) => _buildMilitarExpandido(militar, isComandante: false, isCondutor: true, backgroundColor: Colors.amber.shade50)),
                  ...registro.militares
                      .where((m) => m.nome.toLowerCase() != registro.cicloGuarnicaoComandante.toLowerCase() &&
                          m.nome.toLowerCase() != registro.cicloGuarnicaoCondutor.toLowerCase())
                      .map((militar) => _buildMilitarExpandido(militar, isComandante: false, isCondutor: false, backgroundColor: Colors.blue.shade50)),
                ] else
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Nenhum militar cadastrado na guarnição'),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDespachoFormacaoSection(BuildContext context) {
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
            Row(
              children: [
                Icon(Icons.assignment_ind, color: TacticalTheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Dados do Despacho',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TacticalTheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            
            _buildInfoRow('Público Alvo', _formatarListaEnum(registro.publicoAlvoFormacao, registro.publicoAlvoOutroDescFormacao)),
            const SizedBox(height: 12),
            
            _buildInfoRow('Deslocamento (Saída)', _formatarDataIso(registro.deslocamentoInicialDespacho)),
            _buildInfoRow('Deslocamento (Fim)', _formatarDataIso(registro.deslocamentoFinalDespacho)),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TacticalTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.contact_phone, size: 18, color: TacticalTheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Contato no Local:', 
                        style: TextStyle(fontWeight: FontWeight.bold, color: TacticalTheme.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Nome', registro.nomeContato),
                  _buildInfoRow('Telefone', registro.telefoneContato),
                  
                  if (registro.latitudeContato != null && registro.longitudeContato != null) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.directions),
                        label: const Text('Rota para o Contato'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TacticalTheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          MapLauncherUtil.openMapsDialog(
                            context,
                            registro.latitudeContato!,
                            registro.longitudeContato!,
                          );
                        },
                      ),
                    ),
                  ]
                ],
              ),
            ),
            
            if (registro.arquivosDespachoFormacao.isNotEmpty)
              _buildGaleriaImagens(registro.arquivosDespachoFormacao),
          ],
        ),
      ),
    );
  }

  // Widget para exibir imagens de informações de apoio e pista de pouso
  Widget _buildGaleriaImagens(List<String> arquivos) {
    if (arquivos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(),
        const Text(
          'Arquivos Anexados:', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 90, 
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: arquivos.length,
            itemBuilder: (context, index) {
              final nomeArquivo = arquivos[index];
              
              // Verifica se é imagem
              final extensao = nomeArquivo.split('.').last.toLowerCase();
              final isImagem = ['jpg', 'jpeg', 'png', 'webp'].contains(extensao);

              return GestureDetector(
                onTap: () {
                  if (isImagem) {
                    _abrirImagemFullScreen(context, nomeArquivo);
                  } else {
                    // Chama o método de download se for PDF, DOC, etc.
                    _baixarEAbrirDocumento(context, nomeArquivo);
                  }
                },
                child: Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: isImagem
                        ? AuthImageWidget(
                            fileName: nomeArquivo,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.file_download, color: Colors.blueGrey, size: 30),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  nomeArquivo.length > 10 
                                    ? '${nomeArquivo.substring(0, 8)}...' 
                                    : nomeArquivo,
                                  style: const TextStyle(fontSize: 10),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
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

  void _abrirImagemFullScreen(BuildContext context, String nomeArquivo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              nomeArquivo,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          body: Center(
            // InteractiveViewer permite dar ZOOM na imagem com movimento de pinça
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: AuthImageWidget(
                fileName: nomeArquivo,
                fit: BoxFit.contain, 
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatUsuarioResponsavel(Registro registro) {
    if (registro.hasValidMilitares()) {
      for (var militar in registro.militares) {
        if (militar.id == registro.usuario) {
          return "${militar.postoDescricao} ${militar.nome}";
        }
      }
    }
    return registro.usuario;
  }

  Widget _buildMilitarExpandido(Usuario militar, {
    bool isComandante = false, 
    bool isCondutor = false, 
    Color? backgroundColor
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isComandante ? 3 : (isCondutor ? 2 : 1),
      color: backgroundColor,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isComandante ? Colors.red : (isCondutor ? Colors.amber : Colors.blue),
          child: Icon(
            isComandante ? Icons.star : (isCondutor ? Icons.drive_eta : Icons.person),
            color: Colors.white,
          ),
        ),
        title: Text(
          "${militar.postoDescricao} ${militar.nome}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          isComandante ? "Comandante" : 
          (isCondutor ? "Condutor da Viatura" : "Militar da Guarnição")
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (militar.matricula.isNotEmpty)
                  _buildInfoRow('Matrícula', militar.matricula),
                if (militar.nomeGuerra.isNotEmpty)
                  _buildInfoRow('Nome de Guerra', militar.nomeGuerra),
                if (militar.comandoRegionalNome.isNotEmpty)
                  _buildInfoRow('Comando', militar.comandoRegionalNome),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        border: Border.all(color: Colors.amber.shade700),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, color: Colors.amber.shade900),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Aguardando Sincronização",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
                const Text(
                  "Este registro está salvo no seu dispositivo e será enviado assim que houver conexão.",
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    final String displayValue = (value == null || value.trim().isEmpty) ? '--' : value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(displayValue),
          ),
        ],
      ),
    );
  }
}