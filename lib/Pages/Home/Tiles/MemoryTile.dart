import 'package:flutter/material.dart';
import 'package:ten_mem/Models/Memory.dart';
import 'package:ten_mem/Pages/Home/MemoryWrapper.dart';
import 'package:ten_mem/Shared/Constants.dart';

class MemoryTile extends StatelessWidget {
  
  final MemoryMini memoryMini;
  final String tag;
  
  MemoryTile({this.memoryMini, this.tag});

  double size = 200;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Card(
          color: mainColor,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Hero(
                  tag: tag,
                  child: GestureDetector(
                    child: Image.network(
                      memoryMini.image,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        return progress == null ? child : CircularProgressIndicator();
                      }),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MemoryWrapper(memoryMini: memoryMini, tag: tag,)))
                  ),
                ),
              ),
            ),
        ),
      ),
    );
  }
}
