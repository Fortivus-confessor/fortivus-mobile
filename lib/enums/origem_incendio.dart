enum OrigemIncendio {
  RAIO,
  QUEIMADA_LIXO,
  QUEIMA_LENHOSO,
  ACIDENTE_VEICULAR,
  INTENCIONAL,
  EXTRATIVISMO,
  REDE_ELETRICA,
  SEM_INDICIOS;

  String get descricao {
    switch (this) {
      case OrigemIncendio.RAIO:
        return 'Raio';
      case OrigemIncendio.QUEIMADA_LIXO:
        return 'Queimada / Lixo';
      case OrigemIncendio.QUEIMA_LENHOSO:
        return 'Queima de Lenhoso';
      case OrigemIncendio.ACIDENTE_VEICULAR:
        return 'Acidente Veicular';
      case OrigemIncendio.INTENCIONAL:
        return 'Intencional';
      case OrigemIncendio.EXTRATIVISMO:
        return 'Extrativismo';
      case OrigemIncendio.REDE_ELETRICA:
        return 'Rede Elétrica';
      case OrigemIncendio.SEM_INDICIOS:
        return 'Sem Indícios';
    }
  }
}
