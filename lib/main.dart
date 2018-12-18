import 'package:cerebro_flutter/screens/splash.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

final dummySnapshot = [
  {"name": "TechHunt", "fee": 150},
  {"name": "CS:Go", "fee": 150},
  {"name": "Big Tech Quiz", "fee": 100},
  {"name": "Flutter Hackathon", "fee": 50},
  {"name": "Typeracer", "fee": 70},
];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Events',
      home: Splash(),
      theme: ThemeData.dark(),
    );
  }
}
