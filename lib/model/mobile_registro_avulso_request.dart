
class RegistroAvulsoTemp {
  final int? id;
  final String categoria;
  final double latitude;
  final double longitude;
  final String descricao;

  RegistroAvulsoTemp({
    this.id,
    required this.categoria,
    required this.latitude,
    required this.longitude,
    required this.descricao,
  });

  Map<String, dynamic> toJson() {
    return {
      'categoria': categoria,
      'latitude': latitude,
      'longitude': longitude,
      'descricao': descricao,
    };
  }

  factory RegistroAvulsoTemp.fromJson(Map<String, dynamic> json) {
    return RegistroAvulsoTemp(
      categoria: json['categoria'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      descricao: json['descricao'] as String,
    );
  }

  RegistroAvulsoTemp copyWith({
    String? categoria,
    double? latitude,
    double? longitude,
    String? descricao,
  }) {
    return RegistroAvulsoTemp(
      categoria: categoria ?? this.categoria,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      descricao: descricao ?? this.descricao,
    );
  }

  @override
  String toString() => 'RegistroAvulsoTemp(categoria: $categoria, latitude: $latitude, longitude: $longitude, descricao: $descricao)';
}