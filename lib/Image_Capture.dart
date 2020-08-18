import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class ImageCapture extends StatefulWidget {
  @override
  _ImageCaptureState createState() => _ImageCaptureState();
}

class _ImageCaptureState extends State<ImageCapture> {

  File _imagefile;

  Future pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);

    setState(() {
      _imagefile = selected;
    });
  }

  Future cropImage() async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: _imagefile.path,
      compressFormat: ImageCompressFormat.jpg,
      androidUiSettings: AndroidUiSettings(
          toolbarColor: Colors.white,
          toolbarWidgetColor: Colors.white,
          toolbarTitle: 'Crop It'
      ),
    );

    setState(() {
      _imagefile = cropped ?? _imagefile;
    });
  }

  void clear() {
    setState(() {
      _imagefile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}