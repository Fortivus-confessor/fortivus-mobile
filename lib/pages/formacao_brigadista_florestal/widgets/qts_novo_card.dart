import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fortivus_app/pages/formacao_brigadista_florestal/formacao_brigadista_state.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';
import 'package:fortivus_app/widgets/anexo_unico_card.dart';

class QtsNovoCard extends StatelessWidget {
  const QtsNovoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FormacaoBrigadistaState>(
      builder: (context, state, child) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: RadioGroup<bool>(
              groupValue: state.qtsSeguidoConforme,
              onChanged: (value) {
                if (value != null) {
                  state.setQtsSeguidoConforme(value);
                  if (value) {
                    state.setArquivoQts(null);
                  }
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ============================================================================
                  // TÍTULO
                  // ============================================================================
                  Row(
                    children: [
                      Icon(
                        Icons.description,
                        color: TacticalTheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'QTS Planejado',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '*',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'O QTS planejado foi seguido?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 16),

                  // ============================================================================
                  // OPÇÃO 1: CONFORME PLANEJADO
                  // ============================================================================
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: state.qtsSeguidoConforme
                            ? TacticalTheme.primary
                            : Colors.grey[300]!,
                        width: state.qtsSeguidoConforme ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: state.qtsSeguidoConforme
                          ? TacticalTheme.primary.withValues(alpha: 0.05)
                          : Colors.transparent,
                    ),
                    child: RadioListTile<bool>(
                      title: Text('Sim (Conforme Planejado)'),
                      subtitle: Text(
                          'O QTS foi executado conforme planejado'),
                      value: true,
                      activeColor: TacticalTheme.primary,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ============================================================================
                  // OPÇÃO 2: HOUVE ALTERAÇÕES
                  // ============================================================================
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: !state.qtsSeguidoConforme
                            ? Colors.amber[700]!
                            : Colors.grey[300]!,
                        width: !state.qtsSeguidoConforme ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: !state.qtsSeguidoConforme
                          ? Colors.amber[50]
                          : Colors.transparent,
                    ),
                    child: RadioListTile<bool>(
                      title: Text('Não (Houve Alterações)'),
                      subtitle: Text(
                          'O QTS sofreu alterações durante a execução'),
                      value: false,
                      activeColor: Colors.amber[700],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ============================================================================
                  // ANEXO ÚNICO CARD (Aparece se "Houve Alterações")
                  // ============================================================================
                  if (!state.qtsSeguidoConforme)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.amber[200]!),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.amber[50],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Anexe evidência das alterações:',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                          ),
                          const SizedBox(height: 12),

                          AnexoUnicoCard(
                            title: 'Documento QTS',
                            infoText: 'Anexe uma foto ou documento (PDF/DOCX) do novo QTS.',
                            icon: Icons.edit_document,
                            picker: state.picker,
                            arquivoSelecionado: state.arquivoQtsXFile,
                            onArquivoChanged: (novoArquivo) {
                              state.setArquivoQts(novoArquivo);
                              if (novoArquivo == null) {
                                 debugPrint('🗑️ [QTS] Arquivo removido');
                              } else {
                                 debugPrint('📄 [QTS] Arquivo selecionado: ${novoArquivo.name}');
                              }
                            },
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: TacticalTheme.primary.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(8),
                        color: TacticalTheme.primary.withValues(alpha: 0.05),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: TacticalTheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'QTS foi seguido conforme planejado',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
