import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';

class LocalDbService {
  LocalDbService._();
  static final LocalDbService _instance = LocalDbService._();
  static LocalDbService get instance => _instance;

  AppDatabase get _db => DatabaseProvider.instance.database;

  // ─── USERS ───────────────────────────────────────────────────────────────

  Future<User?> getUser({String? sub}) async {
    if (sub != null) return _db.getUser(sub);
    return _db.getFirstUser();
  }

  Future<void> saveUser(Map<String, dynamic> data) async {
    await _db.upsertUser(UsersCompanion(
      id: Value(data['id'] as String? ?? data['sub'] as String),
      sub: Value(data['sub'] as String),
      nome: Value(data['nome'] as String?),
      primeiroNome: Value(data['primeiroNome'] as String?),
      email: Value(data['email'] as String?),
      matricula: Value(data['matricula'] as String?),
      cpf: Value(data['cpf'] as String?),
      posto: Value(data['posto'] as String?),
      perfil: Value(data['perfil'] as String?),
      estadoOperacional: Value(data['estadoOperacional'] as String?),
      fotoUrl: Value(data['fotoUrl'] as String?),
      tipoSanguineo: Value(data['tipoSanguineo'] as String?),
      centroComandoId: Value(data['centroComandoId'] as String?),
      equipeId: Value(data['equipeId'] as String?),
      token: Value(data['token'] as String?),
      expiracaoToken: Value(data['expiracaoToken'] as String?),
      hashedPassword: Value(data['hashedPassword'] as String?),
    ));
  }

  Future<Map<String, dynamic>?> getUserAsMap({String? sub}) async {
    final user = await getUser(sub: sub);
    if (user == null) return null;
    return {
      'id': user.id,
      'sub': user.sub,
      'nome': user.nome,
      'primeiroNome': user.primeiroNome,
      'email': user.email,
      'matricula': user.matricula,
      'cpf': user.cpf,
      'posto': user.posto,
      'perfil': user.perfil,
      'estadoOperacional': user.estadoOperacional,
      'fotoUrl': user.fotoUrl,
      'tipoSanguineo': user.tipoSanguineo,
      'centroComandoId': user.centroComandoId,
      'equipeId': user.equipeId,
      'token': user.token,
      'expiracaoToken': user.expiracaoToken,
      'hashedPassword': user.hashedPassword,
    };
  }

  Future<void> deleteUser(String sub) => _db.deleteUser(sub);
  Future<void> clearUsers() => _db.clearUsers();

  // ─── DESPACHOS ───────────────────────────────────────────────────────────

  Future<List<Despacho>> getDespachos({String? userId}) =>
      _db.getAllDespachos(userId: userId);

  Future<List<Despacho>> getDespachosAbertos({String? userId}) =>
      _db.getDespachosAbertos(userId: userId);

  Future<List<Despacho>> getDespachosConcluidos({String? userId}) =>
      _db.getDespachosConcluidos(userId: userId);

  Future<Despacho?> getDespachoById(int id) => _db.getDespachoById(id);

  Future<int> countAbertos({String? userId}) =>
      _db.countDespachosAbertos(userId: userId);

  Future<int> countConcluidos({String? userId}) =>
      _db.countDespachosConcluidos(userId: userId);

  Future<void> saveDespacho(Map<String, dynamic> data) async {
    await _db.upsertDespacho(DespachosCompanion(
      id: Value(data['id'] as int),
      ordemServicoId: Value(data['ordemServicoId'] as int),
      escalaId: Value(data['escalaId'] as String?),
      responsavelId: Value(data['responsavelId'] as String?),
      categoria: Value(data['categoria'] as String? ?? 'TERRESTRE'),
      descricaoTarefa: Value(data['descricaoTarefa'] as String?),
      status: Value(data['status'] as String? ?? 'EM_ANDAMENTO'),
      dataInicio: Value(data['dataInicio'] as String?),
      dataFim: Value(data['dataFim'] as String?),
      latitude: Value(data['latitude'] as double?),
      longitude: Value(data['longitude'] as double?),
      isSynced: Value(data['isSynced'] as int? ?? 1),
      userId: Value(data['userId'] as String?),
    ));
  }

