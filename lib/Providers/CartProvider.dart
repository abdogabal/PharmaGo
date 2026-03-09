import 'package:flutter/material.dart';
import '../Models/Medicines.dart';
import '../Models/CartItem.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get itemCount {
    int count = 0;
    _items.forEach((key, cartItem) {
      count += cartItem.quantity;
    });
    return count;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.medic.price! * cartItem.quantity;
    });
    return total;
  }

  void addItem(Medic medic) {
    if (medic.id == null) return;
    
    if (_items.containsKey(medic.id)) {
      _items.update(
        medic.id!,
        (existingCartItem) => CartItem(
          medic: existingCartItem.medic,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        medic.id!,
        () => CartItem(medic: medic, quantity: 1),
      );
    }
    notifyListeners();
  }

  void removeItem(String medicId) {
    _items.remove(medicId);
    notifyListeners();
  }

  void removeSingleItem(String medicId) {
    if (!_items.containsKey(medicId)) return;

    if (_items[medicId]!.quantity > 1) {
      _items.update(
        medicId,
        (existingCartItem) => CartItem(
          medic: existingCartItem.medic,
          quantity: existingCartItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(medicId);
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
