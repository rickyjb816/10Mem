import 'package:flutter/material.dart';
import 'package:ten_mem/Models/Memory.dart';
import 'package:ten_mem/Pages/Home/EditMemory.dart';
import 'package:ten_mem/Pages/Home/MemoryDisplay.dart';
import 'package:ten_mem/Shared/Constants.dart';

class MemoryWrapper extends StatefulWidget {

  final MemoryMini memoryMini;
  final String tag;

  MemoryWrapper({this.memoryMini, this.tag});

  @override
  _MemoryWrapperState createState() => _MemoryWrapperState();
}

class _MemoryWrapperState extends State<MemoryWrapper> {

  bool isEditingMemory = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isEditingMemory ? EditMemory(memoryMini: widget.memoryMini, toggleView: toggleView,) : MemoryDisplay(memoryMini: widget.memoryMini, tag: widget.tag, toggleView: toggleView),
    );
  }

  void toggleView(){
    setState(() => isEditingMemory = !isEditingMemory);
  }
}
