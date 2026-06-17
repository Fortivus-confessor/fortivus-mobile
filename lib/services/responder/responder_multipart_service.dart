import 'dart:convert';
import 'dart:io';
import 'package:fortivus_app/config/environment_config.dart';
import 'package:fortivus_app/services/auth_service.dart';
import 'package:fortivus_app/services/file_upload_queue_service.dart';
import 'package:fortivus_app/services/local_db_service.dart';
import 'package:fortivus_app/services/registro_service.dart';
import 'package:fortivus_app/util/auth_http_helper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:fortivus_app/model/resposta_modelo.dart';
import 'responder_base_service.dart';
import 'shared/responder_shared_helper.dart';

/// Base para todos os serviços que usam multipart
abstract class ResponderMultipartService implements ResponderBaseService {
  String get baseUrl => EnvironmentConfig.apiBaseUrl.replaceAll('/api', '');

  final AuthService authService = AuthService();
  final RegistroService _registroService = RegistroService();
  final FileUploadQueueService _uploadQueueService = FileUploadQueueService();
  final Set<int> _respostasEmProcessamento = {};

  bool _isSincronizando = false;

  Uri getEndpointSalvar(int id);
  Uri getEndpointBusca(int id);
  @override
  @override
  String get categoria;

  bool get temImagemOrigem => false;
  String get chaveImagemOrigem => 'imagemOrigemIncendio';

  @override
  Future<void> salvarResposta({
    required RespostaModelo resposta,
    List<XFile>? arquivos,
    String? descricaoAvulsa,
    bool isAvulso = false,
  }) async {
    final int id = resposta.id;
    if (_respostasEmProcessamento.contains(id)) {
      ResponderSharedHelper.log('⚠️ [$categoria] Resposta já em processamento');
      return;
    }

    try {
      _respostasEmProcessamento.add(id);

      ResponderSharedHelper.log('╔═══════════════════════════════════════════════════════════╗');
      ResponderSharedHelper.log('║ 📋 INICIANDO SALVAMENTO MULTIPART                         ║');
      ResponderSharedHelper.log('╚═══════════════════════════════════════════════════════════╝');
      ResponderSharedHelper.log('🏷️ Categoria: $categoria');
      ResponderSharedHelper.log('🔑 ID: $id');

      final connectivityResult = await Connectivity().checkConnectivity();
      final hasConnection =
          !connectivityResult.contains(ConnectivityResult.none);
      ResponderSharedHelper.log('📡 Conexão: ${hasConnection ? 'ONLINE' : 'OFFLINE'}');

      final Map<String, dynamic> dadosJson = resposta.toJson();

      if (descricaoAvulsa != null && descricaoAvulsa.isNotEmpty) {
        dadosJson['metadata_descricao_avulsa'] = descricaoAvulsa;
        ResponderSharedHelper.log('📝 [DESCRIÇÃO AVULSO] Armazenado: $descricaoAvulsa');
      }

      ResponderSharedHelper.log('');
      ResponderSharedHelper.log('📎 [PASSO 1] Processando arquivos especiais...');
      await processarArquivosEspeciais(id, dadosJson);

      if (hasConnection) {
        try {
          ResponderSharedHelper.log('');
          int idParaUpload = id;
          
          // Verifica se é avulso E o ID é provisório/negativo
          if (isAvulso && id < 0) {
            ResponderSharedHelper.log('🚀 [PASSO 1.5] Criando registro avulso online...');
            final lat = dadosJson['latitudeAreaAtuacao'] ?? dadosJson['latitudeAtuacao'];
            final lng = dadosJson['longitudeAreaAtuacao'] ?? dadosJson['longitudeAtuacao'];
            final desc = dadosJson['metadata_descricao_avulsa'] ?? 'Avulso';

            final novoRegistroApi = await _registroService.criarRegistroAvulsoOnline(
              categoria, lat, lng, desc
            );

            if (novoRegistroApi == null) {
              throw Exception('Falha ao obter ID real do servidor para o registro avulso.');
            }
            idParaUpload = novoRegistroApi.id;
            dadosJson['id'] = idParaUpload;
            ResponderSharedHelper.log('✅ Avulso criado na API. Novo ID: $idParaUpload');
          }
          
          ResponderSharedHelper.log('📤 [PASSO 2] Enviando MULTIPART online...');
          await _enviarRespostaComMultipart(
            id: idParaUpload,
            respostaOriginal: resposta, 
            dadosJson: dadosJson,
            anexos: arquivos,
          );
          ResponderSharedHelper.log('');
          ResponderSharedHelper.log('🗑️ [PASSO 3] Limpando dados locais...');
          await LocalDbService.removerRespostaPendentePorRegistroId(id);
          await LocalDbService.removerRegistro(id);
          await ResponderSharedHelper.limparPastaSegura(id);
          ResponderSharedHelper.log('✅ Dados locais removidos');
          ResponderSharedHelper.log('🎉 SALVAMENTO CONCLUÍDO COM SUCESSO');
          return;
          
        } catch (e) {
          if (e is RegistroServiceException && e.statusCode == 400) {
            ResponderSharedHelper.log('🚫 [$categoria] Erro 400 (Sem Escala). Abortando salvamento local e descartando rascunho.');
            throw Exception('Acesso Negado: Você não possui uma escala vinculada na plataforma para criar ocorrências.');
          }

          // Se for outro erro (ex: 500, timeout), aí sim salva como Pendente
          ResponderSharedHelper.log('⚠️ [$categoria] Falha online: $e');
          ResponderSharedHelper.log('   Salvando resposta localmente para sincronização...');
          dadosJson['id'] = id; 
          final arqEspec = obterArquivoEspecifico(resposta);
          if (arqEspec != null) {
             dadosJson[obterNomeArquivoEspecifico()] = arqEspec.path;
          }
          
          await _salvarLocalmente(id, dadosJson, arquivos);
        }
      } else {
        ResponderSharedHelper.log('📴 [OFFLINE] Salvando resposta localmente...');
        final arqEspec = obterArquivoEspecifico(resposta);
        if (arqEspec != null) {
            dadosJson[obterNomeArquivoEspecifico()] = arqEspec.path;
        }

        await _salvarLocalmente(id, dadosJson, arquivos);
        if (isAvulso) ResponderSharedHelper.log('📴 [$categoria] Offline - aguardando conexão');
      }
    } catch (e) {
      ResponderSharedHelper.log('❌ [$categoria] Erro fatal: $e');
      rethrow;
    } finally {
      _respostasEmProcessamento.remove(id);
    }
  }

