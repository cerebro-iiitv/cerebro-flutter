import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cerebro_flutter/utils/authManagement.dart';

class LoginPage extends StatefulWidget {
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  initState() {
    super.initState();
  }

  Future<void> _handleSignIn() async {
    FirebaseUser user = await AuthManager().signIn();
    if (user != null) {
      Navigator.of(context).pushReplacementNamed('/events');
    }
  }

  @override
  Widget build(BuildContext context) {
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    var iconHeight, _verticalPadding;
    if (currentOrientation == Orientation.portrait) {
      iconHeight = 150.0;
      _verticalPadding = 110.0;
    } else {
      iconHeight = 120.0;
      _verticalPadding = 80.0;
    }
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(
            vertical: _verticalPadding,
            horizontal: 50.0,
          ),
          alignment: Alignment.topCenter,
          child: Image(
            image: AssetImage('assets/images/fest-logo.png'),
            height: iconHeight,
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              OutlineButton(
                borderSide: BorderSide(color: Colors.deepOrange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text('Login with Google'),
                onPressed: () => _handleSignIn(),
              ),
            ],
          ),
        )
      ],
    );
  }
}
