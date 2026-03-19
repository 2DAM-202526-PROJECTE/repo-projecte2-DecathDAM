import 'package:decathdam/config/app_theme.dart';
import 'package:decathdam/view/personal_info_screen.dart';
import 'package:decathdam/viewmodels/auth_viewmodel.dart';
import 'package:decathdam/viewmodels/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);
    final user = authViewModel.currentUserModel;

    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          // Background Gradient Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.35,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.accentBlue,
                    colors.accentBlue.withOpacity(0.6),
                    colors.background,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Blur Effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: colors.background.withOpacity(0.3),
              ),
            ),
          ),
          // Content Scroll
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 20),
                      child: Column(
                        children: [
                          _buildProfileCard(context, colors, user, authViewModel),
                          const SizedBox(height: 32),
                          _buildSectionTitle('Ajustaments', colors),
                          const SizedBox(height: 16),
                          _buildOptionsList(colors, themeProvider, isDarkMode, authViewModel, context),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, AppColors colors, dynamic user,
      AuthViewModel authVM) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                // Avatar with Gradient Border
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [colors.accentBlue, Colors.purpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: colors.background,
                    child: Text(
                      user?.nom.isNotEmpty == true
                          ? user!.nom.substring(0, 1).toUpperCase()
                          : 'U',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: colors.accentBlue,
                      ),
                    ),
                  ),
                ),
                // Info Username
                Text(
                  user?.nom ?? 'Usuari sense nom',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  user?.email ?? 'correu@exemple.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.accentBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Rol: ${user?.rol.toUpperCase() ?? 'CLIENT'}',
                    style: TextStyle(
                      color: colors.accentBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (authVM.isLoading) ...[
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, AppColors colors) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildOptionsList(AppColors colors, ThemeProvider themeProvider,
      bool isDarkMode, AuthViewModel authVM, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          _buildOptionTile(
            colors: colors,
            icon: Icons.person_outline,
            title: 'La meva informació personal',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PersonalInfoScreen()),
              );
            },
          ),
          Divider(color: colors.divider, height: 1),
          _buildOptionTile(
            colors: colors,
            icon: Icons.brightness_6,
            title: 'Tema',
            trailing: DropdownButton<ThemeMode>(
              value: themeProvider.themeMode,
              underline: const SizedBox(),
              icon: Icon(Icons.arrow_drop_down, color: colors.textSecondary),
              dropdownColor: colors.surface,
              style: TextStyle(color: colors.textPrimary, fontSize: 14),
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('Sistema')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Clar')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Fosc')),
              ],
              onChanged: (ThemeMode? mode) {
                if (mode != null) {
                  themeProvider.setThemeMode(mode);
                }
              },
            ),
          ),
          Divider(color: colors.divider, height: 1),
          _buildOptionTile(
            colors: colors,
            icon: Icons.notifications_active_outlined,
            title: 'Notificacions',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notificacions pròximament')),
              );
            },
          ),
          Divider(color: colors.divider, height: 1),
          _buildOptionTile(
            colors: colors,
            icon: Icons.security_outlined,
            title: 'Privacitat i Seguretat',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacitat pròximament')),
              );
            },
          ),
          Divider(color: colors.divider, height: 1),
          _buildOptionTile(
            colors: colors,
            icon: Icons.logout_rounded,
            title: 'Tancar Sessió',
            titleColor: Colors.redAccent,
            iconColor: Colors.redAccent,
            onTap: () {
              authVM.logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required AppColors colors,
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (iconColor ?? colors.accentBlue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor ?? colors.accentBlue, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: titleColor ?? colors.textPrimary,
                  ),
                ),
              ),
              if (trailing != null)
                trailing
              else
                Icon(Icons.arrow_forward_ios,
                    size: 16, color: colors.textSecondary.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }
}
