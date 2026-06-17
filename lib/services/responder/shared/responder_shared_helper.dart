
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ResponderSharedHelper {
  static Future<List<XFile>> moverArquivosParaLocalSeguro(
    int idRegistro,
    List<XFile>? arquivosOriginais,
  ) async {
    if (arquivosOriginais == null || arquivosOriginais.isEmpty) return [];

    final appDocDir = await getApplicationDocumentsDirectory();
    final pastaSegura = Directory('${appDocDir.path}/outbox_files/$idRegistro');

    if (!await pastaSegura.exists()) {
      await pastaSegura.create(recursive: true);
    }

    List<XFile> arquivosSeguros = [];
    for (var arquivo in arquivosOriginais) {
      if (arquivo.path.contains('/outbox_files/')) {
        arquivosSeguros.add(arquivo);
        continue;
      }

      final fileOriginal = File(arquivo.path);
      if (await fileOriginal.exists()) {
        final novoNome =
            '${DateTime.now().millisecondsSinceEpoch}_${p.basename(arquivo.path)}';
        final caminhoSeguro = '${pastaSegura.path}/$novoNome';
        final fileCopiado = await fileOriginal.copy(caminhoSeguro);
        arquivosSeguros.add(XFile(fileCopiado.path));

        log('🔒 Arquivo salvo em: $caminhoSeguro');
      }
    }
    return arquivosSeguros;
  }

  static Future<void> moverImagemParaOutbox({
    required int idRegistro,
    required Map<String, dynamic> dados,
    required String chaveImagem,
  }) async {
    String? imagemPath = dados[chaveImagem] as String?;
    if (imagemPath == null || imagemPath.isEmpty) return;

    try {
      final imagemFile = File(imagemPath);

      if (await imagemFile.exists() && !imagemPath.contains('/outbox_files/')) {
        final appDocDir = await getApplicationDocumentsDirectory();
        final pastaSegura =
            Directory('${appDocDir.path}/outbox_files/$idRegistro');

        if (!await pastaSegura.exists()) {
          await pastaSegura.create(recursive: true);
        }

        final novoNome =
            '${DateTime.now().millisecondsSinceEpoch}_${p.basename(imagemPath)}';
        final caminhoSeguro = '${pastaSegura.path}/$novoNome';

        await imagemFile.copy(caminhoSeguro);
        dados[chaveImagem] = caminhoSeguro;

        log('🖼️ Imagem movida: $caminhoSeguro');
      }
    } catch (e) {
      log('⚠️ Erro ao mover imagem: $e');
    }
  }

  static Future<void> limparPastaSegura(int idRegistro) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final pastaSegura =
          Directory('${appDocDir.path}/outbox_files/$idRegistro');
      if (await pastaSegura.exists()) {
        await pastaSegura.delete(recursive: true);
        log('🧹 Pasta do outbox removida: $idRegistro');
      }
    } catch (e) {
      log('⚠️ Erro ao limpar: $e');
    }
  }

  static Map<String, dynamic> removerMetadata(Map<String, dynamic> dados) {
    return dados
      ..removeWhere((k, v) => [
        'arquivos',
        'arquivosLocais',
        'arquivosGerais',
        'metadata_categoria',
        'metadata_descricao_avulsa',
        'arquivosParaRemover',
        'arquivoQts',
      ].contains(k));
  }

  static void log(String message) {
    if (kDebugMode) debugPrint('[ResponderService] $message');
  }
}