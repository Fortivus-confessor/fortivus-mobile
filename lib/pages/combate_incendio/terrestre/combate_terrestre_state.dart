import 'dart:async';
import 'package:fortivus_app/enums/tipo_resultado_incendio_terrestre.dart';
import 'package:fortivus_app/services/responder/responder_terrestre_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:fortivus_app/enums/enums.dart';
import 'package:fortivus_app/model/combate_incendio_terrestre.dart';
import 'package:fortivus_app/model/propriedade_apoio.dart';
import 'package:fortivus_app/model/mobile_registro_avulso_request.dart';
import 'package:fortivus_app/services/auth_service.dart';
import 'package:fortivus_app/services/local_db_service.dart';

class CombateTerrestreState extends ChangeNotifier {
  // ============================================================================
  // CONSTANTES
  // ============================================================================
  static const String categoria = 'COMBATE_INCENDIO_TERRESTRE';

  // ============================================================================
  // DEPENDÊNCIAS
  // ============================================================================
  final ResponderTerrestreService _service = ResponderTerrestreService();
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

  final TextEditingController quilometragemController = TextEditingController();
  final TextEditingController litrosAguaController = TextEditingController();
  final TextEditingController apoioOutroController = TextEditingController();
  final TextEditingController descricaoOperacaoController = TextEditingController();
  final TextEditingController resultadoDiaController = TextEditingController();

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
  XFile? imagemOrigem;
  DateTime? horarioChegada;

  TipoEfetividadeCombate? efetividade;
  Reforco? reforco;
  TipoResultadoIncendioTerrestre? tipoResultado;
  TipoCausaIncendio? origemIncendio;

  Set<TipoAcaoCombate> acoes = {};
  Set<TipoApoioOrgao> apoios = {};
  Set<TipoMaterialUtilizado> materiais = {};
  Set<OrigemAgua> origensAgua = {};

  List<PropriedadeApoio> propriedades = [];

  // ============================================================================
  // GETTERS
  // ============================================================================
  ImagePicker get picker => _picker;
  bool get isOffline => isOfflineNotifier.value;
  LatLng? get localizacao => localizacaoNotifier.value;
  List<XFile> get arquivos => arquivosNotifier.value;

  // ============================================================================
  // FLAGS DE CONTROLE
  // ============================================================================
  bool _isDisposed = false;
  bool _salvando = false;

  // ============================================================================
  // CONSTRUTOR
  // ============================================================================
  CombateTerrestreState({
    required this.registroId,
    required this.dadosIniciais,
    bool isAvulso = false,
  }) {
    _isAvulso = isAvulso;
    if (kDebugMode) {
      debugPrint('🏗️ [TERRESTRE STATE] Construtor chamado');
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
      debugPrint('🚀 [STATE TERRESTRE] _init() chamado');
    }
    _idRegistroAtual = registroId;
    _setupConnectivityListener();
    _checkInitialConnectivity();
    _loadFormData();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
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
      debugPrint('✅ [STATE] Inicializando AVULSO');
      debugPrint('   - Categoria: ${dadosIniciais!.categoria}');
      debugPrint('   - Descrição: ${dadosIniciais!.descricao}');
      debugPrint(
          '   - Localização: (${dadosIniciais!.latitude}, ${dadosIniciais!.longitude})');
    }
    _setLoading(false);

    localizacaoNotifier.value = LatLng(
      dadosIniciais!.latitude,
      dadosIniciais!.longitude,
    );

