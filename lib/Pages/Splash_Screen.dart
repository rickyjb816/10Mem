import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ten_mem/Shared/Constants.dart';
import 'dart:async';

import '../wrapper.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState(){
    super.initState();

    _mockCheckForSession().then(
            (status){
          if(status){
            _navigateToHome();
          }
        }
    );
  }

  Future<bool> _mockCheckForSession() async {
    await Future.delayed(Duration(seconds: 5), (){});
    return true;
  }

  void _navigateToHome(){
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (BuildContext context) => Wrapper())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    SvgPicture.asset(appIcon, width: 400, height: 400),
                  ],
                )
            )
        )
    );
  }
}