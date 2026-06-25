import 'package:fortivus_app/enums/enums.dart';

class Despacho {
  final int id;
  final int ordemServicoId;
  final String? escalaId;
  final String? responsavelId;
  final CategoriaOperacao categoria;
  final String? descricaoTarefa;
  final SituacaoDespacho status;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final double? latitude;
  final double? longitude;
  final int isSynced;
  final String? userId;

  const Despacho({
    required this.id,
    required this.ordemServicoId,
    this.escalaId,
    this.responsavelId,
    required this.categoria,
    this.descricaoTarefa,
    required this.status,
    this.dataInicio,
    this.dataFim,
    this.latitude,
    this.longitude,
    this.isSynced = 1,
    this.userId,
  });

  bool get isAberto => status.isAberta;
  bool get isConcluido => status.isConcluido;
  String get categoriaDescricao => categoria.descricao;

  factory Despacho.fromJson(Map<String, dynamic> json) {
    return Despacho(
      id: json['id'] as int,
      ordemServicoId: json['ordemServicoId'] as int,
      escalaId: json['escalaId'] as String?,
      responsavelId: json['responsavelId'] as String?,
      categoria: CategoriaOperacao.fromString(
          json['categoria'] as String? ?? 'TERRESTRE'),
      descricaoTarefa: json['descricaoTarefa'] as String?,
      status: SituacaoDespacho.fromString(
          json['status'] as String? ?? 'EM_ANDAMENTO'),
      dataInicio:
          json['dataInicio'] != null ? DateTime.tryParse(json['dataInicio']) : null,
      dataFim: json['dataFim'] != null ? DateTime.tryParse(json['dataFim']) : null,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ordemServicoId': ordemServicoId,
      'escalaId': escalaId,
      'responsavelId': responsavelId,
      'categoria': categoria.name,
      'descricaoTarefa': descricaoTarefa,
      'status': status.name,
      'dataInicio': dataInicio?.toIso8601String(),
      'dataFim': dataFim?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'isSynced': isSynced,
      'userId': userId,
    };
  }

  factory Despacho.fromMap(Map<String, dynamic> map) {
    return Despacho(
      id: map['id'] as int,
      ordemServicoId: map['ordemServicoId'] as int,
      escalaId: map['escalaId'] as String?,
      responsavelId: map['responsavelId'] as String?,
      categoria: CategoriaOperacao.fromString(
          map['categoria'] as String? ?? 'TERRESTRE'),
      descricaoTarefa: map['descricaoTarefa'] as String?,
      status: SituacaoDespacho.fromString(
          map['status'] as String? ?? 'EM_ANDAMENTO'),
      dataInicio:
          map['dataInicio'] != null ? DateTime.tryParse(map['dataInicio']) : null,
      dataFim: map['dataFim'] != null ? DateTime.tryParse(map['dataFim']) : null,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      isSynced: map['isSynced'] as int? ?? 1,
      userId: map['userId'] as String?,
    );
  }

  Despacho copyWith({
    int? id,
    int? ordemServicoId,
    String? escalaId,
    String? responsavelId,
    CategoriaOperacao? categoria,
    String? descricaoTarefa,
    SituacaoDespacho? status,
    DateTime? dataInicio,
    DateTime? dataFim,
    double? latitude,
    double? longitude,
    int? isSynced,
    String? userId,
  }) {
    return Despacho(
      id: id ?? this.id,
      ordemServicoId: ordemServicoId ?? this.ordemServicoId,
      escalaId: escalaId ?? this.escalaId,
      responsavelId: responsavelId ?? this.responsavelId,
      categoria: categoria ?? this.categoria,
      descricaoTarefa: descricaoTarefa ?? this.descricaoTarefa,
      status: status ?? this.status,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isSynced: isSynced ?? this.isSynced,
      userId: userId ?? this.userId,
    );
  }
}
