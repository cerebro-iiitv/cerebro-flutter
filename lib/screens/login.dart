import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

class LoginPage extends StatefulWidget {
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<FirebaseUser> _handleSignIn() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    FirebaseUser user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    print("signed in " + user.displayName);
    return user;
  }

  Future<void> signOut() async {
    return _auth.signOut();
  }
  

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SizedBox(
          height: 100.0,
        ),
        Container(
            padding: EdgeInsets.symmetric(
              vertical: 120.0,
              horizontal: 50.0,
            ),
            child: Image(
              image: AssetImage('assets/images/fest-logo.png'),
              height: 150,
            )),
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
              SizedBox(height: 10.0,),
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
