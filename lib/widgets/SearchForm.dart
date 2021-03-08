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

  @override
  Widget build(BuildContext context) {
    return Card(
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
          Column(
            children: <Widget>[
              SizedBox(
                height: 30,
              ),
              Container(
                child: RaisedButton(
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
                      addesIsSelected = true;
                    });
                  },
                  child: addesIsSelected == false
                      ? Text('Find address')
                      : Text(addressPred.description),
                ),
              ),
              Container(
                child: RaisedButton(
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
                      addesIsSelected = true;
                    });
                  },
                  child: addesIsSelected == false
                      ? Text('Find address')
                      : Text(addressPred.description),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      GoogleMapsPlaces _places = GoogleMapsPlaces(
        apiKey: 'AIzaSyCdLd1RuWXhZRK-QxroPh7d1ok1n1K6C9o',
        apiHeaders: await GoogleApiHeaders().getHeaders(),
      );
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;
      print(p.description);
      print(lat);
      print(lng);
    }
  }
}
