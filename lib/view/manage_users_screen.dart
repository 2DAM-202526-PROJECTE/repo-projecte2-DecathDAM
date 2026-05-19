import 'package:decathdam/config/app_theme.dart';
import 'package:decathdam/models/user_model.dart';
import 'package:decathdam/view/widgets/animated_user_card.dart';
import 'package:decathdam/viewmodels/users_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:decathdam/l10n/app_localizations.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late Stream<List<UserModel>> _usersStream;
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
      Provider.of<UsersViewModel>(context, listen: false)
          .updateSearchQuery(_searchController.text);
    });

    // Inicialitzem l'stream aquí per evitar recrear-lo a cada build
    _usersStream = Provider.of<UsersViewModel>(
      context,
      listen: false,
    ).getUsersStream();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _listAnimController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final usersViewModel = Provider.of<UsersViewModel>(context);
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.manageUsers,
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
                  hintText: l10n.searchUsers,
                  hintStyle: GoogleFonts.outfit(
                    color: colors.textSecondary,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colors.iconSecondary,
                  ),
                  suffixIcon: usersViewModel.searchQuery.isNotEmpty
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
              stream: _usersStream,
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
                final users = usersViewModel.filteredUsers;

                if (allUsers.isEmpty) {
                  return _buildEmptyState(colors, l10n);
                }

                if (users.isEmpty) {
                  return _buildNoResultsState(colors, usersViewModel, l10n);
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

  Widget _buildEmptyState(AppColors colors, AppLocalizations l10n) {
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
            l10n.noUsers,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.addFirstUser,
            style: GoogleFonts.outfit(fontSize: 13, color: colors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(AppColors colors, UsersViewModel usersViewModel, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: colors.textSecondary),
          const SizedBox(height: 12),
          Text(
            l10n.noResultsFor(usersViewModel.searchQuery),
            style: GoogleFonts.outfit(
              fontSize: 15,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

}
