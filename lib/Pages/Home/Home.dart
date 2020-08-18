import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ten_mem/CustomUI/FABBottomAppBar.dart';
import 'package:ten_mem/Models/User.dart';
import 'package:ten_mem/Pages/Home/AddMemory.dart';
import 'package:ten_mem/Services/Database.dart';
import 'package:ten_mem/Shared/Constants.dart';
import 'package:ten_mem/Shared/Loading.dart';
import 'Tabs/FeedbackTab.dart';
import 'Tabs/MemoriesTab.dart';
import 'Tabs/SearchTab.dart';
import 'Tabs/SettingsTab.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int _currentIndex = 1;
  bool isfabVisible = true;

  void _selectedTab(int index) {
    setState(() {
      _currentIndex = index;
      isfabVisible = _currentIndex == 1;
    });
  }


  @override
  Widget build(BuildContext context) {

    final UserMini user = Provider.of<UserMini>(context);

    return StreamBuilder<Object>(
      stream: DatabaseService(uid: user.uid).user,
      builder: (context, snapshot) {

        User user = snapshot.data;

        return user == null ? Loading() : Scaffold(
          body: callPage(_currentIndex),
          floatingActionButton: Visibility(
            child: FloatingActionButton(
              backgroundColor: user.memoryCount < 10 ? mainColor : disabledColor,
              child: Icon(Icons.add),
              onPressed: () {
                var route = ModalRoute.of(context).settings.name;
                user.memoryCount < 10 ? Navigator.push(context, MaterialPageRoute(builder: (context) => AddMemory(), settings: RouteSettings(name: route))) : null;
                },
            ),
            visible: isfabVisible,
          ),
          extendBody: true,
          bottomNavigationBar: FABBottomAppBar(
            notchedShape: CircularNotchedRectangle(),
            onTabSelected: _selectedTab,
            unselectedColor: Colors.white70,
            selectedColor: Colors.white,
            backgroundColor: mainColor,
            items: [
              FABBottomAppBarItem(selectedIconData: MdiIcons.magnify, unselectedIconData: MdiIcons.magnify, text: 'Search'),
              FABBottomAppBarItem(selectedIconData: MdiIcons.plusBoxMultiple, unselectedIconData: MdiIcons.plusBoxMultipleOutline, text: 'Memories'),
              FABBottomAppBarItem(selectedIconData: Icons.thumb_up, unselectedIconData: MdiIcons.thumbUpOutline, text: 'Feedback'),
              FABBottomAppBarItem(selectedIconData: MdiIcons.cog, unselectedIconData: MdiIcons.cogOutline, text: 'Settings'),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          );
      }
    );
  }


  Widget callPage(int index){
    switch(index)
    {
      case 0:{ //Search Page - look at memories and find users
        return SearchTab();
      }
      case 1:{ //Home Page - shows user profile and people they are following
        return MemoriesTab();
      }
      case 2:{ //Memories Page - shows all 10 memories that the user has uploaded
        return FeedbackTab();
      }
      case 3:{ //Settings Page
        return SettingsTab();
      }
    }
  }
}