import 'package:image_picker/image_picker.dart'; // ✅ NOVO IMPORT
import 'package:fortivus_app/model/formacao_brigadista_florestal.dart'; // ✅ NOVO IMPORT
import 'package:fortivus_app/model/resposta_modelo.dart'; // ✅ NOVO IMPORT

import 'responder_multipart_service.dart';
import 'shared/responder_shared_helper.dart';

class ResponderFormacaoService extends ResponderMultipartService {
  @override
  String get categoria => 'FORMACAO_BRIGADISTA_FLORESTAL';

  @override
  Uri getEndpointSalvar(int id) =>
      Uri.parse('$baseUrl/api/formacao-brigadista/mobile/salvar/$id');

  @override
  Uri getEndpointBusca(int id) =>
      Uri.parse('$baseUrl/api/formacao-brigadista/mobile/$id');

  @override
  Future<void> processarArquivosEspeciais(
    int id,
    Map<String, dynamic> dadosJson,
  ) async {
    try {
      validarDadosEspecificos(dadosJson);

      ResponderSharedHelper.log(
        '═══════════════════════════════════════════════════════════',
      );
      ResponderSharedHelper.log('✅ [FORMACAO] Pós-processamento de arquivos');
      ResponderSharedHelper.log('   - Arquivo QTS: já enviado no MULTIPART');
      ResponderSharedHelper.log('   - Anexos: já enviados no MULTIPART');
      ResponderSharedHelper.log(
        '═══════════════════════════════════════════════════════════',
      );
    } catch (e) {
      ResponderSharedHelper.log(
        '❌ [FORMACAO] Erro em processarArquivosEspeciais: $e',
      );
      rethrow; // ✅ CORRIGIDO: Propagar erro para tratamento superior
    }
  }

  // ============================================================================
  // ✅ ARQUIVO ESPECÍFICO: QTS (CORREÇÃO AQUI)
  // ============================================================================

  @override
  String obterNomeArquivoEspecifico() => 'arquivoQts';

  @override
  XFile? obterArquivoEspecifico(RespostaModelo resposta) {
    if (resposta is FormacaoBrigadistaFlorestal) {
      return resposta.arquivoQtsXFile;
    }
    return null;
  }

  // ============================================================================
  // ✅ VALIDAÇÕES
  // ============================================================================

  /// ✅ Validação completa de dados de Formação
  void validarDadosEspecificos(Map<String, dynamic> dadosJson) {
    ResponderSharedHelper.log('🔍 [FORMACAO] Validando dados específicos...');

    try {
      _validarCoordenadas(dadosJson);
      _validarQtdBrigadistas(dadosJson);
      _validarDatasDeslocamento(dadosJson);
      _validarAlunos(dadosJson);

      ResponderSharedHelper.log('   ✅ Validação de dados completa');
    } catch (e) {
      ResponderSharedHelper.log('   ❌ Validação falhou: $e');
      rethrow;
    }
  }

  /// ✅ Valida coordenadas com range geográfico
  void _validarCoordenadas(Map<String, dynamic> dados) {
    final latitudeRaw = dados['latitudeAtuacao'];
    final longitudeRaw = dados['longitudeAtuacao'];

    if (latitudeRaw == null || longitudeRaw == null) {
      throw Exception('Latitude e Longitude são obrigatórias');
    }

    double latitude;
    double longitude;

    try {
      latitude = double.parse(latitudeRaw.toString());
      longitude = double.parse(longitudeRaw.toString());
    } catch (e) {
      throw Exception(
        'Coordenadas inválidas: latitude=$latitudeRaw, longitude=$longitudeRaw',
      );
    }

    if (latitude < -90 || latitude > 90) {
      throw Exception(
        'Latitude deve estar entre -90 e 90, recebido: $latitude',
      );
    }

    if (longitude < -180 || longitude > 180) {
      throw Exception(
        'Longitude deve estar entre -180 e 180, recebido: $longitude',
      );
    }

    ResponderSharedHelper.log('   ✅ Coordenadas válidas: ($latitude, $longitude)');
  }

