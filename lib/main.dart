import 'package:cerebro_flutter/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:cerebro_flutter/screens/events.dart';

void main() => runApp(MyApp());

class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> anim,
      Animation<double> secondaryAnim, Widget child) {
    if (settings.isInitialRoute) return child;
    // Slide Transition for routing
    return SlideTransition(
      position: Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset.zero)
          .animate(anim),
      child: SlideTransition(
        position: Tween<Offset>(begin: Offset.zero, end: Offset(1.0, 0.0))
            .animate(secondaryAnim),
        child: child,
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Events',
      home: Splash(),
      theme: ThemeData.dark(),
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/events':
            return CustomRoute(
              builder: (_) => EventsPage(),
              settings: settings,
            );
        }
        assert(false);
      },
    );
  }
}
