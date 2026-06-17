
import 'package:workmanager/workmanager.dart';
import 'package:fortivus_app/services/responder/responder_base_service.dart';
import 'package:fortivus_app/services/responder/responder_terrestre_service.dart';
import 'package:fortivus_app/services/responder/responder_maquinario_service.dart';
import 'package:fortivus_app/services/responder/responder_aereo_service.dart';
import 'package:fortivus_app/services/responder/responder_ronda_service.dart';
import 'package:fortivus_app/services/responder/responder_conscientizacao_service.dart';
import 'package:fortivus_app/services/responder/responder_formacao_brigadista_service.dart';
import 'package:fortivus_app/services/auth_service.dart';
import 'package:fortivus_app/services/local_db_service.dart';
import 'package:fortivus_app/config/environment_config.dart';
import 'package:fortivus_app/enums/tipo_categoria_formulario.dart';  
import 'package:fortivus_app/services/outbox_sync_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class ResponderServiceFactory {
  static ResponderBaseService createService(TipoCategoriaFormulario categoria) {  
    return switch (categoria) {
      TipoCategoriaFormulario.terrestre => ResponderTerrestreService(),
      TipoCategoriaFormulario.maquinario => ResponderMaquinarioService(),
      TipoCategoriaFormulario.aereo => ResponderAereoService(),
      TipoCategoriaFormulario.ronda => ResponderRondaService(),
      TipoCategoriaFormulario.conscientizacao => ResponderConscientizacaoService(),
      TipoCategoriaFormulario.formacao => ResponderFormacaoService(),
    };
  }
}

class _ProcessedResposta {
  final int registroId;
  final TipoCategoriaFormulario categoria;  
  final Map<String, dynamic> dados;

  _ProcessedResposta({
    required this.registroId,
    required this.categoria,
    required this.dados,
  });
}

class _SyncLogger {
  static const String _prefix = '[BackgroundSync]';

  _SyncLogger._();

  static void debug(String message) {
    if (kDebugMode) debugPrint('$_prefix 🔍 $message');
  }

  static void info(String message) {
    debugPrint('$_prefix ℹ️ $message');
  }

  static void success(String message) {
    debugPrint('$_prefix ✅ $message');
  }

  static void warning(String message) {
    debugPrint('$_prefix ⚠️ $message');
  }

  static void error(String message) {
    debugPrint('$_prefix ❌ $message');
  }
}

class BackgroundSyncService {
  static const String _syncTaskName = "syncTask";
  static const String _uniqueTaskName = 
      "com.beaifmt.fortivus.${kDebugMode ? 'hom' : 'prod'}.sync";
  static const Duration _syncFrequency = Duration(minutes: 15);
  static const Duration _initialDelay = Duration(minutes: 1);

  BackgroundSyncService._();

  static Future<void> initialize() async {
    try {
      await Workmanager().initialize(
        callbackDispatcher,
      );
      _SyncLogger.success('Inicializado com sucesso');
    } catch (e) {
      _SyncLogger.error('Erro ao inicializar: $e');
      rethrow;
    }
  }

  static Future<void> registerPeriodicTask() async {
    try {
      await Workmanager().cancelAll();
      await Workmanager().registerPeriodicTask(
        _uniqueTaskName,
        _syncTaskName,
        frequency: _syncFrequency,
        initialDelay: _initialDelay,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
          requiresDeviceIdle: false,
        ),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
        tag: 'sync_${kDebugMode ? 'hom' : 'prod'}',
        inputData: {
          'apiBaseUrl': EnvironmentConfig.apiBaseUrl,
        },
      );
      _SyncLogger.success('Tarefa periódica registada (intervalo: $_syncFrequency)');
    } catch (e) {
      _SyncLogger.error('Erro ao registar tarefa periódica: $e');
      rethrow;
    }
  }

  static Future<void> stopSync() async {
    try {
      await Workmanager().cancelAll();
      _SyncLogger.info('Sincronização parada');
    } catch (e) {
      _SyncLogger.error('Erro ao parar sincronização: $e');
    }
  }
}

extension _TipoCategoriaFromString on String {
  TipoCategoriaFormulario? toTipoCategoria() {
    try {
      return TipoCategoriaFormulario.values.firstWhere(
        (e) => e.descricao == this,
      );
    } catch (_) {
      return null;
    }
  }
}

