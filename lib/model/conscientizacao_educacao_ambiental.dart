import 'package:fortivus_app/enums/tipo_acao_coscientizacao.dart';
import 'package:fortivus_app/model/resposta_modelo.dart';
import 'package:flutter/material.dart';

class ConscientizacaoEducacaoAmbiental implements RespostaModelo {
  @override
  final int id;
  final double? latitudeAreaAtuacao;
  final double? longitudeAreaAtuacao;
  final TipoAcaoConscientizacao? acaoConscientizacao;
  final String? acaoOutro;
  final DateTime? deslocamentoInicial;
  final DateTime? deslocamentoFinal;
  final int? publicoEstimado;
  final String? historico;
  final List<String> arquivosLocais;
  final DateTime? dataInicialDespachoOriginal;
  final DateTime? dataFinalDespachoOriginal;
  final TipoAcaoConscientizacao? acaoPrevistaDespachoOriginal;
  final double? latitudeDespachoOriginal;
  final double? longitudeDespachoOriginal;
  
  final bool atividadeNoLocal;

  ConscientizacaoEducacaoAmbiental({
    required this.id,
    this.latitudeAreaAtuacao,
    this.longitudeAreaAtuacao,
    this.acaoConscientizacao,
    this.acaoOutro,
    this.deslocamentoInicial,
    this.deslocamentoFinal,
    this.publicoEstimado,
    this.historico,
    this.arquivosLocais = const [],
    this.dataInicialDespachoOriginal,
    this.dataFinalDespachoOriginal,
    this.acaoPrevistaDespachoOriginal,
    this.latitudeDespachoOriginal,
    this.longitudeDespachoOriginal,
    this.atividadeNoLocal = true,
  });

  factory ConscientizacaoEducacaoAmbiental.fromJson(Map<String, dynamic> json) {
    debugPrint('🔧 [MODEL] Parseando JSON');
    debugPrint('   - Chaves: ${json.keys.toList()}');

    T? stringToEnum<T extends Enum>(List<T> values, String? value) {
      if (value == null) return null;
      try {
        return values.firstWhere((e) => e.name == value);
      } catch (_) {
        return null;
      }
    }

    final acaoStr = json['acaoDesenvolvida'];
    final acao = stringToEnum(TipoAcaoConscientizacao.values, acaoStr?.toString());
    final latitudeExecucao = json['latitudeAtuacao'] as num?;
    final longitudeExecucao = json['longitudeAtuacao'] as num?;
    final dataInicialExecucao = json['deslocamentoInicialExecucao'] != null
        ? DateTime.parse(json['deslocamentoInicialExecucao'].toString())
        : null;
    final dataFinalExecucao = json['deslocamentoFinalExecucao'] != null
        ? DateTime.parse(json['deslocamentoFinalExecucao'].toString())
        : null;
    final acaoPrevistaStr = json['acaoPrevistaDespacho'];
    final acaoPrevista =
        stringToEnum(TipoAcaoConscientizacao.values, acaoPrevistaStr?.toString());

    final latitudeDespacho = json['latitudeDespacho'] as num?;
    final longitudeDespacho = json['longitudeDespacho'] as num?;

    final dataInicialDespacho = json['deslocamentoInicialDespacho'] != null
        ? DateTime.parse(json['deslocamentoInicialDespacho'].toString())
        : null;

    final dataFinalDespacho = json['deslocamentoFinalDespacho'] != null
        ? DateTime.parse(json['deslocamentoFinalDespacho'].toString())
        : null;

    debugPrint('✅ [MODEL] Dados parseados:');
    debugPrint('   - Execução: $dataInicialExecucao → $dataFinalExecucao');
    debugPrint('   - Despacho: $dataInicialDespacho → $dataFinalDespacho');

    return ConscientizacaoEducacaoAmbiental(
      id: json['id'] as int? ?? 0,
      latitudeAreaAtuacao: latitudeExecucao?.toDouble(),
      longitudeAreaAtuacao: longitudeExecucao?.toDouble(),
      acaoConscientizacao: acao,
      acaoOutro: json['acaoOutroExecucao']?.toString(),
      deslocamentoInicial: dataInicialExecucao,
      deslocamentoFinal: dataFinalExecucao,
      publicoEstimado: json['publicoEstimado'] as int?,
      historico: json['historico']?.toString(),
      atividadeNoLocal: json['atividadeNoLocal'] as bool? ?? true,
      arquivosLocais: json['arquivos'] != null
          ? List<String>.from(json['arquivos'] as List)
          : [],
      dataInicialDespachoOriginal: dataInicialDespacho,
      dataFinalDespachoOriginal: dataFinalDespacho,
      acaoPrevistaDespachoOriginal: acaoPrevista,
      latitudeDespachoOriginal: latitudeDespacho?.toDouble(),
      longitudeDespachoOriginal: longitudeDespacho?.toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitudeAtuacao': latitudeAreaAtuacao,
      'longitudeAtuacao': longitudeAreaAtuacao,
      if (acaoConscientizacao != null) 'acaoDesenvolvida': acaoConscientizacao!.name,
      'acaoOutroExecucao': acaoOutro,
      'deslocamentoInicialExecucao': deslocamentoInicial?.toIso8601String(),
      'deslocamentoFinalExecucao': deslocamentoFinal?.toIso8601String(),
      'publicoEstimado': publicoEstimado,
      'historico': historico,
      'arquivosGerais': arquivosLocais,
    };
  }
}