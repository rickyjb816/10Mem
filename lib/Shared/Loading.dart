import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ten_mem/Shared/Constants.dart';

class Loading extends StatelessWidget {

  final String text;

  Loading({this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: mainColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SpinKitChasingDots(
                  color: secondaryColor,
                  size: 100.0
              ),
              SizedBox(height: 40,),
              Text(text, style: TextStyle(color: Colors.white, fontSize: 20, decoration: TextDecoration.none), textAlign: TextAlign.center,),
            ],
          ),
        )
    );
  }
}