  Future<void> saveDespachos(List<Map<String, dynamic>> list) async {
    final companions = list
        .map((data) => DespachosCompanion(
              id: Value(data['id'] as int),
              ordemServicoId: Value(data['ordemServicoId'] as int),
              escalaId: Value(data['escalaId'] as String?),
              responsavelId: Value(data['responsavelId'] as String?),
              categoria: Value(data['categoria'] as String? ?? 'TERRESTRE'),
              descricaoTarefa: Value(data['descricaoTarefa'] as String?),
              status: Value(data['status'] as String? ?? 'EM_ANDAMENTO'),
              dataInicio: Value(data['dataInicio'] as String?),
              dataFim: Value(data['dataFim'] as String?),
              latitude: Value(data['latitude'] as double?),
              longitude: Value(data['longitude'] as double?),
              isSynced: Value(data['isSynced'] as int? ?? 1),
              userId: Value(data['userId'] as String?),
            ))
        .toList();
    await _db.upsertDespachos(companions);
  }

  Future<void> updateDespachoStatus(int id, String status) =>
      _db.updateDespachoStatus(id, status);

  Future<void> markDespachoSynced(int id) => _db.markDespachoSynced(id);

  Future<void> deleteDespacho(int id) => _db.deleteDespacho(id);

  Future<void> clearDespachos({String? userId}) =>
      _db.clearDespachos(userId: userId);

  // ─── RESPOSTAS PENDENTES ─────────────────────────────────────────────────

  Future<List<RespostaPendente>> getRespostasPendentes() =>
      _db.getAllRespostasPendentes();

  Future<List<RespostaPendente>> getRespostasPendentesByStatus(String status) =>
      _db.getRespostasPendentesByStatus(status);

  Future<int> saveRespostaPendente({
    required int despachoId,
    required String categoria,
    required String dadosJson,
  }) =>
      _db.insertRespostaPendente(RespostasPendentesCompanion(
        despachoId: Value(despachoId),
        categoria: Value(categoria),
        dados: Value(dadosJson),
        dataCriacao: Value(DateTime.now().toIso8601String()),
        status: const Value('PENDENTE'),
      ));

  Future<void> updateRespostaStatus(int id, String status, {String? erro}) =>
      _db.updateRespostaStatus(id, status, erro: erro);

  Future<void> deleteRespostaPendente(int id) =>
      _db.deleteRespostaPendente(id);

  // ─── EVIDÊNCIAS ──────────────────────────────────────────────────────────

  Future<List<Evidencia>> getEvidenciasByDespacho(int despachoId) =>
      _db.getEvidenciasByDespacho(despachoId);

  Future<int> saveEvidencia({
    required int despachoId,
    required String filePath,
    required String tipo,
    double? latitude,
    double? longitude,
  }) =>
      _db.insertEvidencia(EvidenciasCompanion(
        despachoId: Value(despachoId),
        filePath: Value(filePath),
        tipo: Value(tipo),
        latitude: Value(latitude),
        longitude: Value(longitude),
        dataCaptura: Value(DateTime.now().toIso8601String()),
        statusSincronizacao: const Value('PENDENTE'),
      ));

  Future<void> updateEvidenciaStatus(int id, String status) =>
      _db.updateEvidenciaStatus(id, status);

  // ─── OUTBOX ──────────────────────────────────────────────────────────────

  Future<List<OutboxTableData>> getPendingOutbox() => _db.getPendingOutbox();

  Future<int> addToOutbox({
    required String metodo,
    required String endpoint,
    required String payloadJson,
  }) =>
      _db.insertOutbox(OutboxTableCompanion(
        metodo: Value(metodo),
        endpoint: Value(endpoint),
        payload: Value(payloadJson),
        dataCriacao: Value(DateTime.now().toIso8601String()),
        status: const Value('PENDENTE'),
      ));

  Future<void> updateOutboxStatus(int id, String status, {String? erro}) =>
      _db.updateOutboxStatus(id, status, erro: erro);

  Future<void> incrementOutboxTentativas(int id) =>
      _db.incrementOutboxTentativas(id);

  // ─── UTILITÁRIOS ─────────────────────────────────────────────────────────

  Future<void> close() => DatabaseProvider.instance.close();
}
