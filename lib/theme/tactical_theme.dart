import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'fortivus_colors.dart';

/// Fachada de compatibilidade + construtores de UI reutilizáveis do Fortivus.
///
/// As cores de MARCA (accent*) são constantes. Os construtores estáticos
/// (`buildCard`, `buildInputDecoration`, etc.) agora são theme-aware: leem as
/// cores do tema ativo em tempo de build (via `Builder`/`context`), então se
/// adaptam automaticamente a claro/escuro sem precisar de contexto no call site.
///
/// `primary`/`background` permanecem como constantes (paleta escura) apenas para
/// call sites legados ainda não migrados; código novo deve usar `context.fx.*`.
class TacticalTheme {
  TacticalTheme._();

  // ── Cores de marca (iguais nos dois temas) ──────────────────────────────────
  static const Color accentBlue = FortivusBrand.blue;
  static const Color accentGreen = FortivusBrand.green;
  static const Color accentRed = FortivusBrand.red;
  static const Color accentOrange = FortivusBrand.orange;
  static const Color accentYellow = FortivusBrand.yellow;

  // ── Compat legada (paleta escura) ───────────────────────────────────────────
  static const Color primary = Color(0xFF0B1220);
  static const Color background = Color(0xFF0B1220);
  static const Color cardFill = Color(0xFF151D2C);
  static const Color cardBorder = Color(0xFF2E3A4D);
  static const Color inputFill = Color(0xFF1E293B);
  static const Color inputBorder = Color(0xFF334155);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFF475569);

  // ── ThemeData (delegado ao AppTheme) ────────────────────────────────────────
  static ThemeData get darkTheme => AppTheme.dark;
  static ThemeData get lightTheme => AppTheme.light;

  // ── WIDGETS REUTILIZÁVEIS (theme-aware) ─────────────────────────────────────

  /// Card padrão com título e ícone. Adapta cores ao tema ativo.
  static Widget buildCard({
    required String title,
    required IconData icon,
    required Widget child,
    Color? iconColor,
  }) {
    return Builder(
      builder: (context) {
        final fx = context.fx;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: iconColor ?? FortivusBrand.orange, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: fx.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(height: 24, thickness: 1, color: fx.cardBorder),
                child,
              ],
            ),
          ),
        );
      },
    );
  }

  /// Decoração de input. Sem cores hardcoded — herda do inputDecorationTheme
  /// ativo (claro ou escuro).
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
      prefixIcon: Icon(icon, size: 20),
      suffixIcon: suffixIcon,
    );
  }

  /// Caixa de aviso (laranja).
  static Widget buildWarningBox(String message) {
    return _NoticeBox(
      message: message,
      color: FortivusBrand.orange,
      icon: Icons.warning_amber,
    );
  }

  /// Caixa de informação (azul).
  static Widget buildInfoBox(String message) {
    return _NoticeBox(
      message: message,
      color: FortivusBrand.blue,
      icon: Icons.info_outline,
    );
  }

  /// Chip padrão.
  static Widget buildChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return Builder(builder: (context) {
      final fx = context.fx;
      return FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? FortivusBrand.orange : fx.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedColor: FortivusBrand.orange.withValues(alpha: 0.18),
        backgroundColor: fx.chipUnselected,
        checkmarkColor: FortivusBrand.orange,
        side: BorderSide(
          color: isSelected ? FortivusBrand.orange : fx.chipBorderUnselected,
          width: isSelected ? 1.5 : 1,
        ),
        onSelected: onSelected,
      );
    });
  }

  /// Botão primário de largura total.
  static Widget buildPrimaryButton({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    double? width,
    double height = 54,
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
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Icon(icon ?? Icons.check_circle, size: 22, color: Colors.white),
        label: Text(
          isLoading ? 'PROCESSANDO...' : label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  /// AppBar padrão (adapta ao tema via AppBarTheme).
  static AppBar buildAppBar({
    required String title,
    List<Widget>? actions,
    bool isLoading = false,
  }) {
    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      actions: actions,
      leading: isLoading
          ? const Padding(
              padding: EdgeInsets.all(14),
              child: CircularProgressIndicator(strokeWidth: 2, color: FortivusBrand.orange),
            )
          : null,
    );
  }

  /// Overlay de carregamento em tela cheia.
  static Widget buildLoadingOverlay({String? message}) {
    return Builder(builder: (context) {
      return Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: FortivusBrand.orange),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(message,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: context.fx.textPrimary)),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  /// Estado vazio.
  static Widget buildEmptyState({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? action,
  }) {
    return Builder(builder: (context) {
      final fx = context.fx;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 72, color: fx.textDisabled),
              const SizedBox(height: 16),
              Text(title,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: fx.textPrimary),
                  textAlign: TextAlign.center),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(subtitle,
                    style: TextStyle(fontSize: 14, color: fx.textSecondary),
                    textAlign: TextAlign.center),
              ],
              if (action != null) ...[const SizedBox(height: 24), action],
            ],
          ),
        ),
      );
    });
  }

  // ── Snackbars ───────────────────────────────────────────────────────────────
  static SnackBar buildSuccessSnackBar(String message) =>
      _snack(message, FortivusBrand.green, Icons.check_circle);
  static SnackBar buildErrorSnackBar(String message) => _snack(
        message,
        FortivusBrand.red,
        Icons.error,
        action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
        seconds: 4,
      );
  static SnackBar buildWarningSnackBar(String message) =>
      _snack(message, FortivusBrand.orange, Icons.warning_amber);
  static SnackBar buildInfoSnackBar(String message) =>
      _snack(message, FortivusBrand.blue, Icons.info_outline);

  static SnackBar _snack(String message, Color color, IconData icon,
      {SnackBarAction? action, int seconds = 3}) {
    return SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: seconds),
      action: action,
    );
  }
}

class _NoticeBox extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;
  const _NoticeBox({required this.message, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: TextStyle(fontSize: 12.5, color: context.fx.textPrimary)),
          ),
        ],
      ),
    );
  }
}
