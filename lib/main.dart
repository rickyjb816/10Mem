import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ten_mem/wrapper.dart';
import 'package:flutter/services.dart';
import 'Models/User.dart';
import 'Pages/Splash_Screen.dart';
import 'Services/Authentication.dart';
import 'Shared/CustomDialog.dart';

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
              home: SplashScreen()
          ),
        )
    );
  }
}
