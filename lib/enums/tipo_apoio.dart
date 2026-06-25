enum TipoApoio {
  MAQUINARIO,
  MAO_DE_OBRA,
  OUTRO;

  String get descricao {
    switch (this) {
      case TipoApoio.MAQUINARIO:
        return 'Maquinário';
      case TipoApoio.MAO_DE_OBRA:
        return 'Mão de Obra';
      case TipoApoio.OUTRO:
        return 'Outro';
    }
  }
}
