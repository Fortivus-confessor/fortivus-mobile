enum EfetividadeCombate {
  ALTA,
  MEDIA,
  BAIXA;

  String get descricao {
    switch (this) {
      case EfetividadeCombate.ALTA:
        return 'Alta';
      case EfetividadeCombate.MEDIA:
        return 'Média';
      case EfetividadeCombate.BAIXA:
        return 'Baixa';
    }
  }
}
