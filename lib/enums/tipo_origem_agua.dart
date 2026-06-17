enum OrigemAgua {
  NENHUM("Nenhum"),
  HIDRANTE("Hidrante"),
  POCO("Poço"),
  RIO("Rio"),
  LAGO("Lago"),
  REPRESA("Represa"),
  CAIXA_DAGUA("Caixa d'Água"),
  PISCINA("Piscina"),
  CAMINHAO_PIPA("Caminhão Pipa"),
  CISTERNA("Cisterna"),
  ACUDE("Açude"),
  CORREGO("Córrego");

  final String descricao;
  const OrigemAgua(this.descricao);
}