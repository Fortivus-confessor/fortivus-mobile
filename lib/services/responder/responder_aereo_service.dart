
import 'package:fortivus_app/services/responder/responder_multipart_service.dart';

class ResponderAereoService extends ResponderMultipartService {
  @override
  String get categoria => 'COMBATE_INCENDIO_AEREO';

  @override
  Uri getEndpointSalvar(int id) =>
      Uri.parse(
          '$baseUrl/api/combate-incendio/aereo/mobile/salvar/$id');

  @override
  Uri getEndpointBusca(int id) =>
      Uri.parse('$baseUrl/api/combate-incendio/mobile/$id');
}