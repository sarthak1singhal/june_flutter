import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class ReviewScreen extends StatefulWidget {
  List<String> listVideo;
  String audioPath;
  ReviewScreen({this.listVideo, this.audioPath}) {}

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ReviewState();
  }
}

class ReviewState extends State<ReviewScreen> {
  VideoPlayerController _controller;
  bool _isPlaying = false;
  Duration _duration;
  Duration _position;
  bool _isEnd = false;
  Chewie playerWidget;
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

  File fileMerged = null;

  @override
  void initState() {
    super.initState();


  mergeVideo();









    File file = File(
        "/data/user/0/com.elysion.june/app_flutter/outputjune2020-09-21T12:48:42.861855.mp4");

    _controller = VideoPlayerController.file(file);


    final chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      aspectRatio: 0.5,
    );
     playerWidget = Chewie(
      controller: chewieController,
    );
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;

    // TODO: implement build
    return Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  child: _controller.value.initialized
                      ? playerWidget
                      : Container(),

                ),
              ],
            ),
          ],
        ));
  }

  Future<void> mergeVideo()  {

    getApplicationDocumentsDirectory().then((value)  {

      String fileName = "outputjunemerge${DateTime.now().toIso8601String()}.mp4";
      fileMerged = new File(value.path + "/" + fileName);


      String command = "-i ${widget.listVideo[0]} -i ${widget.listVideo[1]} -filter_complex hstack ${fileMerged.path}" ;

      _flutterFFmpeg.execute(command).then((value) {

      print(value.toString());

      });

      
    });
   



  }


//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      title: _position.toString(),
//      home: Scaffold(
//        body: Column(
//            children: <Widget> [
//              _controller.value.initialized
//                  ? AspectRatio(
//                aspectRatio: _controller.value.aspectRatio,
//                child: playerWidget,
//              )
//                  : Container(),
//              Text('Duration ${_duration?.toString()}'),
//              Text('Position ${_position?.toString()}'),
//              Text('isEnd?  $_isEnd'),
//            ]
//        ),
//        floatingActionButton:  FloatingActionButton(
//          onPressed: _controller.value.isPlaying
//              ? _controller.pause
//              : _controller.play,
//          child: Icon(
//            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
//          ),
//        ),
//      ),
//    );
//  }

}
