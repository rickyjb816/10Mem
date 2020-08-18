import 'package:cloud_firestore/cloud_firestore.dart';

class MemoryMini {
  final String uid;
  final String image;
  final String userUid;

  MemoryMini({this.uid, this.image, this.userUid});
}

class Memory {
  final String uid;
  final String image;
  final String imageRef;
  final String userUid;
  final String description;
  final Timestamp creationDate;
  final Timestamp dateTaken;
  final String narrationUri;
  //final String fileType;

  Memory({this.uid, this.image, this.imageRef, this.userUid, this.description, this.creationDate, this.dateTaken, this.narrationUri});
}