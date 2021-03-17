import 'package:flutter/material.dart';
import 'package:stateTrial/providers/LocationProvider.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import '../widgets/UserForm.dart';
import '../widgets/InfoTabMenus.dart';
import '../widgets/SearchForm.dart';
import '../widgets/MapView.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/CarSearch.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final locData = Provider.of<LocationProvider>(context);

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
            child: Column(
              children: <Widget>[SearchForm(), CarSearch(), InfoTabMenus()],
            )),
        body: MapView());
  }
}
