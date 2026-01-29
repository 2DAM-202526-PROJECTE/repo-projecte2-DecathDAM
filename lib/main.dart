import 'package:decathdam/view/main_screen.dart';
import 'package:decathdam/viewmodels/products_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:decathdam/config/firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  // Imprescindible: assegura que Flutter estigui llest abans d'iniciar Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Connecta l'app amb Firebase usant la configuració del teu fitxer
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ProductsViewModel())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DecathDAM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
