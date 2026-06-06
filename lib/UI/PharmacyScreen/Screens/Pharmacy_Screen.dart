import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Core/resources/StringsManger.dart';
import '../../../Models/Pharmacies.dart';
import '../../../Providers/DetailsProvider.dart';
import '../../../Providers/UserProvider.dart';
import '../../../core/SupabaseHandler.dart';
import '../../../core/resources/ColorManger.dart';
import '../../Home/Tabs/Home/widget/Pharmaitems.dart';
import '../../../../Models/User.dart' as myUser;
import '../../../Providers/CartProvider.dart';
import '../../Cart/CartScreen.dart';
import '../../Home/Tabs/Pharma_Home/widgets/Add_Screen.dart';
import '../widgets/MedicItems.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../Models/Order.dart' as pharmaOrder;
import '../../../Providers/MapPickerProvider.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});
  static const String routeName = 'PharmaScreen';
  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  String searchQuery = '';
  bool isSearching = false;
late Pharma pharma;
  @override
  Widget build(BuildContext context) {
    UserProvider provider = Provider.of<UserProvider>(context);
    DetailsProvider detailsProvider = Provider.of<DetailsProvider>(context);
    pharma = ModalRoute.of(context)!.settings.arguments as Pharma;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:
        isSearching
            ? TextField(
          onChanged: (value) {
            setState(() {
              searchQuery =
                  value
                      .toLowerCase(); // Update query (case-insensitive)
            });
          },
          decoration: InputDecoration(
            hintText: StringsManger.searchPharma.tr(), // Localize if needed
            border: InputBorder.none,
            hintStyle: TextStyle(color: ColorManger.green),
          ),
          style: TextStyle(color: Colors.black),
          autofocus: true, // Auto-focus for better UX
        )
            : Text(
          StringsManger.pharmacies.tr(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchQuery = '';
                }
              });
            },
            icon:
            isSearching
                ? Icon(Icons.close, color: ColorManger.green)
                : Icon(Icons.search, color: ColorManger.green),
          ),
          Consumer<CartProvider>(
            builder: (context, cart, child) => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, CartScreen.routeName);
                    },
                    icon: Icon(Icons.shopping_cart_outlined, color: ColorManger.green)
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
      body: FutureBuilder<myUser.User?>(
        future: SupabaseHandler.getUser(Supabase.instance.client.auth.currentUser?.id ?? ''),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final isOwner = userSnapshot.data?.pharmacy == true &&
              userSnapshot.data?.pharma == pharma.id;

          return Scaffold(
            floatingActionButton: isOwner 
              ? FloatingActionButton(
                  backgroundColor: ColorManger.green,
                  onPressed: () {
                    Navigator.pushNamed(context, AddScreen.routeName);
                  },
                  child: const Icon(Icons.add, color: Colors.white),
                ) 
              : null,
            body: StreamBuilder(
              stream: SupabaseHandler.getAllMedicStream(pharma.id ?? ''),
              builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Column(
              children: [
                Text(snapshot.error.toString()),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: Text(StringsManger.wrong),
                ),
              ],
            );
          }
          var medic = snapshot.data ?? [];
          if (medic.isEmpty) {
            return Center(
              child: Text(
                StringsManger.noPharma.tr(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          }
          final filteredMedicines = medic.where((m) {
            final name = m.name?.toLowerCase() ?? '';
            final ingredient = m.activeIngredient?.toLowerCase() ?? '';
            return name.contains(searchQuery) || ingredient.contains(searchQuery);
          }).toList();

          if (filteredMedicines.isEmpty && searchQuery.isNotEmpty) {
            return Center(
              child: Text(
                StringsManger.noMedic.tr(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPharmacyHeader(),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) => MedicItems(filteredMedicines[index], isOwner: isOwner, pharmaId: pharma.id),
                    itemCount: filteredMedicines.length,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
     }
      ),
    );
  }

  Widget _buildPharmacyHeader() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (pharma.imageUrl != null && pharma.imageUrl!.isNotEmpty)
            Image.network(
              pharma.imageUrl!,
              height: 200,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (pharma.imageUrl == null || pharma.imageUrl!.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(right: 15),
                        decoration: BoxDecoration(
                          color: ColorManger.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.local_pharmacy, color: ColorManger.green, size: 30),
                      ),
                    Expanded(
                      child: Text(
                        pharma.title ?? 'Pharmacy',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Divider(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.phone, color: Colors.grey.shade600, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      pharma.phone ?? 'No phone number available',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                if (pharma.latitude != null && pharma.longitude != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${pharma.latitude},${pharma.longitude}');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.map, size: 18),
                      label: const Text('View Location on Map'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorManger.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _pickAndUploadDirectPrescription(context),
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: const Text('Direct Prescription Upload'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadDirectPrescription(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    
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
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.teal),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final XFile? image = await picker.pickImage(source: source);
    if (image == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext c) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      File imageFile = File(image.path);
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${pharma.id}.jpg';
      String imageUrl = await SupabaseHandler.uploadPrescriptionImage(imageFile, fileName);

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final mapProvider = Provider.of<MapPickerProvider>(context, listen: false);
      await mapProvider.getLocation();
      
      pharmaOrder.Order newOrder = pharmaOrder.Order(
        userID: userProvider.myUser?.id,
        userName: userProvider.myUser?.name,
        userNum: userProvider.myUser?.number,
        pharmaID: pharma.id,
        pharmaName: pharma.title,
        pharmaNum: pharma.phone,
        fullPrice: 0.0,
        finish: false,
        time: DateTime.now(),
        prescriptionUrl: imageUrl,
        isPrescription: true,
        latitude: mapProvider.cameraPosition.target.latitude,
        longitude: mapProvider.cameraPosition.target.longitude,
      );

      await SupabaseHandler.addOrder(newOrder);

      Navigator.pop(context); // Close loading

      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Prescription sent to pharmacy directly!')),
      );

    } catch (e) {
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Failed to upload prescription: $e')),
      );
    }
  }
}

