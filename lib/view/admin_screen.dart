import 'package:decathdam/config/app_theme.dart';
import 'package:decathdam/view/creation_product_screen.dart';
import 'package:decathdam/view/manage_products_screen.dart';
import 'package:decathdam/view/manage_users_screen.dart';
import 'package:decathdam/view/widgets/animated_admin_option.dart';
import 'package:decathdam/view/widgets/dashboard_card.dart';
import 'package:decathdam/view/widgets/logout_button.dart';
import 'package:decathdam/view/widgets/settings_theme_card.dart';
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

              AnimatedAdminOption(
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

              AnimatedAdminOption(
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

              AnimatedAdminOption(
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

              SettingsThemeCard(themeProvider: themeProvider, colors: colors),

              const SizedBox(height: 12),

              AnimatedAdminOption(
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

              AnimatedAdminOption(
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

              LogoutButton(
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
              return DashboardCard(
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
              return DashboardCard(
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
