import 'package:fortivus_app/enums/tipo_conclusao_alunos.dart';

class AlunosFormacaoBrigada {
  final String? id;
  final String nomeCompleto;
  final String cpf;
  final String? email;
  final String? telefone;
  final TipoConclusaoAlunos? concludente;

  AlunosFormacaoBrigada({
    this.id,
    required this.nomeCompleto,
    required this.cpf,
    this.email,
    this.telefone,
    this.concludente,
  });

  AlunosFormacaoBrigada copyWith({
    String? id,
    String? nomeCompleto,
    String? cpf,
    String? email,
    String? telefone,
    TipoConclusaoAlunos? concludente,
  }) {
    return AlunosFormacaoBrigada(
      id: id ?? this.id,
      nomeCompleto: nomeCompleto ?? this.nomeCompleto,
      cpf: cpf ?? this.cpf,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      concludente: concludente ?? this.concludente,
    );
  }

  Map<String, dynamic> toJson() {
  return {
    'nomeCompleto': nomeCompleto,
    'cpf': cpf,
    'email': email,
    'telefone': telefone,
    if (concludente != null) 'concludente': concludente!.name,
  };
}

  factory AlunosFormacaoBrigada.fromJson(Map<String, dynamic> json) {
    T? stringToEnum<T extends Enum>(List<T> values, String? value) {
      if (value == null) return null;
      try {
        return values.firstWhere((e) => e.name == value);
      } catch (_) {
        return null;
      }
    }

    return AlunosFormacaoBrigada(
      id: json['id']?.toString(),
      nomeCompleto: json['nomeCompleto']?.toString() ?? '',
      cpf: json['cpf']?.toString() ?? '',
      email: json['email']?.toString(),
      telefone: json['telefone']?.toString(),
      concludente: stringToEnum(
        TipoConclusaoAlunos.values,
        json['concludente']?.toString(),
      ),
    );
  }
}