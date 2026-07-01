import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:fortivus_app/config/environment_config.dart';
import 'package:fortivus_app/services/auth_service.dart';
import 'package:fortivus_app/services/local_db_service.dart';

class AttachmentUploadService {
  AttachmentUploadService._();
  static final AttachmentUploadService instance = AttachmentUploadService._();

  // Upload imediatamente se online; caso contrário, enfileira no Drift para sync posterior.
  Future<void> salvarOuEnfileirar(
      int despachoId, List<XFile> arquivos, String entityType) async {
    if (arquivos.isEmpty) return;
    final online = await _hasConnection();
    if (online) {
      await _uploadOnline(despachoId, arquivos, entityType);
    } else {
      await _enfileirarOffline(despachoId, arquivos, entityType);
    }
  }

  Future<void> _uploadOnline(
      int despachoId, List<XFile> arquivos, String entityType) async {
    final token = await AuthService().getAccessToken();
    final uri = Uri.parse('${EnvironmentConfig.attachmentsBaseUrl}/upload');

    for (final xfile in arquivos) {
      final file = File(xfile.path);
      if (!file.existsSync()) continue;

      try {
        final request = http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['despachoId'] = despachoId.toString()
          ..fields['entityType'] = entityType
          ..files.add(await http.MultipartFile.fromPath('file', xfile.path));

        final response = await request.send().timeout(const Duration(seconds: 60));

        if (response.statusCode >= 400) {
          if (kDebugMode) {
            debugPrint(
                '[AttachmentUpload] HTTP ${response.statusCode} para ${xfile.name}, enfileirando.');
          }
          await LocalDbService.instance.saveEvidencia(
            despachoId: despachoId,
            filePath: xfile.path,
            tipo: entityType,
          );
        }
      } catch (e) {
        if (kDebugMode) debugPrint('[AttachmentUpload] Falha: $e — enfileirando.');
        await LocalDbService.instance.saveEvidencia(
          despachoId: despachoId,
          filePath: xfile.path,
          tipo: entityType,
        );
      }
    }
  }

  Future<void> _enfileirarOffline(
      int despachoId, List<XFile> arquivos, String entityType) async {
    for (final xfile in arquivos) {
      await LocalDbService.instance.saveEvidencia(
        despachoId: despachoId,
        filePath: xfile.path,
        tipo: entityType,
      );
    }
    if (kDebugMode) {
      debugPrint(
          '[AttachmentUpload] ${arquivos.length} evidência(s) enfileirada(s) para despacho $despachoId');
    }
  }

  Future<bool> _hasConnection() async {
    try {
      final results = await Connectivity().checkConnectivity();
      return !results.contains(ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }
}
