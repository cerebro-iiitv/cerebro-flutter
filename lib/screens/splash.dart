import 'package:cerebro_flutter/models/user.dart';
import 'package:cerebro_flutter/screens/login.dart';
import 'package:cerebro_flutter/screens/events.dart';
import 'package:cerebro_flutter/utils/authManagement.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';
import 'dart:convert';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => new _SplashState();
}

class _SplashState extends State<Splash> {
  final String _kUserPref = "UserPref";
  Widget _routingWidget = LoginPage();

  Future<Null> getSharedPref() async {
    final SharedPreferences _localPref = await SharedPreferences.getInstance();
    String userProfile = _localPref.getString(_kUserPref);
    // Check if user is already saved in Shared Preference then move to Events Page
    // and not to LoginPage
    if (userProfile != null) {
      print('Already present user: ' + userProfile);
      AuthManager().setCurrentUser(User.fromMap(json.decode(userProfile)));
      setState(() {
        _routingWidget = EventsPage();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getSharedPref();
  }

  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
        seconds: 4,
        navigateAfterSeconds: _routingWidget,
        title: Text(
          'Just wait a little longer...',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        image: Image(
          image: AssetImage('assets/images/fest-logo.png'),
          height: 120,
        ),
        backgroundColor: Colors.black,
        styleTextUnderTheLoader: TextStyle(),
        photoSize: 100.0,
        onClick: () => print("Clicked Logo"),
        loaderColor: Colors.orange);
  }
}
