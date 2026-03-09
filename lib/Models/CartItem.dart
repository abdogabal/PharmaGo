import 'package:pharmago/Models/Medicines.dart';

class CartItem {
  final Medic medic;
  int quantity;

  CartItem({required this.medic, this.quantity = 1});

  double get totalPrice => (medic.price ?? 0.0) * quantity;
}
