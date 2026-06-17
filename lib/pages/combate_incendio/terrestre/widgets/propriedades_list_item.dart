import 'package:flutter/material.dart';
import 'package:fortivus_app/model/propriedade_apoio.dart';
import 'package:fortivus_app/enums/enums.dart';

class PropriedadeListItem extends StatelessWidget {
  final PropriedadeApoio propriedade;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PropriedadeListItem({
    super.key,
    required this.propriedade,
    required this.onEdit,
    required this.onDelete,
  });

  String _getResumo() {
    final isApoio = propriedade.tipoInteracao == TipoInteracaoPropriedade.APOIO;
    
    if (isApoio) {
      List<String> partes = [];
      if (propriedade.quantidadeMaquinario != null) {
        partes.add("${propriedade.quantidadeMaquinario} Máq.");
      }
      if (propriedade.quantidadeMaoObra != null) {
        partes.add("${propriedade.quantidadeMaoObra} Pessoas");
      }
      if (propriedade.apoioOutro?.isNotEmpty ?? false) {
        partes.add(propriedade.apoioOutro!);
      }
      return partes.isEmpty ? "Sem detalhes" : partes.join(" / ");
    } else {
      return (propriedade.motivoRecusa == TipoMotivoRecusa.OUTRO)
          ? (propriedade.motivoOutro ?? "Outro motivo")
          : (propriedade.motivoRecusa?.descricao ?? "Motivo não informado");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isApoio = propriedade.tipoInteracao == TipoInteracaoPropriedade.APOIO;
    final resumo = _getResumo();

    return Card(
      elevation: 1,
      color: isApoio ? Colors.white : Colors.red[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isApoio ? Colors.grey.shade300 : Colors.red.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isApoio ? Icons.check_circle : Icons.cancel,
                  color: isApoio ? Colors.green[700] : Colors.red[700],
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    propriedade.nomePropriedade ?? 'Sem Nome',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isApoio ? Colors.black87 : Colors.red[900],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onEdit,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onDelete,
                ),
              ],
            ),
            const Divider(height: 16),
            _buildInfoRow(Icons.person, "Proprietário", propriedade.nomeProprietario),
            const SizedBox(height: 4),
            _buildInfoRow(Icons.phone, "Contato", propriedade.contato),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isApoio ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isApoio ? Colors.green.shade200 : Colors.red.shade200,
                ),
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black87, fontSize: 12),
                  children: [
                    TextSpan(
                      text: isApoio ? "RECURSOS: " : "MOTIVO: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isApoio ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                    TextSpan(text: resumo),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[700]),
        const SizedBox(width: 6),
        Text(
          "$label: ",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
            fontSize: 12,
          ),
        ),
        Expanded(
          child: Text(
            value ?? '-',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}