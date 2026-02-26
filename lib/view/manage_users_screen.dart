import 'package:decathdam/models/user_model.dart';
import 'package:decathdam/viewmodels/users_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _listAnimController;

  @override
  void initState() {
    super.initState();
    _listAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _listAnimController.forward();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _listAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersViewModel = Provider.of<UsersViewModel>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0D1117) : const Color(0xFFF5F6FA);
    final appBarBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white54 : Colors.grey[600]!;
    final searchBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final searchBorder = isDark
        ? Colors.white.withAlpha(15)
        : Colors.grey.withAlpha(51);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Administrar Usuaris',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        backgroundColor: appBarBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddUserDialog(context, usersViewModel, isDark),
        backgroundColor: const Color(0xFFFF6D00),
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text(
          'Afegir',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: searchBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: searchBorder),
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.outfit(color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'Cercar per nom o email...',
                  hintStyle: GoogleFonts.outfit(
                    color: textSecondary,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(Icons.search_rounded, color: textSecondary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: textSecondary),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          // Users list
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: usersViewModel.getUsersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF6D00)),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Error: ${snapshot.error}',
                          style: GoogleFonts.outfit(color: Colors.red[300]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final allUsers = snapshot.data ?? [];
                final users = allUsers.where((user) {
                  if (_searchQuery.isEmpty) return true;
                  return user.nom.toLowerCase().contains(_searchQuery) ||
                      user.email.toLowerCase().contains(_searchQuery);
                }).toList();

                if (allUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF161B22)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.people_outline_rounded,
                            size: 56,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No hi ha usuaris',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Afegeix el primer usuari amb el botó +',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: isDark ? Colors.white30 : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: textSecondary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Cap resultat per "$_searchQuery"',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return _AnimatedUserCard(
                      user: users[index],
                      index: index,
                      viewModel: usersViewModel,
                      parentController: _listAnimController,
                      isDark: isDark,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(
    BuildContext context,
    UsersViewModel viewModel,
    bool isDark,
  ) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String selectedRol = 'client';

    final dialogBg = isDark ? const Color(0xFF1C2128) : Colors.white;
    final dialogText = isDark ? Colors.white : Colors.black87;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: dialogBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Afegir Usuari',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: dialogText,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDialogField(
                      controller: nameController,
                      hint: 'Nom complet',
                      icon: Icons.person_outline_rounded,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),
                    _buildDialogField(
                      controller: emailController,
                      hint: 'Email',
                      icon: Icons.email_outlined,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0D1117)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withAlpha(20)
                              : Colors.grey.withAlpha(51),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedRol,
                          isExpanded: true,
                          dropdownColor: dialogBg,
                          style: GoogleFonts.outfit(color: dialogText),
                          icon: Icon(
                            Icons.arrow_drop_down_rounded,
                            color: isDark ? Colors.white38 : Colors.grey,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'client',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 18,
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Client',
                                    style: GoogleFonts.outfit(
                                      color: dialogText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'admin',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.admin_panel_settings_outlined,
                                    size: 18,
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Admin',
                                    style: GoogleFonts.outfit(
                                      color: dialogText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            setDialogState(() => selectedRol = val!);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel·lar',
                    style: GoogleFonts.outfit(
                      color: isDark ? Colors.white38 : Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        emailController.text.isEmpty) {
                      return;
                    }
                    Navigator.pop(dialogContext);
                    try {
                      await viewModel.addUser({
                        'nom': nameController.text,
                        'email': emailController.text,
                        'rol': selectedRol,
                        'actiu': true,
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Usuari afegit correctament',
                              style: GoogleFonts.outfit(),
                            ),
                            backgroundColor: const Color(0xFF00C853),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6D00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Afegir',
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
      },
    );
  }

  Widget _buildDialogField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
  }) {
    final fieldBg = isDark ? const Color(0xFF0D1117) : Colors.grey[100]!;
    final fieldBorder = isDark
        ? Colors.white.withAlpha(20)
        : Colors.grey.withAlpha(51);
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white30 : Colors.grey;
    final iconColor = isDark ? Colors.white38 : Colors.grey;

    return Container(
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fieldBorder),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.outfit(color: textColor),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: hintColor),
          prefixIcon: Icon(icon, color: iconColor, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

// ─── Animated User Card ──────────────────────────────────────────────────────

class _AnimatedUserCard extends StatefulWidget {
  final UserModel user;
  final int index;
  final UsersViewModel viewModel;
  final AnimationController parentController;
  final bool isDark;

  const _AnimatedUserCard({
    required this.user,
    required this.index,
    required this.viewModel,
    required this.parentController,
    required this.isDark,
  });

  @override
  State<_AnimatedUserCard> createState() => _AnimatedUserCardState();
}

class _AnimatedUserCardState extends State<_AnimatedUserCard>
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

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final isDark = widget.isDark;
    final isAdmin = user.rol == 'admin';
    final initials = user.nom.isNotEmpty
        ? user.nom
              .split(' ')
              .take(2)
              .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
              .join()
        : '?';

    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final cardBorder = user.actiu
        ? (isDark ? Colors.white.withAlpha(15) : Colors.grey.withAlpha(38))
        : Colors.red.withAlpha(38);
    final cardShadow = isDark
        ? Colors.black.withAlpha(38)
        : Colors.black.withAlpha(13);
    final nameColor = user.actiu
        ? (isDark ? Colors.white : Colors.black87)
        : (isDark ? Colors.white38 : Colors.grey);
    final emailColor = isDark ? Colors.white38 : Colors.grey[500]!;
    final actionBarBg = isDark ? const Color(0xFF0D1117) : Colors.grey[100]!;
    final dividerColor = isDark
        ? Colors.white.withAlpha(15)
        : Colors.grey.withAlpha(38);

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
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: cardShadow,
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
                                // Role badge
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
                                    isAdmin ? 'Admin' : 'Client',
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
                                color: emailColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Active indicator
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
                            'Inactiu',
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

                  // Action buttons row
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: actionBarBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // Toggle role
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.swap_horiz_rounded,
                            label: isAdmin ? 'Fer Client' : 'Fer Admin',
                            color: const Color(0xFF42A5F5),
                            onTap: () => _toggleRole(user),
                          ),
                        ),
                        Container(width: 1, height: 28, color: dividerColor),
                        // Toggle active
                        Expanded(
                          child: _ActionButton(
                            icon: user.actiu
                                ? Icons.block_rounded
                                : Icons.check_circle_outline_rounded,
                            label: user.actiu ? 'Desactivar' : 'Activar',
                            color: user.actiu
                                ? Colors.amber
                                : const Color(0xFF00C853),
                            onTap: () => _toggleActive(user),
                          ),
                        ),
                        Container(width: 1, height: 28, color: dividerColor),
                        // Delete
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.delete_outline_rounded,
                            label: 'Eliminar',
                            color: Colors.red[400]!,
                            onTap: () =>
                                _showDeleteDialog(context, user, isDark),
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
    try {
      await widget.viewModel.updateUser(user.id, {'rol': newRole});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${user.nom} ara és ${newRole == 'admin' ? 'Admin' : 'Client'}',
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
    try {
      await widget.viewModel.updateUser(user.id, {'actiu': !user.actiu});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${user.nom} ${!user.actiu ? 'activat' : 'desactivat'}',
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

  void _showDeleteDialog(BuildContext context, UserModel user, bool isDark) {
    final dialogBg = isDark ? const Color(0xFF1C2128) : Colors.white;
    final dialogText = isDark ? Colors.white : Colors.black87;
    final dialogSub = isDark ? Colors.white70 : Colors.grey[600]!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Eliminar usuari?',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: dialogText,
            ),
          ),
          content: RichText(
            text: TextSpan(
              style: GoogleFonts.outfit(color: dialogSub, fontSize: 14),
              children: [
                const TextSpan(text: 'Estàs segur que vols eliminar '),
                TextSpan(
                  text: '"${user.nom}"',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: dialogText,
                  ),
                ),
                const TextSpan(text: '? Aquesta acció no es pot desfer.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel·lar',
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
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
                          'Usuari eliminat: ${user.nom}',
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
                'Eliminar',
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

// ─── Action Button Widget ────────────────────────────────────────────────────

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) {
        setState(() => _isHovered = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: _isHovered ? widget.color.withAlpha(26) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, size: 16, color: widget.color),
            const SizedBox(width: 5),
            Text(
              widget.label,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: widget.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
