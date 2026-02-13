import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pharmago/Models/Medicines.dart';
import 'package:pharmago/Models/Order.dart' as myOrder;
import 'package:pharmago/Providers/UserProvider.dart';
import 'package:pharmago/UI/Home/Tabs/Home/widget/Pharmaitems.dart';
import 'package:provider/provider.dart';

import '../../../../Core/resources/StringsManger.dart';
import '../../../../Providers/MapsProvider.dart';
import '../../../../core/FirestoreHandler.dart';
import '../../../../core/resources/ColorManger.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {

  String searchQuery = '';
  bool isSearching = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final user = context.read<UserProvider>().myUser;

      if (user?.pharmacy == false) {
        context.read<MapsProvider>().loadPharmaciesOnMap();
      }

      context.read<MapsProvider>().getLocation();
    });
  }


  @override
  Widget build(BuildContext context) {
    MapsProvider provider = Provider.of<MapsProvider>(context);
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
                      .toLowerCase();
            });
          },
          decoration: InputDecoration(
            hintText:
            StringsManger.searchPharma.tr(),
            border: InputBorder.none,
            hintStyle: TextStyle(color: ColorManger.green),
          ),
          style: TextStyle(color: ColorManger.black),
          autofocus: true, // Auto-focus for better UX
        )
            : Text(
          StringsManger.pharmacies.tr(),
          style: Theme
              .of(context)
              .textTheme
              .titleMedium,
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
        stream: FirestoreHandler.getAllPharmaStream(),
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
          var pharma = snapshot.data ?? [];
          if (pharma.isEmpty) {
            return Center(
              child: Text(
                StringsManger.noPharma,
                style: Theme
                    .of(context)
                    .textTheme
                    .bodySmall,
              ),
            );
          }
          final filteredPharmacies =
          pharma.where((m) {
            final name = m.title?.toLowerCase() ?? '';
            return name.contains(searchQuery);
          }).toList();

          if (filteredPharmacies.isEmpty && searchQuery.isNotEmpty) {
            return Center(
              child: Text(
                StringsManger.noPharma.tr(),
                style: Theme
                    .of(context)
                    .textTheme
                    .bodySmall,
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListView.separated(
              itemBuilder:
                  (context, index) => PharmaItems(filteredPharmacies[index]),
              separatorBuilder: (context, index) => SizedBox(height: 16),
              itemCount: filteredPharmacies.length,
            ),
          );
        },
      ),
    );
  }
}
