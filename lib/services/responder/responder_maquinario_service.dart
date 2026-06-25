import 'package:fortivus_app/config/environment_config.dart';
import 'responder_multipart_service.dart';

class ResponderMaquinarioService extends ResponderMultipartService {
  @override
  String get categoria => 'MAQUINARIO';

  @override
  Uri getEndpointSalvar(int id) => Uri.parse(
      '${EnvironmentConfig.apiBaseUrl}/v1/operacional/despachos/finalizar-maquinario');

  @override
  Uri getEndpointBusca(int id) => Uri.parse(
      '${EnvironmentConfig.apiBaseUrl}/v1/operacional/despachos/$id/relatorio-maquinario');
}
