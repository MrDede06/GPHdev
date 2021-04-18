import 'package:flutter/material.dart';
import 'package:stateTrial/providers/LocationProvider.dart';
import 'package:provider/provider.dart';

class UserForm extends StatefulWidget {
  @override
  _UserForm createState() => _UserForm();
}

class _UserForm extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  double lattidute = 0;
  double longitude = 0;
  @override
  Widget build(BuildContext context) {
    final locData = Provider.of<LocationProvider>(context);
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            key: ValueKey('lattidute'),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter valid value';
              }
              return null;
            },
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Lattidute',
              hintStyle: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            onSaved: (value) {
              lattidute = double.parse(value);
            },
          ),
          SizedBox(height: 12),
          TextFormField(
            key: ValueKey('longtidute'),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter valid value';
              }
              return null;
            },
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Longtidute',
              hintStyle: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            onSaved: (value) {
              longitude = double.parse(value);
            },
          ),
          SizedBox(height: 12),
          RaisedButton(
            child: Text(
              "Check the location",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            onPressed: () {
              FocusScope.of(context).unfocus();
              _formKey.currentState.save();
              print(lattidute);
              //   locData.updateLocSource(lattidute, longitude, );
            },
          ),
        ],
      ),
    );
  }
}
