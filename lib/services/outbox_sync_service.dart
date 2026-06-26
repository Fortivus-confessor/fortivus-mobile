import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:fortivus_app/config/environment_config.dart';
import 'package:fortivus_app/services/auth_service.dart';
import 'package:fortivus_app/services/local_db_service.dart';
import 'package:http/http.dart' as http;

class OutboxSyncService {
  static const int _maxTentativas = 3;

  static Future<void> syncOutbox() async {
    final token = await AuthService().getAccessToken();
    final headers = _buildHeaders(token);

    try {
      final items = await LocalDbService.instance.getPendingOutbox();

      for (final item in items) {
        if (item.tentativas >= _maxTentativas) continue;

        bool success = false;
        try {
          final response = await _dispatch(item.metodo, item.endpoint, item.payload, headers);
          success = response.statusCode >= 200 && response.statusCode < 300;
        } catch (e) {
          debugPrint('[OutboxSync] Erro no envio (id=${item.id}): $e');
        }

        if (success) {
          await LocalDbService.instance.updateOutboxStatus(item.id, 'SINCRONIZADO');
        } else {
          await LocalDbService.instance.incrementOutboxTentativas(item.id);
          if (item.tentativas + 1 >= _maxTentativas) {
            await LocalDbService.instance.updateOutboxStatus(item.id, 'ERRO',
                erro: 'Max tentativas atingido');
          }
        }
      }
    } catch (e) {
      debugPrint('[OutboxSync] Erro global: $e');
    }
  }

  static Future<http.Response> _dispatch(
      String metodo, String endpoint, String payload, Map<String, String> headers) {
    final uri = Uri.parse(endpoint);
    return switch (metodo.toUpperCase()) {
      'POST'  => http.post(uri, headers: headers, body: payload).timeout(const Duration(seconds: 30)),
      'PUT'   => http.put(uri, headers: headers, body: payload).timeout(const Duration(seconds: 30)),
      'PATCH' => http.patch(uri, headers: headers, body: payload).timeout(const Duration(seconds: 30)),
      _       => Future.error('Método HTTP não suportado: $metodo'),
    };
  }

  static Map<String, String> _buildHeaders(String? token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // ─── EVIDÊNCIAS → attachment-service ──────────────────────────────────────

  static Future<void> syncEvidencias() async {
    final token = await AuthService().getAccessToken();
    if (token == null) return;

    try {
      final user = await LocalDbService.instance.getUser();
      if (user == null) return;

      final evidencias = await LocalDbService.instance.getPendingEvidencias();

      for (final ev in evidencias) {
        final file = File(ev.filePath);
        if (!file.existsSync()) {
          await LocalDbService.instance.updateEvidenciaStatus(ev.id, 'ARQUIVO_AUSENTE');
          continue;
        }

        try {
          final uri = Uri.parse('${EnvironmentConfig.apiBaseUrl}/v1/attachments/upload');
          final request = http.MultipartRequest('POST', uri)
            ..headers['Authorization'] = 'Bearer $token'
            ..fields['despachoId'] = ev.despachoId.toString()
            ..fields['entityType'] = ev.tipo
            ..files.add(await http.MultipartFile.fromPath('file', file.path));

          final streamed = await request.send().timeout(const Duration(seconds: 60));
          final success = streamed.statusCode >= 200 && streamed.statusCode < 300;

          await LocalDbService.instance.updateEvidenciaStatus(
            ev.id,
            success ? 'SINCRONIZADO' : 'ERRO',
          );
        } catch (e) {
          debugPrint('[OutboxSync] Erro ao enviar evidência ${ev.id}: $e');
          await LocalDbService.instance.updateEvidenciaStatus(ev.id, 'ERRO');
        }
      }
    } catch (e) {
      debugPrint('[OutboxSync] Erro global em syncEvidencias: $e');
    }
  }
}
