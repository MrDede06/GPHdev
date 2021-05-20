import 'package:flutter/material.dart';
import 'package:stateTrial/providers/CarProvider.dart';
import 'package:provider/provider.dart';
import 'package:stateTrial/providers/LocationProvider.dart';
import 'package:stateTrial/providers/ChargeStationProvider.dart';
import 'dart:convert';

class InfoTabMenus extends StatefulWidget {
  @override
  _InfoTabMenusState createState() => _InfoTabMenusState();
}

class _InfoTabMenusState extends State<InfoTabMenus>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final carData = Provider.of<CarProvider>(context);
    final locData = Provider.of<LocationProvider>(context);
    final stationData = Provider.of<ChargeStationProvider>(context);
    final List<ChargeStation> stations = stationData.stations;
    const Utf8Codec utf8 = Utf8Codec();
    return Container(
        child: DefaultTabController(
      length: 2,
      child: Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              child: TabBar(
                unselectedLabelColor: Colors.black87,
                tabs: [
                  Tab(
                    icon: Icon(
                      Icons.car_repair,
                      color: Colors.black54,
                    ),
                  ),
                  Tab(
                      icon: Icon(
                    Icons.charging_station_rounded,
                    color: Colors.black54,
                  )),
                ],
              ),
            ),
            Expanded(
              child: Container(
                constraints: BoxConstraints.expand(),
                child: TabBarView(children: [
                  _getInfoTabStat(locData, carData)
                      ? Container(
                          child: Column(
                          children: <Widget>[
                            _getRowWithDivider("From:"),
                            _getRowWithDivider("To:"),
                            _getRowWithDivider("Car:"),
                            _getRowWithDivider("Battery: km"),
                            _getRowWithDivider("Range: km"),
                            _getRowWithDivider("Efficiency: w/km"),
                            _getRowWithDivider("Connectors:"),
                            _getRowWithDivider("Current battery: %"),
                          ],
                        ))
                      : Container(
                          child: Column(
                          children: <Widget>[
                            locData.loc.lattidute == 37.785834
                                ? _getRowWithDivider("From: ")
                                : _getRowWithDividerHL(
                                    "From: " + locData.loc.sourceAddr),
                            locData.loc.lattiduteDest == 51.5266
                                ? _getRowWithDivider("To: ")
                                : _getRowWithDividerHL(
                                    "To: " + locData.loc.destinationAddr),
                            carData.car.name == ""
                                ? _getRowWithDivider("Car: ")
                                : _getRowWithDividerHL(
                                    "Car: " + carData.car.name),
                            carData.car.name == ""
                                ? _getRowWithDivider("Battery: km")
                                : _getRowWithDividerHL("Battery: " +
                                    carData.car.battery.toString() +
                                    " kw"),
                            carData.car.name == ""
                                ? _getRowWithDivider("Range: km")
                                : _getRowWithDividerHL("Range: " +
                                    carData.car.range.toString() +
                                    " km"),
                            carData.car.name == ""
                                ? _getRowWithDivider("Efficiency: w/km")
                                : _getRowWithDividerHL("Efficiency: " +
                                    carData.car.efficieny.toString() +
                                    " w/km"),
                            carData.car.name == ""
                                ? _getRowWithDivider("Connectors:")
                                : _getRowWithDividerHL("Connectors: " +
                                    carData.car.connectors.toString()),
                            carData.car.currentBattery == 0
                                ? _getRowWithDivider("Current battery: %")
                                : _getRowWithDividerHL("Current battery: " +
                                    carData.car.currentBattery
                                        .toInt()
                                        .toString() +
                                    " %"),
                          ],
                        )),
                  Container(
                    child: ListView.builder(
                        itemCount: stations.length,
                        itemBuilder: (_, i) => Column(
                              children: <Widget>[
                                _getRowWithDividerBold(
                                    "Charge Station ${i + 1}: " +
                                        utf8
                                            .encode(stations[i].stationTitle)
                                            .toString()),
                                _getRowWithDivider("Address: " +
                                    utf8
                                        .encode(stations[i].address)
                                        .toString()),
                                _getRowWithDivider("Number of connectors: " +
                                    stations[i].numConnectors.toString()),
                                _getRowWithDivider("Connectors: " +
                                    _convertFromMap(stations[i].connectors)),
                                /*_getRowWithDivider("Connectors: "), */
                                _getRowWithDivider("Distance: " +
                                    stations[i].distance +
                                    " km"),
                                _getRowWithDivider("Duration: " +
                                    _printDuration(stations[i].duration)),
                                SizedBox(
                                  height: 20,
                                )
                              ],
                            )),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _getRowWithDivider(String text) {
    var children = <Widget>[
      new Padding(padding: new EdgeInsets.all(10.0), child: new Text(text)),
      new Divider(height: 5.0),
    ];

    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _getRowWithDividerBold(String text) {
    var children = <Widget>[
      new Padding(
        padding: new EdgeInsets.all(10.0),
        child: new Text(text,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ),
      new Divider(height: 5.0),
    ];

    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _getRowWithDividerHL(String text) {
    var children = <Widget>[
      new Padding(padding: new EdgeInsets.all(10.0), child: new Text(text)),
      new Divider(height: 5.0),
    ];

    return new Container(
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  bool _getInfoTabStat(LocationProvider loc, CarProvider car) {
    if (loc.loc.lattidute == 37.785834 &&
        loc.loc.lattiduteDest == 51.5266 &&
        car.car.name == "" &&
        car.car.currentBattery == 0)
      return true;
    else
      return false;
  }

  String _convertFromMap(List<int> connectors) {
    String finalstr = "";
    List<String> listStr = [];

    for (int i in connectors) {
      if (i == 1)
        listStr.add("Type1");
      else if (i == 2)
        listStr.add("CHAdeMO");
      else if (i == 25)
        listStr.add("Type 2(socket only)");
      else if (i == 1036)
        listStr.add("Type 2(tethered id)");
      else if (i == 32)
        listStr.add("CCS Type-1");
      else
        listStr.add("CCS Type-2");
    }
    return listStr.toString();
  }
}

String _printDuration(int sec) {
  final duration = Duration(seconds: sec);
  return "${duration.inHours}h ${duration.inMinutes.remainder(60)}min";
}
