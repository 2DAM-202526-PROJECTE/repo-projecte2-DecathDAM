import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Servei d'autenticació que encapsula Firebase Auth i Google Sign-In.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _usersCollection = 'usuaris';

  /// Usuari autenticat actual (null si no hi ha sessió).
  User? get currentUser => _auth.currentUser;

  /// Stream dels canvis d'estat d'autenticació.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Email / Password ──────────────────────────────────────────────────

  /// Inicia sessió amb email i contrasenya.
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Registra un nou usuari amb email, contrasenya i nom.
  /// Crea també el document corresponent a Firestore.
  Future<UserCredential> registerWithEmail(
    String email,
    String password,
    String nom,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Actualitza el displayName a Firebase Auth
    await credential.user?.updateDisplayName(nom);

    // Crea el document a Firestore
    if (credential.user != null) {
      await _createUserDocument(
        uid: credential.user!.uid,
        nom: nom,
        email: email.trim(),
      );
    }

    return credential;
  }

  // ─── Google Sign-In ────────────────────────────────────────────────────

  /// Inicia sessió amb Google. Si és un usuari nou, crea el document a Firestore.
  Future<UserCredential?> signInWithGoogle() async {
    // Obre el diàleg de selecció de compte de Google
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      // L'usuari ha cancel·lat
      return null;
    }

    // Obté les credencials d'autenticació
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Inicia sessió a Firebase
    final userCredential = await _auth.signInWithCredential(credential);

    // Si és un nou usuari, crea el document a Firestore
    if (userCredential.additionalUserInfo?.isNewUser == true) {
      await _createUserDocument(
        uid: userCredential.user!.uid,
        nom: userCredential.user!.displayName ?? 'Usuari Google',
        email: userCredential.user!.email ?? '',
      );
    }

    return userCredential;
  }

  // ─── Sign Out ──────────────────────────────────────────────────────────

  /// Tanca la sessió actual (Firebase + Google).
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────

  /// Crea el document d'usuari a Firestore amb rol 'client'.
  Future<void> _createUserDocument({
    required String uid,
    required String nom,
    required String email,
  }) async {
    await _firestore.collection(_usersCollection).doc(uid).set({
      'nom': nom,
      'email': email,
      'rol': 'client',
      'actiu': true,
      'adreca': '',
      'telefon': '',
      'dni': '',
      'dataNaixement': '',
      'genere': '',
      'codiPostal': '',
      'ciutat': '',
    });
  }

  /// Tradueix els codis d'error de Firebase a missatges amigables.
  static String getErrorMessage(String code) {
    debugPrint("FirebaseAuthException code: \$code");
    switch (code) {
      case 'user-not-found':
        return 'No existeix cap compte amb aquest email.';
      case 'wrong-password':
        return 'La contrasenya és incorrecta.';
      case 'email-already-in-use':
        return 'Ja existeix un compte amb aquest email.';
      case 'weak-password':
        return 'La contrasenya ha de tenir almenys 6 caràcters.';
      case 'invalid-email':
        return 'L\'email introduït no és vàlid.';
      case 'too-many-requests':
        return 'Massa intents. Prova-ho de nou més tard.';
      case 'invalid-credential':
        return 'Les credencials no són vàlides. Comprova l\'email i la contrasenya.';
      case 'network-request-failed':
        return 'Error de connexió. Comprova la teva connexió a Internet.';
      default:
        return 'S\'ha produït un error (\$code). Torna-ho a provar.';
    }
  }
}

