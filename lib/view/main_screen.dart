import 'package:decathdam/config/app_theme.dart';
import 'package:decathdam/view/admin_screen.dart';
import 'package:decathdam/view/cart_screen.dart';
import 'package:decathdam/view/client_profile_screen.dart';
import 'package:decathdam/view/explore_screen.dart';
import 'package:decathdam/view/favorites_screen.dart';
import 'package:decathdam/view/home_screen.dart';
import 'package:decathdam/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:decathdam/l10n/app_localizations.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  // Index de la pestanya de Favorits
  static const int _favoritesIndex = 3;

  // GlobalKey per accedir a l'estat del FavoritesScreen
  final GlobalKey<FavoritesScreenState> _favoritesKey =
      GlobalKey<FavoritesScreenState>();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  List<Widget> _buildWidgetOptions(bool isAdmin) {
    return <Widget>[
      const HomeScreen(),
      const ExploreScreen(),
      isAdmin ? const AdminScreen() : const ClientProfileScreen(),
      FavoritesScreen(key: _favoritesKey),
      const CartScreen(),
    ];
  }

  void _onItemTapped(int index) {
    // Si l'usuari surt de la pestanya de Favorits, aplica les eliminacions pendents
    if (_selectedIndex == _favoritesIndex && index != _favoritesIndex) {
      _favoritesKey.currentState?.applyPendingRemovals();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final authViewModel = Provider.of<AuthViewModel>(context);
    final isAdmin = authViewModel.currentUserModel?.rol == 'admin';
    final widgetOptions = _buildWidgetOptions(isAdmin);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appTitle,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        backgroundColor: colors.surface,
        elevation: 0,
      ),
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colors.surface,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: l10n.home),
          BottomNavigationBarItem(icon: const Icon(Icons.search), label: l10n.exploreTitle),
          isAdmin
              ? BottomNavigationBarItem(
                  icon: const Icon(Icons.admin_panel_settings),
                  label: l10n.admin,
                )
              : BottomNavigationBarItem(
                  icon: const Icon(Icons.person),
                  label: l10n.profileTitle,
                ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite),
            label: l10n.favorites,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_cart),
            label: l10n.cart,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: colors.navSelected,
        unselectedItemColor: colors.navUnselected,
        onTap: _onItemTapped,
      ),
    );
  }
}
