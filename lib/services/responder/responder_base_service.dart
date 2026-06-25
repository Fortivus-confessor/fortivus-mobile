import 'package:fortivus_app/model/resposta_modelo.dart';

abstract class ResponderBaseService {
  String get categoria;

  Future<void> salvarResposta({
    required RespostaModelo resposta,
  });

  Future<void> sincronizarRespostasRapido();
  Future<void> sincronizarRespostasPendentes();

  Future<T> getResposta<T extends RespostaModelo>({
    required int despachoId,
    required T Function(Map<String, dynamic>) fromJson,
    required T Function(int id) emptyFactory,
  });

  void dispose();
}
