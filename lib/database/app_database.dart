import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';

part 'app_database.g.dart';

// ─── TABLES ──────────────────────────────────────────────────────────────────

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get sub => text().unique()();
  TextColumn get nome => text().nullable()();
  TextColumn get primeiroNome => text().nullable()();
  TextColumn get email => text().unique().nullable()();
  TextColumn get matricula => text().unique().nullable()();
  TextColumn get cpf => text().unique().nullable()();
  TextColumn get posto => text().nullable()();
  TextColumn get perfil => text().nullable()();
  TextColumn get estadoOperacional => text().nullable()();
  TextColumn get fotoUrl => text().nullable()();
  TextColumn get tipoSanguineo => text().nullable()();
  TextColumn get centroComandoId => text().nullable()();
  TextColumn get equipeId => text().nullable()();
  // campos locais de auth
  TextColumn get token => text().nullable()();
  TextColumn get expiracaoToken => text().nullable()();
  TextColumn get hashedPassword => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Despachos extends Table {
  IntColumn get id => integer()();
  IntColumn get ordemServicoId => integer()();
  TextColumn get escalaId => text().nullable()();
  TextColumn get responsavelId => text().nullable()();
  TextColumn get categoria => text()(); // CategoriaOperacao.name
  TextColumn get descricaoTarefa => text().nullable()();
  TextColumn get status => text()(); // SituacaoDespacho.name
  TextColumn get dataInicio => text().nullable()(); // ISO 8601
  TextColumn get dataFim => text().nullable()(); // ISO 8601
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  IntColumn get isSynced => integer().withDefault(const Constant(1))();
  TextColumn get userId => text().nullable()(); // FK → users.sub

  @override
  Set<Column> get primaryKey => {id};
}

class RespostasPendentes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get despachoId => integer()();
  TextColumn get categoria => text()(); // TERRESTRE / AEREO / MAQUINARIO
  TextColumn get dados => text()(); // JSON do relatório
  TextColumn get dataCriacao => text()(); // ISO 8601
  IntColumn get tentativasSinc => integer().withDefault(const Constant(0))();
  TextColumn get ultimaTentativa => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('PENDENTE'))();
  // PENDENTE | SINCRONIZANDO | SINCRONIZADO | ERRO
}

class Evidencias extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get despachoId => integer()();
  TextColumn get filePath => text()();
  TextColumn get tipo => text()(); // FOTO / DOCUMENTO
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get dataCaptura => text()(); // ISO 8601
  TextColumn get statusSincronizacao =>
      text().withDefault(const Constant('PENDENTE'))();
}

class OutboxTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get metodo => text()(); // GET | POST | PUT | PATCH
  TextColumn get endpoint => text()();
  TextColumn get payload => text()(); // JSON
  TextColumn get dataCriacao => text()(); // ISO 8601
  TextColumn get status => text().withDefault(const Constant('PENDENTE'))();
  IntColumn get tentativas => integer().withDefault(const Constant(0))();
  TextColumn get erro => text().nullable()();
}

// ─── DATABASE ─────────────────────────────────────────────────────────────────

