import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../Core/resources/StringsManger.dart';
import '../Models/Pharmacies.dart';

class DetailsProvider extends ChangeNotifier{

  Placemark? placeMark;
  Pharma? pharma;

  Set<Marker> markers = {};
  getPharmaLocation(double latitude,double longitude) async {
    List<Placemark> placeMarks = await placemarkFromCoordinates(
      latitude ?? 0,
      longitude ?? 0,
    );
    placeMark = placeMarks.first;
    notifyListeners();
  }
  getPharma(Pharma eventData){
    pharma=eventData;
  }

}