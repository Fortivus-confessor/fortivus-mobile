
import 'responder_multipart_service.dart';

class ResponderRondaService extends ResponderMultipartService {
  @override
  String get categoria => 'RONDA';

  @override
  Uri getEndpointSalvar(int id) =>
      Uri.parse('$baseUrl/api/ronda/mobile/salvar/$id');

  @override
  Uri getEndpointBusca(int id) =>
      Uri.parse('$baseUrl/api/ronda/mobile/$id');
}