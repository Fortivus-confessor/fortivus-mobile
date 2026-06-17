import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class User {
  String? id;  
  String? nome;
  String? email;
  String? telefone;
  DateTime? dataNascimento;
  String? matricula;
  String? cpf;
  String? nomeGuerra;
  String? posto;
  String? unidade;
  String? rg;
  String? perfil;
  DateTime? dataAdmissao;
  int? failedAttempts;
  bool? accountLocked;
  String? comandoRegionalId;
  String? token;
  DateTime? expiracaoToken;
  String? hashedPassword;
  String? sub;

  User({
    this.id,
    this.nome,
    this.email,
    this.telefone,
    this.dataNascimento,
    this.matricula,
    this.cpf,
    this.nomeGuerra,
    this.posto,
    this.unidade,
    this.rg,
    this.perfil,
    this.dataAdmissao,
    this.failedAttempts,
    this.accountLocked,
    this.comandoRegionalId,
    this.token,
    this.expiracaoToken,
    this.hashedPassword,
    this.sub,
  });

  static String? extractUserIdFromSub(String? sub) {
    if (sub == null) return null;
    final parts = sub.split(':');
    return parts.length >= 3 ? parts.last : null;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    final userId = map['id'] as String?;
    final subFromMap = map['sub'] as String?;
    final String? calculatedSub = subFromMap ?? (userId != null 
      ? 'f:0b78a94b-a8a1-4b9c-9edf-8bf770ad6a98:$userId' 
      : null);
    return User(
      id: userId,
      nome: map['nome'] as String?,
      email: map['email'] as String?,
      telefone: map['telefone'] as String?,
      dataNascimento: map['dataNascimento'] != null
          ? DateTime.tryParse(map['dataNascimento'] as String)
          : null,
      matricula: map['matricula'] as String?,
      cpf: map['cpf'] as String?,
      nomeGuerra: map['nomeGuerra'] as String?,
      posto: map['posto'] as String?,
      unidade: map['unidade'] as String?,
      rg: map['rg'] as String?,
      perfil: map['perfil'] as String?,
      dataAdmissao: map['dataAdmissao'] != null
          ? DateTime.tryParse(map['dataAdmissao'] as String)
          : null,
      failedAttempts: map['failedAttempts'] as int?,
      accountLocked: map['accountLocked'] == true || map['accountLocked'] == 1,
      comandoRegionalId: map['comandoRegionalId'] as String?,
      token: map['token'] as String?,
      expiracaoToken: map['expiracaoToken'] != null
          ? DateTime.tryParse(map['expiracaoToken'] as String)
          : null,
      hashedPassword: map['hashedPassword'] ?? map['senha'] as String?,
      sub: calculatedSub,
    );
  }

  Map<String, dynamic> toMap() {
    try {
      String? userSub = sub;
      if (userSub == null && token != null) {
        try {
          final decodedToken = JwtDecoder.decode(token!);
          userSub = decodedToken['sub'] as String?;
          if (kDebugMode) {
            debugPrint('[User] Sub extraído do token: $userSub');
          }
          if (id == null && userSub != null) {
            id = extractUserIdFromSub(userSub);
            if (kDebugMode) {
              debugPrint('[User] ID extraído do sub: $id');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[User] Erro ao extrair sub do token: $e');
          }
        }
      }

      return {
        'id': id,
        'nome': nome,
        'email': email,
        'telefone': telefone,
        'dataNascimento': dataNascimento?.toIso8601String(),
        'matricula': matricula,
        'cpf': cpf,
        'nomeGuerra': nomeGuerra,
        'posto': posto,
        'unidade': unidade,
        'rg': rg,
        'perfil': perfil,
        'dataAdmissao': dataAdmissao?.toIso8601String(),
        'failedAttempts': failedAttempts,
        'accountLocked': accountLocked == true ? 1 : 0,
        'comandoRegionalId': comandoRegionalId,
        'token': token,
        'expiracaoToken': expiracaoToken?.toIso8601String(),
        'hashedPassword': hashedPassword,
        'sub': userSub,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[User] Erro ao converter para Map: $e');
      }
      rethrow;
    }
  }

  factory User.fromJson(Map<String, dynamic> json) {
    String? userSub = json['sub'] as String?;
    String? userId = json['id'] as String?;
    
    if (json['token'] != null) {
      try {
        final decodedToken = JwtDecoder.decode(json['token'] as String);
        userSub = decodedToken['sub'] as String?;
        if (kDebugMode) {
          debugPrint('[User] Sub extraído do token na criação: $userSub');
        }
        if (userId == null && userSub != null) {
          userId = extractUserIdFromSub(userSub);
          if (kDebugMode) {
            debugPrint('[User] ID extraído do sub: $userId');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[User] Erro ao extrair sub do token na criação: $e');
        }
      }
    }
    if (userId != null && userSub == null) {
      userSub = 'f:0b78a94b-a8a1-4b9c-9edf-8bf770ad6a98:$userId';
      if (kDebugMode) {
        debugPrint('[User] Sub construído a partir do ID: $userSub');
      }
    }

    return User(
      id: userId,
      nome: json['nome'] as String?,
      email: json['email'] as String?,
      telefone: json['telefone'] as String?,
      dataNascimento: json['dataNascimento'] != null
          ? DateTime.tryParse(json['dataNascimento'] as String)
          : null,
      matricula: json['matricula'] as String?,
      cpf: json['cpf'] as String?,
      nomeGuerra: json['nomeGuerra'] as String?,
      posto: json['posto'] as String?,
      unidade: json['unidade'] as String?,
      rg: json['rg'] as String?,
      perfil: json['perfil'] as String?,
      dataAdmissao: json['dataAdmissao'] != null
          ? DateTime.tryParse(json['dataAdmissao'] as String)
          : null,
      failedAttempts: json['failedAttempts'] as int?,
      accountLocked: json['accountLocked'] as bool?,
      comandoRegionalId: json['comandoRegionalId'] as String?,
      token: json['token'] as String?,
      expiracaoToken: json['expiracaoToken'] != null
          ? DateTime.tryParse(json['expiracaoToken'] as String)
          : null,
      hashedPassword: json['hashedPassword'] ?? json['senha'] as String?,
      sub: userSub,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'dataNascimento': dataNascimento?.toIso8601String().split('T').first,
      'matricula': matricula,
      'cpf': cpf,
      'nomeGuerra': nomeGuerra,
      'posto': posto,
      'unidade': unidade,
      'rg': rg,
      'perfil': perfil,
      'dataAdmissao': dataAdmissao?.toIso8601String().split('T').first,
      'failedAttempts': failedAttempts,
      'accountLocked': accountLocked,
      'comandoRegionalId': comandoRegionalId,
      'token': token,
      'expiracaoToken': expiracaoToken?.toIso8601String(),
      'sub': sub,
    };
  }
}
