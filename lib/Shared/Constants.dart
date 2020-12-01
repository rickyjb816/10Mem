import 'package:flutter/material.dart';

const double radius = 30;

const textInputDecoration = InputDecoration(
    fillColor: Colors.white,
    filled: true,
    errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
        borderRadius: BorderRadius.all(Radius.circular(radius)),
    ),
    focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: mainColor),
        borderRadius: BorderRadius.all(Radius.circular(radius)),
    ),
    //hintStyle: TextStyle(color: Colors.black),
    labelStyle: TextStyle(color: mainColor),
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
        borderRadius: BorderRadius.all(Radius.circular(radius)),
    ),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: mainColor),
        borderRadius: BorderRadius.all(Radius.circular(radius)),
    )
);

const mainColor = Color.fromRGBO(0, 153, 153, 1);
const secondaryColor = Color.fromRGBO(0, 102, 102, 1);
const tertiaryColor = Color.fromRGBO(255, 255, 255, 1);
const disabledColor = Colors.grey;
const charcoalColor = Color.fromRGBO(54, 69, 79, 1);

const appIcon = 'assets/tenmemlogo.svg';

const double padding = 16.0;
const double avatarRadius = 66.0;

final kTitleStyle = TextStyle(
    color: charcoalColor,
    fontFamily: 'CM Sans Serif',
    fontSize: 20.0,
    height: 1.5,
);

final kSubtitleStyle = TextStyle(
    color: charcoalColor,
    fontSize: 18.0,
    height: 1.2,
);