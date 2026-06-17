/*import 'dart:convert';
import 'dart:io';
import 'package:fortivus_app/config/environment_config.dart';
import 'package:fortivus_app/services/auth_service.dart';
import 'package:fortivus_app/services/file_upload_queue_service.dart';
import 'package:fortivus_app/services/local_db_service.dart';
import 'package:fortivus_app/services/registro_service.dart';
import 'package:fortivus_app/util/auth_http_helper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../model/resposta_modelo.dart';

class ResponderRegistroService {
  final String baseUrl;
  bool _isSincronizando = false;
  final AuthService _authService = AuthService();
  final Set<String> _respostasEmProcessamento = {};
  final RegistroService _registroService = RegistroService();
  final FileUploadQueueService _uploadQueueService = FileUploadQueueService();

  ResponderRegistroService()
      : baseUrl = EnvironmentConfig.apiBaseUrl.replaceAll('/api', '');

  // ============================================================================
  // ENDPOINTS
  // ============================================================================
  Uri _getEndpointSalvar(String categoria, String id) {
    if (categoria == 'COMBATE_INCENDIO_AEREO') {
      return Uri.parse('$baseUrl/api/combate-incendio/aereo/mobile/salvar/$id');
    }
    if (categoria == 'COMBATE_INCENDIO_MAQUINARIO') {
      return Uri.parse('$baseUrl/api/combate-incendio/maquinario/mobile/salvar/$id');
    }
    if (categoria == 'RONDA') {
      return Uri.parse('$baseUrl/api/ronda/mobile/salvar/$id');
    }
    if (categoria == 'CONSCIENTIZACAO_EDUCACAO_AMBIENTAL') {
      return Uri.parse('$baseUrl/api/conscientizacao_educacao/mobile/salvar/$id');
    }
    if (categoria == 'FORMACAO_BRIGADISTA_FLORESTAL') {
      return Uri.parse('$baseUrl/api/formacao_brigadista/mobile/salvar/$id');
    }
    return Uri.parse('$baseUrl/api/combate-incendio/terrestre/mobile/salvar/$id');
  }

  Uri _getEndpointSalvarMultipart(String categoria, String id) {
    if (categoria == 'COMBATE_INCENDIO_AEREO') {
      return Uri.parse('$baseUrl/api/combate-incendio/aereo/mobile/salvar/$id');
    }
    if (categoria == 'COMBATE_INCENDIO_MAQUINARIO') {
      return Uri.parse('$baseUrl/api/combate-incendio/maquinario/mobile/salvar/$id');
    }
    return Uri.parse('$baseUrl/api/combate-incendio/terrestre/mobile/salvar/$id');
  }

  Uri _getEndpointArquivos(String categoria, String id) {
    if (categoria == 'RONDA') {
      return Uri.parse('$baseUrl/api/ronda/mobile/arquivos/$id');
    }
    if (categoria == 'CONSCIENTIZACAO_EDUCACAO_AMBIENTAL') {
      return Uri.parse('$baseUrl/api/conscientizacao_educacao/mobile/arquivos/$id');
    }
    if (categoria == 'FORMACAO_BRIGADISTA_FLORESTAL') {
      return Uri.parse('$baseUrl/api/formacao_brigadista/mobile/arquivos/$id');
    }
    return Uri.parse('$baseUrl/api/combate-incendio/mobile/arquivos/$id');
  }

  Uri _getEndpointBusca(String categoria, String id) {
    if (categoria == 'RONDA') {
      return Uri.parse('$baseUrl/api/ronda/mobile/$id');
    }
    if (categoria == 'CONSCIENTIZACAO_EDUCACAO_AMBIENTAL') {
      return Uri.parse('$baseUrl/api/conscientizacao_educacao/mobile/$id');
    }
    if (categoria == 'FORMACAO_BRIGADISTA_FLORESTAL') {
      return Uri.parse('$baseUrl/api/formacao_brigadista/mobile/$id');
    }
    return Uri.parse('$baseUrl/api/combate-incendio/mobile/$id');
  }

  Uri _getEndpointQts(String id) =>
      Uri.parse('$baseUrl/api/formacao_brigadista/mobile/qts/$id');

  // ============================================================================
  // GERENCIAMENTO DE ARQUIVOS
  // ============================================================================
  Future<List<XFile>> _moverArquivosParaLocalSeguro(
    String idRegistro,
    List<XFile>? arquivosOriginais,
  ) async {
    if (arquivosOriginais == null || arquivosOriginais.isEmpty) return [];

    final appDocDir = await getApplicationDocumentsDirectory();
    final pastaSegura = Directory('${appDocDir.path}/outbox_files/$idRegistro');

    if (!await pastaSegura.exists()) {
      await pastaSegura.create(recursive: true);
    }

    List<XFile> arquivosSeguros = [];
    for (var arquivo in arquivosOriginais) {
      if (arquivo.path.contains('/outbox_files/')) {
        arquivosSeguros.add(arquivo);
        continue;
      }

      final fileOriginal = File(arquivo.path);
      if (await fileOriginal.exists()) {
        final novoNome =
            '${DateTime.now().millisecondsSinceEpoch}_${p.basename(arquivo.path)}';
        final caminhoSeguro = '${pastaSegura.path}/$novoNome';
        final fileCopiado = await fileOriginal.copy(caminhoSeguro);
        arquivosSeguros.add(XFile(fileCopiado.path));

        if (kDebugMode) debugPrint('🔒 Arquivo salvo em: $caminhoSeguro');
      }
    }
    return arquivosSeguros;
  }

  Future<void> _limparPastaSegura(String idRegistro) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final pastaSegura = Directory('${appDocDir.path}/outbox_files/$idRegistro');
      if (await pastaSegura.exists()) {
        await pastaSegura.delete(recursive: true);
        if (kDebugMode) debugPrint('🧹 Pasta do outbox removida: $idRegistro');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Erro ao limpar pasta: $e');
    }
  }

  // ============================================================================
  // ARQUIVO QTS
  // ============================================================================
  Future<String?> salvarArquivoQts(String id, XFile arquivo) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) return null;

      final url = _getEndpointQts(id);
      var request = http.MultipartRequest('POST', url);
      final token = await _authService.getAccessToken();
      if (token != null) request.headers['Authorization'] = 'Bearer $token';

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        await arquivo.readAsBytes(),
        filename: arquivo.name,
      ));
      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['arquivoQtsNovo'];
      }
      throw Exception('HTTP ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [QTS] Erro: $e');
      return null;
    }
  }


Future<void> salvarResposta({
  required RespostaModelo resposta,
  required String categoria,
  List<XFile>? arquivos,
  XFile? arquivoQts,
  String? descricaoAvulsa,
  bool isAvulso = false,
  XFile? imagemOrigem,
}) async {
  final String id = resposta.id;
  if (_respostasEmProcessamento.contains(id)) return;

  try {
    _respostasEmProcessamento.add(id);
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasConnection = !connectivityResult.contains(ConnectivityResult.none);
    final Map<String, dynamic> dadosJson = resposta.toJson();

    if (hasConnection) {
      try {
        if (categoria == 'FORMACAO_BRIGADISTA_FLORESTAL' &&
            arquivoQts != null &&
            dadosJson['arquivoQtsNovo']?.toString().isNotEmpty == true) {
          final arquivoQtsHash = await salvarArquivoQts(id, arquivoQts);
          if (arquivoQtsHash != null) {
            dadosJson['arquivoQtsNovo'] = arquivoQtsHash;
          } else {
            await _salvarLocalmente(
              id,
              dadosJson,
              arquivos,
              categoria,
              descricaoAvulsa: descricaoAvulsa,
            );
            return;
          }
        }

        // ✅ Enviar resposta COM imagem origem
        if (categoria.startsWith('COMBATE_INCENDIO_')) {
          await _enviarRespostaComMultipart(
            id: id,
            categoria: categoria,
            dadosJson: dadosJson,
            anexos: arquivos,
            imagemOrigem: imagemOrigem,
          );
        } else {
          await _enviarResposta(
            _getEndpointSalvar(categoria, id),
            dadosJson,
          );
        }

        // ✅ SUCESSO: Limpar tudo
        await LocalDbService.removerRespostaPendentePorRegistroId(id);
        await LocalDbService.removerRegistro(id);
        await _limparPastaSegura(id);
        return;

      } on ValidationException {
        rethrow;
      } catch (e) {
        if (kDebugMode) debugPrint('⚠️ Falha online. Salvando no Outbox.');
        
        // ✅ CORRIGIDO: Passar arquivos para _salvarLocalmente
        await _salvarLocalmente(
          id,
          dadosJson,
          arquivos,  // ✅ PASSAR ARQUIVOS AQUI
          categoria,
          descricaoAvulsa: descricaoAvulsa,
        );

        if (isAvulso) {
          if (kDebugMode) debugPrint('🚀 [AVULSO] Acionando sincronização imediata');
          Future.delayed(const Duration(milliseconds: 500), () {
            sincronizarAvulsoImediato(id);
          });
        }
      }
    } else {
      // ✅ CORRIGIDO: Passar arquivos para _salvarLocalmente
      await _salvarLocalmente(
        id,
        dadosJson,
        arquivos,  // ✅ PASSAR ARQUIVOS AQUI
        categoria,
        descricaoAvulsa: descricaoAvulsa,
      );

      if (isAvulso) {
        if (kDebugMode) debugPrint('📴 [AVULSO] Offline - aguardando conexão');
      }
    }
  } finally {
    _respostasEmProcessamento.remove(id);
  }
}

  // ============================================================================
  // ENVIAR RESPOSTA COM MULTIPART - CORRIGIDO
  // ============================================================================
  Future<void> _enviarRespostaComMultipart({
    required String id,
    required String categoria,
    required Map<String, dynamic> dadosJson,
    List<XFile>? anexos,
    XFile? imagemOrigem,
  }) async {
    final url = _getEndpointSalvarMultipart(categoria, id);

    var request = http.MultipartRequest('POST', url);

    final token = await _authService.getAccessToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // ✅ 1. REMOVER FIELDS DESNECESSÁRIOS ANTES DE ENVIAR
    final dadosParaEnvio = Map<String, dynamic>.from(dadosJson)
      ..removeWhere((k, v) => [
        'arquivos',
        'arquivosLocais',
        'arquivosGerais',
        'metadata_categoria',
        'metadata_descricao_avulsa',
        'arquivosParaRemover',
      ].contains(k));

    // ✅ 2. Adicionar JSON dos dados (SEM metadata)
    request.fields['dados'] = jsonEncode(dadosParaEnvio);

    if (kDebugMode) debugPrint('   📋 JSON adicionado (metadata removida)');

    // ✅ 3. Adicionar anexos
    if (anexos != null && anexos.isNotEmpty) {
      for (var arquivo in anexos) {
        final bytes = await arquivo.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'anexos',
          bytes,
          filename: arquivo.name,
        ));
        if (kDebugMode) debugPrint('   📎 Anexo: ${arquivo.name}');
      }
    }

    // ✅ 4. Adicionar imagem origem (APENAS TERRESTRE)
    if (imagemOrigem != null && categoria == 'COMBATE_INCENDIO_TERRESTRE') {
      final bytes = await imagemOrigem.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'imagemOrigem',
        bytes,
        filename: imagemOrigem.name,
      ));
      if (kDebugMode) debugPrint('   📸 Imagem origem: ${imagemOrigem.name}');
    }

    // ✅ 5. Log
    if (kDebugMode) {
      debugPrint('   📦 Multipart pronto:');
      debugPrint('      - Fields: ${request.fields.length}');
      debugPrint('      - Files: ${request.files.length}');
      debugPrint('      - File types: ${request.files.map((f) => f.field).toList()}');
    }

    // ✅ 6. Enviar
    final streamedResponse = await request.send().timeout(Duration(seconds: 30));
    final response = await http.Response.fromStream(streamedResponse);

    if (kDebugMode) debugPrint('   📥 Status: ${response.statusCode}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  // ============================================================================
  // ENVIAR RESPOSTA JSON PURO
  // ============================================================================
  Future<void> _enviarResposta(
    Uri url,
    Map<String, dynamic> dados,
  ) async {
    final dadosParaEnvio = Map<String, dynamic>.from(dados)
      ..removeWhere((k, v) => [
        'arquivos',
        'arquivosLocais',
        'arquivosGerais',
        'metadata_categoria',
        'metadata_descricao_avulsa'
      ].contains(k));

    if (url.path.contains('formacao_brigadista') &&
        dadosParaEnvio.containsKey('id')) {
      dadosParaEnvio['idRegistroOcorrencia'] = dadosParaEnvio.remove('id');
    }

    final response = await AuthHttpHelper.post(url, body: dadosParaEnvio);

    if (response.statusCode == 400) {
      dynamic errorBody;
      try {
        errorBody = json.decode(response.body);
      } catch (_) {
        errorBody = response.body;
      }
      String msgErro = errorBody is Map
          ? errorBody.entries.map((e) => "${e.key}: ${e.value}").join('\n')
          : errorBody.toString();
      throw ValidationException("Erro de Validação:\n$msgErro");
    }
    if (response.statusCode != 200) {
      throw Exception('Erro API HTTP ${response.statusCode}: ${response.body}');
    }
  }

  Future<void> _enviarArquivos(
    String id,
    List<XFile> arquivos,
    String categoria,
  ) async {
    final url = _getEndpointArquivos(categoria, id);
    var request = http.MultipartRequest('POST', url);
    final token = await _authService.getAccessToken();
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    for (var arquivo in arquivos) {
      try {
        final file = File(arquivo.path);
        if (await file.exists()) {
          request.files.add(http.MultipartFile.fromBytes(
            'files',
            await file.readAsBytes(),
            filename: arquivo.name,
          ));
        } else {
          if (kDebugMode) debugPrint("⚠️ Arquivo não existe: ${arquivo.path}");
        }
      } catch (e) {
        if (kDebugMode) debugPrint("⚠️ Erro ao ler arquivo: $e");
      }
    }
    if (request.files.isEmpty) return;
    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode != 200) {
      throw Exception('Upload arquivos HTTP ${response.statusCode}');
    }
  }

 
Future<void> _salvarLocalmente(
  String id,
  Map<String, dynamic> dados,
  List<XFile>? arquivos,
  String categoria, {
  String? descricaoAvulsa,
}) async {
  dados['metadata_categoria'] = categoria;
  if (descricaoAvulsa != null) {
    dados['metadata_descricao_avulsa'] = descricaoAvulsa;
  }

  // ✅ MOVER ARQUIVOS NORMAIS PARA OUTBOX
  final arquivosSeguros = await _moverArquivosParaLocalSeguro(id, arquivos);

  // ✅ NOVO: MOVER IMAGEM ORIGEM PARA OUTBOX TAMBÉM
  String? imagemOrigemPath = dados['imagemOrigemIncendio'] as String?;
  if (imagemOrigemPath != null && imagemOrigemPath.isNotEmpty) {
    try {
      final imagemFile = File(imagemOrigemPath);
      
      // ✅ Verificar se existe e se já não está em outbox
      if (await imagemFile.exists() && !imagemOrigemPath.contains('/outbox_files/')) {
        final appDocDir = await getApplicationDocumentsDirectory();
        final pastaSegura = Directory('${appDocDir.path}/outbox_files/$id');

        if (!await pastaSegura.exists()) {
          await pastaSegura.create(recursive: true);
        }

        // ✅ Mover com timestamp para evitar duplicação
        final novoNome = '${DateTime.now().millisecondsSinceEpoch}_imagem_origem_${p.basename(imagemOrigemPath)}';
        final caminhoSeguro = '${pastaSegura.path}/$novoNome';
        
        await imagemFile.copy(caminhoSeguro);
        
        // ✅ ATUALIZAR PATH NO BANCO COM NOVO CAMINHO
        dados['imagemOrigemIncendio'] = caminhoSeguro;
        
        if (kDebugMode) {
          debugPrint('🖼️ [SALVAR LOCALMENTE] Imagem origem movida: $caminhoSeguro');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [SALVAR LOCALMENTE] Erro ao mover imagem origem: $e');
      }
      // ✅ Continuar mesmo se falhar (não é crítico)
    }
  }

  // ✅ SALVAR NO BANCO COM ARQUIVOS + IMAGEM
  await LocalDbService.salvarRespostaPendente(
    registroId: id,
    dados: dados,
    arquivos: arquivosSeguros.isNotEmpty ? arquivosSeguros : null,
  );
  
  await LocalDbService.atualizarStatusRegistro(id, 'RESPONDIDO_OFFLINE');

  if (kDebugMode) {
    debugPrint('📦 [SALVAR LOCALMENTE] ${arquivosSeguros.length} arquivo(s) no banco');
  }
}
  // ============================================================================
  // SINCRONIZAÇÃO RÁPIDA
  // ============================================================================
  
// ============================================================================
// SINCRONIZAÇÃO RÁPIDA - CORRIGIDA COM IMAGEM ORIGEM
// ============================================================================
Future<void> sincronizarRespostasRapido() async {
  if (_isSincronizando) {
    if (kDebugMode) debugPrint('⚠️ [SYNC RÁPIDO] Já em progresso');
    return;
  }

  _isSincronizando = true;
  try {
    final respostasPendentes =
        await LocalDbService.getRespostasPendentes();

    if (respostasPendentes.isEmpty) {
      if (kDebugMode) debugPrint('ℹ️ [SYNC RÁPIDO] Nenhuma resposta');
      return;
    }

    if (kDebugMode) {
      debugPrint('📤 [SYNC RÁPIDO] Processando ${respostasPendentes.length}...');
    }

    for (var resposta in respostasPendentes) {
      String registroIdOriginal = resposta['registroId'];
      String registroIdParaUpload = registroIdOriginal;

      if (_respostasEmProcessamento.contains(registroIdOriginal)) continue;
      _respostasEmProcessamento.add(registroIdOriginal);

      try {
        final Map<String, dynamic> dadosSalvos =
            json.decode(resposta['dados']);
        final String categoria =
            dadosSalvos['metadata_categoria'] ?? 'COMBATE_INCENDIO_TERRESTRE';

        if (registroIdOriginal.startsWith('LOC-')) {
          final double? lat = dadosSalvos['latitudeAreaAtuacao'] ??
              dadosSalvos['latitudeAtuacao'];
          final double? long = dadosSalvos['longitudeAreaAtuacao'] ??
              dadosSalvos['longitudeAtuacao'];

          if (lat != null && long != null) {
            String desc = dadosSalvos['metadata_descricao_avulsa'] ??
                dadosSalvos['historicoDescritivo'] ??
                'Registro Avulso Mobile';

            if (kDebugMode) {
              debugPrint('[SYNC RÁPIDO] 🔄 Convertendo LOC- → RO-...');
            }
            final novoRegistroApi =
                await _registroService.criarRegistroAvulsoOnline(
              categoria,
              lat,
              long,
              desc,
            );

            if (novoRegistroApi != null) {
              registroIdParaUpload = novoRegistroApi.id;
              dadosSalvos['id'] = registroIdParaUpload;
              if (kDebugMode) {
                debugPrint('[SYNC RÁPIDO] ✅ Novo ID: $registroIdParaUpload');
              }
            } else {
              throw Exception("Falha ao converter ID");
            }
          } else {
            throw Exception("Dados geográficos inválidos");
          }
        }

        final dadosParaEnvio = Map<String, dynamic>.from(dadosSalvos);
        dadosParaEnvio['id'] = registroIdParaUpload;

        // ✅ NOVO: Extrair imagemOrigem do banco local
        XFile? imagemOrigemParaEnvio;
        if (categoria == 'COMBATE_INCENDIO_TERRESTRE' &&
            dadosSalvos['imagemOrigemIncendio'] != null) {
          String imgPath = dadosSalvos['imagemOrigemIncendio'].toString();
          if (imgPath.isNotEmpty &&
              (imgPath.startsWith('/') || imgPath.startsWith('file://'))) {
            final imgFile = File(imgPath);
            if (await imgFile.exists()) {
              imagemOrigemParaEnvio = XFile(imgPath);
              if (kDebugMode) {
                debugPrint('[SYNC RÁPIDO] 🖼️ Imagem origem encontrada: $imgPath');
              }
            } else {
              if (kDebugMode) {
                debugPrint('[SYNC RÁPIDO] ⚠️ Arquivo de imagem não existe: $imgPath');
              }
            }
          }
        }

        // ✅ ENVIAR COM A IMAGEM ORIGEM
        if (categoria.startsWith('COMBATE_INCENDIO_')) {
          await _enviarRespostaComMultipart(
            id: registroIdParaUpload,
            categoria: categoria,
            dadosJson: dadosParaEnvio,
            anexos: resposta['arquivosPath'] != null
                ? (json.decode(resposta['arquivosPath']) as List)
                    .map((p) => XFile(p.toString()))
                    .toList()
                : null,
            imagemOrigem: imagemOrigemParaEnvio, // ✅ USAR IMAGEM EXTRAÍDA
          );
        } else {
          await _enviarResposta(
            _getEndpointSalvar(categoria, registroIdParaUpload),
            dadosParaEnvio,
          );
        }

        if (kDebugMode) {
          debugPrint('[SYNC RÁPIDO] ✅ Dados enviados: $registroIdParaUpload');
        }

        if (registroIdOriginal.startsWith('LOC-') &&
            registroIdParaUpload.startsWith('RO')) {
          await _atualizarFilaUploads(
            registroIdOriginal,
            registroIdParaUpload,
            categoria,
          );
          if (kDebugMode) {
            debugPrint('[SYNC RÁPIDO] ✅ Fila atualizada');
          }
        }

        // ❌ REMOVER: Não é mais necessário pois a imagem já foi enviada no multipart
        // if (categoria == 'COMBATE_INCENDIO_TERRESTRE' && ...) { ... }

        if (resposta['arquivosPath'] != null) {
          try {
            final paths = json.decode(resposta['arquivosPath']) as List;
            final arquivos =
                paths.map((path) => XFile(path.toString())).toList();

            if (arquivos.isNotEmpty) {
              if (kDebugMode) {
                debugPrint('[SYNC RÁPIDO] 📎 Enviando ${arquivos.length} arquivo(s)...');
              }

              await _enviarArquivos(registroIdParaUpload, arquivos, categoria);

              if (kDebugMode) {
                debugPrint('[SYNC RÁPIDO] ✅ Arquivos enviados com sucesso');
              }
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('[SYNC RÁPIDO] ⚠️ Erro ao enviar arquivos: $e');
            }
            rethrow;
          }
        }

        if (kDebugMode) {
          debugPrint('[SYNC RÁPIDO] 🏆 Sincronização completa: $registroIdParaUpload');
        }
        await LocalDbService.removerRespostaPendentePorRegistroId(
            registroIdOriginal);
        await LocalDbService.removerRegistro(registroIdOriginal);
        await _limparPastaSegura(registroIdOriginal);

      } catch (e) {
        if (kDebugMode) {
          debugPrint('[SYNC RÁPIDO] ❌ Erro: $e');
        }
      } finally {
        _respostasEmProcessamento.remove(registroIdOriginal);
        _respostasEmProcessamento.remove(registroIdParaUpload);
      }
    }

    if (kDebugMode) debugPrint('✅ [SYNC RÁPIDO] Concluído');
  } finally {
    _isSincronizando = false;
  }
}

  // ============================================================================
  // SINCRONIZAÇÃO COMPLETA
  // ============================================================================
 
Future<void> sincronizarRespostasPendentes() async {
  if (_isSincronizando) return;
  _isSincronizando = true;
  try {
    final respostasPendentes =
        await LocalDbService.getRespostasPendentes();

    for (var resposta in respostasPendentes) {
      String registroIdOriginal = resposta['registroId'];
      String registroIdParaUpload = registroIdOriginal;

      if (_respostasEmProcessamento.contains(registroIdOriginal)) continue;
      _respostasEmProcessamento.add(registroIdOriginal);

      try {
        final Map<String, dynamic> dadosSalvos =
            json.decode(resposta['dados']);
        final String categoria =
            dadosSalvos['metadata_categoria'] ?? 'COMBATE_INCENDIO_TERRESTRE';

        if (registroIdOriginal.startsWith('LOC-')) {
          final double? lat = dadosSalvos['latitudeAreaAtuacao'] ??
              dadosSalvos['latitudeAtuacao'];
          final double? long = dadosSalvos['longitudeAreaAtuacao'] ??
              dadosSalvos['longitudeAtuacao'];

          if (lat != null && long != null) {
            String desc = dadosSalvos['metadata_descricao_avulsa'] ??
                dadosSalvos['historicoDescritivo'] ??
                'Registro Avulso Mobile';

            if (kDebugMode) debugPrint('[Sync] 🚀 Convertendo LOC- em RO-...');

            final novoRegistroApi =
                await _registroService.criarRegistroAvulsoOnline(
              categoria,
              lat,
              long,
              desc,
            );

            if (novoRegistroApi != null) {
              registroIdParaUpload = novoRegistroApi.id;
              dadosSalvos['id'] = registroIdParaUpload;
              if (kDebugMode) {
                debugPrint('[Sync] ✅ Conversão bem-sucedida: $registroIdParaUpload');
              }
            } else {
              throw Exception("Falha ao gerar ID real para avulso.");
            }
          } else {
            throw Exception("Dados geográficos inválidos para o avulso.");
          }
        }

        final dadosParaEnvio = Map<String, dynamic>.from(dadosSalvos);
        dadosParaEnvio['id'] = registroIdParaUpload;

        // ✅ NOVO: Extrair imagemOrigem do banco local
        XFile? imagemOrigemParaEnvio;
        if (categoria == 'COMBATE_INCENDIO_TERRESTRE' &&
            dadosSalvos['imagemOrigemIncendio'] != null) {
          String imgPath = dadosSalvos['imagemOrigemIncendio'].toString();
          if (imgPath.isNotEmpty &&
              (imgPath.startsWith('/') || imgPath.startsWith('file://'))) {
            final imgFile = File(imgPath);
            if (await imgFile.exists()) {
              imagemOrigemParaEnvio = XFile(imgPath);
              if (kDebugMode) {
                debugPrint('[Sync] 🖼️ Imagem origem encontrada: $imgPath');
              }
            } else {
              if (kDebugMode) {
                debugPrint('[Sync] ⚠️ Arquivo de imagem não existe: $imgPath');
              }
            }
          }
        }

        // ✅ ENVIAR COM A IMAGEM ORIGEM
        if (categoria.startsWith('COMBATE_INCENDIO_')) {
          await _enviarRespostaComMultipart(
            id: registroIdParaUpload,
            categoria: categoria,
            dadosJson: dadosParaEnvio,
            anexos: resposta['arquivosPath'] != null
                ? (json.decode(resposta['arquivosPath']) as List)
                    .map((p) => XFile(p.toString()))
                    .toList()
                : null,
            imagemOrigem: imagemOrigemParaEnvio, // ✅ USAR IMAGEM EXTRAÍDA
          );
        } else {
          await _enviarResposta(
            _getEndpointSalvar(categoria, registroIdParaUpload),
            dadosParaEnvio,
          );
        }

        if (registroIdOriginal.startsWith('LOC-') &&
            registroIdParaUpload.startsWith('RO')) {
          await _atualizarFilaUploads(
            registroIdOriginal,
            registroIdParaUpload,
            categoria,
          );
        }


        if (resposta['arquivosPath'] != null) {
          try {
            final paths = json.decode(resposta['arquivosPath']) as List;
            final arquivos =
                paths.map((path) => XFile(path.toString())).toList();

            if (arquivos.isNotEmpty) {
              if (kDebugMode) {
                debugPrint('[Sync] 📎 Enviando ${arquivos.length} arquivo(s)...');
              }
              await _enviarArquivos(registroIdParaUpload, arquivos, categoria);
              if (kDebugMode) {
                debugPrint('[Sync] ✅ Arquivos enviados');
              }
            }
          } catch (e) {
            if (kDebugMode) debugPrint('[Sync] ⚠️ Erro ao enviar arquivos: $e');
            rethrow;
          }
        }

        if (kDebugMode) {
          debugPrint('[Sync] 🏆 Sincronização concluída: $registroIdParaUpload');
        }
        await LocalDbService.removerRespostaPendentePorRegistroId(
            registroIdOriginal);
        await LocalDbService.removerRegistro(registroIdOriginal);
        await _limparPastaSegura(registroIdOriginal);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ [Sync] Erro para $registroIdOriginal: $e');
        }

        if (registroIdOriginal.startsWith('LOC-') &&
            registroIdParaUpload.startsWith('RO0')) {
          if (kDebugMode) {
            debugPrint('⚠️ [Sync] Salvando progresso LOC->RO...');
          }
          await LocalDbService.removerRespostaPendentePorRegistroId(
              registroIdOriginal);

          final appDocDir = await getApplicationDocumentsDirectory();
          final pastaVelha = Directory(
              '${appDocDir.path}/outbox_files/$registroIdOriginal');
          if (await pastaVelha.exists()) {
            await pastaVelha.rename(
                '${appDocDir.path}/outbox_files/$registroIdParaUpload');
          }

          final dadosDecodificados = json.decode(resposta['dados']);
          dadosDecodificados['id'] = registroIdParaUpload;
          await LocalDbService.salvarRespostaPendente(
            registroId: registroIdParaUpload,
            dados: dadosDecodificados,
            arquivos: resposta['arquivosPath'] != null
                ? (json.decode(resposta['arquivosPath']) as List)
                    .map((p) => XFile(p.replaceAll(
                        registroIdOriginal, registroIdParaUpload)))
                    .toList()
                : null,
          );

          await _atualizarFilaUploads(
            registroIdOriginal,
            registroIdParaUpload,
            dadosDecodificados['metadata_categoria'] ??
                'COMBATE_INCENDIO_TERRESTRE',
          );
        } else {
          await LocalDbService.atualizarStatusResposta(
              resposta['id'], 'ERRO');
        }
      } finally {
        _respostasEmProcessamento.remove(registroIdOriginal);
        _respostasEmProcessamento.remove(registroIdParaUpload);
      }
    }
  } finally {
    _isSincronizando = false;
  }
}

  // ============================================================================
  // ATUALIZAR FILA DE UPLOADS
  // ============================================================================
  Future<void> _atualizarFilaUploads(
    String registroIdOriginal,
    String registroIdParaUpload,
    String categoria,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('[ATUALIZAR FILA] 🔄 Transferindo: $registroIdOriginal → $registroIdParaUpload');
      }

      final uploadsAntigos =
          await _uploadQueueService.getByRegistroId(registroIdOriginal);

      if (uploadsAntigos.isEmpty) {
        if (kDebugMode) debugPrint('[ATUALIZAR FILA] ℹ️ Nenhum upload pendente');
        return;
      }

      for (var upload in uploadsAntigos) {
        await _uploadQueueService.removeUpload(upload);

        await _uploadQueueService.addUpload(
          registroId: registroIdParaUpload,
          filePath: upload.filePath,
          fileType: upload.fileType,
          categoria: categoria,
        );
      }

      if (kDebugMode) {
        debugPrint('[ATUALIZAR FILA] ✅ ${uploadsAntigos.length} upload(s) transferido(s)');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ATUALIZAR FILA] ⚠️ Erro: $e');
    }
  }

  // ============================================================================
  // RESPOSTA AVULSA
  // ============================================================================
  Future<void> salvarRespostaAvulsa({
    required RespostaModelo resposta,
    required String categoria,
    required String descricaoAvulsa,
    List<XFile>? arquivos,
  }) async {
    await salvarResposta(
      resposta: resposta,
      categoria: categoria,
      arquivos: arquivos,
      descricaoAvulsa: descricaoAvulsa,
      isAvulso: true,
    );
  }

  
Future<void> sincronizarAvulsoImediato(String registroIdOriginal) async {
  if (_isSincronizando) {
    if (kDebugMode) debugPrint('⚠️ [AVULSO IMEDIATO] Sincronização já em progresso');
    return;
  }

  _isSincronizando = true;
  try {
    if (kDebugMode) {
      debugPrint('🚀 [AVULSO IMEDIATO] Sincronizando: $registroIdOriginal');
    }

    final resposta = await LocalDbService
        .getRespostaPendentePorRegistroId(registroIdOriginal);

    if (resposta == null) {
      if (kDebugMode) {
        debugPrint('⚠️ [AVULSO IMEDIATO] Resposta não encontrada');
      }
      return;
    }

    final Map<String, dynamic> dadosSalvos =
        json.decode(resposta['dados']);
    final String categoria =
        dadosSalvos['metadata_categoria'] ?? 'COMBATE_INCENDIO_TERRESTRE';

    String registroIdParaUpload = registroIdOriginal;

    if (kDebugMode) {
      debugPrint('[AVULSO IMEDIATO] 📂 Categoria: $categoria');
      debugPrint('[AVULSO IMEDIATO] 🆔 Registro Original: $registroIdOriginal');
    }

    if (registroIdOriginal.startsWith('LOC-')) {
      if (kDebugMode) debugPrint('[AVULSO IMEDIATO] 🔄 Convertendo LOC- → RO-');

      final double? lat = dadosSalvos['latitudeAreaAtuacao'] ??
          dadosSalvos['latitudeAtuacao'];
      final double? long = dadosSalvos['longitudeAreaAtuacao'] ??
          dadosSalvos['longitudeAtuacao'];

      if (lat == null || long == null) {
        throw Exception('Dados geográficos inválidos para avulso');
      }

      String desc = _obterDescricaoAvulso(dadosSalvos, categoria);

      if (kDebugMode) {
        debugPrint('[AVULSO IMEDIATO] 📍 Lat: $lat, Long: $long');
        debugPrint('[AVULSO IMEDIATO] 📝 Desc: $desc');
      }

      final novoRegistroApi =
          await _registroService.criarRegistroAvulsoOnline(
        categoria,
        lat,
        long,
        desc,
      );

      if (novoRegistroApi == null) {
        throw Exception('Falha ao criar avulso no servidor');
      }

      registroIdParaUpload = novoRegistroApi.id;
      dadosSalvos['id'] = registroIdParaUpload;

      if (kDebugMode) {
        debugPrint('[AVULSO IMEDIATO] ✅ Avulso criado: $registroIdParaUpload');
      }
    }

    if (kDebugMode) debugPrint('[AVULSO IMEDIATO] 📤 Enviando dados...');

    final dadosParaEnvio = Map<String, dynamic>.from(dadosSalvos);
    dadosParaEnvio['id'] = registroIdParaUpload;

    // ✅ NOVO: Extrair imagemOrigem do banco local
    XFile? imagemOrigemParaEnvio;
    if (categoria == 'COMBATE_INCENDIO_TERRESTRE' &&
        dadosSalvos['imagemOrigemIncendio'] != null) {
      String imgPath = dadosSalvos['imagemOrigemIncendio'].toString();
      if (imgPath.isNotEmpty && (imgPath.startsWith('/') || imgPath.startsWith('file://'))) {
        final imgFile = File(imgPath);
        if (await imgFile.exists()) {
          imagemOrigemParaEnvio = XFile(imgPath);
          if (kDebugMode) {
            debugPrint('[AVULSO IMEDIATO] 🖼️ Imagem origem encontrada: $imgPath');
          }
        } else {
          if (kDebugMode) {
            debugPrint('[AVULSO IMEDIATO] ⚠️ Arquivo de imagem não existe: $imgPath');
          }
        }
      }
    }

    // ✅ ENVIAR TUDO NO MULTIPART (dados + anexos + imagem)
    if (categoria.startsWith('COMBATE_INCENDIO_')) {
      await _enviarRespostaComMultipart(
        id: registroIdParaUpload,
        categoria: categoria,
        dadosJson: dadosParaEnvio,
        anexos: resposta['arquivosPath'] != null
            ? (json.decode(resposta['arquivosPath']) as List)
                .map((p) => XFile(p.toString()))
                .toList()
            : null,
        imagemOrigem: imagemOrigemParaEnvio,
      );
    } else {
      await _enviarResposta(
        _getEndpointSalvar(categoria, registroIdParaUpload),
        dadosParaEnvio,
      );
    }

    if (kDebugMode) {
      debugPrint('[AVULSO IMEDIATO] ✅ Dados enviados: $registroIdParaUpload');
    }

    if (registroIdOriginal.startsWith('LOC-') &&
        registroIdParaUpload.startsWith('RO')) {
      if (kDebugMode) {
        debugPrint('[AVULSO IMEDIATO] 🔄 Atualizando fila de uploads');
      }

      await _atualizarFilaUploads(
        registroIdOriginal,
        registroIdParaUpload,
        categoria,
      );

      if (kDebugMode) {
        debugPrint('[AVULSO IMEDIATO] ✅ Fila atualizada');
      }
    }

    // ❌ REMOVER: Não enviar arquivos separadamente
    // Os arquivos já foram enviados no multipart acima!
    // if (resposta['arquivosPath'] != null) {
    //   await _enviarArquivos(...);
    // }

    if (kDebugMode) {
      debugPrint('[AVULSO IMEDIATO] 🏆 Sincronização concluída com sucesso!');
    }

    await LocalDbService.removerRespostaPendentePorRegistroId(
        registroIdOriginal);
    await LocalDbService.removerRegistro(registroIdOriginal);
    await _limparPastaSegura(registroIdOriginal);

    if (kDebugMode) {
      debugPrint('[AVULSO IMEDIATO] ✅ Limpeza completada');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[AVULSO IMEDIATO] ❌ Erro: $e');
    }
    rethrow;
  } finally {
    _isSincronizando = false;
  }
}

  // ============================================================================
  // HELPER - Obter Descrição por Categoria
  // ============================================================================
  String _obterDescricaoAvulso(
    Map<String, dynamic> dados,
    String categoria,
  ) {
    final metadataDesc = dados['metadata_descricao_avulsa'] as String?;
    if (metadataDesc != null && metadataDesc.isNotEmpty) {
      return metadataDesc;
    }

    switch (categoria) {
      case 'COMBATE_INCENDIO_TERRESTRE':
      case 'COMBATE_INCENDIO_AEREO':
      case 'COMBATE_INCENDIO_MAQUINARIO':
        return dados['historicoDescritivo'] ??
            dados['descricao'] ??
            'Registro Avulso Mobile';

      case 'CONSCIENTIZACAO_EDUCACAO_AMBIENTAL':
        return dados['historico'] ??
            dados['metadata_descricao_avulsa'] ??
            'Registro Avulso Mobile';

      case 'FORMACAO_BRIGADISTA_FLORESTAL':
        return dados['descricao'] ??
            dados['metadata_descricao_avulsa'] ??
            'Registro Avulso Mobile';

      case 'RONDA':
        return dados['descricao'] ??
            dados['metadata_descricao_avulsa'] ??
            'Ronda Avulsa';

      default:
        return dados['metadata_descricao_avulsa'] ??
            dados['historico'] ??
            dados['historicoDescritivo'] ??
            dados['descricao'] ??
            'Registro Avulso Mobile';
    }
  }

  // ============================================================================
  // OBTER RESPOSTA
  // ============================================================================
  Future<T> getResposta<T extends RespostaModelo>({
    required String registroId,
    required String categoria,
    required T Function(Map<String, dynamic>) fromJson,
    required T Function(String id) emptyFactory,
  }) async {
    final hasConnection =
        !(await Connectivity().checkConnectivity())
            .contains(ConnectivityResult.none);

    if (hasConnection && !registroId.startsWith('LOC-')) {
      try {
        final response =
            await AuthHttpHelper.get(_getEndpointBusca(categoria, registroId));
        if (response.statusCode == 200) {
          return fromJson(json.decode(response.body));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('⚠️ Erro busca online: $e');
      }
    }

    final respostaLocalMap =
        await LocalDbService.getRespostaPendentePorRegistroId(registroId);
    if (respostaLocalMap != null) {
      final Map<String, dynamic> dadosFinais =
          json.decode(respostaLocalMap['dados']);
      final arquivosPathString = respostaLocalMap['arquivosPath'] as String?;
      if (arquivosPathString != null && arquivosPathString.isNotEmpty) {
        dadosFinais['arquivos'] = (json.decode(arquivosPathString) as List)
            .map((e) => e.toString())
            .toList();
      }
      return fromJson(dadosFinais);
    }
    return emptyFactory(registroId);
  }
}

// ============================================================================
// EXCEPTIONS
// ============================================================================
class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => message;
}*/