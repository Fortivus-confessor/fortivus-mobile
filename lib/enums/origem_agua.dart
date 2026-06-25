enum OrigemAgua {
  NATURAL,
  HIDRANTE,
  RESERVATORIO_FIXO,
  OUTRO;

  String get descricao {
    switch (this) {
      case OrigemAgua.NATURAL:
        return 'Natural';
      case OrigemAgua.HIDRANTE:
        return 'Hidrante';
      case OrigemAgua.RESERVATORIO_FIXO:
        return 'Reservatório Fixo';
      case OrigemAgua.OUTRO:
        return 'Outro';
    }
  }
}
