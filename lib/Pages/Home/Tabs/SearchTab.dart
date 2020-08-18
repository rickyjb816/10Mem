import 'package:flutter/material.dart';
import 'package:ten_mem/Shared/Loading.dart';

class SearchTab extends StatefulWidget {
  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Center(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('This Service Will Be Available In The Final Version Of The App', style: TextStyle(color: Colors.white, fontSize: 40,), textAlign: TextAlign.center,)
          )
      ),
    );
  }
}