import 'dart:async';
import 'dart:io' as io;
import 'dart:math';

import 'package:audioplayer/audioplayer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:provider/provider.dart';
import 'package:ten_mem/Models/User.dart';
import 'package:ten_mem/Services/Database.dart';
import 'package:ten_mem/Shared/Constants.dart';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file/file.dart';

import 'package:path_provider/path_provider.dart';
import 'package:file/local.dart';
import 'package:ten_mem/Shared/Loading.dart';
import 'package:uuid/uuid.dart';

class AddMemory extends StatefulWidget {
  @override
  _AddMemoryState createState() => _AddMemoryState();
}

class _AddMemoryState extends State<AddMemory> {

  String image, title, description, narrationUri;
  String error = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool loading = false;
  String filePath;
  UserMini user;
  io.File _imageFile;
  Timestamp dateTaken;

  DateTime pickedDate;


  @override
  void initState() {
    super.initState();
    pickedDate = DateTime.now();
    dateTaken = Timestamp.fromDate(pickedDate);
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserMini>(context);



    return loading ? Loading(text: 'Your Memmori Is Being Uploaded',) : Scaffold(appBar: AppBar(
      title: Text('Add Memory'),
      centerTitle: true,
      backgroundColor: mainColor,
    ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: 20.0),
                Text('Add Image From:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 10.0),
                    RaisedButton(
                      color: mainColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
                      textColor: Colors.white,
                      onPressed: () {
                        pickImage(ImageSource.camera);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        child: Text('Camera', textScaleFactor: 1.5,),
                      ),
                    ),
                    SizedBox(width: 20,),
                    RaisedButton(
                      color: mainColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
                      textColor: Colors.white,
                      onPressed: () {
                        pickImage(ImageSource.gallery);
                      },
                      child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        child: Text('Device', textScaleFactor: 1.5,),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),

                SizedBox(height: 20.0),
                Card(
                    color: mainColor,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: Image.file(
                            _imageFile ?? io.File(''), height: 200,
                            width: 200,
                            fit: BoxFit.cover,)),
                    )
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  validator: (input) =>
                  input.isEmpty
                      ? 'Enter Title'
                      : null,
                  onSaved: (input) => title = input,
                  decoration: textInputDecoration.copyWith(
                      hintText: 'Title'),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  validator: (input) =>
                  input.isEmpty
                      ? 'Enter Description'
                      : null,
                  onSaved: (input) => description = input,
                  decoration: textInputDecoration.copyWith(
                      hintText: 'Description'),
                ),
                SizedBox(height: 20.0),
                Text('When was this image taken?'),
                SizedBox(height: 10.0),
                ListTile(
                  title: Text('Date Taken: ${pickedDate.day}/${pickedDate.month}/${pickedDate.year}'),
                  trailing: Icon(Icons.keyboard_arrow_down),
                  onTap: pickDate,
                ),
                SizedBox(height: 20,),
                RaisedButton(
                  color: mainColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
                  textColor: Colors.white,
                  onPressed: uploadMemory,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Text('Upload', textScaleFactor: 1.5,),
                  ),
                ),
                SizedBox(height: 12.0,),
                Text(
                    error,
                    style: TextStyle(color: Colors.red, fontSize: 14.0)
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  pickDate() async {
    DateTime date = await showDatePicker(
        context: context,
        initialDate: pickedDate,
        firstDate: DateTime(DateTime.now().year-100),
        lastDate: DateTime(DateTime.now().year+100)
    );

    if(date != null) {
      setState(() {
        pickedDate = date;
        dateTaken = Timestamp.fromDate(pickedDate);
      });
    }
  }

  Future<void> uploadMemory() async {
    final formState = _formKey.currentState;
    if (formState.validate()) {
      formState.save();
      try {
        setState(() => loading = true);
        dynamic result = await DatabaseService().addMemoryData(_imageFile, user.uid, title, description, dateTaken);
        if(result == null) {
          setState(() {
            error = 'Invalid Email And/Or Password';
            loading = false;
          });
        }
        Navigator.pop(context);
      } catch (e) {
        print(e.message);
      }
    }
  }

  Future pickImage(ImageSource source) async {
    io.File selected = await ImagePicker.pickImage(source: source);

    setState(() {
      _imageFile = selected;
    });
    cropImage();
  }

  Future cropImage() async {
    io.File cropped = await ImageCropper.cropImage(
      sourcePath: _imageFile.path,
      compressFormat: ImageCompressFormat.jpg,
      maxHeight: 500,
      maxWidth: 500,
      androidUiSettings: AndroidUiSettings(
          toolbarColor: Colors.grey,
          toolbarWidgetColor: Colors.white,
          toolbarTitle: 'Crop It'
      ),
    );

    setState(() {
      _imageFile = cropped ?? _imageFile;
    });
  }

  void clear() {
    setState(() {
      _imageFile = null;
    });
  }
}
