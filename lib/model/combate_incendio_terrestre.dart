import 'package:fortivus_app/enums/tipo_resultado_incendio_terrestre.dart';
import 'package:image_picker/image_picker.dart';
import '../enums/enums.dart';
import 'combate_incendio.dart';
import 'propriedade_apoio.dart';

class CombateIncendioTerrestre extends CombateIncendio {
  int? quilometragem;
  List<TipoAcaoCombate> tipoAcaoCombateIncendio;
  List<TipoApoioOrgao> tipoApoioOrgao;
  String? tipoApoioOutro;
  List<TipoMaterialUtilizado> tipoMateriaisUtilizados;
  bool? houveApoioPropriedadesRurais;
  bool? houveRecusaColaboracao;
  int? quantidadeLitrosAgua;
  List<OrigemAgua> origemAgua;
  TipoCausaIncendio? origemIncendio;
  String? imagemOrigemIncendio;
  final XFile? imagemOrigemXFile;
  List<PropriedadeApoio> propriedadesApoio;
  List<String> arquivosLocais;
  final String? eventoFogoGeoJson;

  CombateIncendioTerrestre({
    required super.id,
    super.latitudeAreaAtuacao,
    super.longitudeAreaAtuacao,
    super.efetividadeCombate,
    super.reforco,
    super.horarioChegada,
    super.historicoDescritivo,
    
    super.tipoResultado,
    super.resultadoOcorrencia,

    this.quilometragem,
    this.tipoAcaoCombateIncendio = const [],
    this.tipoApoioOrgao = const [],
    this.tipoApoioOutro,
    this.tipoMateriaisUtilizados = const [],
    this.houveApoioPropriedadesRurais,
    this.houveRecusaColaboracao,
    this.quantidadeLitrosAgua,
    this.origemAgua = const [],
    this.origemIncendio,
    this.imagemOrigemIncendio,
    this.imagemOrigemXFile,
    this.propriedadesApoio = const [],
    this.arquivosLocais = const [],
    this.eventoFogoGeoJson,
  });

  factory CombateIncendioTerrestre.fromJson(Map<String, dynamic> json) {
    T? stringToEnum<T>(List<T> values, dynamic value) {
      if (value == null) return null;
      try {
        return values.firstWhere((e) => e.toString().split('.').last == value.toString());
      } catch (_) {
        return null;
      }
    }

    List<T> parseEnumList<T>(List<T> values, dynamic jsonList) {
      if (jsonList == null || jsonList is! List) return [];
      return jsonList
          .map((e) => stringToEnum(values, e))
          .whereType<T>()
          .toList();
    }

    return CombateIncendioTerrestre(
      id: json['id'] as int? ?? 0,
      latitudeAreaAtuacao: (json['latitudeAreaAtuacao'] as num?)?.toDouble(),
      longitudeAreaAtuacao: (json['longitudeAreaAtuacao'] as num?)?.toDouble(),
      efetividadeCombate: stringToEnum(TipoEfetividadeCombate.values, json['efetividadeCombate']),
      reforco: stringToEnum(Reforco.values, json['reforco']),
      horarioChegada: json['horarioChegada'] != null ? DateTime.tryParse(json['horarioChegada']) : null,
      historicoDescritivo: json['historicoDescritivo'],
      tipoResultado: stringToEnum(TipoResultadoIncendioTerrestre.values, json['tipoResultado']),
      resultadoOcorrencia: json['resultadoOcorrencia'],
      quilometragem: (json['quilometragem'] as num?)?.toInt(),
      tipoApoioOutro: json['tipoApoioOutro'],
      houveApoioPropriedadesRurais: json['houveApoioPropriedadesRurais'],
      houveRecusaColaboracao: json['houveRecusaColaboracao'],
      quantidadeLitrosAgua: (json['quantidadeLitrosAgua'] as num?)?.toInt(),
      imagemOrigemIncendio: json['imagemOrigemIncendio'],
      tipoAcaoCombateIncendio: parseEnumList(TipoAcaoCombate.values, json['tipoAcaoCombateIncendio']),
      tipoApoioOrgao: parseEnumList(TipoApoioOrgao.values, json['tipoApoioOrgao']),
      tipoMateriaisUtilizados: parseEnumList(TipoMaterialUtilizado.values, json['tipoMateriaisUtilizados']),
      origemAgua: parseEnumList(OrigemAgua.values, json['origemAgua']),
      origemIncendio: stringToEnum(TipoCausaIncendio.values, json['origemIncendio']),
      propriedadesApoio: (json['propriedadesApoio'] as List?)
              ?.map((e) => PropriedadeApoio.fromJson(e))
              .toList() ?? [],
      arquivosLocais: (json['arquivos'] as List?)?.map((e) => e.toString()).toList() ?? [],
      eventoFogoGeoJson: json['eventoFogoGeoJson']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = baseToJson();
    String? formatarDataParaPost(DateTime? d) {
      if (d == null) return null;
      return d.toIso8601String().substring(0, 16); 
    }
    map['horarioChegada'] = formatarDataParaPost(horarioChegada);
    map.addAll({
      'quilometragem': quilometragem,
      'tipoAcaoCombateIncendio': tipoAcaoCombateIncendio.map((e) => e.name).toList(),
      'tipoApoioOrgao': tipoApoioOrgao.map((e) => e.name).toList(),
      'tipoApoioOutro': tipoApoioOutro,
      'tipoMateriaisUtilizados': tipoMateriaisUtilizados.map((e) => e.name).toList(),
      'houveApoioPropriedadesRurais': houveApoioPropriedadesRurais,
      'houveRecusaColaboracao': houveRecusaColaboracao,
      'quantidadeLitrosAgua': quantidadeLitrosAgua,
      'origemAgua': origemAgua.map((e) => e.name).toList(),
      'origemIncendio': origemIncendio?.name,
      'imagemOrigemIncendio': imagemOrigemIncendio,
      'propriedades': propriedadesApoio.map((e) => e.toJson()).toList(),
      'arquivosParaRemover': null,
    });
    return map;
  }
}
