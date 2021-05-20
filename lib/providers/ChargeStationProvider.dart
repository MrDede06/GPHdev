import 'package:flutter/material.dart';

class ChargeStation {
  String stationTitle;
  String address;
  int duration;
  String distance;
  int numConnectors;
  List<int> connectors;
  ChargeStation(
      {this.stationTitle,
      this.address,
      this.numConnectors,
      this.connectors,
      this.distance,
      this.duration});
}

class ChargeStationProvider with ChangeNotifier {
  List<ChargeStation> _items = [];

  List<ChargeStation> get stations {
    return [..._items];
  }

  void updateStationProperties(ChargeStation station) {
    final newStation = ChargeStation(
        address: station.address,
        stationTitle: station.stationTitle,
        numConnectors: station.numConnectors,
        connectors: station.connectors,
        duration: station.duration,
        distance: station.distance);
    _items.add(newStation);
    notifyListeners();
  }

  void printStationProperties() {
    int i = 0;
    while (i < _items.length) {
      print("charhe Station $i");
      print("title: " + _items[i].stationTitle);
      print("addres: " + _items[i].address);
      print("number of connectors: " + _items[i].numConnectors.toString());
      print("connectors: " + _items[i].connectors.toString());
      i++;
    }
  }

  void clearStationProperties() {
    _items.clear();
  }
}
