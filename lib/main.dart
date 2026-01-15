import 'package:decathdam/viewmodels/craft.dart';
import 'package:flutter/material.dart';
import 'viewmodels/inici_vm.dart';

void main() {
  runApp(const MyApp());
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
      home: const CraftScreen(),
    );
  }
}
