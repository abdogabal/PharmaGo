import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pharmago/core/resources/ColorManger.dart';
import 'package:provider/provider.dart';

import '../../../../../Core/resources/StringsManger.dart';
import '../../../../../Providers/UserProvider.dart';
import '../../../../../core/FirestoreHandler.dart';
import '../../../../PharmacyScreen/widgets/MedicItems.dart';
import '../../Home/widget/Pharmaitems.dart';
import '../widgets/Add_Screen.dart';

class PharmaHome extends StatefulWidget {
  const PharmaHome({super.key});

  @override
  State<PharmaHome> createState() => _PharmaHomeState();
}

class _PharmaHomeState extends State<PharmaHome> {
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
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
            },
            icon: Icon(Icons.search, color: ColorManger.green),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirestoreHandler.getAllMedicStream(
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
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListView.separated(
              itemBuilder: (context, index) => MedicItems(medic[index]),
              separatorBuilder: (context, index) => SizedBox(height: 16),
              itemCount: medic.length,
            ),
          );
        },
      ),
    );
  }
}
