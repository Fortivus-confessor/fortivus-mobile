import 'package:flutter/material.dart';
import 'fortivus_colors.dart';

/// Temas Material 3 claro e escuro do Fortivus.
///
/// Toda a estilização de componentes padrão (AppBar, Card, TextField, botões,
/// chips, etc.) é definida aqui para os dois brilhos, de modo que qualquer tela
/// que use widgets Material padrão se adapta automaticamente ao tema ativo.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light, FortivusColors.light);
  static ThemeData get dark => _build(Brightness.dark, FortivusColors.dark);

  static ThemeData _build(Brightness brightness, FortivusColors fx) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: FortivusBrand.orange,
      brightness: brightness,
    ).copyWith(
      primary: FortivusBrand.orange,
      surface: fx.surface,
      error: FortivusBrand.red,
    );

    final base = ThemeData(brightness: brightness, useMaterial3: true);

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: fx.background,
      extensions: [fx],
      textTheme: base.textTheme.apply(
        bodyColor: fx.textPrimary,
        displayColor: fx.textPrimary,
      ),
      iconTheme: IconThemeData(color: fx.textSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: fx.surface,
        foregroundColor: fx.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: fx.textPrimary,
        ),
        iconTheme: IconThemeData(color: fx.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: fx.cardFill,
        surfaceTintColor: Colors.transparent,
        elevation: isDark ? 0 : 1,
        shadowColor: fx.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: fx.cardBorder, width: 1),
        ),
        margin: const EdgeInsets.only(bottom: 16),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fx.inputFill,
        labelStyle: TextStyle(color: fx.textSecondary),
        hintStyle: TextStyle(color: fx.textDisabled),
        prefixIconColor: fx.textSecondary,
        suffixIconColor: fx.textSecondary,
        helperMaxLines: 2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: fx.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: fx.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FortivusBrand.orange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FortivusBrand.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FortivusBrand.red, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FortivusBrand.orange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: fx.inputBorder,
          disabledForegroundColor: fx.textDisabled,
          minimumSize: const Size(72, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: FortivusBrand.orange,
          foregroundColor: Colors.white,
          minimumSize: const Size(72, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: fx.textPrimary,
          side: BorderSide(color: fx.inputBorder),
          minimumSize: const Size(72, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: FortivusBrand.orange),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: fx.chipUnselected,
        selectedColor: FortivusBrand.orange.withValues(alpha: 0.20),
        checkmarkColor: FortivusBrand.orange,
        labelStyle: TextStyle(color: fx.textSecondary),
        secondaryLabelStyle: TextStyle(color: fx.textPrimary),
        side: BorderSide(color: fx.chipBorderUnselected),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      dividerTheme: DividerThemeData(color: fx.cardBorder, thickness: 1),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? FortivusBrand.orange : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? FortivusBrand.orange.withValues(alpha: 0.4)
              : null,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: fx.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: fx.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: FortivusBrand.orange),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: FortivusBrand.orange,
        foregroundColor: Colors.white,
      ),
    );
  }
}
