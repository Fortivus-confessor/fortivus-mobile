import 'package:fortivus_app/enums/enums.dart';

class PropriedadeApoio {
  final String? id;
  final String? nomePropriedade;
  final String? responsavel;
  final String? telefone;
  final double? latitude;
  final double? longitude;
  final TipoRegistro tipoRegistro;
  final TipoApoio? tipoApoio;
  final int? quantidadeApoio;
  final String? descricaoApoioOutro;
  final MotivoRecusa? motivoRecusa;
  final String? descricaoRecusaOutro;

  const PropriedadeApoio({
    this.id,
    this.nomePropriedade,
    this.responsavel,
    this.telefone,
    this.latitude,
    this.longitude,
    required this.tipoRegistro,
    this.tipoApoio,
    this.quantidadeApoio,
    this.descricaoApoioOutro,
    this.motivoRecusa,
    this.descricaoRecusaOutro,
  });

  factory PropriedadeApoio.fromJson(Map<String, dynamic> json) {
    return PropriedadeApoio(
      id: json['id'] as String?,
      nomePropriedade: json['nomePropriedade'] as String?,
      responsavel: json['responsavel'] as String?,
      telefone: json['telefone'] as String?,
      latitude: (json['localizacaoLat'] as num?)?.toDouble(),
      longitude: (json['localizacaoLng'] as num?)?.toDouble(),
      tipoRegistro: TipoRegistro.values.firstWhere(
        (e) => e.name == json['tipoRegistro'],
        orElse: () => TipoRegistro.APOIO,
      ),
      tipoApoio: json['tipoApoio'] != null
          ? TipoApoio.values.firstWhere(
              (e) => e.name == json['tipoApoio'],
              orElse: () => TipoApoio.OUTRO,
            )
          : null,
      quantidadeApoio: json['quantidadeApoio'] as int?,
      descricaoApoioOutro: json['descricaoApoioOutro'] as String?,
      motivoRecusa: json['motivoRecusa'] != null
          ? MotivoRecusa.values.firstWhere(
              (e) => e.name == json['motivoRecusa'],
              orElse: () => MotivoRecusa.OUTRO,
            )
          : null,
      descricaoRecusaOutro: json['descricaoRecusaOutro'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nomePropriedade': nomePropriedade,
      'responsavel': responsavel,
      'telefone': telefone,
      'localizacaoLat': latitude,
      'localizacaoLng': longitude,
      'tipoRegistro': tipoRegistro.name,
      if (tipoApoio != null) 'tipoApoio': tipoApoio!.name,
      'quantidadeApoio': quantidadeApoio,
      'descricaoApoioOutro': descricaoApoioOutro,
      if (motivoRecusa != null) 'motivoRecusa': motivoRecusa!.name,
      'descricaoRecusaOutro': descricaoRecusaOutro,
    };
  }
}
