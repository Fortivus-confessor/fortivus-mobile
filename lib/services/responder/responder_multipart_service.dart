import 'dart:convert';
import 'package:fortivus_app/services/auth_service.dart';
import 'package:fortivus_app/services/local_db_service.dart';
import 'package:fortivus_app/util/auth_http_helper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:fortivus_app/model/resposta_modelo.dart';
import 'responder_base_service.dart';
import 'shared/responder_shared_helper.dart';

abstract class ResponderMultipartService implements ResponderBaseService {
  final AuthService authService = AuthService();
  final Set<int> _respostasEmProcessamento = {};
  bool _isSincronizando = false;

  Uri getEndpointSalvar(int id);
  Uri getEndpointBusca(int id);

  @override
  String get categoria;

  @override
  Future<void> salvarResposta({
    required RespostaModelo resposta,
  }) async {
    final int id = resposta.despachoId;
    if (_respostasEmProcessamento.contains(id)) {
      ResponderSharedHelper.log('⚠️ [$categoria] Resposta já em processamento');
      return;
    }

    try {
      _respostasEmProcessamento.add(id);

      final connectivityResult = await Connectivity().checkConnectivity();
      final hasConnection = !connectivityResult.contains(ConnectivityResult.none);

      final Map<String, dynamic> dadosJson = resposta.toJson();

      if (hasConnection) {
        try {
          await _enviarRespostaJson(id: id, dadosJson: dadosJson);
          await LocalDbService.instance.removerRespostaPendenteByDespacho(id);
          await LocalDbService.instance.updateDespachoStatus(id, 'CONCLUIDO');
          ResponderSharedHelper.log('✅ [$categoria] Enviado com sucesso');
          return;
        } catch (e) {
          ResponderSharedHelper.log('⚠️ [$categoria] Falha online: $e. Salvando localmente.');
          await _salvarLocalmente(id, dadosJson);
        }
      } else {
        await _salvarLocalmente(id, dadosJson);
      }
    } catch (e) {
      ResponderSharedHelper.log('❌ [$categoria] Erro fatal: $e');
      rethrow;
    } finally {
      _respostasEmProcessamento.remove(id);
    }
  }

  Future<void> _enviarRespostaJson({
    required int id,
    required Map<String, dynamic> dadosJson,
  }) async {
    final url = getEndpointSalvar(id);
    final token = await authService.getAccessToken();

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dadosJson),
    ).timeout(const Duration(seconds: 60));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  Future<void> _salvarLocalmente(int despachoId, Map<String, dynamic> dados) async {
    await LocalDbService.instance.saveRespostaPendente(
      despachoId: despachoId,
      categoria: categoria,
      dadosJson: jsonEncode(dados),
    );
    await LocalDbService.instance.updateDespachoStatus(despachoId, 'PENDENTE_RELATORIO');
    ResponderSharedHelper.log('💾 [$categoria] Resposta salva localmente');
  }

  @override
  Future<void> sincronizarRespostasRapido() async {
    if (_isSincronizando) return;
    _isSincronizando = true;

    try {
      final pendentes = await LocalDbService.instance.getRespostasPendentes();
      final minhas = pendentes.where((r) => r.categoria == categoria).toList();

      for (final resposta in minhas) {
        if (_respostasEmProcessamento.contains(resposta.despachoId)) continue;
        _respostasEmProcessamento.add(resposta.despachoId);

        try {
          final dados = jsonDecode(resposta.dados) as Map<String, dynamic>;
          await _enviarRespostaJson(id: resposta.despachoId, dadosJson: dados);
          await LocalDbService.instance.deleteRespostaPendente(resposta.id);
          await LocalDbService.instance.updateDespachoStatus(resposta.despachoId, 'CONCLUIDO');
          ResponderSharedHelper.log('✅ [$categoria] Sincronizado: ${resposta.despachoId}');
        } catch (e) {
          await LocalDbService.instance
              .updateRespostaStatus(resposta.id, 'ERRO', erro: e.toString());
          ResponderSharedHelper.log('❌ [$categoria] Erro: $e');
        } finally {
          _respostasEmProcessamento.remove(resposta.despachoId);
        }
      }
    } finally {
      _isSincronizando = false;
    }
  }

  @override
  Future<void> sincronizarRespostasPendentes() => sincronizarRespostasRapido();

  @override
  Future<T> getResposta<T extends RespostaModelo>({
    required int despachoId,
    required T Function(Map<String, dynamic>) fromJson,
    required T Function(int id) emptyFactory,
  }) async {
    final hasConnection = !(await Connectivity().checkConnectivity())
        .contains(ConnectivityResult.none);

    if (hasConnection && despachoId > 0) {
      try {
        final response = await AuthHttpHelper.get(getEndpointBusca(despachoId));
        if (response.statusCode == 200) {
          return fromJson(jsonDecode(response.body) as Map<String, dynamic>);
        }
      } catch (e) {
        ResponderSharedHelper.log('⚠️ Erro ao buscar online: $e');
      }
    }

    final respostaLocal =
        await LocalDbService.instance.getRespostaPendenteByDespacho(despachoId);
    if (respostaLocal != null) {
      return fromJson(jsonDecode(respostaLocal.dados) as Map<String, dynamic>);
    }

    return emptyFactory(despachoId);
  }

  @override
  void dispose() {}
}
