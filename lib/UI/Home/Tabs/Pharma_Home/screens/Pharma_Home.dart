import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pharmago/core/resources/ColorManger.dart';
import 'package:provider/provider.dart';

import '../../../../../Core/resources/StringsManger.dart';
import '../../../../../Providers/UserProvider.dart';
import '../../../../../core/SupabaseHandler.dart';
import '../../../../PharmacyScreen/widgets/MedicItems.dart';
import '../../Home/widget/Pharmaitems.dart';
import '../widgets/Add_Screen.dart';

class PharmaHome extends StatefulWidget {
  const PharmaHome({super.key});

  @override
  State<PharmaHome> createState() => _PharmaHomeState();
}

class _PharmaHomeState extends State<PharmaHome> {
  String searchQuery = '';
  bool isSearching = false;
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: isSearching
            ? TextField(
          onChanged: (value) {
            setState(() {
              searchQuery = value.toLowerCase();  // Update query (case-insensitive)
            });
          },
          decoration: InputDecoration(
            hintText: StringsManger.searchMedic.tr(),  // Localize if needed
            border: InputBorder.none,
            hintStyle: TextStyle(color: ColorManger.green),
          ),
          style: TextStyle(color: ColorManger.green),
          autofocus: true,  // Auto-focus for better UX
        )
            : Text(
          StringsManger.pharmacies.tr(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AddScreen.routeName);
            },
            icon: Icon(Icons.add, color: ColorManger.green),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchQuery = '';
                }
              });
            },
            icon: isSearching
                ? Icon(Icons.close, color: ColorManger.green)
                : Icon(Icons.search, color: ColorManger.green),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: SupabaseHandler.getAllMedicStream(
          userProvider.myUser?.pharma ?? '',
        ),
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
                StringsManger.noPharma,
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
    );
  }
}
