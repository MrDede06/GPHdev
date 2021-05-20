import 'dart:async';
import 'package:flutter/services.dart';
import 'package:stateTrial/providers/CarProvider.dart';
import 'package:stateTrial/providers/ChargeStationProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stateTrial/providers/LocationProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:flutter_mapbox_navigation/library.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

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
  List<ChargeStationProvider> stations = [];

  //mapboxpart
  String _platformVersion = 'Unknown';
  String _instruction = "";
  MapBoxNavigation _directions;
  MapBoxOptions _options;

  bool _arrived = false;
  bool _isMultipleStop = false;
  double _distanceRemaining, _durationRemaining;
  MapBoxNavigationViewController _controllerBox;
  bool _routeBuilt = false;
  bool _isNavigating = false;

  var wayPoints = List<WayPoint>();

  @override
  void initState() {
    super.initState();
    initialize();
  }
  //mapboxpartend

  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(51.107883, 17.038538),
    zoom: 6,
  );
  @override
  Widget build(BuildContext context) {
    final locData = Provider.of<LocationProvider>(context);
    final carData = Provider.of<CarProvider>(context);
    final stationData = Provider.of<ChargeStationProvider>(context);
    var media = MediaQuery.of(context);
    double appBarheight = Scaffold.of(context).appBarMaxHeight;
    final scaffold = Scaffold.of(context);
    if (_checkIfParamatersSelected(locData, carData) == true) {
      funcPolyCoordinates.clear();
      markers.clear();
      _polylines.clear();
      polylines.clear();
      polylineCoordinates.clear();
      realpolylineCoordinates.clear();
      stations.clear();
      totalCordCollection.clear();
      markerLocations.clear();
      _getBackEndParameters(locData, carData, scaffold, stationData);
      print("count debug");

      locData.loc.isSelected = false;
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
        (distancePanel != "" && durationPanel != "") && isLoading != true
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
                            onPressed: () async {
                              int i = 0;
                              int y = 1;
                              while (i < funcPolyCoordinates.length) {
                                wayPoints.add(WayPoint(
                                    latitude: funcPolyCoordinates[i].latitude,
                                    longitude: funcPolyCoordinates[i].longitude,
                                    name: "Destination $y)"));
                                i++;
                                y++;
                              }
                              await _directions.startNavigation(
                                  wayPoints: wayPoints, options: _options);
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
    // markers.clear();
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
    print("creating polylines");
    print("===================");
    polylinePoints = PolylinePoints();
    int i = 0;
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

  Future<void> _createPolylinesforError(double lattidute, double longtidute,
      double latiduteDest, double longtiduteDest) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyCdLd1RuWXhZRK-QxroPh7d1ok1n1K6C9o', // Google Maps API Key
      PointLatLng(lattidute, longtidute),
      PointLatLng(latiduteDest, longtiduteDest),
      travelMode: TravelMode.driving,
    );
    totalCordCollection = result.points;
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
    Marker sourcetMarker = Marker(
      markerId: MarkerId("id"),
      position: LatLng(lattidute, longtidute),
    );
    Marker destMarker = Marker(
      markerId: MarkerId("id2"),
      position: LatLng(latiduteDest, longtiduteDest),
    );
    // Add it to Set

    markers.add(sourcetMarker);
    markers.add(destMarker);

    final GoogleMapController controller = await _controller.future;
    List<LatLng> _targetCord = [
      LatLng(lattidute, longtidute),
      LatLng(latiduteDest, longtiduteDest)
    ];
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        boundsFromLatLngList(_targetCord),
        70.0, // padding
      ),
    );
  }

  Future<void> _getBackEndParameters(
      LocationProvider locData,
      CarProvider carData,
      ScaffoldState scaffold,
      ChargeStationProvider stationData) async {
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
      'Accept': 'application/json; charset=UTF-8',
    };
    var msg = jsonEncode(jsonParam);

    var url2 =
        "http://gphbackendfinal-env.eba-7uwmhxbb.eu-west-1.elasticbeanstalk.com/poi";

    try {
      var response2 = await http.post(url2, body: msg, headers: requestHeaders);
      List<dynamic> responseJson2 = json.decode(response2.body);
      print(responseJson2.length);
      int i = 0;
      funcPolyCoordinates
          .add(PointLatLng(locData.loc.lattidute, locData.loc.longitude));
      stationData.clearStationProperties();
      while (i < responseJson2.length) {
        List<int> connectors = [];
        int y = 0;
        markerLocations.add(LatLng(responseJson2[i]["AddressInfo"]["Latitude"],
            responseJson2[i]["AddressInfo"]["Longitude"]));

        funcPolyCoordinates.add(PointLatLng(
            responseJson2[i]["AddressInfo"]["Latitude"],
            responseJson2[i]["AddressInfo"]["Longitude"]));

        while (y < responseJson2[i]["Connections"].length) {
          connectors
              .add(responseJson2[i]["Connections"][y]["ConnectionTypeID"]);
          y++;
        }
        if (i == 0) {
          sourceLat = locData.loc.lattidute;
          sourceLong = locData.loc.longitude;
          destLat = responseJson2[i]["AddressInfo"]["Latitude"];
          destLong = responseJson2[i]["AddressInfo"]["Longitude"];
          print("$i in the first if");
        } else if (i == (responseJson2.length - 1)) {
          sourceLat = responseJson2[responseJson2.length - 2]["AddressInfo"]
              ["Latitude"];
          sourceLong = responseJson2[responseJson2.length - 2]["AddressInfo"]
              ["Longitude"];
          destLat = responseJson2[responseJson2.length - 1]["AddressInfo"]
              ["Latitude"];
          destLong = responseJson2[responseJson2.length - 1]["AddressInfo"]
              ["Longitude"];

          print("$i in the else if");
        } else {
          sourceLat = responseJson2[i - 1]["AddressInfo"]["Latitude"];
          sourceLong = responseJson2[i - 1]["AddressInfo"]["Longitude"];
          destLat = responseJson2[i]["AddressInfo"]["Latitude"];
          destLong = responseJson2[i]["AddressInfo"]["Longitude"];
          print("$i in the else");
        }

        var urlCharge =
            "https://maps.googleapis.com/maps/api/directions/json?origin=$sourceLat,$sourceLong&destination=$destLat,$destLong&key=AIzaSyCdLd1RuWXhZRK-QxroPh7d1ok1n1K6C9o";
        var responseCharge = await http.get(urlCharge);
        Map<String, dynamic> responseJsonCharge =
            json.decode(responseCharge.body);
        List<dynamic> routesCharge = responseJsonCharge["routes"];
        setState(() {
          stationData.updateStationProperties(ChargeStation(
              distance:
                  (routesCharge[0]["legs"][0]["distance"]["value"].toInt() /
                          1000)
                      .round()
                      .toString(),
              duration: routesCharge[0]["legs"][0]["duration"]["value"].toInt(),
              address: responseJson2[i]["AddressInfo"]["AddressLine1"],
              stationTitle: responseJson2[i]["AddressInfo"]["Title"],
              numConnectors: responseJson2[i]["Connections"].length,
              connectors: connectors));
        });

        i++;
      }
      funcPolyCoordinates.add(
          PointLatLng(locData.loc.lattiduteDest, locData.loc.longitudeDest));
      final Uint8List markerIcon =
          await getBytesFromAsset('assets/images/marker.png');
      for (LatLng markerLocation in markerLocations) {
        setState(() {
          markers.add(
            Marker(
                markerId: MarkerId(
                    markerLocations.indexOf(markerLocation).toString()),
                position: markerLocation,
                icon: BitmapDescriptor.fromBytes(markerIcon)),
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
          (routesFinal[0]["legs"][0]["distance"]["value"].toInt() / 1000)
              .round();
      var duration = routesFinal[0]["legs"][0]["duration"]["value"].toInt();

      setState(() {
        durationPanel = _printDuration(Duration(seconds: duration));
        distancePanel = "$distanceFinal km";
        isLoading = false;
        //  carData.car.isCarSelected = false;
        carData.toggleIsCarSelected();
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        carData.toggleIsCarSelected();
        stationData.clearStationProperties();
      });
      print(error);
      scaffold.showSnackBar(
        SnackBar(
          duration: Duration(seconds: 10),
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Route is not found with selected parameters. Please try to change current battery and search again!',
            textAlign: TextAlign.center,
          ),
        ),
      );
      _createPolylinesforError(
        locData.loc.lattidute,
        locData.loc.longitude,
        locData.loc.lattiduteDest,
        locData.loc.longitudeDest,
      );
    }
  }

  bool _checkIfParamatersSelected(
      LocationProvider locData, CarProvider carData) {
    if (locData.loc.lattidute != 37.785834 &&
        locData.loc.lattiduteDest != 51.5266 &&
        carData.car.id != 1 &&
        carData.car.currentBattery != 0 &&
        locData.loc.isSelected == true)
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

  Future<void> _onRouteEvent(e) async {
    _distanceRemaining = await _directions.distanceRemaining;
    _durationRemaining = await _directions.durationRemaining;

    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        _arrived = progressEvent.arrived;
        if (progressEvent.currentStepInstruction != null)
          _instruction = progressEvent.currentStepInstruction;
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        _routeBuilt = true;
        break;
      case MapBoxEvent.route_build_failed:
        _routeBuilt = false;
        break;
      case MapBoxEvent.navigation_running:
        _isNavigating = true;
        break;
      case MapBoxEvent.on_arrival:
        _arrived = true;
        if (!_isMultipleStop) {
          await Future.delayed(Duration(seconds: 3));
          await _controllerBox.finishNavigation();
        } else {}
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        _routeBuilt = false;
        _isNavigating = false;
        break;
      default:
        break;
    }
    //refresh UI
    setState(() {});
  }

  Future<void> initialize() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    _directions = MapBoxNavigation(onRouteEvent: _onRouteEvent);
    _options = MapBoxOptions(
        //initialLatitude: 36.1175275,
        //initialLongitude: -115.1839524,
        zoom: 15.0,
        tilt: 0.0,
        bearing: 0.0,
        enableRefresh: false,
        alternatives: true,
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        allowsUTurnAtWayPoints: true,
        mode: MapBoxNavigationMode.driving,
        units: VoiceUnits.imperial,
        simulateRoute: false,
        animateBuildRoute: true,
        longPressDestinationEnabled: true,
        language: "en");
    /*
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await _directions.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    setState(() {
      _platformVersion = platformVersion;
    });
    */
  }

  Future<Uint8List> getBytesFromAsset(String path) async {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: pixelRatio.round() * 30);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }
}
