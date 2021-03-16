import 'package:flutter/material.dart';
import 'package:stateTrial/providers/LocationProvider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
        "http://finalgphbackend-env.eba-8z7mhh3u.eu-west-1.elasticbeanstalk.com/cars";
    final response = await http.get(url);
    final extractedData = json.decode(response.body) as List<dynamic>;

    while (num < extractedData.length) {
      //print(extractedData[num]['name']);
      cars.add(extractedData[num]['name']);
      num++;
    }
    /*
    extractedData.forEach((orderId) {
      cars.add(extractedData[orderId]['name']);
    });
    print(cars);
    */
    setState(() {
      carss = cars;
      loadedData = extractedData;
    });
  }

  @override
  Widget build(BuildContext context) {
//    final carData = Provider.of<CarProvider>(context);
    final mediaQuery = MediaQuery.of(context);
    return Container(
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
              children: <Widget>[
                DropdownButton(
                  isExpanded: true,
                  hint: Text(
                    "Select the car",
                  ),
                  value: value,
                  onChanged: (newValue) {
                    setState(() {
                      value = newValue;
                    });
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
                  height: 30,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 7),
          )
        ],
      ),
    );
  }
}
