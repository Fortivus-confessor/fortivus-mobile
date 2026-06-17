import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

// ============================================================================
// ENUMS E MODELS
// ============================================================================

/// Tipo de arquivo a ser enviado
enum UploadFileType {
  imageOrigin('IMAGEM_ORIGEM', 'file'),
  attachment('ARQUIVO_ANEXO', 'files');

  final String label;
  final String fieldName;

  const UploadFileType(this.label, this.fieldName);

  /// Converter de string para enum
  static UploadFileType fromString(String value) {
    return values.firstWhere(
      (e) => e.label == value,
      orElse: () => UploadFileType.attachment,
    );
  }
}

/// Representa um arquivo pendente de upload
class PendingFileUpload {
  final int registroId;
  final String filePath;
  final UploadFileType fileType;
  final String categoria;
  final DateTime addedAt;

  PendingFileUpload({
    required this.registroId,
    required this.filePath,
    required this.fileType,
    required this.categoria,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  /// Criar ID único para deduplicação
  String get _uniqueId => '$registroId|$filePath|${fileType.label}';

  Map<String, dynamic> toJson() => {
    'registroId': registroId,
    'filePath': filePath,
    'fileType': fileType.label,
    'categoria': categoria,
    'addedAt': addedAt.toIso8601String(),
  };

  factory PendingFileUpload.fromJson(Map<String, dynamic> json) {
    return PendingFileUpload(
      registroId: json['registroId'] as int? ?? 0,
      filePath: json['filePath'] as String,
      fileType: UploadFileType.fromString(json['fileType'] as String? ?? ''),
      categoria: json['categoria'] as String,
      addedAt: DateTime.tryParse(json['addedAt'] as String? ?? ''),
    );
  }

  @override
  String toString() => 'Upload($registroId/${fileType.label})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingFileUpload &&
          runtimeType == other.runtimeType &&
          _uniqueId == other._uniqueId;

  @override
  int get hashCode => _uniqueId.hashCode;
}

// ============================================================================
// QUEUE SERVICE
// ============================================================================

/// Service para gerenciar fila de uploads pendentes
/// 
/// Responsabilidades:
/// - Persistir uploads no SharedPreferences
/// - Gerenciar operações CRUD da fila
/// - Evitar duplicatas
/// - Sincronizar estado entre instâncias
/// 
/// Thread-safe com lock interno
class FileUploadQueueService {
  static final FileUploadQueueService _instance = FileUploadQueueService._internal();
  factory FileUploadQueueService() => _instance;
  FileUploadQueueService._internal();

  static const String _storageKey = 'pending_file_uploads_queue_v1'; // v1 para versionamento
  static const int _maxQueueSize = 1000; // Proteção contra crescimento infinito

  // Lock para thread-safety (futuro: usar Mutex de verdade)
  bool _isUpdating = false;

  /// Cache em memória para evitar leitura repetida do SharedPreferences
  List<PendingFileUpload>? _cachedQueue;

  // ============================================================================
  // OPERAÇÕES PRINCIPAIS
  // ============================================================================

  /// Adiciona um upload à fila
  /// 
  /// - Valida entrada
  /// - Evita duplicatas
  /// - Persiste no SharedPreferences
  Future<void> addUpload({
    required int registroId,
    required String filePath,
    required UploadFileType fileType,
    required String categoria,
  }) async {
    if (!_validateInputs(registroId, filePath)) return;

    await _updateQueue((queue) {
      final newUpload = PendingFileUpload(
        registroId: registroId,
        filePath: filePath,
        fileType: fileType,
        categoria: categoria,
      );

      // Evitar duplicata
      if (!queue.contains(newUpload)) {
        queue.add(newUpload);
        _log('✅ Upload adicionado', registroId: registroId);
      } else {
        _log('⚠️ Upload já existe', registroId: registroId);
      }
    });
  }

  /// Obtém todos os uploads da fila
  Future<List<PendingFileUpload>> getQueue() async {
    // Usar cache se disponível
    if (_cachedQueue != null) return List.from(_cachedQueue!);

    return await _readQueue() ?? [];
  }

  /// Obtém uploads de um registro específico
  Future<List<PendingFileUpload>> getByRegistroId(int registroId) async {
    final queue = await getQueue();
    return queue.where((u) => u.registroId == registroId).toList();
  }

  /// Obtém uploads de um tipo específico
  Future<List<PendingFileUpload>> getByFileType(UploadFileType fileType) async {
    final queue = await getQueue();
    return queue.where((u) => u.fileType == fileType).toList();
  }

  /// Remove um upload específico
  Future<void> removeUpload(PendingFileUpload upload) async {
    await _updateQueue((queue) {
      final sizeBefore = queue.length;
      queue.removeWhere((u) => u == upload);
      
      if (queue.length < sizeBefore) {
        _log('✅ Upload removido', registroId: upload.registroId);
      }
    });
  }

  /// Remove todos os uploads de um registro
  Future<void> removeByRegistroId(int registroId) async {
    await _updateQueue((queue) {
      final sizeBefore = queue.length;
      queue.removeWhere((u) => u.registroId == registroId);
      
      final removed = sizeBefore - queue.length;
      if (removed > 0) {
        _log('🗑️ $removed upload(s) removido(s)', registroId: registroId);
      }
    });
  }

  /// Remove todos os uploads de um tipo
  Future<void> removeByFileType(UploadFileType fileType) async {
    await _updateQueue((queue) {
      final sizeBefore = queue.length;
      queue.removeWhere((u) => u.fileType == fileType);
      _log('🗑️ ${sizeBefore - queue.length} do tipo $fileType removido(s)');
    });
  }

  /// Limpa a fila completamente
  Future<void> clear() async {
    await _updateQueue((queue) => queue.clear());
    _log('🔥 Fila completa limpa');
  }

  // ============================================================================
  // OPERAÇÕES DE LEITURA
  // ============================================================================

  /// Obtém tamanho da fila
  Future<int> getQueueSize() async {
    return (await getQueue()).length;
  }

  /// Verifica se há uploads pendentes
  Future<bool> hasUploads() async {
    return (await getQueueSize()) > 0;
  }

  /// Verifica se há uploads para um registro
  Future<bool> hasUploadsForRegistro(int registroId) async {
    return (await getByRegistroId(registroId)).isNotEmpty;
  }

  /// Obtém estatísticas da fila
  Future<Map<String, dynamic>> getStats() async {
    final queue = await getQueue();
    
    return {
      'total': queue.length,
      'byType': _groupBy(queue, (u) => u.fileType.label),
      'byCategoria': _groupBy(queue, (u) => u.categoria),
      'oldestAge': queue.isEmpty
          ? null
          : DateTime.now().difference(queue.first.addedAt).inHours,
    };
  }

  // ============================================================================
  // IMPLEMENTAÇÃO PRIVADA
  // ============================================================================

  /// Lê a fila do SharedPreferences com tratamento de erro
  Future<List<PendingFileUpload>?> _readQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_storageKey);

      if (json == null || json.isEmpty) {
        return null;
      }

      final List<dynamic> decoded = jsonDecode(json);
      return decoded
          .map((item) => PendingFileUpload.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _log('❌ Erro ao ler fila: $e');
      return null;
    }
  }

