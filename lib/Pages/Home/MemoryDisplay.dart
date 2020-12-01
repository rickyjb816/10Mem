import 'package:audioplayer/audioplayer.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ten_mem/Models/Memory.dart';
import 'package:ten_mem/Models/Recordings.dart';
import 'package:ten_mem/Models/User.dart';
import 'package:ten_mem/Pages/Home/MemoryInformation.dart';
import 'package:ten_mem/Pages/Home/Tiles/EndTile.dart';
import 'package:ten_mem/Pages/Home/Tiles/RecordingTile.dart';
import 'package:ten_mem/Services/Database.dart';
import 'package:ten_mem/Shared/Constants.dart';
import 'package:ten_mem/Shared/CustomDialog.dart';
import 'package:ten_mem/Shared/Loading.dart';
import 'package:video_player/video_player.dart';



class MemoryDisplay extends StatefulWidget {

  final MemoryMini memoryMini;
  final String tag;
  final Function toggleView;

  MemoryDisplay({this.memoryMini, this.tag, this.toggleView});

  @override
  _MemoryDisplayState createState() => _MemoryDisplayState();
}

class _MemoryDisplayState extends State<MemoryDisplay> with WidgetsBindingObserver{

  AudioPlayer audioPlayer = AudioPlayer();
  bool isInfoShowing = true;
  bool loading = false;
  Memory memory;

  VideoPlayerController videoPlayerController;
  ChewieController chewieController;
  Chewie playerWidget;


  @override
  Widget build(BuildContext context) {






    return StreamBuilder<Object>(
      stream: DatabaseService(uid: widget.memoryMini.uid).memory,
      builder: (context, snapshot) {

        memory = snapshot.data;

        return loading ? Loading(text: "Deleting Memmori") : Scaffold(
          appBar: AppBar(
            title: Text(memory.title),
            centerTitle: true,
            backgroundColor: mainColor,
            actions: <Widget>[
              FlatButton.icon(
                icon: Icon(Icons.delete, color: Colors.white,),
                label: Text('Delete', style: TextStyle(color: Colors.white),),
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });

                  await DatabaseService(uid: memory.userUid).updateUserMemoryCount(memory.userUid, 'memory_count', -1);
                  await DatabaseService(uid: memory.uid).deleteMemoryData(memory.imageRef);
                  Navigator.pop(context);
                },
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: 40),
                Card(
                  color: Color.fromRGBO(54, 69, 79, 1),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      overflow: Overflow.visible,
                      alignment: Alignment.bottomRight,
                      children: <Widget>[
                        GestureDetector(
                        onTap: () {
                          var route = ModalRoute.of(context).settings.name;
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ImageEnlarged(imageUrl: memory.image,), settings: RouteSettings(name: route)));
                        },
                          child: Hero(
                          tag: widget.tag,
                          child: _getVisualWidget('image', memory)
                          )
                        ),
                        Positioned(
                          right: -25,
                          child: RaisedButton(
                            onPressed: () => widget.toggleView(),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Icon(Icons.edit, size: 30,),
                            ),
                            color: mainColor,
                            shape: CircleBorder(),
                            //RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
                            textColor: Colors.white,
                          ),
                        ),
                        Positioned(
                          left: -25,
                          child: RaisedButton(
                            onPressed: () {
                              var route = ModalRoute.of(context).settings.name;
                              Navigator.push(context, MaterialPageRoute(builder: (context) => MemoryInformation(memory: memory), settings: RouteSettings(name: route)));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Icon(Icons.info, size: 30,),
                            ),
                            color: mainColor,
                            shape: CircleBorder(),
                            //RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
                            textColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                Container(
                  height: 600.0,
                  child: RecordingsTab(memory: memory)
                )
              ],
            ),
          )
        );
      }
    );
  }

  final int _numPages = 2;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  _memoryTabs() {
    return Row(
      children: [
        Expanded(
          child: RaisedButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
            onPressed: () {
              _currentPage = 0;
              _pageController.jumpToPage(_currentPage);
            },
            color: _currentPage == 0 ? Colors.white30 : Colors.grey,
            child: Text('Information'),
          ),
        ),
        Expanded(
          child: RaisedButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
            onPressed: () {
              _currentPage = 1;
              _pageController.jumpToPage(_currentPage);
            },
            color: _currentPage == 1 ? Colors.white30 : Colors.grey,
            child: Text('Recording'),
          ),
        ),
      ],
    );
  }

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
      width: isActive ? 148 : 148,
      decoration: BoxDecoration(
        color: isActive ? mainColor : secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    videoPlayerController.dispose();
    chewieController.dispose();
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void showCustomDialog(BuildContext context, User currentUser) {
    if(currentUser.showHelp) {
      showDialog(
        context: context,
        builder: (BuildContext context) =>
            CustomDialog(
              title: "User Profile",
              description:
              "This is your profile page. Here you'll be able to see your profile",
              buttonText: "Okay",
              userUid: currentUser.uid,
            ),
      );
    }
  }

  _getVisualWidget(String fileType, Memory memory) {
    switch(fileType){
      case 'image':{
        return Image.network(
            memory.image,
            fit: BoxFit.cover,
            height: 250,
            width: 250,
            loadingBuilder: (context, child, progress) {
              return progress == null ? child : CircularProgressIndicator();
            }
        );
        break;
      }
      case 'video': {
        //VideoPlayerController vpc = VideoPlayerController.network(memory.image);
        return playerWidget;
        break;
      }
    }
  }
}



