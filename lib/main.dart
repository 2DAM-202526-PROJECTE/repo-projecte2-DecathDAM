import 'package:decathdam/repositories/user_repository.dart';
import 'package:decathdam/services/auth_service.dart';
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
import 'package:decathdam/services/push_notifications_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:decathdam/l10n/app_localizations.dart';
import 'package:decathdam/viewmodels/locale_provider.dart';

void main() async {
  // Imprescindible: assegura que Flutter estigui llest abans d'iniciar Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialització de Stripe
  await PaymentService.init();

  // Connecta l'app amb Firebase usant la configuració del teu fitxer
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicialitza el servei de notificacions d'alta prioritat
  await PushNotificationService.initialize();

  // Repositoris i serveis
  final userRepository = UserRepository();
  final authService = AuthService(userRepository: userRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(
            authService: authService,
            userRepository: userRepository,
          ),
        ),
        ChangeNotifierProvider(create: (_) => ProductsViewModel()),
        ChangeNotifierProvider(
          create: (_) => UsersViewModel(userRepository: userRepository),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
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
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'DecathDAM',
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ca'),
        Locale('es'),
        Locale('en'),
      ],
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const AuthWrapper(),
    );
  }
}
