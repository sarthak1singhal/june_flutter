import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qvid/Model/OverlayModel.dart';
import 'package:qvid/Model/OverlayModelTimeScreen.dart';
import 'package:video_player/video_player.dart';


class SetDurationScreen extends StatefulWidget {

  final String videoPath;

  final List<OverlayWidgetTimeScreen> list;
  final List<OverlayWidgetTimeScreen> timedWidgets;

  final Key objectKey;
  final double time;

  const SetDurationScreen(this.videoPath,{Key key, @required this.list, @required this.time, @required this.objectKey, @required this.timedWidgets}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<SetDurationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  VideoPlayerController _controller;


  @override
  void initState() {

     _controller = VideoPlayerController.file(File(widget.videoPath))..initialize().then((_) {
       setState(() {});
    });
    _controller.setLooping(true);
    _controller.play();
  }


  @override
  void dispose() {

    _controller.dispose();

    super.dispose();
  }

  Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(

        children: [

          Container(height: size.height-250,width: size.width,
            color: Colors.black,
            child: Center(
            child: AspectRatio(
              aspectRatio: 9/16,
              child: Stack(
                children: [
                  VideoPlayer(_controller),
                  Stack(
                    children: widget.list ,
                  ),
                ],
              ),
            ),
          ),),

          Container(height: 186,width: MediaQuery.of(context).size.width, ),
          Divider(color: Colors.white54, thickness: 0.3,),
          Container(height: 40, width: MediaQuery.of(context).size.width,
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(icon: Icon(Icons.clear, color: Colors.white,), onPressed: (){
                Navigator.pop(context);
              }),
              Spacer(),
              IconButton(icon: Icon(Icons.done, color: Colors.white,), onPressed: (){
                Navigator.pop(context);
              })
            ],
          ),
          )
        ],

      ),
    );
  }
}



class OverlayWidgetsScreen extends StatefulWidget {


  final List<OverlayWidget> list;
  final double time;

  const OverlayWidgetsScreen({Key key, this.list, this.time}) : super(key: key);


  @override
  OverlayWidgetsScreen2 createState() => OverlayWidgetsScreen2();
}

class OverlayWidgetsScreen2 extends State<OverlayWidgetsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();




  Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(

        children: [

          Container(height: size.height-300,width: size.width, color: Colors.pinkAccent,),

          Container(height: 300,width: MediaQuery.of(context).size.width, color: Colors.black,)
        ],

      ),
    );
  }
}
