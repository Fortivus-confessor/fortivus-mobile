enum OrgaoApoio {
  EXERCITO,
  FAB,
  MARINHA,
  PM,
  ICMBIO,
  IBAMA,
  SINFRA,
  SEMA,
  DEFESA_CIVIL,
  PREFEITURA,
  OUTROS,
  NENHUM;

  String get descricao {
    switch (this) {
      case OrgaoApoio.EXERCITO:
        return 'Exército';
      case OrgaoApoio.FAB:
        return 'FAB';
      case OrgaoApoio.MARINHA:
        return 'Marinha';
      case OrgaoApoio.PM:
        return 'Polícia Militar';
      case OrgaoApoio.ICMBIO:
        return 'ICMBio';
      case OrgaoApoio.IBAMA:
        return 'IBAMA';
      case OrgaoApoio.SINFRA:
        return 'SINFRA';
      case OrgaoApoio.SEMA:
        return 'SEMA';
      case OrgaoApoio.DEFESA_CIVIL:
        return 'Defesa Civil';
      case OrgaoApoio.PREFEITURA:
        return 'Prefeitura';
      case OrgaoApoio.OUTROS:
        return 'Outros';
      case OrgaoApoio.NENHUM:
        return 'Nenhum';
    }
  }
}
