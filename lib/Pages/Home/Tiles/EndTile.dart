import 'package:flutter/material.dart';
import 'package:ten_mem/Pages/Home/AddRecording.dart';

class RecordingEndTile extends StatelessWidget {

  final String memoryUid;

  RecordingEndTile({this.memoryUid});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 4.0),
      child: SizedBox(
        height: 100,
        child: Card(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: GestureDetector(
                child: Icon(Icons.add, size: 50,),
                onTap: () {
                  var route = ModalRoute.of(context).settings.name;
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddRecording(memoryUid: memoryUid), settings: RouteSettings(name: route)));
                }
            ),
          ),
        ),
      ),
    );
  }
}
