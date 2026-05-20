import 'package:decathdam/models/category_model.dart';
import 'package:decathdam/repositories/category_repository.dart';
import 'package:flutter/material.dart';

class CategoriesViewModel extends ChangeNotifier {
  final CategoryRepository _repository = CategoryRepository();
  List<Category> _categories = [];

  List<Category> get categories => _categories;

  Stream<List<Category>>? _categoriesStream;
  Stream<List<Category>> getCategoriesStream() {
    _categoriesStream ??= _repository.getCategoriesStream();
    return _categoriesStream!;
  }

  Future<List<Category>> fetchCategories() async {
    try {
      _categories = await _repository.fetchCategories();
      notifyListeners();
      return _categories;
    } catch (e) {
      debugPrint("Error fetching categories: $e");
      return [];
    }
  }

  Future<int> getCategoriesCount() async {
    return _repository.getCategoriesCount();
  }

  Future<void> addCategory(Map<String, dynamic> categoryData) async {
    try {
      await _repository.addCategory(categoryData);
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding category: $e");
      rethrow;
    }
  }

  Future<void> updateCategory(
    String id,
    Map<String, dynamic> categoryData,
  ) async {
    try {
      await _repository.updateCategory(id, categoryData);
      notifyListeners();
    } catch (e) {
      debugPrint("Error updating category: $e");
      rethrow;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _repository.deleteCategory(id);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting category: $e");
      rethrow;
    }
  }

  /// Comprova si una categoria té productes associats.
  Future<int> getProductsCountByCategory(String categoryId) async {
    return _repository.getProductsCountByCategory(categoryId);
  }

  /// Retorna el nom d'una categoria pel seu ID dins de la llista carregada.
  String getCategoryName(String categoryId) {
    final cat = _categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => Category(id: '', nom: 'Sense categoria'),
    );
    return cat.nom;
  }
}
