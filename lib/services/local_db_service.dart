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

  // Nunca persiste token/expiracaoToken/hashedPassword aqui: o SQLite local não é
  // criptografado, e o token de sessão já vive protegido no FlutterSecureStorage
  // (Android Keystore/iOS Keychain). Gravar segredos aqui duplicaria a superfície
  // de exposição em caso de extração forense do arquivo do banco.
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
  Future<void> markDespachoUnsynced(int id) => _db.markDespachoUnsynced(id);

  Future<void> deleteDespacho(int id) => _db.deleteDespacho(id);

  Future<void> clearDespachos({String? userId}) =>
      _db.clearDespachos(userId: userId);

  // ─── RESPOSTAS PENDENTES ─────────────────────────────────────────────────

  Future<List<RespostasPendente>> getRespostasPendentes() =>
      _db.getAllRespostasPendentes();

  Future<List<RespostasPendente>> getRespostasPendentesByStatus(String status) =>
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

  Future<void> updateRespostaStatus(int id, String status) =>
      _db.updateRespostaStatus(id, status);

  Future<void> deleteRespostaPendente(int id) =>
      _db.deleteRespostaPendente(id);

  // ─── EVIDÊNCIAS ──────────────────────────────────────────────────────────

  Future<List<Evidencia>> getEvidenciasByDespacho(int despachoId) =>
      _db.getEvidenciasByDespacho(despachoId);

  Future<List<Evidencia>> getPendingEvidencias() => _db.getPendingEvidencias();

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

  Future<void> registrarFalhaEvidencia(int id, {required int maxTentativas}) =>
      _db.registrarFalhaEvidencia(id, maxTentativas: maxTentativas);

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

  // ─── HELPERS DE DESPACHO ─────────────────────────────────────────────────

  Future<RespostasPendente?> getRespostaPendenteByDespacho(int despachoId) async {
    final list = await _db.getRespostasPendentesByStatus('PENDENTE');
    try {
      return list.firstWhere((r) => r.despachoId == despachoId);
    } catch (_) {
      final erros = await _db.getRespostasPendentesByStatus('ERRO');
      try {
        return erros.firstWhere((r) => r.despachoId == despachoId);
      } catch (_) {
        return null;
      }
    }
  }

  // PIN offline é armazenado no SecureStorage (não no Drift) — o OIDC/PKCE nunca expõe
  // a senha ao app. O PIN é definido pelo usuário explicitamente após o primeiro login online.
  Future<User?> authenticateUserOffline(String identifier, String password) async {
    final allUsers = await _db.select(_db.users).get();
    try {
      return allUsers.firstWhere(
        (u) => u.email == identifier || u.matricula == identifier,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> limparTodasAsPastasDeArquivos() async {
    await _db.delete(_db.evidencias).go();
  }

  Future<void> resetarBancoDados() async {
    await _db.delete(_db.respostasPendentes).go();
    await _db.delete(_db.despachos).go();
    await _db.delete(_db.evidencias).go();
    await _db.delete(_db.outboxTable).go();
    await _db.delete(_db.users).go();
  }

  Future<void> removerRespostaPendenteByDespacho(int despachoId) async {
    final resposta = await getRespostaPendenteByDespacho(despachoId);
    if (resposta != null) {
      await _db.deleteRespostaPendente(resposta.id);
    }
  }

  Future<void> apagarDespachosOrfaos(List<int> idsServidor, String userId) async {
    final locais = await _db.getAllDespachos(userId: userId);
    for (final d in locais) {
      if (!idsServidor.contains(d.id)) {
        await _db.deleteDespacho(d.id);
      }
    }
  }

  Future<void> limparConcluidosSincronizados({String? userId}) async {
    final todos = await _db.getAllDespachos(userId: userId);
    for (final d in todos) {
      if (d.status == 'CONCLUIDO' && d.isSynced == 1) {
        await _db.deleteDespacho(d.id);
      }
    }
  }

  Future<DespachoPage> getOfflineDespachosPaginated({
    required String userId,
    int? despachoId,
    int? ordemServicoId,
    String? categoria,
    String? status,
    int page = 0,
    int size = 10,
    String sort = 'desc',
  }) async {
    var todos = await _db.getAllDespachos(userId: userId);

    if (despachoId != null) {
      todos = todos.where((d) => d.id == despachoId).toList();
    }
    if (ordemServicoId != null) {
      todos = todos.where((d) => d.ordemServicoId == ordemServicoId).toList();
    }
    if (categoria != null && categoria.isNotEmpty) {
      todos = todos.where((d) => d.categoria == categoria).toList();
    }
    if (status != null && status.isNotEmpty) {
      if (status == 'ABERTA') {
        todos = todos
            .where((d) =>
                d.status == 'EM_ANDAMENTO' || d.status == 'PENDENTE_RELATORIO')
            .toList();
      } else if (status == 'ENCERRADA') {
        todos = todos.where((d) => d.status == 'CONCLUIDO').toList();
      } else {
        todos = todos.where((d) => d.status == status).toList();
      }
    }

    if (sort == 'desc') {
      todos.sort((a, b) => b.id.compareTo(a.id));
    } else {
      todos.sort((a, b) => a.id.compareTo(b.id));
    }

    final totalItems = todos.length;
    final totalPages = size > 0 ? (totalItems / size).ceil() : 0;
    final start = page * size;
    final end = (start + size).clamp(0, totalItems);
    final pageContent =
        start < totalItems ? todos.sublist(start, end) : <Despacho>[];

    return DespachoPage(
      content: pageContent,
      currentPage: page,
      totalPages: totalPages,
      totalItems: totalItems,
    );
  }

  // ─── UTILITÁRIOS ─────────────────────────────────────────────────────────

  Future<void> close() => DatabaseProvider.instance.close();
}

class DespachoPage {
  final List<Despacho> content;
  final int currentPage;
  final int totalPages;
  final int totalItems;

  DespachoPage({
    required this.content,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });
}
