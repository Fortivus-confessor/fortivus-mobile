import 'dart:async';
import 'package:fortivus_app/enums/tipo_acao_coscientizacao.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:fortivus_app/model/conscientizacao_educacao_ambiental.dart';
import 'package:fortivus_app/model/mobile_registro_avulso_request.dart';
import 'package:fortivus_app/services/responder/responder_conscientizacao_service.dart';
import 'package:fortivus_app/services/auth_service.dart';
import 'package:fortivus_app/services/local_db_service.dart';

class ConscientizacaoState extends ChangeNotifier {
  // ============================================================================
  // CONSTANTES
  // ============================================================================
  static const String categoria = 'CONSCIENTIZACAO_EDUCACAO_AMBIENTAL';

  // ============================================================================
  // DEPENDÊNCIAS
  // ============================================================================
  final ResponderConscientizacaoService _service = ResponderConscientizacaoService();
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

  final TextEditingController acaoOutroController = TextEditingController();
  final TextEditingController publicoEstimadoController = TextEditingController();
  final TextEditingController historicoController = TextEditingController();
  
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
  final ValueNotifier<List<XFile>> arquivosNotifier = ValueNotifier([]);

  // ============================================================================
  // DADOS DO FORMULÁRIO (Valores EDITÁVEIS)
  // ============================================================================
  bool atividadeNoLocal = true;
  String? eventoFogoGeoJson;
  TipoAcaoConscientizacao? acaoSelecionada;
  DateTime? deslocamentoInicial;
  DateTime? deslocamentoFinal;

