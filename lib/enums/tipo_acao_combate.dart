enum TipoAcaoCombate {
  NENHUM("Nenhum"),
  RECONHECIMENTO_PLANEJAMENTO("Reconhecimento e planejamento"),
  COMBATE_INCENDIO_FLORESTAL_DIRETO("Combate a incêndio florestal direto"),
  CONFECCAO_ACEIRO_MANUAL("Confecção de aceiro manual"),
  CONFECCAO_ACEIRO_MECANICO("Confecção aceiro mecânico com apoio de terceiros"),
  REALIZACAO_FOGO_CONTRA_FOGO("Realização de fogo contra fogo"),
  VIGILANCIA("Vigilância"),
  RESCALDO("Rescaldo");

  final String descricao;
  const TipoAcaoCombate(this.descricao);
}