import 'package:cloud_firestore/cloud_firestore.dart';

/// Repositori que gestiona els favorits de cada usuari a Firestore.
///
/// Estructura:  usuaris/{userId}/favorits/{productId}
class FavoritesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Referència a la sub-col·lecció de favorits d'un usuari.
  CollectionReference _favoritesRef(String userId) {
    return _firestore.collection('usuaris').doc(userId).collection('favorits');
  }

  /// Retorna un Stream amb la llista d'IDs de productes favorits.
  Stream<Set<String>> getFavoritesStream(String userId) {
    return _favoritesRef(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toSet();
    });
  }

  /// Obté tots els IDs de productes favorits (una sola vegada).
  Future<Set<String>> getFavorites(String userId) async {
    final snapshot = await _favoritesRef(userId).get();
    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  /// Afegeix un producte als favorits.
  Future<void> addFavorite(String userId, String productId) async {
    await _favoritesRef(userId).doc(productId).set({
      'afegitEl': FieldValue.serverTimestamp(),
    });
  }

  /// Elimina un producte dels favorits.
  Future<void> removeFavorite(String userId, String productId) async {
    await _favoritesRef(userId).doc(productId).delete();
  }

  /// Comprova si un producte és favorit.
  Future<bool> isFavorite(String userId, String productId) async {
    final doc = await _favoritesRef(userId).doc(productId).get();
    return doc.exists;
  }
}