class InfoTab extends StatelessWidget {
  final Memory memory;

  InfoTab({this.memory});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('Information'),
        Text('Description: $memory.description'),
        Text('Uploaded on: ${memory.creationDate.toDate().day}/${memory.creationDate.toDate().month}/${memory.creationDate.toDate().year}'),
        Text('Originally taken: ${memory.dateTaken.toDate().day}/${memory.dateTaken.toDate().month}/${memory.dateTaken.toDate().year}'),
      ],
    );
  }
}

class ImageEnlarged extends StatefulWidget {
  final String imageUrl;

  ImageEnlarged({this.imageUrl});

  @override
  _ImageEnlargedState createState() => _ImageEnlargedState();
}

class _ImageEnlargedState extends State<ImageEnlarged> {
  @override
  Widget build(BuildContext context) {
    return Image.network(widget.imageUrl);
  }
}


class RecordingsTab extends StatefulWidget {

  final Memory memory;

  RecordingsTab({this.memory});

  @override
  _RecordingsTabState createState() => _RecordingsTabState();
}

class _RecordingsTabState extends State<RecordingsTab> {
  int playingIndex;

  AudioPlayer audioPlayer = AudioPlayer();

  List<bool> isPlaying = List<bool>();

  _playingIndex(int index, String uri) {

    switch(audioPlayer.state) {
      case AudioPlayerState.STOPPED:
        {
          audioPlayer.play(uri);
          setState(() {
            isPlaying[index] = true;
          });

          break;
        }
      case AudioPlayerState.PLAYING:
        {
        if(index != playingIndex) {
          audioPlayer.stop();
          isPlaying[playingIndex] = false;
          audioPlayer.play(uri);
          isPlaying[index] = true;
        } else {
          audioPlayer.pause();
          isPlaying[index] = false;
        }
          break;
        }
      case AudioPlayerState.PAUSED:
        {
          audioPlayer.play(uri);
          isPlaying[index] = true;
          break;
        }
      case AudioPlayerState.COMPLETED:
        {
          break;
        }
    }
    playingIndex = index;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream: DatabaseService(uid: widget.memory.uid).recordings,
      builder: (context, snapshot) {

        List<Recording> recordings = snapshot.data;
        isPlaying.clear();
        recordings.forEach((element) {isPlaying.add(false);});



        return Builder(
          builder: (BuildContext context){
            return Column(
              children: <Widget>[
                Text('Recordings'),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: recordings.length+1,
                    itemBuilder: (context, index) {
                    if(index == recordings.length) {
                    return RecordingEndTile(memoryUid: widget.memory.uid, memory: widget.memory);
                    }
                    isPlaying.add(false);
                    return Provider<List<bool>>.value(
                    value: isPlaying,
                    child: RecordingTile(recording: recordings[index], index: index, playingIndex: _playingIndex));
                    },
                  ),
                ),
              ],
            );
            }
        );
    }
    );
  }
}

