import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ten_mem/Models/User.dart';
import 'package:uuid/uuid.dart';

import 'Database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  //Create User Object base on FirebaseUser
  UserMini _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? UserMini(uid: user.uid) : null;
  }

  //Auth Change User Stream
  Stream<UserMini> get user {
    return _auth.onAuthStateChanged
        .map(_userFromFirebaseUser);
  }

  //Sign In Email and Password
  Future signInEmailAndPassword(String email, String password) async {
    try{
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return _userFromFirebaseUser(result.user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //Register with Email and Password
  Future registerWithEmailAndPassword(String email, String password, String name, File profileImage) async {
    try{
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      result.user.sendEmailVerification();

      final FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://tenmem/');

      StorageUploadTask _uploadTask;
      String downloadURL;
      var filePath = 'images/${Uuid().v4()}.png';
      _uploadTask = _storage.ref().child(filePath).putFile(profileImage);
      var storageSnapshot = await _uploadTask.onComplete;
      var url = await storageSnapshot.ref.getDownloadURL();
      downloadURL = url;

      //create a document for the user with the uid
      await DatabaseService(uid: result.user.uid).updateUserData(name, email, downloadURL);

      return _userFromFirebaseUser(result.user);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  //Sign In Google - Works to sign user in but will create user if one doesn't exist and skip any set up process
  Future googleSignIn() async {
    try {
      GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken);

      final AuthResult authResult = await _auth.signInWithCredential(credential);
      FirebaseUser user = authResult.user;

      //await DatabaseService(uid: authResult.user.uid).updateUserData(googleUser.displayName, googleUser.email, 'Add business', 'Add Job Title', 'Location Of User', googleUser.photoUrl);
      user.sendEmailVerification();

      return _userFromFirebaseUser(user);
    } catch(e) {
      return null;
    }
  }

  //Register with Google

  //Sign In Facebook

  //Register with Facebook

  //Sign In Twitter

  //Register with Twitter

  //Sign out
  Future signOut() async{
    try{
      return await _auth.signOut();
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  //UpdatePassword


  //Delete Account
  Future deleteAccount() async {
    FirebaseUser user = await _auth.currentUser();
    //await DatabaseService(uid: user.uid).deleteUserData();
    return await user.delete();
  }
}