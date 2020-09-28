import 'dart:async';
import 'dart:io';

import 'package:fitted_text_field_container/fitted_text_field_container.dart';
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
  Offset initialTextOffset = Offset(0.0, 50.0);
  Offset offsetColorPicker = Offset(0.0, 50.0);
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

  bool firstLoad = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;

    if(firstLoad)
      {
        firstLoad = false;
        offset = Offset(size.width /2-10, size.height/5);
        initialTextOffset = Offset(size.width/2, size.height/2 );
      }



    return Scaffold(
      resizeToAvoidBottomInset : false,
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the VideoPlayerController has finished initialization, use
            // the data it provides to limit the aspect ratio of the VideoPlayer.

            return Stack(
              children: [
                RotatedBox(quarterTurns: 1,
                    child: VideoPlayer(_controller)),



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




                /*Container(
                  //color: Colors.black26,
                  child: Positioned(
                    left: initialTextOffset.dx,
                    top: initialTextOffset.dy,
                    child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            initialTextOffset = Offset(
                                initialTextOffset.dx + details.delta.dx, initialTextOffset.dy + details.delta.dy);
                          });
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Center(
                              child:
                              Text("$lableFloating",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0,
                                      color: Colors.red)),
                            ),
                          ),
                        )),
                  ),
                ),
*/






                Positioned(
                  bottom: 65,
                  right: 0,
                  child: GestureDetector(
                    onTap: (){
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
                    child: Container(height: 44, width: 90,

                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.black26,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.zero,
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.zero,
                        ),
                      ),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Icon( _controller.value.isPlaying ? Icons.pause:Icons.play_arrow, size: 17, color: Colors.white,),
                          Text(_controller.value.isPlaying ? "Pause":"Play", style: TextStyle(color: Colors.white),)
                        ],)
                      ,),
                  ),
                ),
                MediaQuery.of(context).viewInsets.bottom >10 ?Container(
                  color:Colors.black26,
                ) : Positioned(top: 0,left: 0,child: Container(height: 0,width: 0,),),
                MediaQuery.of(context).viewInsets.bottom >10 ? Positioned(
                  top: 30,
                  right: 7,
                  child: FlatButton(
                    child: Text("DONE", style: TextStyle(

                    ), ),
                    textColor: Colors.white,
                    color: Colors.transparent,
                    onPressed: (){

                    },
                  ),
                ):Container(),
                Container(
                  //color: Colors.black26,
                  child: Positioned(
                    left: offset.dx - lableFloating.length*5.5,
                    top: offset.dy,
                    child: GestureDetector(
                        child: FittedTextFieldContainer(
                            calculator: FittedTextFieldCalculator.fitVisibleWithPadding(0, 14),
                            decoration: BoxDecoration(
                                color: lableFloating.length == 0 ? Colors.transparent:Colors.pink
                            ),
                            child:  TextField(
                              textAlign: TextAlign.justify,
                              autofocus: true,
                              controller: _textController,
                              focusNode: focusNode,

                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 21,
                                  color: Colors.white
                              ),
                              cursorWidth: 2,
                              cursorColor: Colors.white,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 20,),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none
                              ),
                              onChanged: (data) {
                                lableFloating = data;

                                // if(lableFloating.length<2)
                                    {
                                  setState(() {

                                  });
                                }


                              },
                              onSubmitted: (data) {
                                setState(() {
                                  showTextfield = !showTextfield;
                                });
                              },
                            )
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
                          focusNode.requestFocus(FocusNode());


                          print(MediaQuery.of(context).viewInsets.bottom);
                          print(size.height);
                          offsetColorPicker = Offset(50, MediaQuery.of(context).viewInsets.bottom-200);

                          _textController.text = "";
                          lableFloating = "";
                          setState(() {
                            showTextfield = !showTextfield;
                          });
                        },
                      ),
                      SizedBox(height: 20,),



                    ],
                  ),
                  alignment: Alignment.bottomCenter,
                ),
              ],
            );






            return RotatedBox(quarterTurns: 1,
                child: VideoPlayer(_controller));
          } else {
            // If the VideoPlayerController is still initializing, show a
            // loading spinner.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),










/*
      floatingActionButton: FloatingActionButton(
        onPressed: () {

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
      ),*/
    );
  }






  getTextLayouts(){

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



class TextList{
  String key, text;
  Color textColor, backgroundColor;
  double left, right, top, bottom;
  double containerHeight;
  double containerWidth;
  double containerRotation;






}