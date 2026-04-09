import 'package:decathdam/models/product_model.dart';
import 'package:decathdam/repositories/product_repository.dart';
import 'package:decathdam/services/seed_service.dart';
import 'package:flutter/material.dart';

class ProductsViewModel extends ChangeNotifier {
  final ProductRepository _repository = ProductRepository();
  List<Product> _products = [];

  List<Product> get products => _products;

  Stream<List<Product>>? _productsStream;
  Stream<List<Product>> getProductsStream() {
    _productsStream ??= _repository.getProductsStream();
    return _productsStream!;
  }

  Future<int> getProductsCount() async {
    return _repository.getProductsCount();
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

  Future<void> seedSampleProducts() async {
    try {
      final seedService = SeedService();
      await seedService.seedProducts();
      await fetchProducts(); // Refresh the list
      notifyListeners();
    } catch (e) {
      debugPrint("Error seeding products: $e");
      rethrow;
    }
  }

  Future<void> fixProductImages() async {
    try {
      final seedService = SeedService();
      await seedService.fixImages();
      await fetchProducts(); // Refresh the list
      notifyListeners();
    } catch (e) {
      debugPrint("Error fixing product images: $e");
      rethrow;
    }
  }
}
