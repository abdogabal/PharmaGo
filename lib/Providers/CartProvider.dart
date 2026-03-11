import 'package:flutter/material.dart';
import '../Models/Medicines.dart';
import '../Models/CartItem.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  String? currentPharmaId;

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

  bool addItem(Medic medic, {String? pharmaId}) {
    if (medic.id == null) return false;
    
    if (pharmaId != null) {
      if (currentPharmaId != null && currentPharmaId != pharmaId) {
        clearCart();
      }
      currentPharmaId = pharmaId;
    }

    if (_items.containsKey(medic.id)) {
      if (_items[medic.id!]!.quantity >= (medic.quantity ?? double.infinity)) {
        return false;
      }
      _items.update(
        medic.id!,
        (existingCartItem) => CartItem(
          medic: existingCartItem.medic,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      if ((medic.quantity ?? double.infinity) < 1) {
        return false;
      }
      _items.putIfAbsent(
        medic.id!,
        () => CartItem(medic: medic, quantity: 1),
      );
    }
    notifyListeners();
    return true;
  }

  void removeItem(String medicId) {
    _items.remove(medicId);
    if (_items.isEmpty) {
      currentPharmaId = null;
    }
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
      if (_items.isEmpty) {
        currentPharmaId = null;
      }
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    currentPharmaId = null;
    notifyListeners();
  }
}
