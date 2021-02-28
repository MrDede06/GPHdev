import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stateTrial/providers/LocationProvider.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';

class MapView extends StatefulWidget {
  @override
  _MapView createState() => _MapView();
}

class _MapView extends State<MapView> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = Set();
  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  @override
  Widget build(BuildContext context) {
    final locData = Provider.of<LocationProvider>(context);

    if (locData.loc.isSelected == true) {
      _updateTheMap(locData.loc.lattidute, locData.loc.longitude);
      addMarker(locData.loc.lattidute, locData.loc.longitude);
      // ignore: unnecessary_statements
      locData.toggleSelected;
    }

    return GoogleMap(
      myLocationEnabled: true,
      initialCameraPosition: _kGooglePlex,
      mapType: MapType.normal,
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

  void addMarker(double lat, double long) {
    Marker resultMarker = Marker(
      markerId: MarkerId("id"),
      position: LatLng(lat, long),
    );
    // Add it to Set
    markers.add(resultMarker);
  }
}
