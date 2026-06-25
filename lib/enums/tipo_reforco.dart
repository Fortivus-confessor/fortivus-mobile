enum TipoReforco {
  TERRESTRE,
  AEREO,
  MAQUINARIO,
  SCI;

  String get descricao {
    switch (this) {
      case TipoReforco.TERRESTRE:
        return 'Terrestre';
      case TipoReforco.AEREO:
        return 'Aéreo';
      case TipoReforco.MAQUINARIO:
        return 'Maquinário';
      case TipoReforco.SCI:
        return 'SCI';
    }
  }
}
