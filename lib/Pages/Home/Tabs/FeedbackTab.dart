import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:ten_mem/Services/Database.dart';
import 'package:ten_mem/Shared/Constants.dart';
import 'package:ten_mem/Models/User.dart';
import 'package:ten_mem/Shared/Loading.dart';

class FeedbackTab extends StatefulWidget {
  @override
  _FeedbackTabState createState() => _FeedbackTabState();
}

class _FeedbackTabState extends State<FeedbackTab> {

  double _rating;
  TextEditingController _futureFeaturesController = TextEditingController();
  TextEditingController _improvementsController = TextEditingController();
  TextEditingController _anythingElseController = TextEditingController();
  bool loading = false;


  @override
  Widget build(BuildContext context) {

    final user = Provider.of<UserMini>(context);

    return SafeArea(
      child: loading ? Loading(text: 'Uploading Feedback') : StreamBuilder<Object>(
        stream: DatabaseService(uid: user.uid).userSettings,
        builder: (context, snapshot) {

          UserSettings userSettings = snapshot.data;

          return userSettings.feedback ? CompletedWidget() : Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text('Feedback', textAlign: TextAlign.center, style: TextStyle(color: mainColor, fontSize: 30)),
                    SizedBox(height: 40,),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("Your feedback is incredibly valuable to us. We want to ensure that the service we launch is one that you will enjoy using for years to come. We'd love you to take a few minutes to offer as much, or as little feedback as you are able. Thanks for using 10 Mem, and for taking the time to let us know what you think of it so far.",
                      style: TextStyle(color: mainColor, fontSize: 20),),
                    ),
                    SizedBox(height: 40),
                    Text('Enjoying The App?', style: TextStyle(color: mainColor, fontSize: 25)),
                    RatingBar(
                      initialRating: 5,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      unratedColor: Colors.amber.withAlpha(50),
                      itemCount: 5,
                      itemSize: 50.0,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),

                      /*builder: (context, _) => Icon(Icons.star, color: Colors.amber),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _rating = rating;
                        });
                      },*/
                    ),
                    Text('Rating: ${_rating ?? ''}', style: TextStyle(color: mainColor, fontSize: 20)),
                    SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Text('What features would you like to see us add in the future versions?', style: TextStyle(color: mainColor, fontSize: 20)),
                    ),
                    SizedBox(
                      height: 100,
                      child: TextField(
                        controller: _futureFeaturesController,
                        expands: false,
                        keyboardType: TextInputType.multiline,
                        minLines: 3,
                        maxLines: null,
                        decoration: textInputDecoration.copyWith(hintText: 'What features would you like to see us add in the future versions?', hintMaxLines: 5,),
                      ),
                    ),
                    SizedBox(height: 40),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Text('What could we do to improve your experience?', style: TextStyle(color: mainColor, fontSize: 20)),
                    ),
                    SizedBox(
                      height: 100,
                      child: TextField(
                        controller: _improvementsController,
                        expands: false,
                        keyboardType: TextInputType.multiline,
                        minLines: 3,
                        maxLines: null,
                        decoration: textInputDecoration.copyWith(hintText: 'What could we do to improve your experience?', hintMaxLines: 5,),
                      ),
                    ),
                    SizedBox(height: 40),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Text("Anything else you'd like to add?", style: TextStyle(color: mainColor, fontSize: 20)),
                    ),
                    SizedBox(
                      height: 100,
                      child: TextField(
                        controller: _anythingElseController,
                        expands: false,
                        keyboardType: TextInputType.multiline,
                        minLines: 3,
                        maxLines: null,
                        decoration: textInputDecoration.copyWith(hintText: "Anything else you'd like to add?", hintMaxLines: 5,),
                      ),
                    ),
                    SizedBox(height: 40),
                    RaisedButton(color: mainColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
                      textColor: Colors.white,
                      onPressed: uploadFeedback,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Text('Submit', textScaleFactor: 1.5,),
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  void uploadFeedback() async {
    setState(() {
      loading = true;
    });
    UserMini user = Provider.of<UserMini>(context);
    await DatabaseService().uploadFeedback(user.uid, _rating, _futureFeaturesController.text, _improvementsController.text, _anythingElseController.text);
    await DatabaseService(uid: user.uid).updateUserSettings('given_feedback', true);
    clear();
  }

  void clear() {
    _futureFeaturesController.clear();
    _improvementsController.clear();
    _anythingElseController.clear();

    setState(() {
      loading = false;
    });
  }
}

class CompletedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Center(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Thank You For Giving Us Feedback On 10Mem', style: TextStyle(color: Colors.white, fontSize: 40,), textAlign: TextAlign.center,)
          )
      ),);
  }
}
