import 'package:cerebro_flutter/screens/events.dart';
import 'package:cerebro_flutter/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => new _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
        seconds: 7,
        navigateAfterSeconds: LoginPage(),
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
