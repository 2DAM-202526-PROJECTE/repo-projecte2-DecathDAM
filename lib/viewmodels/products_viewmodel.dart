import 'package:decathdam/models/product_model.dart';
import 'package:decathdam/repositories/product_repository.dart';
import 'package:flutter/material.dart';

class ProductsViewModel extends ChangeNotifier {
  final ProductRepository _repository = ProductRepository();
  List<Product> _products = [];

  List<Product> get products => _products;

  Stream<List<Product>> getProductsStream() {
    return _repository.getProductsStream();
  }

  Future<void> fetchProducts() async {
    try {
      _products = await _repository.fetchProducts();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching products: $e");
    }
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      await _repository.addProduct(productData);
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding product: $e");
      rethrow;
    }
  }

  Future<void> updateProduct(
    String id,
    Map<String, dynamic> productData,
  ) async {
    try {
      await _repository.updateProduct(id, productData);
      notifyListeners();
    } catch (e) {
      debugPrint("Error updating product: $e");
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _repository.deleteProduct(id);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting product: $e");
      rethrow;
    }
  }
}
