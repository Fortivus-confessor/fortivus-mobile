enum TipoResultadoIncendioTerrestre{
    EM_ANDAMENTO("Em andamento (Combate ativo no momento do preenchimento, sem extinção total.)"),
    NECESSIDADE_EMPREGO(" Necessidade de emprego de equipe de fiscalização (Ex.: queima controlada ou intencional, fogo já extinto, situação monitorada.)"),
    SEM_NECESSIDADE_INTERVENCAO("Sem necessidade de intervenção do CBMMT (Incêndio extinto sozinho ou por outros antes da chegada do CBMMT.)"),
    INCENDIO_EXTINTO("Incêndio extinto pelo CBMMT / Resolvida (Guarnição concluiu o combate e confirmou extinção completa do fogo.)"),
    DESPACHO_INCORRETO("Despacho incorreto (Não foi encontrado nenhum incêndio ou queimada nas imediações.)"),
    OUTRO("Outro");
    final String descricao;
    const TipoResultadoIncendioTerrestre(this.descricao);
}