import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import 'package:fortivus_app/enums/tipo_acao_ronda.dart';
import 'package:fortivus_app/enums/tipo_assuntos_abordados.dart';
import 'package:fortivus_app/model/ronda.dart';
import 'package:fortivus_app/model/mobile_registro_avulso_request.dart';
import 'package:fortivus_app/services/responder/responder_ronda_service.dart';
import 'package:fortivus_app/services/auth_service.dart';
import 'package:fortivus_app/services/local_db_service.dart';

class RondaState extends ChangeNotifier {
  // ============================================================================
  // CONSTANTES
  // ============================================================================
  static const String categoria = 'RONDA';

  // ============================================================================
  // DEPENDÊNCIAS
  // ============================================================================
  final ResponderRondaService _service = ResponderRondaService();  
  final ImagePicker _picker = ImagePicker();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  // ============================================================================
  // IDENTIFICAÇÃO
  // ============================================================================
  final int? registroId;
  final RegistroAvulsoTemp? dadosIniciais;
  
  int? _idRegistroAtual;
  int? get idRegistroAtual => _idRegistroAtual;

  // ✅ NOVO: Flag isAvulso com late final
  late final bool _isAvulso;
  bool get isAvulso => _isAvulso;

  // ============================================================================
  // FORM STATE
  // ============================================================================
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // ============================================================================
  // CONTROLLERS
  // ============================================================================
  final TextEditingController pessoasAtingidasController =
      TextEditingController();
  final TextEditingController acaoOutroController = TextEditingController();

  // ============================================================================
  // LOADING STATE
  // ============================================================================
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
  // DADOS DO FORMULÁRIO
  // ============================================================================
  String? eventoFogoGeoJson;
  Set<TipoAcaoRonda> acoesSelecionadas = {};
  Set<TipoAssuntosAbordados> assuntosSelecionados = {};

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
  RondaState({
    required this.registroId,
    required this.dadosIniciais,
  }) {
    _isAvulso = registroId == null;  // ✅ NOVO: Detectar avulso
    if (kDebugMode) {
      debugPrint('🏗️ [RONDA STATE] Construtor chamado');
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
      debugPrint('🚀 [STATE RONDA] _init() chamado');
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
      debugPrint('✅ [STATE] Inicializando AVULSO RONDA');
      debugPrint('   - Descrição: ${dadosIniciais!.descricao}');
      debugPrint('   - Localização: (${dadosIniciais!.latitude}, ${dadosIniciais!.longitude})');
    }
    _setLoading(false);
    localizacaoNotifier.value = LatLng(
      dadosIniciais!.latitude,
      dadosIniciais!.longitude,
    );

    if (kDebugMode) {
      debugPrint('   ✅ Localização pré-preenchida');
    }
  }

  Future<void> _carregarDadosExistentes() async {
    try {
      final ronda = await _service.getResposta<Ronda>(
        registroId: _idRegistroAtual!,
        fromJson: (json) => Ronda.fromJson(json),
        emptyFactory: (id) => Ronda(id: id),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Tempo limite excedido ao carregar dados');
        },
      );

      _popularFormulario(ronda);
    } catch (e) {
      final rondaVazia = Ronda(id: _idRegistroAtual!);
      _popularFormulario(rondaVazia);
    } finally {
      if (!_isDisposed) {
        _setLoading(false);
      }
    }
  }

  void _popularFormulario(Ronda ronda) {
    // Controllers
    pessoasAtingidasController.text =
        ronda.quantidadePessoasAtingidas?.toString() ?? '';
    acaoOutroController.text = ronda.acaoRondaOutro ?? '';

    // Sets
    if (ronda.acaoRonda != null) {
      acoesSelecionadas = ronda.acaoRonda!.toSet();
    }
    if (ronda.assuntosAbordados != null) {
      assuntosSelecionados = ronda.assuntosAbordados!.toSet();
    }

    // Localização
    if (ronda.latitudeAreaAtuacao != null &&
        ronda.longitudeAreaAtuacao != null) {
      localizacaoNotifier.value = LatLng(
        ronda.latitudeAreaAtuacao!,
        ronda.longitudeAreaAtuacao!,
      );
    }

    // GeoJSON
    eventoFogoGeoJson = ronda.eventoFogoGeoJson;

    // Arquivos
    if (ronda.arquivosLocais.isNotEmpty) {
      arquivosNotifier.value =
          ronda.arquivosLocais.map((path) => XFile(path)).toList();
    }

    notifyListeners();
  }

  // ============================================================================
  // SETTERS (COM PROTEÇÃO)
  // ============================================================================
  void setAcoesSelecionadas(Set<TipoAcaoRonda> value) {
    if (_isDisposed) return;
    acoesSelecionadas = value;
    notifyListeners();
  }

  void setAssuntosSelecionados(Set<TipoAssuntosAbordados> value) {
    if (_isDisposed) return;
    assuntosSelecionados = value;
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

    if (acoesSelecionadas.isEmpty) {
      return false;
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
        debugPrint('📋 [SALVAR] Iniciando salvamento RONDA');
        debugPrint('═════════════════════════════════════════════════════════');
        debugPrint('   - isAvulso: $_isAvulso');
        debugPrint('   - arquivos: ${arquivosNotifier.value.length}');
      }

      // 1. Garantir header
      await _garantirRegistroHeader();

      if (kDebugMode) debugPrint('✅ [SALVAR] Header criado: $_idRegistroAtual');

      // 2. Montar dados
      final ronda = _construirModeloRonda();
      final anexosParaEnvio = List<XFile>.from(arquivosNotifier.value);

      // 3. Salvar via service
      if (kDebugMode) {
        debugPrint('📤 [SALVAR] Enviando via service: dados + ${anexosParaEnvio.length} anexo(s)');
      }

      await _service.salvarResposta(
        resposta: ronda,
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
        
        // SÓ DESLIGA O LOADING SE DEU ERRO (pois a tela não vai fechar)
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
  Ronda _construirModeloRonda() {
    if (_idRegistroAtual == null) {
      throw Exception("ID não definido.");
    }

    return Ronda(
      id: _idRegistroAtual!,
      latitudeAreaAtuacao: localizacaoNotifier.value!.latitude,
      longitudeAreaAtuacao: localizacaoNotifier.value!.longitude,
      acaoRonda: acoesSelecionadas.toList(),
      acaoRondaOutro: acoesSelecionadas.contains(TipoAcaoRonda.OUTRO)
          ? acaoOutroController.text.trim()
          : null,
      assuntosAbordados: assuntosSelecionados.toList(),
      quantidadePessoasAtingidas:
          int.tryParse(pessoasAtingidasController.text),
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

    pessoasAtingidasController.dispose();
    acaoOutroController.dispose();

    isOfflineNotifier.dispose();
    localizacaoNotifier.dispose();
    arquivosNotifier.dispose();

    super.dispose();
  }
}