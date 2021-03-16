import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stateTrial/providers/LocationProvider.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapView extends StatefulWidget {
  @override
  _MapView createState() => _MapView();
}

class _MapView extends State<MapView> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = Set();

  PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  @override
  Widget build(BuildContext context) {
    final locData = Provider.of<LocationProvider>(context);

    if (locData.loc.isSelected == true) {
//      _updateTheMap(locData.loc.lattidute, locData.loc.longitude);
      addMarker(locData.loc.lattidute, locData.loc.longitude,
          locData.loc.lattiduteDest, locData.loc.longitudeDest);
      _createPolylines(locData.loc.lattidute, locData.loc.longitude,
          locData.loc.lattiduteDest, locData.loc.longitudeDest, locData);
      // ignore: unnecessary_statements

      //locData.toggleSelected();
    }

    return GoogleMap(
      myLocationEnabled: true,
      initialCameraPosition: _kGooglePlex,
      mapType: MapType.normal,
      polylines: Set<Polyline>.of(polylines.values),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      markers: markers,
    );
  }

  Future<void> _updateTheMap(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.moveCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, long), zoom: 15)));
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

  _createPolylines(double latSource, double longSource, double latDest,
      double longDest, LocationProvider data) async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyCdLd1RuWXhZRK-QxroPh7d1ok1n1K6C9o', // Google Maps API Key
      PointLatLng(latSource, longSource),
      PointLatLng(latDest, longDest),
      travelMode: TravelMode.transit,
    );
    print("debug");
    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    // Defining an ID
    PolylineId id = PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );

    // Adding the polyline to the map

    setState(() {
      polylines[id] = polyline;
    });

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: LatLng(
            latSource,
            longSource,
          ),
          southwest: LatLng(
            latDest,
            longDest,
          ),
        ),
        100.0, // padding
      ),
    );
    setState(() {
      data.toggleSelected();
    });
  }
}
