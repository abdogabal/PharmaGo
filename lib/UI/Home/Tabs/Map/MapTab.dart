import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmago/UI/PharmacyScreen/Screens/Pharmacy_Screen.dart';
import 'package:provider/provider.dart';

import '../../../../Core/resources/StringsManger.dart';
import '../../../../Providers/MapsProvider.dart';
import '../../../../core/SupabaseHandler.dart';
import '../../../../core/resources/ColorManger.dart';
import '../Home/widget/Pharmaitems.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  @override
  Widget build(BuildContext context) {
    MapsProvider provider = Provider.of<MapsProvider>(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorManger.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Icon(
          Icons.gps_fixed,
          color: Theme.of(context).colorScheme.onTertiary,
        ),
        onPressed: () {
          provider.getLocation();
        },
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: provider.cameraPosition,
            onMapCreated: (controller) {
              provider.googleMapController = controller;
              provider.loadPharmaciesOnMap();
            },
            mapType: MapType.normal,
            markers: provider.markers,
            onTap: (LatLng position) {
              provider.clearSelectedPharma();
            },
          ),
          
          Consumer<MapsProvider>(
            builder: (context, provider, _) {
              if (provider.selectedPharma == null) return SizedBox();

              final pharma = provider.selectedPharma!;

              return Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pharma.title ?? '',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(pharma.phone ?? ''),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              PharmacyScreen.routeName,
                              arguments: pharma,
                            );
                          },
                          child: Text(StringsManger.pharmacies.tr()),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
