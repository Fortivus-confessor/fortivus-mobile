
import 'package:image_picker/image_picker.dart';
import 'package:fortivus_app/model/resposta_modelo.dart';

abstract class ResponderBaseService {
  String get categoria;

  Future<void> salvarResposta({
    required RespostaModelo resposta,
    List<XFile>? arquivos,
    String? descricaoAvulsa,
    bool isAvulso = false,
  });

  Future<void> sincronizarRespostasRapido();
  Future<void> sincronizarRespostasPendentes();
  Future<void> sincronizarAvulsoImediato(int registroIdOriginal);

  Future<T> getResposta<T extends RespostaModelo>({
    required int registroId,
    required T Function(Map<String, dynamic>) fromJson,
    required T Function(int id) emptyFactory,
  });

  void dispose();
}