import 'package:decathdam/view/login_screen.dart';
import 'package:decathdam/view/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Widget que escolta l'estat d'autenticació de Firebase i mostra
/// la pantalla de login o la pantalla principal segons correspongui.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mentre es determina l'estat, mostra una pantalla de càrrega
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF42A5F5),
              ),
            ),
          );
        }

        // Si hi ha un usuari autenticat, mostra la pantalla principal
        if (snapshot.hasData && snapshot.data != null) {
          return const MainScreen();
        }

        // Si no, mostra la pantalla de login
        return const LoginScreen();
      },
    );
  }
}
