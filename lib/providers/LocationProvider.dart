import 'package:flutter/material.dart';

class Location {
  double lattidute;
  double longitude;
  double lattiduteDest;
  double longitudeDest;
  bool isSelected;
  Location({
    this.lattidute,
    this.longitude,
    this.lattiduteDest,
    this.longitudeDest,
    this.isSelected = false,
  });
}

class LocationProvider with ChangeNotifier {
  Location loc = Location(
    lattidute: 37.785834,
    longitude: -122.406417,
    lattiduteDest: 51.5266,
    longitudeDest: -0.0798,
    isSelected: false,
  );

  Location get currentLoc {
    return loc;
  }

  void updateLocSource(double lat, double long) {
    loc.lattidute = lat;
    loc.longitude = long;
    notifyListeners();
  }

  void updateLocDest(double lat, double long) {
    loc.lattiduteDest = lat;
    loc.longitudeDest = long;
    notifyListeners();
  }

  void toggleSelected() {
    loc.isSelected = !loc.isSelected;
    notifyListeners();
  }
}
