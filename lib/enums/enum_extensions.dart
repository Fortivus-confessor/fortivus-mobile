import 'enums.dart';

extension StringToEnum on String {
  AcaoCombate toAcaoCombate() {
    return AcaoCombate.values.firstWhere(
      (e) => e.name == this,
      orElse: () => AcaoCombate.NENHUMA,
    );
  }

  OrgaoApoio toOrgaoApoio() {
    return OrgaoApoio.values.firstWhere(
      (e) => e.name == this,
      orElse: () => OrgaoApoio.NENHUM,
    );
  }

  OrigemIncendio toOrigemIncendio() {
    return OrigemIncendio.values.firstWhere(
      (e) => e.name == this,
      orElse: () => OrigemIncendio.SEM_INDICIOS,
    );
  }
}
