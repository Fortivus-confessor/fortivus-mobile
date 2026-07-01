import 'package:flutter/material.dart';

/// Tokens de cor semânticos do Fortivus que mudam conforme o brilho (claro/escuro).
///
/// Em vez de espalhar `Color(0x...)` pelas telas, cada tela lê `context.fx.surface`,
/// `context.fx.textPrimary`, etc. — e o valor correto para o tema ativo é resolvido
/// automaticamente. As cores de MARCA (laranja/azul/verde/vermelho) são iguais nos
/// dois temas e ficam como constantes em [FortivusBrand].
@immutable
class FortivusColors extends ThemeExtension<FortivusColors> {
  const FortivusColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.cardFill,
    required this.cardBorder,
    required this.inputFill,
    required this.inputBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.chipUnselected,
    required this.chipBorderUnselected,
    required this.shadow,
  });

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color cardFill;
  final Color cardBorder;
  final Color inputFill;
  final Color inputBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color chipUnselected;
  final Color chipBorderUnselected;
  final Color shadow;

  static const dark = FortivusColors(
    background: Color(0xFF0B1220),
    surface: Color(0xFF111A2B),
    surfaceAlt: Color(0xFF1E293B),
    cardFill: Color(0xFF151D2C),
    cardBorder: Color(0xFF2E3A4D),
    inputFill: Color(0xFF1E293B),
    inputBorder: Color(0xFF334155),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    textDisabled: Color(0xFF475569),
    chipUnselected: Color(0xFF1E293B),
    chipBorderUnselected: Color(0xFF334155),
    shadow: Color(0x66000000),
  );

  static const light = FortivusColors(
    background: Color(0xFFF4F6FA),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEEF1F6),
    cardFill: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFE2E8F0),
    inputFill: Color(0xFFF1F5F9),
    inputBorder: Color(0xFFCBD5E1),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF64748B),
    textDisabled: Color(0xFF94A3B8),
    chipUnselected: Color(0xFFEEF1F6),
    chipBorderUnselected: Color(0xFFCBD5E1),
    shadow: Color(0x1F0F172A),
  );

  @override
  FortivusColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? cardFill,
    Color? cardBorder,
    Color? inputFill,
    Color? inputBorder,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? chipUnselected,
    Color? chipBorderUnselected,
    Color? shadow,
  }) {
    return FortivusColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      cardFill: cardFill ?? this.cardFill,
      cardBorder: cardBorder ?? this.cardBorder,
      inputFill: inputFill ?? this.inputFill,
      inputBorder: inputBorder ?? this.inputBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      chipUnselected: chipUnselected ?? this.chipUnselected,
      chipBorderUnselected: chipBorderUnselected ?? this.chipBorderUnselected,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  FortivusColors lerp(ThemeExtension<FortivusColors>? other, double t) {
    if (other is! FortivusColors) return this;
    return FortivusColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      cardFill: Color.lerp(cardFill, other.cardFill, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      chipUnselected: Color.lerp(chipUnselected, other.chipUnselected, t)!,
      chipBorderUnselected: Color.lerp(chipBorderUnselected, other.chipBorderUnselected, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

/// Cores de marca — iguais nos temas claro e escuro.
class FortivusBrand {
  FortivusBrand._();
  static const Color orange = Color(0xFFFF5722); // destaque primário
  static const Color blue = Color(0xFF1E88E5); // ações/informação
  static const Color green = Color(0xFF2E9E5B); // sucesso/sincronizado
  static const Color red = Color(0xFFDC2626); // erro/alerta
  static const Color yellow = Color(0xFFF59E0B); // atenção/pendente
}

/// Acesso conciso aos tokens semânticos: `context.fx.surface`.
extension FortivusThemeAccess on BuildContext {
  FortivusColors get fx =>
      Theme.of(this).extension<FortivusColors>() ?? FortivusColors.dark;
}
