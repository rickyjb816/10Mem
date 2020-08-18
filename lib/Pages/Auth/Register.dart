import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ten_mem/Pages/Auth/LogIn.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ten_mem/Image_Capture.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ten_mem/Services/Authentication.dart';
import 'package:ten_mem/Shared/Constants.dart';
import 'package:ten_mem/Shared/Loading.dart';
import 'package:ten_mem/main.dart';
import 'package:uuid/uuid.dart';

class SignUp extends StatefulWidget {

  final Function toggleView;
  SignUp({this.toggleView});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  String _email, _password, _name;
  String error = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();
  bool loading = false;
  String filePath;

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      appBar: AppBar(
        title: Text(''),
        centerTitle: true,
        backgroundColor: mainColor,
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.person, color: Colors.white,),
            label: Text('Sign In Instead', style: TextStyle(color: Colors.white),),
            onPressed: () {
              widget.toggleView();
            },
          )
        ],
      ),
      backgroundColor: mainColor,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/authbg.png'), fit: BoxFit.cover)
        ),
        child: Center(
          child: Container(
            height: 500,
            width: 300,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(5),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), spreadRadius: 5, blurRadius: 7)]
            ),
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Sign Up', textScaleFactor: 3, style: TextStyle(color: mainColor),),
                    SizedBox(height: 20.0),
                    TextFormField(
                      validator: (input) =>
                      input.isEmpty
                          ? "Enter Valid Email Address"
                          : null,
                      onSaved: (input) => _email = input,
                      decoration: textInputDecoration.copyWith(hintText: 'Email', prefixIcon: Icon(Icons.email, color: mainColor), labelText: 'Email'),
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      validator: (input) =>
                      input.length < 6
                          ? 'needs to be atleast 8 characters'
                          : null,
                      onSaved: (input) => _password = input,
                      decoration: textInputDecoration.copyWith(hintText: 'Password', prefixIcon: Icon(Icons.lock, color: mainColor), labelText: 'Password', labelStyle: TextStyle(color: mainColor)),
                      obscureText: true,
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      validator: (input) =>
                      input.isEmpty
                          ? 'Enter Full Name'
                          : null,
                      onSaved: (input) => _name = input,
                      decoration: textInputDecoration.copyWith(hintText: 'Name', prefixIcon: Icon(Icons.person, color: mainColor), labelText: 'Name', labelStyle: TextStyle(color: mainColor)),
                    ),
                    SizedBox(height: 20.0),
                    Text('Add Image From:'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 10.0),
                        RaisedButton(
                          color: mainColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
                          textColor: Colors.white,
                          onPressed: () {
                            pickImage(ImageSource.camera);
                          },
                          child: Text('Camera'),
                        ),
                        SizedBox(width: 20.0),
                        RaisedButton(
                          color: mainColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
                          textColor: Colors.white,
                          onPressed: () {
                            pickImage(ImageSource.gallery);
                          },
                          child: Text('Device'),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.0),
                    Card(
                      color: mainColor,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                            child: Image.file(_imageFile ?? File(''), height: 200, width: 200, fit: BoxFit.cover, )),
                      )
                    ),
                    SizedBox(height: 30),
                    RaisedButton(
                      onPressed: signUp,
                      color: mainColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
                      textColor: Colors.white,
                      child: Container(
                          alignment: Alignment.center,
                          child: Text('Sign up', textScaleFactor: 1.5,)
                      ),
                    ),
                    SizedBox(height: 12.0,),
                    Text(
                        error,
                        style: TextStyle(color: Colors.red, fontSize: 14.0)
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


  Future<void> signUp() async {
    final formState = _formKey.currentState;
    if (formState.validate()) {
      formState.save();
      try {
        setState(() => loading = true);
        //await startUpload();
        dynamic result = await _auth.registerWithEmailAndPassword(_email, _password, _name, _imageFile);
        if (result == null) {
          setState(() {
            error = 'Please Supply a valid email';
            loading = false;
          });
        }
      } catch (e) {
        print(e.message);
      }
    }
  }

  File _imageFile;

  Future pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);

    setState(() {
      _imageFile = selected;
    });
    cropImage();
  }

  Future cropImage() async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: _imageFile.path,
      compressFormat: ImageCompressFormat.jpg,
      maxHeight: 500,
      maxWidth: 500,
      androidUiSettings: AndroidUiSettings(
          toolbarColor: Colors.grey,
          toolbarWidgetColor: Colors.white,
          toolbarTitle: 'Crop It'
      ),
    );

    setState(() {
      _imageFile = cropped ?? _imageFile;
    });
  }

  void clear() {
    setState(() {
      _imageFile = null;
    });
  }
}