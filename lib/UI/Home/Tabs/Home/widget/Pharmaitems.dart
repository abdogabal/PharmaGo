import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pharmago/Models/Pharmacies.dart';
import 'package:pharmago/core/resources/AssetsManger.dart';
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
  Placemark? placeMark;

  @override
  Widget build(BuildContext context) {
    DetailsProvider detailsProvider = Provider.of<DetailsProvider>(context);
    return InkWell(
      onTap: () {
        //detailsProvider.getPharmaLocation(widget.pharma.latitude!, widget.pharma.longitude!);
        Navigator.pushNamed(
          context,
          PharmacyScreen.routeName,
          arguments: widget.pharma,
        );
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.primary),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 8,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SvgPicture.asset(
                AssetsManger.logo,
                colorFilter: ColorFilter.mode(
                  ColorManger.green,
                  BlendMode.srcIn,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width,
                  ),
                  child: Text(
                    widget.pharma.title ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge,
                    textAlign: TextAlign.start,
                  ),
                ),
                Row(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      AssetsManger.map,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onSecondary,
                        BlendMode.srcIn,
                      ),
                    ),
                    placeMark == null
                        ? Center(
                          child: CircularProgressIndicator(
                            color: ColorManger.white,
                            constraints: BoxConstraints(
                              maxHeight: 15,
                              maxWidth: 15,
                              minHeight: 15,
                              minWidth: 15,
                            ),
                          ),
                        )
                        : Text(
                          '${placeMark?.name} , ${placeMark?.country}',
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                          textAlign: TextAlign.start,
                        ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
