import 'package:flutter/material.dart';

/// Tema centralizado da aplicação Fortivus (Dark Mode Tático)
/// 
/// Contém:
/// - Paleta de cores completa
/// - Widgets reutilizáveis
/// - Decorações padronizadas
/// - ThemeData global
class TacticalTheme {
  // Construtor privado (não pode instanciar)
  TacticalTheme._();

  // ============================================================================
  // CORES PRINCIPAIS (DARK MODE TÁTICO)
  // ============================================================================
  static const Color primary = Color(0xFF0B1220);           // Fundo base ultra-dark
  static const Color secondary = Color(0xFF1E293B);         // Cinza escuro azulado
  static const Color background = Color(0xFF0B1220);        // Fundo principal

  // ============================================================================
  // CORES DE CARDS
  // ============================================================================
  static const Color cardFill = Color(0xFF151D2C);          // Fundo dos cards (um pouco mais claro que o fundo)
  static const Color cardBorder = Color(0xFF2E3A4D);        // Borda dos cards

  // ============================================================================
  // CORES DE INPUTS
  // ============================================================================
  static const Color inputBorder = Color(0xFF334155);       // Borda padrão
  static const Color inputFocused = Color(0xFFFF5722);      // Laranja ao focar
  static const Color inputFill = Color(0xFF1E293B);         // Fundo dos inputs

  // ============================================================================
  // CORES DE ACCENT
  // ============================================================================
  static const Color accentBlue = Color(0xFF1E88E5);        // Azul (ações secundárias)
  static const Color accentGreen = Color(0xFF43A047);       // Verde (sucesso)
  static const Color accentRed = Color(0xFFD32F2F);         // Vermelho tático (erro/alerta grave)
  static const Color accentOrange = Color(0xFFFF5722);      // Laranja tático (destaque primário)
  static const Color accentYellow = Color(0xFFFBC02D);      // Amarelo (atenção)

  // ============================================================================
  // CORES DE CHIPS
  // ============================================================================
  static const Color chipSelected = Color(0x33FF5722);      // Laranja translúcido
  static const Color chipUnselected = Color(0xFF1E293B);    // Cinza escuro
  static const Color chipBorderSelected = accentOrange;
  static const Color chipBorderUnselected = Color(0xFF334155);

  // ============================================================================
  // CORES DE INFORMAÇÃO
  // ============================================================================
  static const Color infoBackground = Color(0x331E88E5);    
  static const Color infoBorder = accentBlue;        
  static const Color infoIcon = accentBlue;          

  // ============================================================================
  // CORES DE AVISO
  // ============================================================================
  static const Color warningBackground = Color(0x33FF5722); 
  static const Color warningBorder = accentOrange;     
  static const Color warningIcon = accentOrange;       

  // ============================================================================
  // CORES DE TEXTO
  // ============================================================================
  static const Color textPrimary = Color(0xFFF8FAFC);       // Branco quase puro
  static const Color textSecondary = Color(0xFF94A3B8);     // Cinza médio claro
  static const Color textDisabled = Color(0xFF475569);      // Cinza escuro

  // ============================================================================
  // THEME DATA GLOBAL
  // ============================================================================
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: accentOrange,
          secondary: accentRed,
          surface: cardFill,
          error: accentRed,
          background: background,
        ),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: textPrimary,
          elevation: 2,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          iconTheme: IconThemeData(color: accentOrange),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentOrange,
            foregroundColor: textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            elevation: 4,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: inputFill,
          labelStyle: const TextStyle(color: textSecondary),
          hintStyle: const TextStyle(color: textDisabled),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: inputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: inputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: inputFocused, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: accentRed),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
        cardTheme: CardThemeData(
          color: cardFill,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: cardBorder, width: 1),
          ),
          margin: const EdgeInsets.only(bottom: 16),
        ),
        dividerTheme: const DividerThemeData(
          color: cardBorder,
          thickness: 1.5,
        ),
      );

  // ============================================================================
  // WIDGETS REUTILIZÁVEIS
  // ============================================================================

  /// Card tático padrão com título e ícone
  static Widget buildCard({
    required String title,
    required IconData icon,
    required Widget child,
    Color? iconColor,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: cardBorder, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      color: cardFill,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              children: [
                Icon(
                  icon,
                  color: iconColor ?? accentOrange,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1.5, color: cardBorder),
            // Conteúdo
            child,
          ],
        ),
      ),
    );
  }

  /// Decoração padrão para inputs
  static InputDecoration buildInputDecoration(
    String label,
    IconData icon, {
    String? helperText,
    String? hintText,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      helperMaxLines: 2,
      prefixIcon: Icon(icon, size: 20, color: textSecondary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: inputFill,
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: const TextStyle(color: textDisabled),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: inputFocused, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: accentRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: accentRed, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
    );
  }

  /// Container de aviso laranja
  static Widget buildWarningBox(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: warningBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: warningBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: warningIcon, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Container de informação azul
  static Widget buildInfoBox(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: infoBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: infoBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: infoIcon, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Chip padrão estilizado
  static FilterChip buildChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? textPrimary : textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: chipSelected,
      backgroundColor: chipUnselected,
      checkmarkColor: accentOrange,
      side: BorderSide(
        color: isSelected ? chipBorderSelected : chipBorderUnselected,
        width: isSelected ? 2 : 1,
      ),
      onSelected: onSelected,
    );
  }

  /// Botão primário padrão
  static Widget buildPrimaryButton({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    double? width,
    double height = 56,
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textPrimary,
                ),
              )
            : Icon(icon ?? Icons.check_circle, size: 22, color: textPrimary),
        label: Text(
          isLoading ? 'PROCESSANDO...' : label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading ? inputBorder : accentOrange,
          foregroundColor: textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isLoading ? 0 : 4,
        ),
      ),
    );
  }

  /// AppBar padrão
  static AppBar buildAppBar({
    required String title,
    List<Widget>? actions,
    bool isLoading = false,
  }) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),
      backgroundColor: primary,
      foregroundColor: textPrimary,
      elevation: 2,
      actions: actions,
      leading: isLoading
          ? const Padding(
              padding: EdgeInsets.all(14),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: accentOrange,
              ),
            )
          : null,
    );
  }

  /// Loading overlay para tela inteira
  static Widget buildLoadingOverlay({String? message}) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Card(
          color: cardFill,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: accentOrange),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Empty state widget
  static Widget buildEmptyState({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 80,
              color: textDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action,
            ],
          ],
        ),
      ),
    );
  }

  /// Snackbar de sucesso
  static SnackBar buildSuccessSnackBar(String message) {
    return SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: textPrimary),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(color: textPrimary))),
        ],
      ),
      backgroundColor: accentGreen,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    );
  }

  /// Snackbar de erro
  static SnackBar buildErrorSnackBar(String message) {
    return SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error, color: textPrimary),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(color: textPrimary))),
        ],
      ),
      backgroundColor: accentRed,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
      action: SnackBarAction(
        label: 'OK',
        textColor: textPrimary,
        onPressed: () {},
      ),
    );
  }

  /// Snackbar de aviso
  static SnackBar buildWarningSnackBar(String message) {
    return SnackBar(
      content: Row(
        children: [
          const Icon(Icons.warning_amber, color: textPrimary),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(color: textPrimary))),
        ],
      ),
      backgroundColor: accentOrange,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    );
  }

  /// Snackbar de informação
  static SnackBar buildInfoSnackBar(String message) {
    return SnackBar(
      content: Row(
        children: [
          const Icon(Icons.info_outline, color: textPrimary),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(color: textPrimary))),
        ],
      ),
      backgroundColor: accentBlue,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    );
  }
}