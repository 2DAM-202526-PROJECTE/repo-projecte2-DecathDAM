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

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Index de la pestanya de Favorits
  static const int _favoritesIndex = 3;

  // GlobalKey per accedir a l'estat del FavoritesScreen
  final GlobalKey<FavoritesScreenState> _favoritesKey =
      GlobalKey<FavoritesScreenState>();

  // Eliminem _widgetOptions de initState perquè ara dependrà de AuthViewModel
  @override
  void initState() {
    super.initState();
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'DecathDAM',
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
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inici'),
          const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explora'),
          isAdmin
              ? const BottomNavigationBarItem(
                  icon: Icon(Icons.admin_panel_settings),
                  label: 'Admin',
                )
              : const BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Perfil',
                ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorits',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cistella',
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
