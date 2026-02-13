import 'package:flutter/material.dart';
import 'package:pharmago/Models/Order.dart';
import 'package:pharmago/core/FirestoreHandler.dart';
import 'package:provider/provider.dart';

import '../../../../../Providers/DetailsProvider.dart';
import '../../../../../core/resources/ColorManger.dart';

class OrderItem extends StatefulWidget {
  final Order order;

  OrderItem(this.order);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
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
                      decoration: widget.order.finish??false?TextDecoration.lineThrough:null,  // Line through the text
                      decorationColor: ColorManger.black,
                      decorationThickness: 2.0,

                    ),
                  ),
                ),
                Checkbox(value: widget.order.finish, onChanged: (value) {
                  FirestoreHandler.checkOrder(value??false, widget.order.id??'');
                },)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
