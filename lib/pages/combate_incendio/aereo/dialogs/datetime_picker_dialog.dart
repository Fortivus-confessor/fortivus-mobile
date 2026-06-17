import 'package:flutter/material.dart';

/// Dialog para seleção de data e hora
/// 
/// Retorna DateTime ou null se cancelado
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
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Theme.of(context).primaryColor,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      );
    },
  );

  if (date == null) return null;

  // Seleciona hora
  if (!context.mounted) return null;

  final time = await showTimePicker(
    context: context,
    initialTime: initialDateTime != null
        ? TimeOfDay.fromDateTime(initialDateTime)
        : TimeOfDay.now(),
    helpText: 'Selecione o horário',
    cancelText: 'Cancelar',
    confirmText: 'Confirmar',
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Theme.of(context).primaryColor,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      );
    },
  );

  if (time == null) return null;

  // Combina data e hora
  return DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
}