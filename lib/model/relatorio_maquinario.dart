import 'dart:convert';
import 'package:fortivus_app/enums/enums.dart';
import 'package:fortivus_app/model/resposta_modelo.dart';

class RelatorioMaquinario implements RespostaModelo {
  final int despachoId;
  final double? horimetroInicial;
  final double? horimetroFinal;
  final String? tempoLiquido;
  final String? horaInicioOperacao;
  final String? horaFimOperacao;
  final List<String> tiposEmprego;
  final double? comprimentoAceiros;
  final String? descricaoOutroEmprego;
  final double? areaAtuacaoLat;
  final double? areaAtuacaoLng;
  final EfetividadeCombate? efetividadeCombate;
  final bool necessidadeReforco;
  final List<TipoReforco> tiposReforcoNecessarios;
  final String? historicoDescritivo;
  final ResultadoOcorrencia? resultadoOcorrencia;
  final String? outroResultadoDescricao;
  final DateTime? dataInicio;
  final DateTime? dataFim;

  const RelatorioMaquinario({
    required this.despachoId,
    this.horimetroInicial,
    this.horimetroFinal,
    this.tempoLiquido,
    this.horaInicioOperacao,
    this.horaFimOperacao,
    this.tiposEmprego = const [],
    this.comprimentoAceiros,
    this.descricaoOutroEmprego,
    this.areaAtuacaoLat,
    this.areaAtuacaoLng,
    this.efetividadeCombate,
    this.necessidadeReforco = false,
    this.tiposReforcoNecessarios = const [],
    this.historicoDescritivo,
    this.resultadoOcorrencia,
    this.outroResultadoDescricao,
    this.dataInicio,
    this.dataFim,
  });

  Map<String, dynamic> toJson() {
    return {
      'despachoId': despachoId,
      'horimetroInicial': horimetroInicial,
      'horimetroFinal': horimetroFinal,
      'tempoLiquido': tempoLiquido,
      'horaInicioOperacao': horaInicioOperacao,
      'horaFimOperacao': horaFimOperacao,
      'tiposEmprego': tiposEmprego,
      'comprimentoAceiros': comprimentoAceiros,
      'descricaoOutroEmprego': descricaoOutroEmprego,
      'areaAtuacaoLat': areaAtuacaoLat,
      'areaAtuacaoLng': areaAtuacaoLng,
      'efetividadeCombate': efetividadeCombate?.name,
      'necessidadeReforco': necessidadeReforco,
      'tiposReforcoNecessarios':
          tiposReforcoNecessarios.map((e) => e.name).toList(),
      'historicoDescritivo': historicoDescritivo,
      'resultadoOcorrencia': resultadoOcorrencia?.name,
      'outroResultadoDescricao': outroResultadoDescricao,
      'dataInicio': dataInicio?.toIso8601String(),
      'dataFim': dataFim?.toIso8601String(),
    };
  }

  factory RelatorioMaquinario.fromJson(Map<String, dynamic> json) {
    return RelatorioMaquinario(
      despachoId: json['despachoId'] as int,
      horimetroInicial: (json['horimetroInicial'] as num?)?.toDouble(),
      horimetroFinal: (json['horimetroFinal'] as num?)?.toDouble(),
      tempoLiquido: json['tempoLiquido'] as String?,
      horaInicioOperacao: json['horaInicioOperacao'] as String?,
      horaFimOperacao: json['horaFimOperacao'] as String?,
      tiposEmprego:
          (json['tiposEmprego'] as List?)?.map((e) => e as String).toList() ??
              [],
      comprimentoAceiros: (json['comprimentoAceiros'] as num?)?.toDouble(),
      descricaoOutroEmprego: json['descricaoOutroEmprego'] as String?,
      areaAtuacaoLat: (json['areaAtuacaoLat'] as num?)?.toDouble(),
      areaAtuacaoLng: (json['areaAtuacaoLng'] as num?)?.toDouble(),
      efetividadeCombate: json['efetividadeCombate'] != null
          ? EfetividadeCombate.values.firstWhere(
              (e) => e.name == json['efetividadeCombate'],
              orElse: () => EfetividadeCombate.MEDIA)
          : null,
      necessidadeReforco: json['necessidadeReforco'] as bool? ?? false,
      tiposReforcoNecessarios: (json['tiposReforcoNecessarios'] as List?)
              ?.map((e) => TipoReforco.values.firstWhere((v) => v.name == e,
                  orElse: () => TipoReforco.TERRESTRE))
              .toList() ??
          [],
      historicoDescritivo: json['historicoDescritivo'] as String?,
      resultadoOcorrencia: json['resultadoOcorrencia'] != null
          ? ResultadoOcorrencia.values.firstWhere(
              (e) => e.name == json['resultadoOcorrencia'],
              orElse: () => ResultadoOcorrencia.OUTRO)
          : null,
      outroResultadoDescricao: json['outroResultadoDescricao'] as String?,
      dataInicio:
          json['dataInicio'] != null ? DateTime.tryParse(json['dataInicio']) : null,
      dataFim: json['dataFim'] != null ? DateTime.tryParse(json['dataFim']) : null,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory RelatorioMaquinario.fromJsonString(String s) =>
      RelatorioMaquinario.fromJson(jsonDecode(s) as Map<String, dynamic>);

  RelatorioMaquinario copyWith({
    int? despachoId,
    double? horimetroInicial,
    double? horimetroFinal,
    String? tempoLiquido,
    String? horaInicioOperacao,
    String? horaFimOperacao,
    List<String>? tiposEmprego,
    double? comprimentoAceiros,
    String? descricaoOutroEmprego,
    double? areaAtuacaoLat,
    double? areaAtuacaoLng,
    EfetividadeCombate? efetividadeCombate,
    bool? necessidadeReforco,
    List<TipoReforco>? tiposReforcoNecessarios,
    String? historicoDescritivo,
    ResultadoOcorrencia? resultadoOcorrencia,
    String? outroResultadoDescricao,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) {
    return RelatorioMaquinario(
      despachoId: despachoId ?? this.despachoId,
      horimetroInicial: horimetroInicial ?? this.horimetroInicial,
      horimetroFinal: horimetroFinal ?? this.horimetroFinal,
      tempoLiquido: tempoLiquido ?? this.tempoLiquido,
      horaInicioOperacao: horaInicioOperacao ?? this.horaInicioOperacao,
      horaFimOperacao: horaFimOperacao ?? this.horaFimOperacao,
      tiposEmprego: tiposEmprego ?? this.tiposEmprego,
      comprimentoAceiros: comprimentoAceiros ?? this.comprimentoAceiros,
      descricaoOutroEmprego:
          descricaoOutroEmprego ?? this.descricaoOutroEmprego,
      areaAtuacaoLat: areaAtuacaoLat ?? this.areaAtuacaoLat,
      areaAtuacaoLng: areaAtuacaoLng ?? this.areaAtuacaoLng,
      efetividadeCombate: efetividadeCombate ?? this.efetividadeCombate,
      necessidadeReforco: necessidadeReforco ?? this.necessidadeReforco,
      tiposReforcoNecessarios:
          tiposReforcoNecessarios ?? this.tiposReforcoNecessarios,
      historicoDescritivo: historicoDescritivo ?? this.historicoDescritivo,
      resultadoOcorrencia: resultadoOcorrencia ?? this.resultadoOcorrencia,
      outroResultadoDescricao:
          outroResultadoDescricao ?? this.outroResultadoDescricao,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
    );
  }
}
