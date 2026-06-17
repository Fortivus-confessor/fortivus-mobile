import '../enums/enums.dart';

class PropriedadeApoio {
  String? id;

  String? nomeProprietario;
  String? nomePropriedade;
  double? latitude;
  double? longitude;
  String? contato;
  
  TipoInteracaoPropriedade? tipoInteracao;
  int? quantidadeMaquinario;
  int? quantidadeMaoObra;
  String? apoioOutro;
  
  TipoMotivoRecusa? motivoRecusa;
  String? motivoOutro;

  PropriedadeApoio({
    this.id,
    this.nomeProprietario,
    this.nomePropriedade,
    this.latitude,
    this.longitude,
    this.contato,
    this.tipoInteracao,
    this.quantidadeMaquinario,
    this.quantidadeMaoObra,
    this.apoioOutro,
    this.motivoRecusa,
    this.motivoOutro,
  });

  factory PropriedadeApoio.fromJson(Map<String, dynamic> json) {
    T? stringToEnum<T>(List<T> values, String? value) {
      if (value == null) return null;
      try { return values.firstWhere((e) => e.toString().split('.').last == value); } catch (_) { return null; }
    }

    return PropriedadeApoio(
      id: json['id']?.toString(),
      nomeProprietario: json['responsavel'] ?? json['nomeProprietario'],
      nomePropriedade: json['nomePropriedade'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      contato: json['telefone'] ?? json['contato'],
      
      tipoInteracao: stringToEnum(TipoInteracaoPropriedade.values, json['tipoInteracao']),
      quantidadeMaquinario: (json['quantidadeMaquinario'] as num?)?.toInt(),
      quantidadeMaoObra: (json['quantidadeMaoObra'] as num?)?.toInt(),
      apoioOutro: json['apoioOutro'],
      motivoRecusa: stringToEnum(TipoMotivoRecusa.values, json['motivoRecusa']),
      motivoOutro: json['motivoOutro'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'responsavel': nomeProprietario,
      'nomePropriedade': nomePropriedade,
      'latitude': latitude,
      'longitude': longitude,
      'telefone': contato,
      
      'tipoInteracao': tipoInteracao?.name,
      'quantidadeMaquinario': quantidadeMaquinario,
      'quantidadeMaoObra': quantidadeMaoObra,
      'apoioOutro': apoioOutro,
      'motivoRecusa': motivoRecusa?.name,
      'motivoOutro': motivoOutro,
    };
  }
}
