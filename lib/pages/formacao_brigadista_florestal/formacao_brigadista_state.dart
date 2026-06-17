import 'dart:async';
import 'package:fortivus_app/enums/tipo_conclusao_alunos.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:fortivus_app/model/formacao_brigadista_florestal.dart';
import 'package:fortivus_app/model/mobile_registro_avulso_request.dart';
import 'package:fortivus_app/model/alunos_formacao_brigada.dart';
import 'package:fortivus_app/services/responder/responder_formacao_brigadista_service.dart';
import 'package:fortivus_app/services/auth_service.dart';
import 'package:fortivus_app/services/local_db_service.dart';

class FormacaoBrigadistaState extends ChangeNotifier {
  // ============================================================================
  // CONSTANTES
  // ============================================================================
  static const String categoria = 'FORMACAO_BRIGADISTA_FLORESTAL';

  // ============================================================================
  // DEPENDÊNCIAS
  // ============================================================================
  final ResponderFormacaoService _service = ResponderFormacaoService();
  final ImagePicker _picker = ImagePicker();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  // ============================================================================
  // IDENTIFICAÇÃO
  // ============================================================================
  final int? registroId;
  final RegistroAvulsoTemp? dadosIniciais;

  int? _idRegistroAtual;
  int? get idRegistroAtual => _idRegistroAtual;

  late final bool _isAvulso;
  bool get isAvulso => _isAvulso;

