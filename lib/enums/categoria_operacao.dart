enum CategoriaOperacao {
  TERRESTRE,
  AEREO,
  MAQUINARIO,
  AQUATICO;

  String get descricao {
    switch (this) {
      case CategoriaOperacao.TERRESTRE:
        return 'Terrestre';
      case CategoriaOperacao.AEREO:
        return 'Aéreo';
      case CategoriaOperacao.MAQUINARIO:
        return 'Maquinário';
      case CategoriaOperacao.AQUATICO:
        return 'Aquático';
    }
  }

  static CategoriaOperacao fromString(String value) {
    return CategoriaOperacao.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CategoriaOperacao.TERRESTRE,
    );
  }
}
