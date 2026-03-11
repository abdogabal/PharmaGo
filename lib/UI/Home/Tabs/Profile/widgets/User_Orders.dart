import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../Core/resources/StringsManger.dart';
import '../../../../../Providers/UserProvider.dart';
import '../../../../../core/SupabaseHandler.dart';
import 'User_Order_Item.dart';

class UserOrders extends StatefulWidget {
  static const String routeName = 'UserOrder';
  const UserOrders({super.key});

  @override
  State<UserOrders> createState() => _UserOrdersState();
}

class _UserOrdersState extends State<UserOrders> {
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "orders".tr(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: StreamBuilder(
        stream: SupabaseHandler.getUserOrdersStream(userProvider.myUser?.id??''),
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
                  "There are no orders".tr(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListView.separated(
              itemBuilder: (context, index) => UserOrderItem(order[index]),
              separatorBuilder: (context, index) => SizedBox(height: 16),
              itemCount: order.length,
            ),
          );
        },
      ),
    );
  }
}
