import 'package:flutter/material.dart';
import 'package:stateTrial/providers/CarProvider.dart';
import 'package:stateTrial/providers/LocationProvider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:progress_indicators/progress_indicators.dart';

class CarSearch extends StatefulWidget {
  @override
  _CarSearchState createState() => _CarSearchState();
}

class _CarSearchState extends State<CarSearch> {
  var _isInit = true;
  int num = 0;
  List<String> cars = new List<String>();
  List<String> carss = new List<String>();
  List<dynamic> loadedData;
  double _currentSliderValue = 0;
  var value;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      getCars();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> getCars() async {
    const url =
        "http://gphbackendfinal-env.eba-7uwmhxbb.eu-west-1.elasticbeanstalk.com/cars";
    final response = await http.get(url);
    final extractedData = json.decode(response.body) as List<dynamic>;

    while (num < extractedData.length) {
      //print(extractedData[num]['name']);
      cars.add(extractedData[num]['name']);
      num++;
    }
    setState(() {
      carss = cars;
      loadedData = extractedData;
    });
  }

  @override
  Widget build(BuildContext context) {
    final carData = Provider.of<CarProvider>(context);
    final locData = Provider.of<LocationProvider>(context);
    final mediaQuery = MediaQuery.of(context);
    bool toogleSearch = false;

    bool _checkIfParamatersSelected(
        LocationProvider locData, CarProvider carData) {
      if (locData.loc.lattidute != 37.785834 &&
          locData.loc.lattiduteDest != 51.5266 &&
          carData.car.id != 0 &&
          carData.car.currentBattery != 0)
        return true;
      else
        return false;
    }

    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          color: Colors.green[300],
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 5),
              ),
              Center(
                  child: Icon(
                Icons.car_rental,
                color: Colors.white,
              )),
              Padding(
                padding: EdgeInsets.only(right: 10),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 5,
                    ),
                    DropdownButton(
                      isExpanded: true,
                      underline: Container(
                        height: 0.9,
                        color: Colors.black45,
                      ),
                      focusColor: Colors.white,
                      hint: Text(
                        "Car",
                        style: TextStyle(color: Colors.black54),
                      ),
                      value: value,
                      onChanged: (newValue) {
                        setState(() {
                          value = newValue;
                          //      locData.loc.isSelected = false;
                        });

                        final selectedCar = loadedData
                            .where((index) => index['name'] == value)
                            .toList();

                        carData.updateCarProperties(
                            selectedCar[0]['id'],
                            selectedCar[0]['name'],
                            selectedCar[0]['totalBattery'],
                            selectedCar[0]['totalRange'],
                            selectedCar[0]['avgUsagePerKm'],
                            selectedCar[0]['connectors']);
                      },
                      items: cars.map((valueItem) {
                        return DropdownMenuItem(
                          value: valueItem,
                          child: Text(valueItem),
                        );
                      }).toList(),
                      icon: Icon(Icons.arrow_drop_down),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Current Battery",
                      textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.black54, fontSize: 15),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.black54,
                        inactiveTrackColor: Colors.black45,
                        trackHeight: 1.0,
                        thumbColor: Colors.black54,
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 8.0),
                        overlayColor: Colors.purple.withAlpha(32),
                        overlayShape:
                            RoundSliderOverlayShape(overlayRadius: 14.0),
                      ),
                      child: Slider(
                          value: _currentSliderValue,
                          min: 0,
                          max: 100,
                          divisions: 100,
                          // activeColor: Colors.black45,
                          //inactiveColor: Colors.black45,
                          label: _currentSliderValue.round().toString() + "%",
                          onChanged: (double value) {
                            setState(() {
                              _currentSliderValue = value;
                            });
                          },
                          onChangeEnd: (double value) {
                            setState(() {
                              carData.updateCurrentBattery(value);
                              //  locData.loc.isSelected = false;
                            });
                          }),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 7),
              )
            ],
          ),
        ),
        Container(
          alignment: Alignment.center,
          color: Colors.green[300],
          child: (_checkIfParamatersSelected(locData, carData) == true)
              ? (carData.car.isCarSelected == true)
                  ? JumpingDotsProgressIndicator(
                      fontSize: 20,
                    )
                  : Container(
                      width: 30,
                      height: 30,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: FloatingActionButton(
                          elevation: 5,
                          focusElevation: 1,
                          hoverElevation: 3,
                          child: Icon(
                            Icons.search,
                            color: Colors.black54,
                          ),
                          onPressed: () {
                            setState(() {
                              carData.car.isCarSelected = true;
                              locData.toggleSelected();
                            });
                          }),
                    )
              : Container(),
        )
      ],
    );
  }
}
