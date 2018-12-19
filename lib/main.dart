import 'package:cerebro_flutter/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:cerebro_flutter/screens/events.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Events',
      home: Splash(),
      theme: ThemeData.dark(),
      routes: {
        '/events': (context) => EventsPage(),
      },
    );
  }
}
