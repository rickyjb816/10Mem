import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ten_mem/wrapper.dart';
import 'package:flutter/services.dart';
import 'Models/User.dart';
import 'Pages/Splash_Screen.dart';
import 'Services/Authentication.dart';
import 'Shared/CustomDialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_){
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserMini>.value(
        value: AuthService().user,
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if(!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus.unfocus();
            }
          },
          child: MaterialApp (
              debugShowCheckedModeBanner: false,
              home: _MessagerHandlerState()
          ),
        )
    );
  }
}

class _MessagerHandlerState extends StatefulWidget {
  @override
  __MessagerHandlerStateState createState() => __MessagerHandlerStateState();
}

class __MessagerHandlerStateState extends State<_MessagerHandlerState> {

  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();


  @override
  void initState() {
    super.initState();
    _fcm.configure(
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        //_navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        //_navigateToItemDetail(message);
      },
      onMessage: (Map<String, dynamic> message) async {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(title: Text(message['notification']['title']), subtitle: Text(message['notification']['body'])),
            actions: [FlatButton(child: Text('Ok'), onPressed: () => Navigator.of(context).pop(),)],
          )
      );
    },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrapper();
  }
}