  // ============================================================================
  // ✅ DADOS ORIGINAIS DO DESPACHO (Valores IMUTÁVEIS para comparação)
  // ============================================================================
  double? latitudeRegistroOcorrencia;
  double? longitudeRegistroOcorrencia;
  TipoAcaoConscientizacao? acaoPrevistaDespacho;
  DateTime? dataInicialDespacho;
  DateTime? dataFinalDespacho;

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
  ConscientizacaoState({
    required this.registroId,
    required this.dadosIniciais,
    this.latitudeRegistroOcorrencia,
    this.longitudeRegistroOcorrencia,
    this.acaoPrevistaDespacho,
    this.dataInicialDespacho,
    this.dataFinalDespacho,
    bool isAvulso = false,
  }) {
    _isAvulso = isAvulso;
    if (kDebugMode) {
      debugPrint('🏗️ [CONSCIENTIZACAO STATE] Construtor chamado');
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
      debugPrint('🚀 [STATE CONSCIENTIZACAO] _init() chamado');
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

  // ============================================================================
  // CARREGAMENTO DE DADOS
  // ============================================================================
  void _iniciarComDadosTemporarios() {
    if (kDebugMode) {
      debugPrint('✅ [STATE] Inicializando AVULSO CONSCIENTIZAÇÃO');
      debugPrint('   - Descrição: ${dadosIniciais!.descricao}');
      debugPrint('   - Localização: (${dadosIniciais!.latitude}, ${dadosIniciais!.longitude})');
    }
    
    _setLoading(false);

    atividadeNoLocal = false; // ✅ Para avulso, sempre "Não"

    localizacaoNotifier.value = LatLng(
      dadosIniciais!.latitude,
      dadosIniciais!.longitude,
    );

    historicoController.text = dadosIniciais!.descricao;

    if (kDebugMode) {
      debugPrint('   ✅ Campos pré-preenchidos');
    }
  }

  Future<void> _carregarDadosExistentes() async {
    try {
      final conscientizacao =
          await _service.getResposta<ConscientizacaoEducacaoAmbiental>(
        registroId: _idRegistroAtual!,
        fromJson: (json) => ConscientizacaoEducacaoAmbiental.fromJson(json),
        emptyFactory: (id) {
          if (kDebugMode) debugPrint('⚠️ Usando factory fallback');
          return ConscientizacaoEducacaoAmbiental(
            id: id,
            latitudeAreaAtuacao: latitudeRegistroOcorrencia,
            longitudeAreaAtuacao: longitudeRegistroOcorrencia,
            acaoConscientizacao: acaoPrevistaDespacho,
            deslocamentoInicial: dataInicialDespacho,
            deslocamentoFinal: dataFinalDespacho,
            latitudeDespachoOriginal: latitudeRegistroOcorrencia,
            longitudeDespachoOriginal: longitudeRegistroOcorrencia,
            acaoPrevistaDespachoOriginal: acaoPrevistaDespacho,
            dataInicialDespachoOriginal: dataInicialDespacho,
            dataFinalDespachoOriginal: dataFinalDespacho,
          );
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Timeout ao carregar conscientização');
        },
      );

      _popularFormulario(conscientizacao);
    } catch (e) {
      final conscientizacaoFallback = ConscientizacaoEducacaoAmbiental(
        id: _idRegistroAtual!,
        latitudeAreaAtuacao: latitudeRegistroOcorrencia,
        longitudeAreaAtuacao: longitudeRegistroOcorrencia,
        acaoConscientizacao: acaoPrevistaDespacho,
        deslocamentoInicial: deslocamentoInicial,
        deslocamentoFinal: deslocamentoFinal,
        latitudeDespachoOriginal: latitudeRegistroOcorrencia,
        longitudeDespachoOriginal: longitudeRegistroOcorrencia,
        acaoPrevistaDespachoOriginal: acaoPrevistaDespacho,
        dataInicialDespachoOriginal: dataInicialDespacho,
        dataFinalDespachoOriginal: dataFinalDespacho,
      );
      _popularFormulario(conscientizacaoFallback);
    } finally {
      if (!_isDisposed) {
        _setLoading(false);
      }
    }
  }

  void _popularFormulario(ConscientizacaoEducacaoAmbiental conscientizacao) {
    // Controllers
    publicoEstimadoController.text =
        conscientizacao.publicoEstimado?.toString() ?? '';
    acaoOutroController.text = conscientizacao.acaoOutro ?? '';
    historicoController.text = conscientizacao.historico ?? '';

    // Campo booleano
    atividadeNoLocal = conscientizacao.atividadeNoLocal;

    // Ação Selecionada (editável)
    acaoSelecionada = conscientizacao.acaoConscientizacao;

    // ✅ IMPORTANTE: Guardar dados ORIGINAIS do Despacho (imutáveis)
    acaoPrevistaDespacho = conscientizacao.acaoPrevistaDespachoOriginal;
    dataInicialDespacho = conscientizacao.dataInicialDespachoOriginal;
    dataFinalDespacho = conscientizacao.dataFinalDespachoOriginal;
    latitudeRegistroOcorrencia = conscientizacao.latitudeDespachoOriginal;
    longitudeRegistroOcorrencia = conscientizacao.longitudeDespachoOriginal;

    // Datas editáveis (do usuário)
    deslocamentoInicial = conscientizacao.deslocamentoInicial;
    deslocamentoFinal = conscientizacao.deslocamentoFinal;

    // Localização (editável)
    if (conscientizacao.latitudeAreaAtuacao != null &&
        conscientizacao.longitudeAreaAtuacao != null) {
      localizacaoNotifier.value = LatLng(
        conscientizacao.latitudeAreaAtuacao!,
        conscientizacao.longitudeAreaAtuacao!,
      );
    } else {
      localizacaoNotifier.value = null;
    }

    // Arquivos
    if (conscientizacao.arquivosLocais.isNotEmpty) {
      arquivosNotifier.value = conscientizacao.arquivosLocais
          .map((path) => XFile(path))
          .toList();
    }

    notifyListeners();
  }

  // ============================================================================
  // SETTERS (COM PROTEÇÃO)
  // ============================================================================
  void setAtividadeNoLocal(bool value) {
    if (_isDisposed) return;
    atividadeNoLocal = value;
    notifyListeners();
  }

  void setAcaoSelecionada(TipoAcaoConscientizacao? value) {
    if (_isDisposed) return;
    acaoSelecionada = value;
    notifyListeners();
  }

  void setDeslocamentoInicial(DateTime? value) {
    if (_isDisposed) return;
    deslocamentoInicial = value;
    notifyListeners();
  }

  void setDeslocamentoFinal(DateTime? value) {
    if (_isDisposed) return;
    deslocamentoFinal = value;
    notifyListeners();
  }

  void setLocalizacao(LatLng latLng) {
    if (_isDisposed) return;
    localizacaoNotifier.value = latLng;
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

    if (localizacaoNotifier.value == null) {
      return false;
    }

    if (acaoSelecionada == null) {
      return false;
    }

    if (_isAvulso) {
      return true;
    } else {
      // Para despacho normal, precisa de datas
      if (deslocamentoInicial == null || deslocamentoFinal == null) {
        return false;
      }
      return true;
    }
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
        debugPrint('📋 [SALVAR] Iniciando salvamento CONSCIENTIZAÇÃO');
        debugPrint('═════════════════════════════════════════════════════════');
        debugPrint('   - isAvulso: $_isAvulso');
        debugPrint('   - arquivos: ${arquivosNotifier.value.length}');
      }

      // 1. Garantir header (offline/LOC)
      await _garantirRegistroHeader();

      if (kDebugMode) debugPrint('✅ [SALVAR] Header criado: $_idRegistroAtual');

      // 2. Montar dados
      final conscientizacao = _construirModelo();
      final anexosParaEnvio = List<XFile>.from(arquivosNotifier.value);

      // 3. Salvar via service
      if (kDebugMode) {
        debugPrint('📤 [SALVAR] Enviando via service: dados + ${anexosParaEnvio.length} anexo(s)');
      }

      await _service.salvarResposta(
        resposta: conscientizacao,
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
        
        // SÓ DESLIGA O LOADING SE DEU ERRO (A tela fecha em caso de sucesso)
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
  ConscientizacaoEducacaoAmbiental _construirModelo() {
    if (_idRegistroAtual == null) {
      throw Exception("ID não definido.");
    }

    return ConscientizacaoEducacaoAmbiental(
      id: _idRegistroAtual!,
      latitudeAreaAtuacao: localizacaoNotifier.value!.latitude,
      longitudeAreaAtuacao: localizacaoNotifier.value!.longitude,
      atividadeNoLocal: atividadeNoLocal,
      acaoConscientizacao: acaoSelecionada,
      acaoOutro: acaoSelecionada == TipoAcaoConscientizacao.OUTRO
          ? acaoOutroController.text.trim()
          : null,
      deslocamentoInicial: _isAvulso
          ? deslocamentoInicial
          : (deslocamentoInicial ?? dataInicialDespacho),
      deslocamentoFinal: _isAvulso
          ? deslocamentoFinal
          : (deslocamentoFinal ?? dataFinalDespacho),
      publicoEstimado: int.tryParse(publicoEstimadoController.text),
      historico: historicoController.text.trim(),
      latitudeDespachoOriginal: latitudeRegistroOcorrencia,
      longitudeDespachoOriginal: longitudeRegistroOcorrencia,
      acaoPrevistaDespachoOriginal: acaoPrevistaDespacho,
      dataInicialDespachoOriginal: dataInicialDespacho,
      dataFinalDespachoOriginal: dataFinalDespacho,
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

    publicoEstimadoController.dispose();
    acaoOutroController.dispose();
    historicoController.dispose();
    isOfflineNotifier.dispose();
    localizacaoNotifier.dispose();
    arquivosNotifier.dispose();

    super.dispose();
  }
}