  /// Escreve a fila no SharedPreferences com validação
  Future<void> _writeQueue(List<PendingFileUpload> queue) async {
    try {
      if (queue.length > _maxQueueSize) {
        _log('⚠️ Fila excede limite ($_maxQueueSize)');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonList = queue.map((u) => u.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));

      // Atualizar cache
      _cachedQueue = List.from(queue);
      _log('💾 Fila persistida (${queue.length} itens)');
    } catch (e) {
      _log('❌ Erro ao escrever fila: $e');
    }
  }

  /// Operação atômica para atualizar a fila
  /// 
  /// Executa callback com a fila atual e persiste o resultado
  Future<void> _updateQueue(void Function(List<PendingFileUpload>) updateFn) async {
    // Simular lock (em produção, usar Mutex real)
    while (_isUpdating) {
      await Future.delayed(const Duration(milliseconds: 10));
    }

    _isUpdating = true;
    try {
      final queue = await getQueue();
      updateFn(queue);
      await _writeQueue(queue);
    } finally {
      _isUpdating = false;
    }
  }

  /// Agrupa itens por chave
  Map<String, int> _groupBy<T>(
    List<T> items,
    String Function(T) keyFn,
  ) {
    final groups = <String, int>{};
    for (final item in items) {
      final key = keyFn(item);
      groups[key] = (groups[key] ?? 0) + 1;
    }
    return groups;
  }

  /// Valida entrada
  bool _validateInputs(int registroId, String filePath) {
    if (registroId == 0 || filePath.isEmpty) {
      _log('⚠️ Entrada inválida');
      return false;
    }
    return true;
  }

  /// Logging estruturado
  void _log(String message, {int? registroId}) {
    if (kDebugMode) {
      final prefix = registroId != null ? '[$registroId] ' : '';
      debugPrint('[FileUploadQueue] $prefix$message');
    }
  }
}