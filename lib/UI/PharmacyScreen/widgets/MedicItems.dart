import 'package:flutter/material.dart';
import 'package:pharmago/UI/Home/Tabs/Pharma_Home/widgets/Edit_Screen.dart';
import 'package:provider/provider.dart';

import '../../../Models/Medicines.dart';
import '../../../Providers/DetailsProvider.dart';
import '../../../core/resources/ColorManger.dart';

class MedicItems extends StatefulWidget {
final Medic medic;
MedicItems(this.medic);

  @override
  State<MedicItems> createState() => _MedicItemsState();
}

class _MedicItemsState extends State<MedicItems> {

  @override
  Widget build(BuildContext context) {
    DetailsProvider detailsProvider= Provider.of<DetailsProvider>(context);
    return InkWell(
      onTap: (){
        //detailsProvider.getPharmaLocation(widget.pharma.latitude!, widget.pharma.longitude!);
        Navigator.pushNamed(context, EditScreen.routeName,arguments: widget.medic);
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
                    widget.medic.name!,
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
