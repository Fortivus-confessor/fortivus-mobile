enum ResultadoOcorrencia {
  EM_ANDAMENTO,
  NECESSIDADE_FISCALIZACAO,
  SEM_INTERVENCAO,
  EXTINTO_RESOLVIDA,
  DESPACHO_INCORRETO,
  OUTRO;

  String get descricao {
    switch (this) {
      case ResultadoOcorrencia.EM_ANDAMENTO:
        return 'Em Andamento';
      case ResultadoOcorrencia.NECESSIDADE_FISCALIZACAO:
        return 'Necessidade de Fiscalização';
      case ResultadoOcorrencia.SEM_INTERVENCAO:
        return 'Sem Necessidade de Intervenção';
      case ResultadoOcorrencia.EXTINTO_RESOLVIDA:
        return 'Extinto / Resolvida';
      case ResultadoOcorrencia.DESPACHO_INCORRETO:
        return 'Despacho Incorreto';
      case ResultadoOcorrencia.OUTRO:
        return 'Outro';
    }
  }
}
