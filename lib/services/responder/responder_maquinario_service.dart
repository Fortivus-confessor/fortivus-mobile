
import 'responder_multipart_service.dart';

class ResponderMaquinarioService extends ResponderMultipartService {
  @override
  String get categoria => 'COMBATE_INCENDIO_MAQUINARIO';

  @override
  Uri getEndpointSalvar(int id) =>
      Uri.parse(
          '$baseUrl/api/combate-incendio/maquinario/mobile/salvar/$id');

  @override
  Uri getEndpointBusca(int id) =>
      Uri.parse('$baseUrl/api/combate-incendio/mobile/$id');
}