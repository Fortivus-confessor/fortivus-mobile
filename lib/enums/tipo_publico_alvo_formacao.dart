enum TipoPublicoAlvoFormacao {
  COMUNIDADE_TRADICIONAL("Comunidade Tradicional"),
  ORGAO_PUBLICO("Órgão Público"),
  EMPRESA_PRIVADA("Empresa Privada"),
  BRIGADISTAS_BRIGADA_ESTADUAL_MISTRA("Brigadistas da Brigada Estadual Mista - BEM"),
  BRIGADISTAS_BRIGADA_MUNICIPAL_MISTA("Brigadistas da Brigada Municipal Mista - BMM"),
  BRIGADISTAS_BRIGADA_VOLUNTARIA("Brigadistas de Brigada Voluntária"),
  FORCAS_ARMADAS("Forças Armadas"),
  OUTRO("Outro");
  final String descricao;
  const TipoPublicoAlvoFormacao(this.descricao);
}