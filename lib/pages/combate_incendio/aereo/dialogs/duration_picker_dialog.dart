import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortivus_app/theme/tactical_theme.dart';
import 'package:fortivus_app/theme/fortivus_colors.dart';

/// Dialog para seleção de duração (horas e minutos)
/// 
/// Retorna Duration ou null se cancelado
Future<Duration?> showDurationPickerDialog({
  required BuildContext context,
  Duration? initialDuration,
}) async {
  final horasController = TextEditingController(
    text: initialDuration != null ? initialDuration.inHours.toString() : '',
  );
  final minutosController = TextEditingController(
    text: initialDuration != null
        ? (initialDuration.inMinutes % 60).toString()
        : '',
  );

  final formKey = GlobalKey<FormState>();

  return showDialog<Duration>(
    context: context,
    // Impede fechar ao tocar fora para evitar perda de dados em campo
    barrierDismissible: false, 
    builder: (BuildContext ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.timelapse,
              color: TacticalTheme.accentOrange,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Tempo de Operação',
              style: TextStyle(
                color: ctx.fx.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SizedBox(
          // Garante que o diálogo tenha uma largura consistente
          width: MediaQuery.of(context).size.width * 0.9,
          child: SingleChildScrollView( // <--- CORREÇÃO DO BOTTOM OVERFLOW
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Descrição
                  Text(
                    'Informe o tempo total da operação',
                    style: TextStyle(
                      fontSize: 14,
                      color: ctx.fx.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Campos de horas e minutos
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // Mantém alinhado se houver erro
                    children: [
                      // Horas
                      Expanded(
                        child: TextFormField(
                          controller: horasController,
                          decoration: InputDecoration(
                            labelText: 'Horas',
                            hintText: '0',
                            prefixIcon: const Icon(
                              Icons.access_time,
                              size: 20,
                              color: TacticalTheme.accentOrange,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 12,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Obrigatório';
                            final valor = int.tryParse(v);
                            if (valor == null || valor < 0) return 'Inválido';
                            return null;
                          },
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Text(
                          ':',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: TacticalTheme.accentOrange,
                          ),
                        ),
                      ),

                      // Minutos
                      Expanded(
                        child: TextFormField(
                          controller: minutosController,
                          decoration: InputDecoration(
                            labelText: 'Minutos',
                            hintText: '0',
                            prefixIcon: const Icon(
                              Icons.timer,
                              size: 20,
                              color: TacticalTheme.accentOrange,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 12,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Obrigatório';
                            final valor = int.tryParse(v);
                            if (valor == null || valor < 0 || valor >= 60) {
                              return '0-59';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Info box - Agora protegido pelo SingleChildScrollView
                  TacticalTheme.buildInfoBox(
                    'Informe o tempo total que a aeronave esteve em operação',
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          // Botão cancelar
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'CANCELAR',
              style: TextStyle(color: Colors.grey),
            ),
          ),

          // Botão confirmar
          ElevatedButton.icon(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final horas = int.parse(horasController.text);
                final minutos = int.parse(minutosController.text);
                final duracao = Duration(hours: horas, minutes: minutos);
                Navigator.pop(ctx, duracao);
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('CONFIRMAR'),
          ),
        ],
      );
    },
  );
}