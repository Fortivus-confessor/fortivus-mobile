import 'dart:convert';
import 'package:fortivus_app/enums/enums.dart';

class RelatorioAereo {
  final int despachoId;
  final double? horimetroInicial;
  final double? horimetroFinal;
  final String? horasLiquidas;
  final List<String> tiposEmprego;
  final double? areaAtuacaoLat;
  final double? areaAtuacaoLng;
  final int? qtdeLancamentos;
  final bool houveUsoAgua;
  final int? volumeAguaLitros;
  final List<String> origensAgua;
  final String? outraOrigemAguaDescricao;
  final EfetividadeCombate? efetividadeCombate;
  final bool necessidadeReforco;
  final List<TipoReforco> tiposReforcoNecessarios;
  final String? historicoDescritivo;
  final ResultadoOcorrencia? resultadoOcorrencia;
  final String? outroResultadoDescricao;
  final DateTime? dataInicio;
  final DateTime? dataFim;

  const RelatorioAereo({
    required this.despachoId,
    this.horimetroInicial,
    this.horimetroFinal,
    this.horasLiquidas,
    this.tiposEmprego = const [],
    this.areaAtuacaoLat,
    this.areaAtuacaoLng,
    this.qtdeLancamentos,
    this.houveUsoAgua = false,
    this.volumeAguaLitros,
    this.origensAgua = const [],
    this.outraOrigemAguaDescricao,
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
      'horasLiquidas': horasLiquidas,
      'tiposEmprego': tiposEmprego,
      'areaAtuacaoLat': areaAtuacaoLat,
      'areaAtuacaoLng': areaAtuacaoLng,
      'qtdeLancamentos': qtdeLancamentos,
      'houveUsoAgua': houveUsoAgua,
      'volumeAguaLitros': volumeAguaLitros,
      'origensAgua': origensAgua,
      'outraOrigemAguaDescricao': outraOrigemAguaDescricao,
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

  factory RelatorioAereo.fromJson(Map<String, dynamic> json) {
    return RelatorioAereo(
      despachoId: json['despachoId'] as int,
      horimetroInicial: (json['horimetroInicial'] as num?)?.toDouble(),
      horimetroFinal: (json['horimetroFinal'] as num?)?.toDouble(),
      horasLiquidas: json['horasLiquidas'] as String?,
      tiposEmprego:
          (json['tiposEmprego'] as List?)?.map((e) => e as String).toList() ??
              [],
      areaAtuacaoLat: (json['areaAtuacaoLat'] as num?)?.toDouble(),
      areaAtuacaoLng: (json['areaAtuacaoLng'] as num?)?.toDouble(),
      qtdeLancamentos: json['qtdeLancamentos'] as int?,
      houveUsoAgua: json['houveUsoAgua'] as bool? ?? false,
      volumeAguaLitros: json['volumeAguaLitros'] as int?,
      origensAgua:
          (json['origensAgua'] as List?)?.map((e) => e as String).toList() ??
              [],
      outraOrigemAguaDescricao: json['outraOrigemAguaDescricao'] as String?,
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

  factory RelatorioAereo.fromJsonString(String s) =>
      RelatorioAereo.fromJson(jsonDecode(s) as Map<String, dynamic>);

  RelatorioAereo copyWith({
    int? despachoId,
    double? horimetroInicial,
    double? horimetroFinal,
    String? horasLiquidas,
    List<String>? tiposEmprego,
    double? areaAtuacaoLat,
    double? areaAtuacaoLng,
    int? qtdeLancamentos,
    bool? houveUsoAgua,
    int? volumeAguaLitros,
    List<String>? origensAgua,
    String? outraOrigemAguaDescricao,
    EfetividadeCombate? efetividadeCombate,
    bool? necessidadeReforco,
    List<TipoReforco>? tiposReforcoNecessarios,
    String? historicoDescritivo,
    ResultadoOcorrencia? resultadoOcorrencia,
    String? outroResultadoDescricao,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) {
    return RelatorioAereo(
      despachoId: despachoId ?? this.despachoId,
      horimetroInicial: horimetroInicial ?? this.horimetroInicial,
      horimetroFinal: horimetroFinal ?? this.horimetroFinal,
      horasLiquidas: horasLiquidas ?? this.horasLiquidas,
      tiposEmprego: tiposEmprego ?? this.tiposEmprego,
      areaAtuacaoLat: areaAtuacaoLat ?? this.areaAtuacaoLat,
      areaAtuacaoLng: areaAtuacaoLng ?? this.areaAtuacaoLng,
      qtdeLancamentos: qtdeLancamentos ?? this.qtdeLancamentos,
      houveUsoAgua: houveUsoAgua ?? this.houveUsoAgua,
      volumeAguaLitros: volumeAguaLitros ?? this.volumeAguaLitros,
      origensAgua: origensAgua ?? this.origensAgua,
      outraOrigemAguaDescricao:
          outraOrigemAguaDescricao ?? this.outraOrigemAguaDescricao,
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
