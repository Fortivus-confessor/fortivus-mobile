import 'package:fortivus_app/config/environment_config.dart';
import 'responder_multipart_service.dart';

class ResponderTerrestreService extends ResponderMultipartService {
  @override
  String get categoria => 'TERRESTRE';

  @override
  Uri getEndpointSalvar(int id) => Uri.parse(
      '${EnvironmentConfig.apiBaseUrl}/v1/operacional/despachos/finalizar-terrestre');

  @override
  Uri getEndpointBusca(int id) => Uri.parse(
      '${EnvironmentConfig.apiBaseUrl}/v1/operacional/despachos/$id/relatorio-terrestre');
}
