import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fortivus_app/services/local_db_service.dart';

/// LOCAL-FIRST: evidências (fotos) são sempre enfileiradas no banco local
/// (fonte da verdade) e enviadas ao attachment-service em background pelo
/// OutboxSyncService. Nunca bloqueia o usuário esperando o upload — mesmo online.
class AttachmentUploadService {
  AttachmentUploadService._();
  static final AttachmentUploadService instance = AttachmentUploadService._();

  Future<void> salvarOuEnfileirar(
      int despachoId, List<XFile> arquivos, String entityType) async {
    if (arquivos.isEmpty) return;
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
}
