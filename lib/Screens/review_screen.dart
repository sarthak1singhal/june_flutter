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
  int duration ;
  ReviewScreen({this.listVideo, this.audioPath,this.duration}) {}

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
  Offset offset = Offset(0.0, 50.0);
  Offset offsetSec = Offset(0.0, 100.0);
  Future<void> _initializeVideoPlayerFuture;
  String lableFloating = "";
  TextEditingController _textController = TextEditingController();
  var focusNode = new FocusNode();
  bool showTextfield = false;
  bool showImage = false;
  List<String> _listtempts = List();

  File finalfilecutAudio;
  @override
  void initState() {
    mergeVideo();
    super.initState();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();


    getApplicationDocumentsDirectory().then((value){
      for (int i = 0; i < widget.listVideo.length; i++) {
        String s ="${value.path + "/" + "intermediate$i.ts"}";
        File file = File(s);
        file.deleteSync();
        print("file deleted");
      }

    });


    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;

    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the VideoPlayerController has finished initialization, use
                // the data it provides to limit the aspect ratio of the VideoPlayer.
                return RotatedBox(quarterTurns: 1,
                child: VideoPlayer(_controller));
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
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text("$lableFloating",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 28.0,
                            color: Colors.red)),
                  ),
                ),
              )),
        ),
      ),
          Container(
            child: Positioned(
              left: offsetSec.dx,
              top: offsetSec.dy,
              child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      offsetSec = Offset(
                          offsetSec.dx + details.delta.dx, offsetSec.dy + details.delta.dy);
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:  Visibility(
                      child: Align(
                        child: Container(
                          height: 100,
                          width: 100,
                          color: Colors.white,
                          child: Center(child: Text("Add Image Here?",style: TextStyle(color: Colors.black,),textAlign: TextAlign.center,)),

                        ),
                        alignment: Alignment.center,
                      ),
                      visible: showImage,
                    ),
                  )),
            ),
          ),
          Align(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [


                GestureDetector(
                  child: Container(
                    child: Text(
                      !showImage?"Add Image":"Hide Image",
                      style: TextStyle(color: Colors.black),
                    ),
                    padding: EdgeInsets.all(8.0),
                    color: Colors.white,
                  ),
                  onTap: () {
                    setState(() {
                      showImage = !showImage;
                    });
                  },
                ),

                SizedBox(height: 20,),
                GestureDetector(
                  child: Container(
                    child: Text(
                      "Add Text",
                      style: TextStyle(color: Colors.black),
                    ),
                    padding: EdgeInsets.all(8.0),
                    color: Colors.white,
                  ),
                  onTap: () {
                    FocusScope.of(context).requestFocus(focusNode);
                    setState(() {
                      showTextfield = !showTextfield;
                    });
                  },
                ),
                SizedBox(height: 20,),
                Visibility(
                  child: Align(
                    child: TextField(
                      controller: _textController,
                      focusNode: focusNode,
                      decoration: InputDecoration(border: OutlineInputBorder()),
                      onChanged: (data) {
                        setState(() {
                          lableFloating = data;
                        });
                      },
                      onSubmitted: (data) {
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
            alignment: Alignment.bottomCenter,
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
//        child: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow,),
      child:   FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the VideoPlayerController has finished initialization, use
            // the data it provides to limit the aspect ratio of the VideoPlayer.
            return Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow,);
          } else {
            // If the VideoPlayerController is still initializing, show a
            // loading spinner.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      ),
    );
  }

  void mergeVideo() {
    getApplicationDocumentsDirectory().then((value) async {
      String fileName =
          "outputjunemerge${DateTime.now().toIso8601String()}.mp4";

      fileMerged = new File(value.path + "/" + fileName);

      finalFileWithAudio = new File(value.path +
          "/" +
          "outputjunewithaudio${DateTime.now().toIso8601String()}.mp4");


       finalfilecutAudio = new File(value.path +
          "/" +
          "outputjunecuthaudio${DateTime.now().toIso8601String()}.mp3");


      for (int i = 0; i < widget.listVideo.length; i++) {
        String s =
            "-i ${widget.listVideo[i]} -c copy -bsf:v h264_mp4toannexb -f mpegts ${value.path + "/" + "intermediate$i.ts"}";
        _listtempts.add(s);
      }

      for (int i = 0; i < widget.listVideo.length; i++) {
        int code  = await _flutterFFmpeg.execute(_listtempts[i]);
        print("June---->creating temp file$code");
      }

      String concat = null;
      for (int i = 0; i < widget.listVideo.length; i++) {
        if (concat == null)
          concat = value.path + "/" + "intermediate$i.ts" + "|";
        else {
          if (i == widget.listVideo.length - 1)
            concat = concat + value.path + "/" + "intermediate$i.ts";
          else {
            concat = concat + value.path + "/" + "intermediate$i.ts" + "|";
          }
        }
      }

      String mergefileCommand = "-i " +
          '"concat:$concat"' +
          " -c copy -bsf:a aac_adtstoasc ${fileMerged.path}";  // command for merging video

      _flutterFFmpeg.execute(mergefileCommand).then((value) async {
        print("June---->video merge $value");


        if(widget.audioPath.isNotEmpty) {
          String cutAudioCommand = " -i ${widget.audioPath} -ss 00:00:00 -t ${widget.duration} -acodec copy ${finalfilecutAudio.path}"; // command for cut audio


          int code = await _flutterFFmpeg.execute(cutAudioCommand);
          print("June---->cut audio $code");

          String mixiAudioCommand =
              " -i ${fileMerged.path} -i ${finalfilecutAudio
              .path} -c copy -map 0:v:0 -map 1:a:0 ${finalFileWithAudio
              .path}"; // command for mixing audio with merged video

          _flutterFFmpeg.execute(mixiAudioCommand).then((value) {
            print("June---->audio merge$value");
            _controller = VideoPlayerController.file(finalFileWithAudio);
            _controller.setLooping(true);
            _initializeVideoPlayerFuture = _controller.initialize();
            setState(() {});
          });
        }
        else {
          _controller = VideoPlayerController.file(fileMerged);
          _controller.setLooping(true);
          _initializeVideoPlayerFuture = _controller.initialize();
          setState(() {});
        }



      });
    });

  }


}
