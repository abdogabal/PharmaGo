import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../../Models/Medicines.dart';
import '../../../../core/SupabaseHandler.dart';
import '../../../../core/SupabaseHandler.dart';
import '../../../../Models/Pharmacies.dart';
import '../../../PharmacyScreen/Screens/Pharmacy_Screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../Models/User.dart' as myUser;
import 'package:string_similarity/string_similarity.dart';
import 'package:flutter/services.dart';

class HomeTap extends StatefulWidget {
  static const String routeName = "home";
  const HomeTap({super.key});

  @override
  State<HomeTap> createState() => _HomeTapState();
}

class _HomeTapState extends State<HomeTap> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text("Pharmacy",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        actions: [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 1. Search Bar
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "searchPharma".tr(),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 25),

            /// 2. Prescription Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "orderQuickly".tr(),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1.2
                          ),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: () => _pickAndUploadPrescription(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                            ),
                          ),
                          child: Text("uploadPres".tr()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    flex: 1,
                    child: Icon(Icons.medication_liquid_sharp,
                        size: 70, color: Colors.teal),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            /// 3. Pharmacy Section
            _buildSectionHeader("pharmacies".tr()),
            const SizedBox(height: 15),
            FutureBuilder<myUser.User?>(
              future: SupabaseHandler.getUser(Supabase.instance.client.auth.currentUser?.id ?? ''),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final isOwner = userSnapshot.data?.pharmacy == true && userSnapshot.data?.pharma != null;
                final ownerPharmaId = userSnapshot.data?.pharma;

                return StreamBuilder<List<Pharma>>(
                  stream: SupabaseHandler.getAllPharmaciesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var pharmacies = snapshot.data ?? [];
                    
                    if (isOwner) {
                      pharmacies = pharmacies.where((p) => p.id == ownerPharmaId).toList();
                    }
                    
                    if (searchQuery.isNotEmpty) {
                      pharmacies = pharmacies.where((p) => p.title?.toLowerCase().contains(searchQuery) ?? false).toList();
                    }
                    
                    if (pharmacies.isEmpty) {
                      return Center(child: Text("noPharma".tr()));
                    }
                    return Column(
                      children: pharmacies.map((pharma) => _buildPharmacyCardVertical(context, pharma)).toList(),
                    );
                  },
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: () {},
          child: Text("seeAll".tr(),
              style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildPharmacyCardVertical(BuildContext context, Pharma pharma) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, PharmacyScreen.routeName, arguments: pharma);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_pharmacy, color: Colors.teal, size: 30),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pharma.title ?? "",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 14),
                      const SizedBox(width: 4),
                      Text("4.5", style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadPrescription(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    // Allow user to pick from gallery or camera
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) return; // User canceled
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext c) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      File imageFile = File(image.path);
      // Use the emulator local ip if testing on Android Simulator, or the specific Wi-Fi IP
      // var uri = Uri.parse('http://10.0.2.2:8000/predict'); // Default to emulator localhost
      var uri = Uri.parse('http://192.168.1.8:8000/predict'); // For physical device, uncomment and change
      var request = http.MultipartRequest('POST', uri);
      
      request.files.add(await http.MultipartFile.fromPath(
        'file', 
        imageFile.path,
      ));

      var response = await request.send();
      
      // Close the loading dialog
      Navigator.pop(context);

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseBody);
        
        // The API now returns a list of matches instead of just 'text'
        List<dynamic> matchesDynamic = jsonResponse['matches'] ?? [jsonResponse['text']];
        List<String> matches = matchesDynamic.map((e) => e.toString()).toList();
        
        // Show result
        showDialog(
          context: context,
          builder: (BuildContext c) {
            return AlertDialog(
              title: const Text("Prescription Read Successfully!"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text("The AI Model found these likely medicines:"),
                   const SizedBox(height: 10),
                   ...matches.map((m) => Padding(
                     padding: const EdgeInsets.symmetric(vertical: 4.0),
                     child: Text("• $m", style: const TextStyle(fontWeight: FontWeight.bold)),
                   )).toList(),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text("Search Medicine"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text("Close"),
                )
              ],
            );
          }
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('API Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Failed to connect to AI Server: $e')),
      );
    }
  }
}