class _SyncOrchestrator {
  Future<bool> executarSincronizacao() async {
    try {
      _SyncLogger.debug('Iniciando ciclo de sincronização');

      // ✅ 1. Verificar conectividade
      if (!await _verificarConectividade()) {
        return false;
      }

      // ✅ 2. Verificar autenticação
      if (!await _verificarAutenticacao()) {
        return true;
      }

      // ✅ 3. Buscar respostas pendentes
      final respostas = await LocalDbService.getRespostasPendentes();
      if (respostas.isEmpty) {
        _SyncLogger.info('Nenhuma resposta pendente');
        return true;
      }

      _SyncLogger.debug('Encontradas ${respostas.length} respostas pendentes');

      final respuestasProcessadas = _processarRespostas(respostas);
      
      if (respuestasProcessadas.isEmpty) {
        _SyncLogger.warning('Nenhuma resposta válida após processamento');
        return false;
      }

      await _sincronizarPorCategoria(respuestasProcessadas);

      // NOVO OFFLINE-FIRST: Sincronizar Fila Genérica e Evidências
      _SyncLogger.debug('Iniciando sincronização da Fila Outbox e Evidências');
      await OutboxSyncService.syncOutbox();
      await OutboxSyncService.syncEvidencias();

      _SyncLogger.success('Ciclo de sincronização concluído');
      return true;
    } catch (e, stackTrace) {
      _SyncLogger.error('Erro crítico: $e\n$stackTrace');
      return false;
    }
  }

  Future<bool> _verificarConectividade() async {
    try {
      final result = await Connectivity().checkConnectivity();
      final temConexao = !result.contains(ConnectivityResult.none);
      
      if (!temConexao) {
        _SyncLogger.debug('Sem conexão de internet');
      }
      return temConexao;
    } catch (e) {
      _SyncLogger.error('Erro ao verificar conectividade: $e');
      return false;
    }
  }

  Future<bool> _verificarAutenticacao() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(AuthService.keyIsLoggedIn) ?? false;
      final isOfflineSession = prefs.getBool(AuthService.keyIsOfflineSession) ?? false;

      if (!isLoggedIn) {
        _SyncLogger.debug('Usuário não autenticado');
        return false;
      }

      if (isOfflineSession) {
        _SyncLogger.debug('Sessão offline - não sincronizar');
        return false;
      }

      return true;
    } catch (e) {
      _SyncLogger.error('Erro ao verificar autenticação: $e');
      return false;
    }
  }

 List<_ProcessedResposta> _processarRespostas(
    List<Map<String, dynamic>> respostas,
  ) {
    final processadas = <_ProcessedResposta>[];

    for (var resposta in respostas) {
      try {
        // ✅ Leitura blindada: pega o valor, converte pra String por precaução e tenta ler como int
        final idRaw = resposta['registroId'];
        final int? registroId = idRaw != null ? int.tryParse(idRaw.toString()) : null;
        
        final dadosJson = resposta['dados'] as String?;

        if (registroId == null || dadosJson == null || dadosJson.isEmpty) {
          _SyncLogger.warning('Resposta inválida: registroId=$registroId');
          continue;
        }

        final dados = _parseJson(dadosJson);
        final metadataCategoria = dados['metadata_categoria'] as String? ?? 
                                  dados['categoria'] as String?;
        final categoria = metadataCategoria?.toTipoCategoria(); 

        if (categoria == null) {
          _SyncLogger.warning('Categoria desconhecida: $metadataCategoria');
          continue;
        }

        processadas.add(
          _ProcessedResposta(
            registroId: registroId,
            categoria: categoria,
            dados: dados,
          ),
        );
      } catch (e) {
        _SyncLogger.warning('Erro ao processar resposta: $e');
      }
    }

    return processadas;
  }

  Future<void> _sincronizarPorCategoria(
    List<_ProcessedResposta> respostas,
  ) async {
    final Map<TipoCategoriaFormulario, List<_ProcessedResposta>> porCategoria = {};  
    
    for (var resposta in respostas) {
      porCategoria.putIfAbsent(resposta.categoria, () => []).add(resposta);
    }

    for (var entry in porCategoria.entries) {
      final categoria = entry.key;
      final respostasCategoria = entry.value;
      await _sincronizarCategoria(categoria, respostasCategoria);
    }
  }

  Future<void> _sincronizarCategoria(
    TipoCategoriaFormulario categoria, 
    List<_ProcessedResposta> respostas,
  ) async {
    try {
      _SyncLogger.debug('Sincronizando ${categoria.descricao} (${respostas.length} respostas)');

      final service = ResponderServiceFactory.createService(categoria);
      await service.sincronizarRespostasPendentes();

      _SyncLogger.success('${categoria.descricao} sincronizado com sucesso');
    } catch (e, stackTrace) {
      _SyncLogger.error('Erro ao sincronizar ${categoria.descricao}: $e\n$stackTrace');
    }
  }

  static Map<String, dynamic> _parseJson(String jsonString) {
    try {
      final json = jsonDecode(jsonString);
      return Map<String, dynamic>.from(json ?? {});
    } catch (e) {
      _SyncLogger.error('Erro ao fazer parse JSON: $e');
      return {};
    }
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();

    if (taskName != "syncTask") {
      return false;
    }

    final orchestrator = _SyncOrchestrator();
    return await orchestrator.executarSincronizacao();
  });
}