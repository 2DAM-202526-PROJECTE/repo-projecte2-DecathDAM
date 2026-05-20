import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decathdam/models/category_model.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'categories';

  /// Stream en temps real de totes les categories ordenades per 'ordre'.
  Stream<List<Category>> getCategoriesStream() {
    return _firestore
        .collection(_collectionName)
        .orderBy('ordre')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Category.fromFirestore(doc.id, doc.data());
      }).toList();
    });
  }

  /// Obté totes les categories una sola vegada.
  Future<List<Category>> fetchCategories() async {
    final snapshot = await _firestore
        .collection(_collectionName)
        .orderBy('ordre')
        .get();
    return snapshot.docs.map((doc) {
      return Category.fromFirestore(doc.id, doc.data());
    }).toList();
  }

  /// Crea una nova categoria.
  Future<void> addCategory(Map<String, dynamic> categoryData) async {
    await _firestore.collection(_collectionName).add(categoryData);
  }

  /// Actualitza una categoria existent.
  Future<void> updateCategory(
    String id,
    Map<String, dynamic> categoryData,
  ) async {
    await _firestore.collection(_collectionName).doc(id).update(categoryData);
  }

  /// Elimina una categoria.
  Future<void> deleteCategory(String id) async {
    await _firestore.collection(_collectionName).doc(id).delete();
  }

  /// Retorna el nombre de categories.
  Future<int> getCategoriesCount() async {
    final snapshot =
        await _firestore.collection(_collectionName).count().get();
    return snapshot.count ?? 0;
  }

  /// Obté una categoria pel seu ID.
  Future<Category?> getCategoryById(String id) async {
    final doc = await _firestore.collection(_collectionName).doc(id).get();
    if (doc.exists) {
      return Category.fromFirestore(doc.id, doc.data()!);
    }
    return null;
  }

  /// Comprova si hi ha productes assignats a una categoria.
  Future<int> getProductsCountByCategory(String categoryId) async {
    final snapshot = await _firestore
        .collection('productes')
        .where('categoriaId', isEqualTo: categoryId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}