  /// ✅ Valida quantidade de brigadistas (converte String se necessário)
  void _validarQtdBrigadistas(Map<String, dynamic> dados) {
    final qtdRaw = dados['qtdBrigadistasCapacitados'];

    if (qtdRaw == null) {
      throw Exception('Quantidade de brigadistas capacitados é obrigatória');
    }

    int qtd;
    try {
      qtd = int.parse(qtdRaw.toString());
    } catch (e) {
      throw Exception(
        'Quantidade de brigadistas deve ser um número inteiro, recebido: $qtdRaw',
      );
    }

    if (qtd < 0) {
      throw Exception(
        'Quantidade de brigadistas não pode ser negativa, recebido: $qtd',
      );
    }

    ResponderSharedHelper.log('   ✅ Qtd Brigadistas: $qtd');
  }

  /// ✅ Valida datas de deslocamento
  void _validarDatasDeslocamento(Map<String, dynamic> dados) {
    final deslocamentoInicialRaw = dados['deslocamentoInicialGuarnicao'];
    final deslocamentoFinalRaw = dados['deslocamentoFinalGuarnicao'];

    if (deslocamentoInicialRaw == null) {
      throw Exception('Data de deslocamento inicial é obrigatória');
    }

    if (deslocamentoFinalRaw == null) {
      throw Exception('Data de deslocamento final é obrigatória');
    }

    DateTime? dataInicial;
    DateTime? dataFinal;

    try {
      dataInicial = _parseData(deslocamentoInicialRaw);
      dataFinal = _parseData(deslocamentoFinalRaw);
    } catch (e) {
      throw Exception('Datas de deslocamento inválidas: $e');
    }

    if (dataInicial.isAfter(dataFinal)) {
      throw Exception(
        'Data de deslocamento inicial deve ser anterior à final. '
        'Inicial: $dataInicial, Final: $dataFinal',
      );
    }

    ResponderSharedHelper.log('   ✅ Deslocamento: $dataInicial até $dataFinal');
  }

  /// ✅ Valida alunos matriculados com tratamento seguro
  void _validarAlunos(Map<String, dynamic> dados) {
    final alunosRaw = dados['alunosMatriculados'];

    if (alunosRaw == null) {
      ResponderSharedHelper.log('   ⚠️ Nenhum aluno informado');
      return;
    }

    if (alunosRaw is! List) {
      throw Exception(
        'Alunos matriculados deve ser uma lista, recebido: ${alunosRaw.runtimeType}',
      );
    }

    if (alunosRaw.isEmpty) {
      ResponderSharedHelper.log('   ⚠️ Lista de alunos vazia');
      return;
    }

    ResponderSharedHelper.log('   ✅ Alunos: ${alunosRaw.length}');

    for (int i = 0; i < alunosRaw.length; i++) {
      try {
        final aluno = alunosRaw[i];

        if (aluno is! Map<String, dynamic>) {
          throw Exception(
            'Aluno $i deve ser um Map, recebido: ${aluno.runtimeType}',
          );
        }

        final nome = aluno['nomeCompleto'];
        final concludente = aluno['concludente'];

        if (nome == null || nome.toString().trim().isEmpty) {
          throw Exception('Aluno $i: nomeCompleto é obrigatório');
        }

        if (concludente == null) {
          throw Exception('Aluno $i: concludente é obrigatório');
        }

        ResponderSharedHelper.log(
          '      ${i + 1}. ${nome.toString().trim()} (concludente: $concludente)',
        );
      } catch (e) {
        throw Exception('Erro validando aluno $i: $e');
      }
    }
  }

  /// ✅ Helper: Parse seguro de data
  DateTime _parseData(dynamic valor) {
    if (valor == null) {
      throw Exception('Data não pode ser nula');
    }

    if (valor is DateTime) {
      return valor;
    }

    if (valor is String) {
      try {
        return DateTime.parse(valor);
      } catch (e) {
        throw Exception(
          'Formato de data inválido: "$valor". Use ISO 8601 (yyyy-MM-dd)',
        );
      }
    }

    throw Exception(
      'Tipo de data inválido: ${valor.runtimeType}. Esperado DateTime ou String',
    );
  }
}