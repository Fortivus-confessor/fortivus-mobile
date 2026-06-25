enum TipoEmpregoMaquinario {
  ABERTURA_ACEIRO,
  COMBATE_DIRETO,
  RESCALDO,
  TRANSPORTE,
  OUTRO;

  String get descricao {
    switch (this) {
      case TipoEmpregoMaquinario.ABERTURA_ACEIRO:
        return 'Abertura de Aceiro';
      case TipoEmpregoMaquinario.COMBATE_DIRETO:
        return 'Combate Direto';
      case TipoEmpregoMaquinario.RESCALDO:
        return 'Rescaldo';
      case TipoEmpregoMaquinario.TRANSPORTE:
        return 'Transporte';
      case TipoEmpregoMaquinario.OUTRO:
        return 'Outro';
    }
  }
}
