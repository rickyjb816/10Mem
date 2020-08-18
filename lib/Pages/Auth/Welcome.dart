import 'package:flutter/material.dart';
import 'LogIn.dart';
import 'Register.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {

  bool showSignIn = true;

  @override
  Widget build(BuildContext context) {
    return showSignIn ? LoginPage(toggleView: toggleView) : SignUp(toggleView: toggleView);
  }


  void navigateToSignIn(){
    Navigator.push(context,MaterialPageRoute(builder: (context) => LoginPage(), fullscreenDialog: true));
  }

  void navigateToSignUp(){
    Navigator.push(context,MaterialPageRoute(builder: (context) => SignUp(), fullscreenDialog: true));
  }

  void toggleView(){
    setState(() => showSignIn = !showSignIn);
  }
}