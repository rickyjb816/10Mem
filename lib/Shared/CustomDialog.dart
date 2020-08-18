import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ten_mem/Services/Database.dart';
import 'package:ten_mem/Shared/Constants.dart';

class CustomDialog extends StatefulWidget {
  final String title, description, buttonText;
  final Image image;
  final String userUid;

  CustomDialog({
    @required this.title,
    @required this.description,
    @required this.buttonText,
    this.image,
    this.userUid,
  });

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  bool showHelp = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        //...bottom card part,
        Container(
          padding: EdgeInsets.only(
            top: avatarRadius + padding,
            bottom: padding,
            left: padding,
            right: padding,
          ),
          margin: EdgeInsets.only(top: avatarRadius),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(padding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 24.0),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 300,
                  height: 50,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Don't Show Again"),
                      Checkbox(
                        value: showHelp,
                        onChanged: (value) {
                          setState(() {
                            showHelp = value;
                          });
                        },

                      ),
                      RaisedButton(
                        color: mainColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
                        textColor: Colors.white,
                        onPressed: () {
                          if(showHelp) {
                            DatabaseService(uid: widget.userUid).updateUserSettings('show_help', !showHelp);
                          }
                          Navigator.of(context).pop(); // To close the dialog
                        },
                        child: Text(widget.buttonText),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        //...top circlular image part,
        Positioned(
          left: padding,
          right: padding,
          child: CircleAvatar(
            backgroundColor: mainColor,
            radius: avatarRadius,
          ),
        ),
      ],
    );
  }
}