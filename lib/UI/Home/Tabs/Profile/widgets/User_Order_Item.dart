import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../Models/Order.dart';
import '../../../../../Providers/DetailsProvider.dart';
import '../../../../../core/resources/ColorManger.dart';

class UserOrderItem extends StatefulWidget {
  final Order order;

  UserOrderItem(this.order);

  @override
  State<UserOrderItem> createState() => _UserOrderItemState();
}

class _UserOrderItemState extends State<UserOrderItem> {
  @override
  Widget build(BuildContext context) {
    DetailsProvider detailsProvider = Provider.of<DetailsProvider>(context);
    return InkWell(
      onTap: () {
        //detailsProvider.getPharmaLocation(widget.pharma.latitude!, widget.pharma.longitude!);
        //Navigator.pushNamed(context, PharmacyScreen.routeName,arguments: widget.pharma);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: ColorManger.white,
            ),
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.order.id!,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: ColorManger.black,
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
}
