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

class Car {
  String name;
  double battery;
  int range;
  int efficieny;
  String connectors;
  int currentBattery;
  Car(
      {this.name,
      this.battery,
      this.range,
      this.efficieny,
      this.connectors,
      this.currentBattery});
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

class CarProvider with ChangeNotifier {
  Car car = Car(
      name: "",
      battery: 0,
      range: 0,
      efficieny: 0,
      connectors: "",
      currentBattery: 0);

  void updateCarProperties(
      String name, int battery, int range, int efficiensy, String connector) {
    car.name = name;
    car.range = range;
    car.efficieny = efficiensy;
    car.connectors = connector;
    notifyListeners();
  }

  void updateCurrentBattery(int currentBattery) {
    car.currentBattery = currentBattery;
    notifyListeners();
  }
}