  Future<void> processarArquivosEspeciais(int id, Map<String, dynamic> dadosJson) async {
    ResponderSharedHelper.log('   ℹ️ Nenhum arquivo especial para processar');
  }

  Future<void> _enviarRespostaComMultipart({
    required int id,
    RespostaModelo? respostaOriginal, 
    required Map<String, dynamic> dadosJson,
    List<XFile>? anexos,
  }) async {
    try {
      ResponderSharedHelper.log('═══════════════════════════════════════════════════════════');
      ResponderSharedHelper.log('📦 ENVIANDO MULTIPART');
      ResponderSharedHelper.log('═══════════════════════════════════════════════════════════');
      final url = getEndpointSalvar(id);
      ResponderSharedHelper.log('📍 Endpoint: $url');
      var request = http.MultipartRequest('POST', url);
      ResponderSharedHelper.log('');
      ResponderSharedHelper.log('🔐 [MULTIPART] Adicionando autenticação...');
      final token = await authService.getAccessToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      ResponderSharedHelper.log('');
      ResponderSharedHelper.log('📄 [MULTIPART] Adicionando dados JSON...');
      final String? descricaoAvulsaSalva = dadosJson['metadata_descricao_avulsa'] as String?;
      final dadosParaEnvio = ResponderSharedHelper.removerMetadata(dadosJson);

      if (descricaoAvulsaSalva != null) {
        dadosParaEnvio['metadata_descricao_avulsa'] = descricaoAvulsaSalva;
      }

      final jsonString = jsonEncode(dadosParaEnvio);
      request.fields['dados'] = jsonString;

      ResponderSharedHelper.log('');
      ResponderSharedHelper.log('📎 [MULTIPART] Adicionando arquivo específico...');
      
      XFile? arquivoEspecifico;
      final nomeArquivo = obterNomeArquivoEspecifico();
      
      if (respostaOriginal != null) {
        arquivoEspecifico = obterArquivoEspecifico(respostaOriginal);
      } else {
        final possiblePath = dadosParaEnvio[nomeArquivo]?.toString();
        if (possiblePath != null && possiblePath.isNotEmpty) {
           final fileCheck = File(possiblePath);
           if (await fileCheck.exists()) {
             arquivoEspecifico = XFile(possiblePath);
           }
        }
      }
      
      if (arquivoEspecifico != null) {
        final bytes = await arquivoEspecifico.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          nomeArquivo,
          bytes,
          filename: arquivoEspecifico.name,
        ));
        ResponderSharedHelper.log('   ✅ Arquivo adicionado: ${arquivoEspecifico.name}');
      } else {
        ResponderSharedHelper.log('   ℹ️ Nenhum arquivo específico');
      }

