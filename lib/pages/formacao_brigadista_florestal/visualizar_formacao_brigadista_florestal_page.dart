
import 'dart:io';
import 'package:fortivus_app/components/auth_image_widget.dart';
import 'package:fortivus_app/enums/tipo_conclusao_alunos.dart';
import 'package:flutter/material.dart';
import 'package:fortivus_app/model/formacao_brigadista_florestal.dart';
import 'package:fortivus_app/services/responder/responder_formacao_brigadista_service.dart';  
import 'package:fortivus_app/util/map_launcher_util.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';

class VisualizarFormacaoBrigadistPage extends StatefulWidget {
  final int registroId;

  const VisualizarFormacaoBrigadistPage({
    super.key,
    required this.registroId,
  });

  @override
  State<VisualizarFormacaoBrigadistPage> createState() =>
      _VisualizarFormacaoBrigadistaBusPageState();
}

class _VisualizarFormacaoBrigadistaBusPageState
    extends State<VisualizarFormacaoBrigadistPage> {
  final ResponderFormacaoService _service = ResponderFormacaoService(); 
  late final Future<FormacaoBrigadistaFlorestal> _futureFormacao;

  @override
  void initState() {
    super.initState();
    // ✅ REMOVIDO: categoria (não é parâmetro)
    _futureFormacao = _service.getResposta<FormacaoBrigadistaFlorestal>(
      registroId: widget.registroId,
      fromJson: (json) {
        debugPrint('📥 [VISUALIZAR] JSON recebido:');
        debugPrint('   - Tem alunosMatriculados: ${json.containsKey('alunosMatriculados')}');
        debugPrint('   - Tem arquivos: ${json.containsKey('arquivos')}');
        
        if (json.containsKey('alunosMatriculados') && json['alunosMatriculados'] != null) {
          final alunosList = json['alunosMatriculados'] as List;
          debugPrint('   - Quantidade de alunos: ${alunosList.length}');
        }
        
        if (json.containsKey('arquivos') && json['arquivos'] != null) {
          final arquivosList = json['arquivos'] as List;
          debugPrint('   - Quantidade de arquivos: ${arquivosList.length}');
        }
        
        return FormacaoBrigadistaFlorestal.fromJson(json);
      },
      emptyFactory: (id) => FormacaoBrigadistaFlorestal(id: id),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '--';
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatCoord(double? valor) {
    if (valor == null) return '--';
    return valor.toStringAsFixed(6);
  }

  Widget _buildImagemAdaptavel(
    String path, {
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
  }) {
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
            title: const Text(
              "Visualização",
              style: TextStyle(color: Colors.white),
            ),
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
        title: Text('RO Formação: ${widget.registroId}'),
        backgroundColor: TacticalTheme.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: TacticalTheme.background,
      body: FutureBuilder<FormacaoBrigadistaFlorestal>(
        future: _futureFormacao,
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
            final formacao = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ 1. LOCALIZAÇÃO
                  _buildLocalizacaoCard(context, formacao),
                  const SizedBox(height: 16),

                  // ✅ 2. DESLOCAMENTO
                  _buildDeslocamentoCard(formacao),
                  const SizedBox(height: 16),

                  // ✅ 3. CAPACITAÇÃO
                  _buildCapacitacaoCard(formacao),
                  const SizedBox(height: 16),

                  // ✅ 4. QUEIMA DE INSTRUÇÃO
                  if (formacao.queimaInstrucaoRealizada) ...[
                    _buildQueimaCard(context, formacao),
                    const SizedBox(height: 16),
                  ],

                  // ✅ 5. ACIDENTES/INCIDENTES
                  if (formacao.acidentesIncidentesOcorridos) ...[
                    _buildAcidentesCard(formacao),
                    const SizedBox(height: 16),
                  ],

                  // ✅ 6. HISTÓRICO
                  _buildHistoricoCard(formacao),
                  const SizedBox(height: 16),

                  // ✅ 7. ALUNOS MATRICULADOS
                  _buildAlunosCard(formacao),
                  const SizedBox(height: 16),

                  // ✅ 8. QTS NOVO
                  if (formacao.arquivoQtsNovo != null &&
                      formacao.arquivoQtsNovo!.isNotEmpty &&
                      formacao.arquivoQtsNovo != 'QTS_CONFORME') ...[
                    _buildQtsCard(context, formacao),
                    const SizedBox(height: 16),
                  ],

                  // ✅ 9. ANEXOS
                  if (formacao.arquivos.isNotEmpty)
                    _buildGaleriaCard(context, formacao),
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

  // ============================================================================
  // CARDS
  // ============================================================================

  Widget _buildLocalizacaoCard(
    BuildContext context,
    FormacaoBrigadistaFlorestal formacao,
  ) {
    bool temCoordenadas = formacao.latitudeAtuacao != null &&
        formacao.longitudeAtuacao != null;

    return _buildCardBase(
      title: 'Localização da Atividade',
      icon: Icons.location_on,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoTile(
                'Latitude',
                _formatCoord(formacao.latitudeAtuacao),
              ),
            ),
            Expanded(
              child: _buildInfoTile(
                'Longitude',
                _formatCoord(formacao.longitudeAtuacao),
              ),
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
                backgroundColor: TacticalTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {
                MapLauncherUtil.openMapsDialog(
                  context,
                  formacao.latitudeAtuacao!,
                  formacao.longitudeAtuacao!,
                );
              },
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildDeslocamentoCard(FormacaoBrigadistaFlorestal formacao) {
    return _buildCardBase(
      title: 'Período de Deslocamento',
      icon: Icons.schedule,
      children: [
        _buildInfoTile(
          'Deslocamento Inicial',
          _formatDateTime(formacao.deslocamentoInicialGuarnicao),
        ),
        const SizedBox(height: 12),
        _buildInfoTile(
          'Deslocamento Final',
          _formatDateTime(formacao.deslocamentoFinalGuarnicao),
        ),
      ],
    );
  }

  Widget _buildCapacitacaoCard(FormacaoBrigadistaFlorestal formacao) {
    return _buildCardBase(
      title: 'Capacitação de Brigadistas',
      icon: Icons.school,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: TacticalTheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: TacticalTheme.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.people, color: TacticalTheme.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Brigadistas Capacitados',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formacao.qtdBrigadistasCapacitados ?? 0} pessoas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: TacticalTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQueimaCard(
    BuildContext context,
    FormacaoBrigadistaFlorestal formacao,
  ) {
    bool temCoordenadasQueima = formacao.latitudeQueimaInst != null &&
        formacao.longitudeQueimaInst != null;

    return _buildCardBase(
      title: 'Queima de Instrução',
      icon: Icons.local_fire_department,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    'Realizada',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoTile(
                      'Latitude',
                      _formatCoord(formacao.latitudeQueimaInst),
                    ),
                  ),
                  Expanded(
                    child: _buildInfoTile(
                      'Longitude',
                      _formatCoord(formacao.longitudeQueimaInst),
                    ),
                  ),
                ],
              ),
              if (temCoordenadasQueima) ...[
                const SizedBox(height: 12),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.map),
                    label: const Text('Ver no Mapa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () {
                      MapLauncherUtil.openMapsDialog(
                        context,
                        formacao.latitudeQueimaInst!,
                        formacao.longitudeQueimaInst!,
                      );
                    },
                  ),
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAcidentesCard(FormacaoBrigadistaFlorestal formacao) {
    return _buildCardBase(
      title: 'Acidentes/Incidentes',
      icon: Icons.warning_amber,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.error, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Ocorrências Registradas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoTile(
                'Descrição',
                formacao.descricaoAcidenteIncidente ?? 'Não informado',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoricoCard(FormacaoBrigadistaFlorestal formacao) {
    if (formacao.historico == null || formacao.historico!.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildCardBase(
      title: 'Histórico da Formação',
      icon: Icons.description,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: _buildInfoTile(
            'Descrição',
            formacao.historico ?? 'Não informado',
          ),
        ),
      ],
    );
  }

  Widget _buildAlunosCard(FormacaoBrigadistaFlorestal formacao) {
    if (formacao.alunosMatriculados.isEmpty) {
      return _buildCardBase(
        title: 'Alunos Matriculados',
        icon: Icons.people,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Nenhum aluno registrado',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return _buildCardBase(
      title: 'Alunos Matriculados',
      icon: Icons.people,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: TacticalTheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: TacticalTheme.primary.withValues(alpha: 0.3)),
          ),
          child: Text(
            '${formacao.alunosMatriculados.length} aluno${formacao.alunosMatriculados.length != 1 ? 's' : ''} registrado${formacao.alunosMatriculados.length != 1 ? 's' : ''}',
            style: TextStyle(
              color: TacticalTheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: formacao.alunosMatriculados.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final aluno = formacao.alunosMatriculados[index];
            return _buildCardAluno(aluno);
          },
        ),
      ],
    );
  }

  Widget _buildQtsCard(
    BuildContext context,
    FormacaoBrigadistaFlorestal formacao,
  ) {
    final qtsFileName = formacao.arquivoQtsNovo ?? '';
    final isImage = qtsFileName.toLowerCase().endsWith('.jpg') ||
        qtsFileName.toLowerCase().endsWith('.png') ||
        qtsFileName.toLowerCase().endsWith('.jpeg');

    return _buildCardBase(
      title: 'Arquivo QTS (Alterado)',
      icon: Icons.file_present,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: TacticalTheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Arquivo QTS Modificado',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          qtsFileName,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontFamily: 'monospace',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isImage) ...[
                const SizedBox(height: 12),
                Center(
                  child: GestureDetector(
                    onTap: () => _abrirImagemFullScreen(context, qtsFileName),
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildImagemAdaptavel(
                          qtsFileName,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.fullscreen),
                    label: const Text('Ver em Tela Cheia'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TacticalTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () =>
                        _abrirImagemFullScreen(context, qtsFileName),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.insert_drive_file,
                        color: TacticalTheme.primary,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Arquivo Anexado',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardAluno(dynamic aluno) {
    final statusColor = _getStatusColor(aluno.concludente);
    final statusText = aluno.concludente != null
        ? (aluno.concludente as TipoConclusaoAlunos).descricao
        : 'Pendente';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aluno.nomeCompleto,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'CPF: ${aluno.cpf}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 10,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (aluno.email != null || aluno.telefone != null) ...[
            const SizedBox(height: 8),
            if (aluno.email != null)
              Row(
                children: [
                  Icon(Icons.email, size: 13, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      aluno.email!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            if (aluno.telefone != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.phone, size: 13, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text(
                    aluno.telefone!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(TipoConclusaoAlunos? status) {
    switch (status) {
      case TipoConclusaoAlunos.PRIMEIRA_FORMACAO:
        return TacticalTheme.accentGreen;
      case TipoConclusaoAlunos.RECICLAGEM:
        return TacticalTheme.accentGreen;
      case TipoConclusaoAlunos.DESISTENTE:
        return Colors.red[700]!;
      case null:
        return Colors.grey;
    }
  }

  Widget _buildGaleriaCard(
    BuildContext context,
    FormacaoBrigadistaFlorestal formacao,
  ) {
    List<String> arquivosUrls = formacao.arquivos;

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
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: isImage
                          ? _buildImagemAdaptavel(nomeArquivo)
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.insert_drive_file,
                                  color: Colors.grey[600],
                                  size: 30,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Arquivo",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                )
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

  // ============================================================================
  // WIDGETS AUXILIARES
  // ============================================================================

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