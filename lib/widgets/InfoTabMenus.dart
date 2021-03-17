import 'package:flutter/material.dart';
import 'package:stateTrial/providers/CarProvider.dart';
import 'package:provider/provider.dart';

class InfoTabMenus extends StatefulWidget {
  @override
  _InfoTabMenusState createState() => _InfoTabMenusState();
}

class _InfoTabMenusState extends State<InfoTabMenus>
    with TickerProviderStateMixin {
  /*
  TabController _tabController;
  @override
  void initState() {
    _tabController = new TabController(length: 3, vsync: this);
    super.initState();
  }
  */
  @override
  Widget build(BuildContext context) {
    final carData = Provider.of<CarProvider>(context);
    return Container(
        child: DefaultTabController(
      length: 3,
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
                  Tab(
                      icon: Icon(
                    Icons.self_improvement_sharp,
                    color: Colors.black54,
                  )),
                ],
              ),
            ),
            Expanded(
              child: Container(
                constraints: BoxConstraints.expand(),
                child: TabBarView(children: [
                  carData.car.name == ""
                      ? Container(
                          child: Column(
                          children: <Widget>[
                            _getRowWithDivider(""),
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
                            _getRowWithDivider(carData.car.name),
                            _getRowWithDivider("Battery: " +
                                carData.car.battery.toString() +
                                " kw"),
                            _getRowWithDivider("Range: " +
                                carData.car.range.toString() +
                                " km"),
                            _getRowWithDivider("Efficiency: " +
                                carData.car.efficieny.toString() +
                                " w/km"),
                            _getRowWithDivider("Connectors: " +
                                carData.car.connectors.toString()),
                            _getRowWithDivider("Current battery: " +
                                carData.car.currentBattery.toString() +
                                " %"),
                          ],
                        )),
                  Center(
                    child: Text(
                      "Charge Station Body",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  Center(
                    child: Text(
                      "Fuck Body :)",
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
}
