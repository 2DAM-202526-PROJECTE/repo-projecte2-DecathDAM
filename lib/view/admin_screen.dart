import 'package:decathdam/config/app_theme.dart';
import 'package:decathdam/view/creation_product_screen.dart';
import 'package:decathdam/view/creation_user_screen.dart';
import 'package:decathdam/view/manage_products_screen.dart';
import 'package:decathdam/view/manage_users_screen.dart';
import 'package:decathdam/view/manage_featured_screen.dart';
import 'package:decathdam/view/settings_screen.dart';
import 'package:decathdam/view/widgets/animated_admin_option.dart';
import 'package:decathdam/view/widgets/dashboard_card.dart';
import 'package:decathdam/viewmodels/products_viewmodel.dart';
import 'package:decathdam/viewmodels/users_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:decathdam/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

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
                          l10n.adminPanel,
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.manageProductsUsers,
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
              _buildDashboardGrid(productsViewModel, usersViewModel, l10n),

              const SizedBox(height: 32),

              // Section: Gestió ràpida
              Text(
                l10n.quickManagement,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              AnimatedAdminOption(
                icon: Icons.add_box_rounded,
                title: l10n.createProducts,
                subtitle: l10n.addProductsCatalog,
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
                title: l10n.manageProducts,
                subtitle: l10n.editDeleteProducts,
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
                icon: Icons.star_rounded,
                title: l10n.featuredProducts,
                subtitle: l10n.chooseFeatured,
                gradientColors: const [Color(0xFFFFB300), Color(0xFFFFCA28)],
                delay: 125,
                colors: colors,
                onTap: () {
                  Navigator.push(
                    context,
                    _createRoute(const ManageFeaturedScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              AnimatedAdminOption(
                icon: Icons.person_add_alt_1_rounded,
                title: l10n.createUser,
                subtitle: l10n.addNewUserFull,
                gradientColors: const [Color(0xFFFB8C00), Color(0xFFFFA726)],
                delay: 150,
                colors: colors,
                onTap: () {
                  Navigator.push(
                    context,
                    _createRoute(const CreationUserScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              AnimatedAdminOption(
                icon: Icons.people_rounded,
                title: l10n.manageUsers,
                subtitle: l10n.manageRolesPerms,
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

              const SizedBox(height: 12),

              AnimatedAdminOption(
                icon: Icons.auto_awesome_rounded,
                title: l10n.generateTestData,
                subtitle: l10n.createRealisticProducts,
                gradientColors: const [Color(0xFF673AB7), Color(0xFF9575CD)],
                delay: 250,
                colors: colors,
                onTap: () {
                  _showSeedConfirmationDialog(context, productsViewModel);
                },
              ),

              const SizedBox(height: 12),

              AnimatedAdminOption(
                icon: Icons.build_circle_rounded,
                title: l10n.fixImages,
                subtitle: l10n.fixBrokenImages,
                gradientColors: const [Color(0xFFE91E63), Color(0xFFF06292)],
                delay: 300,
                colors: colors,
                onTap: () {
                  _showFixImagesDialog(context, productsViewModel);
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
    AppLocalizations l10n,
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
                label: l10n.products,
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
                label: l10n.users,
                value: '$count',
                gradientColors: const [Color(0xFFE65100), Color(0xFFFF6D00)],
              );
            },
          ),
        ),
      ],
    );
  }

  void _showSeedConfirmationDialog(
    BuildContext context,
    ProductsViewModel productsVM,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.generateTestData),
        content: Text(
          l10n.seedConfirmationText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Mostrar snackbar de càrrega
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.generatingProducts)),
              );

              try {
                await productsVM.seedSampleProducts();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.productsGenerated),
                      backgroundColor: Colors.green,
                    ),
                  );
                  setState(() {}); // Forçar refresc del dashboard
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${l10n.errorGeneratingProducts}$e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(l10n.generate),
          ),
        ],
      ),
    );
  }

  void _showFixImagesDialog(
    BuildContext context,
    ProductsViewModel productsVM,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.fixImages),
        content: Text(
          l10n.fixImagesConfirmation,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.fixingImages)),
              );

              try {
                await productsVM.fixProductImages();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.imagesFixed),
                      backgroundColor: Colors.green,
                    ),
                  );
                  setState(() {});
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${l10n.errorFixingImages}$e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(l10n.fix),
          ),
        ],
      ),
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
