import 'package:decathdam/models/product_model.dart';
import 'package:flutter/material.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.preu * quantity;
}

class CartViewModel extends ChangeNotifier {
  final Map<String, CartItem> _items = {};
  String _selectedCountry = 'Espanya';

  // Tax rates by country (simulated)
  final Map<String, double> _taxRates = {
    'Espanya': 0.21,
    'França': 0.20,
    'Andorra': 0.045,
    'Estats Units': 0.07,
  };

  List<CartItem> get items => _items.values.toList();
  String get selectedCountry => _selectedCountry;
  List<String> get availableCountries => _taxRates.keys.toList();

  double get subtotal {
    return _items.values.fold(0, (sum, item) => sum + item.total);
  }

  double get taxRate => _taxRates[_selectedCountry] ?? 0.21;

  double get taxAmount => subtotal * taxRate;

  double get totalPrice => subtotal + taxAmount;

  void addToCart(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  void incrementQuantity(String productId) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(String productId) {
    if (_items.containsKey(productId)) {
      if (_items[productId]!.quantity > 1) {
        _items[productId]!.quantity--;
      } else {
        _items.remove(productId);
      }
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void setCountry(String country) {
    if (_taxRates.containsKey(country)) {
      _selectedCountry = country;
      notifyListeners();
    }
  }

  int get totalItemsCount {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }
}
