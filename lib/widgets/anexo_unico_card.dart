import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';

class AnexoUnicoCard extends StatefulWidget {
  final XFile? arquivoSelecionado;
  final Function(XFile?) onArquivoChanged;
  final ImagePicker picker;
  final String title;
  final String? infoText;
  final IconData icon;

  const AnexoUnicoCard({
    super.key,
    required this.arquivoSelecionado,
    required this.onArquivoChanged,
    required this.picker,
    this.title = 'Documento Específico',
    this.infoText,
    this.icon = Icons.file_present,
  });

  @override
  State<AnexoUnicoCard> createState() => _AnexoUnicoCardState();
}

class _AnexoUnicoCardState extends State<AnexoUnicoCard> {
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

  Future<void> _capturarFotoCamera() async {
    _setProcessing(true);
    try {
      final XFile? foto = await widget.picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (foto != null) {
        widget.onArquivoChanged(foto);
      }
    } catch (e) {
      debugPrint('Erro ao capturar câmera: $e');
    } finally {
      _setProcessing(false);
    }
  }

  Future<void> _selecionarDaGaleria() async {
    _setProcessing(true);
    try {
      final XFile? foto = await widget.picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (foto != null) {
        widget.onArquivoChanged(foto);
      }
    } catch (e) {
      debugPrint('Erro ao abrir galeria: $e');
    } finally {
      _setProcessing(false);
    }
  }

  Future<void> _selecionarArquivoDocumento() async {
    _setProcessing(true);
    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        allowMultiple: false, // Garante que só um seja escolhido
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'kml', 'kmz', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        widget.onArquivoChanged(XFile(result.files.single.path!));
      }
    } catch (e) {
      debugPrint('Erro ao selecionar documento: $e');
    } finally {
      _setProcessing(false);
    }
  }

  void _removerArquivo() {
    widget.onArquivoChanged(null);
  }

  // ============================================================================
  // PRÉ-VISUALIZAÇÃO DE ARQUIVOS
  // ============================================================================

  bool _isImage(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png'].contains(ext);
  }

  IconData _getIconForExtension(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'doc':
      case 'docx': return Icons.description;
      case 'kml':
      case 'kmz': return Icons.map;
      default: return Icons.insert_drive_file;
    }
  }

  Color _getColorForExtension(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf': return Colors.red.shade600;
      case 'doc':
      case 'docx': return Colors.blue.shade600;
      case 'kml':
      case 'kmz': return Colors.green.shade700;
      default: return Colors.grey.shade600;
    }
  }

  void _abrirVisualizadorImagem(File imageFile) {
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
                maxScale: 4.0,
                child: Image.file(imageFile),
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
      icon: widget.icon,
      iconColor: TacticalTheme.accentBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TacticalTheme.buildInfoBox(
            widget.infoText ?? 'Selecione um documento ou tire uma foto.',
          ),
          const SizedBox(height: 16),

          // Se não houver arquivo, mostra os botões de seleção
          if (widget.arquivoSelecionado == null) ...[
            AbsorbPointer(
              absorbing: _isProcessing,
              child: Opacity(
                opacity: _isProcessing ? 0.5 : 1.0,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildBtn(
                            onPressed: _capturarFotoCamera,
                            icon: Icons.camera_alt,
                            label: 'Câmera',
                            color: Colors.grey.shade200,
                            textColor: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildBtn(
                            onPressed: _selecionarDaGaleria,
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
                        onPressed: _selecionarArquivoDocumento,
                        icon: Icons.folder_open,
                        label: 'Selecionar Arquivo',
                        color: TacticalTheme.primary.withValues(alpha: 0.1),
                        textColor: TacticalTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(strokeWidth: 3),
                      SizedBox(height: 8),
                      Text('Processando...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
          ] 
          // Se já houver arquivo, mostra a pré-visualização em destaque
          else
            _buildPreviewDestaque(),
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

  Widget _buildPreviewDestaque() {
    final file = widget.arquivoSelecionado!;
    final isImg = _isImage(file.path);
    final fileObj = File(file.path);

    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TacticalTheme.primary.withValues(alpha: 0.5), width: 2),
        image: isImg
            ? DecorationImage(
                image: FileImage(fileObj),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.2), BlendMode.darken),
              )
            : null,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: isImg
                ? Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _abrirVisualizadorImagem(fileObj),
                      child: const Center(
                        child: Icon(Icons.zoom_in, color: Colors.white, size: 40),
                      ),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getIconForExtension(file.path),
                        color: _getColorForExtension(file.path),
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          file.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: ElevatedButton.icon(
              onPressed: _removerArquivo,
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('Remover'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: Size.zero,
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}