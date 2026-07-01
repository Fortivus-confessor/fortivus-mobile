import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import 'package:fortivus_app/enums/enums.dart';
import 'package:fortivus_app/model/relatorio_aereo.dart';
import 'package:fortivus_app/services/responder/responder_aereo_service.dart';
import 'package:fortivus_app/services/local_db_service.dart';
import 'package:fortivus_app/services/attachment_upload_service.dart';
import 'package:fortivus_app/validation/report_validator.dart';

class CombateAereoState extends ChangeNotifier {
  static const String categoria = 'AEREO';

  final ResponderAereoService _service = ResponderAereoService();
  final ImagePicker _picker = ImagePicker();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  final int? registroId;
  int? _idRegistroAtual;
  int? get idRegistroAtual => _idRegistroAtual;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController horimetroInicialController = TextEditingController();
  final TextEditingController horimetroFinalController = TextEditingController();
  final TextEditingController litrosAguaController = TextEditingController();
  final TextEditingController alijamentosController = TextEditingController();
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

  Duration? tempoOperacaoMinutos;
  DateTime? horarioChegada;

  TipoEmpregoAereo? tipoEmprego;
  EfetividadeCombate? efetividade;
  bool necessidadeReforco = false;
  ResultadoOcorrencia? resultadoOcorrencia;

  Set<OrigemAgua> origensAgua = {};

  // eventoFogoGeoJson kept for LocalizacaoMapaCard compatibility
  String? eventoFogoGeoJson;

  bool _isDisposed = false;
  bool _salvando = false;

  ImagePicker get picker => _picker;
  bool get isOffline => isOfflineNotifier.value;

  CombateAereoState({required this.registroId}) {
    if (kDebugMode) debugPrint('🏗️ [AÉREO STATE] Construtor: registroId=$registroId');
    _init();
  }

  void _init() {
    _idRegistroAtual = registroId;
    _setupConnectivityListener();
    _checkInitialConnectivity();
    _loadFormData();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
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
      final relatorio = await _service.getResposta<RelatorioAereo>(
        despachoId: _idRegistroAtual!,
        fromJson: (json) => RelatorioAereo.fromJson(json),
        emptyFactory: (id) => RelatorioAereo(despachoId: id),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => RelatorioAereo(despachoId: _idRegistroAtual!),
      );
      _popularFormulario(relatorio);
    } catch (e) {
      _popularFormulario(RelatorioAereo(despachoId: _idRegistroAtual!));
    } finally {
      if (!_isDisposed) _setLoading(false);
    }
  }

  void _popularFormulario(RelatorioAereo relatorio) {
    horimetroInicialController.text = relatorio.horimetroInicial?.toString() ?? '';
    horimetroFinalController.text = relatorio.horimetroFinal?.toString() ?? '';
    litrosAguaController.text = relatorio.volumeAguaLitros?.toString() ?? '';
    alijamentosController.text = relatorio.qtdeLancamentos?.toString() ?? '';
    descricaoOperacaoController.text = relatorio.historicoDescritivo ?? '';

    // horasLiquidas → tempoOperacaoMinutos
    if (relatorio.horasLiquidas != null) {
      final parts = relatorio.horasLiquidas!.split(':');
      if (parts.length == 2) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        tempoOperacaoMinutos = Duration(hours: h, minutes: m);
      }
    }

    // tiposEmprego → tipoEmprego (first value)
    if (relatorio.tiposEmprego.isNotEmpty) {
      try {
        tipoEmprego = TipoEmpregoAereo.values.firstWhere(
          (e) => e.name == relatorio.tiposEmprego.first,
        );
      } catch (_) {}
    }

    efetividade = relatorio.efetividadeCombate;
    necessidadeReforco = relatorio.necessidadeReforco;
    resultadoOcorrencia = relatorio.resultadoOcorrencia;
    outroResultadoDescricao = relatorio.outroResultadoDescricao;
    resultadoDiaController.text = relatorio.outroResultadoDescricao ?? '';

    horarioChegada = relatorio.dataInicio;

    if (relatorio.areaAtuacaoLat != null && relatorio.areaAtuacaoLng != null) {
      localizacaoNotifier.value = LatLng(relatorio.areaAtuacaoLat!, relatorio.areaAtuacaoLng!);
    }

    origensAgua = relatorio.origensAgua
        .map((name) {
          try {
            return OrigemAgua.values.firstWhere((e) => e.name == name);
          } catch (_) {
            return null;
          }
        })
        .whereType<OrigemAgua>()
        .toSet();
  }

  String? outroResultadoDescricao;

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

  void setTipoEmprego(TipoEmpregoAereo? value) {
    if (_isDisposed) return;
    tipoEmprego = value;
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

  bool validarFormulario() {
    if (!formKey.currentState!.validate()) return false;
    if (localizacaoNotifier.value == null) return false;
    return true;
  }

  Future<String?> salvar() async {
    if (_salvando) return 'Salvamento já em andamento.';
    if (!validarFormulario()) return 'Preencha os campos obrigatórios e a localização.';
    final erroValidacao = AereoValidator().firstError(this);
    if (erroValidacao != null) return erroValidacao;
    _salvando = true;
    _setLoading(true);
    bool sucesso = false;
    try {
      if (_idRegistroAtual == null) {
        return 'Despacho não identificado.';
      }
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
        debugPrint('❌ [SALVAR AEREO] $e');
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

  RelatorioAereo _construirRelatorio() {
    final String? horasLiquidas;
    if (tempoOperacaoMinutos != null) {
      final h = (tempoOperacaoMinutos!.inMinutes ~/ 60).toString().padLeft(2, '0');
      final m = (tempoOperacaoMinutos!.inMinutes % 60).toString().padLeft(2, '0');
      horasLiquidas = '$h:$m';
    } else {
      horasLiquidas = null;
    }

    return RelatorioAereo(
      despachoId: _idRegistroAtual!,
      horimetroInicial: double.tryParse(horimetroInicialController.text.trim()),
      horimetroFinal: double.tryParse(horimetroFinalController.text.trim()),
      horasLiquidas: horasLiquidas,
      tiposEmprego: tipoEmprego != null ? [tipoEmprego!.name] : [],
      areaAtuacaoLat: localizacaoNotifier.value?.latitude,
      areaAtuacaoLng: localizacaoNotifier.value?.longitude,
      qtdeLancamentos: int.tryParse(alijamentosController.text.trim()),
      houveUsoAgua: litrosAguaController.text.trim().isNotEmpty,
      volumeAguaLitros: int.tryParse(litrosAguaController.text.trim()),
      origensAgua: origensAgua.map((e) => e.name).toList(),
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
