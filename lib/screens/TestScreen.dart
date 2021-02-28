import 'package:flutter/material.dart';
import 'package:stateTrial/providers/LocationProvider.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import '../widgets/UserForm.dart';
import '../widgets/MapView.dart';

class TestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final locData = Provider.of<LocationProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Container(
              child: Image.asset("assets/images/logo1.png"),
              height: 50,
            ),
          ),
          shadowColor: Colors.black,
          backgroundColor: Colors.green[200],
          actions: <Widget>[
            Bounce(
                duration: Duration(milliseconds: 200),
                onPressed: () {
                  print("Profile");
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
            child: Padding(
              padding: EdgeInsets.only(top: 80),
              child: SizedBox(
                height: 100,
                child: UserForm(),
              ),
            )),
        body: MapView());
  }
}
