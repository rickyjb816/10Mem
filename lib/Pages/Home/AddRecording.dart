import 'dart:async';
import 'dart:io' as io;
import 'dart:math';

import 'package:audio_recorder/audio_recorder.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file/local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ten_mem/Services/Database.dart';
import 'package:ten_mem/Shared/Constants.dart';
import 'package:ten_mem/Shared/Loading.dart';
import 'package:uuid/uuid.dart';

class AddRecording extends StatefulWidget {

  final String memoryUid;

  AddRecording({this.memoryUid});

  @override
  _AddRecordingState createState() => _AddRecordingState();
}

String title;

//Voice Recording Stuff
String recordingErrorMsg = "Test";
Recording _recording = new Recording();
bool _isRecording = false;
Random random = new Random();
TextEditingController _controller = new TextEditingController();
LocalFileSystem localFileSystem;
io.File narration;

bool loading = false;

//Question Stuff
Map<String, bool> values = {
  'When was this photograph taken?': false,
  "Where was it taken?": false,
  "Whos in the photograph?": false,
  "What was happening when this photograph was taken?": false,
  "How does this photograph make you feel? Why?": false,
  "Who took the photograph?": false,
  "Why was it taken?": false,
  "Who are you and who's this person to you?": false,
  "What is this memory?" : false,
  "What does this mean to you?": false,
};

class _AddRecordingState extends State<AddRecording> {



  @override
  Widget build(BuildContext context) {

    return NewRecordingWidget(memoryUid: widget.memoryUid);
  }
}


class NewRecordingWidget extends StatefulWidget {
  final String memoryUid;

  NewRecordingWidget({this.memoryUid});

  @override
  _NewRecordingWidgetState createState() => _NewRecordingWidgetState();
}

class _NewRecordingWidgetState extends State<NewRecordingWidget> {
  final int _numPages = 4;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? tertiaryColor : Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  TextEditingController _title = TextEditingController();

  start() async {
    try {
      if (await Permission.microphone.isGranted) {
        String path;
        io.Directory appDocDirectory =
        await getApplicationDocumentsDirectory();
        path = appDocDirectory.path + '/' + Uuid().v4();
        recordingErrorMsg = "Recording";
        print("Start recording: $path");
        await AudioRecorder.start(path: path, audioOutputFormat: AudioOutputFormat.WAV);
        bool isRecording = await AudioRecorder.isRecording;
        setState(() {
          _recording = new Recording(duration: new Duration(), path: "");
          _isRecording = isRecording;
        });
      } else {
        await Permission.microphone.request();
        recordingErrorMsg = "You must accept permissions";
      }
    } catch (e) {
      print(e);
    }
  }

