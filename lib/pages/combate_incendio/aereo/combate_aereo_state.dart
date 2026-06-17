
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import 'package:fortivus_app/enums/enums.dart';
import 'package:fortivus_app/enums/tipo_emprego.dart';
import 'package:fortivus_app/enums/tipo_resultado_incendio.dart';
import 'package:fortivus_app/model/combate_incendio_aereo.dart';
import 'package:fortivus_app/model/mobile_registro_avulso_request.dart';
import 'package:fortivus_app/services/responder/responder_aereo_service.dart';  // ✅ MUDADO
import 'package:fortivus_app/services/auth_service.dart';
import 'package:fortivus_app/services/local_db_service.dart';

class CombateAereoState extends ChangeNotifier {
  // ============================================================================
  // CONSTANTES
  // ============================================================================
  static const String categoria = 'COMBATE_INCENDIO_AEREO';

  // ============================================================================
  // DEPENDÊNCIAS
  // ============================================================================
  final ResponderAereoService _service = ResponderAereoService();  // ✅ MUDADO
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

  // ============================================================================
  // CONTROLLERS
  // ============================================================================
  final TextEditingController horimetroInicialController =
      TextEditingController();
  final TextEditingController horimetroFinalController =
      TextEditingController();
  final TextEditingController litrosAguaController = TextEditingController();
  final TextEditingController alijamentosController = TextEditingController();
  final TextEditingController descricaoOperacaoController =
      TextEditingController();
  final TextEditingController resultadoDiaController =
      TextEditingController();

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
  Duration? tempoOperacaoMinutos;
  DateTime? horarioChegada;
  
  TipoEmprego? tipoEmprego;
  TipoEfetividadeCombate? efetividade;
  Reforco? reforco;
  TipoResultadoIncendio? tipoResultado;
  
  Set<OrigemAgua> origensAgua = {};

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
  CombateAereoState({
    required this.registroId,
    required this.dadosIniciais,
    bool isAvulso = false,
  }) {
    _isAvulso = isAvulso;
    if (kDebugMode) {
      debugPrint('🏗️ [AÉREO STATE] Construtor chamado');
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
      debugPrint('🚀 [STATE AÉREO] _init() chamado');
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
      debugPrint('✅ [STATE] Inicializando AVULSO AÉREO');
      debugPrint('   - Localização: (${dadosIniciais!.latitude}, ${dadosIniciais!.longitude})');
    }
    _setLoading(false);
    
    localizacaoNotifier.value = LatLng(
      dadosIniciais!.latitude,
      dadosIniciais!.longitude,
    );
    if (kDebugMode) {
      debugPrint('   ✅ Campos pré-preenchidos');
    }
  }

