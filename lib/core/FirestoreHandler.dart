import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pharmago/Models/Pharmacies.dart';

import '../Models/Medicines.dart';
import '../Models/User.dart';
import '../Models/Order.dart' as pharmaOrder;

class FirestoreHandler {
  static CollectionReference<User> getUserCollection() {
    var collection = FirebaseFirestore.instance
        .collection("User")
        .withConverter(
          fromFirestore: (snapshot, options) {
            Map<String, dynamic>? data = snapshot.data();
            return User.fromFireStore(data);
          },
          toFirestore: (user, options) {
            return user.toFireStore();
          },
        );
    return collection;
  }

  static Future<void> addUser(User user) {
    var collection = getUserCollection();
    var document = collection.doc(user.id);
    return document.set(user);
  }

  static Future<User?> getUser(String userID) async {
    var collection = getUserCollection();
    var document = collection.doc(userID);
    var snapshot = await document.get();
    return snapshot.data();
  }

  static CollectionReference<Pharma> getPharmaCollection() {
    var collection = FirebaseFirestore.instance
        .collection("Pharmacies")
        .withConverter(
          fromFirestore: (snapshot, options) {
            Map<String, dynamic>? data = snapshot.data();
            return Pharma.fromFireStore(data);
          },
          toFirestore: (pharma, options) {
            return pharma.toFireStore();
          },
        );
    return collection;
  }

  static Stream<List<Pharma>> getAllPharmaStream() async* {
    var collection = getPharmaCollection();
    var stream = collection.snapshots();
    var pharmaStream = stream.map((snapshot) {
      var document = snapshot.docs;
      var pharmaList = document.map((doc) => doc.data()).toList();
      return pharmaList;
    });
    yield* pharmaStream;
  }

  static CollectionReference<Medic> getMedicCollection(String pharmacy) {
    var collection = FirebaseFirestore.instance
        .collection("Pharmacies")
        .doc(pharmacy)
        .collection('medicines')
        .withConverter(
          fromFirestore: (snapshot, options) {
            Map<String, dynamic>? data = snapshot.data();
            return Medic.fromFireStore(data);
          },
          toFirestore: (medic, options) {
            return medic.toFireStore();
          },
        );
    return collection;
  }

  static Stream<List<Medic>> getAllMedicStream(String pharmacy) async* {
    var collection = getMedicCollection(pharmacy);
    var stream = collection.snapshots();
    var medicStream = stream.map((snapshot) {
      var document = snapshot.docs;
      var medicList = document.map((doc) => doc.data()).toList();
      return medicList;
    });
    yield* medicStream;
  }

  static CollectionReference<pharmaOrder.Order> getPharmaOrderCollection() {
    var collection = FirebaseFirestore.instance
        .collection("Orders")
        .withConverter(
          fromFirestore: (snapshot, options) {
            Map<String, dynamic>? data = snapshot.data();
            return pharmaOrder.Order.fromFireStore(data);
          },
          toFirestore: (order, options) {
            return order.toFireStore();
          },
        );
    return collection;
  }

  static Stream<List<pharmaOrder.Order>> getPharmaOrderStream(
    String pharmaID,
  ) async* {
    var collection = getPharmaOrderCollection().where(
      "PharmaID",
      isEqualTo: pharmaID,
    );
    var stream = collection.snapshots();
    var orderStream = stream.map((snapshot) {
      var document = snapshot.docs;
      var orderList = document.map((doc) => doc.data()).toList();
      return orderList;
    });
    yield* orderStream;
  }

  static Stream<List<pharmaOrder.Order>> getUserOrdersStream(
    String userID,
  ) async* {
    var collection = getPharmaOrderCollection().where(
      "UserID",
      isEqualTo: userID,
    );
    var stream = collection.snapshots();
    var orderStream = stream.map((snapshot) {
      var document = snapshot.docs;
      var orderList = document.map((doc) => doc.data()).toList();
      return orderList;
    });
    yield* orderStream;
  }

  static Future<void> addOrder(pharmaOrder.Order order) {
    var collection = getPharmaOrderCollection();
    var document = collection.doc();
    order.id = document.id;
    return document.set(order);
  }

  static Future<void> addMedic(Medic medic, String pharmacy) {
    var collection = getMedicCollection(pharmacy);
    var document = collection.doc();
    medic.id = document.id;
    return document.set(medic);
  }

  static Future<void> editMedic(Medic medic, String pharmacy) {
    var collection = getMedicCollection(pharmacy);
    var document = collection.doc(medic.id);
    return document.update(({
      "name": medic.name,
      "quantity": medic.quantity,
      "price": medic.price,
    }));
  }
}
