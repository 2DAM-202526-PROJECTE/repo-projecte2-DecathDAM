import 'package:decathdam/config/app_theme.dart';
import 'package:decathdam/models/user_model.dart';
import 'package:decathdam/view/widgets/animated_user_card.dart';
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
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'Administrar Usuaris',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddUserDialog(context, usersViewModel, colors),
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
                color: colors.inputFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.searchBorder),
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.outfit(color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Cercar per nom o email...',
                  hintStyle: GoogleFonts.outfit(
                    color: colors.textSecondary,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colors.iconSecondary,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: colors.iconSecondary,
                          ),
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
                  return _buildEmptyState(colors);
                }

                if (users.isEmpty) {
                  return _buildNoResultsState(colors);
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return AnimatedUserCard(
                      user: users[index],
                      index: index,
                      viewModel: usersViewModel,
                      parentController: _listAnimController,
                      colors: colors,
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

  Widget _buildEmptyState(AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 56,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No hi ha usuaris',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Afegeix el primer usuari amb el botó +',
            style: GoogleFonts.outfit(fontSize: 13, color: colors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: colors.textSecondary),
          const SizedBox(height: 12),
          Text(
            'Cap resultat per "$_searchQuery"',
            style: GoogleFonts.outfit(
              fontSize: 15,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(
    BuildContext context,
    UsersViewModel viewModel,
    AppColors colors,
  ) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String selectedRol = 'client';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: colors.dialog,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Afegir Usuari',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
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
                      colors: colors,
                    ),
                    const SizedBox(height: 14),
                    _buildDialogField(
                      controller: emailController,
                      hint: 'Email',
                      icon: Icons.email_outlined,
                      colors: colors,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.inputFillAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.inputBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedRol,
                          isExpanded: true,
                          dropdownColor: colors.dialog,
                          style: GoogleFonts.outfit(color: colors.textPrimary),
                          icon: Icon(
                            Icons.arrow_drop_down_rounded,
                            color: colors.iconSecondary,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'client',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 18,
                                    color: colors.iconSecondary,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Client',
                                    style: GoogleFonts.outfit(
                                      color: colors.textPrimary,
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
                                    color: colors.iconSecondary,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Admin',
                                    style: GoogleFonts.outfit(
                                      color: colors.textPrimary,
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
                    style: GoogleFonts.outfit(color: colors.cancelButton),
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
    required AppColors colors,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.inputFillAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.inputBorder),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.outfit(color: colors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: colors.textHint),
          prefixIcon: Icon(icon, color: colors.iconSecondary, size: 20),
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
