import 'package:fortivus_app/config/environment_config.dart';
import 'responder_multipart_service.dart';

class ResponderAereoService extends ResponderMultipartService {
  @override
  String get categoria => 'AEREO';

  @override
  Uri getEndpointSalvar(int id) => Uri.parse(
      '${EnvironmentConfig.apiBaseUrl}/v1/operacional/despachos/finalizar-aereo');

  @override
  Uri getEndpointBusca(int id) => Uri.parse(
      '${EnvironmentConfig.apiBaseUrl}/v1/operacional/despachos/$id/relatorio-aereo');
}
