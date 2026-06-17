import 'package:fortivus_app/model/alunos_formacao_brigada.dart';
import 'package:fortivus_app/model/resposta_modelo.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FormacaoBrigadistaFlorestal implements RespostaModelo {
  @override
  final int id;
  final double? latitudeAtuacao;
  final double? longitudeAtuacao;
  final DateTime? deslocamentoInicialGuarnicao;
  final DateTime? deslocamentoFinalGuarnicao;
  final int? qtdBrigadistasCapacitados;
  final bool queimaInstrucaoRealizada;
  final double? latitudeQueimaInst;
  final double? longitudeQueimaInst;
  final bool acidentesIncidentesOcorridos;
  final String? descricaoAcidenteIncidente;
  final String? historico;
  final String? arquivoQtsNovo;
  final XFile? arquivoQtsXFile;
  final List<String> arquivos;
  final List<AlunosFormacaoBrigada> alunosMatriculados;
  final double? latitudeDespacho;
  final double? longitudeDespacho;
  final DateTime? deslocamentoInicialDespacho;
  final DateTime? deslocamentoFinalDespacho;

  FormacaoBrigadistaFlorestal({
    required this.id,
    this.arquivoQtsXFile,
    this.latitudeAtuacao,
    this.longitudeAtuacao,
    this.deslocamentoInicialGuarnicao,
    this.deslocamentoFinalGuarnicao,
    this.qtdBrigadistasCapacitados,
    this.queimaInstrucaoRealizada = false,
    this.latitudeQueimaInst,
    this.longitudeQueimaInst,
    this.acidentesIncidentesOcorridos = false,
    this.descricaoAcidenteIncidente,
    this.historico,
    this.arquivoQtsNovo,
    this.arquivos = const [],
    this.alunosMatriculados = const [],
    this.latitudeDespacho,
    this.longitudeDespacho,
    this.deslocamentoInicialDespacho,
    this.deslocamentoFinalDespacho,
  });

  factory FormacaoBrigadistaFlorestal.fromJson(Map<String, dynamic> json) {
    debugPrint('🔧 [MODEL FORMACAO] Parseando JSON');
    debugPrint('   - Chaves: ${json.keys.toList()}');

    final dataInicialExecucao = json['deslocamentoInicialGuarnicao'] != null
        ? DateTime.parse(json['deslocamentoInicialGuarnicao'].toString())
        : null;

    final dataFinalExecucao = json['deslocamentoFinalGuarnicao'] != null
        ? DateTime.parse(json['deslocamentoFinalGuarnicao'].toString())
        : null;

    final dataInicialDespacho = json['deslocamentoInicialDespacho'] != null
        ? DateTime.parse(json['deslocamentoInicialDespacho'].toString())
        : null;

    final dataFinalDespacho = json['deslocamentoFinalDespacho'] != null
        ? DateTime.parse(json['deslocamentoFinalDespacho'].toString())
        : null;

    List<AlunosFormacaoBrigada> alunos = [];

    if (json['alunosMatriculados'] != null && json['alunosMatriculados'] is List) {
      debugPrint('👥 [MODEL FORMACAO] Parseando alunos...');
      final alunosList = json['alunosMatriculados'] as List;
      debugPrint('   - Total de alunos: ${alunosList.length}');

      alunos = alunosList
          .map((a) {
            try {
              return AlunosFormacaoBrigada.fromJson(a as Map<String, dynamic>);
            } catch (e) {
              debugPrint('   ❌ Erro ao parsear aluno: $e');
              return null;
            }
          })
          .whereType<AlunosFormacaoBrigada>()
          .toList();

      debugPrint('   - Alunos parseados com sucesso: ${alunos.length}');
    } else {
      debugPrint('⚠️ [MODEL FORMACAO] alunosMatriculados é NULL ou não é List');
    }

    List<String> arquivosAnexados = [];

    if (json['arquivos'] != null && json['arquivos'] is List) {
      debugPrint('📎 [MODEL FORMACAO] Parseando arquivos...');
      final arquivosList = json['arquivos'] as List;
      debugPrint('   - Total de arquivos: ${arquivosList.length}');

      arquivosAnexados = arquivosList
          .map((arquivo) {
            try {
              if (arquivo is Map<String, dynamic>) {
                final url = arquivo['urlArquivo'] as String?;
                final nome = arquivo['nomeOriginal'] as String?;

                if (url != null && url.isNotEmpty) {
                  debugPrint('     - $nome -> $url');
                  return url;
                }
              } else if (arquivo is String) {
                debugPrint('     - $arquivo');
                return arquivo;
              }
              return null;
            } catch (e) {
              debugPrint('   ❌ Erro ao parsear arquivo: $e');
              return null;
            }
          })
          .whereType<String>()
          .toList();

      debugPrint('   - Arquivos parseados: ${arquivosAnexados.length}');
    } else if (json['arquivosLocais'] != null && json['arquivosLocais'] is List) {
      debugPrint('📎 [MODEL FORMACAO] Parseando arquivos locais...');
      arquivosAnexados = List<String>.from(json['arquivosLocais'] as List);
      debugPrint('   - Total de arquivos locais: ${arquivosAnexados.length}');
    } else {
      debugPrint('⚠️ [MODEL FORMACAO] Nenhum arquivo encontrado');
    }

    debugPrint('✅ [MODEL FORMACAO] Dados parseados com sucesso:');
    debugPrint('   - ID: ${json['id']}');
    debugPrint('   - Data inicial execução: $dataInicialExecucao');
    debugPrint('   - Data final execução: $dataFinalExecucao');
    debugPrint('   - Data inicial despacho: $dataInicialDespacho');
    debugPrint('   - Data final despacho: $dataFinalDespacho');
    debugPrint('   - Latitude despacho: ${json['latitudeDespacho']}');
    debugPrint('   - Longitude despacho: ${json['longitudeDespacho']}');
    debugPrint('   - Alunos: ${alunos.length}');
    debugPrint('   - Arquivos: ${arquivosAnexados.length}');
    debugPrint('   - QtdBrigadistas: ${json['qtdBrigadistasCapacitados']}');

    return FormacaoBrigadistaFlorestal(
      id: json['id'] as int? ?? 0,
      latitudeAtuacao: (json['latitudeAtuacao'] as num?)?.toDouble(),
      longitudeAtuacao: (json['longitudeAtuacao'] as num?)?.toDouble(),
      deslocamentoInicialGuarnicao: dataInicialExecucao,
      deslocamentoFinalGuarnicao: dataFinalExecucao,
      qtdBrigadistasCapacitados: json['qtdBrigadistasCapacitados'] as int?,
      queimaInstrucaoRealizada: json['queimaInstrucaoRealizada'] as bool? ?? false,
      latitudeQueimaInst: (json['latitudeQueimaInst'] as num?)?.toDouble(),
      longitudeQueimaInst: (json['longitudeQueimaInst'] as num?)?.toDouble(),
      acidentesIncidentesOcorridos: json['acidentesIncidentesOcorridos'] as bool? ?? false,
      descricaoAcidenteIncidente: json['descricaoAcidenteIncidente']?.toString(),
      historico: json['historico']?.toString(),
      arquivoQtsNovo: json['arquivoQtsNovo']?.toString(),
      arquivos: arquivosAnexados,
      alunosMatriculados: alunos,
      latitudeDespacho: (json['latitudeDespacho'] as num?)?.toDouble(),
      longitudeDespacho: (json['longitudeDespacho'] as num?)?.toDouble(),
      deslocamentoInicialDespacho: dataInicialDespacho,
      deslocamentoFinalDespacho: dataFinalDespacho,
    );
  }

 @override
  Map<String, dynamic> toJson() {
    return {
      'idRegistroOcorrencia': id, 
      'latitudeAtuacao': latitudeAtuacao,
      'longitudeAtuacao': longitudeAtuacao,
      'deslocamentoInicialGuarnicao': deslocamentoInicialGuarnicao?.toIso8601String().substring(0, 19),
      'deslocamentoFinalGuarnicao': deslocamentoFinalGuarnicao?.toIso8601String().substring(0, 19),
      'qtdBrigadistasCapacitados': qtdBrigadistasCapacitados,
      'queimaInstrucaoRealizada': queimaInstrucaoRealizada,
      'latitudeQueimaInst': latitudeQueimaInst,
      'longitudeQueimaInst': longitudeQueimaInst,
      'acidentesIncidentesOcorridos': acidentesIncidentesOcorridos,
      'descricaoAcidenteIncidente': descricaoAcidenteIncidente,
      'historico': historico,
      'arquivoQtsNovo': arquivoQtsNovo,
      'alunosMatriculados': alunosMatriculados.map((a) => a.toJson()).toList(),
      'arquivos': arquivos,
    };
  }
}