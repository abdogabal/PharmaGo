import 'dart:ffi';

class User {
  String? id;
  String? name;
  String? email;
  String? number;
  bool? pharmacy;
  String? pharma;

  User({this.name, this.email, this.id, this.number,this.pharmacy,this.pharma});

  User.fromFireStore(Map<String, dynamic>? data) {
    id = data?["id"];
    name = data?["name"];
    email = data?["email"];
    number = data?["number"];
    pharmacy = data?['Pharmacy'] as bool?;
    pharma = data?["pharma"];

  }

  Map<String, dynamic> toFireStore() {

    return {
      "id":id,
      "name":name,
      "email":email,
      "number":number,
      "Pharmacy":pharmacy,
      "pharma":pharma
    };
  }
}
