import 'package:decathdam/config/app_theme.dart';
import 'package:decathdam/viewmodels/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsThemeCard extends StatefulWidget {
  final ThemeProvider themeProvider;
  final AppColors colors;

  const SettingsThemeCard({
    super.key,
    required this.themeProvider,
    required this.colors,
  });

  @override
  State<SettingsThemeCard> createState() => _SettingsThemeCardState();
}

class _SettingsThemeCardState extends State<SettingsThemeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final currentMode = widget.themeProvider.themeMode;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: colors.cardShadow,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9800), Color(0xFFFFC107)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.palette_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aparença',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Canvia entre mode clar, fosc o sistema',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.actionBar,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _ThemeChip(
                      icon: Icons.light_mode_rounded,
                      label: 'Clar',
                      isSelected: currentMode == ThemeMode.light,
                      colors: colors,
                      onTap: () =>
                          widget.themeProvider.setThemeMode(ThemeMode.light),
                    ),
                    const SizedBox(width: 4),
                    _ThemeChip(
                      icon: Icons.dark_mode_rounded,
                      label: 'Fosc',
                      isSelected: currentMode == ThemeMode.dark,
                      colors: colors,
                      onTap: () =>
                          widget.themeProvider.setThemeMode(ThemeMode.dark),
                    ),
                    const SizedBox(width: 4),
                    _ThemeChip(
                      icon: Icons.settings_suggest_rounded,
                      label: 'Sistema',
                      isSelected: currentMode == ThemeMode.system,
                      colors: colors,
                      onTap: () =>
                          widget.themeProvider.setThemeMode(ThemeMode.system),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Theme Chip (privat dins d'aquest fitxer) ────────────────────────────────

class _ThemeChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final AppColors colors;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.colors,
    required this.onTap,
  });

  @override
  State<_ThemeChip> createState() => _ThemeChipState();
}

class _ThemeChipState extends State<_ThemeChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final selectedBg = widget.colors.navSelected;
    const unselectedBg = Colors.transparent;
    const selectedText = Colors.white;
    final unselectedText = widget.colors.textSecondary;

    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.93 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: widget.isSelected ? selectedBg : unselectedBg,
              borderRadius: BorderRadius.circular(10),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: selectedBg.withAlpha(77),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: 16,
                  color: widget.isSelected ? selectedText : unselectedText,
                ),
                const SizedBox(width: 5),
                Text(
                  widget.label,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: widget.isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: widget.isSelected ? selectedText : unselectedText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
