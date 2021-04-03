import 'dart:async';
import 'package:stateTrial/providers/CarProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stateTrial/providers/LocationProvider.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapView extends StatefulWidget {
  @override
  _MapView createState() => _MapView();
}

class _MapView extends State<MapView> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = Set();
  Set<Marker> markers_src_dst = Set();
  final List<LatLng> markerLocations = [];
  List<PointLatLng> totalCordCollection = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Set<Polyline> _polylines = {};

  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  List<PointLatLng> funcPolyCoordinates = [];
  List<LatLng> realpolylineCoordinates = [];

  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(51.107883, 17.038538),
    zoom: 12,
  );
  @override
  Widget build(BuildContext context) {
    final locData = Provider.of<LocationProvider>(context);
    final carData = Provider.of<CarProvider>(context);

    if (_checkIfParamatersSelected(locData, carData) == true) {
      _getBackEndParameters(locData, carData);
      print("count debug");
      // _createPolylines(locData.loc.lattidute, locData.loc.longitude,
      //   locData.loc.lattiduteDest, locData.loc.longitudeDest, locData);

      locData.loc.isSelected = true;
    }

    return GoogleMap(
      myLocationEnabled: true,
      initialCameraPosition: _kGooglePlex,
      mapType: MapType.normal,
      polylines: _polylines,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      markers: markers,
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
    print("funcpolycoordinates:");
    print(funcPolyCoordinates);

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

      print("--------");
      print(totalCordCollection.length);
      print(result.points.length);
      print(result.status);
      print(result.errorMessage);
      print("--------");

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
      print(markerLocation);
      setState(() {
        markers.add(
          Marker(
            markerId:
                MarkerId(markerLocations.indexOf(markerLocation).toString()),
            position: markerLocation,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          ),
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
}
