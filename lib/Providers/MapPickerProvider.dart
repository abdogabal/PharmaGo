import 'dart:ffi';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../Core/resources/StringsManger.dart';


class MapPickerProvider extends ChangeNotifier {
  Location location = Location();
  GoogleMapController? googleMapController;
  CameraPosition cameraPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  Set<Marker> markers = {};
  LatLng? eventLocation;

  MapPickerProvider() {
    getLocation();
    //   setLocationListener();
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

    markers.add(
      Marker(
        markerId: MarkerId('1'),
        position: LatLng(
          locationData.latitude ?? 0,
          locationData.longitude ?? 0,
        ),
        infoWindow: InfoWindow(title: StringsManger.userLocation.tr()),
      ),
    );
    googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
    notifyListeners();
  }

  //to-do\\
  void changeLocation(LatLng latLang) {
    eventLocation = latLang;
    markers.removeWhere((marker) {return marker.markerId.value != '1';});
    markers.add(
      Marker(
        markerId: MarkerId(''),
        position: latLang,
        infoWindow: InfoWindow(title: StringsManger.pharmaLocations.tr()),
      ),
    );
  }

  geo.Placemark? placeMark;

  savePlaceMark(geo.Placemark userPlaceMark) {
    placeMark = userPlaceMark;
    notifyListeners();
  }

}
