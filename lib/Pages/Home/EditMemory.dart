import 'dart:io' as io;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ten_mem/Models/Memory.dart';
import 'package:ten_mem/Models/User.dart';
import 'package:ten_mem/Services/Database.dart';
import 'package:ten_mem/Shared/Constants.dart';
import 'package:ten_mem/Shared/Loading.dart';

class EditMemory extends StatefulWidget {

  final MemoryMini memoryMini;
  final Function toggleView;

  const EditMemory({this.memoryMini, this.toggleView});

  @override
  _EditMemoryState createState() => _EditMemoryState();
}

class _EditMemoryState extends State<EditMemory> {

  TextEditingController _controller;
  String description;

  String image;
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
    return StreamBuilder<Object>(
      stream: DatabaseService(uid: widget.memoryMini.uid).memory,
      builder: (context, snapshot) {

        Memory memory = snapshot.data;

        _controller = new TextEditingController(text: memory.description);
        description = memory.description;
        pickedDate = memory.dateTaken.toDate();
        //dateTaken = Timestamp.fromDate(pickedDate);

        return loading ? Loading(text: "Your Memmori Is Being Updated",) : Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.close),
              backgroundColor: mainColor,
              onPressed: () async {
                loading = true;
                if(_imageFile != null) {
                  await DatabaseService(uid: memory.uid).deleteFile(memory.imageRef);
                }
                //Save To Database
                await DatabaseService(uid: memory.uid).updateMemoryData(_imageFile != null, _imageFile, _imageFile == null ? memory.image : '', _imageFile == null ? memory.imageRef : '', _controller.text, Timestamp.fromDate(pickedDate));
                widget.toggleView();
                loading = false;
                },
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          body: Container(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
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
                              child: _imageFile != null ? Image.file(_imageFile,
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,
                              ) : Image.network(memory.image,
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,
                              )
                          ),
                        )
                    ),
                    TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: textInputDecoration.copyWith(
                          hintText: 'Description'),
                    ),
                    SizedBox(height: 20.0),
                    ListTile(
                      title: Text('Date Taken: ${pickedDate.day}/${pickedDate.month}/${pickedDate.year}'),
                      trailing: Icon(Icons.keyboard_arrow_down),
                      onTap: pickDate,
                    ),
                  ],
                ),
              ),
            ),
          )
        );
      }
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
