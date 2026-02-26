import 'package:decathdam/config/app_theme.dart';
import 'package:decathdam/view/creation_product_screen.dart';
import 'package:decathdam/view/manage_products_screen.dart';
import 'package:decathdam/view/manage_users_screen.dart';
import 'package:decathdam/view/settings_screen.dart';
import 'package:decathdam/view/widgets/animated_admin_option.dart';
import 'package:decathdam/view/widgets/dashboard_card.dart';
import 'package:decathdam/viewmodels/products_viewmodel.dart';
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
              // Header amb icona d'ajustes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                      ],
                    ),
                  ),
                  // Icona d'ajustes
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        _createRoute(const SettingsScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.border, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: colors.cardShadow,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.settings_rounded,
                        color: colors.textSecondary,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Dashboard Grid
              _buildDashboardGrid(productsViewModel, usersViewModel),

              const SizedBox(height: 32),

              // Section: Gestió ràpida
              Text(
                'Gestió ràpida',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
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

              const SizedBox(height: 24),
            ],
          ),
        ),
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
}
