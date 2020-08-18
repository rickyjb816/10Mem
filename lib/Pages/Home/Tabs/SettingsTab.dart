import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info/package_info.dart';
import 'package:ten_mem/Models/User.dart';
import 'package:ten_mem/Services/Authentication.dart';
import 'package:ten_mem/Services/Database.dart';
import 'package:ten_mem/Shared/Constants.dart';
import 'package:ten_mem/Shared/Loading.dart';

class SettingsTab extends StatefulWidget {
  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {

  final AuthService _auth = AuthService();

  bool notificationSettings;
  bool lightDarkMode;
  bool visibility;

  @override
  Widget build(BuildContext context) {

    String appName;
    String version;

    final user = Provider.of<UserMini>(context);

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      appName = packageInfo.appName;
      String packageName = packageInfo.packageName;
      version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;
    });

    return StreamBuilder<UserSettings>(
        stream: DatabaseService(uid: user.uid).userSettings,
        builder: (context, snapshot) {
          if(snapshot.hasData){

            UserSettings userSettings = snapshot.data;

            return Scaffold(
              backgroundColor: Colors.grey,
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 20),
                      Text("SETTINGS -", style: TextStyle(color: Colors.white, fontSize: 40,), textAlign: TextAlign.left,),
                      SizedBox(height: 10),
                      Text("This Service will be available in the final version and will include a number of options to improve access for users with vision and hearing impairments, as well as tools to allow users to customise and personalise the appearance of the app", style: TextStyle(color: Colors.white, fontSize: 20,), textAlign: TextAlign.left),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Loading();
          }
        }
    );
  }
}

//Column(
//                mainAxisAlignment: MainAxisAlignment.center,
//                crossAxisAlignment: CrossAxisAlignment.start,
//                children: <Widget>[
//                  Text('Notifications'),
//                  Switch(
//                    value: notificationSettings ?? userSettings.notifications,
//                    activeColor: mainColor,
//                    onChanged: (val) async {
//                      setState(() async {
//                        notificationSettings = val;
//                        await DatabaseService(uid: userSettings.uid).updateUserSettings('settings_notifications', notificationSettings);
//                        //Needs to update the notification settings so it doesn't send them to the user or does depending on the setting
//                      }
//                      );
//                    },
//                  ),
//                  Text('Light Mode'),
//                  Switch(
//                    value: lightDarkMode ?? userSettings.lightDarkMode,
//                    activeColor: mainColor,
//                    onChanged: (val) async {
//                      setState(() async {
//                        lightDarkMode = val;
//                        //update Theme
//                        await DatabaseService(uid: userSettings.uid).updateUserSettings('settings_light_dark_mode', lightDarkMode);
//                      }
//                      );
//                    },
//                  ),
//                  Text('Visibility'),
//                  Switch(
//                    value: visibility ?? userSettings.visibility,
//                    activeColor: mainColor,
//                    onChanged: (val) async {
//                      setState(() async {
//                        visibility = val;
//                        await DatabaseService(uid: userSettings.uid).updateUserSettings('settings_visibility', visibility);
//                        //Doesn't Need to do anything just need to make sure this is checked when searching
//                      }
//                      );
//                    },
//                  ),
//                  RaisedButton(
//                    onPressed: () {
//                      showAboutDialog(
//                          context: context,
//                          applicationName: appName,
//                          applicationLegalese: 'This is a test for the legal information'
//                      );
//                      //Would like a better way of displaying this
//                    },
//                    child: Text('Legal Information'),
//                  ),
//                  RaisedButton(
//                    onPressed: () {
//                      showAboutDialog(
//                          context: context,
//                          applicationName: appName,
//                          applicationLegalese: 'This is a test for the Help and Support'
//                      );
//                      //Would like a better way of displaying this
//                    },
//                    child: Text('Help and Support'),
//                  ),
//                  RaisedButton(
//                    onPressed: () async {
//                      await _auth.signOut();
//                    },
//                    child: Text('Sign out'),
//                  ),
//                  RaisedButton(
//                    onPressed: () async {
//                      await _auth.deleteAccount();
//                    },
//                    child: Text('Delete Account'),
//                  ),
//                  Text('$appName version:$version'),
//                ],
//              ),

