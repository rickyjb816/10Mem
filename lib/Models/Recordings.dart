import 'package:cloud_firestore/cloud_firestore.dart';

class Recording {

  final String uid;
  final String recordingUri;
  final String memoryUid;
  final String title;
  final Timestamp creationDate;

  Recording({this.uid, this.recordingUri, this.memoryUid, this.title, this.creationDate});
}