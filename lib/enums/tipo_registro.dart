enum TipoRegistro {
  APOIO,
  RECUSA;

  String get descricao {
    switch (this) {
      case TipoRegistro.APOIO:
        return 'Apoio';
      case TipoRegistro.RECUSA:
        return 'Recusa';
    }
  }
}
