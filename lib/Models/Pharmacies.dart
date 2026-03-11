

class Pharma {
  String? id;
  String? title;
  String? phone;
  double? latitude;
  double? longitude;
  String? imageUrl;

  Pharma({
    this.id,
    this.title,
    this.longitude,
    this.latitude,
    this.phone,
    this.imageUrl,
  });

  Pharma.fromJson(Map<String, dynamic>? data) {
    id = data?['id'];
    title = data?['title'];
    phone = data?['phone'];
    latitude = (data?['latitude'] as num?)?.toDouble();
    longitude = (data?['longitude'] as num?)?.toDouble();
    imageUrl = data?['image_url'];
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "longitude": longitude,
      "latitude": latitude,
      "phone": phone,
      "image_url": imageUrl,
    };
  }
}
