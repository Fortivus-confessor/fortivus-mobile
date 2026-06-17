import 'package:fortivus_app/enums/tipo_emprego.dart';
import 'package:fortivus_app/enums/tipo_resultado_incendio.dart';

import '../enums/enums.dart';
import 'combate_incendio.dart';

class CombateIncendioAereo extends CombateIncendio {
  final String? horimetroInicial;
  final String? horimetroFinal;
  final int? tempoOperacaoMinutos;
  final TipoEmprego? tipoEmprego;
  final int? quantidadeLitrosAgua;
  final List<String>? origemAgua;
  final int? quantidadeAlijamento;
  final String? eventoFogoGeoJson;
  final List<String> arquivosLocais;

  CombateIncendioAereo({
    required super.id,
    super.latitudeAreaAtuacao,
    super.longitudeAreaAtuacao,
    super.efetividadeCombate,
    super.reforco,
    super.horarioChegada,
    super.historicoDescritivo,
    super.tipoResultado,
    super.resultadoOcorrencia,
    
    this.horimetroInicial,
    this.horimetroFinal,
    this.tempoOperacaoMinutos,
    this.tipoEmprego,
    this.quantidadeLitrosAgua,
    this.origemAgua,
    this.quantidadeAlijamento,
    this.eventoFogoGeoJson,
    this.arquivosLocais = const [],
  });

  factory CombateIncendioAereo.fromJson(Map<String, dynamic> json) {
    T? stringToEnum<T extends Enum>(List<T> values, String? value) {
      if (value == null) return null;
      try {
        return values.firstWhere((e) => e.name == value);
      } catch (_) {
        return null;
      }
    }

    List<String>? parseOrigemAgua(dynamic value) {
      if (value == null) return null;
      
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      } 
      
      if (value is String) {
        if (value.isEmpty) return [];
        return value.split(',').map((e) => e.trim()).toList();
      }
      
      return null;
    }

    return CombateIncendioAereo(
      id: json['id'] as int? ?? 0,
      latitudeAreaAtuacao: (json['latitudeAreaAtuacao'] as num?)?.toDouble(),
      longitudeAreaAtuacao: (json['longitudeAreaAtuacao'] as num?)?.toDouble(),
      efetividadeCombate: stringToEnum(TipoEfetividadeCombate.values, json['efetividadeCombate']),
      reforco: stringToEnum(Reforco.values, json['reforco']),
      horarioChegada: json['horarioChegada'] != null ? DateTime.tryParse(json['horarioChegada']) : null,
      historicoDescritivo: json['historicoDescritivo'],
      tipoResultado: stringToEnum(TipoResultadoIncendio.values, json['tipoResultado']),
      resultadoOcorrencia: json['resultadoOcorrencia'],
      horimetroInicial: json['horimetroInicial']?.toString(),
      horimetroFinal: json['horimetroFinal']?.toString(),
      
      tempoOperacaoMinutos: (json['tempoOperacaoMinutos'] as num?)?.toInt(),
      tipoEmprego: stringToEnum(TipoEmprego.values, json['tipoEmprego']),
      quantidadeLitrosAgua: (json['quantidadeLitrosAgua'] as num?)?.toInt(),
      origemAgua: parseOrigemAgua(json['origemAgua']),
      quantidadeAlijamento: (json['quantidadeAlijamento'] as num?)?.toInt(),
      eventoFogoGeoJson: json['eventoFogoGeoJson']?.toString(),
      arquivosLocais: (json['arquivos'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = baseToJson();
    
    // Formato: yyyy-MM-ddTHH:mm:ss (Padrão ISO seguro para Java)
    String? formatarDataParaPost(DateTime? d) {
      if (d == null) return null;
      // Pega "2026-01-29T14:57:00.000" e corta para "2026-01-29T14:57:00"
      return d.toIso8601String().substring(0, 19); 
    }

    map.addAll({
      'horimetroInicial': horimetroInicial,
      'horimetroFinal': horimetroFinal,
      'tempoOperacaoMinutos': tempoOperacaoMinutos,
      'horarioChegada': formatarDataParaPost(horarioChegada),
      'tipoEmprego': tipoEmprego?.name,
      'quantidadeLitrosAgua': quantidadeLitrosAgua,
      'origemAgua': origemAgua,
      'quantidadeAlijamento': quantidadeAlijamento,
    });
    return map;
  }
}
