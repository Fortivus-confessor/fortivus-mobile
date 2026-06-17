enum TipoApoioOrgao {
  NENHUM("Nenhum"),
  EXERCITO_BRASILEIRO("Exército brasileiro"),
  MARINHA_BRASILEIRA("Marinha brasileira"),
  FORCA_AEREA_BRASILEIRA("Força aérea brasileira"),
  ICMBIO("ICMBIO"),
  SINFRA("SINFRA"),
  DEFESA_CIVIL_ESTADUAL("Defesa Civil Estadual"),
  DEFESA_CIVIL_MUNICIPAL("Defesa Civil Municipal"),
  IBAMA("IBAMA"),
  SEMA("SEMA"),
  FORCA_NACIONAL("Força Nacional"),
  POLICIA_CIVIL("Policia Civil"),
  POLICIA_MILITAR("Policia Militar"),
  PRF("Policia Rodoviária Federal"),
  PF("Policia Federal"),
  PREFEITURA_MUNICIPAL("Prefeitura Municipal"),
  GUARDA_MUNICIPAL("Guarda Municipal"),
  OUTRO("Outro");

  final String descricao;
  const TipoApoioOrgao(this.descricao);
}