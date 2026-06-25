enum MotivoRecusa {
  PASSAGEM,
  AGUA,
  RECURSOS_NAO_DISPONIBILIZADOS,
  COMBATE,
  RECOMENDACOES,
  CONTRAFOGO_DESORDENADO,
  OUTRO;

  String get descricao {
    switch (this) {
      case MotivoRecusa.PASSAGEM:
        return 'Passagem Negada';
      case MotivoRecusa.AGUA:
        return 'Falta de Água';
      case MotivoRecusa.RECURSOS_NAO_DISPONIBILIZADOS:
        return 'Recursos Não Disponibilizados';
      case MotivoRecusa.COMBATE:
        return 'Recusa ao Combate';
      case MotivoRecusa.RECOMENDACOES:
        return 'Não Seguiu Recomendações';
      case MotivoRecusa.CONTRAFOGO_DESORDENADO:
        return 'Contrafogo Desordenado';
      case MotivoRecusa.OUTRO:
        return 'Outro';
    }
  }
}
