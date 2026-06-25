enum TipoEmpregoAereo {
  RECONHECIMENTO,
  LANCAMENTO_AGUA,
  TRANSPORTE_PESSOAL,
  APOIO_LOGISTICO;

  String get descricao {
    switch (this) {
      case TipoEmpregoAereo.RECONHECIMENTO:
        return 'Reconhecimento';
      case TipoEmpregoAereo.LANCAMENTO_AGUA:
        return 'Lançamento de Água';
      case TipoEmpregoAereo.TRANSPORTE_PESSOAL:
        return 'Transporte de Pessoal';
      case TipoEmpregoAereo.APOIO_LOGISTICO:
        return 'Apoio Logístico';
    }
  }
}
