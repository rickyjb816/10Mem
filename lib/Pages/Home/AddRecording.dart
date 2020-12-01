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
import 'package:ten_mem/Models/Memory.dart';
import 'package:ten_mem/Services/Database.dart';
import 'package:ten_mem/Shared/Constants.dart';
import 'package:ten_mem/Shared/CustomDialog.dart';
import 'package:ten_mem/Shared/Loading.dart';
import 'package:uuid/uuid.dart';

class AddRecording extends StatefulWidget {

  final String memoryUid;
  final Memory memory;

  AddRecording({this.memoryUid, this.memory});

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

    return NewRecordingWidget(memoryUid: widget.memoryUid, memory: widget.memory,);
  }
}


class NewRecordingWidget extends StatefulWidget {
  final String memoryUid;
  final Memory memory;

  NewRecordingWidget({this.memoryUid, this.memory});

  @override
  _NewRecordingWidgetState createState() => _NewRecordingWidgetState();
}

class _NewRecordingWidgetState extends State<NewRecordingWidget> {
  final int _numPages = 3;
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
        color: isActive ? charcoalColor : Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  TextEditingController _title = TextEditingController();

  String stopWatchTime = '00:00:00';
  var swatch = Stopwatch();
  final dur = const Duration(seconds: 1);

  startTimer() {
    Timer(dur, updateTimer);
  }

  updateTimer() {
    if(swatch.isRunning) {
      startTimer();
      setState(() {
        stopWatchTime = swatch.elapsed.inHours.toString().padLeft(2, '0') + ':' +
            (swatch.elapsed.inMinutes%60).toString().padLeft(2, '0') + ':' +
            (swatch.elapsed.inSeconds%60).toString().padLeft(2, '0');
      });
    }
  }

  startStopWatch() {
    swatch.start();
    startTimer();
  }

