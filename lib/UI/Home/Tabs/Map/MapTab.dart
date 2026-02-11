import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../Core/resources/StringsManger.dart';
import '../../../../Providers/MapsProvider.dart';
import '../../../../core/FirestoreHandler.dart';
import '../../../../core/resources/ColorManger.dart';

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
        alignment:Alignment.bottomCenter,
        children: [
          Column(
            children: [
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: provider.cameraPosition,
                  onMapCreated: (controller) {
                    provider.googleMapController = controller;
                  },
                  mapType: MapType.normal,
                  markers: provider.markers,
                ),
              ),
            ],
          ),
          /*StreamBuilder(
            stream: FirestoreHandler.getAllEventsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Column(
                  children: [
                    Text(snapshot.error.toString()),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text(StringsManger.tryAgain),
                    ),
                  ],
                );
              }
              var events = snapshot.data ?? [];
              if (events.isEmpty) {
                return Center(
                  child: Text(
                    StringsManger.noEvent,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }
              return Container(
                height: 100,
                margin: EdgeInsets.symmetric(horizontal: 16.0,vertical: 32),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) =>MapEventItems(events[index]),
                  separatorBuilder: (context, index) => SizedBox(width: 10),
                  itemCount: events.length,
                ),
              );
            },
          ),*/
        ],
      ),
    );
  }
}
