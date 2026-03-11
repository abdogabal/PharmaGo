

class Medic {
  String? id;
  String? name;
double? price;
  double? quantity;
  String? imageUrl;
  String? pharmaId;
  String? activeIngredient;

  Medic({
    this.id,
    this.name,
    this.price,
    this.quantity,
    this.imageUrl,
    this.pharmaId,
    this.activeIngredient,
  });

  Medic.fromJson(Map<String, dynamic>? data) {
    id = data?['id'];
    name = data?['name'];
    price = (data?['price'] as num?)?.toDouble();
    quantity = (data?['quantity'] as num?)?.toDouble();
    imageUrl = data?['image_url'];
    pharmaId = data?['pharmacy_id'];
    activeIngredient = data?['active_ingredient'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      "name": name,
      "quantity": quantity,
      "price": price,
      "pharmacy_id": pharmaId,
      "active_ingredient": activeIngredient,
    };
    if (id != null) {
      map["id"] = id;
    }
    // Omit image_url since the column doesn't exist in Supabase
    return map;
  }
}