  stop() async {
    var recording = await AudioRecorder.stop();
    print("Stop recording: ${recording.path}");
    bool isRecording = await AudioRecorder.isRecording;
    recordingErrorMsg = recording.path;
    narration = io.File(recording.path);
    recordingErrorMsg = "Stopped";
    setState(() {
      _isRecording = isRecording;
      _recording = recording;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading ? Loading(text: 'Your Recording Is Being Uploaded') : Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.1, 0.4],
              colors: [
                mainColor,
                secondaryColor,
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  height: 600.0,
                  child: PageView(
                    physics: ClampingScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Give your recording a title',
                              style: kTitleStyle,
                            ),
                            SizedBox(height: 15.0),
                            TextField(
                              textCapitalization: TextCapitalization.sentences,
                              controller: _title,
                              decoration: textInputDecoration.copyWith(
                                  hintText: 'Title', prefixIcon: Icon(Icons.title, color: mainColor), labelText: 'Title', labelStyle: TextStyle(color: mainColor)),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Record your Narration',
                              style: kTitleStyle,
                            ),
                            SizedBox(height: 15.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                RaisedButton(
                                  onPressed: _isRecording ? null : start,
                                  child: new Text("Start"),
                                  color: Colors.green,
                                ),
                                SizedBox(width: 20,),
                                RaisedButton(
                                  onPressed: _isRecording ? stop : null,
                                  child: new Text("Stop"),
                                  color: Colors.red,
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Center(child: Text('Duration: ${_recording.duration.toString().split('.')[0]}', style: kSubtitleStyle,)),
                            SizedBox(height: 40),
                            Center(
                                child: Text('Questions', style: kSubtitleStyle)
                            ),
                            SizedBox(
                              height: 300,
                              child: ListView(
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                children: values.keys.map((String key) {
                                  return Card(
                                    child: CheckboxListTile(
                                      title: Text(key),
                                      value: values[key],
                                      onChanged: (bool value) {
                                        setState(() {
                                          values[key] = value;
                                        });
                                        },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Text(
                                'Preview',
                                style: kTitleStyle,
                              ),
                            ),
                            SizedBox(height: 15.0),
                            Text(
                              'Title: ${_title.text}',
                              style: kSubtitleStyle,
                            ),
                            RaisedButton(
                              child: Text('Play'),
                              color: mainColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
                              textColor: Colors.white,
                              onPressed: () {
                                AudioPlayer().play(narration.path, isLocal: true);
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Text(
                                'Upload',
                                style: kTitleStyle,
                              ),
                            ),
                            SizedBox(height: 15.0),
                            RaisedButton(
                              color: mainColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
                              textColor: Colors.white,
                              child: Text('Upload'),
                              onPressed: () async {
                                setState(() => loading = true);
                                dynamic result = await DatabaseService().uploadRecording(widget.memoryUid, narration, _title.text);
                                if(result == null) {
                                  setState(() {
                                    loading = false;
                                  });
                                }
                                Navigator.pop(context);
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageIndicator(),
                ),
                Expanded(
                  child: Align(
                    alignment: FractionalOffset.bottomRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _currentPage == 0 ? Text('') : FlatButton(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 30.0,
                              ),
                              SizedBox(width: 10.0),
                              Text(
                                'Previous',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22.0,
                                ),
                              ),
                            ],
                          ),
                          onPressed: () {
                            _pageController.previousPage(
                                duration: Duration(milliseconds: 500),
                                curve: Curves.ease);
                            },
                        ),
                        _currentPage == _numPages-1 ? Text('') : FlatButton(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.ease,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                'Next',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22.0,
                                ),
                              ),
                              SizedBox(width: 10.0),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 30.0,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}




class RecordingOrginal extends StatefulWidget {
  final String memoryUid;

  const RecordingOrginal({Key key, this.memoryUid});

  @override
  _RecordingOrginalState createState() => _RecordingOrginalState();
}

class _RecordingOrginalState extends State<RecordingOrginal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: <Widget>[
                Text('Narration'),
                TextField(
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (val) {setState(() => title = val);},
                    decoration: textInputDecoration.copyWith(hintText: 'Title', prefixIcon: Icon(Icons.title, color: mainColor), labelText: 'Title')),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: _isRecording ? null : start,
                      child: new Text("Start"),
                      color: Colors.green,
                    ),
                    SizedBox(width: 20,),
                    RaisedButton(
                      onPressed: _isRecording ? stop : null,
                      child: new Text("Stop"),
                      color: Colors.red,
                    ),
                  ],
                ),
                SizedBox(height: 40,),
                Text('Questions'),
                SizedBox(
                  height: 500,
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: values.keys.map((String key) {
                      return CheckboxListTile(
                        title: Text(key),
                        value: values[key],
                        onChanged: (bool value) {
                          setState(() {
                            values[key] = value;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                RaisedButton(
                  child: Text('Upload'),
                  onPressed: () async {
                    setState(() => loading = true);
                    dynamic result = await DatabaseService().uploadRecording(widget.memoryUid, narration, title);
                    if(result == null) {
                      setState(() {
                        loading = false;
                      });
                    }
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          ),
        )
    );
  }

  start() async {
    try {
      if (await Permission.microphone.isGranted) {
        String path;
        io.Directory appDocDirectory =
        await getApplicationDocumentsDirectory();
        path = appDocDirectory.path + '/' + Uuid().v4();
        recordingErrorMsg = "Recording";
        print("Start recording: $path");
        await AudioRecorder.start(path: path, audioOutputFormat: AudioOutputFormat.WAV);
        bool isRecording = await AudioRecorder.isRecording;
        setState(() {
          _recording = new Recording(duration: new Duration(), path: "");
          _isRecording = isRecording;
        });
      } else {
        await Permission.microphone.request();
        recordingErrorMsg = "You must accept permissions";
      }
    } catch (e) {
      print(e);
    }
  }

  stop() async {
    var recording = await AudioRecorder.stop();
    print("Stop recording: ${recording.path}");
    bool isRecording = await AudioRecorder.isRecording;
    recordingErrorMsg = recording.path;
    narration = io.File(recording.path);
    recordingErrorMsg = "Stopped";
    setState(() {
      _isRecording = isRecording;
    });
  }
}

