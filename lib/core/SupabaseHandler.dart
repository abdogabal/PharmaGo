import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Models/Pharmacies.dart';
import '../Models/Medicines.dart';
import '../Models/User.dart' as myUser;
import '../Models/Order.dart' as pharmaOrder;

class SupabaseHandler {
  static final supabase = Supabase.instance.client;

  // --- Users ---
  static Future<void> addUser(myUser.User user) async {
    await supabase.from('users').upsert(user.toJson());
  }

  static Future<myUser.User?> getUser(String userID) async {
    final data = await supabase.from('users').select().eq('id', userID).maybeSingle();
    if (data == null) return null;
    return myUser.User.fromJson(data);
  }

  // --- Pharmacies ---
  static Stream<List<Pharma>> getAllPharmaciesStream() {
    return supabase.from('pharmacies').stream(primaryKey: ['id']).map((maps) {
      return maps.map((map) => Pharma.fromJson(map)).toList();
    });
  }

  // --- Medicines ---
  static Stream<List<Medic>> getAllMedicinesStream() {
    return supabase.from('medicines').stream(primaryKey: ['id']).map((maps) {
      return maps.map((map) => Medic.fromJson(map)).toList();
    });
  }

  static Stream<List<Medic>> getAllMedicStream(String pharmacyId) {
    return supabase.from('medicines').stream(primaryKey: ['id']).eq('pharmacy_id', pharmacyId).map((maps) {
      return maps.map((map) => Medic.fromJson(map)).toList();
    });
  }

  static Stream<List<Medic>> getAllMedicGroupStream() {
    return getAllMedicinesStream();
  }

  static Future<void> addMedic(Medic medic, String pharmacyId) async {
    final data = medic.toJson();
    data['pharmacy_id'] = pharmacyId;
    await supabase.from('medicines').insert(data);
  }

  static Future<void> editMedic(Medic medic, String pharmacyId) async {
    final data = medic.toJson();
    data['pharmacy_id'] = pharmacyId;
    await supabase.from('medicines').update(data).eq('id', medic.id ?? '');
  }

  // --- Orders ---
  static Future<void> addOrder(pharmaOrder.Order order) async {
    final insertData = order.toJson();
    final data = await supabase.from('orders').insert(insertData).select().single();
    order.id = data['id'];
  }

  static Stream<List<pharmaOrder.Order>> getUserOrdersStream(String userID) {
    return supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('user_id', userID)
        .map((maps) => maps.map((map) => pharmaOrder.Order.fromJson(map)).toList());
  }

  static Stream<List<pharmaOrder.Order>> getPharmaOrderStream(String pharmaID) {
    return supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('pharma_id', pharmaID)
        .map((maps) => maps.map((map) => pharmaOrder.Order.fromJson(map)).toList());
  }

  // --- Order Medicines ---
  static Future<void> addMedicToOrder(Medic medic, String orderId) async {
    final itemData = {
      'order_id': orderId,
      'name': medic.name,
      'price': medic.price,
      'quantity': medic.quantity,
    };
    
    // Only add medicine_id if it's a valid non-empty string, to avoid Postgres UUID parse errors
    if (medic.id != null && medic.id!.isNotEmpty) {
      itemData['medicine_id'] = medic.id;
    }

    await supabase.from('order_items').insert(itemData);
  }

  static Future<List<Medic>> getMedicinesForOrder(String orderId) async {
    if (orderId.isEmpty || orderId.length < 32 || orderId == 'null') {
      return [];
    }
    final data = await supabase.from('order_items').select().eq('order_id', orderId);
    return data.map((map) {
      return Medic(
        id: map['medicine_id'],
        name: map['name'],
        price: (map['price'] as num?)?.toDouble(),
        quantity: (map['quantity'] as num?)?.toDouble(),
      );
    }).toList();
  }

  static Future<void> makeOrder(
    pharmaOrder.Order order,
    List<Medic> medicines,
  ) async {
    // Add Order First to generate the ID
    await addOrder(order);
    
    // Then add order items
    for (int i = 0; i < medicines.length; i++) {
      await addMedicToOrder(medicines[i], order.id ?? '');
    }
  }

  static Future<void> checkOrder(bool finish, String id) async {
    // Stock deduction is now handled purely by the Supabase Database Trigger
    await supabase.from('orders').update({'finish': finish}).eq('id', id);
  }

  static Future<void> refuseOrder(String id) async {
    // Fetch the order to get the prescription URL before deleting
    final orderData = await supabase.from('orders').select('is_prescription, prescription_url').eq('id', id).maybeSingle();

    // Delete the order items first (if no cascade delete)
    await supabase.from('order_items').delete().eq('order_id', id);
    // Then delete the order itself
    await supabase.from('orders').delete().eq('id', id);

    // If it has a prescription image, delete it from storage
    if (orderData != null && orderData['is_prescription'] == true && orderData['prescription_url'] != null) {
      String url = orderData['prescription_url'].toString();
      Uri uri = Uri.parse(url);
      String path = uri.path; 
      String storagePrefix = 'object/public/prescriptions/';
      int prefixIndex = path.indexOf(storagePrefix);
      
      if (prefixIndex != -1) {
        String fileName = path.substring(prefixIndex + storagePrefix.length);
        fileName = Uri.decodeComponent(fileName); // Decode any URL-encoded characters
        
        final List<FileObject> deletedFiles = await supabase.storage.from('prescriptions').remove([fileName]);
        if (deletedFiles.isEmpty) {
          throw Exception("Storage RLS blocked deletion or file not found.");
        }
      }
    }
  }

  static Future<String> uploadPharmacyImage(File imageFile, String fileName) async {
    await supabase.storage.from('prescriptions').upload(fileName, imageFile);
    return supabase.storage.from('prescriptions').getPublicUrl(fileName);
  }

  static Future<String> uploadMedicineImage(File imageFile, String fileName) async {
    await supabase.storage.from('prescriptions').upload(fileName, imageFile);
    return supabase.storage.from('prescriptions').getPublicUrl(fileName);
  }

  static Future<String> uploadPrescriptionImage(File imageFile, String fileName) async {
    await supabase.storage.from('prescriptions').upload(fileName, imageFile);
    return supabase.storage.from('prescriptions').getPublicUrl(fileName); // Supabase returns publicURL of the filename
  }
}
