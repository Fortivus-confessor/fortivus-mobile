enum SituacaoDespacho {
  EM_ANDAMENTO,
  PENDENTE_RELATORIO,
  CONCLUIDO;

  String get descricaoApi => name;

  String get label {
    switch (this) {
      case SituacaoDespacho.EM_ANDAMENTO:
        return 'Em Andamento';
      case SituacaoDespacho.PENDENTE_RELATORIO:
        return 'Pendente Relatório';
      case SituacaoDespacho.CONCLUIDO:
        return 'Concluído';
    }
  }

  bool get isAberta =>
      this == SituacaoDespacho.EM_ANDAMENTO ||
      this == SituacaoDespacho.PENDENTE_RELATORIO;

  bool get isConcluido => this == SituacaoDespacho.CONCLUIDO;

  static SituacaoDespacho fromString(String value) {
    return SituacaoDespacho.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SituacaoDespacho.EM_ANDAMENTO,
    );
  }
}
