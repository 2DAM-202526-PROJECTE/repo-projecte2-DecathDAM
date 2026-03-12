import 'package:decathdam/services/payment_service.dart';
import 'package:decathdam/view/auth_wrapper.dart';
import 'package:decathdam/viewmodels/cart_viewmodel.dart';
import 'package:decathdam/viewmodels/favorites_viewmodel.dart';
import 'package:decathdam/viewmodels/products_viewmodel.dart';
import 'package:decathdam/viewmodels/auth_viewmodel.dart';
import 'package:decathdam/viewmodels/theme_provider.dart';
import 'package:decathdam/viewmodels/users_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:decathdam/config/firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  // Imprescindible: assegura que Flutter estigui llest abans d'iniciar Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialització de Stripe
  await PaymentService.init();

  // Connecta l'app amb Firebase usant la configuració del teu fitxer

  // Connecta l'app amb Firebase usant la configuració del teu fitxer
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ProductsViewModel()),
        ChangeNotifierProvider(create: (_) => UsersViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'DecathDAM',
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const AuthWrapper(),
    );
  }
}