@DriftDatabase(
    tables: [Users, Despachos, RespostasPendentes, Evidencias, OutboxTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 4) {
            // Migração de sqflite manual (v1-v3) para Drift (v4).
            // Dados antigos descartados — o app re-sincroniza do servidor.
            await m.createAll();
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  // ─── USERS ───────────────────────────────────────────────────────────────

  Future<User?> getUser(String sub) =>
      (select(users)..where((u) => u.sub.equals(sub))).getSingleOrNull();

  Future<User?> getFirstUser() => select(users).getSingleOrNull();

  Future<void> upsertUser(UsersCompanion user) =>
      into(users).insertOnConflictUpdate(user);

  Future<void> deleteUser(String sub) =>
      (delete(users)..where((u) => u.sub.equals(sub))).go();

  Future<void> clearUsers() => delete(users).go();

  // ─── DESPACHOS ───────────────────────────────────────────────────────────

  Future<List<Despacho>> getAllDespachos({String? userId}) {
    final query = select(despachos);
    if (userId != null) {
      query.where((d) => d.userId.equals(userId));
    }
    return query.get();
  }

  Future<List<Despacho>> getDespachosAbertos({String? userId}) {
    final query = select(despachos)
      ..where((d) =>
          d.status.equals('EM_ANDAMENTO') |
          d.status.equals('PENDENTE_RELATORIO'));
    if (userId != null) {
      query.where((d) => d.userId.equals(userId));
    }
    return query.get();
  }

  Future<List<Despacho>> getDespachosConcluidos({String? userId}) {
    final query = select(despachos)
      ..where((d) => d.status.equals('CONCLUIDO'));
    if (userId != null) {
      query.where((d) => d.userId.equals(userId));
    }
    return query.get();
  }

  Future<Despacho?> getDespachoById(int id) =>
      (select(despachos)..where((d) => d.id.equals(id))).getSingleOrNull();

  Future<int> countDespachosAbertos({String? userId}) async {
    final list = await getDespachosAbertos(userId: userId);
    return list.length;
  }

  Future<int> countDespachosConcluidos({String? userId}) async {
    final list = await getDespachosConcluidos(userId: userId);
    return list.length;
  }

  Future<void> upsertDespacho(DespachosCompanion despacho) =>
      into(despachos).insertOnConflictUpdate(despacho);

  Future<void> upsertDespachos(List<DespachosCompanion> list) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(despachos, list);
    });
  }

  Future<void> updateDespachoStatus(int id, String status) =>
      (update(despachos)..where((d) => d.id.equals(id)))
          .write(DespachosCompanion(status: Value(status)));

  Future<void> markDespachoSynced(int id) =>
      (update(despachos)..where((d) => d.id.equals(id)))
          .write(const DespachosCompanion(isSynced: Value(1)));

  Future<void> markDespachoUnsynced(int id) =>
      (update(despachos)..where((d) => d.id.equals(id)))
          .write(const DespachosCompanion(isSynced: Value(0)));

  Future<void> deleteDespacho(int id) =>
      (delete(despachos)..where((d) => d.id.equals(id))).go();

  Future<void> clearDespachos({String? userId}) {
    final query = delete(despachos);
    if (userId != null) query.where((d) => d.userId.equals(userId));
    return query.go();
  }

  // ─── RESPOSTAS PENDENTES ─────────────────────────────────────────────────

  Future<List<RespostasPendente>> getAllRespostasPendentes() =>
      select(respostasPendentes).get();

  Future<List<RespostasPendente>> getRespostasPendentesByStatus(
          String status) =>
      (select(respostasPendentes)..where((r) => r.status.equals(status))).get();

  Future<int> insertRespostaPendente(
          RespostasPendentesCompanion resposta) =>
      into(respostasPendentes).insert(resposta);

  Future<void> updateRespostaStatus(int id, String status,
      {int? tentativas}) {
    return (update(respostasPendentes)..where((r) => r.id.equals(id))).write(
      RespostasPendentesCompanion(
        status: Value(status),
        ultimaTentativa: Value(DateTime.now().toIso8601String()),
        tentativasSinc:
            tentativas != null ? Value(tentativas) : const Value.absent(),
      ),
    );
  }

  Future<void> deleteRespostaPendente(int id) =>
      (delete(respostasPendentes)..where((r) => r.id.equals(id))).go();

  // ─── EVIDÊNCIAS ──────────────────────────────────────────────────────────

  Future<List<Evidencia>> getEvidenciasByDespacho(int despachoId) =>
      (select(evidencias)..where((e) => e.despachoId.equals(despachoId))).get();

  Future<List<Evidencia>> getPendingEvidencias() =>
      (select(evidencias)..where((e) => e.statusSincronizacao.equals('PENDENTE'))).get();

  Future<int> insertEvidencia(EvidenciasCompanion evidencia) =>
      into(evidencias).insert(evidencia);

  Future<void> updateEvidenciaStatus(int id, String status) =>
      (update(evidencias)..where((e) => e.id.equals(id)))
          .write(EvidenciasCompanion(statusSincronizacao: Value(status)));

  // ─── OUTBOX ──────────────────────────────────────────────────────────────

  Future<List<OutboxTableData>> getPendingOutbox() =>
      (select(outboxTable)..where((o) => o.status.equals('PENDENTE'))).get();

  Future<int> insertOutbox(OutboxTableCompanion item) =>
      into(outboxTable).insert(item);

  Future<void> updateOutboxStatus(int id, String status, {String? erro}) =>
      (update(outboxTable)..where((o) => o.id.equals(id))).write(
        OutboxTableCompanion(
          status: Value(status),
          erro: erro != null ? Value(erro) : const Value.absent(),
          tentativas: const Value.absent(),
        ),
      );

  Future<void> incrementOutboxTentativas(int id) async {
    final item = await (select(outboxTable)..where((o) => o.id.equals(id)))
        .getSingleOrNull();
    if (item != null) {
      await (update(outboxTable)..where((o) => o.id.equals(id)))
          .write(OutboxTableCompanion(tentativas: Value(item.tentativas + 1)));
    }
  }
}

// ─── CONNECTION ──────────────────────────────────────────────────────────────

QueryExecutor _openConnection() {
  return SqfliteQueryExecutor.inDatabaseFolder(
    path: 'fortivus_v4.db',
    logStatements: false,
  );
}
