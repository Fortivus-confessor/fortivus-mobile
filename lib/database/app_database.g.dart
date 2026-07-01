// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subMeta = const VerificationMeta('sub');
  @override
  late final GeneratedColumn<String> sub = GeneratedColumn<String>(
      'sub', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
      'nome', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _primeiroNomeMeta =
      const VerificationMeta('primeiroNome');
  @override
  late final GeneratedColumn<String> primeiroNome = GeneratedColumn<String>(
      'primeiro_nome', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _matriculaMeta =
      const VerificationMeta('matricula');
  @override
  late final GeneratedColumn<String> matricula = GeneratedColumn<String>(
      'matricula', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _cpfMeta = const VerificationMeta('cpf');
  @override
  late final GeneratedColumn<String> cpf = GeneratedColumn<String>(
      'cpf', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _postoMeta = const VerificationMeta('posto');
  @override
  late final GeneratedColumn<String> posto = GeneratedColumn<String>(
      'posto', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _perfilMeta = const VerificationMeta('perfil');
  @override
  late final GeneratedColumn<String> perfil = GeneratedColumn<String>(
      'perfil', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _estadoOperacionalMeta =
      const VerificationMeta('estadoOperacional');
  @override
  late final GeneratedColumn<String> estadoOperacional =
      GeneratedColumn<String>('estado_operacional', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fotoUrlMeta =
      const VerificationMeta('fotoUrl');
  @override
  late final GeneratedColumn<String> fotoUrl = GeneratedColumn<String>(
      'foto_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tipoSanguineoMeta =
      const VerificationMeta('tipoSanguineo');
  @override
  late final GeneratedColumn<String> tipoSanguineo = GeneratedColumn<String>(
      'tipo_sanguineo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _centroComandoIdMeta =
      const VerificationMeta('centroComandoId');
  @override
  late final GeneratedColumn<String> centroComandoId = GeneratedColumn<String>(
      'centro_comando_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _equipeIdMeta =
      const VerificationMeta('equipeId');
  @override
  late final GeneratedColumn<String> equipeId = GeneratedColumn<String>(
      'equipe_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<String> token = GeneratedColumn<String>(
      'token', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _expiracaoTokenMeta =
      const VerificationMeta('expiracaoToken');
  @override
  late final GeneratedColumn<String> expiracaoToken = GeneratedColumn<String>(
      'expiracao_token', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _hashedPasswordMeta =
      const VerificationMeta('hashedPassword');
  @override
  late final GeneratedColumn<String> hashedPassword = GeneratedColumn<String>(
      'hashed_password', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sub,
        nome,
        primeiroNome,
        email,
        matricula,
        cpf,
        posto,
        perfil,
        estadoOperacional,
        fotoUrl,
        tipoSanguineo,
        centroComandoId,
        equipeId,
        token,
        expiracaoToken,
        hashedPassword
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sub')) {
      context.handle(
          _subMeta, sub.isAcceptableOrUnknown(data['sub']!, _subMeta));
    } else if (isInserting) {
      context.missing(_subMeta);
    }
    if (data.containsKey('nome')) {
      context.handle(
          _nomeMeta, nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta));
    }
    if (data.containsKey('primeiro_nome')) {
      context.handle(
          _primeiroNomeMeta,
          primeiroNome.isAcceptableOrUnknown(
              data['primeiro_nome']!, _primeiroNomeMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('matricula')) {
      context.handle(_matriculaMeta,
          matricula.isAcceptableOrUnknown(data['matricula']!, _matriculaMeta));
    }
    if (data.containsKey('cpf')) {
      context.handle(
          _cpfMeta, cpf.isAcceptableOrUnknown(data['cpf']!, _cpfMeta));
    }
    if (data.containsKey('posto')) {
      context.handle(
          _postoMeta, posto.isAcceptableOrUnknown(data['posto']!, _postoMeta));
    }
    if (data.containsKey('perfil')) {
      context.handle(_perfilMeta,
          perfil.isAcceptableOrUnknown(data['perfil']!, _perfilMeta));
    }
    if (data.containsKey('estado_operacional')) {
      context.handle(
          _estadoOperacionalMeta,
          estadoOperacional.isAcceptableOrUnknown(
              data['estado_operacional']!, _estadoOperacionalMeta));
    }
    if (data.containsKey('foto_url')) {
      context.handle(_fotoUrlMeta,
          fotoUrl.isAcceptableOrUnknown(data['foto_url']!, _fotoUrlMeta));
    }
    if (data.containsKey('tipo_sanguineo')) {
      context.handle(
          _tipoSanguineoMeta,
          tipoSanguineo.isAcceptableOrUnknown(
              data['tipo_sanguineo']!, _tipoSanguineoMeta));
    }
    if (data.containsKey('centro_comando_id')) {
      context.handle(
          _centroComandoIdMeta,
          centroComandoId.isAcceptableOrUnknown(
              data['centro_comando_id']!, _centroComandoIdMeta));
    }
    if (data.containsKey('equipe_id')) {
      context.handle(_equipeIdMeta,
          equipeId.isAcceptableOrUnknown(data['equipe_id']!, _equipeIdMeta));
    }
    if (data.containsKey('token')) {
      context.handle(
          _tokenMeta, token.isAcceptableOrUnknown(data['token']!, _tokenMeta));
    }
    if (data.containsKey('expiracao_token')) {
      context.handle(
          _expiracaoTokenMeta,
          expiracaoToken.isAcceptableOrUnknown(
              data['expiracao_token']!, _expiracaoTokenMeta));
    }
    if (data.containsKey('hashed_password')) {
      context.handle(
          _hashedPasswordMeta,
          hashedPassword.isAcceptableOrUnknown(
              data['hashed_password']!, _hashedPasswordMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sub: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sub'])!,
      nome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nome']),
      primeiroNome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}primeiro_nome']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      matricula: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}matricula']),
      cpf: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cpf']),
      posto: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}posto']),
      perfil: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}perfil']),
      estadoOperacional: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}estado_operacional']),
      fotoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}foto_url']),
      tipoSanguineo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo_sanguineo']),
      centroComandoId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}centro_comando_id']),
      equipeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}equipe_id']),
      token: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}token']),
      expiracaoToken: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}expiracao_token']),
      hashedPassword: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hashed_password']),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String sub;
  final String? nome;
  final String? primeiroNome;
  final String? email;
  final String? matricula;
  final String? cpf;
  final String? posto;
  final String? perfil;
  final String? estadoOperacional;
  final String? fotoUrl;
  final String? tipoSanguineo;
  final String? centroComandoId;
  final String? equipeId;
  final String? token;
  final String? expiracaoToken;
  final String? hashedPassword;
  const User(
      {required this.id,
      required this.sub,
      this.nome,
      this.primeiroNome,
      this.email,
      this.matricula,
      this.cpf,
      this.posto,
      this.perfil,
      this.estadoOperacional,
      this.fotoUrl,
      this.tipoSanguineo,
      this.centroComandoId,
      this.equipeId,
      this.token,
      this.expiracaoToken,
      this.hashedPassword});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sub'] = Variable<String>(sub);
    if (!nullToAbsent || nome != null) {
      map['nome'] = Variable<String>(nome);
    }
    if (!nullToAbsent || primeiroNome != null) {
      map['primeiro_nome'] = Variable<String>(primeiroNome);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || matricula != null) {
      map['matricula'] = Variable<String>(matricula);
    }
    if (!nullToAbsent || cpf != null) {
      map['cpf'] = Variable<String>(cpf);
    }
    if (!nullToAbsent || posto != null) {
      map['posto'] = Variable<String>(posto);
    }
    if (!nullToAbsent || perfil != null) {
      map['perfil'] = Variable<String>(perfil);
    }
    if (!nullToAbsent || estadoOperacional != null) {
      map['estado_operacional'] = Variable<String>(estadoOperacional);
    }
    if (!nullToAbsent || fotoUrl != null) {
      map['foto_url'] = Variable<String>(fotoUrl);
    }
    if (!nullToAbsent || tipoSanguineo != null) {
      map['tipo_sanguineo'] = Variable<String>(tipoSanguineo);
    }
    if (!nullToAbsent || centroComandoId != null) {
      map['centro_comando_id'] = Variable<String>(centroComandoId);
    }
    if (!nullToAbsent || equipeId != null) {
      map['equipe_id'] = Variable<String>(equipeId);
    }
    if (!nullToAbsent || token != null) {
      map['token'] = Variable<String>(token);
    }
    if (!nullToAbsent || expiracaoToken != null) {
      map['expiracao_token'] = Variable<String>(expiracaoToken);
    }
    if (!nullToAbsent || hashedPassword != null) {
      map['hashed_password'] = Variable<String>(hashedPassword);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      sub: Value(sub),
      nome: nome == null && nullToAbsent ? const Value.absent() : Value(nome),
      primeiroNome: primeiroNome == null && nullToAbsent
          ? const Value.absent()
          : Value(primeiroNome),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      matricula: matricula == null && nullToAbsent
          ? const Value.absent()
          : Value(matricula),
      cpf: cpf == null && nullToAbsent ? const Value.absent() : Value(cpf),
      posto:
          posto == null && nullToAbsent ? const Value.absent() : Value(posto),
      perfil:
          perfil == null && nullToAbsent ? const Value.absent() : Value(perfil),
      estadoOperacional: estadoOperacional == null && nullToAbsent
          ? const Value.absent()
          : Value(estadoOperacional),
      fotoUrl: fotoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoUrl),
      tipoSanguineo: tipoSanguineo == null && nullToAbsent
          ? const Value.absent()
          : Value(tipoSanguineo),
      centroComandoId: centroComandoId == null && nullToAbsent
          ? const Value.absent()
          : Value(centroComandoId),
      equipeId: equipeId == null && nullToAbsent
          ? const Value.absent()
          : Value(equipeId),
      token:
          token == null && nullToAbsent ? const Value.absent() : Value(token),
      expiracaoToken: expiracaoToken == null && nullToAbsent
          ? const Value.absent()
          : Value(expiracaoToken),
      hashedPassword: hashedPassword == null && nullToAbsent
          ? const Value.absent()
          : Value(hashedPassword),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      sub: serializer.fromJson<String>(json['sub']),
      nome: serializer.fromJson<String?>(json['nome']),
      primeiroNome: serializer.fromJson<String?>(json['primeiroNome']),
      email: serializer.fromJson<String?>(json['email']),
      matricula: serializer.fromJson<String?>(json['matricula']),
      cpf: serializer.fromJson<String?>(json['cpf']),
      posto: serializer.fromJson<String?>(json['posto']),
      perfil: serializer.fromJson<String?>(json['perfil']),
      estadoOperacional:
          serializer.fromJson<String?>(json['estadoOperacional']),
      fotoUrl: serializer.fromJson<String?>(json['fotoUrl']),
      tipoSanguineo: serializer.fromJson<String?>(json['tipoSanguineo']),
      centroComandoId: serializer.fromJson<String?>(json['centroComandoId']),
      equipeId: serializer.fromJson<String?>(json['equipeId']),
      token: serializer.fromJson<String?>(json['token']),
      expiracaoToken: serializer.fromJson<String?>(json['expiracaoToken']),
      hashedPassword: serializer.fromJson<String?>(json['hashedPassword']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sub': serializer.toJson<String>(sub),
      'nome': serializer.toJson<String?>(nome),
      'primeiroNome': serializer.toJson<String?>(primeiroNome),
      'email': serializer.toJson<String?>(email),
      'matricula': serializer.toJson<String?>(matricula),
      'cpf': serializer.toJson<String?>(cpf),
      'posto': serializer.toJson<String?>(posto),
      'perfil': serializer.toJson<String?>(perfil),
      'estadoOperacional': serializer.toJson<String?>(estadoOperacional),
      'fotoUrl': serializer.toJson<String?>(fotoUrl),
      'tipoSanguineo': serializer.toJson<String?>(tipoSanguineo),
      'centroComandoId': serializer.toJson<String?>(centroComandoId),
      'equipeId': serializer.toJson<String?>(equipeId),
      'token': serializer.toJson<String?>(token),
      'expiracaoToken': serializer.toJson<String?>(expiracaoToken),
      'hashedPassword': serializer.toJson<String?>(hashedPassword),
    };
  }

  User copyWith(
          {String? id,
          String? sub,
          Value<String?> nome = const Value.absent(),
          Value<String?> primeiroNome = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> matricula = const Value.absent(),
          Value<String?> cpf = const Value.absent(),
          Value<String?> posto = const Value.absent(),
          Value<String?> perfil = const Value.absent(),
          Value<String?> estadoOperacional = const Value.absent(),
          Value<String?> fotoUrl = const Value.absent(),
          Value<String?> tipoSanguineo = const Value.absent(),
          Value<String?> centroComandoId = const Value.absent(),
          Value<String?> equipeId = const Value.absent(),
          Value<String?> token = const Value.absent(),
          Value<String?> expiracaoToken = const Value.absent(),
          Value<String?> hashedPassword = const Value.absent()}) =>
      User(
        id: id ?? this.id,
        sub: sub ?? this.sub,
        nome: nome.present ? nome.value : this.nome,
        primeiroNome:
            primeiroNome.present ? primeiroNome.value : this.primeiroNome,
        email: email.present ? email.value : this.email,
        matricula: matricula.present ? matricula.value : this.matricula,
        cpf: cpf.present ? cpf.value : this.cpf,
        posto: posto.present ? posto.value : this.posto,
        perfil: perfil.present ? perfil.value : this.perfil,
        estadoOperacional: estadoOperacional.present
            ? estadoOperacional.value
            : this.estadoOperacional,
        fotoUrl: fotoUrl.present ? fotoUrl.value : this.fotoUrl,
        tipoSanguineo:
            tipoSanguineo.present ? tipoSanguineo.value : this.tipoSanguineo,
        centroComandoId: centroComandoId.present
            ? centroComandoId.value
            : this.centroComandoId,
        equipeId: equipeId.present ? equipeId.value : this.equipeId,
        token: token.present ? token.value : this.token,
        expiracaoToken:
            expiracaoToken.present ? expiracaoToken.value : this.expiracaoToken,
        hashedPassword:
            hashedPassword.present ? hashedPassword.value : this.hashedPassword,
      );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      sub: data.sub.present ? data.sub.value : this.sub,
      nome: data.nome.present ? data.nome.value : this.nome,
      primeiroNome: data.primeiroNome.present
          ? data.primeiroNome.value
          : this.primeiroNome,
      email: data.email.present ? data.email.value : this.email,
      matricula: data.matricula.present ? data.matricula.value : this.matricula,
      cpf: data.cpf.present ? data.cpf.value : this.cpf,
      posto: data.posto.present ? data.posto.value : this.posto,
      perfil: data.perfil.present ? data.perfil.value : this.perfil,
      estadoOperacional: data.estadoOperacional.present
          ? data.estadoOperacional.value
          : this.estadoOperacional,
      fotoUrl: data.fotoUrl.present ? data.fotoUrl.value : this.fotoUrl,
      tipoSanguineo: data.tipoSanguineo.present
          ? data.tipoSanguineo.value
          : this.tipoSanguineo,
      centroComandoId: data.centroComandoId.present
          ? data.centroComandoId.value
          : this.centroComandoId,
      equipeId: data.equipeId.present ? data.equipeId.value : this.equipeId,
      token: data.token.present ? data.token.value : this.token,
      expiracaoToken: data.expiracaoToken.present
          ? data.expiracaoToken.value
          : this.expiracaoToken,
      hashedPassword: data.hashedPassword.present
          ? data.hashedPassword.value
          : this.hashedPassword,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('sub: $sub, ')
          ..write('nome: $nome, ')
          ..write('primeiroNome: $primeiroNome, ')
          ..write('email: $email, ')
          ..write('matricula: $matricula, ')
          ..write('cpf: $cpf, ')
          ..write('posto: $posto, ')
          ..write('perfil: $perfil, ')
          ..write('estadoOperacional: $estadoOperacional, ')
          ..write('fotoUrl: $fotoUrl, ')
          ..write('tipoSanguineo: $tipoSanguineo, ')
          ..write('centroComandoId: $centroComandoId, ')
          ..write('equipeId: $equipeId, ')
          ..write('token: $token, ')
          ..write('expiracaoToken: $expiracaoToken, ')
          ..write('hashedPassword: $hashedPassword')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      sub,
      nome,
      primeiroNome,
      email,
      matricula,
      cpf,
      posto,
      perfil,
      estadoOperacional,
      fotoUrl,
      tipoSanguineo,
      centroComandoId,
      equipeId,
      token,
      expiracaoToken,
      hashedPassword);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.sub == this.sub &&
          other.nome == this.nome &&
          other.primeiroNome == this.primeiroNome &&
          other.email == this.email &&
          other.matricula == this.matricula &&
          other.cpf == this.cpf &&
          other.posto == this.posto &&
          other.perfil == this.perfil &&
          other.estadoOperacional == this.estadoOperacional &&
          other.fotoUrl == this.fotoUrl &&
          other.tipoSanguineo == this.tipoSanguineo &&
          other.centroComandoId == this.centroComandoId &&
          other.equipeId == this.equipeId &&
          other.token == this.token &&
          other.expiracaoToken == this.expiracaoToken &&
          other.hashedPassword == this.hashedPassword);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> sub;
  final Value<String?> nome;
  final Value<String?> primeiroNome;
  final Value<String?> email;
  final Value<String?> matricula;
  final Value<String?> cpf;
  final Value<String?> posto;
  final Value<String?> perfil;
  final Value<String?> estadoOperacional;
  final Value<String?> fotoUrl;
  final Value<String?> tipoSanguineo;
  final Value<String?> centroComandoId;
  final Value<String?> equipeId;
  final Value<String?> token;
  final Value<String?> expiracaoToken;
  final Value<String?> hashedPassword;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.sub = const Value.absent(),
    this.nome = const Value.absent(),
    this.primeiroNome = const Value.absent(),
    this.email = const Value.absent(),
    this.matricula = const Value.absent(),
    this.cpf = const Value.absent(),
    this.posto = const Value.absent(),
    this.perfil = const Value.absent(),
    this.estadoOperacional = const Value.absent(),
    this.fotoUrl = const Value.absent(),
    this.tipoSanguineo = const Value.absent(),
    this.centroComandoId = const Value.absent(),
    this.equipeId = const Value.absent(),
    this.token = const Value.absent(),
    this.expiracaoToken = const Value.absent(),
    this.hashedPassword = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String sub,
    this.nome = const Value.absent(),
    this.primeiroNome = const Value.absent(),
    this.email = const Value.absent(),
    this.matricula = const Value.absent(),
    this.cpf = const Value.absent(),
    this.posto = const Value.absent(),
    this.perfil = const Value.absent(),
    this.estadoOperacional = const Value.absent(),
    this.fotoUrl = const Value.absent(),
    this.tipoSanguineo = const Value.absent(),
    this.centroComandoId = const Value.absent(),
    this.equipeId = const Value.absent(),
    this.token = const Value.absent(),
    this.expiracaoToken = const Value.absent(),
    this.hashedPassword = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sub = Value(sub);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? sub,
    Expression<String>? nome,
    Expression<String>? primeiroNome,
    Expression<String>? email,
    Expression<String>? matricula,
    Expression<String>? cpf,
    Expression<String>? posto,
    Expression<String>? perfil,
    Expression<String>? estadoOperacional,
    Expression<String>? fotoUrl,
    Expression<String>? tipoSanguineo,
    Expression<String>? centroComandoId,
    Expression<String>? equipeId,
    Expression<String>? token,
    Expression<String>? expiracaoToken,
    Expression<String>? hashedPassword,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sub != null) 'sub': sub,
      if (nome != null) 'nome': nome,
      if (primeiroNome != null) 'primeiro_nome': primeiroNome,
      if (email != null) 'email': email,
      if (matricula != null) 'matricula': matricula,
      if (cpf != null) 'cpf': cpf,
      if (posto != null) 'posto': posto,
      if (perfil != null) 'perfil': perfil,
      if (estadoOperacional != null) 'estado_operacional': estadoOperacional,
      if (fotoUrl != null) 'foto_url': fotoUrl,
      if (tipoSanguineo != null) 'tipo_sanguineo': tipoSanguineo,
      if (centroComandoId != null) 'centro_comando_id': centroComandoId,
      if (equipeId != null) 'equipe_id': equipeId,
      if (token != null) 'token': token,
      if (expiracaoToken != null) 'expiracao_token': expiracaoToken,
      if (hashedPassword != null) 'hashed_password': hashedPassword,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? id,
      Value<String>? sub,
      Value<String?>? nome,
      Value<String?>? primeiroNome,
      Value<String?>? email,
      Value<String?>? matricula,
      Value<String?>? cpf,
      Value<String?>? posto,
      Value<String?>? perfil,
      Value<String?>? estadoOperacional,
      Value<String?>? fotoUrl,
      Value<String?>? tipoSanguineo,
      Value<String?>? centroComandoId,
      Value<String?>? equipeId,
      Value<String?>? token,
      Value<String?>? expiracaoToken,
      Value<String?>? hashedPassword,
      Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      sub: sub ?? this.sub,
      nome: nome ?? this.nome,
      primeiroNome: primeiroNome ?? this.primeiroNome,
      email: email ?? this.email,
      matricula: matricula ?? this.matricula,
      cpf: cpf ?? this.cpf,
      posto: posto ?? this.posto,
      perfil: perfil ?? this.perfil,
      estadoOperacional: estadoOperacional ?? this.estadoOperacional,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      tipoSanguineo: tipoSanguineo ?? this.tipoSanguineo,
      centroComandoId: centroComandoId ?? this.centroComandoId,
      equipeId: equipeId ?? this.equipeId,
      token: token ?? this.token,
      expiracaoToken: expiracaoToken ?? this.expiracaoToken,
      hashedPassword: hashedPassword ?? this.hashedPassword,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sub.present) {
      map['sub'] = Variable<String>(sub.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (primeiroNome.present) {
      map['primeiro_nome'] = Variable<String>(primeiroNome.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (matricula.present) {
      map['matricula'] = Variable<String>(matricula.value);
    }
    if (cpf.present) {
      map['cpf'] = Variable<String>(cpf.value);
    }
    if (posto.present) {
      map['posto'] = Variable<String>(posto.value);
    }
    if (perfil.present) {
      map['perfil'] = Variable<String>(perfil.value);
    }
    if (estadoOperacional.present) {
      map['estado_operacional'] = Variable<String>(estadoOperacional.value);
    }
    if (fotoUrl.present) {
      map['foto_url'] = Variable<String>(fotoUrl.value);
    }
    if (tipoSanguineo.present) {
      map['tipo_sanguineo'] = Variable<String>(tipoSanguineo.value);
    }
    if (centroComandoId.present) {
      map['centro_comando_id'] = Variable<String>(centroComandoId.value);
    }
    if (equipeId.present) {
      map['equipe_id'] = Variable<String>(equipeId.value);
    }
    if (token.present) {
      map['token'] = Variable<String>(token.value);
    }
    if (expiracaoToken.present) {
      map['expiracao_token'] = Variable<String>(expiracaoToken.value);
    }
    if (hashedPassword.present) {
      map['hashed_password'] = Variable<String>(hashedPassword.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('sub: $sub, ')
          ..write('nome: $nome, ')
          ..write('primeiroNome: $primeiroNome, ')
          ..write('email: $email, ')
          ..write('matricula: $matricula, ')
          ..write('cpf: $cpf, ')
          ..write('posto: $posto, ')
          ..write('perfil: $perfil, ')
          ..write('estadoOperacional: $estadoOperacional, ')
          ..write('fotoUrl: $fotoUrl, ')
          ..write('tipoSanguineo: $tipoSanguineo, ')
          ..write('centroComandoId: $centroComandoId, ')
          ..write('equipeId: $equipeId, ')
          ..write('token: $token, ')
          ..write('expiracaoToken: $expiracaoToken, ')
          ..write('hashedPassword: $hashedPassword, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DespachosTable extends Despachos
    with TableInfo<$DespachosTable, Despacho> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DespachosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _ordemServicoIdMeta =
      const VerificationMeta('ordemServicoId');
  @override
  late final GeneratedColumn<int> ordemServicoId = GeneratedColumn<int>(
      'ordem_servico_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _escalaIdMeta =
      const VerificationMeta('escalaId');
  @override
  late final GeneratedColumn<String> escalaId = GeneratedColumn<String>(
      'escala_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _responsavelIdMeta =
      const VerificationMeta('responsavelId');
  @override
  late final GeneratedColumn<String> responsavelId = GeneratedColumn<String>(
      'responsavel_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoriaMeta =
      const VerificationMeta('categoria');
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
      'categoria', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descricaoTarefaMeta =
      const VerificationMeta('descricaoTarefa');
  @override
  late final GeneratedColumn<String> descricaoTarefa = GeneratedColumn<String>(
      'descricao_tarefa', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dataInicioMeta =
      const VerificationMeta('dataInicio');
  @override
  late final GeneratedColumn<String> dataInicio = GeneratedColumn<String>(
      'data_inicio', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dataFimMeta =
      const VerificationMeta('dataFim');
  @override
  late final GeneratedColumn<String> dataFim = GeneratedColumn<String>(
      'data_fim', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<int> isSynced = GeneratedColumn<int>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        ordemServicoId,
        escalaId,
        responsavelId,
        categoria,
        descricaoTarefa,
        status,
        dataInicio,
        dataFim,
        latitude,
        longitude,
        isSynced,
        userId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'despachos';
  @override
  VerificationContext validateIntegrity(Insertable<Despacho> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ordem_servico_id')) {
      context.handle(
          _ordemServicoIdMeta,
          ordemServicoId.isAcceptableOrUnknown(
              data['ordem_servico_id']!, _ordemServicoIdMeta));
    } else if (isInserting) {
      context.missing(_ordemServicoIdMeta);
    }
    if (data.containsKey('escala_id')) {
      context.handle(_escalaIdMeta,
          escalaId.isAcceptableOrUnknown(data['escala_id']!, _escalaIdMeta));
    }
    if (data.containsKey('responsavel_id')) {
      context.handle(
          _responsavelIdMeta,
          responsavelId.isAcceptableOrUnknown(
              data['responsavel_id']!, _responsavelIdMeta));
    }
    if (data.containsKey('categoria')) {
      context.handle(_categoriaMeta,
          categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta));
    } else if (isInserting) {
      context.missing(_categoriaMeta);
    }
    if (data.containsKey('descricao_tarefa')) {
      context.handle(
          _descricaoTarefaMeta,
          descricaoTarefa.isAcceptableOrUnknown(
              data['descricao_tarefa']!, _descricaoTarefaMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('data_inicio')) {
      context.handle(
          _dataInicioMeta,
          dataInicio.isAcceptableOrUnknown(
              data['data_inicio']!, _dataInicioMeta));
    }
    if (data.containsKey('data_fim')) {
      context.handle(_dataFimMeta,
          dataFim.isAcceptableOrUnknown(data['data_fim']!, _dataFimMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Despacho map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Despacho(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      ordemServicoId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ordem_servico_id'])!,
      escalaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}escala_id']),
      responsavelId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}responsavel_id']),
      categoria: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}categoria'])!,
      descricaoTarefa: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}descricao_tarefa']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      dataInicio: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data_inicio']),
      dataFim: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data_fim']),
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_synced'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
    );
  }

  @override
  $DespachosTable createAlias(String alias) {
    return $DespachosTable(attachedDatabase, alias);
  }
}

class Despacho extends DataClass implements Insertable<Despacho> {
  final int id;
  final int ordemServicoId;
  final String? escalaId;
  final String? responsavelId;
  final String categoria;
  final String? descricaoTarefa;
  final String status;
  final String? dataInicio;
  final String? dataFim;
  final double? latitude;
  final double? longitude;
  final int isSynced;
  final String? userId;
  const Despacho(
      {required this.id,
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
      required this.isSynced,
      this.userId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ordem_servico_id'] = Variable<int>(ordemServicoId);
    if (!nullToAbsent || escalaId != null) {
      map['escala_id'] = Variable<String>(escalaId);
    }
    if (!nullToAbsent || responsavelId != null) {
      map['responsavel_id'] = Variable<String>(responsavelId);
    }
    map['categoria'] = Variable<String>(categoria);
    if (!nullToAbsent || descricaoTarefa != null) {
      map['descricao_tarefa'] = Variable<String>(descricaoTarefa);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || dataInicio != null) {
      map['data_inicio'] = Variable<String>(dataInicio);
    }
    if (!nullToAbsent || dataFim != null) {
      map['data_fim'] = Variable<String>(dataFim);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['is_synced'] = Variable<int>(isSynced);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    return map;
  }

  DespachosCompanion toCompanion(bool nullToAbsent) {
    return DespachosCompanion(
      id: Value(id),
      ordemServicoId: Value(ordemServicoId),
      escalaId: escalaId == null && nullToAbsent
          ? const Value.absent()
          : Value(escalaId),
      responsavelId: responsavelId == null && nullToAbsent
          ? const Value.absent()
          : Value(responsavelId),
      categoria: Value(categoria),
      descricaoTarefa: descricaoTarefa == null && nullToAbsent
          ? const Value.absent()
          : Value(descricaoTarefa),
      status: Value(status),
      dataInicio: dataInicio == null && nullToAbsent
          ? const Value.absent()
          : Value(dataInicio),
      dataFim: dataFim == null && nullToAbsent
          ? const Value.absent()
          : Value(dataFim),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      isSynced: Value(isSynced),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
    );
  }

  factory Despacho.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Despacho(
      id: serializer.fromJson<int>(json['id']),
      ordemServicoId: serializer.fromJson<int>(json['ordemServicoId']),
      escalaId: serializer.fromJson<String?>(json['escalaId']),
      responsavelId: serializer.fromJson<String?>(json['responsavelId']),
      categoria: serializer.fromJson<String>(json['categoria']),
      descricaoTarefa: serializer.fromJson<String?>(json['descricaoTarefa']),
      status: serializer.fromJson<String>(json['status']),
      dataInicio: serializer.fromJson<String?>(json['dataInicio']),
      dataFim: serializer.fromJson<String?>(json['dataFim']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      isSynced: serializer.fromJson<int>(json['isSynced']),
      userId: serializer.fromJson<String?>(json['userId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ordemServicoId': serializer.toJson<int>(ordemServicoId),
      'escalaId': serializer.toJson<String?>(escalaId),
      'responsavelId': serializer.toJson<String?>(responsavelId),
      'categoria': serializer.toJson<String>(categoria),
      'descricaoTarefa': serializer.toJson<String?>(descricaoTarefa),
      'status': serializer.toJson<String>(status),
      'dataInicio': serializer.toJson<String?>(dataInicio),
      'dataFim': serializer.toJson<String?>(dataFim),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'isSynced': serializer.toJson<int>(isSynced),
      'userId': serializer.toJson<String?>(userId),
    };
  }

  Despacho copyWith(
          {int? id,
          int? ordemServicoId,
          Value<String?> escalaId = const Value.absent(),
          Value<String?> responsavelId = const Value.absent(),
          String? categoria,
          Value<String?> descricaoTarefa = const Value.absent(),
          String? status,
          Value<String?> dataInicio = const Value.absent(),
          Value<String?> dataFim = const Value.absent(),
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          int? isSynced,
          Value<String?> userId = const Value.absent()}) =>
      Despacho(
        id: id ?? this.id,
        ordemServicoId: ordemServicoId ?? this.ordemServicoId,
        escalaId: escalaId.present ? escalaId.value : this.escalaId,
        responsavelId:
            responsavelId.present ? responsavelId.value : this.responsavelId,
        categoria: categoria ?? this.categoria,
        descricaoTarefa: descricaoTarefa.present
            ? descricaoTarefa.value
            : this.descricaoTarefa,
        status: status ?? this.status,
        dataInicio: dataInicio.present ? dataInicio.value : this.dataInicio,
        dataFim: dataFim.present ? dataFim.value : this.dataFim,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        isSynced: isSynced ?? this.isSynced,
        userId: userId.present ? userId.value : this.userId,
      );
  Despacho copyWithCompanion(DespachosCompanion data) {
    return Despacho(
      id: data.id.present ? data.id.value : this.id,
      ordemServicoId: data.ordemServicoId.present
          ? data.ordemServicoId.value
          : this.ordemServicoId,
      escalaId: data.escalaId.present ? data.escalaId.value : this.escalaId,
      responsavelId: data.responsavelId.present
          ? data.responsavelId.value
          : this.responsavelId,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      descricaoTarefa: data.descricaoTarefa.present
          ? data.descricaoTarefa.value
          : this.descricaoTarefa,
      status: data.status.present ? data.status.value : this.status,
      dataInicio:
          data.dataInicio.present ? data.dataInicio.value : this.dataInicio,
      dataFim: data.dataFim.present ? data.dataFim.value : this.dataFim,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      userId: data.userId.present ? data.userId.value : this.userId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Despacho(')
          ..write('id: $id, ')
          ..write('ordemServicoId: $ordemServicoId, ')
          ..write('escalaId: $escalaId, ')
          ..write('responsavelId: $responsavelId, ')
          ..write('categoria: $categoria, ')
          ..write('descricaoTarefa: $descricaoTarefa, ')
          ..write('status: $status, ')
          ..write('dataInicio: $dataInicio, ')
          ..write('dataFim: $dataFim, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('isSynced: $isSynced, ')
          ..write('userId: $userId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      ordemServicoId,
      escalaId,
      responsavelId,
      categoria,
      descricaoTarefa,
      status,
      dataInicio,
      dataFim,
      latitude,
      longitude,
      isSynced,
      userId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Despacho &&
          other.id == this.id &&
          other.ordemServicoId == this.ordemServicoId &&
          other.escalaId == this.escalaId &&
          other.responsavelId == this.responsavelId &&
          other.categoria == this.categoria &&
          other.descricaoTarefa == this.descricaoTarefa &&
          other.status == this.status &&
          other.dataInicio == this.dataInicio &&
          other.dataFim == this.dataFim &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.isSynced == this.isSynced &&
          other.userId == this.userId);
}

class DespachosCompanion extends UpdateCompanion<Despacho> {
  final Value<int> id;
  final Value<int> ordemServicoId;
  final Value<String?> escalaId;
  final Value<String?> responsavelId;
  final Value<String> categoria;
  final Value<String?> descricaoTarefa;
  final Value<String> status;
  final Value<String?> dataInicio;
  final Value<String?> dataFim;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<int> isSynced;
  final Value<String?> userId;
  const DespachosCompanion({
    this.id = const Value.absent(),
    this.ordemServicoId = const Value.absent(),
    this.escalaId = const Value.absent(),
    this.responsavelId = const Value.absent(),
    this.categoria = const Value.absent(),
    this.descricaoTarefa = const Value.absent(),
    this.status = const Value.absent(),
    this.dataInicio = const Value.absent(),
    this.dataFim = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.userId = const Value.absent(),
  });
  DespachosCompanion.insert({
    this.id = const Value.absent(),
    required int ordemServicoId,
    this.escalaId = const Value.absent(),
    this.responsavelId = const Value.absent(),
    required String categoria,
    this.descricaoTarefa = const Value.absent(),
    required String status,
    this.dataInicio = const Value.absent(),
    this.dataFim = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.userId = const Value.absent(),
  })  : ordemServicoId = Value(ordemServicoId),
        categoria = Value(categoria),
        status = Value(status);
  static Insertable<Despacho> custom({
    Expression<int>? id,
    Expression<int>? ordemServicoId,
    Expression<String>? escalaId,
    Expression<String>? responsavelId,
    Expression<String>? categoria,
    Expression<String>? descricaoTarefa,
    Expression<String>? status,
    Expression<String>? dataInicio,
    Expression<String>? dataFim,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? isSynced,
    Expression<String>? userId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ordemServicoId != null) 'ordem_servico_id': ordemServicoId,
      if (escalaId != null) 'escala_id': escalaId,
      if (responsavelId != null) 'responsavel_id': responsavelId,
      if (categoria != null) 'categoria': categoria,
      if (descricaoTarefa != null) 'descricao_tarefa': descricaoTarefa,
      if (status != null) 'status': status,
      if (dataInicio != null) 'data_inicio': dataInicio,
      if (dataFim != null) 'data_fim': dataFim,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (isSynced != null) 'is_synced': isSynced,
      if (userId != null) 'user_id': userId,
    });
  }

  DespachosCompanion copyWith(
      {Value<int>? id,
      Value<int>? ordemServicoId,
      Value<String?>? escalaId,
      Value<String?>? responsavelId,
      Value<String>? categoria,
      Value<String?>? descricaoTarefa,
      Value<String>? status,
      Value<String?>? dataInicio,
      Value<String?>? dataFim,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<int>? isSynced,
      Value<String?>? userId}) {
    return DespachosCompanion(
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

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ordemServicoId.present) {
      map['ordem_servico_id'] = Variable<int>(ordemServicoId.value);
    }
    if (escalaId.present) {
      map['escala_id'] = Variable<String>(escalaId.value);
    }
    if (responsavelId.present) {
      map['responsavel_id'] = Variable<String>(responsavelId.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (descricaoTarefa.present) {
      map['descricao_tarefa'] = Variable<String>(descricaoTarefa.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (dataInicio.present) {
      map['data_inicio'] = Variable<String>(dataInicio.value);
    }
    if (dataFim.present) {
      map['data_fim'] = Variable<String>(dataFim.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<int>(isSynced.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DespachosCompanion(')
          ..write('id: $id, ')
          ..write('ordemServicoId: $ordemServicoId, ')
          ..write('escalaId: $escalaId, ')
          ..write('responsavelId: $responsavelId, ')
          ..write('categoria: $categoria, ')
          ..write('descricaoTarefa: $descricaoTarefa, ')
          ..write('status: $status, ')
          ..write('dataInicio: $dataInicio, ')
          ..write('dataFim: $dataFim, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('isSynced: $isSynced, ')
          ..write('userId: $userId')
          ..write(')'))
        .toString();
  }
}

class $RespostasPendentesTable extends RespostasPendentes
    with TableInfo<$RespostasPendentesTable, RespostasPendente> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RespostasPendentesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _despachoIdMeta =
      const VerificationMeta('despachoId');
  @override
  late final GeneratedColumn<int> despachoId = GeneratedColumn<int>(
      'despacho_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _categoriaMeta =
      const VerificationMeta('categoria');
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
      'categoria', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dadosMeta = const VerificationMeta('dados');
  @override
  late final GeneratedColumn<String> dados = GeneratedColumn<String>(
      'dados', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dataCriacaoMeta =
      const VerificationMeta('dataCriacao');
  @override
  late final GeneratedColumn<String> dataCriacao = GeneratedColumn<String>(
      'data_criacao', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tentativasSincMeta =
      const VerificationMeta('tentativasSinc');
  @override
  late final GeneratedColumn<int> tentativasSinc = GeneratedColumn<int>(
      'tentativas_sinc', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _ultimaTentativaMeta =
      const VerificationMeta('ultimaTentativa');
  @override
  late final GeneratedColumn<String> ultimaTentativa = GeneratedColumn<String>(
      'ultima_tentativa', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('PENDENTE'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        despachoId,
        categoria,
        dados,
        dataCriacao,
        tentativasSinc,
        ultimaTentativa,
        status
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'respostas_pendentes';
  @override
  VerificationContext validateIntegrity(Insertable<RespostasPendente> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('despacho_id')) {
      context.handle(
          _despachoIdMeta,
          despachoId.isAcceptableOrUnknown(
              data['despacho_id']!, _despachoIdMeta));
    } else if (isInserting) {
      context.missing(_despachoIdMeta);
    }
    if (data.containsKey('categoria')) {
      context.handle(_categoriaMeta,
          categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta));
    } else if (isInserting) {
      context.missing(_categoriaMeta);
    }
    if (data.containsKey('dados')) {
      context.handle(
          _dadosMeta, dados.isAcceptableOrUnknown(data['dados']!, _dadosMeta));
    } else if (isInserting) {
      context.missing(_dadosMeta);
    }
    if (data.containsKey('data_criacao')) {
      context.handle(
          _dataCriacaoMeta,
          dataCriacao.isAcceptableOrUnknown(
              data['data_criacao']!, _dataCriacaoMeta));
    } else if (isInserting) {
      context.missing(_dataCriacaoMeta);
    }
    if (data.containsKey('tentativas_sinc')) {
      context.handle(
          _tentativasSincMeta,
          tentativasSinc.isAcceptableOrUnknown(
              data['tentativas_sinc']!, _tentativasSincMeta));
    }
    if (data.containsKey('ultima_tentativa')) {
      context.handle(
          _ultimaTentativaMeta,
          ultimaTentativa.isAcceptableOrUnknown(
              data['ultima_tentativa']!, _ultimaTentativaMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RespostasPendente map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RespostasPendente(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      despachoId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}despacho_id'])!,
      categoria: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}categoria'])!,
      dados: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dados'])!,
      dataCriacao: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data_criacao'])!,
      tentativasSinc: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tentativas_sinc'])!,
      ultimaTentativa: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}ultima_tentativa']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $RespostasPendentesTable createAlias(String alias) {
    return $RespostasPendentesTable(attachedDatabase, alias);
  }
}

class RespostasPendente extends DataClass
    implements Insertable<RespostasPendente> {
  final int id;
  final int despachoId;
  final String categoria;
  final String dados;
  final String dataCriacao;
  final int tentativasSinc;
  final String? ultimaTentativa;
  final String status;
  const RespostasPendente(
      {required this.id,
      required this.despachoId,
      required this.categoria,
      required this.dados,
      required this.dataCriacao,
      required this.tentativasSinc,
      this.ultimaTentativa,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['despacho_id'] = Variable<int>(despachoId);
    map['categoria'] = Variable<String>(categoria);
    map['dados'] = Variable<String>(dados);
    map['data_criacao'] = Variable<String>(dataCriacao);
    map['tentativas_sinc'] = Variable<int>(tentativasSinc);
    if (!nullToAbsent || ultimaTentativa != null) {
      map['ultima_tentativa'] = Variable<String>(ultimaTentativa);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  RespostasPendentesCompanion toCompanion(bool nullToAbsent) {
    return RespostasPendentesCompanion(
      id: Value(id),
      despachoId: Value(despachoId),
      categoria: Value(categoria),
      dados: Value(dados),
      dataCriacao: Value(dataCriacao),
      tentativasSinc: Value(tentativasSinc),
      ultimaTentativa: ultimaTentativa == null && nullToAbsent
          ? const Value.absent()
          : Value(ultimaTentativa),
      status: Value(status),
    );
  }

  factory RespostasPendente.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RespostasPendente(
      id: serializer.fromJson<int>(json['id']),
      despachoId: serializer.fromJson<int>(json['despachoId']),
      categoria: serializer.fromJson<String>(json['categoria']),
      dados: serializer.fromJson<String>(json['dados']),
      dataCriacao: serializer.fromJson<String>(json['dataCriacao']),
      tentativasSinc: serializer.fromJson<int>(json['tentativasSinc']),
      ultimaTentativa: serializer.fromJson<String?>(json['ultimaTentativa']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'despachoId': serializer.toJson<int>(despachoId),
      'categoria': serializer.toJson<String>(categoria),
      'dados': serializer.toJson<String>(dados),
      'dataCriacao': serializer.toJson<String>(dataCriacao),
      'tentativasSinc': serializer.toJson<int>(tentativasSinc),
      'ultimaTentativa': serializer.toJson<String?>(ultimaTentativa),
      'status': serializer.toJson<String>(status),
    };
  }

  RespostasPendente copyWith(
          {int? id,
          int? despachoId,
          String? categoria,
          String? dados,
          String? dataCriacao,
          int? tentativasSinc,
          Value<String?> ultimaTentativa = const Value.absent(),
          String? status}) =>
      RespostasPendente(
        id: id ?? this.id,
        despachoId: despachoId ?? this.despachoId,
        categoria: categoria ?? this.categoria,
        dados: dados ?? this.dados,
        dataCriacao: dataCriacao ?? this.dataCriacao,
        tentativasSinc: tentativasSinc ?? this.tentativasSinc,
        ultimaTentativa: ultimaTentativa.present
            ? ultimaTentativa.value
            : this.ultimaTentativa,
        status: status ?? this.status,
      );
  RespostasPendente copyWithCompanion(RespostasPendentesCompanion data) {
    return RespostasPendente(
      id: data.id.present ? data.id.value : this.id,
      despachoId:
          data.despachoId.present ? data.despachoId.value : this.despachoId,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      dados: data.dados.present ? data.dados.value : this.dados,
      dataCriacao:
          data.dataCriacao.present ? data.dataCriacao.value : this.dataCriacao,
      tentativasSinc: data.tentativasSinc.present
          ? data.tentativasSinc.value
          : this.tentativasSinc,
      ultimaTentativa: data.ultimaTentativa.present
          ? data.ultimaTentativa.value
          : this.ultimaTentativa,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RespostasPendente(')
          ..write('id: $id, ')
          ..write('despachoId: $despachoId, ')
          ..write('categoria: $categoria, ')
          ..write('dados: $dados, ')
          ..write('dataCriacao: $dataCriacao, ')
          ..write('tentativasSinc: $tentativasSinc, ')
          ..write('ultimaTentativa: $ultimaTentativa, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, despachoId, categoria, dados, dataCriacao,
      tentativasSinc, ultimaTentativa, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RespostasPendente &&
          other.id == this.id &&
          other.despachoId == this.despachoId &&
          other.categoria == this.categoria &&
          other.dados == this.dados &&
          other.dataCriacao == this.dataCriacao &&
          other.tentativasSinc == this.tentativasSinc &&
          other.ultimaTentativa == this.ultimaTentativa &&
          other.status == this.status);
}

class RespostasPendentesCompanion extends UpdateCompanion<RespostasPendente> {
  final Value<int> id;
  final Value<int> despachoId;
  final Value<String> categoria;
  final Value<String> dados;
  final Value<String> dataCriacao;
  final Value<int> tentativasSinc;
  final Value<String?> ultimaTentativa;
  final Value<String> status;
  const RespostasPendentesCompanion({
    this.id = const Value.absent(),
    this.despachoId = const Value.absent(),
    this.categoria = const Value.absent(),
    this.dados = const Value.absent(),
    this.dataCriacao = const Value.absent(),
    this.tentativasSinc = const Value.absent(),
    this.ultimaTentativa = const Value.absent(),
    this.status = const Value.absent(),
  });
  RespostasPendentesCompanion.insert({
    this.id = const Value.absent(),
    required int despachoId,
    required String categoria,
    required String dados,
    required String dataCriacao,
    this.tentativasSinc = const Value.absent(),
    this.ultimaTentativa = const Value.absent(),
    this.status = const Value.absent(),
  })  : despachoId = Value(despachoId),
        categoria = Value(categoria),
        dados = Value(dados),
        dataCriacao = Value(dataCriacao);
  static Insertable<RespostasPendente> custom({
    Expression<int>? id,
    Expression<int>? despachoId,
    Expression<String>? categoria,
    Expression<String>? dados,
    Expression<String>? dataCriacao,
    Expression<int>? tentativasSinc,
    Expression<String>? ultimaTentativa,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (despachoId != null) 'despacho_id': despachoId,
      if (categoria != null) 'categoria': categoria,
      if (dados != null) 'dados': dados,
      if (dataCriacao != null) 'data_criacao': dataCriacao,
      if (tentativasSinc != null) 'tentativas_sinc': tentativasSinc,
      if (ultimaTentativa != null) 'ultima_tentativa': ultimaTentativa,
      if (status != null) 'status': status,
    });
  }

  RespostasPendentesCompanion copyWith(
      {Value<int>? id,
      Value<int>? despachoId,
      Value<String>? categoria,
      Value<String>? dados,
      Value<String>? dataCriacao,
      Value<int>? tentativasSinc,
      Value<String?>? ultimaTentativa,
      Value<String>? status}) {
    return RespostasPendentesCompanion(
      id: id ?? this.id,
      despachoId: despachoId ?? this.despachoId,
      categoria: categoria ?? this.categoria,
      dados: dados ?? this.dados,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      tentativasSinc: tentativasSinc ?? this.tentativasSinc,
      ultimaTentativa: ultimaTentativa ?? this.ultimaTentativa,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (despachoId.present) {
      map['despacho_id'] = Variable<int>(despachoId.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (dados.present) {
      map['dados'] = Variable<String>(dados.value);
    }
    if (dataCriacao.present) {
      map['data_criacao'] = Variable<String>(dataCriacao.value);
    }
    if (tentativasSinc.present) {
      map['tentativas_sinc'] = Variable<int>(tentativasSinc.value);
    }
    if (ultimaTentativa.present) {
      map['ultima_tentativa'] = Variable<String>(ultimaTentativa.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RespostasPendentesCompanion(')
          ..write('id: $id, ')
          ..write('despachoId: $despachoId, ')
          ..write('categoria: $categoria, ')
          ..write('dados: $dados, ')
          ..write('dataCriacao: $dataCriacao, ')
          ..write('tentativasSinc: $tentativasSinc, ')
          ..write('ultimaTentativa: $ultimaTentativa, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $EvidenciasTable extends Evidencias
    with TableInfo<$EvidenciasTable, Evidencia> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EvidenciasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _despachoIdMeta =
      const VerificationMeta('despachoId');
  @override
  late final GeneratedColumn<int> despachoId = GeneratedColumn<int>(
      'despacho_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
      'tipo', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _dataCapturaMeta =
      const VerificationMeta('dataCaptura');
  @override
  late final GeneratedColumn<String> dataCaptura = GeneratedColumn<String>(
      'data_captura', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusSincronizacaoMeta =
      const VerificationMeta('statusSincronizacao');
  @override
  late final GeneratedColumn<String> statusSincronizacao =
      GeneratedColumn<String>('status_sincronizacao', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('PENDENTE'));
  static const VerificationMeta _tentativasMeta =
      const VerificationMeta('tentativas');
  @override
  late final GeneratedColumn<int> tentativas = GeneratedColumn<int>(
      'tentativas', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        despachoId,
        filePath,
        tipo,
        latitude,
        longitude,
        dataCaptura,
        statusSincronizacao,
        tentativas
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'evidencias';
  @override
  VerificationContext validateIntegrity(Insertable<Evidencia> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('despacho_id')) {
      context.handle(
          _despachoIdMeta,
          despachoId.isAcceptableOrUnknown(
              data['despacho_id']!, _despachoIdMeta));
    } else if (isInserting) {
      context.missing(_despachoIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
          _tipoMeta, tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta));
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    if (data.containsKey('data_captura')) {
      context.handle(
          _dataCapturaMeta,
          dataCaptura.isAcceptableOrUnknown(
              data['data_captura']!, _dataCapturaMeta));
    } else if (isInserting) {
      context.missing(_dataCapturaMeta);
    }
    if (data.containsKey('status_sincronizacao')) {
      context.handle(
          _statusSincronizacaoMeta,
          statusSincronizacao.isAcceptableOrUnknown(
              data['status_sincronizacao']!, _statusSincronizacaoMeta));
    }
    if (data.containsKey('tentativas')) {
      context.handle(
          _tentativasMeta,
          tentativas.isAcceptableOrUnknown(
              data['tentativas']!, _tentativasMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Evidencia map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Evidencia(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      despachoId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}despacho_id'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      tipo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      dataCaptura: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data_captura'])!,
      statusSincronizacao: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}status_sincronizacao'])!,
      tentativas: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tentativas'])!,
    );
  }

  @override
  $EvidenciasTable createAlias(String alias) {
    return $EvidenciasTable(attachedDatabase, alias);
  }
}

class Evidencia extends DataClass implements Insertable<Evidencia> {
  final int id;
  final int despachoId;
  final String filePath;
  final String tipo;
  final double? latitude;
  final double? longitude;
  final String dataCaptura;
  final String statusSincronizacao;
  final int tentativas;
  const Evidencia(
      {required this.id,
      required this.despachoId,
      required this.filePath,
      required this.tipo,
      this.latitude,
      this.longitude,
      required this.dataCaptura,
      required this.statusSincronizacao,
      required this.tentativas});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['despacho_id'] = Variable<int>(despachoId);
    map['file_path'] = Variable<String>(filePath);
    map['tipo'] = Variable<String>(tipo);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['data_captura'] = Variable<String>(dataCaptura);
    map['status_sincronizacao'] = Variable<String>(statusSincronizacao);
    map['tentativas'] = Variable<int>(tentativas);
    return map;
  }

  EvidenciasCompanion toCompanion(bool nullToAbsent) {
    return EvidenciasCompanion(
      id: Value(id),
      despachoId: Value(despachoId),
      filePath: Value(filePath),
      tipo: Value(tipo),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      dataCaptura: Value(dataCaptura),
      statusSincronizacao: Value(statusSincronizacao),
      tentativas: Value(tentativas),
    );
  }

  factory Evidencia.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Evidencia(
      id: serializer.fromJson<int>(json['id']),
      despachoId: serializer.fromJson<int>(json['despachoId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      tipo: serializer.fromJson<String>(json['tipo']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      dataCaptura: serializer.fromJson<String>(json['dataCaptura']),
      statusSincronizacao:
          serializer.fromJson<String>(json['statusSincronizacao']),
      tentativas: serializer.fromJson<int>(json['tentativas']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'despachoId': serializer.toJson<int>(despachoId),
      'filePath': serializer.toJson<String>(filePath),
      'tipo': serializer.toJson<String>(tipo),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'dataCaptura': serializer.toJson<String>(dataCaptura),
      'statusSincronizacao': serializer.toJson<String>(statusSincronizacao),
      'tentativas': serializer.toJson<int>(tentativas),
    };
  }

  Evidencia copyWith(
          {int? id,
          int? despachoId,
          String? filePath,
          String? tipo,
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          String? dataCaptura,
          String? statusSincronizacao,
          int? tentativas}) =>
      Evidencia(
        id: id ?? this.id,
        despachoId: despachoId ?? this.despachoId,
        filePath: filePath ?? this.filePath,
        tipo: tipo ?? this.tipo,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        dataCaptura: dataCaptura ?? this.dataCaptura,
        statusSincronizacao: statusSincronizacao ?? this.statusSincronizacao,
        tentativas: tentativas ?? this.tentativas,
      );
  Evidencia copyWithCompanion(EvidenciasCompanion data) {
    return Evidencia(
      id: data.id.present ? data.id.value : this.id,
      despachoId:
          data.despachoId.present ? data.despachoId.value : this.despachoId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      dataCaptura:
          data.dataCaptura.present ? data.dataCaptura.value : this.dataCaptura,
      statusSincronizacao: data.statusSincronizacao.present
          ? data.statusSincronizacao.value
          : this.statusSincronizacao,
      tentativas:
          data.tentativas.present ? data.tentativas.value : this.tentativas,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Evidencia(')
          ..write('id: $id, ')
          ..write('despachoId: $despachoId, ')
          ..write('filePath: $filePath, ')
          ..write('tipo: $tipo, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('dataCaptura: $dataCaptura, ')
          ..write('statusSincronizacao: $statusSincronizacao, ')
          ..write('tentativas: $tentativas')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, despachoId, filePath, tipo, latitude,
      longitude, dataCaptura, statusSincronizacao, tentativas);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Evidencia &&
          other.id == this.id &&
          other.despachoId == this.despachoId &&
          other.filePath == this.filePath &&
          other.tipo == this.tipo &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.dataCaptura == this.dataCaptura &&
          other.statusSincronizacao == this.statusSincronizacao &&
          other.tentativas == this.tentativas);
}

class EvidenciasCompanion extends UpdateCompanion<Evidencia> {
  final Value<int> id;
  final Value<int> despachoId;
  final Value<String> filePath;
  final Value<String> tipo;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String> dataCaptura;
  final Value<String> statusSincronizacao;
  final Value<int> tentativas;
  const EvidenciasCompanion({
    this.id = const Value.absent(),
    this.despachoId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.tipo = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.dataCaptura = const Value.absent(),
    this.statusSincronizacao = const Value.absent(),
    this.tentativas = const Value.absent(),
  });
  EvidenciasCompanion.insert({
    this.id = const Value.absent(),
    required int despachoId,
    required String filePath,
    required String tipo,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    required String dataCaptura,
    this.statusSincronizacao = const Value.absent(),
    this.tentativas = const Value.absent(),
  })  : despachoId = Value(despachoId),
        filePath = Value(filePath),
        tipo = Value(tipo),
        dataCaptura = Value(dataCaptura);
  static Insertable<Evidencia> custom({
    Expression<int>? id,
    Expression<int>? despachoId,
    Expression<String>? filePath,
    Expression<String>? tipo,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? dataCaptura,
    Expression<String>? statusSincronizacao,
    Expression<int>? tentativas,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (despachoId != null) 'despacho_id': despachoId,
      if (filePath != null) 'file_path': filePath,
      if (tipo != null) 'tipo': tipo,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (dataCaptura != null) 'data_captura': dataCaptura,
      if (statusSincronizacao != null)
        'status_sincronizacao': statusSincronizacao,
      if (tentativas != null) 'tentativas': tentativas,
    });
  }

  EvidenciasCompanion copyWith(
      {Value<int>? id,
      Value<int>? despachoId,
      Value<String>? filePath,
      Value<String>? tipo,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<String>? dataCaptura,
      Value<String>? statusSincronizacao,
      Value<int>? tentativas}) {
    return EvidenciasCompanion(
      id: id ?? this.id,
      despachoId: despachoId ?? this.despachoId,
      filePath: filePath ?? this.filePath,
      tipo: tipo ?? this.tipo,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      dataCaptura: dataCaptura ?? this.dataCaptura,
      statusSincronizacao: statusSincronizacao ?? this.statusSincronizacao,
      tentativas: tentativas ?? this.tentativas,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (despachoId.present) {
      map['despacho_id'] = Variable<int>(despachoId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (dataCaptura.present) {
      map['data_captura'] = Variable<String>(dataCaptura.value);
    }
    if (statusSincronizacao.present) {
      map['status_sincronizacao'] = Variable<String>(statusSincronizacao.value);
    }
    if (tentativas.present) {
      map['tentativas'] = Variable<int>(tentativas.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EvidenciasCompanion(')
          ..write('id: $id, ')
          ..write('despachoId: $despachoId, ')
          ..write('filePath: $filePath, ')
          ..write('tipo: $tipo, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('dataCaptura: $dataCaptura, ')
          ..write('statusSincronizacao: $statusSincronizacao, ')
          ..write('tentativas: $tentativas')
          ..write(')'))
        .toString();
  }
}

class $OutboxTableTable extends OutboxTable
    with TableInfo<$OutboxTableTable, OutboxTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _metodoMeta = const VerificationMeta('metodo');
  @override
  late final GeneratedColumn<String> metodo = GeneratedColumn<String>(
      'metodo', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _endpointMeta =
      const VerificationMeta('endpoint');
  @override
  late final GeneratedColumn<String> endpoint = GeneratedColumn<String>(
      'endpoint', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dataCriacaoMeta =
      const VerificationMeta('dataCriacao');
  @override
  late final GeneratedColumn<String> dataCriacao = GeneratedColumn<String>(
      'data_criacao', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('PENDENTE'));
  static const VerificationMeta _tentativasMeta =
      const VerificationMeta('tentativas');
  @override
  late final GeneratedColumn<int> tentativas = GeneratedColumn<int>(
      'tentativas', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _erroMeta = const VerificationMeta('erro');
  @override
  late final GeneratedColumn<String> erro = GeneratedColumn<String>(
      'erro', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, metodo, endpoint, payload, dataCriacao, status, tentativas, erro];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_table';
  @override
  VerificationContext validateIntegrity(Insertable<OutboxTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('metodo')) {
      context.handle(_metodoMeta,
          metodo.isAcceptableOrUnknown(data['metodo']!, _metodoMeta));
    } else if (isInserting) {
      context.missing(_metodoMeta);
    }
    if (data.containsKey('endpoint')) {
      context.handle(_endpointMeta,
          endpoint.isAcceptableOrUnknown(data['endpoint']!, _endpointMeta));
    } else if (isInserting) {
      context.missing(_endpointMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('data_criacao')) {
      context.handle(
          _dataCriacaoMeta,
          dataCriacao.isAcceptableOrUnknown(
              data['data_criacao']!, _dataCriacaoMeta));
    } else if (isInserting) {
      context.missing(_dataCriacaoMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('tentativas')) {
      context.handle(
          _tentativasMeta,
          tentativas.isAcceptableOrUnknown(
              data['tentativas']!, _tentativasMeta));
    }
    if (data.containsKey('erro')) {
      context.handle(
          _erroMeta, erro.isAcceptableOrUnknown(data['erro']!, _erroMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      metodo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metodo'])!,
      endpoint: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}endpoint'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      dataCriacao: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data_criacao'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      tentativas: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tentativas'])!,
      erro: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}erro']),
    );
  }

  @override
  $OutboxTableTable createAlias(String alias) {
    return $OutboxTableTable(attachedDatabase, alias);
  }
}

class OutboxTableData extends DataClass implements Insertable<OutboxTableData> {
  final int id;
  final String metodo;
  final String endpoint;
  final String payload;
  final String dataCriacao;
  final String status;
  final int tentativas;
  final String? erro;
  const OutboxTableData(
      {required this.id,
      required this.metodo,
      required this.endpoint,
      required this.payload,
      required this.dataCriacao,
      required this.status,
      required this.tentativas,
      this.erro});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['metodo'] = Variable<String>(metodo);
    map['endpoint'] = Variable<String>(endpoint);
    map['payload'] = Variable<String>(payload);
    map['data_criacao'] = Variable<String>(dataCriacao);
    map['status'] = Variable<String>(status);
    map['tentativas'] = Variable<int>(tentativas);
    if (!nullToAbsent || erro != null) {
      map['erro'] = Variable<String>(erro);
    }
    return map;
  }

  OutboxTableCompanion toCompanion(bool nullToAbsent) {
    return OutboxTableCompanion(
      id: Value(id),
      metodo: Value(metodo),
      endpoint: Value(endpoint),
      payload: Value(payload),
      dataCriacao: Value(dataCriacao),
      status: Value(status),
      tentativas: Value(tentativas),
      erro: erro == null && nullToAbsent ? const Value.absent() : Value(erro),
    );
  }

  factory OutboxTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxTableData(
      id: serializer.fromJson<int>(json['id']),
      metodo: serializer.fromJson<String>(json['metodo']),
      endpoint: serializer.fromJson<String>(json['endpoint']),
      payload: serializer.fromJson<String>(json['payload']),
      dataCriacao: serializer.fromJson<String>(json['dataCriacao']),
      status: serializer.fromJson<String>(json['status']),
      tentativas: serializer.fromJson<int>(json['tentativas']),
      erro: serializer.fromJson<String?>(json['erro']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'metodo': serializer.toJson<String>(metodo),
      'endpoint': serializer.toJson<String>(endpoint),
      'payload': serializer.toJson<String>(payload),
      'dataCriacao': serializer.toJson<String>(dataCriacao),
      'status': serializer.toJson<String>(status),
      'tentativas': serializer.toJson<int>(tentativas),
      'erro': serializer.toJson<String?>(erro),
    };
  }

  OutboxTableData copyWith(
          {int? id,
          String? metodo,
          String? endpoint,
          String? payload,
          String? dataCriacao,
          String? status,
          int? tentativas,
          Value<String?> erro = const Value.absent()}) =>
      OutboxTableData(
        id: id ?? this.id,
        metodo: metodo ?? this.metodo,
        endpoint: endpoint ?? this.endpoint,
        payload: payload ?? this.payload,
        dataCriacao: dataCriacao ?? this.dataCriacao,
        status: status ?? this.status,
        tentativas: tentativas ?? this.tentativas,
        erro: erro.present ? erro.value : this.erro,
      );
  OutboxTableData copyWithCompanion(OutboxTableCompanion data) {
    return OutboxTableData(
      id: data.id.present ? data.id.value : this.id,
      metodo: data.metodo.present ? data.metodo.value : this.metodo,
      endpoint: data.endpoint.present ? data.endpoint.value : this.endpoint,
      payload: data.payload.present ? data.payload.value : this.payload,
      dataCriacao:
          data.dataCriacao.present ? data.dataCriacao.value : this.dataCriacao,
      status: data.status.present ? data.status.value : this.status,
      tentativas:
          data.tentativas.present ? data.tentativas.value : this.tentativas,
      erro: data.erro.present ? data.erro.value : this.erro,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxTableData(')
          ..write('id: $id, ')
          ..write('metodo: $metodo, ')
          ..write('endpoint: $endpoint, ')
          ..write('payload: $payload, ')
          ..write('dataCriacao: $dataCriacao, ')
          ..write('status: $status, ')
          ..write('tentativas: $tentativas, ')
          ..write('erro: $erro')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, metodo, endpoint, payload, dataCriacao, status, tentativas, erro);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxTableData &&
          other.id == this.id &&
          other.metodo == this.metodo &&
          other.endpoint == this.endpoint &&
          other.payload == this.payload &&
          other.dataCriacao == this.dataCriacao &&
          other.status == this.status &&
          other.tentativas == this.tentativas &&
          other.erro == this.erro);
}

class OutboxTableCompanion extends UpdateCompanion<OutboxTableData> {
  final Value<int> id;
  final Value<String> metodo;
  final Value<String> endpoint;
  final Value<String> payload;
  final Value<String> dataCriacao;
  final Value<String> status;
  final Value<int> tentativas;
  final Value<String?> erro;
  const OutboxTableCompanion({
    this.id = const Value.absent(),
    this.metodo = const Value.absent(),
    this.endpoint = const Value.absent(),
    this.payload = const Value.absent(),
    this.dataCriacao = const Value.absent(),
    this.status = const Value.absent(),
    this.tentativas = const Value.absent(),
    this.erro = const Value.absent(),
  });
  OutboxTableCompanion.insert({
    this.id = const Value.absent(),
    required String metodo,
    required String endpoint,
    required String payload,
    required String dataCriacao,
    this.status = const Value.absent(),
    this.tentativas = const Value.absent(),
    this.erro = const Value.absent(),
  })  : metodo = Value(metodo),
        endpoint = Value(endpoint),
        payload = Value(payload),
        dataCriacao = Value(dataCriacao);
  static Insertable<OutboxTableData> custom({
    Expression<int>? id,
    Expression<String>? metodo,
    Expression<String>? endpoint,
    Expression<String>? payload,
    Expression<String>? dataCriacao,
    Expression<String>? status,
    Expression<int>? tentativas,
    Expression<String>? erro,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (metodo != null) 'metodo': metodo,
      if (endpoint != null) 'endpoint': endpoint,
      if (payload != null) 'payload': payload,
      if (dataCriacao != null) 'data_criacao': dataCriacao,
      if (status != null) 'status': status,
      if (tentativas != null) 'tentativas': tentativas,
      if (erro != null) 'erro': erro,
    });
  }

  OutboxTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? metodo,
      Value<String>? endpoint,
      Value<String>? payload,
      Value<String>? dataCriacao,
      Value<String>? status,
      Value<int>? tentativas,
      Value<String?>? erro}) {
    return OutboxTableCompanion(
      id: id ?? this.id,
      metodo: metodo ?? this.metodo,
      endpoint: endpoint ?? this.endpoint,
      payload: payload ?? this.payload,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      status: status ?? this.status,
      tentativas: tentativas ?? this.tentativas,
      erro: erro ?? this.erro,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (metodo.present) {
      map['metodo'] = Variable<String>(metodo.value);
    }
    if (endpoint.present) {
      map['endpoint'] = Variable<String>(endpoint.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (dataCriacao.present) {
      map['data_criacao'] = Variable<String>(dataCriacao.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (tentativas.present) {
      map['tentativas'] = Variable<int>(tentativas.value);
    }
    if (erro.present) {
      map['erro'] = Variable<String>(erro.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxTableCompanion(')
          ..write('id: $id, ')
          ..write('metodo: $metodo, ')
          ..write('endpoint: $endpoint, ')
          ..write('payload: $payload, ')
          ..write('dataCriacao: $dataCriacao, ')
          ..write('status: $status, ')
          ..write('tentativas: $tentativas, ')
          ..write('erro: $erro')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $DespachosTable despachos = $DespachosTable(this);
  late final $RespostasPendentesTable respostasPendentes =
      $RespostasPendentesTable(this);
  late final $EvidenciasTable evidencias = $EvidenciasTable(this);
  late final $OutboxTableTable outboxTable = $OutboxTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [users, despachos, respostasPendentes, evidencias, outboxTable];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required String sub,
  Value<String?> nome,
  Value<String?> primeiroNome,
  Value<String?> email,
  Value<String?> matricula,
  Value<String?> cpf,
  Value<String?> posto,
  Value<String?> perfil,
  Value<String?> estadoOperacional,
  Value<String?> fotoUrl,
  Value<String?> tipoSanguineo,
  Value<String?> centroComandoId,
  Value<String?> equipeId,
  Value<String?> token,
  Value<String?> expiracaoToken,
  Value<String?> hashedPassword,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> sub,
  Value<String?> nome,
  Value<String?> primeiroNome,
  Value<String?> email,
  Value<String?> matricula,
  Value<String?> cpf,
  Value<String?> posto,
  Value<String?> perfil,
  Value<String?> estadoOperacional,
  Value<String?> fotoUrl,
  Value<String?> tipoSanguineo,
  Value<String?> centroComandoId,
  Value<String?> equipeId,
  Value<String?> token,
  Value<String?> expiracaoToken,
  Value<String?> hashedPassword,
  Value<int> rowid,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sub => $composableBuilder(
      column: $table.sub, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nome => $composableBuilder(
      column: $table.nome, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get primeiroNome => $composableBuilder(
      column: $table.primeiroNome, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get matricula => $composableBuilder(
      column: $table.matricula, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cpf => $composableBuilder(
      column: $table.cpf, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get posto => $composableBuilder(
      column: $table.posto, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get perfil => $composableBuilder(
      column: $table.perfil, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get estadoOperacional => $composableBuilder(
      column: $table.estadoOperacional,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fotoUrl => $composableBuilder(
      column: $table.fotoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipoSanguineo => $composableBuilder(
      column: $table.tipoSanguineo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get centroComandoId => $composableBuilder(
      column: $table.centroComandoId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get equipeId => $composableBuilder(
      column: $table.equipeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get token => $composableBuilder(
      column: $table.token, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get expiracaoToken => $composableBuilder(
      column: $table.expiracaoToken,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hashedPassword => $composableBuilder(
      column: $table.hashedPassword,
      builder: (column) => ColumnFilters(column));
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sub => $composableBuilder(
      column: $table.sub, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nome => $composableBuilder(
      column: $table.nome, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get primeiroNome => $composableBuilder(
      column: $table.primeiroNome,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get matricula => $composableBuilder(
      column: $table.matricula, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cpf => $composableBuilder(
      column: $table.cpf, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get posto => $composableBuilder(
      column: $table.posto, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get perfil => $composableBuilder(
      column: $table.perfil, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get estadoOperacional => $composableBuilder(
      column: $table.estadoOperacional,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fotoUrl => $composableBuilder(
      column: $table.fotoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipoSanguineo => $composableBuilder(
      column: $table.tipoSanguineo,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get centroComandoId => $composableBuilder(
      column: $table.centroComandoId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get equipeId => $composableBuilder(
      column: $table.equipeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get token => $composableBuilder(
      column: $table.token, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get expiracaoToken => $composableBuilder(
      column: $table.expiracaoToken,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hashedPassword => $composableBuilder(
      column: $table.hashedPassword,
      builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sub =>
      $composableBuilder(column: $table.sub, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get primeiroNome => $composableBuilder(
      column: $table.primeiroNome, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get matricula =>
      $composableBuilder(column: $table.matricula, builder: (column) => column);

  GeneratedColumn<String> get cpf =>
      $composableBuilder(column: $table.cpf, builder: (column) => column);

  GeneratedColumn<String> get posto =>
      $composableBuilder(column: $table.posto, builder: (column) => column);

  GeneratedColumn<String> get perfil =>
      $composableBuilder(column: $table.perfil, builder: (column) => column);

  GeneratedColumn<String> get estadoOperacional => $composableBuilder(
      column: $table.estadoOperacional, builder: (column) => column);

  GeneratedColumn<String> get fotoUrl =>
      $composableBuilder(column: $table.fotoUrl, builder: (column) => column);

  GeneratedColumn<String> get tipoSanguineo => $composableBuilder(
      column: $table.tipoSanguineo, builder: (column) => column);

  GeneratedColumn<String> get centroComandoId => $composableBuilder(
      column: $table.centroComandoId, builder: (column) => column);

  GeneratedColumn<String> get equipeId =>
      $composableBuilder(column: $table.equipeId, builder: (column) => column);

  GeneratedColumn<String> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);

  GeneratedColumn<String> get expiracaoToken => $composableBuilder(
      column: $table.expiracaoToken, builder: (column) => column);

  GeneratedColumn<String> get hashedPassword => $composableBuilder(
      column: $table.hashedPassword, builder: (column) => column);
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sub = const Value.absent(),
            Value<String?> nome = const Value.absent(),
            Value<String?> primeiroNome = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> matricula = const Value.absent(),
            Value<String?> cpf = const Value.absent(),
            Value<String?> posto = const Value.absent(),
            Value<String?> perfil = const Value.absent(),
            Value<String?> estadoOperacional = const Value.absent(),
            Value<String?> fotoUrl = const Value.absent(),
            Value<String?> tipoSanguineo = const Value.absent(),
            Value<String?> centroComandoId = const Value.absent(),
            Value<String?> equipeId = const Value.absent(),
            Value<String?> token = const Value.absent(),
            Value<String?> expiracaoToken = const Value.absent(),
            Value<String?> hashedPassword = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            sub: sub,
            nome: nome,
            primeiroNome: primeiroNome,
            email: email,
            matricula: matricula,
            cpf: cpf,
            posto: posto,
            perfil: perfil,
            estadoOperacional: estadoOperacional,
            fotoUrl: fotoUrl,
            tipoSanguineo: tipoSanguineo,
            centroComandoId: centroComandoId,
            equipeId: equipeId,
            token: token,
            expiracaoToken: expiracaoToken,
            hashedPassword: hashedPassword,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sub,
            Value<String?> nome = const Value.absent(),
            Value<String?> primeiroNome = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> matricula = const Value.absent(),
            Value<String?> cpf = const Value.absent(),
            Value<String?> posto = const Value.absent(),
            Value<String?> perfil = const Value.absent(),
            Value<String?> estadoOperacional = const Value.absent(),
            Value<String?> fotoUrl = const Value.absent(),
            Value<String?> tipoSanguineo = const Value.absent(),
            Value<String?> centroComandoId = const Value.absent(),
            Value<String?> equipeId = const Value.absent(),
            Value<String?> token = const Value.absent(),
            Value<String?> expiracaoToken = const Value.absent(),
            Value<String?> hashedPassword = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            sub: sub,
            nome: nome,
            primeiroNome: primeiroNome,
            email: email,
            matricula: matricula,
            cpf: cpf,
            posto: posto,
            perfil: perfil,
            estadoOperacional: estadoOperacional,
            fotoUrl: fotoUrl,
            tipoSanguineo: tipoSanguineo,
            centroComandoId: centroComandoId,
            equipeId: equipeId,
            token: token,
            expiracaoToken: expiracaoToken,
            hashedPassword: hashedPassword,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()>;
typedef $$DespachosTableCreateCompanionBuilder = DespachosCompanion Function({
  Value<int> id,
  required int ordemServicoId,
  Value<String?> escalaId,
  Value<String?> responsavelId,
  required String categoria,
  Value<String?> descricaoTarefa,
  required String status,
  Value<String?> dataInicio,
  Value<String?> dataFim,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<int> isSynced,
  Value<String?> userId,
});
typedef $$DespachosTableUpdateCompanionBuilder = DespachosCompanion Function({
  Value<int> id,
  Value<int> ordemServicoId,
  Value<String?> escalaId,
  Value<String?> responsavelId,
  Value<String> categoria,
  Value<String?> descricaoTarefa,
  Value<String> status,
  Value<String?> dataInicio,
  Value<String?> dataFim,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<int> isSynced,
  Value<String?> userId,
});

class $$DespachosTableFilterComposer
    extends Composer<_$AppDatabase, $DespachosTable> {
  $$DespachosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ordemServicoId => $composableBuilder(
      column: $table.ordemServicoId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get escalaId => $composableBuilder(
      column: $table.escalaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get responsavelId => $composableBuilder(
      column: $table.responsavelId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoria => $composableBuilder(
      column: $table.categoria, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descricaoTarefa => $composableBuilder(
      column: $table.descricaoTarefa,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dataInicio => $composableBuilder(
      column: $table.dataInicio, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dataFim => $composableBuilder(
      column: $table.dataFim, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));
}

class $$DespachosTableOrderingComposer
    extends Composer<_$AppDatabase, $DespachosTable> {
  $$DespachosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ordemServicoId => $composableBuilder(
      column: $table.ordemServicoId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get escalaId => $composableBuilder(
      column: $table.escalaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get responsavelId => $composableBuilder(
      column: $table.responsavelId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoria => $composableBuilder(
      column: $table.categoria, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descricaoTarefa => $composableBuilder(
      column: $table.descricaoTarefa,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dataInicio => $composableBuilder(
      column: $table.dataInicio, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dataFim => $composableBuilder(
      column: $table.dataFim, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));
}

class $$DespachosTableAnnotationComposer
    extends Composer<_$AppDatabase, $DespachosTable> {
  $$DespachosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ordemServicoId => $composableBuilder(
      column: $table.ordemServicoId, builder: (column) => column);

  GeneratedColumn<String> get escalaId =>
      $composableBuilder(column: $table.escalaId, builder: (column) => column);

  GeneratedColumn<String> get responsavelId => $composableBuilder(
      column: $table.responsavelId, builder: (column) => column);

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<String> get descricaoTarefa => $composableBuilder(
      column: $table.descricaoTarefa, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get dataInicio => $composableBuilder(
      column: $table.dataInicio, builder: (column) => column);

  GeneratedColumn<String> get dataFim =>
      $composableBuilder(column: $table.dataFim, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<int> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);
}

class $$DespachosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DespachosTable,
    Despacho,
    $$DespachosTableFilterComposer,
    $$DespachosTableOrderingComposer,
    $$DespachosTableAnnotationComposer,
    $$DespachosTableCreateCompanionBuilder,
    $$DespachosTableUpdateCompanionBuilder,
    (Despacho, BaseReferences<_$AppDatabase, $DespachosTable, Despacho>),
    Despacho,
    PrefetchHooks Function()> {
  $$DespachosTableTableManager(_$AppDatabase db, $DespachosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DespachosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DespachosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DespachosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> ordemServicoId = const Value.absent(),
            Value<String?> escalaId = const Value.absent(),
            Value<String?> responsavelId = const Value.absent(),
            Value<String> categoria = const Value.absent(),
            Value<String?> descricaoTarefa = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> dataInicio = const Value.absent(),
            Value<String?> dataFim = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<int> isSynced = const Value.absent(),
            Value<String?> userId = const Value.absent(),
          }) =>
              DespachosCompanion(
            id: id,
            ordemServicoId: ordemServicoId,
            escalaId: escalaId,
            responsavelId: responsavelId,
            categoria: categoria,
            descricaoTarefa: descricaoTarefa,
            status: status,
            dataInicio: dataInicio,
            dataFim: dataFim,
            latitude: latitude,
            longitude: longitude,
            isSynced: isSynced,
            userId: userId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int ordemServicoId,
            Value<String?> escalaId = const Value.absent(),
            Value<String?> responsavelId = const Value.absent(),
            required String categoria,
            Value<String?> descricaoTarefa = const Value.absent(),
            required String status,
            Value<String?> dataInicio = const Value.absent(),
            Value<String?> dataFim = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<int> isSynced = const Value.absent(),
            Value<String?> userId = const Value.absent(),
          }) =>
              DespachosCompanion.insert(
            id: id,
            ordemServicoId: ordemServicoId,
            escalaId: escalaId,
            responsavelId: responsavelId,
            categoria: categoria,
            descricaoTarefa: descricaoTarefa,
            status: status,
            dataInicio: dataInicio,
            dataFim: dataFim,
            latitude: latitude,
            longitude: longitude,
            isSynced: isSynced,
            userId: userId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DespachosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DespachosTable,
    Despacho,
    $$DespachosTableFilterComposer,
    $$DespachosTableOrderingComposer,
    $$DespachosTableAnnotationComposer,
    $$DespachosTableCreateCompanionBuilder,
    $$DespachosTableUpdateCompanionBuilder,
    (Despacho, BaseReferences<_$AppDatabase, $DespachosTable, Despacho>),
    Despacho,
    PrefetchHooks Function()>;
typedef $$RespostasPendentesTableCreateCompanionBuilder
    = RespostasPendentesCompanion Function({
  Value<int> id,
  required int despachoId,
  required String categoria,
  required String dados,
  required String dataCriacao,
  Value<int> tentativasSinc,
  Value<String?> ultimaTentativa,
  Value<String> status,
});
typedef $$RespostasPendentesTableUpdateCompanionBuilder
    = RespostasPendentesCompanion Function({
  Value<int> id,
  Value<int> despachoId,
  Value<String> categoria,
  Value<String> dados,
  Value<String> dataCriacao,
  Value<int> tentativasSinc,
  Value<String?> ultimaTentativa,
  Value<String> status,
});

class $$RespostasPendentesTableFilterComposer
    extends Composer<_$AppDatabase, $RespostasPendentesTable> {
  $$RespostasPendentesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get despachoId => $composableBuilder(
      column: $table.despachoId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoria => $composableBuilder(
      column: $table.categoria, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dados => $composableBuilder(
      column: $table.dados, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dataCriacao => $composableBuilder(
      column: $table.dataCriacao, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tentativasSinc => $composableBuilder(
      column: $table.tentativasSinc,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ultimaTentativa => $composableBuilder(
      column: $table.ultimaTentativa,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$RespostasPendentesTableOrderingComposer
    extends Composer<_$AppDatabase, $RespostasPendentesTable> {
  $$RespostasPendentesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get despachoId => $composableBuilder(
      column: $table.despachoId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoria => $composableBuilder(
      column: $table.categoria, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dados => $composableBuilder(
      column: $table.dados, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dataCriacao => $composableBuilder(
      column: $table.dataCriacao, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tentativasSinc => $composableBuilder(
      column: $table.tentativasSinc,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ultimaTentativa => $composableBuilder(
      column: $table.ultimaTentativa,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$RespostasPendentesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RespostasPendentesTable> {
  $$RespostasPendentesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get despachoId => $composableBuilder(
      column: $table.despachoId, builder: (column) => column);

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<String> get dados =>
      $composableBuilder(column: $table.dados, builder: (column) => column);

  GeneratedColumn<String> get dataCriacao => $composableBuilder(
      column: $table.dataCriacao, builder: (column) => column);

  GeneratedColumn<int> get tentativasSinc => $composableBuilder(
      column: $table.tentativasSinc, builder: (column) => column);

  GeneratedColumn<String> get ultimaTentativa => $composableBuilder(
      column: $table.ultimaTentativa, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$RespostasPendentesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RespostasPendentesTable,
    RespostasPendente,
    $$RespostasPendentesTableFilterComposer,
    $$RespostasPendentesTableOrderingComposer,
    $$RespostasPendentesTableAnnotationComposer,
    $$RespostasPendentesTableCreateCompanionBuilder,
    $$RespostasPendentesTableUpdateCompanionBuilder,
    (
      RespostasPendente,
      BaseReferences<_$AppDatabase, $RespostasPendentesTable, RespostasPendente>
    ),
    RespostasPendente,
    PrefetchHooks Function()> {
  $$RespostasPendentesTableTableManager(
      _$AppDatabase db, $RespostasPendentesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RespostasPendentesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RespostasPendentesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RespostasPendentesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> despachoId = const Value.absent(),
            Value<String> categoria = const Value.absent(),
            Value<String> dados = const Value.absent(),
            Value<String> dataCriacao = const Value.absent(),
            Value<int> tentativasSinc = const Value.absent(),
            Value<String?> ultimaTentativa = const Value.absent(),
            Value<String> status = const Value.absent(),
          }) =>
              RespostasPendentesCompanion(
            id: id,
            despachoId: despachoId,
            categoria: categoria,
            dados: dados,
            dataCriacao: dataCriacao,
            tentativasSinc: tentativasSinc,
            ultimaTentativa: ultimaTentativa,
            status: status,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int despachoId,
            required String categoria,
            required String dados,
            required String dataCriacao,
            Value<int> tentativasSinc = const Value.absent(),
            Value<String?> ultimaTentativa = const Value.absent(),
            Value<String> status = const Value.absent(),
          }) =>
              RespostasPendentesCompanion.insert(
            id: id,
            despachoId: despachoId,
            categoria: categoria,
            dados: dados,
            dataCriacao: dataCriacao,
            tentativasSinc: tentativasSinc,
            ultimaTentativa: ultimaTentativa,
            status: status,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RespostasPendentesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RespostasPendentesTable,
    RespostasPendente,
    $$RespostasPendentesTableFilterComposer,
    $$RespostasPendentesTableOrderingComposer,
    $$RespostasPendentesTableAnnotationComposer,
    $$RespostasPendentesTableCreateCompanionBuilder,
    $$RespostasPendentesTableUpdateCompanionBuilder,
    (
      RespostasPendente,
      BaseReferences<_$AppDatabase, $RespostasPendentesTable, RespostasPendente>
    ),
    RespostasPendente,
    PrefetchHooks Function()>;
typedef $$EvidenciasTableCreateCompanionBuilder = EvidenciasCompanion Function({
  Value<int> id,
  required int despachoId,
  required String filePath,
  required String tipo,
  Value<double?> latitude,
  Value<double?> longitude,
  required String dataCaptura,
  Value<String> statusSincronizacao,
  Value<int> tentativas,
});
typedef $$EvidenciasTableUpdateCompanionBuilder = EvidenciasCompanion Function({
  Value<int> id,
  Value<int> despachoId,
  Value<String> filePath,
  Value<String> tipo,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String> dataCaptura,
  Value<String> statusSincronizacao,
  Value<int> tentativas,
});

class $$EvidenciasTableFilterComposer
    extends Composer<_$AppDatabase, $EvidenciasTable> {
  $$EvidenciasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get despachoId => $composableBuilder(
      column: $table.despachoId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dataCaptura => $composableBuilder(
      column: $table.dataCaptura, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get statusSincronizacao => $composableBuilder(
      column: $table.statusSincronizacao,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tentativas => $composableBuilder(
      column: $table.tentativas, builder: (column) => ColumnFilters(column));
}

class $$EvidenciasTableOrderingComposer
    extends Composer<_$AppDatabase, $EvidenciasTable> {
  $$EvidenciasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get despachoId => $composableBuilder(
      column: $table.despachoId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dataCaptura => $composableBuilder(
      column: $table.dataCaptura, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get statusSincronizacao => $composableBuilder(
      column: $table.statusSincronizacao,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tentativas => $composableBuilder(
      column: $table.tentativas, builder: (column) => ColumnOrderings(column));
}

class $$EvidenciasTableAnnotationComposer
    extends Composer<_$AppDatabase, $EvidenciasTable> {
  $$EvidenciasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get despachoId => $composableBuilder(
      column: $table.despachoId, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get dataCaptura => $composableBuilder(
      column: $table.dataCaptura, builder: (column) => column);

  GeneratedColumn<String> get statusSincronizacao => $composableBuilder(
      column: $table.statusSincronizacao, builder: (column) => column);

  GeneratedColumn<int> get tentativas => $composableBuilder(
      column: $table.tentativas, builder: (column) => column);
}

class $$EvidenciasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EvidenciasTable,
    Evidencia,
    $$EvidenciasTableFilterComposer,
    $$EvidenciasTableOrderingComposer,
    $$EvidenciasTableAnnotationComposer,
    $$EvidenciasTableCreateCompanionBuilder,
    $$EvidenciasTableUpdateCompanionBuilder,
    (Evidencia, BaseReferences<_$AppDatabase, $EvidenciasTable, Evidencia>),
    Evidencia,
    PrefetchHooks Function()> {
  $$EvidenciasTableTableManager(_$AppDatabase db, $EvidenciasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EvidenciasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EvidenciasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EvidenciasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> despachoId = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<String> tipo = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String> dataCaptura = const Value.absent(),
            Value<String> statusSincronizacao = const Value.absent(),
            Value<int> tentativas = const Value.absent(),
          }) =>
              EvidenciasCompanion(
            id: id,
            despachoId: despachoId,
            filePath: filePath,
            tipo: tipo,
            latitude: latitude,
            longitude: longitude,
            dataCaptura: dataCaptura,
            statusSincronizacao: statusSincronizacao,
            tentativas: tentativas,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int despachoId,
            required String filePath,
            required String tipo,
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            required String dataCaptura,
            Value<String> statusSincronizacao = const Value.absent(),
            Value<int> tentativas = const Value.absent(),
          }) =>
              EvidenciasCompanion.insert(
            id: id,
            despachoId: despachoId,
            filePath: filePath,
            tipo: tipo,
            latitude: latitude,
            longitude: longitude,
            dataCaptura: dataCaptura,
            statusSincronizacao: statusSincronizacao,
            tentativas: tentativas,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EvidenciasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EvidenciasTable,
    Evidencia,
    $$EvidenciasTableFilterComposer,
    $$EvidenciasTableOrderingComposer,
    $$EvidenciasTableAnnotationComposer,
    $$EvidenciasTableCreateCompanionBuilder,
    $$EvidenciasTableUpdateCompanionBuilder,
    (Evidencia, BaseReferences<_$AppDatabase, $EvidenciasTable, Evidencia>),
    Evidencia,
    PrefetchHooks Function()>;
typedef $$OutboxTableTableCreateCompanionBuilder = OutboxTableCompanion
    Function({
  Value<int> id,
  required String metodo,
  required String endpoint,
  required String payload,
  required String dataCriacao,
  Value<String> status,
  Value<int> tentativas,
  Value<String?> erro,
});
typedef $$OutboxTableTableUpdateCompanionBuilder = OutboxTableCompanion
    Function({
  Value<int> id,
  Value<String> metodo,
  Value<String> endpoint,
  Value<String> payload,
  Value<String> dataCriacao,
  Value<String> status,
  Value<int> tentativas,
  Value<String?> erro,
});

class $$OutboxTableTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxTableTable> {
  $$OutboxTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metodo => $composableBuilder(
      column: $table.metodo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endpoint => $composableBuilder(
      column: $table.endpoint, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dataCriacao => $composableBuilder(
      column: $table.dataCriacao, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tentativas => $composableBuilder(
      column: $table.tentativas, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get erro => $composableBuilder(
      column: $table.erro, builder: (column) => ColumnFilters(column));
}

class $$OutboxTableTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxTableTable> {
  $$OutboxTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metodo => $composableBuilder(
      column: $table.metodo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endpoint => $composableBuilder(
      column: $table.endpoint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dataCriacao => $composableBuilder(
      column: $table.dataCriacao, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tentativas => $composableBuilder(
      column: $table.tentativas, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get erro => $composableBuilder(
      column: $table.erro, builder: (column) => ColumnOrderings(column));
}

class $$OutboxTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxTableTable> {
  $$OutboxTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get metodo =>
      $composableBuilder(column: $table.metodo, builder: (column) => column);

  GeneratedColumn<String> get endpoint =>
      $composableBuilder(column: $table.endpoint, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get dataCriacao => $composableBuilder(
      column: $table.dataCriacao, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get tentativas => $composableBuilder(
      column: $table.tentativas, builder: (column) => column);

  GeneratedColumn<String> get erro =>
      $composableBuilder(column: $table.erro, builder: (column) => column);
}

class $$OutboxTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OutboxTableTable,
    OutboxTableData,
    $$OutboxTableTableFilterComposer,
    $$OutboxTableTableOrderingComposer,
    $$OutboxTableTableAnnotationComposer,
    $$OutboxTableTableCreateCompanionBuilder,
    $$OutboxTableTableUpdateCompanionBuilder,
    (
      OutboxTableData,
      BaseReferences<_$AppDatabase, $OutboxTableTable, OutboxTableData>
    ),
    OutboxTableData,
    PrefetchHooks Function()> {
  $$OutboxTableTableTableManager(_$AppDatabase db, $OutboxTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> metodo = const Value.absent(),
            Value<String> endpoint = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<String> dataCriacao = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> tentativas = const Value.absent(),
            Value<String?> erro = const Value.absent(),
          }) =>
              OutboxTableCompanion(
            id: id,
            metodo: metodo,
            endpoint: endpoint,
            payload: payload,
            dataCriacao: dataCriacao,
            status: status,
            tentativas: tentativas,
            erro: erro,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String metodo,
            required String endpoint,
            required String payload,
            required String dataCriacao,
            Value<String> status = const Value.absent(),
            Value<int> tentativas = const Value.absent(),
            Value<String?> erro = const Value.absent(),
          }) =>
              OutboxTableCompanion.insert(
            id: id,
            metodo: metodo,
            endpoint: endpoint,
            payload: payload,
            dataCriacao: dataCriacao,
            status: status,
            tentativas: tentativas,
            erro: erro,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OutboxTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OutboxTableTable,
    OutboxTableData,
    $$OutboxTableTableFilterComposer,
    $$OutboxTableTableOrderingComposer,
    $$OutboxTableTableAnnotationComposer,
    $$OutboxTableTableCreateCompanionBuilder,
    $$OutboxTableTableUpdateCompanionBuilder,
    (
      OutboxTableData,
      BaseReferences<_$AppDatabase, $OutboxTableTable, OutboxTableData>
    ),
    OutboxTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$DespachosTableTableManager get despachos =>
      $$DespachosTableTableManager(_db, _db.despachos);
  $$RespostasPendentesTableTableManager get respostasPendentes =>
      $$RespostasPendentesTableTableManager(_db, _db.respostasPendentes);
  $$EvidenciasTableTableManager get evidencias =>
      $$EvidenciasTableTableManager(_db, _db.evidencias);
  $$OutboxTableTableTableManager get outboxTable =>
      $$OutboxTableTableTableManager(_db, _db.outboxTable);
}
