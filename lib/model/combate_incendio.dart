import 'package:fortivus_app/model/resposta_modelo.dart';
import '../enums/enums.dart';

abstract class CombateIncendio implements RespostaModelo {
  @override 
  final int id;
  
  double? latitudeAreaAtuacao;
  double? longitudeAreaAtuacao;
  TipoEfetividadeCombate? efetividadeCombate;
  Reforco? reforco;
  DateTime? horarioChegada;
  String? historicoDescritivo;
  dynamic tipoResultado;
  String? resultadoOcorrencia;

  CombateIncendio({
    required this.id,
    this.latitudeAreaAtuacao,
    this.longitudeAreaAtuacao,
    this.efetividadeCombate,
    this.reforco,
    this.horarioChegada,
    this.historicoDescritivo,
    this.tipoResultado,
    this.resultadoOcorrencia,
  });

  Map<String, dynamic> baseToJson() {
    return {
      'id': id,
      'latitudeAreaAtuacao': latitudeAreaAtuacao,
      'longitudeAreaAtuacao': longitudeAreaAtuacao,
      'efetividadeCombate': efetividadeCombate?.toString().split('.').last,
      'reforco': reforco?.toString().split('.').last,
      'horarioChegada': horarioChegada?.toIso8601String(),
      'historicoDescritivo': historicoDescritivo,
      'tipoResultado': tipoResultado?.toString().split('.').last,
      'resultadoOcorrencia': resultadoOcorrencia,
    };
  }
}
