import 'package:flutter/material.dart';

/// Utilitário para padronização de Dropdowns no app FORTIVUS.
/// Implementa quebra de linha automática e divisórias entre as opções.
class DropdownUtil {
  
  /// Constrói os itens do menu com quebra de linha e divisória preta.
  /// Use em conjunto com [itemHeight: null] no DropdownButton.
  static List<DropdownMenuItem<T>> buildItems<T>(
    List<T> items,
    String Function(T) getLabel,
  ) {
    return items.map((e) {
      final label = getLabel(e);
      return DropdownMenuItem<T>(
        value: e,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                maxLines: null,
                overflow: TextOverflow.visible,
              ),
            ),
            const Divider(
              color: Colors.black,
              height: 1,
              thickness: 1,
            ),
          ],
        ),
      );
    }).toList();
  }

  /// Constrói a exibição do item selecionado (quando o dropdown está fechado).
  /// Remove a divisória e aplica reticências se o texto for muito longo.
  static List<Widget> buildSelectedItems<T>(
    List<T> items,
    String Function(T) getLabel,
  ) {
    return items.map((e) {
      return Container(
        alignment: Alignment.centerLeft,
        child: Text(
          getLabel(e),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList();
  }
}
