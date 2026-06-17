import 'package:fortivus_app/model/resposta_modelo.dart';

import '../enums/tipo_acao_ronda.dart';
import '../enums/tipo_assuntos_abordados.dart';

class Ronda implements RespostaModelo {
  @override
  final int id;
  final double? latitudeAreaAtuacao;
  final double? longitudeAreaAtuacao;
  final List<TipoAcaoRonda>? acaoRonda;
  final String? acaoRondaOutro;
  final List<TipoAssuntosAbordados>? assuntosAbordados;
  final int? quantidadePessoasAtingidas;
  final String? eventoFogoGeoJson;
  final List<String> arquivosLocais;

  Ronda({
    required this.id,
    this.latitudeAreaAtuacao,
    this.longitudeAreaAtuacao,
    this.acaoRonda,
    this.acaoRondaOutro,
    this.assuntosAbordados,
    this.quantidadePessoasAtingidas,
    this.eventoFogoGeoJson,
    this.arquivosLocais = const [],
  });

  factory Ronda.fromJson(Map<String, dynamic> json) {
    T? stringToEnum<T extends Enum>(List<T> values, String? value) {
      if (value == null) return null;
      try {
        return values.firstWhere((e) => e.name == value);
      } catch (_) {
        return null;
      }
    }

    List<T>? listStringToEnumList<T extends Enum>(
        List<T> values, List<dynamic>? jsonList) {
      if (jsonList == null) return null;
      return jsonList
          .map((e) => stringToEnum(values, e.toString()))
          .where((e) => e != null)
          .cast<T>()
          .toList();
    }

    return Ronda(
      id: json['id'] as int? ?? 0,
      latitudeAreaAtuacao: (json['latitudeAreaAtuacao'] as num?)?.toDouble(),
      longitudeAreaAtuacao: (json['longitudeAreaAtuacao'] as num?)?.toDouble(),
      acaoRonda: listStringToEnumList(TipoAcaoRonda.values, json['acaoRonda']),
      acaoRondaOutro: json['acaoRondaOutro']?.toString(),
      assuntosAbordados: listStringToEnumList(
          TipoAssuntosAbordados.values, json['assuntosAbordados']),
      quantidadePessoasAtingidas: json['quantidadePessoasAtingidas'] as int?,
      eventoFogoGeoJson: json['eventoFogoGeoJson']?.toString(),
      arquivosLocais: json['arquivosLocais'] != null
          ? List<String>.from(json['arquivosLocais'] as List)
          : [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    map['id'] = id;
    map['latitudeAreaAtuacao'] = latitudeAreaAtuacao;
    map['longitudeAreaAtuacao'] = longitudeAreaAtuacao;

    if (acaoRonda != null) {
      map['acaoRonda'] = acaoRonda!.map((e) => e.name).toList();
    }

    map['acaoRondaOutro'] = acaoRondaOutro;

    if (assuntosAbordados != null) {
      map['assuntosAbordados'] = assuntosAbordados!.map((e) => e.name).toList();
    }

    map['quantidadePessoasAtingidas'] = quantidadePessoasAtingidas;
    map['arquivosLocais'] = arquivosLocais;

    return map;
  }
}
