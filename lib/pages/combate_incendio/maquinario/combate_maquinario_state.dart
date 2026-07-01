import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import 'package:fortivus_app/enums/enums.dart';
import 'package:fortivus_app/model/relatorio_maquinario.dart';
import 'package:fortivus_app/services/responder/responder_maquinario_service.dart';
import 'package:fortivus_app/services/attachment_upload_service.dart';
import 'package:fortivus_app/validation/report_validator.dart';

class CombateMaquinarioState extends ChangeNotifier {
  static const String categoria = 'MAQUINARIO';

  final ResponderMaquinarioService _service = ResponderMaquinarioService();
  final ImagePicker _picker = ImagePicker();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  final int? registroId;
  int? _idRegistroAtual;
  int? get idRegistroAtual => _idRegistroAtual;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController horimetroInicialController = TextEditingController();
  final TextEditingController horimetroFinalController = TextEditingController();
  final TextEditingController comprimentoAceiroController = TextEditingController();
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
  DateTime? horaInicioOperacao;
  DateTime? horaFinalOperacao;
  DateTime? horarioChegada;

  TipoEmpregoMaquinario? tipoEmprego;
  EfetividadeCombate? efetividade;
  bool necessidadeReforco = false;
  ResultadoOcorrencia? resultadoOcorrencia;

  bool _isDisposed = false;
  bool _salvando = false;

  ImagePicker get picker => _picker;
  bool get isOffline => isOfflineNotifier.value;

  String get tempoLiquido {
    if (horaInicioOperacao == null || horaFinalOperacao == null) return '--:--';
    final duracao = horaFinalOperacao!.difference(horaInicioOperacao!);
    if (duracao.isNegative) return 'Inválido';
    final h = duracao.inHours;
    final m = duracao.inMinutes.remainder(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  CombateMaquinarioState({required this.registroId}) {
    if (kDebugMode) debugPrint('🏗️ [MAQUINÁRIO STATE] Construtor: registroId=$registroId');
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
      final relatorio = await _service.getResposta<RelatorioMaquinario>(
        despachoId: _idRegistroAtual!,
        fromJson: (json) => RelatorioMaquinario.fromJson(json),
        emptyFactory: (id) => RelatorioMaquinario(despachoId: id),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => RelatorioMaquinario(despachoId: _idRegistroAtual!),
      );
      _popularFormulario(relatorio);
    } catch (e) {
      _popularFormulario(RelatorioMaquinario(despachoId: _idRegistroAtual!));
    } finally {
      if (!_isDisposed) _setLoading(false);
    }
  }

  void _popularFormulario(RelatorioMaquinario relatorio) {
    horimetroInicialController.text = relatorio.horimetroInicial?.toString() ?? '';
    horimetroFinalController.text = relatorio.horimetroFinal?.toString() ?? '';
    comprimentoAceiroController.text = relatorio.comprimentoAceiros?.toString() ?? '';
    descricaoOperacaoController.text = relatorio.historicoDescritivo ?? '';
    resultadoDiaController.text = relatorio.outroResultadoDescricao ?? '';

    if (relatorio.horaInicioOperacao != null) {
      final parts = relatorio.horaInicioOperacao!.split(':');
      if (parts.length >= 2) {
        final now = DateTime.now();
        horaInicioOperacao = DateTime(now.year, now.month, now.day,
            int.tryParse(parts[0]) ?? 0, int.tryParse(parts[1]) ?? 0);
      }
    }
    if (relatorio.horaFimOperacao != null) {
      final parts = relatorio.horaFimOperacao!.split(':');
      if (parts.length >= 2) {
        final now = DateTime.now();
        horaFinalOperacao = DateTime(now.year, now.month, now.day,
            int.tryParse(parts[0]) ?? 0, int.tryParse(parts[1]) ?? 0);
      }
    }

    horarioChegada = relatorio.dataInicio;

    if (relatorio.tiposEmprego.isNotEmpty) {
      try {
        tipoEmprego = TipoEmpregoMaquinario.values.firstWhere(
          (e) => e.name == relatorio.tiposEmprego.first,
        );
      } catch (_) {}
    }

    efetividade = relatorio.efetividadeCombate;
    necessidadeReforco = relatorio.necessidadeReforco;
    resultadoOcorrencia = relatorio.resultadoOcorrencia;

    if (relatorio.areaAtuacaoLat != null && relatorio.areaAtuacaoLng != null) {
      localizacaoNotifier.value = LatLng(relatorio.areaAtuacaoLat!, relatorio.areaAtuacaoLng!);
    }
  }

  void setHoraInicioOperacao(DateTime? value) {
    if (_isDisposed) return;
    horaInicioOperacao = value;
    notifyListeners();
  }

  void setHoraFinalOperacao(DateTime? value) {
    if (_isDisposed) return;
    horaFinalOperacao = value;
    notifyListeners();
  }

  void setHorarioChegada(DateTime? value) {
    if (_isDisposed) return;
    horarioChegada = value;
    notifyListeners();
  }

  void setTipoEmprego(TipoEmpregoMaquinario? value) {
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

  void setLocalizacao(LatLng latLng) {
    if (_isDisposed) return;
    localizacaoNotifier.value = latLng;
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
    if (!validarFormulario()) return 'Preencha os campos obrigatórios e a localização.';
    final erroValidacao = MaquinarioValidator().firstError(this);
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
        debugPrint('❌ [SALVAR MAQUINÁRIO] $e');
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

  RelatorioMaquinario _construirRelatorio() {
    String? fmt(DateTime? dt) {
      if (dt == null) return null;
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    return RelatorioMaquinario(
      despachoId: _idRegistroAtual!,
      horimetroInicial: double.tryParse(horimetroInicialController.text.trim()),
      horimetroFinal: double.tryParse(horimetroFinalController.text.trim()),
      horaInicioOperacao: fmt(horaInicioOperacao),
      horaFimOperacao: fmt(horaFinalOperacao),
      tempoLiquido: (horaInicioOperacao != null && horaFinalOperacao != null)
          ? tempoLiquido
          : null,
      tiposEmprego: tipoEmprego != null ? [tipoEmprego!.name] : [],
      comprimentoAceiros: double.tryParse(
        comprimentoAceiroController.text.trim().replaceAll(',', '.'),
      ),
      areaAtuacaoLat: localizacaoNotifier.value?.latitude,
      areaAtuacaoLng: localizacaoNotifier.value?.longitude,
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
    comprimentoAceiroController.dispose();
    descricaoOperacaoController.dispose();
    resultadoDiaController.dispose();
    isOfflineNotifier.dispose();
    localizacaoNotifier.dispose();
    arquivosNotifier.dispose();
    super.dispose();
  }
}
