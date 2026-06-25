import 'dart:convert';
import 'package:fortivus_app/enums/enums.dart';
import 'package:fortivus_app/model/propriedade_apoio.dart';

class RelatorioTerrestre {
  final int despachoId;
  final List<AcaoCombate> acoesRealizadas;
  final List<OrgaoApoio> orgaosApoio;
  final String? outrosOrgaosDescricao;
  final double? areaAtuacaoLat;
  final double? areaAtuacaoLng;
  final bool houveUsoAgua;
  final int? volumeAguaLitros;
  final List<OrigemAgua> origensAgua;
  final String? outraOrigemAguaDescricao;
  final bool houveApoioPropriedades;
  final bool houveRecusaPropriedades;
  final List<PropriedadeApoio> propriedades;
  final OrigemIncendio? possivelOrigemIncendio;
  final String? outraOrigemDescricao;
  final EfetividadeCombate? efetividadeCombate;
  final bool necessidadeReforco;
  final List<TipoReforco> tiposReforcoNecessarios;
  final String? historicoDescritivo;
  final ResultadoOcorrencia? resultadoOcorrencia;
  final String? outroResultadoDescricao;
  final DateTime? dataInicio;
  final DateTime? dataFim;

  const RelatorioTerrestre({
    required this.despachoId,
    this.acoesRealizadas = const [],
    this.orgaosApoio = const [],
    this.outrosOrgaosDescricao,
    this.areaAtuacaoLat,
    this.areaAtuacaoLng,
    this.houveUsoAgua = false,
    this.volumeAguaLitros,
    this.origensAgua = const [],
    this.outraOrigemAguaDescricao,
    this.houveApoioPropriedades = false,
    this.houveRecusaPropriedades = false,
    this.propriedades = const [],
    this.possivelOrigemIncendio,
    this.outraOrigemDescricao,
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
      'acoesRealizadas': acoesRealizadas.map((e) => e.name).toList(),
      'orgaosApoio': orgaosApoio.map((e) => e.name).toList(),
      'outrosOrgaosDescricao': outrosOrgaosDescricao,
      'areaAtuacaoLat': areaAtuacaoLat,
      'areaAtuacaoLng': areaAtuacaoLng,
      'houveUsoAgua': houveUsoAgua,
      'volumeAguaLitros': volumeAguaLitros,
      'origensAgua': origensAgua.map((e) => e.name).toList(),
      'outraOrigemAguaDescricao': outraOrigemAguaDescricao,
      'houveApoioPropriedades': houveApoioPropriedades,
      'houveRecusaPropriedades': houveRecusaPropriedades,
      'propriedades': propriedades.map((e) => e.toJson()).toList(),
      'possivelOrigemIncendio': possivelOrigemIncendio?.name,
      'outraOrigemDescricao': outraOrigemDescricao,
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

  factory RelatorioTerrestre.fromJson(Map<String, dynamic> json) {
    List<AcaoCombate> parseAcoes(dynamic list) {
      if (list == null) return [];
      return (list as List)
          .map((e) => AcaoCombate.values
              .firstWhere((v) => v.name == e, orElse: () => AcaoCombate.NENHUMA))
          .toList();
    }

    List<OrgaoApoio> parseOrgaos(dynamic list) {
      if (list == null) return [];
      return (list as List)
          .map((e) => OrgaoApoio.values
              .firstWhere((v) => v.name == e, orElse: () => OrgaoApoio.NENHUM))
          .toList();
    }

    List<OrigemAgua> parseOrigens(dynamic list) {
      if (list == null) return [];
      return (list as List)
          .map((e) => OrigemAgua.values
              .firstWhere((v) => v.name == e, orElse: () => OrigemAgua.OUTRO))
          .toList();
    }

    List<TipoReforco> parseReforcos(dynamic list) {
      if (list == null) return [];
      return (list as List)
          .map((e) => TipoReforco.values.firstWhere((v) => v.name == e,
              orElse: () => TipoReforco.TERRESTRE))
          .toList();
    }

    return RelatorioTerrestre(
      despachoId: json['despachoId'] as int,
      acoesRealizadas: parseAcoes(json['acoesRealizadas']),
      orgaosApoio: parseOrgaos(json['orgaosApoio']),
      outrosOrgaosDescricao: json['outrosOrgaosDescricao'] as String?,
      areaAtuacaoLat: (json['areaAtuacaoLat'] as num?)?.toDouble(),
      areaAtuacaoLng: (json['areaAtuacaoLng'] as num?)?.toDouble(),
      houveUsoAgua: json['houveUsoAgua'] as bool? ?? false,
      volumeAguaLitros: json['volumeAguaLitros'] as int?,
      origensAgua: parseOrigens(json['origensAgua']),
      outraOrigemAguaDescricao: json['outraOrigemAguaDescricao'] as String?,
      houveApoioPropriedades: json['houveApoioPropriedades'] as bool? ?? false,
      houveRecusaPropriedades: json['houveRecusaPropriedades'] as bool? ?? false,
      propriedades: (json['propriedades'] as List?)
              ?.map((e) =>
                  PropriedadeApoio.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      possivelOrigemIncendio: json['possivelOrigemIncendio'] != null
          ? OrigemIncendio.values.firstWhere(
              (e) => e.name == json['possivelOrigemIncendio'],
              orElse: () => OrigemIncendio.SEM_INDICIOS)
          : null,
      outraOrigemDescricao: json['outraOrigemDescricao'] as String?,
      efetividadeCombate: json['efetividadeCombate'] != null
          ? EfetividadeCombate.values.firstWhere(
              (e) => e.name == json['efetividadeCombate'],
              orElse: () => EfetividadeCombate.MEDIA)
          : null,
      necessidadeReforco: json['necessidadeReforco'] as bool? ?? false,
      tiposReforcoNecessarios: parseReforcos(json['tiposReforcoNecessarios']),
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

  factory RelatorioTerrestre.fromJsonString(String s) =>
      RelatorioTerrestre.fromJson(jsonDecode(s) as Map<String, dynamic>);

  RelatorioTerrestre copyWith({
    int? despachoId,
    List<AcaoCombate>? acoesRealizadas,
    List<OrgaoApoio>? orgaosApoio,
    String? outrosOrgaosDescricao,
    double? areaAtuacaoLat,
    double? areaAtuacaoLng,
    bool? houveUsoAgua,
    int? volumeAguaLitros,
    List<OrigemAgua>? origensAgua,
    String? outraOrigemAguaDescricao,
    bool? houveApoioPropriedades,
    bool? houveRecusaPropriedades,
    List<PropriedadeApoio>? propriedades,
    OrigemIncendio? possivelOrigemIncendio,
    String? outraOrigemDescricao,
    EfetividadeCombate? efetividadeCombate,
    bool? necessidadeReforco,
    List<TipoReforco>? tiposReforcoNecessarios,
    String? historicoDescritivo,
    ResultadoOcorrencia? resultadoOcorrencia,
    String? outroResultadoDescricao,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) {
    return RelatorioTerrestre(
      despachoId: despachoId ?? this.despachoId,
      acoesRealizadas: acoesRealizadas ?? this.acoesRealizadas,
      orgaosApoio: orgaosApoio ?? this.orgaosApoio,
      outrosOrgaosDescricao:
          outrosOrgaosDescricao ?? this.outrosOrgaosDescricao,
      areaAtuacaoLat: areaAtuacaoLat ?? this.areaAtuacaoLat,
      areaAtuacaoLng: areaAtuacaoLng ?? this.areaAtuacaoLng,
      houveUsoAgua: houveUsoAgua ?? this.houveUsoAgua,
      volumeAguaLitros: volumeAguaLitros ?? this.volumeAguaLitros,
      origensAgua: origensAgua ?? this.origensAgua,
      outraOrigemAguaDescricao:
          outraOrigemAguaDescricao ?? this.outraOrigemAguaDescricao,
      houveApoioPropriedades:
          houveApoioPropriedades ?? this.houveApoioPropriedades,
      houveRecusaPropriedades:
          houveRecusaPropriedades ?? this.houveRecusaPropriedades,
      propriedades: propriedades ?? this.propriedades,
      possivelOrigemIncendio:
          possivelOrigemIncendio ?? this.possivelOrigemIncendio,
      outraOrigemDescricao: outraOrigemDescricao ?? this.outraOrigemDescricao,
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
