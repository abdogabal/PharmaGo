

class Order {
  String? id;
  String? userID;
  String? userName;
  String? pharmaName;
  String? pharmaID;
  String? pharmaNum;
  String? userNum;
  DateTime? time;
  double? latitude;
  double? longitude;
  double? fullPrice;
  bool? finish;
  String? prescriptionImage;

  Order({
    this.id,
    this.userID,
    this.pharmaID,
    this.pharmaName,
    this.pharmaNum,
    this.userName,
    this.userNum,
    this.fullPrice,
    this.finish,
    this.time,
    this.longitude,
    this.latitude,
    this.prescriptionImage,
  });

  Order.fromJson(Map<String, dynamic>? data) {
    id = data?['ID'];
    userID = data?['user_id'];
    pharmaID = data?['pharma_id'];
    pharmaName = data?['pharma_name'];
    pharmaNum = data?['pharma_num'];
    userName = data?['user_name'];
    userNum = data?['user_num'];
    fullPrice = (data?['full_price'] as num?)?.toDouble();
    finish = data?['finish'] as bool?;
    
    // Parse Supabase DateTime string
    if (data?['created_at'] != null) {
      time = DateTime.tryParse(data?['created_at'].toString() ?? '');
    }
    
    latitude = (data?['latitude'] as num?)?.toDouble();
    longitude = (data?['longitude'] as num?)?.toDouble();
    prescriptionImage = data?['prescriptionImage'];
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "longitude": longitude,
      "latitude": latitude,
      "user_id": userID,
      "user_name": userName,
      "user_num": userNum,
      "pharma_id": pharmaID,
      "pharma_name": pharmaName,
      "pharma_num": pharmaNum,
      "full_price": fullPrice,
      "finish": finish,
      "created_at": time?.toIso8601String(),
      "prescriptionImage": prescriptionImage,
    };
  }
}
