import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ten_mem/Models/Recordings.dart';

class RecordingTile extends StatefulWidget {

  final Recording recording;
  final int index;
  final Function playingIndex;
  RecordingTile({this.recording, this.index, this.playingIndex});

  @override
  _RecordingTileState createState() => _RecordingTileState();
}

class _RecordingTileState extends State<RecordingTile> with WidgetsBindingObserver {

  AudioPlayer audioPlayer = AudioPlayer();
  IconData icon = Icons.play_arrow;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    audioPlayer.stop();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch(state){
      case AppLifecycleState.paused:{
        audioPlayer.stop();
        break;
      }
      case AppLifecycleState.inactive:{
        audioPlayer.stop();
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    //List<bool> isPlayingList = Provider.of<List<bool>>(context);

    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        color: Colors.white,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Builder(
            builder: (BuildContext context) {
              final isPlayingList = Provider.of<List<bool>>(context);
              return ListTile(
                //leading: Icon(isPlayingList[widget.index] ? Icons.pause : Icons.play_arrow, size: 40,),
                title: Text('${widget.index+1}. ${widget.recording.title}'),
                subtitle: Text('Recorded on: ${widget.recording.creationDate.toDate().day}/${widget.recording.creationDate.toDate().month}/${widget.recording.creationDate.toDate().year}'),
                onTap: () {widget.playingIndex(widget.index, widget.recording.recordingUri);},
              );
            },
            ),
          )
        ),
      );
  }
}