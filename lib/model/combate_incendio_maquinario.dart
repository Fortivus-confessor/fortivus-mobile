import 'package:fortivus_app/enums/tipo_emprego.dart';
import 'package:fortivus_app/enums/tipo_resultado_incendio.dart';
import '../enums/enums.dart';
import 'combate_incendio.dart';

class CombateIncendioMaquinario extends CombateIncendio {
  final String? horimetroInicial;
  final String? horimetroFinal;
  final DateTime? horaInicioOperacao;
  final DateTime? horaFinalOperacao;
  final TipoEmprego? tipoEmprego;
  final double? comprimentoAceiro;
  final List<String> arquivosLocais;
  final String? eventoFogoGeoJson;

  CombateIncendioMaquinario({
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
    this.horaInicioOperacao,
    this.horaFinalOperacao,
    this.tipoEmprego,
    this.comprimentoAceiro,
    this.arquivosLocais = const [],
    this.eventoFogoGeoJson,
  });

  factory CombateIncendioMaquinario.fromJson(Map<String, dynamic> json) {
    T? stringToEnum<T extends Enum>(List<T> values, String? value) {
      if (value == null) return null;
      try {
        return values.firstWhere((e) => e.name == value);
      } catch (_) {
        return null;
      }
    }

    return CombateIncendioMaquinario(
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
      horaInicioOperacao: json['horaInicioOperacao'] != null ? DateTime.tryParse(json['horaInicioOperacao']) : null,
      horaFinalOperacao: json['horaFinalOperacao'] != null ? DateTime.tryParse(json['horaFinalOperacao']) : null,
      tipoEmprego: stringToEnum(TipoEmprego.values, json['tipoEmprego']),
      comprimentoAceiro: (json['comprimentoAceiro'] as num?)?.toDouble(),
      arquivosLocais: (json['arquivos'] as List?)?.map((e) => e.toString()).toList() ?? [],
      eventoFogoGeoJson: json['eventoFogoGeoJson']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = baseToJson();
    
    String? formatarDataParaPost(DateTime? d) {
      if (d == null) return null;
      return d.toIso8601String().substring(0, 19); 
    }

    map.addAll({
      'horimetroInicial': horimetroInicial,
      'horimetroFinal': horimetroFinal,
      'horaInicioOperacao': formatarDataParaPost(horaInicioOperacao),
      'horaFinalOperacao': formatarDataParaPost(horaFinalOperacao),
      'tipoEmprego': tipoEmprego?.name,
      'comprimentoAceiro': comprimentoAceiro,
    });
    return map;
  }
}
