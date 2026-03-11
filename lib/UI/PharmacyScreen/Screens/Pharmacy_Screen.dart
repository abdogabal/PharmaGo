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
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorManger.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.local_pharmacy, color: ColorManger.green, size: 30),
              ),
              const SizedBox(width: 15),
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
          if (pharma.latitude != null && pharma.longitude != null)
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
        ],
      ),
    );
  }
}
