import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ten_mem/Models/Memory.dart';
import 'package:ten_mem/Models/Recordings.dart';
import 'package:ten_mem/Models/User.dart';
import 'package:ten_mem/Pages/Splash_Screen.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {

  final String uid;
  DatabaseService({ this.uid });

  //Collection Reference
  final CollectionReference userCollection = Firestore.instance.collection('Users');
  final CollectionReference memoriesCollection = Firestore.instance.collection('Memories');
  final CollectionReference recordingsCollection = Firestore.instance.collection('Recordings');
  final CollectionReference feedbackCollection = Firestore.instance.collection('Feedback');

  Future updateUserData(String name, String email, String profileImage) async {
    return await userCollection.document(uid).setData({
      'name': name,
      'email': email,
      'settings_notifications': true,
      'settings_light_dark_mode': true,
      'settings_visibility': true,
      'given_feedback': false,
      'profile_image': profileImage,
      'show_help': true,
    });
  }

  Future updateUserSettings(String field, bool val) async {
    return await userCollection.document(uid).updateData({
      field : val,
    });
  }

  Future updateUserMemoryCount(String userUid, String field, int value) async {
    return await userCollection.document(userUid).updateData({
      field : FieldValue.increment(value),
    });
  }

  Future updateMemoryData(bool hasImageChanged, File image, String title, String imageName, String imageRef, String description, Timestamp dateTaken) async {
    var url;
    var filePath;

    if(hasImageChanged) {
      final FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://tenmem/');

      StorageUploadTask _uploadTask;
      String imageDownloadURL;

      filePath = '${Uuid().v4()}.png';
      _uploadTask = _storage.ref().child(filePath).putFile(image);
      var storageSnapshot = await _uploadTask.onComplete;
      url = await storageSnapshot.ref.getDownloadURL();
      imageDownloadURL = url;
    }

    return await memoriesCollection.document(uid).updateData({
      'title': title,
      'image': url ?? imageName,
      'image_ref': filePath ?? imageRef,
      'description': description,
      'date_taken': dateTaken,
    });
  }

  Future uploadFeedback(String userUid, double rating, String futureFeatures, String improvements, String anythingElse) async {
    return await feedbackCollection.document().setData({
      'user_uid': userUid,
      'rating': rating,
      'future_features': futureFeatures,
      'improvements': improvements,
      'anything_else': anythingElse
    });
  }

  Future deleteUserData() async {
    return userCollection.document(uid).delete();
  }

  Future deleteMemoryData(String imageRef) async {
    //Delete Images
    await deleteFile(imageRef);
    //Need to Delete Recordings too
    return memoriesCollection.document(uid).delete();
  }

  Future deleteFile(String imageRef) async {
    final FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://tenmem/');
    await _storage.ref().child(imageRef).delete();
  }

  //User Settings from snapshot
  UserSettings _userSettingsFromSnapshot(DocumentSnapshot snapshot) {
    return UserSettings(
      uid: uid,
      notifications: snapshot.data['settings_notifications'],
      lightDarkMode: snapshot.data['settings_light_dark_mode'],
      visibility: snapshot.data['settings_visibility'],
      feedback: snapshot.data['given_feedback'],
      showHelp: snapshot.data['show_help'],
    );
  }

  //User Settings from snapshot
  User _userFromSnapshot(DocumentSnapshot snapshot) {
    return User(
      uid: uid,
      username: snapshot.data['name'],
      email: snapshot.data['email'],
      profileImage: snapshot.data['profile_image'],
      memoryCount: snapshot.data['memory_count'],
      showHelp: snapshot.data['show_help'],
    );
  }

  //User Settings from snapshot
  List<MemoryMini> _memoriesFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return MemoryMini(
        uid: doc.documentID,
        userUid: doc.data['user_uid'] ?? '',
        image: doc.data['image'],
      );
    }).toList();
  }

  //get User doc stream
  Stream<UserSettings> get userSettings {
    return userCollection.document(uid).get(source: Source.serverAndCache).asStream()
        .map(_userSettingsFromSnapshot);
  }

  //get User doc stream
  Stream<User> get user {
    return userCollection.document(uid).snapshots()
        .map(_userFromSnapshot);
  }

  //get MemoryMini Docs stream
  Stream<List<MemoryMini>> get memoryMini {
    return memoriesCollection
        .where('user_uid', isEqualTo: uid)
        .orderBy('creation_date', descending: false)
        .limit(10)
        .snapshots()
        .map(_memoriesFromSnapshot);
  }

  Stream<List<Recording>> get recordings {
    return recordingsCollection
        .where('memory_uid', isEqualTo: uid)
        .orderBy('creation_date', descending: false)
        .getDocuments(source: Source.serverAndCache).asStream()
        .map(_recordingsFromSnapshot);
  }

  //get Memory doc stream
  Stream<Memory> get memory {
    return memoriesCollection.document(uid).get(source: Source.serverAndCache).asStream().map(_memoryFromSnapshot);
  }

  List<Recording> _recordingsFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return Recording(
        uid: doc.documentID,
        recordingUri: doc.data['recording_uri'],
        memoryUid: doc.data['memory_uid'],
        title: doc.data['title'],
        creationDate: doc.data['creation_date'],
      );
    }).toList();
  }

  //Map doc to data type and add provider to display the populate
  Memory _memoryFromSnapshot(DocumentSnapshot snapshot) {
    return Memory(
      uid: uid,
      title: snapshot.data['title'],
      image: snapshot.data['image'],
      imageRef: snapshot.data['image_ref'],
      userUid: snapshot.data['user_uid'],
      description: snapshot.data['description'],
      creationDate: snapshot.data['creation_date'],
      dateTaken: snapshot.data['date_taken'],
      narrationUri: snapshot.data['narration_uri'],
      //fileType: snapshot.data['file_type'],
    );
  }

  Future addMemoryData(File image, String userUid, String title, String decsription, Timestamp dateTaken) async {
    final FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://tenmem/');

    StorageUploadTask _uploadTask;
    String imageDownloadURL, narrationDownloadUri;

    var filePath = '${Uuid().v4()}.png';
    _uploadTask = _storage.ref().child(filePath).putFile(image);
    var storageSnapshot = await _uploadTask.onComplete;
    var url = await storageSnapshot.ref.getDownloadURL();
    imageDownloadURL = url;

    updateUserMemoryCount(userUid, 'memory_count', 1);

    return await memoriesCollection.document(uid).setData({
      'title': title,
      'image': imageDownloadURL,
      'image_ref': filePath,
      'user_uid': userUid,
      'description': decsription,
      'creation_date': Timestamp.now(),
      'date_taken': dateTaken,
    });
  }

  Future uploadRecording(String memoryUid, File narration, String title) async {
    final FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://tenmem/');

    StorageUploadTask _uploadTask;
    String narrationDownloadUri;

    var filePath = '${Uuid().v4()}.WAV';
    _uploadTask = _storage.ref().child(filePath).putFile(narration);
    var storageSnapshot = await _uploadTask.onComplete;
    var url = await storageSnapshot.ref.getDownloadURL();
    narrationDownloadUri = url;

    return await recordingsCollection.document(uid).setData({
      'memory_uid': memoryUid,
      'recording_uri': narrationDownloadUri,
      'recording_name': filePath,
      'title': title,
      'creation_date': Timestamp.now(),
    });
  }
}