enum TipoCategoriaFormulario {
  terrestre('COMBATE_INCENDIO_TERRESTRE'),
  maquinario('COMBATE_INCENDIO_MAQUINARIO'),
  aereo('COMBATE_INCENDIO_AEREO'),
  ronda('RONDA'),
  conscientizacao('CONSCIENTIZACAO_EDUCACAO_AMBIENTAL'),
  formacao('FORMACAO_BRIGADISTA_FLORESTAL');

  final String descricao;
  const TipoCategoriaFormulario(this.descricao);
}