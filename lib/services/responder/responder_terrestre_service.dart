import 'package:image_picker/image_picker.dart'; 
import 'package:fortivus_app/model/combate_incendio_terrestre.dart'; 
import 'package:fortivus_app/model/resposta_modelo.dart'; 
import 'package:fortivus_app/services/responder/responder_multipart_service.dart';

class ResponderTerrestreService extends ResponderMultipartService {
  @override
  String get categoria => 'COMBATE_INCENDIO_TERRESTRE';

  @override
  Uri getEndpointSalvar(int id) =>
      Uri.parse('$baseUrl/api/combate-incendio/terrestre/mobile/salvar/$id');

  @override
  Uri getEndpointBusca(int id) =>
      Uri.parse('$baseUrl/api/combate-incendio/mobile/$id');

  @override
  String obterNomeArquivoEspecifico() {
    return 'imagemOrigem'; 
  }

  @override
  XFile? obterArquivoEspecifico(RespostaModelo resposta) {
    if (resposta is CombateIncendioTerrestre) {
      return resposta.imagemOrigemXFile;
    }
    return null;
  }
}
