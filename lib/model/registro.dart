import 'dart:convert';
import 'package:fortivus_app/model/apoio_pista.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class Registro {
  final int id;
  // A ordemServico no banco agora é long, então no Dart ela passa a ser int
  final int ordemServico; 
  final String dataCriacaoFormatada;
  final String dataPreenchimentoFormatada;
  final String cicloGuarnicao;
  final String cicloGuarnicaoGuarnicao;
  final String cicloGuarnicaoVeiculo;
  final String cicloGuarnicaoComandante;
  final String cicloGuarnicaoPostoComandante;
  final String cicloGuarnicaoCondutor;
  final String cicloGuarnicaoPostoCondutor;
  final String cicloGuarnicaoConcatenado;
  final String categoriaDescricao;
  final String descricao;
  final String situacao;
  final String usuario;
  final double? latitudeRo;
  final double? longitudeRo;
  final String categoria;
  final List<Usuario> militares;
  final String? comandoRegionalNome;
  final String? viaturaModelo;
  final String? viaturaIdentificador;
  final InformacaoApoio? informacaoApoio;
  final PistaPouso? pistaPouso;
  bool? isSynced;
  String? userId;

  final String? dataInicioRo;
  final String? dataFinalRo;
  final bool retroativo;

  String? get dataInicioRoFormatada {
    if (dataInicioRo == null || dataInicioRo!.isEmpty) return null;
    try {
      final dateTime = DateTime.parse(dataInicioRo!);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dataInicioRo;
    }
  }

  String? get dataFinalRoFormatada {
    if (dataFinalRo == null || dataFinalRo!.isEmpty) return null;
    try {
      final dateTime = DateTime.parse(dataFinalRo!);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dataFinalRo;
    }
  }

  final String? tipoAcaoConscientizacao;
  final String? acaoOutroConscientizacao;
  final bool? projetosSentinelas;
  final String? deslocamentoInicialDespacho;
  final String? deslocamentoFinalDespacho;
  final String? nomeContato;
  final String? telefoneContato;
  final double? latitudeContato;
  final double? longitudeContato;
  final List<String> arquivosDespachoConscientizacao;

  // Informações de Formação para detalhes
  final String? nomeLocalFormacao;
  final List<String> publicoAlvoFormacao;
  final String? publicoAlvoOutroDescFormacao;
  final String? cargaHorariaFormacao;
  final String? deslocamentoInicialFormacao;
  final String? deslocamentoFinalFormacao;
  final bool? houveContatoPrevioFormacao;
  final String? nomeContatoPrevioFormacao;
  final String? telefoneContatoPrevioFormacao;
  final String? enderecoLocalFormacao;
  final List<String> arquivosDespachoFormacao;

  bool hasValidMilitares() {
    return militares.isNotEmpty;
  }

  List<Usuario> getMilitaresByFuncao(String funcao) {
    return militares.where((m) => 
      m.postoDescricao.toLowerCase() == funcao.toLowerCase()).toList();
  }

  Usuario? getComandante() {
    if (!hasValidMilitares()) return null;
    return militares.firstWhere(
      (m) => m.nome.toLowerCase() == cicloGuarnicaoComandante.toLowerCase() &&
             m.postoDescricao.toLowerCase() == cicloGuarnicaoPostoComandante.toLowerCase(),
      orElse: () => militares.firstWhere(
        (m) => m.postoDescricao.toLowerCase().contains('comandante'),
        orElse: () => Usuario(
          id: '',
          nome: cicloGuarnicaoComandante,
          postoDescricao: cicloGuarnicaoPostoComandante,
          matricula: '',
          nomeGuerra: '',
          comandoRegionalNome: comandoRegionalNome ?? '',
        ),
      ),
    );
  }

  Usuario? getCondutor() {
    if (!hasValidMilitares()) return null;
    return militares.firstWhere(
      (m) => m.nome.toLowerCase() == cicloGuarnicaoCondutor.toLowerCase() &&
             m.postoDescricao.toLowerCase() == cicloGuarnicaoPostoCondutor.toLowerCase(),
      orElse: () => militares.firstWhere(
        (m) => m.postoDescricao.toLowerCase().contains('condutor'),
        orElse: () => Usuario(
          id: '',
          nome: cicloGuarnicaoCondutor,
          postoDescricao: cicloGuarnicaoPostoCondutor,
          matricula: '',
          nomeGuerra: '',
          comandoRegionalNome: comandoRegionalNome ?? '',
        ),
      ),
    );
  }

  Registro({
    required this.id,
    required this.ordemServico,
    required this.dataCriacaoFormatada,
    required this.dataPreenchimentoFormatada,
    required this.cicloGuarnicao,
    required this.cicloGuarnicaoGuarnicao,
    required this.cicloGuarnicaoVeiculo,
    required this.cicloGuarnicaoComandante,
    required this.cicloGuarnicaoPostoComandante,
    required this.cicloGuarnicaoCondutor,
    required this.cicloGuarnicaoPostoCondutor,
    required this.cicloGuarnicaoConcatenado,
    required this.categoriaDescricao,
    required this.descricao,
    required this.situacao,
    required this.usuario,
    this.militares = const [],
    this.latitudeRo,
    this.longitudeRo,
    required this.categoria,
    this.comandoRegionalNome,
    this.viaturaModelo,
    this.viaturaIdentificador,
    this.informacaoApoio,
    this.pistaPouso,

    this.tipoAcaoConscientizacao,
    this.acaoOutroConscientizacao,
    this.projetosSentinelas,
    this.deslocamentoInicialDespacho,
    this.deslocamentoFinalDespacho,
    this.nomeContato,
    this.telefoneContato,
    this.latitudeContato,
    this.longitudeContato,
    this.arquivosDespachoConscientizacao = const [],

    this.nomeLocalFormacao,
    this.publicoAlvoFormacao = const [],
    this.publicoAlvoOutroDescFormacao,
    this.cargaHorariaFormacao,
    this.deslocamentoInicialFormacao,
    this.deslocamentoFinalFormacao,
    this.houveContatoPrevioFormacao,
    this.nomeContatoPrevioFormacao,
    this.telefoneContatoPrevioFormacao,
    this.enderecoLocalFormacao,
    this.arquivosDespachoFormacao = const [],

    this.dataInicioRo,
    this.dataFinalRo,
    this.retroativo = false,

    this.isSynced = true,
    this.userId,
  });

  factory Registro.fromJson(Map<String, dynamic> json) {
    List<Usuario> militaresList = [];
    if (json['militares'] != null && json['militares'] is List) {
      militaresList = (json['militares'] as List)
          .map((militar) => Usuario.fromJson(militar))
          .toList();
    }
    String safeString(dynamic value, {String key = 'codigo'}) {
      if (value == null) return "";
      if (value is Map) {
        return (value[key] ?? value['id'] ?? value['nome'] ?? value.toString()).toString();
      }
      return value.toString();
    }

    InformacaoApoio? apoioTemp;
    if (json['informacaoApoio'] != null) {
      apoioTemp = InformacaoApoio.fromJson(json['informacaoApoio']);
      
      List<String> arquivosApoioSeguros = [];
      if (json['arquivosApoio'] != null) {
        for (var arq in json['arquivosApoio']) {
          if (arq is Map) {
            final url = arq['urlArquivo'] ?? arq['url'];
            if (url != null) arquivosApoioSeguros.add(url.toString());
          } else if (arq is String) {
            arquivosApoioSeguros.add(arq);
          }
        }
      }
      
      apoioTemp = InformacaoApoio(
        localReferencia: apoioTemp.localReferencia,
        pessoaContato: apoioTemp.pessoaContato,
        telefone: apoioTemp.telefone,
        logisticaDisponivel: apoioTemp.logisticaDisponivel,
        listaArquivo: arquivosApoioSeguros,
      );
    }

    PistaPouso? pistaTemp;
    if (json['pistaPouso'] != null) {
      pistaTemp = PistaPouso.fromJson(json['pistaPouso']);
      
      List<String> arquivosPistaSeguros = [];
      if (json['arquivosPista'] != null) {
        for (var arq in json['arquivosPista']) {
          if (arq is Map) {
            final url = arq['urlArquivo'] ?? arq['url'];
            if (url != null) arquivosPistaSeguros.add(url.toString());
          } else if (arq is String) {
            arquivosPistaSeguros.add(arq);
          }
        }
      }
      
      pistaTemp = PistaPouso(
        latitude: pistaTemp.latitude,
        longitude: pistaTemp.longitude,
        comprimento: pistaTemp.comprimento,
        largura: pistaTemp.largura,
        tipoCaptacaoAgua: pistaTemp.tipoCaptacaoAgua,
        listaArquivo: arquivosPistaSeguros,
      );
    }

    List<String> arquivosDespachoList = [];
    if (json['arquivosDespachoConscientizacao'] != null) {
      for (var arq in json['arquivosDespachoConscientizacao']) {
        if (arq is Map && arq['urlArquivo'] != null) {
          arquivosDespachoList.add(arq['urlArquivo'].toString());
        } else if (arq is String) {
          arquivosDespachoList.add(arq);
        }
      }
    }

    List<String> publicoAlvoList = [];
    if (json['publicoAlvoFormacao'] != null) {
      publicoAlvoList = (json['publicoAlvoFormacao'] as List).map((e) => e.toString()).toList();
    }

    List<String> arquivosFormacaoList = [];
    if (json['arquivosDespachoFormacao'] != null) {
      for (var arq in json['arquivosDespachoFormacao']) {
        if (arq is Map && arq['urlArquivo'] != null) {
          arquivosFormacaoList.add(arq['urlArquivo'].toString());
        } else if (arq is String) {
          arquivosFormacaoList.add(arq);
        }
      }
    }

    // Tratamento seguro para a OrdemServico vindo de Map ou direto como inteiro
    int parseOrdemServico(dynamic osJson) {
      if (osJson == null) return 0;
      if (osJson is int) return osJson;
      if (osJson is Map) return (osJson['id'] as int?) ?? 0;
      if (osJson is String) return int.tryParse(osJson) ?? 0;
      return 0;
    }

    return Registro(
      id: json['id'] as int? ?? 0,
      ordemServico: parseOrdemServico(json["ordemServicoId"]), 
      dataCriacaoFormatada: json["dataCriacaoFormatada"] ?? "",
      dataPreenchimentoFormatada: json["dataPreenchimentoFormatada"] ?? "",
      cicloGuarnicao: safeString(json["cicloGuarnicao"], key: 'identificador'),
      cicloGuarnicaoGuarnicao: safeString(json["cicloGuarnicaoGuarnicao"]),
      cicloGuarnicaoVeiculo: safeString(json["cicloGuarnicaoVeiculo"]),
      cicloGuarnicaoComandante: safeString(json["cicloGuarnicaoComandante"]),
      cicloGuarnicaoPostoComandante: safeString(json["cicloGuarnicaoPostoComandante"]),
      cicloGuarnicaoCondutor: safeString(json["cicloGuarnicaoCondutor"]),
      cicloGuarnicaoPostoCondutor: safeString(json["cicloGuarnicaoPostoCondutor"]),
      cicloGuarnicaoConcatenado: json["cicloGuarnicaoConcatenado"]?.toString() ?? "",
      categoriaDescricao: json["categoriaDescricao"] ?? "",
      descricao: json["descricao"] ?? "",
      situacao: json["situacao"] ?? "",
      usuario: safeString(json["usuario"]),
      latitudeRo: json["latitudeRo"] != null ? (json["latitudeRo"] as num).toDouble() : null,
      longitudeRo: json["longitudeRo"] != null ? (json["longitudeRo"] as num).toDouble() : null,
      categoria: json["categoria"] ?? "",
      comandoRegionalNome: json["comandoRegionalNome"]?.toString(),
      viaturaModelo: json["viaturaModelo"]?.toString(),
      viaturaIdentificador: json["viaturaIdentificador"]?.toString(),
      informacaoApoio: apoioTemp,
      pistaPouso: pistaTemp,

      tipoAcaoConscientizacao: json["tipoAcaoConscientizacao"]?.toString(),
      acaoOutroConscientizacao: json["acaoOutroConscientizacao"]?.toString(),
      projetosSentinelas: json["projetosSentinelas"],
      deslocamentoInicialDespacho: json["deslocamentoInicialDespacho"]?.toString(),
      deslocamentoFinalDespacho: json["deslocamentoFinalDespacho"]?.toString(),
      nomeContato: json["nomeContato"]?.toString(),
      telefoneContato: json["telefoneContato"]?.toString(),
      latitudeContato: json["latitudeContato"]?.toDouble(),
      longitudeContato: json["longitudeContato"]?.toDouble(),
      arquivosDespachoConscientizacao: arquivosDespachoList,

      nomeLocalFormacao: json["nomeLocalFormacao"]?.toString(),
      publicoAlvoFormacao: publicoAlvoList,
      publicoAlvoOutroDescFormacao: json["publicoAlvoOutroDescFormacao"]?.toString(),
      cargaHorariaFormacao: json["cargaHorariaFormacao"]?.toString(),
      deslocamentoInicialFormacao: json["deslocamentoInicialFormacao"]?.toString(),
      deslocamentoFinalFormacao: json["deslocamentoFinalFormacao"]?.toString(),
      houveContatoPrevioFormacao: json["houveContatoPrevioFormacao"],
      nomeContatoPrevioFormacao: json["nomeContatoPrevioFormacao"]?.toString(),
      telefoneContatoPrevioFormacao: json["telefoneContatoPrevioFormacao"]?.toString(),
      enderecoLocalFormacao: json["enderecoLocalFormacao"]?.toString(),
      arquivosDespachoFormacao: arquivosFormacaoList,

      isSynced: true,
      militares: militaresList,
      dataInicioRo: json['dataInicioRo']?.toString(),
      dataFinalRo: json['dataFinalRo']?.toString(),
      retroativo: json['retroativo'] == true || json['retroativo'] == 'true',
    );
  }

 factory Registro.fromMap(Map<String, dynamic> map) {
    List<Usuario> militaresList = [];
    
    final dynamic militaresRaw = map['militares'];
    if (militaresRaw != null) {
      try {
        List<dynamic> militaresJson;
        
        if (militaresRaw is List) {
          militaresJson = militaresRaw;
        } else if (militaresRaw is String && militaresRaw.isNotEmpty && militaresRaw != '[]') {
          militaresJson = json.decode(militaresRaw);
        } else {
          militaresJson = [];
        }

        militaresList = militaresJson.map((m) {
          final Map<String, dynamic> mData = m is Map<String, dynamic> ? m : json.decode(m.toString());
          return Usuario(
            id: mData['id']?.toString() ?? '',
            nome: mData['nome']?.toString() ?? '',
            postoDescricao: mData['postoDescricao']?.toString() ?? '',
            matricula: mData['matricula']?.toString() ?? '',
            nomeGuerra: mData['nomeGuerra']?.toString() ?? '',
            comandoRegionalNome: mData['comandoRegionalNome']?.toString() ?? '',
          );
        }).toList();
        
      } catch (e) {
        if (kDebugMode) debugPrint('[Registro] ❌ Erro ao processar militares no ID ${map['id']}: $e');
      }
    }
    
    return Registro(
      id: map['id'] as int? ?? 0,
      ordemServico: map['ordemServico'] as int? ?? 0, // Agora int
      dataCriacaoFormatada: map['dataCriacaoFormatada']?.toString() ?? '',
      dataPreenchimentoFormatada: map['dataPreenchimentoFormatada']?.toString() ?? '',
      cicloGuarnicao: map['cicloGuarnicao']?.toString() ?? '',
      cicloGuarnicaoGuarnicao: map['cicloGuarnicaoGuarnicao']?.toString() ?? '',
      cicloGuarnicaoVeiculo: map['cicloGuarnicaoVeiculo']?.toString() ?? '',
      cicloGuarnicaoComandante: map['cicloGuarnicaoComandante']?.toString() ?? '',
      cicloGuarnicaoPostoComandante: map['cicloGuarnicaoPostoComandante']?.toString() ?? '',
      cicloGuarnicaoCondutor: map['cicloGuarnicaoCondutor']?.toString() ?? '',
      cicloGuarnicaoPostoCondutor: map['cicloGuarnicaoPostoCondutor']?.toString() ?? '',
      cicloGuarnicaoConcatenado: map['cicloGuarnicaoConcatenado']?.toString() ?? '',
      categoriaDescricao: map['categoriaDescricao']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      situacao: map['situacao']?.toString() ?? '',
      usuario: map['usuario']?.toString() ?? '',
      latitudeRo: map['latitudeRo'] != null ? (map['latitudeRo'] as num).toDouble() : null,
      longitudeRo: map['longitudeRo'] != null ? (map['longitudeRo'] as num).toDouble() : null,
      categoria: map['categoria']?.toString() ?? '',
      militares: militaresList,
      comandoRegionalNome: map['comandoRegionalNome'] as String?,
      viaturaModelo: map['viaturaModelo'] as String?,
      viaturaIdentificador: map['viaturaIdentificador'] as String?,
      informacaoApoio: map['informacaoApoio'] != null 
          ? (map['informacaoApoio'] is String 
              ? InformacaoApoio.fromJson(json.decode(map['informacaoApoio'])) 
              : InformacaoApoio.fromJson(map['informacaoApoio']))
          : null,
      pistaPouso: map['pistaPouso'] != null 
          ? (map['pistaPouso'] is String 
              ? PistaPouso.fromJson(json.decode(map['pistaPouso'])) 
              : PistaPouso.fromJson(map['pistaPouso']))
          : null,
      isSynced: map['isSynced'] == 1 || map['isSynced'] == true,
      userId: map['userId'] as String?,
      dataInicioRo: map['dataInicioRo']?.toString(),
      dataFinalRo: map['dataFinalRo']?.toString(),
      retroativo: map['retroativo'] == 1 || map['retroativo'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    final String militaresJson = militares.isEmpty 
        ? '[]' 
        : json.encode(militares.map((m) => {
            'id': m.id,
            'nome': m.nome,
            'postoDescricao': m.postoDescricao,
            'matricula': m.matricula,
            'nomeGuerra': m.nomeGuerra,
            'comandoRegionalNome': m.comandoRegionalNome,
          }).toList());

    return {
      'id': id,
      'ordemServico': ordemServico, // Salva nativamente como inteiro no SQLite
      'dataCriacaoFormatada': dataCriacaoFormatada,
      'dataPreenchimentoFormatada': dataPreenchimentoFormatada,
      'cicloGuarnicao': cicloGuarnicao,
      'cicloGuarnicaoGuarnicao': cicloGuarnicaoGuarnicao,
      'cicloGuarnicaoVeiculo': cicloGuarnicaoVeiculo,
      'cicloGuarnicaoComandante': cicloGuarnicaoComandante,
      'cicloGuarnicaoPostoComandante': cicloGuarnicaoPostoComandante,
      'cicloGuarnicaoCondutor': cicloGuarnicaoCondutor,
      'cicloGuarnicaoPostoCondutor': cicloGuarnicaoPostoCondutor,
      'cicloGuarnicaoConcatenado': cicloGuarnicaoConcatenado,
      'categoriaDescricao': categoriaDescricao,
      'descricao': descricao,
      'situacao': situacao,
      'usuario': usuario,
      'latitudeRo': latitudeRo,
      'longitudeRo': longitudeRo,
      'categoria': categoria,
      'militares': militaresJson, 
      'comandoRegionalNome': comandoRegionalNome ?? '',
      'viaturaModelo': viaturaModelo ?? '',
      'viaturaIdentificador': viaturaIdentificador ?? '',
      'informacaoApoio': informacaoApoio != null ? json.encode(informacaoApoio!.toJson()) : null,
      'pistaPouso': pistaPouso != null ? json.encode(pistaPouso!.toJson()) : null,
      'isSynced': isSynced == true ? 1 : 0,
      'userId': userId ?? '',
      'dataInicioRo': dataInicioRo,
      'dataFinalRo': dataFinalRo,
      'retroativo': retroativo ? 1 : 0,
    };
  }
  
  bool hasValidCoordinates() {
    return latitudeRo != null && longitudeRo != null;
  }
  
  String getCoordinatesForUrl() {
    if (hasValidCoordinates()) {
      return '$latitudeRo,$longitudeRo';
    }
    return '';
  }
}

class Usuario {
  final String id;
  final String nome;
  final String postoDescricao;
  final String matricula;
  final String nomeGuerra;
  final String comandoRegionalNome;

  Usuario({
    required this.id,
    required this.nome,
    required this.postoDescricao,
    required this.matricula,
    required this.nomeGuerra,
    required this.comandoRegionalNome,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id']?.toString() ?? '',
      nome: json['nome'] ?? '',
      postoDescricao: json['postoDescricao'] ?? '',
      matricula: json['matricula'] ?? '',
      nomeGuerra: json['nomeGuerra'] ?? '',
      comandoRegionalNome: json['comandoRegionalNome'] ?? '',
    );
  }

  String getNomeCompleto() {
    return '$postoDescricao $nome';
  }
}