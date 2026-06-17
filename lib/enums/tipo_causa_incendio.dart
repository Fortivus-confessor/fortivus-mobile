enum TipoCausaIncendio {
  RAIO("Raio(descarga elétrica atmosférica)"),
  QUEIMADA_ILEGAL_MATERIAL("Queimada ilegal de material lenhoso enleirado"),
  QUEIMADA_ILEGAL_LIXO("Queimada ilegal de lixo e folhas"),
  PROBLEMA_DE_REDE("Problemas na rede elétrica(curto circuito, cabo rompido, etc)"),
  ACAO_INTENCIONAL("Ação intencional(incendiário/criminosa)"),
  ACIDENTE_VEICULAR("Acidente veicular"),
  ATIVIDADE_EXTRATIVISTA("Atividade extrativo(carvão, mel, coleta, etc)"),
  SEM_INCENDIOS_CAUSA("Sem indícios da possível causa");

  final String descricao;
  const TipoCausaIncendio(this.descricao);
}