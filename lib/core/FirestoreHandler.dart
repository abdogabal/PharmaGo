import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/User.dart';

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

}
