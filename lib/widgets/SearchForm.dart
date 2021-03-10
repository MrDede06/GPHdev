import 'package:flutter/material.dart';
import 'package:stateTrial/providers/LocationProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'dart:async';
import 'package:flutter_bounce/flutter_bounce.dart';

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
    return Container(
      width: double.infinity,
      color: Colors.black54,
      child: Card(
        color: Colors.green[200],
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 5),
            ),
            Center(child: Icon(Icons.add_road_rounded)),
            Padding(
              padding: EdgeInsets.only(right: 15),
            ),
            Flexible(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(15)),
                    child: RaisedButton(
                      color: Colors.green[100],
                      onPressed: () async {
                        // show input autocomplete with selected mode
                        // then get the Prediction selected

                        Prediction p = await PlacesAutocomplete.show(
                            mode: Mode.overlay,
                            context: context,
                            apiKey: 'AIzaSyCdLd1RuWXhZRK-QxroPh7d1ok1n1K6C9o');

                        displayPrediction(p);
                        setState(() {
                          addressPred = p;
                        });
                      },
                      child: addesIsSelected == false
                          ? Text('Find address')
                          : Text(
                              addressPred.description,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              //                           overflow: TextOverflow.ellipsis,
                            ),
                    ),
                  ),
                  Container(
                    child: RaisedButton(
                      color: Colors.green[100],
                      onPressed: () async {
                        // show input autocomplete with selected mode
                        // then get the Prediction selected

                        Prediction p = await PlacesAutocomplete.show(
                            mode: Mode.overlay,
                            context: context,
                            apiKey: 'AIzaSyCdLd1RuWXhZRK-QxroPh7d1ok1n1K6C9o');

                        displayPredictionDest(p);
                        setState(() {
                          addressPredDest = p;
                        });
                      },
                      child: addesIsSelectedDest == false
                          ? Text('Find address')
                          : Text(
                              addressPredDest.description,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Null> displayPrediction(Prediction p) async {
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
      print(p.description);
      print(lat);
      print(lng);
    }
  }

  Future<Null> displayPredictionDest(Prediction p) async {
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
      print(p.description);
      print(lat);
      print(lng);
    }
  }
}
