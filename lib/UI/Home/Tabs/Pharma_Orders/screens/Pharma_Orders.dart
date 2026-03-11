import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../Core/resources/StringsManger.dart';
import '../../../../../Providers/UserProvider.dart';
import '../../../../../core/SupabaseHandler.dart';
import '../widgets/Order_Item.dart';

class PharmaOrders extends StatefulWidget {
  const PharmaOrders({super.key});

  @override
  State<PharmaOrders> createState() => _PharmaOrdersState();
}

class _PharmaOrdersState extends State<PharmaOrders> {
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
      ),
      body: StreamBuilder(
        stream: SupabaseHandler.getPharmaOrderStream(userProvider.myUser?.pharma??''),
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
          var order = snapshot.data ?? [];
          if (order.isEmpty) {
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
              itemBuilder: (context, index) => OrderItem(order[index]),
              separatorBuilder: (context, index) => SizedBox(height: 16),
              itemCount: order.length,
            ),
          );
        },
      ),
    );
  }
}
