import 'package:fortivus_app/pages/combate_incendio/aereo/combate_aereo_state.dart';
import 'package:fortivus_app/pages/combate_incendio/maquinario/combate_maquinario_state.dart';
import 'package:fortivus_app/pages/combate_incendio/terrestre/combate_terrestre_state.dart';

// ─── CONTRATO ─────────────────────────────────────────────────────────────────

typedef ValidationErrors = Map<String, String>;

/// Validador genérico. T = state do formulário.
/// Retorna mapa campo→erro; campo ausente no mapa = sem erro.
abstract class ReportValidator<T> {
  ValidationErrors validate(T state);

  bool isValid(T state) => validate(state).isEmpty;

  /// Lança a validação e retorna a primeira mensagem de erro, ou null.
  String? firstError(T state) => validate(state).values.firstOrNull;
}

// ─── VALIDADOR TERRESTRE ───────────────────────────────────────────────────────

class TerrestreValidator extends ReportValidator<CombateTerrestreState> {
  @override
  ValidationErrors validate(CombateTerrestreState s) {
    final errors = <String, String>{};

    if (s.acoes.isEmpty) {
      errors['acoesRealizadas'] = 'Informe ao menos uma ação de combate realizada.';
    }
    if (s.efetividade == null) {
      errors['efetividadeCombate'] = 'Selecione a efetividade do combate.';
    }
    if (s.resultadoOcorrencia == null) {
      errors['resultadoOcorrencia'] = 'Selecione o resultado da ocorrência.';
    }
    if (s.descricaoOperacaoController.text.trim().isEmpty) {
      errors['historicoDescritivo'] = 'Descreva o histórico da operação.';
    }
    if (s.possivelOrigemIncendio == null) {
      errors['possivelOrigemIncendio'] = 'Informe a possível origem do incêndio.';
    }
    final temAgua = s.origensAgua.isNotEmpty;
    final litrosStr = s.litrosAguaController.text.trim();
    if (temAgua && (litrosStr.isEmpty || double.tryParse(litrosStr) == null)) {
      errors['volumeAgua'] = 'Informe o volume de água utilizado.';
    }

    return errors;
  }
}

// ─── VALIDADOR AÉREO ──────────────────────────────────────────────────────────

class AereoValidator extends ReportValidator<CombateAereoState> {
  @override
  ValidationErrors validate(CombateAereoState s) {
    final errors = <String, String>{};

    if (s.tipoEmprego == null) {
      errors['tipoEmprego'] = 'Selecione o tipo de emprego da aeronave.';
    }
    if (s.efetividade == null) {
      errors['efetividadeCombate'] = 'Selecione a efetividade do combate.';
    }
    if (s.resultadoOcorrencia == null) {
      errors['resultadoOcorrencia'] = 'Selecione o resultado da ocorrência.';
    }
    if (s.descricaoOperacaoController.text.trim().isEmpty) {
      errors['historicoDescritivo'] = 'Descreva o histórico da operação.';
    }
    final horimetroInicial = double.tryParse(s.horimetroInicialController.text);
    final horimetroFinal = double.tryParse(s.horimetroFinalController.text);
    if (horimetroInicial == null) {
      errors['horimetroInicial'] = 'Horímetro inicial inválido.';
    }
    if (horimetroFinal == null) {
      errors['horimetroFinal'] = 'Horímetro final inválido.';
    }
    if (horimetroInicial != null && horimetroFinal != null && horimetroFinal < horimetroInicial) {
      errors['horimetroFinal'] = 'Horímetro final deve ser maior que o inicial.';
    }
    if (s.tempoOperacaoMinutos == null) {
      errors['tempoOperacao'] = 'Informe o tempo de operação.';
    }

    return errors;
  }
}

// ─── VALIDADOR MAQUINÁRIO ─────────────────────────────────────────────────────

class MaquinarioValidator extends ReportValidator<CombateMaquinarioState> {
  @override
  ValidationErrors validate(CombateMaquinarioState s) {
    final errors = <String, String>{};

    if (s.tipoEmprego == null) {
      errors['tipoEmprego'] = 'Selecione o tipo de emprego do maquinário.';
    }
    if (s.efetividade == null) {
      errors['efetividadeCombate'] = 'Selecione a efetividade do combate.';
    }
    if (s.resultadoOcorrencia == null) {
      errors['resultadoOcorrencia'] = 'Selecione o resultado da ocorrência.';
    }
    if (s.descricaoOperacaoController.text.trim().isEmpty) {
      errors['historicoDescritivo'] = 'Descreva o histórico da operação.';
    }

    return errors;
  }
}

// ─── FACTORY ──────────────────────────────────────────────────────────────────

class ReportValidatorFactory {
  static ReportValidator<dynamic> forCategoria(String categoria) {
    return switch (categoria.toUpperCase()) {
      'AEREO'      => AereoValidator(),
      'MAQUINARIO' => MaquinarioValidator(),
      _            => TerrestreValidator(),
    };
  }
}
