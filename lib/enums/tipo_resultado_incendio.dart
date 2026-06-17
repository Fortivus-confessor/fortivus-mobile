enum TipoResultadoIncendio{
    EM_ANDAMENTO("Em andamento (Combate ativo no momento do preenchimento, sem extinção total.)"),
    INCENDIO_EXTINTO("Incêndio extinto pelo CBMMT / Resolvida (Guarnição concluiu o combate e confirmou extinção completa do fogo.)"),
    OUTRO("Outro");
    final String descricao;
    const TipoResultadoIncendio(this.descricao);
}