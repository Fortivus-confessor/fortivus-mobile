import 'dart:io';

import 'package:fortivus_app/components/auth_image_widget.dart';
import 'package:fortivus_app/config/environment_config.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../model/registro.dart';
import '../util/map_launcher_util.dart';

class DetalhesRegistroPage extends StatelessWidget {
  final Registro registro;

  const DetalhesRegistroPage({super.key, required this.registro});

  Future<void> _baixarEAbrirDocumento(BuildContext context, String nomeArquivo) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Abrindo documento...'), 
        duration: Duration(seconds: 2),
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
        String nomeParaSalvar = nomeArquivo;
        final contentDisposition = response.headers['content-disposition'];
        
        if (contentDisposition != null) {
          final utf8Match = RegExp(r"filename\*=UTF-8''([^;]+)").firstMatch(contentDisposition);
          if (utf8Match != null) {
            nomeParaSalvar = Uri.decodeComponent(utf8Match.group(1)!);
          } else {
            final normalMatch = RegExp(r'filename="([^"]+)"').firstMatch(contentDisposition);
            if (normalMatch != null) {
              nomeParaSalvar = normalMatch.group(1)!;
            }
          }
        }

        final String tempPath = '${tempDir.path}/$nomeParaSalvar';
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
        final erroString = e.toString().toLowerCase();
        final isOffline = erroString.contains('socketexception') || 
                          erroString.contains('network is unreachable') || 
                          erroString.contains('clientexception') ||
                          erroString.contains('failed host lookup');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(isOffline ? Icons.wifi_off : Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isOffline 
                      ? 'Você está offline. Conecte-se à internet para baixar este arquivo.' 
                      : 'Falha ao abrir: $e',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: isOffline ? Colors.orange.shade800 : Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isOffline = registro.situacao == 'RESPONDIDO_OFFLINE';
    final bool isRetroativo = registro.retroativo;

    return Scaffold(
      appBar: AppBar(
        title: Text('RO: ${registro.id}${isRetroativo ? ' (Retroativo)' : ''}'),
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
              
            if (isRetroativo)
              _buildRetroativoBanner(),

            _buildSection(
              'Informações Básicas',
              [
                if(registro.ordemServico != 0)
                _buildInfoRow('Ordem de Serviço', registro.ordemServico.toString()),
                _buildInfoRow('Data de Criação', registro.dataCriacaoFormatada),
                if (isRetroativo && registro.dataFinalRoFormatada != null)
                  _buildInfoRow('Data Final', registro.dataFinalRoFormatada),
                _buildInfoRow('Categoria', registro.categoriaDescricao),
                _buildInfoRow('Situação', registro.situacao),
              ],
            ),
            
            if (registro.informacaoApoio != null) ...[
              const SizedBox(height: 20),
              _buildInfoApoio(),
            ],

            if (registro.pistaPouso != null) ...[
              const SizedBox(height: 20),
              _buildPistaPouso(context),
            ],

            const SizedBox(height: 20),
            _buildSection(
              'Detalhes da Ocorrência',
              [
                _buildInfoRow('Usuário Responsável', _formatUsuarioResponsavel(registro)),
    
                if (registro.hasValidCoordinates()) ...[
                  _buildInfoRow('Coordenadas', registro.getCoordinatesForUrl()),
                  const SizedBox(height: 8),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.map),
                      label: const Text('Abrir no Mapa'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (registro.militares.isNotEmpty) ...[
                  ...registro.militares
                      .where((m) => m.postoDescricao.toLowerCase() == registro.cicloGuarnicaoPostoComandante.toLowerCase() &&
                          m.nome.toLowerCase() == registro.cicloGuarnicaoComandante.toLowerCase())
                      .map((militar) => _buildMilitarExpandido(
                            militar,
                            isComandante: true,
                            isCondutor: false,
                            backgroundColor: Colors.red.shade50,
                          )),
                  ...registro.militares
                      .where((m) => m.postoDescricao.toLowerCase() == registro.cicloGuarnicaoPostoCondutor.toLowerCase() &&
                          m.nome.toLowerCase() == registro.cicloGuarnicaoCondutor.toLowerCase())
                      .map((militar) => _buildMilitarExpandido(
                            militar,
                            isComandante: false,
                            isCondutor: true,
                            backgroundColor: Colors.amber.shade50,
                          )),
                  ...registro.militares
                      .where((m) => 
                          m.nome.toLowerCase() != registro.cicloGuarnicaoComandante.toLowerCase() &&
                          m.nome.toLowerCase() != registro.cicloGuarnicaoCondutor.toLowerCase())
                      .map((militar) => _buildMilitarExpandido(
                            militar,
                            isComandante: false,
                            isCondutor: false,
                            backgroundColor: Colors.blue.shade50,
                          )),
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

  Widget _buildInfoApoio() {
    final apoio = registro.informacaoApoio!;

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
                Icon(Icons.handshake, color: TacticalTheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Informações de Apoio',
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
            
            _buildInfoRow('Local de Referência', apoio.localReferencia),
            _buildInfoRow('Pessoa de Contato', apoio.pessoaContato),
            _buildInfoRow('Telefone', apoio.telefone),
            
            if (apoio.logisticaDisponivel != null && apoio.logisticaDisponivel!.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Logística Disponível:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(apoio.logisticaDisponivel!),
              )
            ],

            _buildGaleriaImagens(apoio.listaArquivo),
          ],
        ),
      ),
    );
  }

  Widget _buildPistaPouso(BuildContext context) {
    final pista = registro.pistaPouso!;

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
                Icon(Icons.flight_takeoff, color: TacticalTheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Pista de Pouso',
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

            _buildInfoRow('Captação de Água', pista.tipoCaptacaoAgua),
            _buildInfoRow('Comprimento', pista.comprimento != null ? '${pista.comprimento} m' : null),
            _buildInfoRow('Largura', pista.largura != null ? '${pista.largura} m' : null),

            if (pista.hasCoordinates) ...[
              const SizedBox(height: 12),
              const Divider(),
              _buildInfoRow('Coordenadas', '${pista.latitude}, ${pista.longitude}'),
              const SizedBox(height: 8),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.airplanemode_active),
                  label: const Text('Rota para Pista'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[800],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    MapLauncherUtil.openMapsDialog(
                      context,
                      pista.latitude,
                      pista.longitude,
                    );
                  },
                ),
              ),
            ],

            _buildGaleriaImagens(pista.listaArquivo),
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

  Widget _buildRetroativoBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        border: Border.all(color: Colors.orange.shade700),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.history, color: Colors.orange.shade900),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Registro Retroativo",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
                Text(
                  "Este registro foi realizado retroativamente.",
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
                if (registro.dataInicioRoFormatada != null)
                  Text(
                    "Início: ${registro.dataInicioRoFormatada}",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                  ),
                if (registro.dataFinalRoFormatada != null)
                  Text(
                    "Fim: ${registro.dataFinalRoFormatada}",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
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

  Widget _buildInfoRow(String label, String? value, {Color? valueColor, bool isBoldValue = false}) {
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
            child: Text(
              displayValue,
              style: TextStyle(
                color: valueColor,
                fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}