import 'package:flutter/material.dart';
import 'package:ten_mem/Models/Memory.dart';
import 'package:ten_mem/Shared/Constants.dart';

class MemoryInformation extends StatefulWidget {
  @override
  _MemoryInformationState createState() => _MemoryInformationState();

  final Memory memory;

  MemoryInformation({this.memory});
}

class _MemoryInformationState extends State<MemoryInformation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.memory.title),
        centerTitle: true,
        backgroundColor: mainColor),
      body: SafeArea(
        child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Card(
                  color: Color.fromRGBO(54, 69, 79, 1),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(
                        widget.memory.image,
                        fit: BoxFit.cover,
                        height: 250,
                        width: 250,
                        loadingBuilder: (context, child, progress) {
                          return progress == null ? child : CircularProgressIndicator();
                        }
                    ),
                  ),
                ),
              ),
              Text('Information'),
              Text('Description: ${widget.memory.description}'),
              Text('Uploaded on: ${widget.memory.creationDate.toDate().day}/${widget.memory.creationDate.toDate().month}/${widget.memory.creationDate.toDate().year}'),
              Text('Originally taken: ${widget.memory.dateTaken.toDate().day}/${widget.memory.dateTaken.toDate().month}/${widget.memory.dateTaken.toDate().year}'),
            ]
        ),
      )
    );
  }
}
