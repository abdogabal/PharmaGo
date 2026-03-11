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
import '../widgets/MedicItems.dart';

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
        ],
      ),
      body: StreamBuilder(
        stream: SupabaseHandler.getAllMedicStream(pharma.id??''),
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
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListView.separated(
              itemBuilder: (context, index) => MedicItems(filteredMedicines[index]),
              separatorBuilder: (context, index) => SizedBox(height: 16),
              itemCount: filteredMedicines.length,
            ),
          );
        },
      ),
    );;
  }
}
