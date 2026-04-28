import 'package:decathdam/services/auth_service.dart';
import 'package:decathdam/models/user_model.dart';
import 'package:decathdam/repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// ViewModel que gestiona l'estat d'autenticació de l'app.
class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  final UserRepository _userRepository;

  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUserModel;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _authService.currentUser;
  UserModel? get currentUserModel => _currentUserModel;
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  AuthViewModel({AuthService? authService, UserRepository? userRepository})
      : _authService = authService ?? AuthService(),
        _userRepository = userRepository ?? UserRepository() {
    // Escolta els canvis d'autenticació per mantenir UserModel sincronitzat
    _authService.authStateChanges.listen((User? user) async {
      await _fetchUserModel(user);
    });
    // Obté l'usuari inicial si ja hi ha sessió
    if (currentUser != null) {
      _fetchUserModel(currentUser);
    }
  }

  Future<void> _fetchUserModel(User? user) async {
    if (user != null) {
      _currentUserModel = await _userRepository.getUserById(user.uid);
    } else {
      _currentUserModel = null;
    }
    notifyListeners();
  }

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
      debugPrint("Intentant login per a: $email");
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
      debugPrint("Error al fer login: $e");
      _errorMessage = 'Error inesperat: $e';
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
      debugPrint("Error al registrar: $e");
      _errorMessage = 'Error inesperat: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Restablir Contrasenya ─────────────────────────────────────────────

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = AuthService.getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint("Error al restablir contrasenya: $e");
      _errorMessage = 'Error inesperat: $e';
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
    _currentUserModel = null;
    notifyListeners();
  }

  // ─── Actualitzar Perfil ────────────────────────────────────────────────

  Future<bool> updateProfile({
    required String nom,
    required String adreca,
    required String telefon,
    required String dni,
    required String dataNaixement,
    required String genere,
    required String codiPostal,
    required String ciutat,
  }) async {
    if (currentUser == null || _currentUserModel == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Actualitza el displayName a Firebase Auth
      await currentUser!.updateDisplayName(nom);

      // 2. Actualitza a Firestore
      final updatedUser = _currentUserModel!.copyWith(
        nom: nom,
        adreca: adreca,
        telefon: telefon,
        dni: dni,
        dataNaixement: dataNaixement,
        genere: genere,
        codiPostal: codiPostal,
        ciutat: ciutat,
      );
      await _userRepository.updateUser(updatedUser);

      // 3. Actualitza l'estat local
      _currentUserModel = updatedUser;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error al actualitzar el perfil: $e");
      _errorMessage = 'Error en actualitzar el perfil: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