      ResponderSharedHelper.log('');
      ResponderSharedHelper.log('📎 [MULTIPART] Adicionando anexos adicionais...');
      if (anexos != null && anexos.isNotEmpty) {
        ResponderSharedHelper.log('   ✅ ${anexos.length} anexo(s)');
        for (int i = 0; i < anexos.length; i++) {
          final arquivo = anexos[i];
          final bytes = await arquivo.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes(
            'anexos', bytes, filename: arquivo.name,
          ));
        }
      } else {
        ResponderSharedHelper.log('   ℹ️ Nenhum anexo');
      }

      if (temImagemOrigem && dadosParaEnvio[chaveImagemOrigem] != null) {
        final imgPath = dadosParaEnvio[chaveImagemOrigem].toString();
        final imgFile = File(imgPath);
        if (await imgFile.exists()) {
          final bytes = await imgFile.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes(
            'imagemOrigem', bytes, filename: p.basename(imgPath),
          ));
          ResponderSharedHelper.log('   ✅ Imagem origem adicionada (Legado)');
        }
      }

      ResponderSharedHelper.log('');
      ResponderSharedHelper.log('⏳ [MULTIPART] Enviando...');
      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 120));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ResponderSharedHelper.log('   ✅ Sucesso no envio (Status: ${response.statusCode})');
      } else {
        ResponderSharedHelper.log('   ❌ Erro HTTP ${response.statusCode}');
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      ResponderSharedHelper.log('❌ [MULTIPART] Erro ao enviar: $e');
      rethrow;
    }
  }

  XFile? obterArquivoEspecifico(RespostaModelo resposta) {
    return null;
  }

  String obterNomeArquivoEspecifico() {
    return 'arquivoEspecifico';
  }

  Future<void> _salvarLocalmente(
    int id,
    Map<String, dynamic> dados,
    List<XFile>? arquivos,
  ) async {
    ResponderSharedHelper.log('');
    ResponderSharedHelper.log('💾 [LOCAL] Salvando resposta localmente...');

    dados['metadata_categoria'] = categoria;

    final arquivosSeguros =
        await ResponderSharedHelper.moverArquivosParaLocalSeguro(id, arquivos);

    if (temImagemOrigem) {
      await ResponderSharedHelper.moverImagemParaOutbox(
        idRegistro: id,
        dados: dados,
        chaveImagem: chaveImagemOrigem,
      );
    }
    
    final nomeEspec = obterNomeArquivoEspecifico();
    if (dados[nomeEspec] != null && !temImagemOrigem) {
       await ResponderSharedHelper.moverImagemParaOutbox(
        idRegistro: id,
        dados: dados,
        chaveImagem: nomeEspec,
      );
    }

    await LocalDbService.salvarRespostaPendente(
      registroId: id,
      dados: dados,
      arquivos: arquivosSeguros.isNotEmpty ? arquivosSeguros : null,
    );
    
    await LocalDbService.atualizarStatusRegistro(id, 'RESPONDIDO_OFFLINE');
    ResponderSharedHelper.log('📦 [$categoria] Resposta salva localmente');
  }

  @override
  Future<void> sincronizarRespostasRapido() async {
    if (_isSincronizando) return;
    _isSincronizando = true;

    try {
      ResponderSharedHelper.log('🔄 [SYNC RÁPIDO] Iniciando...');
      final respostasPendentes = await LocalDbService.getRespostasPendentes();

      for (var resposta in respostasPendentes) {
        final Map<String, dynamic> dadosSalvos = json.decode(resposta['dados']);
        if (dadosSalvos['metadata_categoria'] != categoria) continue;

        int registroIdOriginal = resposta['registroId'];
        int registroIdParaUpload = registroIdOriginal;

        if (_respostasEmProcessamento.contains(registroIdOriginal)) continue;
        _respostasEmProcessamento.add(registroIdOriginal);

        try {
          if (registroIdOriginal < 0) {
            final latRaw = dadosSalvos['latitudeAreaAtuacao'] ?? dadosSalvos['latitudeAtuacao'];
            final lngRaw = dadosSalvos['longitudeAreaAtuacao'] ?? dadosSalvos['longitudeAtuacao'];
            
            final lat = (latRaw is num) ? latRaw.toDouble() : 0.0;
            final lng = (lngRaw is num) ? lngRaw.toDouble() : 0.0;

            final novoRegistroApi = await _registroService.criarRegistroAvulsoOnline(
              categoria,
              lat,
              lng,
              dadosSalvos['metadata_descricao_avulsa'] ?? 'Avulso',  
            );

            if (novoRegistroApi != null) {
              registroIdParaUpload = novoRegistroApi.id;
              dadosSalvos['id'] = registroIdParaUpload;
            }
          }

          final dadosParaEnvio = Map<String, dynamic>.from(dadosSalvos);
          dadosParaEnvio['id'] = registroIdParaUpload;

          await _enviarRespostaComMultipart(
            id: registroIdParaUpload,
            respostaOriginal: null, 
            dadosJson: dadosParaEnvio,
            anexos: resposta['arquivosPath'] != null
                ? (json.decode(resposta['arquivosPath']) as List)
                    .map((p) => XFile(p.toString()))
                    .toList()
                : null,
          );

          if (registroIdOriginal < 0 && registroIdParaUpload > 0) {
            await _atualizarFilaUploads(registroIdOriginal, registroIdParaUpload); 
          }

          await LocalDbService.removerRespostaPendentePorRegistroId(registroIdOriginal);
          await LocalDbService.removerRegistro(registroIdOriginal);
          await ResponderSharedHelper.limparPastaSegura(registroIdOriginal);

          ResponderSharedHelper.log('   ✅ Sincronizado com sucesso');
        } catch (e) {
          ResponderSharedHelper.log('   ❌ Erro: $e');
        } finally {
          _respostasEmProcessamento.remove(registroIdOriginal);
        }
      }
    } finally {
      _isSincronizando = false;
    }
  }

  @override
  Future<void> sincronizarRespostasPendentes() => sincronizarRespostasRapido();

  @override
  Future<void> sincronizarAvulsoImediato(int registroIdOriginal) async {
    if (_isSincronizando) return;
    _isSincronizando = true;

    try {
      final resposta = await LocalDbService.getRespostaPendentePorRegistroId(registroIdOriginal);
      if (resposta == null) return;

      final Map<String, dynamic> dadosSalvos = json.decode(resposta['dados']);
      int registroIdParaUpload = registroIdOriginal;

      if (registroIdOriginal < 0) {
        final novoRegistroApi = await _registroService.criarRegistroAvulsoOnline(
            categoria,
            dadosSalvos['latitudeAreaAtuacao'] ?? dadosSalvos['latitudeAtuacao'],
            dadosSalvos['longitudeAreaAtuacao'] ?? dadosSalvos['longitudeAtuacao'],
            dadosSalvos['metadata_descricao_avulsa'] ?? 'Avulso',  
        );
        if (novoRegistroApi != null) {
          registroIdParaUpload = novoRegistroApi.id;
          dadosSalvos['id'] = registroIdParaUpload;
        }
      }

      final dadosParaEnvio = Map<String, dynamic>.from(dadosSalvos);
      dadosParaEnvio['id'] = registroIdParaUpload;

      await _enviarRespostaComMultipart(
        id: registroIdParaUpload,
        respostaOriginal: null,
        dadosJson: dadosParaEnvio,
        anexos: resposta['arquivosPath'] != null
            ? (json.decode(resposta['arquivosPath']) as List)
                .map((p) => XFile(p.toString()))
                .toList()
            : null,
      );

      if (registroIdOriginal < 0 && registroIdParaUpload > 0) {
        await _atualizarFilaUploads(registroIdOriginal, registroIdParaUpload); // <-- Passando int
      }

      await LocalDbService.removerRespostaPendentePorRegistroId(registroIdOriginal);
      await LocalDbService.removerRegistro(registroIdOriginal);
      await ResponderSharedHelper.limparPastaSegura(registroIdOriginal);

    } catch (e) {
      ResponderSharedHelper.log('❌ [SYNC AVULSO] Erro: $e');
    } finally {
      _isSincronizando = false;
    }
  }

  @override
  Future<T> getResposta<T extends RespostaModelo>({
    required int registroId,
    required T Function(Map<String, dynamic>) fromJson,
    required T Function(int id) emptyFactory,
  }) async {
    ResponderSharedHelper.log('');
    ResponderSharedHelper.log('🔍 [GET] Buscando resposta: $registroId');

    final hasConnection = !(await Connectivity().checkConnectivity())
        .contains(ConnectivityResult.none);

    if (hasConnection && registroId > 0) {
      try {
        final response = await AuthHttpHelper.get(getEndpointBusca(registroId));
        if (response.statusCode == 200) {
          return fromJson(json.decode(response.body));
        }
      } catch (e) {
        ResponderSharedHelper.log('   ⚠️ Erro ao buscar online: $e');
      }
    }

    final respostaLocal =
        await LocalDbService.getRespostaPendentePorRegistroId(registroId);
    if (respostaLocal != null) {
      return fromJson(json.decode(respostaLocal['dados']));
    }

    return emptyFactory(registroId);
  }

  @override
  void dispose() {}

  Future<void> _atualizarFilaUploads(
    int registroIdOriginal,
    int registroIdParaUpload,
  ) async {
    try {
      final uploadsAntigos =
          await _uploadQueueService.getByRegistroId(registroIdOriginal);

      for (var upload in uploadsAntigos) {
        await _uploadQueueService.removeUpload(upload);
        await _uploadQueueService.addUpload(
          registroId: registroIdParaUpload,
          filePath: upload.filePath,
          fileType: upload.fileType,
          categoria: categoria,
        );
      }
    } catch (e) {
      ResponderSharedHelper.log('[$categoria] ⚠️ Erro ao atualizar fila: $e');
    }
  }
}