import 'package:flutter/material.dart';

/// Mostra dialog para seleção de data e hora
Future<DateTime?> showDateTimePickerDialog({
  required BuildContext context,
  DateTime? initialDateTime,
}) async {
  // Seleciona data
  final date = await showDatePicker(
    context: context,
    initialDate: initialDateTime ?? DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime(2100),
    helpText: 'Selecione a data',
    cancelText: 'Cancelar',
    confirmText: 'Avançar',
  );

  if (date == null) return null;

  if (!context.mounted) return null;

  // Seleciona hora
  final time = await showTimePicker(
    context: context,
    initialTime: initialDateTime != null
        ? TimeOfDay.fromDateTime(initialDateTime)
        : TimeOfDay.now(),
    helpText: 'Selecione o horário',
    cancelText: 'Cancelar',
    confirmText: 'Confirmar',
  );

  if (time == null) return null;

  // Combina data + hora
  return DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
}