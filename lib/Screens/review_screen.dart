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
  File finalFileWithAudio = null;
  Offset offset = Offset.zero;
  Future<void> _initializeVideoPlayerFuture;
  String lableFloating = "";
  TextEditingController _textController = TextEditingController();
  var focusNode = new FocusNode();
  bool showTextfield = false;
  @override
  void initState() {
    mergeVideo();

    File file = File(widget.listVideo[0]);

    _controller = VideoPlayerController.file(file);
    _controller.setLooping(true);

    _initializeVideoPlayerFuture = _controller.initialize();

    super.initState();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;

    // TODO: implement build
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the VideoPlayerController has finished initialization, use
                // the data it provides to limit the aspect ratio of the VideoPlayer.
                return AspectRatio(
                  aspectRatio: deviceRatio,
                  // Use the VideoPlayer widget to display the video.
                  child: VideoPlayer(_controller),
                );
              } else {
                // If the VideoPlayerController is still initializing, show a
                // loading spinner.
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          Container(
             child: Positioned(
               left: offset.dx,
               top: offset.dy,
               child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  offset = Offset(
                      offset.dx + details.delta.dx, offset.dy + details.delta.dy);
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(lableFloating,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28.0,
                          color: Colors.red)),
                ),
              )),
        ),
      ),
          Align(
            child: GestureDetector(
              child: Container(

                child: Text(
                  "Add Text",
                  style: TextStyle(color: Colors.black),
                ),
                padding: EdgeInsets.all(8.0),
                color: Colors.white,
              ),
              onTap: (){
                FocusScope.of(context).requestFocus(focusNode);
                setState(() {
                  showTextfield = !showTextfield;
                });
              },

            ),
            alignment: Alignment.bottomCenter,
          ),
          Visibility(
            child: Align(
              child: TextField(
                controller: _textController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                      border: OutlineInputBorder()
                  ),
                onChanged: (data){
                  setState(() {
                    lableFloating = data;
                  });
                },
                onSubmitted: (data){
                  setState(() {
                    showTextfield = !showTextfield;
                  });


                },

              ),
              alignment: Alignment.bottomCenter,
            ),
            visible: showTextfield,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Wrap the play or pause in a call to `setState`. This ensures the
          // correct icon is shown.
          setState(() {
            // If the video is playing, pause it.
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              // If the video is paused, play it.
              _controller.play();
            }
          });
        },
        // Display the correct icon depending on the state of the player.
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  void mergeVideo() {
    getApplicationDocumentsDirectory().then((value) {
      String fileName =
          "outputjunemerge${DateTime.now().toIso8601String()}.mp4";
      fileMerged = new File(value.path + "/" + fileName);
      finalFileWithAudio = new File(value.path +
          "/" +
          "outputjunewithaudio${DateTime.now().toIso8601String()}.mp4");
      String s1 =
          "-i ${widget.listVideo[0]} -c copy -bsf:v h264_mp4toannexb -f mpegts ${value.path + "/" + "intermediate1.ts"}";
      String s2 =
          "-i ${widget.listVideo[1]} -c copy -bsf:v h264_mp4toannexb -f mpegts ${value.path + "/" + "intermediate2.ts"}";
      String s3 = "-i " +
          '"concat:${value.path + "/" + "intermediate1.ts"}|${value.path + "/" + "intermediate2.ts"}"' +
          " -c copy -bsf:a aac_adtstoasc ${fileMerged.path}";
      String mixiAudioCommand =
          " -i ${fileMerged.path} -i ${widget.audioPath} -c copy -map 0:v:0 -map 1:a:0 ${finalFileWithAudio.path}";

      _flutterFFmpeg.execute(s1).then((value) {
        print(value);
        _flutterFFmpeg.execute(s2).then((value) {
          print(value);
          _flutterFFmpeg.execute(s3).then((value) {
            print(value);
            _flutterFFmpeg.execute(mixiAudioCommand).then((value) {
              print(value);
              final FlutterFFprobe _flutterFFprobe = new FlutterFFprobe();
              _flutterFFprobe
                  .getMediaInformation(fileMerged.absolute.path)
                  .then((info) {
                print(info);

                int duration =
                    info.getAllProperties()['streams'][0]['duration_ts'];
              }).catchError((e) {
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text(e.toString())));
              });
            });
          });
        });
      });
    });
  }
}
