import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decathdam/models/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'productes';

  Stream<List<Product>> getProductsStream() {
    return _firestore.collection(_collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromFirestore(doc.id, doc.data());
      }).toList();
    });
  }

  Future<List<Product>> fetchProducts() async {
    final snapshot = await _firestore.collection(_collectionName).get();
    return snapshot.docs.map((doc) {
      return Product.fromFirestore(doc.id, doc.data());
    }).toList();
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    await _firestore.collection(_collectionName).add(productData);
  }

  Future<void> updateProduct(
    String id,
    Map<String, dynamic> productData,
  ) async {
    await _firestore.collection(_collectionName).doc(id).update(productData);
  }

  Future<void> deleteProduct(String id) async {
    await _firestore.collection(_collectionName).doc(id).delete();
  }
}
