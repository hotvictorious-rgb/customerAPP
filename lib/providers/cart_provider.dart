import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../core/utils/currency_formatter.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get lineTotal {
    final unit = double.tryParse(product.unitPrice) ?? 0.0;
    return unit * quantity;
  }

  String get formattedLineTotal => CurrencyFormatter.format(lineTotal);
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get rawSubtotal => _items.fold(0.0, (sum, item) => sum + item.lineTotal);
  String get formattedSubtotal => CurrencyFormatter.format(rawSubtotal);

  int? get shopId => _items.isNotEmpty ? _items.first.product.shopId : null;
  String? get currentShopName => _items.isNotEmpty ? (_items.first.product.shop?.name ?? 'Merchant Shop') : null;

  bool isDifferentShop(ProductModel product) {
    if (_items.isEmpty) return false;
    return _items.first.product.shopId != product.shopId;
  }

  void addToCart(ProductModel product, {int quantity = 1}) {
    final existingIndex = _items.indexWhere((i) => i.product.id == product.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void clearAndAdd(ProductModel product, {int quantity = 1}) {
    _items.clear();
    addToCart(product, quantity: quantity);
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  void removeFromCart(int productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
