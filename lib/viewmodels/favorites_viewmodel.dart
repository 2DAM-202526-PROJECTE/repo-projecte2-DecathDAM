import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:decathdam/repositories/favorites_repository.dart';

/// ViewModel que gestiona l'estat dels favorits, sincronitzats amb Firestore.
class FavoritesViewModel extends ChangeNotifier {
  final FavoritesRepository _repository;
  final FirebaseAuth _auth;

  Set<String> _favoriteIds = {};
  StreamSubscription<Set<String>>? _favoritesSubscription;
  StreamSubscription<User?>? _authSubscription;

  /// El userId actual per saber quan canvia la sessió.
  String? _currentUserId;

  FavoritesViewModel({
    FavoritesRepository? repository,
    FirebaseAuth? auth,
  })  : _repository = repository ?? FavoritesRepository(),
        _auth = auth ?? FirebaseAuth.instance {
    // Escolta canvis d'autenticació per canviar d'usuari
    _currentUserId = _auth.currentUser?.uid;
    _listenToAuth();
    // Si ja hi ha sessió, connecta amb els favorits immediatament
    if (_currentUserId != null) {
      _listenToFavorites(_currentUserId!);
    }
  }

  Set<String> get favoriteIds => _favoriteIds;

  bool isFavorite(String productId) {
    return _favoriteIds.contains(productId);
  }

  /// Afegeix o elimina un producte dels favorits a Firestore.
  Future<void> toggleFavorite(String productId) async {
    final userId = _currentUserId;
    if (userId == null) return; // No hi ha sessió, no fem res

    if (_favoriteIds.contains(productId)) {
      // Actualització optimista: elimina localment primer
      _favoriteIds.remove(productId);
      notifyListeners();
      try {
        await _repository.removeFavorite(userId, productId);
      } catch (e) {
        // Si falla, revertim
        _favoriteIds.add(productId);
        notifyListeners();
        debugPrint('Error eliminant favorit: $e');
      }
    } else {
      // Actualització optimista: afegeix localment primer
      _favoriteIds.add(productId);
      notifyListeners();
      try {
        await _repository.addFavorite(userId, productId);
      } catch (e) {
        // Si falla, revertim
        _favoriteIds.remove(productId);
        notifyListeners();
        debugPrint('Error afegint favorit: $e');
      }
    }
  }

  /// Escolta els canvis d'autenticació.
  void _listenToAuth() {
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      final newUserId = user?.uid;
      if (newUserId != _currentUserId) {
        _currentUserId = newUserId;
        _favoritesSubscription?.cancel();
        if (newUserId != null) {
          _listenToFavorites(newUserId);
        } else {
          // L'usuari ha tancat sessió: neteja els favorits locals
          _favoriteIds = {};
          notifyListeners();
        }
      }
    });
  }

  /// Escolta en temps real els favorits de l'usuari des de Firestore.
  void _listenToFavorites(String userId) {
    _favoritesSubscription =
        _repository.getFavoritesStream(userId).listen((ids) {
      _favoriteIds = ids;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _favoritesSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
