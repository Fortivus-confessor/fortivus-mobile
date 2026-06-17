enum TipoAcaoConscientizacao {
  PALESTRA_CRECHE("Palestra em creche"),
  PALESTRA_CONSCIENTIZACAO("Palestra em escola"),
  PALESTRA_CENTRO_COMUNITARIO("Palestra em centro comunitário"),
  ENTREVISTA_RADIO("Entrevista para rádio"),
  ENTREVISTA_TELEVISAO("Entrevista para televisão"),
  BLITZ_EDUCATIVA("Blitz educativa"),
  OUTRO("Outro");
  final String descricao;
  const TipoAcaoConscientizacao(this.descricao);
}
