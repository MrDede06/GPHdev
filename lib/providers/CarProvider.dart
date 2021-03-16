import 'package:flutter/material.dart';

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
