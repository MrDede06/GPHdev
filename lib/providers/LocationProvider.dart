import 'package:flutter/material.dart';

class Location {
  double lattidute;
  double longitude;
  bool isSelected;
  Location({
    this.lattidute,
    this.longitude,
    this.isSelected = false,
  });
}

class LocationProvider with ChangeNotifier {
  Location loc =
      Location(lattidute: 37.785834, longitude: -122.406417, isSelected: false);

  Location get currentLoc {
    return loc;
  }

  void updateLoc(double lat, double long, bool isSelected) {
    loc.lattidute = lat;
    loc.longitude = long;
    loc.isSelected = isSelected;
    notifyListeners();
  }

  void toggleSelected() {
    loc.isSelected = !loc.isSelected;
    notifyListeners();
  }
}
