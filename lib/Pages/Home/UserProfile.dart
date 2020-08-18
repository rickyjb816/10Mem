import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ten_mem/Models/User.dart';
import 'package:ten_mem/Services/Authentication.dart';
import 'package:ten_mem/Services/Database.dart';
import 'package:ten_mem/Shared/Constants.dart';
import 'package:ten_mem/Shared/CustomDialog.dart';
import 'package:ten_mem/main.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

  final AuthService _auth = AuthService();
  User user;

  @override
  void initState() {
    super.initState();
    /*if(user.showHelp) {
      showDialog(
        context: context,
        builder: (BuildContext context) =>
            CustomDialog(
              title: "User Profile",
              description:
              "This is your profile page. Here you'll be able to see your profile",
              buttonText: "Okay",
              userUid: 'user.uid',
            ),
      );
    }*/
  }

  @override
  Widget build(BuildContext context) {

    final UserMini userMini = Provider.of<UserMini>(context);

    return StreamBuilder<Object>(
      stream: DatabaseService(uid: userMini.uid).user,
      builder: (context, snapshot) {

        user = snapshot.data;

        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text("User's Profile"),
              backgroundColor: mainColor,
            ),
            backgroundColor: Colors.grey,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 40,),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('In the full version you will be able to edit your profile details and use this page to manage Memmoris that you are included in from other users.', textScaleFactor: 1.5, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20,),),
                ),
                SizedBox(height: 40,),
                RaisedButton(
                  color: mainColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
                  textColor: Colors.white,
                  onPressed: () async {
                    await _auth.signOut();
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Text('Logout', textScaleFactor: 1.5,),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
