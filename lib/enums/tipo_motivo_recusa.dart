enum TipoMotivoRecusa {
  NAO_AUTORIZOU_PASSAGEM("Não autorizou passagem pela propriedade"),
  RECUSOU_FORNECIMENTO_AGUA("Recusou fornecimento de água"),
  NAO_DISPONIBILIZOU_RECURSOS_DISPONIVEIS("Não disponibilizou recursos disponíveis na propriedade"),
  RECUSOU_COMBATE_INCENDIO("Se recusou a combater o incêndio florestal"),
  RECUSOU_ATENDER_RECOMENDACOES("Se recusou a atender as recomendações da guarnição do CBMMT"),
  REALIZOU_CONTRAFOGO_DESORDENADA("Realizou fogo contrafogo de maneira desordenada com o CBMMT"),
  OUTRO("Outro");

  final String descricao;
  const TipoMotivoRecusa(this.descricao);
}
