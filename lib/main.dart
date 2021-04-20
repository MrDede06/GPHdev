import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stateTrial/providers/ChargeStationProvider.dart';
import 'package:stateTrial/providers/LocationProvider.dart';
import 'package:stateTrial/providers/CarProvider.dart';
import 'package:stateTrial/screens/SplashScreen.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: LocationProvider(),
        ),
        ChangeNotifierProvider.value(
          value: CarProvider(),
        ),
        ChangeNotifierProvider.value(
          value: ChargeStationProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Green Power Hunters',
        theme: ThemeData(
          primaryColor: Colors.green[200],
          accentColor: Colors.green[500],
        ),
        home: SplashScreen(),
      ),
    );
  }
}
