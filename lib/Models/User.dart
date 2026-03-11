

class User {
  String? id;
  String? name;
  String? email;
  String? number;
  bool? pharmacy;
  String? pharma;

  User({this.name, this.email, this.id, this.number,this.pharmacy = false,this.pharma});

  User.fromJson(Map<String, dynamic>? data) {
    id = data?["id"];
    name = data?["name"];
    email = data?["email"];
    number = data?["number"];
    pharmacy = data?['pharmacy'] as bool?;
    pharma = data?["pharma_id"];

  }

  Map<String, dynamic> toJson() {

    return {
      "id":id,
      "name":name,
      "email":email,
      "number":number,
      "pharmacy": pharmacy,
      "pharma_id": pharma
    };
  }
}
