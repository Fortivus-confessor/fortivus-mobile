
import 'responder_base_service.dart';
import 'responder_terrestre_service.dart';
import 'responder_aereo_service.dart';
import 'responder_maquinario_service.dart';
import 'responder_ronda_service.dart';
import 'responder_formacao_brigadista_service.dart';
import 'responder_conscientizacao_service.dart';

class ResponderServiceFactory {
  static final Map<String, ResponderBaseService> _instances = {};

  static ResponderBaseService create(String categoria) {
    if (_instances.containsKey(categoria)) {
      return _instances[categoria]!;
    }

    late ResponderBaseService service;

    switch (categoria) {
      case 'COMBATE_INCENDIO_TERRESTRE':
        service = ResponderTerrestreService();
        break;
      case 'COMBATE_INCENDIO_AEREO':
        service = ResponderAereoService();
        break;
      case 'COMBATE_INCENDIO_MAQUINARIO':
        service = ResponderMaquinarioService();
        break;
      case 'RONDA':
        service = ResponderRondaService();
        break;
      case 'CONSCIENTIZACAO_EDUCACAO_AMBIENTAL':
        service = ResponderConscientizacaoService();
        break;
      case 'FORMACAO_BRIGADISTA_FLORESTAL':
        service = ResponderFormacaoService();
        break;
      default:
        throw Exception('Categoria não suportada: $categoria');
    }

    _instances[categoria] = service;
    return service;
  }

  static void dispose(String categoria) {
    _instances[categoria]?.dispose();
    _instances.remove(categoria);
  }

  static void disposeAll() {
    for (var service in _instances.values) {
      service.dispose();
    }
    _instances.clear();
  }
}