  stopStopWatch() {
    swatch.stop();

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
        startStopWatch();
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
    stopStopWatch();
    setState(() {
      _isRecording = isRecording;
      _recording = recording;
    });
    _pageController.nextPage(
      duration: Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  _getRecordingDuration() {
      return _recording.duration != null ? _recording.duration.toString().split('.')[0] : stopWatchTime;
  }

  void showCustomDialog(BuildContext context) {
    //User tempUser = Provider.of<User>(context);
      showDialog(
        context: context,
        builder: (BuildContext context) =>
            CustomDialog(
              title: "Add A Narration",
              description:
              "This is a screen that will tell the user how to upload a recording to a memory",
              buttonText: "Okay",
              userUid: 'user.uid',
            ),
      );
  }

  @override
  void dispose() {
    super.dispose();
    narration = null;
    _recording = null;
  }

  String errorMessage = '';
  int questionIndex = 0;

  @override
  Widget build(BuildContext context) {

    _recording = new Recording();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    //questionIndex = 0;
    //String question = values.keys.elementAt(questionIndex);


    return loading ? Loading(text: 'Your Recording Is Being Uploaded') : Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SafeArea(
          child: Container(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    height: 500.0,
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
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                    hintText: 'Title', prefixIcon: Icon(Icons.title, color: charcoalColor), labelText: 'Title', labelStyle: TextStyle(color: charcoalColor)),
                              )
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Flexible(
                              flex: 2,
                              child: Center(
                                  child: Text('Questions', style: kSubtitleStyle)
                              ),
                            ),
                            Flexible(
                              flex: 3,
                              child: SizedBox(
                                width: width*0.99,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      fit: FlexFit.tight,
                                      child: IconButton(
                                        icon: Icon(Icons.chevron_left),
                                        onPressed: () {
                                          setState(() {
                                            if(questionIndex-1 > 0)
                                              questionIndex--;
                                          });
                                        },
                                      ),
                                    ),
                                    Flexible(
                                      flex: 8,
                                      fit: FlexFit.tight,
                                      child: Card(
                                        child: Container(
                                          child: Row(
                                            children: [
                                              Checkbox(
                                                  value: values.values.elementAt(questionIndex),
                                                  onChanged: (bool val) {
                                                    setState(() {
                                                      values[values.keys.elementAt(questionIndex)] = val;
                                                      if(questionIndex+1 < values.length)
                                                        questionIndex++;
                                                    });
                                                  }),
                                              Flexible(child: Text(values.keys.elementAt(questionIndex)))
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      fit: FlexFit.tight,
                                      child: IconButton(
                                        icon: Icon(Icons.chevron_right),
                                        onPressed: () {
                                          setState(() {
                                            if(questionIndex+1 < values.length)
                                              questionIndex++;
                                          });

                                        }
                                      )
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Flexible(
                                flex: 1,
                                child: SizedBox(height: 50)
                            ),
                            Flexible(
                              flex: 12,
                              child: Center(
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        border: Border.all(
                                          width: 4,
                                          color: charcoalColor,
                                    )),
                                    height: height*0.8,
                                    width: width*0.5,
                                    child: Image.network(widget.memory.image, fit: BoxFit.fill,)
                                ),
                              ),
                            ),
                            SizedBox(height: 25.0),
                            Center(
                              child: Text(
                                'Record your Narration',
                                style: kTitleStyle,
                              ),
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
                            Center(child: Text('Duration: ${_getRecordingDuration()}', style: kSubtitleStyle,)),
                            Center(child: Text(errorMessage, style: kSubtitleStyle.copyWith(color: Colors.red),)),
                            SizedBox(height: 40),

                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              //crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Preview And Upload',
                                  style: kTitleStyle,
                                ),
                                SizedBox(height: 15.0),
                                Text(
                                  'Title: ${_title.text}',
                                  style: kSubtitleStyle,
                                ),
                                SizedBox(height: 15.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    RaisedButton(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Icon(Icons.play_arrow, size: 50,),
                                            Text("Preview", style: TextStyle(fontSize: 20),)
                                          ],
                                        ),
                                      ),
                                      color: mainColor,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
                                      textColor: Colors.white,
                                      onPressed: () {
                                        AudioPlayer().play(narration.path, isLocal: true);
                                      },
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    RaisedButton(
                                      color: mainColor,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
                                      textColor: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Icon(Icons.file_upload, size: 50),
                                            Text("Upload", style: TextStyle(fontSize: 20))
                                          ],
                                        ),
                                      ),
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
                              ],
                            ),
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
                                  color: charcoalColor,
                                  size: 30.0,
                                ),
                                SizedBox(width: 10.0),
                                Text(
                                  'Previous',
                                  style: TextStyle(
                                    color: charcoalColor,
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
                              if(_currentPage == 0) {
                                Future.delayed(Duration(milliseconds: 500), () => showCustomDialog(context));
                              }
                              if(_currentPage == 1) {
                                if(narration != null) {
                                  _pageController.nextPage(
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.ease,
                                  );
                                  }
                                else {
                                  setState(() {
                                    errorMessage = 'Please Record Some Narration';
                                  });
                                  }
                              }
                              else {
                                _pageController.nextPage(
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.ease,
                                );
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  'Next',
                                  style: TextStyle(
                                    color: charcoalColor,
                                    fontSize: 22.0,
                                  ),
                                ),
                                SizedBox(width: 10.0),
                                Icon(
                                  Icons.arrow_forward,
                                  color: charcoalColor,
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
      ),
    );
  }
}



class RecordingPage extends StatefulWidget {

  final Function start;
  final Function stop;

  RecordingPage({this.start, this.stop});

  @override
  _RecordingPageState createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {

  _getRecordingDuration() {
    return _recording.duration != null ? _recording.duration.toString().split('.')[0] : stopWatchTime;
  }

  String errorMessage = '';

  String stopWatchTime = '00:00:00';
  var swatch = Stopwatch();
  final dur = const Duration(seconds: 1);

  startTimer() {
    Timer(dur, updateTimer);
  }

  updateTimer() {
    if(swatch.isRunning) {
      startTimer();
      setState(() {
        stopWatchTime = swatch.elapsed.inHours.toString().padLeft(2, '0') + ':' +
            (swatch.elapsed.inMinutes%60).toString().padLeft(2, '0') + ':' +
            (swatch.elapsed.inSeconds%60).toString().padLeft(2, '0');
      });
    }
  }

  startStopWatch() {
    swatch.start();
    startTimer();
  }

  stopStopWatch() {
    swatch.stop();

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                onPressed: _isRecording ? null : widget.start,
                child: new Text("Start"),
                color: Colors.green,
              ),
              SizedBox(width: 20,),
              RaisedButton(
                onPressed: _isRecording ? widget.stop : null,
                child: new Text("Stop"),
                color: Colors.red,
              ),
            ],
          ),
          SizedBox(height: 20),
          Center(child: Text('Duration: ${_getRecordingDuration()}', style: kSubtitleStyle,)),
          Center(child: Text(errorMessage, style: kSubtitleStyle.copyWith(color: Colors.red),)),
          SizedBox(height: 40),
          Center(
              child: Text('Questions', style: kSubtitleStyle)
          ),
          SizedBox(
            height: 192,
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

