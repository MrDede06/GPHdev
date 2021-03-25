import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stateTrial/providers/LocationProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import '../widgets/InfoTabMenus.dart';
import '../widgets/SearchForm.dart';
import '../widgets/MapView.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/CarSearch.dart';
import 'package:stateTrial/providers/CarProvider.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final locData = Provider.of<LocationProvider>(context);
    final carData = Provider.of<CarProvider>(context);
    String url;
    double sourceLat, sourceLong, destLat, destLong;
    var jsonParam;

    Future<void> _launchURL() async {
      const url =
          'http://green-power-hunters.s3-website.eu-central-1.amazonaws.com/';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Container(
            child: Bounce(
              child: Image.asset("assets/images/logo1.png"),
              onPressed: _launchURL,
              duration: Duration(milliseconds: 100),
            ),
            height: 50,
          ),
          shadowColor: Colors.black,
          backgroundColor: Colors.green[200],
          actions: <Widget>[
            Bounce(
                duration: Duration(milliseconds: 100),
                onPressed: () async {
                  sourceLat = locData.loc.lattidute;
                  sourceLong = locData.loc.longitude;
                  destLat = locData.loc.lattiduteDest;
                  destLong = locData.loc.longitudeDest;
                  url =
                      "https://maps.googleapis.com/maps/api/directions/json?origin=$sourceLat,$sourceLong&destination=$destLat,$destLong&key=AIzaSyCdLd1RuWXhZRK-QxroPh7d1ok1n1K6C9o";
                  var response = await http.get(url);
                  Map<String, dynamic> responseJson =
                      json.decode(response.body);
                  List<dynamic> routes = responseJson["routes"];
                  var distance =
                      (routes[0]["legs"][0]["distance"]["value"].toInt() / 1000)
                          .round();
                  var polyString =
                      routes[0]["overview_polyline"]["points"].toString();
                  var latStart = locData.loc.lattidute;
                  var longStart = locData.loc.longitude;

                  jsonParam = {
                    "car": {
                      "id": carData.car.id,
                      "currentBatteryPercentage":
                          carData.car.currentBattery.toInt()
                    },
                    "route": {
                      "length": "$distance",
                      "starting": {
                        "latitude": "$latStart",
                        "longitude": "$longStart"
                      },
                      "polyline": "$polyString"
                    }
                  };

                  Map<String, String> requestHeaders = {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                  };
                  var msg = jsonEncode(jsonParam);

                  var url2 =
                      "http://finalgphbackend-env.eba-8z7mhh3u.eu-west-1.elasticbeanstalk.com/poi";

                  var response2 =
                      await http.post(url2, body: msg, headers: requestHeaders);

                  print("sasasasa");
                  print(response2.statusCode);
                  print(response2.body);
                  print(response2);
                  print("sadfasfdaswfdafasef");
                  List<dynamic> responseJson2 = json.decode(response2.body);
                  print(responseJson2);
                },
                child: Icon(
                  Icons.person,
                  color: Colors.black54,
                )),
            Padding(padding: EdgeInsets.only(right: 10)),
          ],
        ),
        drawer: Drawer(
            elevation: 40,
            child: Column(
              children: <Widget>[SearchForm(), CarSearch(), InfoTabMenus()],
            )),
        body: MapView());
  }
}
