import 'package:flutter/material.dart';

class Car {
  int id;
  String name;
  int battery;
  int range;
  int efficieny;
  List<dynamic> connectors;
  double currentBattery;
  bool isCarSelected;
  Car(
      {this.id,
      this.name,
      this.battery,
      this.range,
      this.efficieny,
      this.connectors,
      this.currentBattery,
      this.isCarSelected});
}

class CarProvider with ChangeNotifier {
  Car car = Car(
      id: 0,
      name: "",
      battery: 0,
      range: 0,
      efficieny: 0,
      connectors: [],
      currentBattery: 0,
      isCarSelected: false);

  void updateCarProperties(int id, String name, int battery, int range,
      int efficiensy, List<dynamic> connector) {
    car.name = name;
    car.range = range;
    car.efficieny = efficiensy;
    car.connectors = connector;
    car.battery = battery;
    car.id = id;
    notifyListeners();
  }

  void updateCurrentBattery(double currentBattery) {
    car.currentBattery = currentBattery;
    notifyListeners();
  }

  void toggleIsCarSelected() {
    car.isCarSelected = !car.isCarSelected;
    notifyListeners();
  }
}
