import 'package:flutter/material.dart';
import 'package:stateTrial/providers/LocationProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'dart:async';

class SearchForm extends StatefulWidget {
  @override
  _SearchFormState createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  Prediction addressPred;
  bool addesIsSelected = false;
  Prediction addressPredDest;
  bool addesIsSelectedDest = false;

  @override
  Widget build(BuildContext context) {
    final locData = Provider.of<LocationProvider>(context);
    final mediaQuery = MediaQuery.of(context);
    return Container(
      width: double.infinity,
      color: Colors.green[200],
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 5),
          ),
          Center(
              child: Icon(
            Icons.add_road_rounded,
            color: Colors.white,
          )),
          Padding(
            padding: EdgeInsets.only(right: 10),
          ),
          Flexible(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: mediaQuery.padding.top,
                ),
                TextField(
                  decoration: InputDecoration(
                      hintText: addesIsSelected == false
                          ? 'From:'.toString()
                          : addressPred.description.toString(),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white))),
                  onTap: () async {
                    Prediction p = await PlacesAutocomplete.show(
                        mode: Mode.overlay,
                        context: context,
                        apiKey: 'AIzaSyCdLd1RuWXhZRK-QxroPh7d1ok1n1K6C9o');

                    displayPrediction(p, locData);
                    setState(() {
                      addressPred = p;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(
                      hintText: addesIsSelectedDest == false
                          ? 'To:'.toString()
                          : addressPredDest.description.toString(),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white))),
                  onTap: () async {
                    Prediction p = await PlacesAutocomplete.show(
                        mode: Mode.overlay,
                        context: context,
                        apiKey: 'AIzaSyCdLd1RuWXhZRK-QxroPh7d1ok1n1K6C9o');

                    displayPredictionDest(p, locData);
                    setState(() {
                      addressPredDest = p;
                    });
                  },
                ),
                SizedBox(
                  height: 30,
                ),
                /*
                  Center(
                    child: InkWell(
                      child: Icon(Icons.search),
                      onTap: () {
                        // ignore: unnecessary_statements
                        locData.toggleSelected();
                      },
                    ),
                  )
                  */
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

  Future<Null> displayPrediction(Prediction p, LocationProvider loc) async {
    setState(() {
      addesIsSelected = false;
    });

    if (p != null) {
      GoogleMapsPlaces _places = GoogleMapsPlaces(
        apiKey: 'AIzaSyCdLd1RuWXhZRK-QxroPh7d1ok1n1K6C9o',
        apiHeaders: await GoogleApiHeaders().getHeaders(),
      );
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;
      setState(() {
        addesIsSelected = true;
      });
      loc.updateLocSource(lat, lng);
      print(p.description);
      print(lat);
      print(lng);
    }
  }

  Future<Null> displayPredictionDest(Prediction p, LocationProvider loc) async {
    setState(() {
      addesIsSelectedDest = false;
    });
    if (p != null) {
      GoogleMapsPlaces _places = GoogleMapsPlaces(
        apiKey: 'AIzaSyCdLd1RuWXhZRK-QxroPh7d1ok1n1K6C9o',
        apiHeaders: await GoogleApiHeaders().getHeaders(),
      );
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;
      setState(() {
        addesIsSelectedDest = true;
      });
      loc.updateLocDest(lat, lng);
      print(p.description);
      print(lat);
      print(lng);
    }
  }
}
