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
            return name.contains(searchQuery);
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
            child: ListView.builder(
              itemBuilder: (context, index) => MedicItems(filteredMedicines[index], isOwner: isOwner),
              itemCount: filteredMedicines.length,
            ),
          );
        },
      ),
    );
     }
      ),
    );
  }
}
