class InformacaoApoio {
  final String? localReferencia;
  final String? pessoaContato;
  final String? telefone;
  final String? logisticaDisponivel;
  final List<String> listaArquivo;

  InformacaoApoio({
    this.localReferencia,
    this.pessoaContato,
    this.telefone,
    this.logisticaDisponivel,
    this.listaArquivo = const [],
  });

  factory InformacaoApoio.fromJson(Map<String, dynamic> json) {
    return InformacaoApoio(
      localReferencia: json['localReferencia'],
      pessoaContato: json['pessoaContato'],
      telefone: json['telefone'],
      logisticaDisponivel: json['logisticaDisponivel'],
      listaArquivo: json['listaArquivo'] != null 
          ? List<String>.from(json['listaArquivo']) 
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'localReferencia': localReferencia,
      'pessoaContato': pessoaContato,
      'telefone': telefone,
      'logisticaDisponivel': logisticaDisponivel,
      'listaArquivo': listaArquivo,
    };
  }
}

class PistaPouso {
  final double? latitude;
  final double? longitude;
  final double? comprimento;
  final double? largura;
  final String? tipoCaptacaoAgua;
  final List<String> listaArquivo;

  PistaPouso({
    this.latitude,
    this.longitude,
    this.comprimento,
    this.largura,
    this.tipoCaptacaoAgua,
    this.listaArquivo = const [],
  });

  factory PistaPouso.fromJson(Map<String, dynamic> json) {
    return PistaPouso(
      latitude: json['latitude'],
      longitude: json['longitude'],
      comprimento: json['comprimento'],
      largura: json['largura'],
      tipoCaptacaoAgua: json['tipoCaptacaoAgua'],
      listaArquivo: json['listaArquivo'] != null 
          ? List<String>.from(json['listaArquivo']) 
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'comprimento': comprimento,
      'largura': largura,
      'tipoCaptacaoAgua': tipoCaptacaoAgua,
      'listaArquivo': listaArquivo,
    };
  }
  bool get hasCoordinates => latitude != null && longitude != null;
}