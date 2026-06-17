enum TipoAssuntosAbordados {
  NECESSIDADE_INTEGRACAO("Necessidade de integração com o SICRAIF"),
  CONSTRUCAO_MANUTENCAO_ACEIRO("Construção e manutenção de aceiros"),
  MANUTENCAO_MAQUINARIO("Manutenção de maquinários"),
  ORIENTACAO_PERIODO_PROIBITIVO("Orientação sobre o período proibitivo de queimadas em Mato Grosso");
  final String descricao;
  const TipoAssuntosAbordados(this.descricao);
}