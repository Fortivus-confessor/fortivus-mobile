
import 'responder_multipart_service.dart';

class ResponderConscientizacaoService extends ResponderMultipartService {
  @override
  String get categoria => 'CONSCIENTIZACAO_EDUCACAO_AMBIENTAL';

  @override
  Uri getEndpointSalvar(int id) =>
      Uri.parse(
          '$baseUrl/api/conscientizacao_educacao/mobile/salvar/$id');

  @override
  Uri getEndpointBusca(int id) =>
      Uri.parse('$baseUrl/api/conscientizacao_educacao/mobile/$id');
}