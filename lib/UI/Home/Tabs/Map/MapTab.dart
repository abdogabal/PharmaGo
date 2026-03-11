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
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: ColorManger.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(Icons.location_on, color: ColorManger.green, size: 30),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pharma.title ?? '',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                                      const SizedBox(width: 4),
                                      Text(
                                        pharma.phone ?? 'No phone',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorManger.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                PharmacyScreen.routeName,
                                arguments: pharma,
                              );
                            },
                            icon: const Icon(Icons.storefront, size: 20),
                            label: Text(
                              StringsManger.pharmacies.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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
