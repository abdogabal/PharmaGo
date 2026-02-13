import 'package:flutter/material.dart';
import 'package:pharmago/Models/Pharmacies.dart';
import 'package:pharmago/core/resources/ColorManger.dart';
import 'package:provider/provider.dart';

import '../../../../../Providers/DetailsProvider.dart';
import '../../../../PharmacyScreen/Screens/Pharmacy_Screen.dart';

class PharmaItems extends StatefulWidget {
  final Pharma pharma;
  PharmaItems(this.pharma);

  @override
  State<PharmaItems> createState() => _PharmaItemsState();
}

class _PharmaItemsState extends State<PharmaItems> {

  @override
  Widget build(BuildContext context) {
    DetailsProvider detailsProvider= Provider.of<DetailsProvider>(context);
    return InkWell(
      onTap: (){
        //detailsProvider.getPharmaLocation(widget.pharma.latitude!, widget.pharma.longitude!);
        Navigator.pushNamed(context, PharmacyScreen.routeName,arguments: widget.pharma);
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
                    widget.pharma.title!,
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