  Future<void> _carregarDadosExistentes() async {
    try {
      final combate = await _service.getResposta<CombateIncendioAereo>(
        registroId: _idRegistroAtual!,
        fromJson: (json) => CombateIncendioAereo.fromJson(json),
        emptyFactory: (id) => CombateIncendioAereo(id: id),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Tempo limite excedido ao carregar dados');
        },
      );

      _popularFormulario(combate);
    } catch (e) {
      final combateVazio = CombateIncendioAereo(id: _idRegistroAtual!);
      _popularFormulario(combateVazio);
    } finally {
      if (!_isDisposed) {
        _setLoading(false);
      }
    }
  }

  void _popularFormulario(CombateIncendioAereo combate) {
    // Controllers
    horimetroInicialController.text = combate.horimetroInicial ?? '';
    horimetroFinalController.text = combate.horimetroFinal ?? '';
    litrosAguaController.text = combate.quantidadeLitrosAgua?.toString() ?? '';
    alijamentosController.text = combate.quantidadeAlijamento?.toString() ?? '';
    descricaoOperacaoController.text = combate.historicoDescritivo ?? '';
    resultadoDiaController.text = combate.resultadoOcorrencia ?? '';

    // Duration
    tempoOperacaoMinutos = combate.tempoOperacaoMinutos != null
        ? Duration(minutes: combate.tempoOperacaoMinutos!)
        : null;

    // Enums
    tipoEmprego = combate.tipoEmprego;
    efetividade = combate.efetividadeCombate;
    reforco = combate.reforco;
    tipoResultado = combate.tipoResultado;

    // DateTime
    horarioChegada = combate.horarioChegada;

    // Localização
    if (combate.latitudeAreaAtuacao != null &&
        combate.longitudeAreaAtuacao != null) {
      localizacaoNotifier.value = LatLng(
        combate.latitudeAreaAtuacao!,
        combate.longitudeAreaAtuacao!,
      );
    }

    // Origem da água
    if (combate.origemAgua != null) {
      origensAgua.clear();
      for (var nomeEnum in combate.origemAgua!) {
        try {
          origensAgua.add(
            OrigemAgua.values.firstWhere((e) => e.name == nomeEnum),
          );
        } catch (_) {
          if (kDebugMode) debugPrint('⚠️ OrigemAgua inválida: $nomeEnum');
        }
      }
    }

    // GeoJSON
    eventoFogoGeoJson = combate.eventoFogoGeoJson;

    // Arquivos
    if (combate.arquivosLocais.isNotEmpty) {
      arquivosNotifier.value =
          combate.arquivosLocais.map((path) => XFile(path)).toList();
    }
  }

  // ============================================================================
  // SETTERS (COM PROTEÇÃO)
  // ============================================================================
  void setTempoOperacao(Duration? value) {
    if (_isDisposed) return;
    tempoOperacaoMinutos = value;
    notifyListeners();
  }

  void setHorarioChegada(DateTime? value) {
    if (_isDisposed) return;
    horarioChegada = value;
    notifyListeners();
  }

  void setTipoEmprego(TipoEmprego? value) {
    if (_isDisposed) return;
    tipoEmprego = value;
    notifyListeners();
  }

  void setEfetividade(TipoEfetividadeCombate? value) {
    if (_isDisposed) return;
    efetividade = value;
    notifyListeners();
  }

  void setReforco(Reforco? value) {
    if (_isDisposed) return;
    reforco = value;
    notifyListeners();
  }

  void setTipoResultado(TipoResultadoIncendio? value) {
    if (_isDisposed) return;
    tipoResultado = value;
    notifyListeners();
  }

  void setOrigensAgua(Set<OrigemAgua> value) {
    if (_isDisposed) return;
    origensAgua = value;
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

    return true;
  }

 
  Future<String?> salvar() async {
    if (_salvando) return "Salvamento já em andamento.";
    if (!validarFormulario()) return "Preencha os campos obrigatórios e a localização.";
    _salvando = true;
    _setLoading(true);
    bool sucesso = false; 
    try {
      await _garantirRegistroHeader();
      final combate = _construirModeloCombate();
      final anexosParaEnvio = List<XFile>.from(arquivosNotifier.value);

      await _service.salvarResposta(
        resposta: combate,
        arquivos: anexosParaEnvio.isNotEmpty ? anexosParaEnvio : null,
        descricaoAvulsa: _isAvulso ? dadosIniciais?.descricao : null, 
        isAvulso: _isAvulso,
      );
      sucesso = true; 
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
        if (!sucesso) { 
          _setLoading(false); 
        }
      }
    }
  }

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

  CombateIncendioAereo _construirModeloCombate() {
    if (_idRegistroAtual == null) {
      throw Exception("ID não definido.");
    }

    return CombateIncendioAereo(
      id: _idRegistroAtual!,
      horimetroInicial: horimetroInicialController.text.trim(),
      horimetroFinal: horimetroFinalController.text.trim(),
      tempoOperacaoMinutos: tempoOperacaoMinutos?.inMinutes,
      tipoEmprego: tipoEmprego,
      quantidadeLitrosAgua: int.tryParse(litrosAguaController.text),
      quantidadeAlijamento: int.tryParse(alijamentosController.text),
      origemAgua: origensAgua.map((e) => e.name).toList(),
      latitudeAreaAtuacao: localizacaoNotifier.value!.latitude,
      longitudeAreaAtuacao: localizacaoNotifier.value!.longitude,
      horarioChegada: horarioChegada,
      efetividadeCombate: efetividade,
      reforco: reforco,
      historicoDescritivo: descricaoOperacaoController.text.trim(),
      tipoResultado: tipoResultado,
      resultadoOcorrencia: tipoResultado == TipoResultadoIncendio.OUTRO
          ? resultadoDiaController.text.trim()
          : null,
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

    horimetroInicialController.dispose();
    horimetroFinalController.dispose();
    litrosAguaController.dispose();
    alijamentosController.dispose();
    descricaoOperacaoController.dispose();
    resultadoDiaController.dispose();

    isOfflineNotifier.dispose();
    localizacaoNotifier.dispose();
    arquivosNotifier.dispose();

    super.dispose();
  }
}