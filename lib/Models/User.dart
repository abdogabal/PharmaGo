class User {
  String? id;
  String? name;
  String? email;
  String? number;

  User({this.name, this.email, this.id, this.number});

  User.fromFireStore(Map<String, dynamic>? data) {
    id = data?["id"];
    name = data?["name"];
    email = data?["email"];
    number = data?["number"];
  }

  Map<String, dynamic> toFireStore() {

    return {
      "id":id,
      "name":name,
      "email":email,
      "number":number,
    };
  }
}
