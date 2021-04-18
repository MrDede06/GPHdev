import 'package:flutter/material.dart';
import 'package:stateTrial/providers/CarProvider.dart';
import 'package:provider/provider.dart';
import 'package:stateTrial/providers/LocationProvider.dart';

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
                  Center(
                    child: Text(
                      "Charge Station Body",
                      style: TextStyle(color: Colors.black),
                    ),
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
}
