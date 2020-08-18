import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ten_mem/Models/Memory.dart';
import 'package:ten_mem/Models/User.dart';
import 'file:///S:/Freelance%20Work/ten_mem/lib/Pages/Home/Tiles/EndTile.dart';
import 'package:ten_mem/Pages/Home/Tiles/MemoryTile.dart';
import 'package:ten_mem/Pages/Home/Tiles/UserTile.dart';
import 'package:ten_mem/Services/Database.dart';
import 'package:ten_mem/Shared/Constants.dart';
import 'package:ten_mem/Shared/CustomDialog.dart';
import 'package:ten_mem/Shared/Loading.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class MemoriesTab extends StatefulWidget {
  @override
  _MemoriesTabState createState() => _MemoriesTabState();
}

class _MemoriesTabState extends State<MemoriesTab> {

  UserMini user;

  @override
  Widget build(BuildContext context) {

    user = Provider.of<UserMini>(context);

    return MultiProvider(
      providers: [
        StreamProvider<User>.value(value: DatabaseService(uid: user.uid).user),
        StreamProvider<List<MemoryMini>>.value(value: DatabaseService(uid: user.uid).memoryMini)
      ],
      child: user == null ? Loading() : Scaffold(
        extendBody: true,
        body: MemoriesWidget(),
      )
    );
  }




}



class UserDisplayWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    User user = Provider.of<User>(context);

    //Source.cache;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          CircleAvatar(
              radius: 20.0,
              backgroundImage: NetworkImage(user.profileImage)
          ),
          SizedBox(width: 10),
          Text(user.username)
        ],
      ),
    );
  }
}


class MemoriesWidget extends StatefulWidget {
  @override
  _MemoriesWidgetState createState() => _MemoriesWidgetState();
}

class _MemoriesWidgetState extends State<MemoriesWidget> {

  User user;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () => showCustomDialog(context, user));
  }

  @override
  Widget build(BuildContext context) {

    List<MemoryMini> memories = Provider.of<List<MemoryMini>>(context);
    user = Provider.of<User>(context);

    return memories == null || user == null ? Loading() : StaggeredGridView.countBuilder(
      crossAxisCount: 2,
      itemCount: memories.length < 10 ? memories.length+1 : 10+1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return UserTile(user: user);
        } else {
          return MemoryTile(memoryMini: memories[index-1], tag: 'memory${index-1}');
        }
      },
      staggeredTileBuilder: (int index) => index == 0
          ? new StaggeredTile.fit(2)
          : new StaggeredTile.fit(1),
    );
  }

  void showCustomDialog(BuildContext context, User currentUser) {
    //User tempUser = Provider.of<User>(context);
    if(user.showHelp) {
      showDialog(
        context: context,
        builder: (BuildContext context) =>
            CustomDialog(
              title: "Add A Memmori",
              description:
              "To add new Memmori's tap the plus at the bottom of the screen",
              buttonText: "Okay",
              userUid: user.uid,
            ),
      );
    }
  }
}