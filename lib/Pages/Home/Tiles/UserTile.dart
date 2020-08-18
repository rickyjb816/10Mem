import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ten_mem/Models/User.dart';
import 'package:ten_mem/Pages/Home/UserProfile.dart';

class UserTile extends StatelessWidget {

  final User user;

  UserTile({this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 4.0),
      child: SizedBox(
        height: 100,
        child: GestureDetector(
          onTap: () {
            var route = ModalRoute.of(context).settings.name;
            Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfile(), settings: RouteSettings(name: route)));
          },
          child: Card(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                    radius: 35.0,
                    backgroundImage: NetworkImage(user.profileImage)
                ),
                SizedBox(width: 10),
                Flexible(
                    child: Text("${user.username}'s Memories", style: TextStyle(fontSize: 20), overflow: TextOverflow.ellipsis,)
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}