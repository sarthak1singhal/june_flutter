import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qvid/Components/newScreenGrid.dart';
import 'package:qvid/Components/tab_grid.dart';

class MorePage extends StatelessWidget {
  final String title;
  final List list;

  MorePage({this.title, this.list});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: NewScreenGrid(list)),
    );
  }
}
