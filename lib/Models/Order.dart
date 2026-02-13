import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  String? id;
  String? userID;
  String? userName;
  String? pharmaName;
  String? pharmaID;
  String? pharmaNum;
  String? userNum;
  Timestamp? time;
  double? latitude;
  double? longitude;
  double? fullPrice;
  bool? finish;

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
  });

  Order.fromFireStore(Map<String, dynamic>? data) {
    id = data?['ID'];
    userID = data?['UserID'];
    pharmaID = data?['PharmaID'];
    pharmaName = data?['PharmaName'];
    pharmaNum = data?['PharmaNum'];
    userName = data?['UserName'];
    userNum = data?['UserNum'];
    fullPrice = (data?['FullPrice'] as num?)?.toDouble();
    finish = data?['finish']as bool?;
    time = data?['Time'];
    latitude = (data?['latitude'] as num?)?.toDouble();
    longitude = (data?['longitude'] as num?)?.toDouble();

  }

  Map<String, dynamic> toFireStore() {
    return {
      "ID": id,
      "longitude": longitude,
      "latitude": latitude,
      "UserID": userID,
      "UserName": userName,
      "UserNum": userNum,
      "PharmaID": pharmaID,
      "PharmaName": pharmaName,
      "PharmaNum": pharmaNum,
      "FullPrice": fullPrice,
      "finish": finish,
      "Time": time,
    };
  }
}
