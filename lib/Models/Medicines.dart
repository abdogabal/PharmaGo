import 'package:cloud_firestore/cloud_firestore.dart';

class Medic {
  String? id;
  String? name;
double? price;
double? quantity;

  Medic({
    this.id,
    this.name,
    this.price,
    this.quantity,
  });

  Medic.fromFireStore(Map<String, dynamic>? data) {
    id = data?['id'];
    name = data?['name'];
    price = (data?['price'] as num?)?.toDouble();
    quantity = (data?['quantity'] as num?)?.toDouble();
  }

  Map<String, dynamic> toFireStore() {
    return {
      "id": id,
      "name": name,
      "quantity": quantity,
      "price": price,
    };
  }
}