    if (kDebugMode) {
      debugPrint('   ✅ Campos pré-preenchidos com sucesso');
    }
  }

  Future<void> _carregarDadosExistentes() async {
    try {
      final combate = await _service
          .getResposta<CombateIncendioTerrestre>(
        registroId: _idRegistroAtual!,
        fromJson: (json) => CombateIncendioTerrestre.fromJson(json),
        emptyFactory: (id) => CombateIncendioTerrestre(id: id),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Timeout ao carregar dados');
        },
      );
      _popularFormulario(combate);
    } catch (e) {
      final combateVazio = CombateIncendioTerrestre(id: _idRegistroAtual!);
      _popularFormulario(combateVazio);
    } finally {
      if (!_isDisposed) {
        _setLoading(false);
      }
    }
  }

  void _popularFormulario(CombateIncendioTerrestre combate) {
    quilometragemController.text = combate.quilometragem?.toString() ?? '';
    litrosAguaController.text = combate.quantidadeLitrosAgua?.toString() ?? '';
    apoioOutroController.text = combate.tipoApoioOutro ?? '';
    descricaoOperacaoController.text = combate.historicoDescritivo ?? '';
    resultadoDiaController.text = combate.resultadoOcorrencia ?? '';

    if (combate.latitudeAreaAtuacao != null &&
        combate.longitudeAreaAtuacao != null) {
      localizacaoNotifier.value = LatLng(
        combate.latitudeAreaAtuacao!,
        combate.longitudeAreaAtuacao!,
      );
    }
    eventoFogoGeoJson = combate.eventoFogoGeoJson;
    horarioChegada = combate.horarioChegada;
    efetividade = combate.efetividadeCombate;
    reforco = combate.reforco;
    tipoResultado = combate.tipoResultado;
    origemIncendio = combate.origemIncendio;
    acoes = combate.tipoAcaoCombateIncendio.toSet();
    apoios = combate.tipoApoioOrgao.toSet();
    materiais = combate.tipoMateriaisUtilizados.toSet();
    origensAgua = combate.origemAgua.toSet();
    propriedades = List.from(combate.propriedadesApoio);

    if (combate.imagemOrigemIncendio != null &&
        combate.imagemOrigemIncendio!.isNotEmpty) {
      imagemOrigem = XFile(combate.imagemOrigemIncendio!);
    }

    if (combate.arquivosLocais.isNotEmpty) {
      arquivosNotifier.value =
          combate.arquivosLocais.map((path) => XFile(path)).toList();
    }
  }

  // ============================================================================
  // SETTERS (Todos com proteção de disposed)
  // ============================================================================
  void setLocalizacao(LatLng? value) {
    if (_isDisposed) return;
    localizacaoNotifier.value = value;
    notifyListeners();
  }

  void setImagemOrigem(XFile? value) {
    if (_isDisposed) return;
    imagemOrigem = value;
    notifyListeners();
  }

  void setHorarioChegada(DateTime? value) {
    if (_isDisposed) return;
    horarioChegada = value;
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

  void setTipoResultado(TipoResultadoIncendioTerrestre? value) {
    if (_isDisposed) return;
    tipoResultado = value;
    notifyListeners();
  }

  void setOrigemIncendio(TipoCausaIncendio? value) {
    if (_isDisposed) return;
    origemIncendio = value;
    notifyListeners();
  }

  void setAcoes(Set<TipoAcaoCombate> value) {
    if (_isDisposed) return;
    acoes = value;
    notifyListeners();
  }

  void setApoios(Set<TipoApoioOrgao> value) {
    if (_isDisposed) return;
    apoios = value;
    notifyListeners();
  }

  void setMateriais(Set<TipoMaterialUtilizado> value) {
    if (_isDisposed) return;
    materiais = value;
    notifyListeners();
  }

  void setOrigensAgua(Set<OrigemAgua> value) {
    if (_isDisposed) return;
    origensAgua = value;
    notifyListeners();
  }

  void adicionarPropriedade(PropriedadeApoio propriedade) {
    if (_isDisposed) return;
    propriedades = [...propriedades, propriedade];
    notifyListeners();
  }

  void atualizarPropriedade(int index, PropriedadeApoio propriedade) {
    if (_isDisposed) return;
    propriedades[index] = propriedade;
    notifyListeners();
  }

  void removerPropriedade(int index) {
    if (_isDisposed) return;
    propriedades = [...propriedades]..removeAt(index);
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
    if (_salvando) {
      return "Salvamento já em andamento.";
    }

    if (!validarFormulario()) {
      return "Verifique os campos obrigatórios e a localização no mapa.";
    }
    _salvando = true;
    _setLoading(true);
    bool sucesso = false; 
    try {
      if (kDebugMode) {
        debugPrint('═════════════════════════════════════════════════════════');
        debugPrint('📋 [SALVAR] Iniciando salvamento TERRESTRE');
        debugPrint('═════════════════════════════════════════════════════════');
        debugPrint('   - isAvulso: $_isAvulso');
        debugPrint('   - imagemOrigem: ${imagemOrigem != null ? "SIM ✅" : "NÃO ❌"}');
        debugPrint('   - arquivos: ${arquivosNotifier.value.length}');
      }
      await _garantirRegistroHeader();
      if (kDebugMode) debugPrint('✅ [SALVAR] Header criado: $_idRegistroAtual');
      final combate = _construirModeloCombate();
      final anexosParaEnvio = List<XFile>.from(arquivosNotifier.value);
      if (kDebugMode) {
        debugPrint('📤 [SALVAR] Enviando via service...');
      }
      await _service.salvarResposta(
        resposta: combate,
        arquivos: anexosParaEnvio.isNotEmpty ? anexosParaEnvio : null,
        descricaoAvulsa: _isAvulso ? dadosIniciais?.descricao : null,
        isAvulso: _isAvulso,
      );
      if (kDebugMode) debugPrint('✅ [SALVAR] Salvamento via service bem-sucedido');
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
  CombateIncendioTerrestre _construirModeloCombate() {
    if (_idRegistroAtual == null) {
      throw Exception("ID não definido.");
    }
    
    return CombateIncendioTerrestre(
      id: _idRegistroAtual!,
      latitudeAreaAtuacao: localizacaoNotifier.value!.latitude,
      longitudeAreaAtuacao: localizacaoNotifier.value!.longitude,
      quilometragem: int.tryParse(
        quilometragemController.text.replaceAll('.', ''),
      ),
      horarioChegada: horarioChegada,
      efetividadeCombate: efetividade,
      reforco: reforco,
      tipoAcaoCombateIncendio: acoes.toList(),
      tipoApoioOrgao: apoios.toList(),
      tipoApoioOutro: apoioOutroController.text.trim().isEmpty
          ? null
          : apoioOutroController.text.trim(),
      tipoMateriaisUtilizados: materiais.toList(),
      origemAgua: origensAgua.toList(),
      quantidadeLitrosAgua: int.tryParse(litrosAguaController.text),
      origemIncendio: origemIncendio,
      imagemOrigemXFile: imagemOrigem,
      imagemOrigemIncendio: imagemOrigem?.path,
      houveApoioPropriedadesRurais: propriedades.any((p) => p.tipoInteracao == TipoInteracaoPropriedade.APOIO,),
      houveRecusaColaboracao: propriedades.any((p) => p.tipoInteracao == TipoInteracaoPropriedade.RECUSA,),
      propriedadesApoio: propriedades,
      historicoDescritivo: descricaoOperacaoController.text.trim(),
      tipoResultado: tipoResultado,
      resultadoOcorrencia: tipoResultado ==
              TipoResultadoIncendioTerrestre.OUTRO
          ? resultadoDiaController.text.trim()
          : null,
    );
  }

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
    quilometragemController.dispose();
    litrosAguaController.dispose();
    apoioOutroController.dispose();
    descricaoOperacaoController.dispose();
    resultadoDiaController.dispose();
    isOfflineNotifier.dispose();
    localizacaoNotifier.dispose();
    arquivosNotifier.dispose();
    super.dispose();
  }
}
