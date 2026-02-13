import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../Models/Pharmacies.dart';

class MapsProvider extends ChangeNotifier {
  Location location = Location();
  late GoogleMapController googleMapController;
  CameraPosition cameraPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  Set<Marker> markers = {};
  Pharma? selectedPharma;

  //MapsProvider() {
  //getLocation();
  //   setLocationListener();
  //}
  Future<void> loadPharmaciesOnMap() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Pharmacies').get();

    markers.removeWhere((m) => m.markerId.value != 'user');

    for (var doc in snapshot.docs) {
      final data = doc.data();

      final lat = (data['latitude'] as num?)?.toDouble();
      final lng = (data['longitude'] as num?)?.toDouble();

      if (lat == null || lng == null) continue;

      final pharma = Pharma.fromFireStore(data);

      markers.add(
        Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: pharma.title),
          onTap: () {
            selectedPharma = pharma;
            notifyListeners();
          },
        ),
      );
    }

    notifyListeners();
  }

  void clearSelectedPharma() {
    selectedPharma = null;
    notifyListeners();
  }
  Future<bool> _getLocationPermission() async {
    PermissionStatus permissionStatus;
    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
    }
    return permissionStatus == PermissionStatus.granted;
  }

  Future<bool> _checkLocationService() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }
    return serviceEnabled;
  }

  Future<void> getLocation() async {
    bool permissionGranted = await _getLocationPermission();
    if (!permissionGranted) {
      return;
    }
    bool serviceEnable = await _checkLocationService();
    if (!serviceEnable) {
      return;
    }
    LocationData locationData = await location.getLocation();
    changeLocationOnMap(locationData);

    notifyListeners();
  }

  changeLocationOnMap(LocationData locationData) {
    cameraPosition = CameraPosition(
      target: LatLng(locationData.latitude ?? 0, locationData.longitude ?? 0),
      zoom: 14.4746,
    );
    markers.removeWhere((m) => m.markerId.value == 'user');

    markers.add(
      Marker(
        markerId: MarkerId('user'),
        position: LatLng(
          locationData.latitude ?? 0,
          locationData.longitude ?? 0,
        ),
        infoWindow: InfoWindow(title: 'User Location'),
      ),
    );

    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
    notifyListeners();
  }

  setLocationListener() {
    location.changeSettings(accuracy: LocationAccuracy.high, interval: 1000);
    location.onLocationChanged.listen((LocationData currentLocation) {
      changeLocationOnMap(currentLocation);
      notifyListeners();
    });
  }

  geo.Placemark? placeMark;

  savePlaceMark(geo.Placemark userPlaceMark) {
    placeMark = userPlaceMark;
    notifyListeners();
  }

  changeCameraPosition(double latitude, double longitude, String title) {
    cameraPosition = CameraPosition(
      target: LatLng(latitude ?? 0, longitude ?? 0),
      zoom: 14.4746,
    );
    markers.add(
      Marker(
        markerId: MarkerId(UniqueKey().toString()),
        position: LatLng(latitude ?? 0, longitude ?? 0),
        infoWindow: InfoWindow(title: title),
      ),
    );
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
    notifyListeners();
  }
}
