enum AcaoCombate {
  RECONHECIMENTO_PLANEJAMENTO,
  COMBATE_DIRETO,
  ACEIRO_MANUAL,
  ACEIRO_MECANICO_APOIO,
  FOGO_CONTRAFOGO,
  VIGILANCIA,
  RESCALDO,
  NENHUMA;

  String get descricao {
    switch (this) {
      case AcaoCombate.RECONHECIMENTO_PLANEJAMENTO:
        return 'Reconhecimento e Planejamento';
      case AcaoCombate.COMBATE_DIRETO:
        return 'Combate Direto';
      case AcaoCombate.ACEIRO_MANUAL:
        return 'Aceiro Manual';
      case AcaoCombate.ACEIRO_MECANICO_APOIO:
        return 'Aceiro Mecânico de Apoio';
      case AcaoCombate.FOGO_CONTRAFOGO:
        return 'Fogo de Contrafogo';
      case AcaoCombate.VIGILANCIA:
        return 'Vigilância';
      case AcaoCombate.RESCALDO:
        return 'Rescaldo';
      case AcaoCombate.NENHUMA:
        return 'Nenhuma';
    }
  }
}
