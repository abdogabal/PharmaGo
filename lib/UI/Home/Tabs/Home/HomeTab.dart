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
import '../../../../Providers/CartProvider.dart';
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
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.document_scanner, color: Colors.teal),
            tooltip: "Scan Prescription",
            onPressed: () => Navigator.pushNamed(context, "scan_prescription"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 1. Search Bar
            TextField(
              controller: _searchController,
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
                  builder: (context, pharmaSnapshot) {
                    if (pharmaSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var pharmacies = pharmaSnapshot.data ?? [];
                    
                    if (isOwner) {
                      pharmacies = pharmacies.where((p) => p.id == ownerPharmaId).toList();
                    }

                    return StreamBuilder<List<Medic>>(
                      stream: SupabaseHandler.getAllMedicinesStream(),
                      builder: (context, medicSnapshot) {
                        if (medicSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        var allMedicines = medicSnapshot.data ?? [];

                        if (searchQuery.isNotEmpty) {
                          var pharmaMatchIds = pharmacies
                              .where((p) => p.title?.toLowerCase().contains(searchQuery) ?? false)
                              .map((p) => p.id)
                              .toSet();
                          
                          var medicMatchPharmaIds = allMedicines
                              .where((m) {
                                final nameMatch = m.name?.toLowerCase().contains(searchQuery) ?? false;
                                final ingredientMatch = m.activeIngredient?.toLowerCase().contains(searchQuery) ?? false;
                                return nameMatch || ingredientMatch;
                              })
                              .map((m) => m.pharmaId)
                              .whereType<String>()
                              .toSet();

                          var allMatchingIds = pharmaMatchIds.union(medicMatchPharmaIds);

                          pharmacies = pharmacies.where((p) => allMatchingIds.contains(p.id)).toList();
                        }
                        
                        if (pharmacies.isEmpty) {
                          return Center(child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Text("noPharma".tr()),
                          ));
                        }
                        return Column(
                          children: pharmacies.map((pharma) => _buildPharmacyCardVertical(context, pharma)).toList(),
                        );
                      }
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
        final cart = Provider.of<CartProvider>(context, listen: false);
        if (cart.currentPharmaId != null && cart.currentPharmaId != pharma.id && cart.items.isNotEmpty) {
          cart.clearCart();
        }
        cart.currentPharmaId = pharma.id;

        Navigator.pushNamed(context, PharmacyScreen.routeName, arguments: pharma);
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (pharma.imageUrl != null && pharma.imageUrl!.isNotEmpty)
              Image.network(
                pharma.imageUrl!,
                height: 140,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              )
            else
              _buildPlaceholder(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
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
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 140,
      color: Colors.teal.withOpacity(0.1),
      child: const Center(
        child: Icon(Icons.local_pharmacy, color: Colors.teal, size: 50),
      ),
    );
  }

  Future<void> _pickAndUploadPrescription(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    
    // Show top sheet to choose source
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.teal),
                title: const Text('Photo Library'),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.teal),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return; // User canceled inside the modal

    final XFile? image = await picker.pickImage(source: source);
    
    if (image == null) return; // User canceled image picker
    
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
      // Use Hugging Face Space API
      var uri = Uri.parse('https://eyadsakr11-trocr-prescription-reader.hf.space/predict');
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer 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';
      
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
              content: SizedBox(
                width: double.maxFinite,
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         const Text("The AI Model found these likely medicines:"),
                         const SizedBox(height: 10),
                         ...matches.map((m) {
                           String name = m;
                           String activeIng = "";
                           if (m.contains("(Active: ")) {
                             var parts = m.split("(Active: ");
                             name = parts[0].trim();
                             var rest = parts[1];
                             var ingParts = rest.split(")");
                             activeIng = ingParts[0].trim();
                           } else if (m.contains(" ->")) {
                             var parts = m.split(" ->");
                             name = parts[0].trim();
                           }
                           
                           return Padding(
                             padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text("• $m", style: const TextStyle(fontWeight: FontWeight.bold)),
                                 const SizedBox(height: 4),
                                 Wrap(
                                   spacing: 8.0,
                                   runSpacing: 4.0,
                                   children: [
                                     TextButton.icon(
                                       icon: const Icon(Icons.search, size: 16),
                                       label: Text(name),
                                       style: TextButton.styleFrom(
                                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                         minimumSize: Size.zero,
                                         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                       ),
                                       onPressed: () {
                                         setState(() {
                                           searchQuery = name.toLowerCase();
                                           _searchController.text = name;
                                         });
                                         Navigator.pop(c);
                                       },
                                     ),
                                     if (activeIng.isNotEmpty && activeIng != "Unknown")
                                       TextButton.icon(
                                         icon: const Icon(Icons.science, size: 16),
                                         label: Text(activeIng),
                                         style: TextButton.styleFrom(
                                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                           minimumSize: Size.zero,
                                           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                         ),
                                         onPressed: () {
                                           setState(() {
                                             searchQuery = activeIng.toLowerCase();
                                             _searchController.text = activeIng;
                                           });
                                           Navigator.pop(c);
                                         },
                                       ),
                                   ],
                                 ),
                               ],
                             ),
                           );
                         }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
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