  // ============================================================================
  // FORM STATE
  // ============================================================================
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController historicoController = TextEditingController();
  final TextEditingController latitudeQueimaController = TextEditingController();
  final TextEditingController longitudeQueimaController = TextEditingController();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    if (_isDisposed) return;
    _isLoading = value;
    notifyListeners();
  }

  // ============================================================================
  // NOTIFIERS
  // ============================================================================
  final ValueNotifier<bool> isOfflineNotifier = ValueNotifier(false);
  final ValueNotifier<LatLng?> localizacaoNotifier = ValueNotifier(null);
  final ValueNotifier<LatLng?> localizacaoQueimaNotifier = ValueNotifier(null);
  final ValueNotifier<List<XFile>> arquivosNotifier = ValueNotifier([]);

  // ============================================================================
  // DADOS DO FORMULÁRIO (Valores EDITÁVEIS)
  // ============================================================================
  double? latitudeAtuacao;
  double? longitudeAtuacao;

  DateTime? deslocamentoInicialGuarnicao;
  DateTime? deslocamentoFinalGuarnicao;

  bool queimaInstrucaoRealizada = false;
  double? latitudeQueimaInst;
  double? longitudeQueimaInst;

  bool acidentesIncidentesOcorridos = false;
  String? descricaoAcidenteIncidente;
  String? arquivoQtsNovo;

  // ============================================================================
  // ✅ DADOS ORIGINAIS DO DESPACHO (Valores IMUTÁVEIS para comparação)
  // ============================================================================
  double? latitudeDespacho;
  double? longitudeDespacho;
  DateTime? deslocamentoInicialDespacho;
  DateTime? deslocamentoFinalDespacho;

  bool formacaoConforme = true;

  // ============================================================================
  // ALUNOS
  // ============================================================================
  List<AlunosFormacaoBrigada> alunos = [];

  int get qtdBrigadistasFormados => _calcularQtdBrigadistas();

  int _calcularQtdBrigadistas() {
    if (alunos.isEmpty) return 0;

    final alunosFormados = alunos.where((aluno) {
      return aluno.concludente == TipoConclusaoAlunos.PRIMEIRA_FORMACAO ||
          aluno.concludente == TipoConclusaoAlunos.RECICLAGEM;
    }).length;

    if (kDebugMode) debugPrint('📊 [QTD BRIGADISTAS] Calculado: $alunosFormados');
    return alunosFormados;
  }

  void adicionarAluno(AlunosFormacaoBrigada aluno) {
    if (_isDisposed) return;
    alunos.add(aluno);
    notifyListeners();
  }

  void removerAluno(int index) {
    if (_isDisposed) return;
    if (index >= 0 && index < alunos.length) {
      alunos.removeAt(index);
      notifyListeners();
    }
  }

  void atualizarAluno(int index, AlunosFormacaoBrigada aluno) {
    if (_isDisposed) return;
    if (index >= 0 && index < alunos.length) {
      alunos[index] = aluno;
      notifyListeners();
    }
  }

  // ============================================================================
  // QTS
  // ============================================================================
  bool qtsSeguidoConforme = true;
  XFile? arquivoQtsXFile;

  void setQtsSeguidoConforme(bool value) {
    if (_isDisposed) return;
    qtsSeguidoConforme = value;
    if (kDebugMode) {
      debugPrint('📋 [STATE FORMACAO] QTS Seguido: ${value ? "Conforme Planejado" : "Houve Alterações"}');
    }
    if (value) {
      arquivoQtsXFile = null;
      if (kDebugMode) debugPrint('🗑️ [STATE FORMACAO] Arquivo QTS removido');
    }
    notifyListeners();
  }

 void setArquivoQts(XFile? arquivo) {
    if (_isDisposed) return;
    arquivoQtsXFile = arquivo; // ✅ Guarda o arquivo físico aqui
    
    if (arquivo != null) {
      if (kDebugMode) {
        debugPrint('📎 [STATE FORMACAO] Arquivo QTS definido: ${arquivo.name}');
      }
      // Opcional: define o nome apenas para referência visual se necessário
      arquivoQtsNovo = arquivo.name; 
    } else {
      arquivoQtsNovo = null;
    }
    notifyListeners();
  }

  void setFormacaoConforme(bool value) {
    if (_isDisposed) return;
    formacaoConforme = value;
    notifyListeners();
  }

  // ============================================================================
  // GETTERS
  // ============================================================================
  ImagePicker get picker => _picker;
  bool get isOffline => isOfflineNotifier.value;

  // ============================================================================
  // FLAGS DE CONTROLE
  // ============================================================================
  bool _isDisposed = false;
  bool _salvando = false;

  // ============================================================================
  // CONSTRUTOR
  // ============================================================================
  FormacaoBrigadistaState({
    required this.registroId,
    required this.dadosIniciais,
    this.latitudeDespacho,
    this.longitudeDespacho,
    this.deslocamentoInicialDespacho,
    this.deslocamentoFinalDespacho,
    bool isAvulso = false,
  }) {
    _isAvulso = isAvulso;
    if (kDebugMode) {
      debugPrint('🏗️ [FORMACAO STATE] Construtor chamado');
      debugPrint('   - isAvulso: $_isAvulso');
      debugPrint('   - registroId: $registroId');
    }
    _init();
  }

  // ============================================================================
  // INICIALIZAÇÃO
  // ============================================================================
  void _init() {
    if (kDebugMode) {
      debugPrint('🚀 [STATE FORMACAO] _init() chamado');
      debugPrint('   - isAvulso: $_isAvulso');
    }

    _idRegistroAtual = registroId;
    _setupConnectivityListener();
    _checkInitialConnectivity();
    _loadFormData();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen(_updateConnectionStatus);
  }

  Future<void> _checkInitialConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    if (_isDisposed) return;
    isOfflineNotifier.value = result.contains(ConnectivityResult.none);
  }

  Future<void> _loadFormData() async {
    if (_idRegistroAtual != null) {
      await _carregarDadosExistentes();
    } else if (dadosIniciais != null) {
      _iniciarComDadosTemporarios();
    } else {
      _setLoading(false);
    }
  }

  void _iniciarComDadosTemporarios() {
    if (kDebugMode) {
      debugPrint('✅ [STATE] Inicializando AVULSO FORMAÇÃO');
      debugPrint('   - isAvulso: $_isAvulso');
    }

    formacaoConforme = false;

    if (_isAvulso) {
      if (dadosIniciais != null) {
        localizacaoNotifier.value = LatLng(
          dadosIniciais!.latitude.toDouble(),
          dadosIniciais!.longitude.toDouble(),
        );
        latitudeAtuacao ??= dadosIniciais!.latitude.toDouble();
        longitudeAtuacao ??= dadosIniciais!.longitude.toDouble();
      }

      deslocamentoInicialGuarnicao = null;
      deslocamentoFinalGuarnicao = null;
    } else {
      if (latitudeDespacho != null && longitudeDespacho != null) {
        localizacaoNotifier.value = LatLng(
          latitudeDespacho!,
          longitudeDespacho!,
        );
        latitudeAtuacao ??= latitudeDespacho;
        longitudeAtuacao ??= longitudeDespacho;
      }

      if (deslocamentoInicialDespacho != null) {
        deslocamentoInicialGuarnicao ??= deslocamentoInicialDespacho;
      }
      if (deslocamentoFinalDespacho != null) {
        deslocamentoFinalGuarnicao ??= deslocamentoFinalDespacho;
      }
    }

    historicoController.text = dadosIniciais!.descricao;

    _setLoading(false);
  }

  Future<void> _carregarDadosExistentes() async {
    try {
      final formacao = await _service
          .getResposta<FormacaoBrigadistaFlorestal>(
            registroId: _idRegistroAtual!,
            fromJson: (json) => FormacaoBrigadistaFlorestal.fromJson(json),
            emptyFactory: (id) => FormacaoBrigadistaFlorestal(id: id),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Timeout ao carregar formação');
            },
          );

      if (!_isDisposed) {
        _popularFormulario(formacao);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [STATE FORMACAO] Erro: $e');
      if (!_isDisposed) {
        _setLoading(false);
      }
    }
  }

  void _popularFormulario(FormacaoBrigadistaFlorestal formacao) {
    latitudeAtuacao = formacao.latitudeAtuacao;
    longitudeAtuacao = formacao.longitudeAtuacao;
    deslocamentoInicialGuarnicao = formacao.deslocamentoInicialGuarnicao;
    deslocamentoFinalGuarnicao = formacao.deslocamentoFinalGuarnicao;
    queimaInstrucaoRealizada = formacao.queimaInstrucaoRealizada;
    latitudeQueimaInst = formacao.latitudeQueimaInst;
    longitudeQueimaInst = formacao.longitudeQueimaInst;
    acidentesIncidentesOcorridos = formacao.acidentesIncidentesOcorridos;
    descricaoAcidenteIncidente = formacao.descricaoAcidenteIncidente;
    historicoController.text = formacao.historico ?? '';
    arquivoQtsNovo = formacao.arquivoQtsNovo;

    _processarQts(formacao.arquivoQtsNovo);

    latitudeDespacho = formacao.latitudeDespacho;
    longitudeDespacho = formacao.longitudeDespacho;
    deslocamentoInicialDespacho = formacao.deslocamentoInicialDespacho;
    deslocamentoFinalDespacho = formacao.deslocamentoFinalDespacho;

    _inicializarLocalizacao(formacao);
    _inicializarAlunos(formacao);
    _inicializarArquivos(formacao);

    _setLoading(false);
    notifyListeners();
  }

  void _processarQts(String? arquivoQts) {
    if (arquivoQts != null && arquivoQts.isNotEmpty && arquivoQts != 'QTS_ALTERADO') {
      qtsSeguidoConforme = false;
    } else if (arquivoQts == 'QTS_ALTERADO') {
      qtsSeguidoConforme = false;
    } else {
      qtsSeguidoConforme = true;
      arquivoQtsXFile = null;
    }
  }

  void _inicializarLocalizacao(FormacaoBrigadistaFlorestal formacao) {
    if (_isDisposed) return;

    if (latitudeAtuacao != null && longitudeAtuacao != null) {
      localizacaoNotifier.value = LatLng(
        latitudeAtuacao!,
        longitudeAtuacao!,
      );
    } else if (latitudeDespacho != null && longitudeDespacho != null) {
      localizacaoNotifier.value = LatLng(
        latitudeDespacho!,
        longitudeDespacho!,
      );
      latitudeAtuacao ??= latitudeDespacho;
      longitudeAtuacao ??= longitudeDespacho;
    }

    if (latitudeQueimaInst != null && longitudeQueimaInst != null) {
      localizacaoQueimaNotifier.value = LatLng(
        latitudeQueimaInst!,
        longitudeQueimaInst!,
      );
    }
  }

  void _inicializarAlunos(FormacaoBrigadistaFlorestal formacao) {
    if (formacao.alunosMatriculados.isNotEmpty) {
      alunos = List.from(formacao.alunosMatriculados);
    }
  }

  void _inicializarArquivos(FormacaoBrigadistaFlorestal formacao) {
    if (formacao.arquivos.isNotEmpty) {
      arquivosNotifier.value = formacao.arquivos
          .map((path) => XFile(path))
          .toList();
    }
  }

  // ============================================================================
  // SETTERS
  // ============================================================================
  void setDeslocamentoInicial(DateTime? value) {
    if (_isDisposed) return;
    deslocamentoInicialGuarnicao = value;
    notifyListeners();
  }

  void setDeslocamentoFinal(DateTime? value) {
    if (_isDisposed) return;
    deslocamentoFinalGuarnicao = value;
    notifyListeners();
  }

  void setLocalizacao(LatLng latLng) {
    if (_isDisposed) return;
    latitudeAtuacao = latLng.latitude;
    longitudeAtuacao = latLng.longitude;
    localizacaoNotifier.value = latLng;
    notifyListeners();
  }

  void setLocalizacaoQueima(LatLng latLng) {
    if (_isDisposed) return;
    latitudeQueimaInst = latLng.latitude;
    longitudeQueimaInst = latLng.longitude;
    localizacaoQueimaNotifier.value = latLng;

    latitudeQueimaController.text = latLng.latitude.toStringAsFixed(6);
    longitudeQueimaController.text = latLng.longitude.toStringAsFixed(6);

    notifyListeners();
  }

  void setQueimaInstrucao(bool value) {
    if (_isDisposed) return;
    queimaInstrucaoRealizada = value;
    if (!value) {
      latitudeQueimaInst = null;
      longitudeQueimaInst = null;
      latitudeQueimaController.clear();
      longitudeQueimaController.clear();
      localizacaoQueimaNotifier.value = null;
    }
    notifyListeners();
  }

  void setAcidentesIncidentes(bool value) {
    if (_isDisposed) return;
    acidentesIncidentesOcorridos = value;
    if (!value) {
      descricaoAcidenteIncidente = null;
    }
    notifyListeners();
  }

  void atualizarArquivos(List<XFile> novosArquivos) {
    if (_isDisposed) return;
    arquivosNotifier.value = novosArquivos;
  }

  void adicionarArquivos(List<XFile> novos) {
    if (_isDisposed) return;
    arquivosNotifier.value = [...arquivosNotifier.value, ...novos];
  }

  void removerArquivo(int index) {
    if (_isDisposed) return;
    final lista = [...arquivosNotifier.value];
    lista.removeAt(index);
    arquivosNotifier.value = lista;
  }

  // ============================================================================
  // VALIDAÇÃO
  // ============================================================================
  bool validarFormulario() {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (latitudeAtuacao == null || longitudeAtuacao == null) {
      return false;
    }

    if (deslocamentoInicialGuarnicao == null) {
      return false;
    }

    if (deslocamentoFinalGuarnicao == null) {
      return false;
    }

    if (qtdBrigadistasFormados <= 0) {
      return false;
    }

    if (historicoController.text.trim().isEmpty) {
      return false;
    }

    if (queimaInstrucaoRealizada) {
      if (latitudeQueimaInst == null || longitudeQueimaInst == null) {
        return false;
      }
    }

    if (acidentesIncidentesOcorridos) {
      if (descricaoAcidenteIncidente == null ||
          descricaoAcidenteIncidente!.trim().isEmpty) {
        return false;
      }
    }

    return true;
  }

  // ============================================================================
  // SALVAMENTO - FLUXO OTIMIZADO (CLEAN CODE)
  // ============================================================================
  Future<String?> salvar() async {
    if (_salvando) {
      return "Salvamento já em andamento.";
    }

    if (!validarFormulario()) {
      return "Preencha os campos obrigatórios!";
    }

    _salvando = true;
    _setLoading(true);
    
    bool sucesso = false; // FLAG DE SUCESSO

    try {
      if (kDebugMode) {
        debugPrint('═════════════════════════════════════════════════════════');
        debugPrint('📋 [SALVAR] Iniciando salvamento FORMAÇÃO');
        debugPrint('═════════════════════════════════════════════════════════');
        debugPrint('   - isAvulso: $_isAvulso');
        debugPrint('   - QTS alterado: ${!qtsSeguidoConforme}');
        debugPrint('   - arquivos: ${arquivosNotifier.value.length}');
      }

      // 1. Garantir header (offline/LOC)
      await _garantirRegistroHeader();

      if (kDebugMode) debugPrint('✅ [SALVAR] Header criado: $_idRegistroAtual');

      // 2. Montar dados
      final formacao = _construirModelo();
      final anexosParaEnvio = List<XFile>.from(arquivosNotifier.value);

      // 3. Salvar via service
      if (kDebugMode) {
        debugPrint('📤 [SALVAR] Enviando via service: dados + ${anexosParaEnvio.length} anexo(s)');
      }

      await _service.salvarResposta(
        resposta: formacao,
        arquivos: anexosParaEnvio.isNotEmpty ? anexosParaEnvio : null,
        descricaoAvulsa: _isAvulso ? dadosIniciais?.descricao : null,
        isAvulso: _isAvulso,
      );

      if (kDebugMode) debugPrint('✅ [SALVAR] Salvamento via service bem-sucedido');

      sucesso = true; // MARCA SUCESSO ANTES DO RETURN
      return null;

    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [SALVAR] Erro: $e');
        debugPrint(stackTrace.toString());
      }
      return _tratarErroSalvamento(e);

    } finally {
      if (!_isDisposed) {
        _salvando = false;
        
        // SÓ DESLIGA O LOADING SE DEU ERRO
        if (!sucesso) {
          _setLoading(false);
        }
      }
    }
  }

  // ============================================================================
  // GARANTIR HEADER
  // ============================================================================
  Future<void> _garantirRegistroHeader() async {
    if (_idRegistroAtual != null) return;

    if (dadosIniciais == null) {
      throw Exception("Dados iniciais não fornecidos.");
    }

    final userSub = await AuthService().getUserSub();
    if (userSub == null) {
      throw Exception("Usuário não identificado.");
    }

    final novoRegistro = await LocalDbService.criarRegistroAvulsoOffline(
      categoria: dadosIniciais!.categoria,
      lat: dadosIniciais!.latitude,
      long: dadosIniciais!.longitude,
      userSub: userSub,
      descricao: dadosIniciais!.descricao,
    );

    _idRegistroAtual = novoRegistro.id;

    if (kDebugMode) {
      debugPrint('✅ [GARANTIR HEADER] Registro criado: $_idRegistroAtual');
    }
  }

  // ============================================================================
  // CONSTRUIR MODELO
  // ============================================================================
 FormacaoBrigadistaFlorestal _construirModelo() {
    if (_idRegistroAtual == null) {
      throw Exception("ID não definido.");
    }

    return FormacaoBrigadistaFlorestal(
      id: _idRegistroAtual!,
      latitudeAtuacao: latitudeAtuacao,
      longitudeAtuacao: longitudeAtuacao,
      deslocamentoInicialGuarnicao: deslocamentoInicialGuarnicao,
      deslocamentoFinalGuarnicao: deslocamentoFinalGuarnicao,
      qtdBrigadistasCapacitados: qtdBrigadistasFormados,
      queimaInstrucaoRealizada: queimaInstrucaoRealizada,
      latitudeQueimaInst: latitudeQueimaInst,
      longitudeQueimaInst: longitudeQueimaInst,
      acidentesIncidentesOcorridos: acidentesIncidentesOcorridos,
      descricaoAcidenteIncidente: descricaoAcidenteIncidente,
      historico: historicoController.text.trim(),
      arquivoQtsXFile: arquivoQtsXFile,
      arquivoQtsNovo: !qtsSeguidoConforme ? null : arquivoQtsNovo,
      alunosMatriculados: alunos,
      arquivos: arquivosNotifier.value
          .map((f) => f.path)
          .toList(),
      latitudeDespacho: latitudeDespacho,
      longitudeDespacho: longitudeDespacho,
      deslocamentoInicialDespacho: deslocamentoInicialDespacho,
      deslocamentoFinalDespacho: deslocamentoFinalDespacho,
    );
  }

  // ============================================================================
  // TRATAR ERRO
  // ============================================================================
  String _tratarErroSalvamento(dynamic erro) {
    final mensagem = erro.toString();

    if (mensagem.contains('400') ||
        mensagem.toLowerCase().contains('bad request')) {
      return 'Verifique os campos preenchidos.';
    }

    if (mensagem.contains('EntityNotFoundException')) {
      return 'RegistroOcorrencia não encontrado.';
    }

    if (mensagem.toLowerCase().contains('network') ||
        mensagem.contains('connection')) {
      return 'Erro de conexão. Tente novamente.';
    }

    return 'Erro inesperado: $erro';
  }

  // ============================================================================
  // DISPOSE
  // ============================================================================
  @override
  void dispose() {
    _isDisposed = true;

    _connectivitySubscription.cancel();
    historicoController.dispose();
    latitudeQueimaController.dispose();
    longitudeQueimaController.dispose();
    isOfflineNotifier.dispose();
    localizacaoNotifier.dispose();
    localizacaoQueimaNotifier.dispose();
    arquivosNotifier.dispose();

    super.dispose();
  }
}