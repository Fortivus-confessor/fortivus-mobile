import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/user.dart';
import '../model/registro.dart';
import '../pages/registro_page.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:geolocator/geolocator.dart'; // NOVA ARQUITETURA OFFLINE-FIRST
import 'dart:convert'; // Para utf8.encode

class LocalDbService {
  static Database? _database;

  static const String _tokenKey = 'jwt_token';
  static const String _userTable = 'users';
  static const String _registroTable =
      'registros'; // Nova tabela para registros
  static const String _respostasTable = 'respostas_pendentes';

  // --- Função para verificar senha usando BCrypt
  static bool _verifyPassword(String plainPassword, String hashedPassword) {
    try {
      return BCrypt.checkpw(plainPassword, hashedPassword);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalDbService] Erro ao verificar senha com BCrypt: $e');
      }
      return false;
    }
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');
    if (kDebugMode) {
      debugPrint('[LocalDbService] Opening database at: $path');
    }

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await _createAllTables(db);
        await _createIndexes(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _upgradeDatabase(db, oldVersion, newVersion);
      },
    );
  }

  static Future<void> _createIndexes(Database db) async {
    if (kDebugMode) {
      debugPrint('[LocalDbService] Creating indexes...');
    }

    // Índices para a tabela de registros
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_registro_user ON $_registroTable(userId)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_registro_situacao ON $_registroTable(situacao)');

    // Índices para a tabela de respostas
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_resposta_registro ON $_respostasTable(registroId)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_resposta_status ON $_respostasTable(status)');
  }

  static Future<void> _createAllTables(Database db) async {
    if (kDebugMode) {
      debugPrint('[LocalDbService] Creating all tables during onCreate...');
    }

    // Tabela de usuários (Intocada)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_userTable(
        id TEXT PRIMARY KEY,
        sub TEXT UNIQUE NOT NULL,
        nome TEXT,
        email TEXT UNIQUE,
        telefone TEXT,
        dataNascimento TEXT,
        matricula TEXT UNIQUE,
        cpf TEXT UNIQUE,
        nomeGuerra TEXT,
        posto TEXT,
        unidade TEXT,
        rg TEXT,
        perfil TEXT,
        dataAdmissao TEXT,
        failedAttempts INTEGER DEFAULT 0,
        accountLocked INTEGER DEFAULT 0,
        comandoRegionalId TEXT,
        comandoRegionalNome TEXT,
        token TEXT,
        expiracaoToken TEXT, 
        hashedPassword TEXT
      )
    ''');

    // Tabela de registros (Já nasce completa e com os tipos corretos)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_registroTable(
        id INTEGER PRIMARY KEY, 
        ordemServico INTEGER NOT NULL, 
        dataCriacaoFormatada TEXT,
        dataPreenchimentoFormatada TEXT,
        cicloGuarnicao TEXT,
        cicloGuarnicaoGuarnicao TEXT,
        cicloGuarnicaoVeiculo TEXT,
        cicloGuarnicaoComandante TEXT,
        cicloGuarnicaoPostoComandante TEXT,
        cicloGuarnicaoCondutor TEXT,
        cicloGuarnicaoPostoCondutor TEXT,
        cicloGuarnicaoConcatenado TEXT,
        categoriaDescricao TEXT,
        descricao TEXT NOT NULL,
        situacao TEXT NOT NULL,
        usuario TEXT,
        latitudeRo REAL,
        longitudeRo REAL,
        categoria TEXT,
        militares TEXT,
        comandoRegionalNome TEXT,
        viaturaModelo TEXT,
        viaturaIdentificador TEXT,
        informacaoApoio TEXT,
        pistaPouso TEXT,

        tipoAcaoConscientizacao TEXT,
        acaoOutroConscientizacao TEXT,
        projetosSentinelas INTEGER,
        deslocamentoInicialDespacho TEXT,
        deslocamentoFinalDespacho TEXT,
        nomeContato TEXT,
        telefoneContato TEXT,
        latitudeContato REAL,
        longitudeContato REAL,
        arquivosDespachoConscientizacao TEXT,

        nomeLocalFormacao TEXT,
        publicoAlvoFormacao TEXT,
        publicoAlvoOutroDescFormacao TEXT,
        cargaHorariaFormacao TEXT,
        deslocamentoInicialFormacao TEXT,
        deslocamentoFinalFormacao TEXT,
        houveContatoPrevioFormacao INTEGER,
        nomeContatoPrevioFormacao TEXT,
        telefoneContatoPrevioFormacao TEXT,
        enderecoLocalFormacao TEXT,
        arquivosDespachoFormacao TEXT,

        dataInicioRo TEXT,
        dataFinalRo TEXT,
        retroativo INTEGER DEFAULT 0,

        isSynced INTEGER DEFAULT 1,
        userId TEXT NOT NULL,
        FOREIGN KEY(userId) REFERENCES $_userTable(sub)
      )
    ''');

    // Tabela de respostas (Legado)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_respostasTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        registroId INTEGER NOT NULL, 
        dados TEXT NOT NULL,
        arquivosPath TEXT,
        dataCriacao TEXT NOT NULL,
        tentativasSinc INTEGER DEFAULT 0,
        ultimaTentativa TEXT,
        status TEXT DEFAULT 'PENDENTE',
        FOREIGN KEY(registroId) REFERENCES $_registroTable(id)
      )
    ''');

    // NOVA ARQUITETURA OFFLINE-FIRST: Evidencias
    await db.execute('''
      CREATE TABLE IF NOT EXISTS evidencia_table(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ocorrenciaId INTEGER,
        filePath TEXT NOT NULL,
        tipo TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        dataCaptura TEXT NOT NULL,
        statusSincronizacao TEXT DEFAULT 'PENDENTE'
      )
    ''');

    // NOVA ARQUITETURA OFFLINE-FIRST: Outbox (Fila Genérica)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS outbox_table(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        metodo TEXT NOT NULL,
        endpoint TEXT NOT NULL,
        payload TEXT NOT NULL,
        dataCriacao TEXT NOT NULL,
        status TEXT DEFAULT 'PENDENTE',
        tentativas INTEGER DEFAULT 0,
        erro TEXT
      )
    ''');

    if (kDebugMode) {
      debugPrint('[LocalDbService] ✅ Todas as tabelas criadas');
    }
  }

  static Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    if (kDebugMode) {
      debugPrint('[LocalDbService] Upgrading database from version $oldVersion to $newVersion');
    }
    
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE $_registroTable ADD COLUMN dataFinalRo TEXT');
        await db.execute('ALTER TABLE $_registroTable ADD COLUMN retroativo INTEGER DEFAULT 0');
        if (kDebugMode) {
          debugPrint('[LocalDbService] Migração v2 aplicada com sucesso (Colunas dataFinalRo e retroativo adicionadas)');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[LocalDbService] Erro na migração v2: $e');
        }
      }
    }

    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE $_registroTable ADD COLUMN dataInicioRo TEXT');
        if (kDebugMode) {
          debugPrint('[LocalDbService] Migração v3 aplicada com sucesso (Coluna dataInicioRo adicionada)');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[LocalDbService] Erro na migração v3: $e');
        }
      }
    }

    await verificarIntegridadeDados(db);
  }

  
  static Future<User?> getUserByEmail(String email) async {
    final db = await database;
    
    try {
      final results = await db.query(
        _userTable,
        where: 'LOWER(email) = ?',
        whereArgs: [email.toLowerCase()],
        limit: 1,
      );
      
      if (results.isEmpty) {
        if (kDebugMode) {
          debugPrint('[LocalDB] ❌ Usuário não encontrado com email: $email');
        }
        return null;
      }
      
      return User.fromMap(results.first);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalDB] ❌ Erro ao buscar usuário por email: $e');
      }
      return null;
    }
  }

  /// Busca usuário por ID
  static Future<User?> getUserById(String id) async {
    final db = await database;
    
    try {
      final results = await db.query(
        _userTable,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      
      if (results.isEmpty) return null;
      
      return User.fromMap(results.first);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalDB] ❌ Erro ao buscar usuário por ID: $e');
      }
      return null;
    }
  }

  static Future<Database> get database async {
    if (_database != null) return _database!;

    if (kDebugMode) {
      debugPrint('[LocalDbService] Initializing database...');
    }

    _database = await _initDb();

    if (kDebugMode) {
      debugPrint('[LocalDbService] Database initialized successfully.');
    }

    return _database!;
  }

  // --- Funções de gerenciamento de Token ---
  static Future<void> saveToken(String token) async {
    if (kDebugMode) {
      debugPrint('[LocalDbService] Saving token...');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    if (kDebugMode) {
      debugPrint('[LocalDbService] Token saved: ${token.substring(0, 10)}...');
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (kDebugMode && token != null) {
      debugPrint(
          '[LocalDbService] Getting token: ${token.substring(0, min(10, token.length))}...');
    } else if (kDebugMode) {
      debugPrint('[LocalDbService] Getting token: null');
    }
    return token;
  }

  static int min(int a, int b) {
    return a < b ? a : b;
  }

  static Future<void> removeToken() async {
    if (kDebugMode) {
      debugPrint('[LocalDbService] Removing token...');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    if (kDebugMode) {
      debugPrint('[LocalDbService] Token removed.');
    }
  }

  static Future<void> saveUser(User user) async {
    final db = await database;

    // Extrai o sub do token JWT
    String? userSub;
    if (user.token != null) {
      try {
        final decodedToken = JwtDecoder.decode(user.token!);
        userSub = decodedToken['sub'] as String?;
        if (kDebugMode) {
          debugPrint('[LocalDbService] Token decodificado com sucesso');
          debugPrint('[LocalDbService] Sub extraído: $userSub');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[LocalDbService] Erro ao decodificar token: ${user.token}');
          debugPrint('[LocalDbService] Erro: $e');
        }

        // Tenta extrair o sub do token recebido da API
        final apiResponse = user.toMap();
        if (apiResponse.containsKey('sub')) {
          userSub = apiResponse['sub'] as String?;
          if (kDebugMode) {
            debugPrint('[LocalDbService] Sub extraído da resposta da API: $userSub');
          }
        }
      }
    }

    if (userSub == null) {
      if (kDebugMode) {
        debugPrint('[LocalDbService] Cannot save user without sub');
      }
      return;
    }

    // Busca usuário existente pelo sub
    final existingUser = await getUserBySub(userSub);

    // Prepara o mapa de dados incluindo o sub
    final userMap = user.toMap();
    userMap['sub'] = userSub;

    // Remove o apiId do mapa pois não vamos mais usá-lo
    userMap.remove('apiId');

    if (existingUser != null) {
      user.id = existingUser.id;
      await db.update(
        _userTable,
        userMap,
        where: 'id = ?',
        whereArgs: [user.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (kDebugMode) {
        debugPrint('[LocalDbService] User updated with sub: $userSub');
      }
    } else {
      await db.insert(
        _userTable,
        userMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (kDebugMode) {
        debugPrint('[LocalDbService] New user inserted with sub: $userSub');
      }
    }

    // Salva o sub nas preferências
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_sub', userSub);

    if (kDebugMode) {
      debugPrint('[LocalDbService] User sub saved in preferences: $userSub');
    }
  }

  static Future<User?> getUserBySub(String sub) async {
    final db = await database;
    if (kDebugMode) {
      debugPrint('[LocalDbService] Querying user by sub: $sub');
    }
    final List<Map<String, dynamic>> maps = await db.query(
      _userTable,
      where: 'sub = ?',
      whereArgs: [sub],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  static Future<User?> getLoggedUser() async {
    final db = await database;
    final prefs = await SharedPreferences.getInstance();

    final String? userSub = prefs.getString('current_user_sub');
    if (userSub == null || userSub.isEmpty) {
      if (kDebugMode) {
        debugPrint('[LocalDbService] No logged user sub found in preferences');
      }
      return null;
    }

    final List<Map<String, dynamic>> maps = await db.query(
      _userTable,
      where: 'sub = ?',
      whereArgs: [userSub],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      if (kDebugMode) {
        debugPrint('[LocalDbService] Logged user found with sub: $userSub');
      }
      return User.fromMap(maps.first);
    }

    if (kDebugMode) {
      debugPrint('[LocalDbService] No user found for sub: $userSub');
    }
    return null;
  }

  static Future<User?> authenticateUserOffline(
      String identifier, String password) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      _userTable,
      where: '(email = ? OR matricula = ?)',
      whereArgs: [identifier, identifier],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final userData = maps.first;
      final String? storedHash = userData['hashedPassword'] as String?;

      if (storedHash != null && storedHash.isNotEmpty) {
        if (_verifyPassword(password, storedHash)) {
          return User.fromMap(userData);
        }
      }
    }
    return null;
  }

  static Future<void> removeUser() async {
    final db = await database;
    if (kDebugMode) {
      debugPrint('[LocalDbService] Deleting all users from $_userTable...');
    }
    await db.delete(_userTable);
    if (kDebugMode) {
      debugPrint('[LocalDbService] All users deleted from $_userTable.');
    }
  }

  static Future<void> close() async {
    final db = await database;
    if (kDebugMode) {
      debugPrint('[LocalDbService] Closing database...');
    }
    await db.close();
    _database = null;
    if (kDebugMode) {
      debugPrint('[LocalDbService] Database closed.');
    }
  }

  static Future<void> saveRegistro(Registro registro, String userSub) async {
    final db = await database;
    try {

      if (registro.situacao == 'ENCERRADA') {
        if (kDebugMode) {
          debugPrint('[LocalDbService] 🚫 Registro ${registro.id} ENCERRADO rejeitado. Removendo do cache local se existir.');
        }
        await db.delete(_registroTable, where: 'id = ?', whereArgs: [registro.id]);
        await db.delete(_respostasTable, where: 'registroId = ?', whereArgs: [registro.id]);
        return; // Aborta a função, não salva no banco!
      }
      registro.userId = userSub;
      final Map<String, dynamic> registroMap = registro.toMap();

      await db.insert(
        _registroTable,
        registroMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      if (e.toString().contains('no column named cicloGuarnicaoCondutor') ||
          e
              .toString()
              .contains('no column named cicloGuarnicaoPostoCondutor') ||
          e.toString().contains('no column named dataPreenchimentoFormatada')) {
        if (kDebugMode) {
          debugPrint('[LocalDbService] Erro de esquema detectado, corrigindo...');
        }

        try {
          final existingRegistro = await getRegistroById(registro.id);
          if (existingRegistro != null) {
            registro.userId = existingRegistro.userId ?? userSub; 
            final Map<String, dynamic> registroMapAtualizado = registro.toMap();

            await db.update(
              _registroTable,
              registroMapAtualizado,
              where: 'id = ?',
              whereArgs: [registro.id],
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          } else {
            final Map<String, dynamic> registroMapAtualizado = registro.toMap();
            await db.insert(
              _registroTable,
              registroMapAtualizado,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
          if (kDebugMode) {
            debugPrint('[LocalDbService] Registro salvo após correção do esquema');
          }
        } catch (retryError) {
          if (kDebugMode) {
            debugPrint(
                '[LocalDbService] Falha ao salvar registro mesmo após correção: $retryError');
          }
          throw Exception('Falha persistente ao salvar registro: $retryError');
        }
      } else {
        if (kDebugMode) {
          debugPrint('[LocalDbService] Erro ao salvar registro: $e');
        }
        throw Exception('Falha ao salvar registro: $e');
      }
    }
  }

  static Future<void> saveRegistros(
      List<Registro> registros, String userSub) async {
    final db = await database;
    if (kDebugMode) {
      debugPrint(
          '[LocalDbService] Salvando ${registros.length} registros protegendo pendentes...');
    }

    try {
      await db.transaction((txn) async {
        for (var registro in registros) {
          final List<Map<String, dynamic>> existingMaps = await txn.query(
            _registroTable,
            where: 'id = ?',
            whereArgs: [registro.id],
          );

          bool deveSalvar = true;

          if (registro.situacao == 'ENCERRADA') {
            if (existingMaps.isNotEmpty) {
              await txn.delete(_registroTable, where: 'id = ?', whereArgs: [registro.id]);
              await txn.delete(_respostasTable, where: 'registroId = ?', whereArgs: [registro.id]);
            }
            deveSalvar = false; 
          }

          if (existingMaps.isNotEmpty && deveSalvar) { 
            final registroLocal = Registro.fromMap(existingMaps.first);
            if ((registroLocal.situacao == 'RESPONDIDO_OFFLINE' ||
                    registroLocal.situacao == 'ENCERRADA') &&
                registro.situacao == 'ABERTA') {
              if (kDebugMode) {
                debugPrint(
                    '[LocalDbService] Protegendo registro ${registro.id} (Status Local: ${registroLocal.situacao} vs Server: ${registro.situacao})');
              }
              deveSalvar = false;
            }
          }

          if (deveSalvar) {
            registro.userId = userSub;
            final Map<String, dynamic> registroMap = registro.toMap();

            if (existingMaps.isNotEmpty) {
              await txn.update(
                _registroTable,
                registroMap,
                where: 'id = ?',
                whereArgs: [registro.id],
              );
            } else {
              await txn.insert(
                _registroTable,
                registroMap,
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          }
        }
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[LocalDbService] Erro ao salvar registros: $e');
      throw Exception('Falha ao salvar registros: $e');
    }
  }

  static Future<void> verificarIntegridadeDados([Database? dbInstance]) async {
    final db = dbInstance ?? await database;
    try {
      // Obter todos os registros
      final registros = await db.query(_registroTable);

      if (kDebugMode) {
        debugPrint(
            '[LocalDbService] Verificando integridade de ${registros.length} registros...');

        // Verificar cada registro
        for (var i = 0; i < registros.length; i++) {
          final registro = registros[i];
          debugPrint('Registro #${i + 1}:');
          debugPrint('  - id: ${registro['id']}');
          debugPrint('  - situacao: ${registro['situacao']}');

          // Verificar se militares estão presentes e válidos
          if (registro['militares'] != null) {
            try {
              final militaresJson =
                  json.decode(registro['militares'].toString());
              debugPrint('  - militares: ${militaresJson.length} encontrados');

              // Se houver militares, verifique o primeiro
              if (militaresJson.isNotEmpty) {
                debugPrint('    - Primeiro militar: ${militaresJson[0]['nome']}');
              }
            } catch (e) {
              debugPrint('  - militares: ERRO DE DESERIALIZAÇÃO: $e');
              debugPrint('  - valor bruto: ${registro['militares']}');
            }
          } else {
            debugPrint('  - militares: NULO');
          }

          // Verificar coordenadas
          debugPrint(
              '  - coordenadas: ${registro['latitudeRo']}, ${registro['longitudeRo']}');

          // Verificar outros dados importantes
          debugPrint('  - ordemServico: ${registro['ordemServico']}');
          debugPrint('  - dataCriacao: ${registro['dataCriacaoFormatada']}');
          debugPrint('  - userId: ${registro['userId']}');
          debugPrint('  - isSynced: ${registro['isSynced']}');
          debugPrint('----------------------------------');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalDbService] Erro ao verificar integridade: $e');
      }
    }
  }

  // Helper para buscar registro dentro de uma transação
  static Future<Registro?> getRegistroByApiIdFromTxn(
      Transaction txn, String id) async {
    final List<Map<String, dynamic>> maps = await txn.query(
      _registroTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Registro.fromMap(maps.first);
    }
    return null;
  }

  static Future<Registro?> getRegistroById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _registroTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Registro.fromMap(maps.first);
    }
    return null;
  }

  static Future<List<Registro>> getAllRegistros({
    String? situacao,
    String? categoria,
    required String userId, 
  }) async {
    final db = await database;
    if (kDebugMode) {
      debugPrint(
          '[LocalDbService] Getting all registros from DB (no pagination) for user: $userId...');
    }
    List<String> whereClauses = [
      'userId = ?'
    ];
    List<dynamic> whereArgs = [
      userId
    ]; 

    if (categoria != null && categoria.isNotEmpty) {
      whereClauses.add('categoriaDescricao = ?');
      whereArgs.add(categoria);
    }
    if (situacao != null && situacao.isNotEmpty) {
      whereClauses.add('situacao = ?');
      whereArgs.add(situacao);
    }

    String? whereString =
        whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final List<Map<String, dynamic>> maps = await db.query(
      _registroTable,
      where: whereString,
      whereArgs: whereArgs,
    );

    if (kDebugMode) {
      debugPrint(
          '[LocalDbService] Found ${maps.length} total offline registros for user $userId (without pagination).');
    }
    return List.generate(maps.length, (i) {
      return Registro.fromMap(maps[i]);
    });
  }

  static Future<void> clearRegistros(String userId) async {
    final db = await database;
    if (kDebugMode) {
      debugPrint(
          '[LocalDbService] Deleting all registros from $_registroTable for user: $userId...');
    }
    await db.delete(
      _registroTable,
      where: 'userId = ?', // <--- FILTRA AQUI
      whereArgs: [userId],
    );
    if (kDebugMode) {
      debugPrint(
          '[LocalDbService] All registros deleted from $_registroTable for user: $userId.');
    }
  }

  static Future<void> salvarRespostaPendente({
    required int registroId,
    required Map<String, dynamic> dados,
    List<XFile>? arquivos,
  }) async {
    if (kDebugMode) {
      debugPrint('1. TIPO do objeto "dados" recebido: ${dados.runtimeType}');
      debugPrint('2. CONTEÚDO do objeto "dados" recebido:');
      try {
        JsonEncoder encoder = const JsonEncoder.withIndent('  ');
        String prettyprint = encoder.convert(dados);
        debugPrint(prettyprint);
      } catch (e) {
        debugPrint('Não foi possível imprimir o conteúdo formatado: $dados');
      }

      try {
        final String dadosCodificados = json.encode(dados);
        debugPrint(
            '3. RESULTADO de json.encode(dados) (O que está sendo salvo no DB):');
        debugPrint(dadosCodificados);
      } catch (e) {
        debugPrint('3. FALHA ao executar json.encode(dados): $e');
      }
      debugPrint('----------------------------------------------------');
    }

    try {
      final db = await database;
      final String dataCriacao = DateTime.now().toIso8601String();
      String? arquivosPath;
      if (arquivos != null && arquivos.isNotEmpty) {
        arquivosPath = await _salvarArquivosLocalmente(registroId, arquivos);
      }
      final existente = await db.query(
        _respostasTable,
        where: 'registroId = ?',
        whereArgs: [registroId],
        limit: 1,
      );
      final Map<String, Object?> dadosParaSalvar = {
        'registroId': registroId,
        'dados': json.encode(dados),
        'arquivosPath': arquivosPath,
        'dataCriacao': dataCriacao,
        'tentativasSinc': 0,
        'status': 'PENDENTE'
      };

      if (existente.isEmpty) {
        await db.insert(
          _respostasTable,
          dadosParaSalvar,
        );
        if (kDebugMode) {
          debugPrint('Resposta pendente criada para registro $registroId');
        }
      } else {
        await db.update(
          _respostasTable,
          dadosParaSalvar,
          where: 'registroId = ?',
          whereArgs: [registroId],
        );
        if (kDebugMode) {
          debugPrint('Resposta pendente atualizada para registro $registroId');
        }
      }

      await atualizarStatusRegistro(registroId, 'RESPONDIDO_OFFLINE');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao salvar resposta pendente: $e');
      }
      throw Exception('Falha ao salvar resposta pendente: $e');
    }
  }

  static Future<Registro> criarRegistroAvulsoOffline({
    required String categoria,
    required double lat,
    required double long,
    required String userSub,
    required String descricao,
  }) async {
    await database;
    final int tempId = -(DateTime.now().millisecondsSinceEpoch);
    final novoRegistro = Registro(
      id: tempId,
      ordemServico: 0,
      dataCriacaoFormatada: DateTime.now().toIso8601String(),
      dataPreenchimentoFormatada: "",
      cicloGuarnicao: "",
      cicloGuarnicaoGuarnicao: "Guarnição Local",
      cicloGuarnicaoVeiculo: "",
      cicloGuarnicaoComandante: "",
      cicloGuarnicaoPostoComandante: "",
      cicloGuarnicaoCondutor: "",
      cicloGuarnicaoPostoCondutor: "",
      cicloGuarnicaoConcatenado: "Registro Avulso (Offline)",
      categoriaDescricao: categoria,
      descricao: descricao,
      situacao: "ABERTA",
      usuario: "Eu",
      latitudeRo: lat,
      longitudeRo: long,
      categoria: categoria,
      userId: userSub,
      isSynced: false,
    );

    await saveRegistro(novoRegistro, userSub);
    return novoRegistro;
  }

  static Future<void> apagarRegistrosOrfaos(
      List<int> idsDoServidor, String userId) async {
    final db = await database;
    if (kDebugMode) {
      debugPrint(
          '[LocalDbService] Verificando ${idsDoServidor.length} IDs do servidor para apagar registros órfãos...');
    }
    if (idsDoServidor.isEmpty) return;
    final placeholders = List.filled(idsDoServidor.length, '?').join(',');
    final count = await db.delete(
      _registroTable,
      where: 'userId = ? AND id NOT IN ($placeholders)',
      whereArgs: [userId, ...idsDoServidor],
    );
    if (count > 0 && kDebugMode) {
      debugPrint('[LocalDbService] $count registros órfãos foram apagados.');
    }
  }

  static Future<void> limparTodasAsPastasDeArquivos() async {
    try {
      if (kDebugMode) {
        debugPrint('[LocalDbService] 🧹 Iniciando limpeza total da pasta de imagens pendentes...');
      }
      final directory = await getApplicationDocumentsDirectory();
      final String pastaPendentes = join(directory.path, 'pendentes');
      final dir = Directory(pastaPendentes);
      
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        if (kDebugMode) {
          debugPrint('[LocalDbService] ✅ Pasta /pendentes deletada com sucesso.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalDbService] ❌ Erro ao deletar todas as pastas físicas: $e');
      }
    }
  }

  static Future<List<Map<String, dynamic>>> getRespostasPendentes() async {
    try {
      final db = await database;
      return await db.query(
        _respostasTable,
        // Altere a cláusula 'where' para incluir o status 'ERRO'
        where: 'status = ? OR status = ?',
        // Adicione 'ERRO' aos argumentos
        whereArgs: ['PENDENTE', 'ERRO'],
        orderBy: 'dataCriacao ASC',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalDbService] Erro ao buscar respostas pendentes: $e');
      }
      return [];
    }
  }

  static Future<void> atualizarStatusResposta(int id, String status) async {
    try {
      final db = await database;

      // Primeiro obtemos o valor atual de tentativas
      final tentativas = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT tentativasSinc FROM $_respostasTable WHERE id = ?',
            [id],
          )) ??
          0;

      await db.update(
        _respostasTable,
        {
          'status': status,
          'ultimaTentativa': DateTime.now().toIso8601String(),
          'tentativasSinc': tentativas + 1, // Incrementa o valor
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      if (kDebugMode) {
        debugPrint(
            '[LocalDbService] Status da resposta $id atualizado para $status');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalDbService] Erro ao atualizar status da resposta: $e');
      }
      throw Exception('Falha ao atualizar status da resposta: $e');
    }
  }

  static Future<String> _salvarArquivosLocalmente(
    int registroId,
    List<XFile> arquivos,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final String pastaPendentes = join(directory.path, 'pendentes', registroId.toString());
    try {
      final dir = Directory(pastaPendentes);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      List<String> paths = [];
      
      // Captura GPS no momento do salvamento da evidência
      double? lat;
      double? lng;
      try {
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        lat = pos.latitude;
        lng = pos.longitude;
      } catch (e) {
        debugPrint('[LocalDbService] Não foi possível capturar GPS da evidência: $e');
      }

      final db = await database; // NOVA ARQUITETURA OFFLINE-FIRST: Instância do DB

      for (var arquivo in arquivos) {
        final String nomeArquivo = basename(arquivo.path);
        final String novoCaminho = join(pastaPendentes, nomeArquivo);
        final File arquivoDestino = File(novoCaminho);
        try {
          final File arquivoOrigem = File(arquivo.path);

          if (await arquivoOrigem.exists()) {
            await arquivoOrigem.copy(novoCaminho);
          } else {
            if (kDebugMode) {
              debugPrint(
                  '[LocalDbService] Arquivo de cache sumiu, tentando recuperar bytes: ${arquivo.path}');
            }
            final bytes = await arquivo.readAsBytes();
            await arquivoDestino.writeAsBytes(bytes);
          }

          if (await arquivoDestino.exists()) {
            paths.add(novoCaminho);
            
            // NOVA ARQUITETURA OFFLINE-FIRST: Inserir na tabela de evidências
            await db.insert('evidencia_table', {
              'ocorrenciaId': registroId,
              'filePath': novoCaminho,
              'tipo': nomeArquivo.split('.').last.toUpperCase(),
              'latitude': lat,
              'longitude': lng,
              'dataCaptura': DateTime.now().toIso8601String(),
              'statusSincronizacao': 'PENDENTE'
            });
            
          } else {
            if (kDebugMode) {
              debugPrint(
                  '[LocalDbService] FALHA: Arquivo não foi criado em $novoCaminho');
            }
          }
        } catch (e) {
          // Isso impede que o usuário perca todo o formulário por causa de uma foto corrompida.
          if (kDebugMode) {
            debugPrint('[LocalDbService] Erro ao processar imagem específica: $e');
          }
        }
      }

      return json.encode(paths);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalDbService] Erro crítico na pasta de arquivos: $e');
      }
      throw Exception('Falha ao preparar diretório de arquivos: $e');
    }
  }

  static Future<RegistroPage> getOfflineRegistrosPaginated({
    int? registroId, 
    int? ordemServicoId,
    String? categoria,
    String? situacao,
    required String userId,
    int page = 0,
    int size = 10,
    String sort = "desc",
  }) async {
    final db = await database;
    if (kDebugMode) {
      debugPrint(
          '[LocalDbService] Getting offline registros (paginated) from DB for user: $userId...');
    }
    List<String> whereClauses = ['userId = ?'];
    List<dynamic> whereArgs = [userId];
    if (registroId != null) {
      whereClauses.add('id = ?');
      whereArgs.add(registroId);
    }
    
    if (ordemServicoId != null) {
      whereClauses.add('ordemServico = ?');
      whereArgs.add(ordemServicoId);
    }
    
    if (categoria != null && categoria.isNotEmpty) {
      whereClauses.add('categoriaDescricao = ?');
      whereArgs.add(categoria);
    }
    
    if (situacao != null && situacao.isNotEmpty) {
      // Handle both online and offline status
      if (situacao == 'ENCERRADA') {
        whereClauses.add('(situacao = ? OR situacao = ?)');
        whereArgs.add('ENCERRADA');
        whereArgs.add('RESPONDIDO_OFFLINE');
      } else if (situacao == 'ABERTA') {
        whereClauses.add('situacao = ? AND situacao != ?');
        whereArgs.add('ABERTA');
        whereArgs.add('RESPONDIDO_OFFLINE');
      } else {
        whereClauses.add('situacao = ?');
        whereArgs.add(situacao);
      }
    }

    String? whereString =
        whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final orderBy = 'dataCriacaoFormatada ${sort.toUpperCase()}';
    final offset = page * size;

    final List<Map<String, dynamic>> maps = await db.query(
      _registroTable,
      where: whereString,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: size,
      offset: offset,
    );

    final List<Registro> content = List.generate(maps.length, (i) {
      return Registro.fromMap(maps[i]);
    });

    final int totalItems = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM $_registroTable ${whereString != null ? 'WHERE $whereString' : ''}',
          whereArgs,
        )) ??
        0;

    final int totalPages = (totalItems / size).ceil();

    if (kDebugMode) {
      debugPrint(
          '[LocalDbService] Found $totalItems offline registros, page $page of $totalPages');
    }
    
    return RegistroPage(
      content: content,
      currentPage: page,
      totalPages: totalPages,
      totalItems: totalItems,
    );
  }

  // Método para atualizar o status de um registro
  static Future<void> atualizarStatusRegistro(
      int id, String novoStatus) async {
    final db = await database;
    if (kDebugMode) {
      debugPrint(
          '[LocalDbService] Atualizando status do registro $id para $novoStatus');
    }

    try {
      await db.update(
        _registroTable,
        {'situacao': novoStatus},
        where: 'id = ?',
        whereArgs: [id],
      );
      if (kDebugMode) {
        debugPrint('[LocalDbService] Status do registro atualizado com sucesso');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalDbService] Erro ao atualizar status do registro: $e');
      }
      throw Exception('Falha ao atualizar status do registro: $e');
    }
  }

  static Future<void> removerRespostaPendentePorRegistroId(int registroId) async {
    final db = await database;
    try {
      await _limparPastaDeArquivos(registroId);
      final count = await db.delete(
        _respostasTable,
        where: 'registroId = ?',
        whereArgs: [registroId],
      );
      if (kDebugMode) {
        debugPrint('[LocalDbService-Outbox] $count resposta(s) deletada(s) para o RO $registroId.');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalDbService-Outbox] Erro ao deletar resposta do RO $registroId: $e');
      }
    }
  }

  static Future<void> limparRegistrosEncerradosESincronizados() async {
    try {
      final db = await database; 
      
      final count = await db.delete(
        'registros',
        where: "situacao = ? AND isSynced = ?",
        whereArgs: ['ENCERRADA', 1],
      );

      if (kDebugMode && count > 0) {
        debugPrint('[LocalDbService] 🧹 Expurgo: $count RO(s) encerrado(s) e sincronizado(s) apagado(s) com sucesso.');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalDbService] ❌ Erro ao limpar ROs encerrados: $e');
      }
    }
  }

  static Future<void> _limparPastaDeArquivos(int registroId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final String pastaPendentes = join(directory.path, 'pendentes', registroId.toString());
      final dir = Directory(pastaPendentes);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        if (kDebugMode) {
          debugPrint('[LocalDbService-Outbox] Pasta de arquivos do RO $registroId deletada com sucesso do tablet.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalDbService-Outbox] Erro ao deletar arquivos físicos do RO $registroId: $e');
      }
    }
  }

  static Future<void> removerRegistro(int id) async {
    final db = await database;
    try {
      final count = await db.delete(
        _registroTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (kDebugMode) {
        debugPrint('[LocalDbService-Outbox] Ocorrência base $id removida do SQLite (Count: $count).');
      }
      await removerRespostaPendentePorRegistroId(id);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalDbService-Outbox] Erro ao remover registro $id: $e');
      }
      throw Exception('Falha ao remover registro: $e');
    }
  }

  static Future<void> atualizarStatusRespostaPorRegistroId(
      int registroId, String status) async {
    try {
      final db = await database;

      await db.update(
        _respostasTable,
        {'status': status},
        where: 'registroId = ?',
        whereArgs: [registroId],
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            '[LocalDbService] Erro ao atualizar status da resposta por registroId: $e');
      }
    }
  }

  static Future<Map<String, dynamic>?> getRespostaPorRegistroId(
      int registroId) async {
    final db = await database;
    if (kDebugMode) {
      debugPrint(
          '[LocalDbService] Buscando resposta local para o registro ID: $registroId');
    }
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _respostasTable,
        where: 'registroId = ?', 
        whereArgs: [registroId],
        limit: 1, 
      );

      if (maps.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('[LocalDbService] Resposta local encontrada para $registroId.');
        }
        return maps.first;
      } else {
        if (kDebugMode) {
          debugPrint(
              '[LocalDbService] Nenhuma resposta local encontrada para o registro ID: $registroId');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalDbService] Erro ao buscar resposta por registro ID: $e');
      }
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getRespostaPendentePorRegistroId(
      int registroId) async {
    final db = await database;
    if (kDebugMode) {
      debugPrint(
          '[LocalDbService] Buscando resposta pendente para o registro ID: $registroId');
    }
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _respostasTable,
        where: 'registroId = ?',
        whereArgs: [registroId],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('[LocalDbService] Resposta pendente local encontrada.');
        }
        return maps.first;
      } else {
        if (kDebugMode) {
          debugPrint(
              '[LocalDbService] Nenhuma resposta pendente local encontrada para o registro ID: $registroId');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalDbService] Erro ao buscar resposta pendente: $e');
      }
      return null;
    }
  }

  static Future<void> resetarBancoDados() async {
    try {
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'app_database.db');

      if (kDebugMode) {
        debugPrint('[LocalDbService] Resetando banco de dados em: $path');
      }

      await deleteDatabase(path);

      // Inicializar novamente o banco
      await database;

      if (kDebugMode) {
        debugPrint('[LocalDbService] Banco de dados resetado com sucesso.');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalDbService] Erro ao resetar banco de dados: $e');
      }
    }
  }

}
