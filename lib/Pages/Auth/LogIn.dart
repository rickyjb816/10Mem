import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:ten_mem/Pages/Home/Home.dart';
import 'package:ten_mem/Services/Authentication.dart';
import 'package:ten_mem/Shared/Constants.dart';
import 'package:ten_mem/Shared/Loading.dart';

class LoginPage extends StatefulWidget {

  final Function toggleView;
  LoginPage({this.toggleView});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  String _email, _password;
  String error = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();
  bool loading = false;


  @override
  Widget build(BuildContext context) {

     return loading ? Loading() : Scaffold(
       //backgroundColor: mainColor,

        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/authbg.png'), fit: BoxFit.cover),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                height: 500,
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), spreadRadius: 5, blurRadius: 7)],
                ),
                //color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Form(
                  key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Login', textScaleFactor: 3, style: TextStyle(color: mainColor)),
                        SizedBox(height: 20.0),
                        TextFormField(
                          onChanged: (val) {
                            setState(() => _email = val);
                          },
                          validator: (input) => input.isEmpty ? "Enter Valid Email Address" : null,
                          onSaved: (input) => _email = input,
                          decoration: textInputDecoration.copyWith(hintText: 'Email', prefixIcon: Icon(Icons.email, color: mainColor), labelText: 'Email'),
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          onChanged: (val) {
                            setState(() => _password = val);
                          },
                          validator: (input) => input.length < 6 ? 'Your password needs to be atleast 6 characters' : null,
                          onSaved: (input) => _password = input,
                          decoration: textInputDecoration.copyWith(hintText: 'Password', prefixIcon: Icon(Icons.lock, color: mainColor), labelText: 'Password', labelStyle: TextStyle(color: mainColor)),
                          obscureText: true,
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: GestureDetector(
                              child: Text('Forgot Password?', style: TextStyle( fontWeight: FontWeight.bold, color: mainColor, decoration: TextDecoration.underline)),
                              onTap: () {},
                            ),
                          ),
                        ),
                        Text(
                            error,
                            style: TextStyle(color: Colors.red, fontSize: 14.0)
                        ),
                        SizedBox(height: 20.0),
                        RaisedButton(
                          onPressed: () async {
                            setState(() => loading = true);
                            dynamic result = await _auth.signInEmailAndPassword(_email, _password);
                            if(result == null) {
                              setState(() {
                                error = 'Invalid Email And/Or Password';
                                loading = false;
                              });
                            }
                          },
                          color: mainColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
                          textColor: Colors.white,
                          child: Container(
                            alignment: Alignment.center,
                              child: Text('Log in', textScaleFactor: 1.5,)
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Text('Or Sign In With:'),
                        RaisedButton.icon(
                          icon: Icon(MdiIcons.google),
                          label: Text('Google'),
                          color: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
                          textColor: Colors.white,
                          onPressed: () async {
                            setState(() => loading = true);
                            dynamic result = await _auth.googleSignIn();
                            if(result == null) {
                              setState(() {
                                error = 'Invalid Email And/Or Password';
                                loading = false;
                              });
                            }
                          },
                        ),

                        SizedBox(height: 25.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('New User? ', style: TextStyle(fontSize: 20),),
                            GestureDetector(
                              child: Text('Sign Up', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: mainColor, decoration: TextDecoration.underline)),
                              onTap: () {widget.toggleView();},
                            ),
                          ],

                        ),
                      ],
                    ),
                  ),
              ),
            ),
            ),
        ),
    );
  }

  Future<void> signIn() async {
    final formState = _formKey.currentState;
    if(formState.validate())
    {
      formState.save();
      try{

        AuthResult authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email, password: _password);
        FirebaseUser user = authResult.user;
        Navigator.push(context,MaterialPageRoute(builder: (context) => Home()));
      }catch(e){
        print(e.message);
      }
    }
  }
}
