import 'package:cloud_firestore/cloud_firestore.dart';

class Pharma {
  String? id;
  String? title;
  String? phone;
  double? latitude;
  double? longitude;

  Pharma({
    this.id,
    this.title,
    this.longitude,
    this.latitude,
    this.phone
  });

  Pharma.fromFireStore(Map<String, dynamic>? data) {
    id = data?['id'];
    title = data?['title'];
    phone = data?['phone'];
    latitude = (data?['latitude'] as num?)?.toDouble();
    longitude = (data?['longitude'] as num?)?.toDouble();
  }

  Map<String, dynamic> toFireStore() {
    return {
      "id": id,
      "title": title,
      "longitude": longitude,
      "latitude": latitude,
      "phone": phone,
    };
  }
}
