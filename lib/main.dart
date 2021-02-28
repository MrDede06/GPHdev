import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stateTrial/providers/LocationProvider.dart';
import 'package:provider/provider.dart';
import 'screens/TestScreen.dart';

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
    return ChangeNotifierProvider(
      create: (context) => LocationProvider(),
      child: MaterialApp(
        title: 'Green Power Hunters',
        theme: ThemeData(
          primaryColor: Colors.green[200],
          accentColor: Colors.green[500],
        ),
        home: TestScreen(),
      ),
    );
  }
}
