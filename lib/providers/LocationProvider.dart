import 'package:flutter/material.dart';

class Location {
  double lattidute;
  double longitude;
  double lattiduteDest;
  double longitudeDest;
  bool isSelected;
  String sourceAddr;
  String destinationAddr;
  Location(
      {this.lattidute,
      this.longitude,
      this.lattiduteDest,
      this.longitudeDest,
      this.isSelected = false,
      this.sourceAddr,
      this.destinationAddr});
}

class LocationProvider with ChangeNotifier {
  Location loc = Location(
      lattidute: 37.785834,
      longitude: -122.406417,
      lattiduteDest: 51.5266,
      longitudeDest: -0.0798,
      isSelected: false,
      sourceAddr: "",
      destinationAddr: "");

  Location get currentLoc {
    return loc;
  }

  void updateLocSource(double lat, double long, String addr) {
    loc.lattidute = lat;
    loc.longitude = long;
    loc.sourceAddr = addr;
    notifyListeners();
  }

  void updateLocDest(double lat, double long, String addr) {
    loc.lattiduteDest = lat;
    loc.longitudeDest = long;
    loc.destinationAddr = addr;
    notifyListeners();
  }

  void updateSourceAddr(String addr) {
    loc.sourceAddr = addr;
    notifyListeners();
  }

  void updateDestAddr(String addr) {
    loc.destinationAddr = addr;
    notifyListeners();
  }

  void toggleSelected() {
    loc.isSelected = !loc.isSelected;
    notifyListeners();
  }
}
