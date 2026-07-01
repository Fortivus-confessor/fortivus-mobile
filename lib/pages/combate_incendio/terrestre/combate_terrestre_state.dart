import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import 'package:fortivus_app/enums/enums.dart';
import 'package:fortivus_app/model/relatorio_terrestre.dart';
import 'package:fortivus_app/model/propriedade_apoio.dart';
import 'package:fortivus_app/services/responder/responder_terrestre_service.dart';
import 'package:fortivus_app/services/attachment_upload_service.dart';
import 'package:fortivus_app/validation/report_validator.dart';

class CombateTerrestreState extends ChangeNotifier {
  static const String categoria = 'TERRESTRE';

  final ResponderTerrestreService _service = ResponderTerrestreService();
  final ImagePicker _picker = ImagePicker();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  final int? registroId;
  int? _idRegistroAtual;
  int? get idRegistroAtual => _idRegistroAtual;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController litrosAguaController = TextEditingController();
  final TextEditingController apoioOutroController = TextEditingController();
  final TextEditingController descricaoOperacaoController = TextEditingController();
  final TextEditingController resultadoDiaController = TextEditingController();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    if (_isDisposed) return;
    _isLoading = value;
    notifyListeners();
  }

  final ValueNotifier<bool> isOfflineNotifier = ValueNotifier(false);
  final ValueNotifier<LatLng?> localizacaoNotifier = ValueNotifier(null);
  final ValueNotifier<List<XFile>> arquivosNotifier = ValueNotifier([]);

  String? eventoFogoGeoJson;
  DateTime? horarioChegada;

  EfetividadeCombate? efetividade;
  bool necessidadeReforco = false;
  ResultadoOcorrencia? resultadoOcorrencia;
  OrigemIncendio? possivelOrigemIncendio;

  Set<AcaoCombate> acoes = {};
  Set<OrgaoApoio> apoios = {};
  Set<OrigemAgua> origensAgua = {};

  List<PropriedadeApoio> propriedades = [];

  bool _isDisposed = false;
  bool _salvando = false;

  ImagePicker get picker => _picker;
  bool get isOffline => isOfflineNotifier.value;
  LatLng? get localizacao => localizacaoNotifier.value;

  CombateTerrestreState({required this.registroId}) {
    if (kDebugMode) debugPrint('🏗️ [TERRESTRE STATE] Construtor: registroId=$registroId');
    _init();
  }

  void _init() {
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
    } else {
      _setLoading(false);
    }
  }

  Future<void> _carregarDadosExistentes() async {
    try {
      final relatorio = await _service.getResposta<RelatorioTerrestre>(
        despachoId: _idRegistroAtual!,
        fromJson: (json) => RelatorioTerrestre.fromJson(json),
        emptyFactory: (id) => RelatorioTerrestre(despachoId: id),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => RelatorioTerrestre(despachoId: _idRegistroAtual!),
      );
      _popularFormulario(relatorio);
    } catch (e) {
      _popularFormulario(RelatorioTerrestre(despachoId: _idRegistroAtual!));
    } finally {
      if (!_isDisposed) _setLoading(false);
    }
  }

  void _popularFormulario(RelatorioTerrestre relatorio) {
    litrosAguaController.text = relatorio.volumeAguaLitros?.toString() ?? '';
    apoioOutroController.text = relatorio.outrosOrgaosDescricao ?? '';
    descricaoOperacaoController.text = relatorio.historicoDescritivo ?? '';
    resultadoDiaController.text = relatorio.outroResultadoDescricao ?? '';

    horarioChegada = relatorio.dataInicio;
    efetividade = relatorio.efetividadeCombate;
    necessidadeReforco = relatorio.necessidadeReforco;
    resultadoOcorrencia = relatorio.resultadoOcorrencia;
    possivelOrigemIncendio = relatorio.possivelOrigemIncendio;

    acoes = relatorio.acoesRealizadas.toSet();
    apoios = relatorio.orgaosApoio.toSet();
    origensAgua = relatorio.origensAgua.toSet();
    propriedades = List.from(relatorio.propriedades);

    if (relatorio.areaAtuacaoLat != null && relatorio.areaAtuacaoLng != null) {
      localizacaoNotifier.value = LatLng(relatorio.areaAtuacaoLat!, relatorio.areaAtuacaoLng!);
    }
  }

  void setHorarioChegada(DateTime? value) {
    if (_isDisposed) return;
    horarioChegada = value;
    notifyListeners();
  }

  void setEfetividade(EfetividadeCombate? value) {
    if (_isDisposed) return;
    efetividade = value;
    notifyListeners();
  }

  void setNecessidadeReforco(bool value) {
    if (_isDisposed) return;
    necessidadeReforco = value;
    notifyListeners();
  }

  void setResultadoOcorrencia(ResultadoOcorrencia? value) {
    if (_isDisposed) return;
    resultadoOcorrencia = value;
    notifyListeners();
  }

  void setPossivelOrigemIncendio(OrigemIncendio? value) {
    if (_isDisposed) return;
    possivelOrigemIncendio = value;
    notifyListeners();
  }

  void setAcoes(Set<AcaoCombate> value) {
    if (_isDisposed) return;
    acoes = value;
    notifyListeners();
  }

  void setApoios(Set<OrgaoApoio> value) {
    if (_isDisposed) return;
    apoios = value;
    notifyListeners();
  }

  void setOrigensAgua(Set<OrigemAgua> value) {
    if (_isDisposed) return;
    origensAgua = value;
    notifyListeners();
  }

  void setLocalizacao(LatLng? value) {
    if (_isDisposed) return;
    localizacaoNotifier.value = value;
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

  bool validarFormulario() {
    if (!formKey.currentState!.validate()) return false;
    if (localizacaoNotifier.value == null) return false;
    return true;
  }

  Future<String?> salvar() async {
    if (_salvando) return 'Salvamento já em andamento.';
    if (!validarFormulario()) return 'Verifique os campos obrigatórios e a localização no mapa.';
    final erroValidacao = TerrestreValidator().firstError(this);
    if (erroValidacao != null) return erroValidacao;
    _salvando = true;
    _setLoading(true);
    bool sucesso = false;
    try {
      if (_idRegistroAtual == null) return 'Despacho não identificado.';
      final relatorio = _construirRelatorio();
      await _service.salvarResposta(resposta: relatorio);
      await AttachmentUploadService.instance.salvarOuEnfileirar(
        _idRegistroAtual!,
        arquivosNotifier.value,
        categoria,
      );
      sucesso = true;
      return null;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('❌ [SALVAR TERRESTRE] $e');
        debugPrint(st.toString());
      }
      return _tratarErro(e);
    } finally {
      if (!_isDisposed) {
        _salvando = false;
        if (!sucesso) _setLoading(false);
      }
    }
  }

  RelatorioTerrestre _construirRelatorio() {
    final houveApoio = propriedades.any((p) => p.tipoRegistro == TipoRegistro.APOIO);
    final houveRecusa = propriedades.any((p) => p.tipoRegistro == TipoRegistro.RECUSA);
    final litros = int.tryParse(litrosAguaController.text.trim());

    return RelatorioTerrestre(
      despachoId: _idRegistroAtual!,
      acoesRealizadas: acoes.toList(),
      orgaosApoio: apoios.toList(),
      outrosOrgaosDescricao: apoios.contains(OrgaoApoio.OUTROS)
          ? apoioOutroController.text.trim().isNotEmpty
              ? apoioOutroController.text.trim()
              : null
          : null,
      areaAtuacaoLat: localizacaoNotifier.value?.latitude,
      areaAtuacaoLng: localizacaoNotifier.value?.longitude,
      houveUsoAgua: litros != null && litros > 0,
      volumeAguaLitros: litros,
      origensAgua: origensAgua.toList(),
      houveApoioPropriedades: houveApoio,
      houveRecusaPropriedades: houveRecusa,
      propriedades: propriedades,
      possivelOrigemIncendio: possivelOrigemIncendio,
      efetividadeCombate: efetividade,
      necessidadeReforco: necessidadeReforco,
      tiposReforcoNecessarios: const [],
      historicoDescritivo: descricaoOperacaoController.text.trim(),
      resultadoOcorrencia: resultadoOcorrencia,
      outroResultadoDescricao: resultadoOcorrencia == ResultadoOcorrencia.OUTRO
          ? resultadoDiaController.text.trim()
          : null,
      dataInicio: horarioChegada,
    );
  }

  String _tratarErro(dynamic erro) {
    final msg = erro.toString();
    if (msg.contains('400') || msg.toLowerCase().contains('bad request')) {
      return 'Verifique os campos preenchidos.';
    }
    if (msg.toLowerCase().contains('network') || msg.contains('connection')) {
      return 'Erro de conexão. Tente novamente.';
    }
    return 'Erro inesperado: $erro';
  }

  @override
  void dispose() {
    _isDisposed = true;
    _connectivitySubscription.cancel();
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
