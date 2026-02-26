import 'package:decathdam/config/app_theme.dart';
import 'package:decathdam/view/creation_product_screen.dart';
import 'package:decathdam/view/manage_products_screen.dart';
import 'package:decathdam/view/manage_users_screen.dart';
import 'package:decathdam/viewmodels/products_viewmodel.dart';
import 'package:decathdam/viewmodels/theme_provider.dart';
import 'package:decathdam/viewmodels/users_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsViewModel = Provider.of<ProductsViewModel>(context);
    final usersViewModel = Provider.of<UsersViewModel>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Panell d\'Administració',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Gestiona productes i usuaris',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),

              // Dashboard Grid
              _buildDashboardGrid(productsViewModel, usersViewModel),

              const SizedBox(height: 32),

              // Section: Gestió ràpida
              _buildSectionTitle('Gestió ràpida', colors),
              const SizedBox(height: 16),

              _AnimatedAdminOption(
                icon: Icons.add_box_rounded,
                title: 'Crear Productes',
                subtitle: 'Afegeix nous productes al catàleg',
                gradientColors: const [Color(0xFF00C853), Color(0xFF00E676)],
                delay: 0,
                colors: colors,
                onTap: () {
                  Navigator.push(
                    context,
                    _createRoute(const CreationProductScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              _AnimatedAdminOption(
                icon: Icons.inventory_2_rounded,
                title: 'Administrar Productes',
                subtitle: 'Edita o elimina productes existents',
                gradientColors: const [Color(0xFF2196F3), Color(0xFF42A5F5)],
                delay: 100,
                colors: colors,
                onTap: () {
                  Navigator.push(
                    context,
                    _createRoute(const ManageProductsScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              _AnimatedAdminOption(
                icon: Icons.people_rounded,
                title: 'Administrar Usuaris',
                subtitle: 'Gestiona rols i permisos dels usuaris',
                gradientColors: const [Color(0xFFFF6D00), Color(0xFFFF9100)],
                delay: 200,
                colors: colors,
                onTap: () {
                  Navigator.push(
                    context,
                    _createRoute(const ManageUsersScreen()),
                  );
                },
              ),

              const SizedBox(height: 36),

              // Section: Ajustes
              _buildSectionTitle('Ajustes', colors),
              const SizedBox(height: 16),

              // Theme toggle card
              _SettingsThemeCard(themeProvider: themeProvider, colors: colors),

              const SizedBox(height: 12),

              // Language option (placeholder)
              _AnimatedAdminOption(
                icon: Icons.language_rounded,
                title: 'Idioma',
                subtitle: 'Català',
                gradientColors: const [Color(0xFF7C4DFF), Color(0xFFB388FF)],
                delay: 300,
                colors: colors,
                onTap: () {
                  _showInfoSnackBar(
                    context,
                    colors,
                    'Funció d\'idioma pròximament',
                  );
                },
              ),

              const SizedBox(height: 12),

              // Notifications option (placeholder)
              _AnimatedAdminOption(
                icon: Icons.notifications_rounded,
                title: 'Notificacions',
                subtitle: 'Gestiona les alertes de l\'app',
                gradientColors: const [Color(0xFF00BCD4), Color(0xFF4DD0E1)],
                delay: 400,
                colors: colors,
                onTap: () {
                  _showInfoSnackBar(
                    context,
                    colors,
                    'Notificacions pròximament',
                  );
                },
              ),

              const SizedBox(height: 28),

              // Logout button
              _LogoutButton(
                colors: colors,
                onTap: () {
                  _showLogoutDialog(context, colors);
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, AppColors colors) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
    );
  }

  Widget _buildDashboardGrid(
    ProductsViewModel productsVM,
    UsersViewModel usersVM,
  ) {
    return Row(
      children: [
        Expanded(
          child: FutureBuilder<int>(
            future: productsVM.getProductsCount(),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return _DashboardCard(
                icon: Icons.inventory_2_rounded,
                label: 'Productes',
                value: '$count',
                gradientColors: const [Color(0xFF1E88E5), Color(0xFF42A5F5)],
              );
            },
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: FutureBuilder<int>(
            future: usersVM.getUsersCount(),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return _DashboardCard(
                icon: Icons.people_rounded,
                label: 'Usuaris',
                value: '$count',
                gradientColors: const [Color(0xFFE65100), Color(0xFFFF6D00)],
              );
            },
          ),
        ),
      ],
    );
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  void _showInfoSnackBar(
    BuildContext context,
    AppColors colors,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: colors.dialog,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppColors colors) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.dialog,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Tancar sessió',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          content: Text(
            'Estàs segur que vols tancar la sessió? Hauràs d\'iniciar sessió de nou per accedir.',
            style: GoogleFonts.outfit(
              color: colors.textSecondary,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel·lar',
                style: GoogleFonts.outfit(color: colors.cancelButton),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _showInfoSnackBar(
                  context,
                  colors,
                  'Funció de logout pròximament',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Tancar sessió',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Dashboard Card ──────────────────────────────────────────────────────────

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradientColors;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withAlpha(77),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.white.withAlpha(204),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Settings Theme Card ─────────────────────────────────────────────────────

class _SettingsThemeCard extends StatefulWidget {
  final ThemeProvider themeProvider;
  final AppColors colors;

  const _SettingsThemeCard({required this.themeProvider, required this.colors});

  @override
  State<_SettingsThemeCard> createState() => _SettingsThemeCardState();
}

class _SettingsThemeCardState extends State<_SettingsThemeCard>
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
              // Theme selector chips
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

// ─── Theme Chip ──────────────────────────────────────────────────────────────

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

// ─── Logout Button ───────────────────────────────────────────────────────────

class _LogoutButton extends StatefulWidget {
  final AppColors colors;
  final VoidCallback onTap;

  const _LogoutButton({required this.colors, required this.onTap});

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 500), () {
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
    final borderCol = widget.colors.isDark
        ? Colors.red.withAlpha(64)
        : Colors.red.withAlpha(51);
    final bgCol = widget.colors.isDark
        ? Colors.red.withAlpha(13)
        : Colors.red.withAlpha(10);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: bgCol,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderCol, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Tancar sessió',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
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

// ─── Admin Option with Animation ─────────────────────────────────────────────

class _AnimatedAdminOption extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final int delay;
  final VoidCallback onTap;
  final AppColors colors;

  const _AnimatedAdminOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.delay,
    required this.onTap,
    required this.colors,
  });

  @override
  State<_AnimatedAdminOption> createState() => _AnimatedAdminOptionState();
}

class _AnimatedAdminOptionState extends State<_AnimatedAdminOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;

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

    Future.delayed(Duration(milliseconds: widget.delay), () {
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

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: widget.gradientColors),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.subtitle,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
