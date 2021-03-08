import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stateTrial/screens/MainScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTime();
  }

  startTime() async {
    var duration = new Duration(seconds: 4);
    return new Timer(duration, route);
  }

  route() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => MainScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Image.asset("assets/images/logo1.png"),
            ),
            Padding(padding: EdgeInsets.only(top: 15)),
            Text(
              "Green Power Hunters",
              style: TextStyle(
                  fontSize: 30.0,
                  color: Colors.black54,
                  fontStyle: GoogleFonts.bigShouldersDisplay().fontStyle,
                  fontWeight: FontWeight.bold),
            ),
            Padding(padding: EdgeInsets.only(top: 15)),
            CircularProgressIndicator(
              backgroundColor: Colors.black54,
            )
          ],
        ),
      ),
    );
  }
}
