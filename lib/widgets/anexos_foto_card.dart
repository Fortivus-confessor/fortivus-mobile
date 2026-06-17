import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';

class AnexosFotoCard extends StatefulWidget {
  final ValueNotifier<List<XFile>> arquivosNotifier;
  final ImagePicker picker;
  final String? infoText;
  final String title;

  const AnexosFotoCard({
    super.key,
    required this.arquivosNotifier,
    required this.picker,
    this.infoText,
    this.title = 'Anexos da Operação',
  });

  @override
  State<AnexosFotoCard> createState() => _AnexosFotoCardState();
}

class _AnexosFotoCardState extends State<AnexosFotoCard> {
  // ============================================================================
  // ESTADO
  // ============================================================================
  bool _isProcessing = false;

  void _setProcessing(bool value) {
    if (mounted) {
      setState(() => _isProcessing = value);
    }
  }

  // ============================================================================
  // AÇÕES DE SELEÇÃO
  // ============================================================================

  Future<void> _adicionarFotoCamera() async {
    _setProcessing(true);
    try {
      final XFile? foto = await widget.picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (foto != null) {
        widget.arquivosNotifier.value = [...widget.arquivosNotifier.value, foto];
      }
    } catch (e) {
      debugPrint('Erro ao capturar câmera: $e');
    } finally {
      _setProcessing(false);
    }
  }

  Future<void> _adicionarDaGaleria() async {
    _setProcessing(true);
    try {
      // Permite selecionar várias fotos de uma vez (Nativo iOS e Android)
      final List<XFile> fotos = await widget.picker.pickMultiImage(
        imageQuality: 80,
      );
      if (fotos.isNotEmpty) {
        widget.arquivosNotifier.value = [...widget.arquivosNotifier.value, ...fotos];
      }
    } catch (e) {
      debugPrint('Erro ao abrir galeria: $e');
    } finally {
      _setProcessing(false);
    }
  }

  Future<void> _adicionarArquivos() async {
    _setProcessing(true);
    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'kml', 'kmz', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        final novosArquivos = result.files
            .where((f) => f.path != null)
            .map((f) => XFile(f.path!))
            .toList();
        widget.arquivosNotifier.value = [...widget.arquivosNotifier.value, ...novosArquivos];
      }
    } catch (e) {
      debugPrint('Erro ao selecionar arquivos: $e');
    } finally {
      _setProcessing(false);
    }
  }

  void _removerArquivo(int index) {
    final lista = List<XFile>.from(widget.arquivosNotifier.value);
    lista.removeAt(index);
    widget.arquivosNotifier.value = lista;
  }

  // ============================================================================
  // PRÉ-VISUALIZAÇÃO DE ARQUIVOS
  // ============================================================================

  bool _isImage(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png'].contains(ext);
  }

  void _abrirVisualizador(XFile arquivo) {
    if (!_isImage(arquivo.path)) return; // Documentos não abrem no visualizador de imagem

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (BuildContext context) {
        return Stack(
          children: [
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0, // Permite zoom de até 4x
                child: Image.file(File(arquivo.path)),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================================
  // BUILD PRINCIPAL
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return TacticalTheme.buildCard(
      title: widget.title,
      icon: Icons.attach_file,
      iconColor: TacticalTheme.accentBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TacticalTheme.buildInfoBox(
            widget.infoText ?? 'Anexe imagens da ocorrência ou arquivos (PDF, KML).',
          ),
          const SizedBox(height: 16),

          // --- BOTÕES DE AÇÃO ---
          AbsorbPointer(
            absorbing: _isProcessing, // Bloqueia cliques se estiver processando
            child: Opacity(
              opacity: _isProcessing ? 0.5 : 1.0,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildBtn(
                          onPressed: _adicionarFotoCamera,
                          icon: Icons.camera_alt,
                          label: 'Câmera',
                          color: Colors.grey.shade200,
                          textColor: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildBtn(
                          onPressed: _adicionarDaGaleria,
                          icon: Icons.photo_library,
                          label: 'Galeria',
                          color: Colors.grey.shade200,
                          textColor: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: _buildBtn(
                      onPressed: _adicionarArquivos,
                      icon: Icons.folder_open,
                      label: 'Adicionar Documentos',
                      color: TacticalTheme.primary.withValues(alpha: 0.1),
                      textColor: TacticalTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- BARRA DE PROGRESSO ---
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(strokeWidth: 3),
                    SizedBox(height: 8),
                    Text('Processando arquivos...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),

          // --- LISTA DE ANEXOS ---
          ValueListenableBuilder<List<XFile>>(
            valueListenable: widget.arquivosNotifier,
            builder: (context, arquivos, _) {
              if (arquivos.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(),
                  ),
                  Text(
                    'Anexos Selecionados (${arquivos.length}):',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(
                      arquivos.length,
                      (index) => _buildMiniatura(arquivos[index], index),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // WIDGETS AUXILIARES
  // ============================================================================

  Widget _buildBtn({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildMiniatura(XFile arquivo, int index) {
    final isImg = _isImage(arquivo.path);
    final ext = arquivo.path.split('.').last.toUpperCase();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () => _abrirVisualizador(arquivo),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              image: isImg
                  ? DecorationImage(
                      image: FileImage(File(arquivo.path)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: !isImg
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        ext == 'PDF' ? Icons.picture_as_pdf : Icons.insert_drive_file,
                        color: ext == 'PDF' ? Colors.red : Colors.blueGrey,
                        size: 30,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ext,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                : null,
          ),
        ),
        
        // Botão de Excluir no canto
        Positioned(
          right: -8,
          top: -8,
          child: InkWell(
            onTap: () => _removerArquivo(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}