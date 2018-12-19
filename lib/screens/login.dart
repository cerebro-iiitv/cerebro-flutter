import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cerebro_flutter/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

class LoginPage extends StatefulWidget {
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final String _kUserPref = "UserPref";

  Future<Null> getSharedPref() async {
    final SharedPreferences _localPref = await SharedPreferences.getInstance();
    String userProfile = _localPref.getString(_kUserPref);
    if (userProfile != null) {
      print('Already present user: ' + userProfile);
      Navigator.pushNamed(context, '/events');
    }
  }

  @override
  initState() {
    super.initState();
    getSharedPref();
  }

  Future<FirebaseUser> _handleSignIn() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    FirebaseUser user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    print("signed in " + user.displayName);
    assert(user != null);
    User _loggedInUser = User.fromFirebaseUser(user);
    print(_loggedInUser.toString());

    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(_kUserPref, json.encode(_loggedInUser.toJson())).then((_) {
      print('Shared Preference saved');
      Navigator.pushNamed(context, '/events');
    }).catchError((_) {
      print('Unable to save to sharedPreference');
    });

    return user;
  }

  Future<void> signOut() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove(_kUserPref);
    print('User removed');
    return _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(
            vertical: 120.0,
            horizontal: 50.0,
          ),
          alignment: Alignment.topCenter,
          child: Image(
            image: AssetImage('assets/images/fest-logo.png'),
            height: 150,
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
                    borderRadius: BorderRadius.circular(20.0)),
                child: Text('Login with Google'),
                onPressed: () => _handleSignIn(),
              ),
              SizedBox(
                height: 10.0,
              ),
              OutlineButton(
                borderSide: BorderSide(color: Colors.deepOrange),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                child: Text('Logout'),
                onPressed: () => signOut(),
              ),
            ],
          ),
        )
      ],
    );
  }
}
