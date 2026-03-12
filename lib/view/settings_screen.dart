import 'package:decathdam/config/app_theme.dart';
import 'package:decathdam/view/widgets/animated_admin_option.dart';
import 'package:decathdam/view/widgets/logout_button.dart';
import 'package:decathdam/view/widgets/settings_theme_card.dart';
import 'package:decathdam/viewmodels/auth_viewmodel.dart';
import 'package:decathdam/viewmodels/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'Ajustes',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colors.textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aparença
            SettingsThemeCard(themeProvider: themeProvider, colors: colors),

            const SizedBox(height: 12),

            // Idioma
            AnimatedAdminOption(
              icon: Icons.language_rounded,
              title: 'Idioma',
              subtitle: 'Català',
              gradientColors: const [Color(0xFF7C4DFF), Color(0xFFB388FF)],
              delay: 100,
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

            // Notificacions
            AnimatedAdminOption(
              icon: Icons.notifications_rounded,
              title: 'Notificacions',
              subtitle: 'Gestiona les alertes de l\'app',
              gradientColors: const [Color(0xFF00BCD4), Color(0xFF4DD0E1)],
              delay: 200,
              colors: colors,
              onTap: () {
                _showInfoSnackBar(context, colors, 'Notificacions pròximament');
              },
            ),

            const SizedBox(height: 28),

            // Tancar sessió
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
              onPressed: () async {
                final authVM = Provider.of<AuthViewModel>(context, listen: false);
                Navigator.pop(dialogContext); // Tanca el diàleg
                
                // Tanca la sessió (l'AuthWrapper detectarà el canvi i ens portarà al login)
                await authVM.logout();
                
                // Opcionalment tanquem també la pantalla d'ajustos per si el rebuild triga
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
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
