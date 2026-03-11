

class Medic {
  String? id;
  String? name;
double? price;
double? quantity;
String? imageUrl;

  Medic({
    this.id,
    this.name,
    this.price,
    this.quantity,
    this.imageUrl,
  });

  Medic.fromJson(Map<String, dynamic>? data) {
    id = data?['id'];
    name = data?['name'];
    price = (data?['price'] as num?)?.toDouble();
    quantity = (data?['quantity'] as num?)?.toDouble();
    imageUrl = data?['image_url'];
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "quantity": quantity,
      "price": price,
      "image_url": imageUrl,
    };
  }
}
