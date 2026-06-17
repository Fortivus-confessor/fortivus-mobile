import 'package:flutter/material.dart';

class ChipField<T extends Enum> extends StatelessWidget {
  final String label;
  final List<T> options;
  final Set<T> selectedValues;
  final ValueChanged<Set<T>> onChanged;
  final bool required;
  final T? exclusiveValue;

  const ChipField({
    super.key,
    required this.label,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
    this.required = false,
    this.exclusiveValue,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<Set<T>>(
      initialValue: selectedValues,
      validator: (value) {
        if (required && (value == null || value.isEmpty)) {
          return 'Selecione ao menos uma opção';
        }
        return null;
      },
      builder: (state) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: label + (required ? ' *' : ''),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.all(12),
            errorText: state.errorText,
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: options.map((option) {
              final isSelected = selectedValues.contains(option);
              String descricao = option.name;
              try {
                descricao = (option as dynamic).descricao;
              } catch (_) {}

              return FilterChip(
                label: Text(descricao, style: const TextStyle(fontSize: 12)),
                selected: isSelected,
                selectedColor: Colors.blue.shade100,
                onSelected: (selected) {
                  Set<T> newSelection = Set.from(selectedValues);

                  if (exclusiveValue != null && option == exclusiveValue) {
                    if (selected) {
                      newSelection = {option};
                    } else {
                      newSelection.remove(option);
                    }
                  } else {
                    if (exclusiveValue != null) {
                      newSelection.remove(exclusiveValue);
                    }
                    if (selected) {
                      newSelection.add(option);
                    } else {
                      newSelection.remove(option);
                    }
                  }

                  onChanged(newSelection);
                  state.didChange(newSelection);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}