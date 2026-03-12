import 'package:decathdam/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// ViewModel que gestiona l'estat d'autenticació de l'app.
class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _authService.currentUser;
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  /// Neteja el missatge d'error.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ─── Login amb email / password ────────────────────────────────────────

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithEmail(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = AuthService.getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'S\'ha produït un error inesperat.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Registre amb email / password ─────────────────────────────────────

  Future<bool> register(String email, String password, String nom) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.registerWithEmail(email, password, nom);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = AuthService.getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'S\'ha produït un error inesperat.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Login amb Google ──────────────────────────────────────────────────

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.signInWithGoogle();
      _isLoading = false;
      notifyListeners();
      return result != null;
    } on FirebaseAuthException catch (e) {
      _errorMessage = AuthService.getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'S\'ha produït un error amb Google Sign-In.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Sign Out ──────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _authService.signOut();
    notifyListeners();
  }
}
