import 'package:decathdam/config/app_theme.dart';
import 'package:decathdam/models/user_model.dart';
import 'package:decathdam/view/widgets/action_button.dart';
import 'package:decathdam/viewmodels/users_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:decathdam/l10n/app_localizations.dart';

class AnimatedUserCard extends StatefulWidget {
  final UserModel user;
  final int index;
  final UsersViewModel viewModel;
  final AnimationController parentController;
  final AppColors colors;

  const AnimatedUserCard({
    super.key,
    required this.user,
    required this.index,
    required this.viewModel,
    required this.parentController,
    required this.colors,
  });

  @override
  State<AnimatedUserCard> createState() => _AnimatedUserCardState();
}

class _AnimatedUserCardState extends State<AnimatedUserCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final user = widget.user;
    final colors = widget.colors;
    final l10n = AppLocalizations.of(context)!;
    final isAdmin = user.rol == 'admin';
    final initials = user.nom.isNotEmpty
        ? user.nom
              .split(' ')
              .take(2)
              .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
              .join()
        : '?';

    final cardBorder = user.actiu ? colors.border : Colors.red.withAlpha(38);
    final nameColor = user.actiu ? colors.textPrimary : colors.textSecondary;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadowLight,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isAdmin
                                ? [
                                    const Color(0xFFFF6D00),
                                    const Color(0xFFFF9100),
                                  ]
                                : [
                                    const Color(0xFF1E88E5),
                                    const Color(0xFF42A5F5),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    user.nom,
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: nameColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isAdmin
                                        ? const Color(0xFFFF6D00).withAlpha(38)
                                        : const Color(0xFF1E88E5).withAlpha(38),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isAdmin ? l10n.adminRole : l10n.clientRole,
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isAdmin
                                          ? const Color(0xFFFF9100)
                                          : const Color(0xFF42A5F5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              user.email,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: colors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      if (!user.actiu)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(26),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            l10n.inactive,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: Colors.red[300],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Action bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.actionBar,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ActionButton(
                            icon: Icons.swap_horiz_rounded,
                            label: isAdmin ? l10n.makeClient : l10n.makeAdmin,
                            color: const Color(0xFF42A5F5),
                            onTap: () => _toggleRole(user),
                          ),
                        ),
                        Container(width: 1, height: 28, color: colors.divider),
                        Expanded(
                          child: ActionButton(
                            icon: user.actiu
                                ? Icons.block_rounded
                                : Icons.check_circle_outline_rounded,
                            label: user.actiu ? l10n.deactivate : l10n.activate,
                            color: user.actiu
                                ? Colors.amber
                                : const Color(0xFF00C853),
                            onTap: () => _toggleActive(user),
                          ),
                        ),
                        Container(width: 1, height: 28, color: colors.divider),
                        Expanded(
                          child: ActionButton(
                            icon: Icons.delete_outline_rounded,
                            label: l10n.delete,
                            color: Colors.red[400]!,
                            onTap: () =>
                                _showDeleteDialog(context, user, colors),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleRole(UserModel user) async {
    final newRole = user.rol == 'admin' ? 'client' : 'admin';
    final l10n = AppLocalizations.of(context)!;
    try {
      final updatedUser = user.copyWith(rol: newRole);
      await widget.viewModel.updateUser(updatedUser);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.userNowIsRole(user.nom, newRole == 'admin' ? l10n.adminRole : l10n.clientRole),
              style: GoogleFonts.outfit(),
            ),
            backgroundColor: const Color(0xFF1E88E5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _toggleActive(UserModel user) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final updatedUser = user.copyWith(actiu: !user.actiu);
      await widget.viewModel.updateUser(updatedUser);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !user.actiu ? l10n.userActivated(user.nom) : l10n.userDeactivated(user.nom),
              style: GoogleFonts.outfit(),
            ),
            backgroundColor: !user.actiu
                ? const Color(0xFF00C853)
                : Colors.amber[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    UserModel user,
    AppColors colors,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.dialog,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            l10n.deleteUserConfirmation,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          content: RichText(
            text: TextSpan(
              style: GoogleFonts.outfit(
                color: colors.textSecondary,
                fontSize: 14,
              ),
              children: [
                TextSpan(text: l10n.deleteUserText(user.nom).split('"${user.nom}"')[0]),
                TextSpan(
                  text: '"${user.nom}"',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                TextSpan(text: l10n.deleteUserText(user.nom).split('"${user.nom}"').length > 1 ? l10n.deleteUserText(user.nom).split('"${user.nom}"')[1] : ''),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                l10n.cancel,
                style: GoogleFonts.outfit(color: colors.cancelButton),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  await widget.viewModel.deleteUser(user.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.userDeleted(user.nom),
                          style: GoogleFonts.outfit(),
                        ),
                        backgroundColor: Colors.red[600],
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                l10n.delete,
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
