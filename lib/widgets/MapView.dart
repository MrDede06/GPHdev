import 'dart:async';
import 'package:stateTrial/providers/CarProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stateTrial/providers/LocationProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:progress_indicators/progress_indicators.dart';

class MapView extends StatefulWidget {
  @override
  _MapView createState() => _MapView();
}

class _MapView extends State<MapView> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = Set();
  final List<LatLng> markerLocations = [];
  List<PointLatLng> totalCordCollection = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Set<Polyline> _polylines = {};
  String durationPanel = "";
  String distancePanel = "";
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  List<PointLatLng> funcPolyCoordinates = [];
  List<LatLng> realpolylineCoordinates = [];
  bool isLoading = false;

  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(51.107883, 17.038538),
    zoom: 6,
  );
  @override
  Widget build(BuildContext context) {
    final locData = Provider.of<LocationProvider>(context);
    final carData = Provider.of<CarProvider>(context);
    var media = MediaQuery.of(context);
    double appBarheight = Scaffold.of(context).appBarMaxHeight;
    if (_checkIfParamatersSelected(locData, carData) == true) {
      _getBackEndParameters(locData, carData);
      print("count debug");
      // _createPolylines(locData.loc.lattidute, locData.loc.longitude,
      //   locData.loc.lattiduteDest, locData.loc.longitudeDest, locData);

      locData.loc.isSelected = true;
    }

    return Stack(
      children: <Widget>[
        GoogleMap(
          myLocationEnabled: true,
          initialCameraPosition: _kGooglePlex,
          mapType: MapType.normal,
          polylines: _polylines,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: markers,
        ),
        (distancePanel != "" && durationPanel != "")
            ? Container(
                child: Card(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: 50,
                      ),
                      Icon(Icons.car_rental),
                      SizedBox(
                        width: 5,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        //  crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Center(
                            child: Text(durationPanel),
                          ),
                          Text(distancePanel),
                        ],
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Card(
                        elevation: 15,
                        color: Colors.green[200],
                        child: Bounce(
                            child: Row(
                              children: <Widget>[
                                Text("Open Navigation"),
                                Icon(Icons.arrow_forward_ios)
                              ],
                            ),
                            duration: Duration(milliseconds: 100),
                            onPressed: () {
                              print("navigation");
                            }),
                      )
                    ],
                  ),
                  color: Colors.green[100],
                  margin: EdgeInsets.all(10),
                ),
                alignment: Alignment.bottomLeft,
                margin: EdgeInsets.only(left: 4, bottom: 60),
              )
            : Container(),
        isLoading == true
            ? Positioned(
                height: (media.size.height - appBarheight) * 0.7,
                right: media.size.width * 0.3,
                child: JumpingText(
                  'Loading...',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ) /* JumpingDotsProgressIndicator(
                  color: Colors.black,
                  fontSize: 150,
                ), */
                )
            : Container()
      ],
    );
  }

  void addMarker(double lat, double long, double latDest, double longDest) {
    Marker sourcetMarker = Marker(
      markerId: MarkerId("id"),
      position: LatLng(lat, long),
    );
    Marker destMarker = Marker(
      markerId: MarkerId("id2"),
      position: LatLng(latDest, longDest),
    );
    // Add it to Set

    markers.add(sourcetMarker);
    markers.add(destMarker);
  }

  Future<void> _createPolylines(
      double lattidute,
      double longtidute,
      double latiduteDest,
      double longtiduteDest,
      LocationProvider data,
      List<PointLatLng> funcPolyCoordinates) async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    int i = 0;
    print(funcPolyCoordinates.length);
    print(funcPolyCoordinates);
    while (i < funcPolyCoordinates.length - 1) {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyCdLd1RuWXhZRK-QxroPh7d1ok1n1K6C9o', // Google Maps API Key
        PointLatLng(
            funcPolyCoordinates[i].latitude, funcPolyCoordinates[i].longitude),
        PointLatLng(funcPolyCoordinates[i + 1].latitude,
            funcPolyCoordinates[i + 1].longitude),
        travelMode: TravelMode.driving,
      );
      totalCordCollection += result.points;
      i++;
    }
    //print(result.points);
    // Adding the coordinates to the list
    print("create polyline");
    if (totalCordCollection.isNotEmpty) {
      totalCordCollection.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    setState(() {
      Polyline polyline = Polyline(
          polylineId: PolylineId("poly"),
          color: Color.fromARGB(255, 40, 122, 198),
          points: polylineCoordinates);
      _polylines.add(polyline);
    });
  }

  Future<void> _getBackEndParameters(
      LocationProvider locData, CarProvider carData) async {
    setState(() {
      isLoading = true;
    });
    double sourceLat = locData.loc.lattidute;
    double sourceLong = locData.loc.longitude;
    double destLat = locData.loc.lattiduteDest;
    double destLong = locData.loc.longitudeDest;
    var url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=$sourceLat,$sourceLong&destination=$destLat,$destLong&key=AIzaSyCdLd1RuWXhZRK-QxroPh7d1ok1n1K6C9o";
    var response = await http.get(url);
    Map<String, dynamic> responseJson = json.decode(response.body);
    List<dynamic> routes = responseJson["routes"];
    var distance =
        (routes[0]["legs"][0]["distance"]["value"].toInt() / 1000).round();
    var polyString = routes[0]["overview_polyline"]["points"].toString();
    var latStart = locData.loc.lattidute;
    var longStart = locData.loc.longitude;

    var jsonParam = {
      "car": {
        "id": carData.car.id,
        "currentBatteryPercentage": carData.car.currentBattery.toInt()
      },
      "route": {
        "length": "$distance",
        "starting": {"latitude": "$latStart", "longitude": "$longStart"},
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

    var response2 = await http.post(url2, body: msg, headers: requestHeaders);

    print("debug stuff");
    print(response2.statusCode);
    print(response2.reasonPhrase);
    print("debug stuff end");

    List<dynamic> responseJson2 = json.decode(response2.body);

    //print(responseJson2.length);
    int i = 0;

    funcPolyCoordinates
        .add(PointLatLng(locData.loc.lattidute, locData.loc.longitude));
    while (i < responseJson2.length) {
      markerLocations.add(LatLng(responseJson2[i]["AddressInfo"]["Latitude"],
          responseJson2[i]["AddressInfo"]["Longitude"]));

      funcPolyCoordinates.add(PointLatLng(
          responseJson2[i]["AddressInfo"]["Latitude"],
          responseJson2[i]["AddressInfo"]["Longitude"]));
      i++;
    }
    funcPolyCoordinates
        .add(PointLatLng(locData.loc.lattiduteDest, locData.loc.longitudeDest));

    for (LatLng markerLocation in markerLocations) {
      setState(() {
        markers.add(
          Marker(
              markerId:
                  MarkerId(markerLocations.indexOf(markerLocation).toString()),
              position: markerLocation,
              icon: BitmapDescriptor.fromAsset("assets/images/marker.png")),
        );
      });
    }
    setState(() {
      addMarker(locData.loc.lattidute, locData.loc.longitude,
          locData.loc.lattiduteDest, locData.loc.longitudeDest);
    });

    final GoogleMapController controller = await _controller.future;
    List<LatLng> _targetCord = [
      LatLng(locData.loc.lattidute, locData.loc.longitude),
      LatLng(locData.loc.lattiduteDest, locData.loc.longitudeDest)
    ];
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        boundsFromLatLngList(_targetCord),
        70.0, // padding
      ),
    );
    print("get back end parameters");
    _createPolylines(
        locData.loc.lattidute,
        locData.loc.longitude,
        locData.loc.lattiduteDest,
        locData.loc.longitudeDest,
        locData,
        funcPolyCoordinates);

    String finalUrl = returnUrl(
        markerLocations,
        locData.loc.lattidute,
        locData.loc.longitude,
        locData.loc.lattiduteDest,
        locData.loc.longitudeDest);

    var responseFinal = await http.get(finalUrl);
    Map<String, dynamic> responseJsonFinal = json.decode(responseFinal.body);
    List<dynamic> routesFinal = responseJsonFinal["routes"];
    var distanceFinal =
        (routesFinal[0]["legs"][0]["distance"]["value"].toInt() / 1000).round();
    var duration = routesFinal[0]["legs"][0]["duration"]["value"].toInt();

    setState(() {
      durationPanel = _printDuration(Duration(seconds: duration));
      distancePanel = "$distanceFinal km";
      isLoading = false;
    });

    print("disatnce is : $distancePanel");
    print("duration is : $durationPanel");
  }

  bool _checkIfParamatersSelected(
      LocationProvider locData, CarProvider carData) {
    if (locData.loc.lattidute != 37.785834 &&
        locData.loc.lattiduteDest != 51.5266 &&
        carData.car.id != 1 &&
        carData.car.currentBattery != 0 &&
        locData.loc.isSelected == false)
      return true;
    else
      return false;
  }

  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    assert(list.isNotEmpty);
    double x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1) y1 = latLng.longitude;
        if (latLng.longitude < y0) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
  }

  Future<PolylineResult> getPointsPoly(
      PointLatLng source, PointLatLng dest) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyCdLd1RuWXhZRK-QxroPh7d1ok1n1K6C9o', // Google Maps API Key
      PointLatLng(source.latitude, source.longitude),
      PointLatLng(dest.latitude, dest.longitude),
      travelMode: TravelMode.transit,
    );
    return result;
  }

  String returnUrl(List<LatLng> theList, double latidute, double longtidute,
      double latiduteDest, double longtiduteDest) {
    String url;
    String baseUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=$latidute,$longtidute&destination=$latiduteDest,$longtiduteDest&";
    if (theList.length == 0) {
      url = "$baseUrl&key=AIzaSyCdLd1RuWXhZRK-QxroPh7d1ok1n1K6C9o";
    } else if (theList.length == 1) {
      double lat1 = theList[0].latitude;
      double long1 = theList[0].longitude;
      url =
          "$baseUrl&waypoints=via:$lat1%2C$long1&key=AIzaSyCdLd1RuWXhZRK-QxroPh7d1ok1n1K6C9o";
    } else if (theList.length == 2) {
      double lat1 = theList[0].latitude;
      double long1 = theList[0].longitude;
      double lat2 = theList[1].latitude;
      double long2 = theList[1].longitude;
      url =
          "$baseUrl&waypoints=via:$lat1%2C$long1%7Cvia:$lat2%2C$long2&key=AIzaSyCdLd1RuWXhZRK-QxroPh7d1ok1n1K6C9o";
    } else if (theList.length == 3) {
      double lat1 = theList[0].latitude;
      double long1 = theList[0].longitude;
      double lat2 = theList[1].latitude;
      double long2 = theList[1].longitude;
      double lat3 = theList[2].latitude;
      double long3 = theList[2].longitude;

      url =
          "$baseUrl&waypoints=via:$lat1%2C$long1%7Cvia:$lat2%2C$long2%7Cvia:$lat3%2C$long3&key=AIzaSyCdLd1RuWXhZRK-QxroPh7d1ok1n1K6C9o";
    } else {
      double lat1 = theList[0].latitude;
      double long1 = theList[0].longitude;
      double lat2 = theList[1].latitude;
      double long2 = theList[1].longitude;
      double lat3 = theList[2].latitude;
      double long3 = theList[2].longitude;
      double lat4 = theList[3].latitude;
      double long4 = theList[3].longitude;

      url =
          "$baseUrl&waypoints=via:$lat1%2C$long1%7Cvia:$lat2%2C$long2%7Cvia:$lat3%2C$long3%7Cvia:$lat4%2C$long4&key=AIzaSyCdLd1RuWXhZRK-QxroPh7d1ok1n1K6C9o";
    }
    return url;
  }

  String _printDuration(Duration duration) {
    return "${duration.inHours}h ${duration.inMinutes.remainder(60)}min";
  }
}
