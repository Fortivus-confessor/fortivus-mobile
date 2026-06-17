import 'package:flutter/foundation.dart';
import 'package:fortivus_app/services/local_db_service.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'dart:io';

class OutboxSyncService {
  static const String _outboxTable = 'outbox_table';
  static const String _evidenciaTable = 'evidencia_table';

  static Future<void> syncOutbox() async {
    try {
      final db = await LocalDbService.database;
      final items = await db.query(
        _outboxTable,
        where: 'status = ?',
        whereArgs: ['PENDENTE'],
      );

      for (var item in items) {
        final id = item['id'] as int;
        final metodo = item['metodo'] as String;
        final endpoint = item['endpoint'] as String;
        final payload = item['payload'] as String;
        final tentativas = (item['tentativas'] as int?) ?? 0;

        bool success = false;
        try {
          if (metodo.toUpperCase() == 'POST') {
            final response = await http.post(
              Uri.parse(endpoint),
              headers: {'Content-Type': 'application/json'},
              body: payload,
            );
            if (response.statusCode >= 200 && response.statusCode < 300) {
              success = true;
            }
          } else if (metodo.toUpperCase() == 'PUT') {
            final response = await http.put(
              Uri.parse(endpoint),
              headers: {'Content-Type': 'application/json'},
              body: payload,
            );
            if (response.statusCode >= 200 && response.statusCode < 300) {
              success = true;
            }
          }
        } catch (e) {
          debugPrint('[OutboxSync] Erro no envio: $e');
        }

        if (success) {
          await db.update(
            _outboxTable,
            {'status': 'SINCRONIZADO', 'erro': null},
            where: 'id = ?',
            whereArgs: [id],
          );
        } else {
          await db.update(
            _outboxTable,
            {'tentativas': tentativas + 1, 'erro': 'Falha na requisição'},
            where: 'id = ?',
            whereArgs: [id],
          );
        }
      }
    } catch (e) {
      debugPrint('[OutboxSync] Erro global no Outbox: $e');
    }
  }

  static Future<void> syncEvidencias() async {
    try {
      final db = await LocalDbService.database;
      final items = await db.query(
        _evidenciaTable,
        where: 'statusSincronizacao = ?',
        whereArgs: ['PENDENTE'],
      );

      for (var item in items) {
        final id = item['id'] as int;
        final ocorrenciaId = item['ocorrenciaId'] as int;
        final filePath = item['filePath'] as String;
        final latitude = item['latitude'] as double?;
        final longitude = item['longitude'] as double?;
        final file = File(filePath);

        if (!await file.exists()) {
          await db.update(
            _evidenciaTable,
            {'statusSincronizacao': 'ERRO_ARQUIVO_INEXISTENTE'},
            where: 'id = ?',
            whereArgs: [id],
          );
          continue;
        }

        // Simulação de upload multipart
        bool success = true; // Substituir pelo código de upload real

        if (success) {
          await db.update(
            _evidenciaTable,
            {'statusSincronizacao': 'SINCRONIZADO'},
            where: 'id = ?',
            whereArgs: [id],
          );
        }
      }
    } catch (e) {
      debugPrint('[OutboxSync] Erro na sincronização de evidências: $e');
    }
  }
}
