import 'package:flutter/material.dart';

/// Classe centralitzada amb tots els colors de l'app adaptats al tema.
/// Ús: `final colors = AppColors.of(context);`
class AppColors {
  final bool isDark;

  AppColors._({required this.isDark});

  /// Crea una instància basada en el tema actual del context.
  factory AppColors.of(BuildContext context) {
    return AppColors._(isDark: Theme.of(context).brightness == Brightness.dark);
  }

  // ─── Backgrounds ──────────────────────────────────────────────────────

  /// Fons principal del Scaffold
  Color get background =>
      isDark ? const Color(0xFF0D1117) : const Color(0xFFF5F6FA);

  /// Fons de l'AppBar / BottomNav
  Color get surface => isDark ? const Color(0xFF161B22) : Colors.white;

  /// Fons de cards / contenidors elevats
  Color get card => isDark ? const Color(0xFF161B22) : Colors.white;

  /// Fons de diàlegs
  Color get dialog => isDark ? const Color(0xFF1C2128) : Colors.white;

  /// Fons de camps d'input / cerca
  Color get inputFill => isDark ? const Color(0xFF161B22) : Colors.white;

  /// Fons de camps d'input dins diàlegs
  Color get inputFillAlt =>
      isDark ? const Color(0xFF0D1117) : const Color(0xFFF0F0F5);

  /// Fons de la barra d'accions
  Color get actionBar =>
      isDark ? const Color(0xFF0D1117) : const Color(0xFFF0F0F5);

  /// Fons per a placeholders d'error d'imatge
  Color get errorPlaceholder =>
      isDark ? const Color(0xFF1C2128) : const Color(0xFFEEEEEE);

  /// Fons d'imatge buida
  Color get imagePlaceholder =>
      isDark ? const Color(0xFF0D1117) : const Color(0xFFE0E0E0);

  // ─── Text ─────────────────────────────────────────────────────────────

  /// Text principal (títols, noms)
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF1A1A2E);

  /// Text secundari (subtítols, descripcions)
  Color get textSecondary => isDark ? Colors.white54 : const Color(0xFF757575);

  /// Text de labels de formulari
  Color get textLabel => isDark ? Colors.white70 : const Color(0xFF424242);

  /// Text de hints / placeholders
  Color get textHint => isDark ? Colors.white30 : const Color(0xFFBDBDBD);

  /// Text molt suau (tercer nivell)
  Color get textMuted => isDark ? Colors.white30 : const Color(0xFF9E9E9E);

  // ─── Icons ────────────────────────────────────────────────────────────

  /// Icones principals
  Color get icon => isDark ? Colors.white : Colors.black87;

  /// Icones secundàries / inactives
  Color get iconSecondary => isDark ? Colors.white38 : const Color(0xFF757575);

  // ─── Borders / Dividers ───────────────────────────────────────────────

  /// Vora suau per a cards i contenidors
  Color get border =>
      isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(13);

  /// Vora per a inputs
  Color get inputBorder =>
      isDark ? Colors.white.withAlpha(20) : const Color(0xFFE0E0E0);

  /// Vora per a cerca
  Color get searchBorder =>
      isDark ? Colors.white.withAlpha(15) : Colors.grey.withAlpha(51);

  /// Divisor dins de barres d'accions
  Color get divider =>
      isDark ? Colors.white.withAlpha(15) : Colors.grey.withAlpha(38);

  // ─── Shadows ──────────────────────────────────────────────────────────

  /// Ombra de cards
  Color get cardShadow =>
      isDark ? Colors.black.withAlpha(51) : Colors.black.withAlpha(18);

  /// Ombra suau
  Color get shadowLight =>
      isDark ? Colors.black.withAlpha(38) : Colors.black.withAlpha(13);

  // ─── Accent Colors ────────────────────────────────────────────────────

  /// Color de preu / accent blau
  Color get accentBlue =>
      isDark ? const Color(0xFF42A5F5) : const Color(0xFF0077C8);

  /// Color seleccionat en nav bar
  Color get navSelected =>
      isDark ? const Color(0xFF42A5F5) : const Color(0xFF1565C0);

  /// Color no seleccionat en nav bar
  Color get navUnselected => isDark ? Colors.white38 : const Color(0xFF757575);

  /// Botó cancel·lar en diàlegs
  Color get cancelButton => isDark ? Colors.white38 : Colors.grey;
}
