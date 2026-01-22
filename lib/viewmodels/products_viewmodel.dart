import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decathdam/models/product_model.dart';
import 'package:flutter/material.dart';

class ProductsViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Product> _products = [];

  List<Product> get products => _products;

  Stream<List<Product>> getProductsStream() {
    return _firestore.collection('productes').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromFirestore(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> fetchProducts() async {
    try {
      final snapshot = await _firestore.collection('productes').get();
      _products = snapshot.docs.map((doc) {
        return Product.fromFirestore(doc.id, doc.data());
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching products: $e");
    }
  }
}
