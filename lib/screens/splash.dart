import 'package:flutter/material.dart';

class Splash extends StatelessWidget {
 @override
 Widget build(BuildContext context) {
   return Center(
     child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Image.asset('assets/images/icon.png'),
          Image(
            image: AssetImage('assets/images/fest-logo.png'),
            height: 80 ,
          )
        ],
     )
   );
 }
}
