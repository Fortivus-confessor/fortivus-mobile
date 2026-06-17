import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fortivus_app/config/environment_config.dart';
import 'package:fortivus_app/util/auth_http_helper.dart';

class AuthImageWidget extends StatefulWidget {
  final String fileName; 
  final double? width;
  final double? height;
  final BoxFit fit;

  const AuthImageWidget({
    super.key,
    required this.fileName,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  State<AuthImageWidget> createState() => _AuthImageWidgetState();
}

class _AuthImageWidgetState extends State<AuthImageWidget> {
  late Future<dynamic> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = _loadImage();
  }

  @override
  void didUpdateWidget(AuthImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fileName != widget.fileName) {
      _imageFuture = _loadImage();
    }
  }

  Future<dynamic> _loadImage() async {
    try {
      if (kDebugMode) {
        debugPrint('[AuthImageWidget] 🔍 Tentando carregar: ${widget.fileName}');
      }
      if (widget.fileName.startsWith('/')) {
        final file = File(widget.fileName);
        if (await file.exists()) {
          if (kDebugMode) {
            debugPrint('[AuthImageWidget] ✅ Arquivo local (caminho completo): ${widget.fileName}');
          }
          return file;
        } else {
          if (kDebugMode) {
            debugPrint('[AuthImageWidget] ⚠️ Caminho não existe: ${widget.fileName}');
          }
        }
      }
      final localFile = await _getLocalImageFile();
      if (localFile != null && await localFile.exists()) {
        if (kDebugMode) {
          debugPrint('[AuthImageWidget] ✅ Imagem local encontrada: ${localFile.path}');
        }
        return localFile;
      }

      // ✅ 3. SE NÃO ACHOU LOCAL, BAIXA DA API
      if (kDebugMode) {
        debugPrint('[AuthImageWidget] 📡 Tentando baixar da API: ${widget.fileName}');
      }
      return await _downloadImage();

    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AuthImageWidget] ❌ Erro ao carregar imagem: $e');
      }
      return null;
    }
  }

  Future<File?> _getLocalImageFile() async {
    try {
      // Extrai apenas o nome do arquivo (sem caminho)
      final fileName = widget.fileName.split('/').last;
      
      if (kDebugMode) {
        debugPrint('[AuthImageWidget] 🔎 Procurando arquivo: $fileName');
      }

      // 1. Tenta no diretório temporário
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      
      if (await tempFile.exists()) {
        if (kDebugMode) {
          debugPrint('[AuthImageWidget] ✅ Encontrado em temp: ${tempFile.path}');
        }
        return tempFile;
      }

      // 2. Tenta no cache do image_picker
      final cacheDir = Directory('${tempDir.path}/image_picker');
      if (await cacheDir.exists()) {
        final cacheFile = File('${cacheDir.path}/$fileName');
        if (await cacheFile.exists()) {
          if (kDebugMode) {
            debugPrint('[AuthImageWidget] ✅ Encontrado em cache: ${cacheFile.path}');
          }
          return cacheFile;
        }
      }

      // 3. Busca recursiva no diretório temporário
      final files = tempDir.listSync(recursive: true, followLinks: false);
      for (var entity in files) {
        if (entity is File && entity.path.endsWith(fileName)) {
          if (kDebugMode) {
            debugPrint('[AuthImageWidget] ✅ Encontrado por busca: ${entity.path}');
          }
          return entity;
        }
      }

      // 4. Tenta no diretório de documentos (cache persistente)
      final appDir = await getApplicationDocumentsDirectory();
      final offlineDir = Directory('${appDir.path}/offline_images');
      
      if (await offlineDir.exists()) {
        final offlineFile = File('${offlineDir.path}/$fileName');
        if (await offlineFile.exists()) {
          if (kDebugMode) {
            debugPrint('[AuthImageWidget] ✅ Encontrado em offline_images: ${offlineFile.path}');
          }
          return offlineFile;
        }
      }

      if (kDebugMode) {
        debugPrint('[AuthImageWidget] ❌ Arquivo não encontrado localmente: $fileName');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AuthImageWidget] ❌ Erro ao buscar arquivo local: $e');
      }
      return null;
    }
  }

  Future<Uint8List?> _downloadImage() async {
    try {
      // Extrai apenas o nome do arquivo para a URL
      final fileName = widget.fileName.split('/').last;
      
      String baseUrl = EnvironmentConfig.apiBaseUrl;
      if (baseUrl.endsWith('/')) baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      
      final url = Uri.parse('$baseUrl/registro_ocorrencia/arquivos/$fileName');

      if (kDebugMode) {
        debugPrint('[AuthImageWidget] 📡 URL: $url');
      }

      final response = await AuthHttpHelper.get(url);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          debugPrint('[AuthImageWidget] ✅ Download bem-sucedido (${response.bodyBytes.length} bytes)');
        }
        await _saveToCache(response.bodyBytes);
        return response.bodyBytes;
      } else {
        if (kDebugMode) {
          debugPrint('[AuthImageWidget] ❌ Erro ao baixar: ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AuthImageWidget] ❌ Erro no download: $e');
      }
      return null;
    }
  }

  Future<void> _saveToCache(Uint8List bytes) async {
    try {
      final fileName = widget.fileName.split('/').last;
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${appDir.path}/offline_images');
      
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      final file = File('${cacheDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      
      if (kDebugMode) {
        debugPrint('[AuthImageWidget] 💾 Imagem salva no cache: ${file.path}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AuthImageWidget] ❌ Erro ao salvar cache: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[200],
            child: const Center(
              child: SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[300],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image, size: 20, color: Colors.grey),
                const SizedBox(height: 4),
                Text(
                  'Indisponível',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
                if (kDebugMode)
                  Text(
                    widget.fileName.split('/').last,
                    style: const TextStyle(fontSize: 8, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          );
        }

        final data = snapshot.data!;

        if (data is File) {
          return Image.file(
            data,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            cacheWidth: widget.width != null ? (widget.width! * 2).toInt() : null,
            errorBuilder: (context, error, stackTrace) {
              if (kDebugMode) {
                debugPrint('[AuthImageWidget] ❌ Erro ao renderizar File: $error');
              }
              return Container(
                width: widget.width,
                height: widget.height,
                color: Colors.grey[300],
                child: const Icon(Icons.error, color: Colors.red),
              );
            },
          );
        } else if (data is Uint8List) {
          return Image.memory(
            data,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            cacheWidth: widget.width != null ? (widget.width! * 2).toInt() : null,
            errorBuilder: (context, error, stackTrace) {
              if (kDebugMode) {
                debugPrint('[AuthImageWidget] ❌ Erro ao renderizar Memory: $error');
              }
              return Container(
                width: widget.width,
                height: widget.height,
                color: Colors.grey[300],
                child: const Icon(Icons.error, color: Colors.red),
              );
            },
          );
        }

        return Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey[300],
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
        );
      },
    );
  }
}