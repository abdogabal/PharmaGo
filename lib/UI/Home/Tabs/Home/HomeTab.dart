import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../../Models/Medicines.dart';
import '../../../../core/SupabaseHandler.dart';
import '../../../../Providers/CartProvider.dart';
import '../../../Cart/CartScreen.dart';

class HomeTap extends StatelessWidget {
  static const String routeName = "home";
  const HomeTap({super.key});

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
          Consumer<CartProvider>(
            builder: (context, cart, child) => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, CartScreen.routeName);
                    },
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black)
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${cart.itemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
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
              decoration: InputDecoration(
                hintText: "searchMedic".tr(),
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

            /// 3. Popular Product Section
            _buildSectionHeader("popularProduct".tr()),
            const SizedBox(height: 15),
            StreamBuilder<List<Medic>>(
              stream: SupabaseHandler.getAllMedicGroupStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                var medicines = snapshot.data ?? [];
                if (medicines.isEmpty) {
                  return Center(child: Text("noMedic".tr()));
                }
                return Column(
                  children: [
                    SizedBox(
                      height: 230,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: medicines.length > 5 ? 5 : medicines.length,
                        itemBuilder: (context, index) => _buildProductCard(context, medicines[index]),
                      ),
                    ),
                    const SizedBox(height: 30),
                    /// 4. Product On Sale Section
                    _buildSectionHeader("productOnSale".tr()),
                    const SizedBox(height: 15),
                    ...medicines.take(3).map((medic) => _buildProductCardVertical(context, medic)).toList(),
                    const SizedBox(height: 20),
                  ],
                );
              },
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

  Widget _buildProductCard(BuildContext context, Medic medic) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 15, bottom: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Icon(Icons.medication, size: 60, color: Colors.teal.shade200),
            ),
          ),
          const SizedBox(height: 10),
          Text(medic.name ?? "",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("\$${medic.price ?? 0}",
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.teal)),
              InkWell(
                onTap: () {
                  Provider.of<CartProvider>(context, listen: false).addItem(medic);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${medic.name} added to cart!'),
                      duration: const Duration(seconds: 1),
                      backgroundColor: Colors.teal,
                    ),
                  );
                },
                child: const Icon(Icons.add_box, color: Colors.teal, size: 28),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildProductCardVertical(BuildContext context, Medic medic) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.medical_services, color: Colors.teal),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(medic.name ?? "",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text("\$${medic.price ?? 0}",
                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              Provider.of<CartProvider>(context, listen: false).addItem(medic);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${medic.name} added to cart!'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: Colors.teal,
                ),
              );
            },
            child: const Icon(Icons.add_circle, color: Colors.teal, size: 32),
          ),
        ],
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
      // Use the actual Wi-Fi IP address so the physical phone can reach the computer
      var uri = Uri.parse('http://192.168.1.13:8000/predict');
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
        String recognizedText = jsonResponse['text'];
        
        // Show result
        showDialog(
          context: context,
          builder: (BuildContext c) {
            return AlertDialog(
              title: const Text("Prescription Read Successfully!"),
              content: Text("The AI Model Read:\n\n$recognizedText"),
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