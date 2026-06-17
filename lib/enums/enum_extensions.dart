import 'enums.dart';

extension StringToEnum on String {
  TipoAcaoCombate toTipoAcaoCombateIncendio() {
    return TipoAcaoCombate.values.firstWhere(
      (e) => e.name == this,
      orElse: () => TipoAcaoCombate.NENHUM,
    );
  }

  TipoApoioOrgao toTipoApoioOrgao() {
    return TipoApoioOrgao.values.firstWhere(
      (e) => e.name == this,
      orElse: () => TipoApoioOrgao.NENHUM,
    );
  }

  TipoAreaAtuacao toTipoAreaAtuacao() {
    return TipoAreaAtuacao.values.firstWhere(
      (e) => e.name == this,
      orElse: () => TipoAreaAtuacao.NENHUM,
    );
  }

  TipoCausaIncendio toTipoCausaIncendio() {
    return TipoCausaIncendio.values.firstWhere(
      (e) => e.name == this,
      orElse: () => TipoCausaIncendio.SEM_INCENDIOS_CAUSA,
    );
  }

  TipoMaterialUtilizado toTipoMateriaisUtilizados() {
    return TipoMaterialUtilizado.values.firstWhere(
      (e) => e.name == this,
      orElse: () => TipoMaterialUtilizado.NENHUM,
    );
  }
}