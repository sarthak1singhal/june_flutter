import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:qvid/Functions/LocalColors.dart';
import 'package:qvid/Functions/MergeImagesWithVideo.dart';
import 'package:qvid/Model/OverlayDeatils.dart';
import 'package:qvid/Theme/colors.dart';

import 'package:chewie/chewie.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qvid/BottomNavigation/AddVideo/setDurationScreen.dart';
import 'package:qvid/Functions/EncodingProvider.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Functions/VideoDownloader.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Model/MediaInfo.dart';
import 'package:qvid/Model/OverlayModel.dart';
import 'package:qvid/Model/OverlayModelTimeScreen.dart';
import 'package:qvid/Screens/TextPainter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:text_editor/text_editor.dart';
import 'package:video_player/video_player.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import 'hideShowScreen.dart';


class ReviewScreen2 extends StatefulWidget {
  List<MediaInfo> listVideo;
  String audioPath;
  double duration ;
  ReviewScreen2({this.listVideo, this.audioPath,this.duration}) {}

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ReviewState();
  }
}

class ReviewState extends State<ReviewScreen2>  {
  VideoPlayerController _controller;

  GlobalKey key = GlobalKey();
  GlobalKey parentKey = GlobalKey();
  String finalVideoPath;

  Chewie playerWidget;
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

  File fileMerged ;
  File finalFileWithAudio ;
  ScreenshotController screenshotController = ScreenshotController();
  ScreenshotController parentScreenshotController = ScreenshotController();


  List<Widget> textOverlayList = [];
  Offset initialTextOffset = Offset(0.0, 50.0);
  Offset offsetColorPicker = Offset(0.0, 50.0);
  Offset offsetSec = Offset(0.0, 100.0);
  Future<void> _initializeVideoPlayerFuture;
  TextEditingController _textController = TextEditingController();
  var focusNode = new FocusNode();
  bool showTextfield = false;
  bool showImage = false;
  List<String> _listtempts = List();

  File finalfilecutAudio;
  OverlayWidget selectedWidget;


  List<OverlayWidget > listOverlays = [];


  double _lowerValue, _upperValue;
  bool isLoading = false;
  File loadingImage;


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
  Offset o;
  bool showTrimmer  = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    if(firstLoad)
    {
      firstLoad = false;
       initialTextOffset = Offset(size.width/2, size.height/4 );
    }



    return Scaffold(key: parentKey ,
      resizeToAvoidBottomInset : false,
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the VideoPlayerController has finished initialization, use
            // the data it provides to limit the aspect ratio of the VideoPlayer.

            return  Stack(
              children: [
               SafeArea(child:  Container(

                 height:size.height,
                 width: size.width,
                 child:  Align(
                   alignment: Alignment.topCenter,
                   child: Screenshot(
                     controller: parentScreenshotController,
                     child: AspectRatio(

                       child: Stack(
                         children: [
                           VideoPlayer(_controller),


                           Screenshot(
                             controller: screenshotController,
                             child: Container(
                               child: ShowHideScreen(
                                 list: listOverlays,
                                 startTime: 0,
                                 endTime: widget.duration,
                                 isPlaying: _controller.value.isPlaying,
                                 controller: _controller,



                               ),

                             ),
                           ),




                           Positioned(
                             bottom: showTrimmer?100: 65,
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


                           isLoading ?
                           Stack(
                             children: [
                               loadingImage==null?Container(height: 0,width: 0,): Image.file(loadingImage),
                               Container(height: size.height, width: size.width, color: Colors.black12, child: Center(child: Functions.showLoaderSmall(),),)
                             ],
                           )
                               :Positioned(left: 0,top: 0,child: Container(height: 0,width: 0,),)
                           ,



                           showTextfield? Positioned(
                             left: 8,
                             right:8,
                             top: initialTextOffset.dy,
                             child: GestureDetector(

                                 child:                        Container(
                                     constraints: BoxConstraints(minHeight: 0,maxHeight: MediaQuery.of(context).size.height,maxWidth: MediaQuery.of(context).size.width,minWidth: 4),

                                     color: Colors.redAccent,
                                     child: TextField(

                                       autofocus: true,
                                       maxLines: null,

                                       cursorColor: Colors.green,
                                       style: TextStyle(inherit: false, fontSize: 24, textBaseline: TextBaseline.alphabetic),
                                       focusNode:  focusNode,
                                       decoration: InputDecoration(
                                         contentPadding: EdgeInsets.all(14),
                                         fillColor: Colors.orange,
                                         filled: true,
                                         border: InputBorder.none,

                                         focusedBorder: InputBorder.none,
                                       ),

                                       controller: _textController,
                                       textInputAction: TextInputAction.newline,

                                       onSubmitted: (val) {
                                         print(val);
                                       },
                                     )
                                 )

                             ),
                           ) :Positioned(top: 0,left: 0,child: SizedBox(height: 0,width: 0,),),






                         ],
                       ),

                       aspectRatio: 8.9/16,
                     ),
                   )),
               ),),

                showTrimmer  ?
                Positioned(
                  child: Column(
                    children: [
                      Container(
                        color: Colors.black,
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: EdgeInsets.only(left: 20,right: 20,top: 13,bottom: 5),
                          child: Builder(
                            builder: (c){

                              List<Widget> l = [];
                              for(int i=0;i<thumbPath.length;i++)
                                {
                                  l.add(Flexible(
                                    child: Image.file(File(thumbPath[i])),
                                  ));
                                }
                              return FlutterSlider(
                                values: [selectedWidget.startTime*10,selectedWidget.endTime*10],
                                rangeSlider: true,

                                max: widget.duration*10,
                                min: 0,
                                tooltip: FlutterSliderTooltip(
                                    format: (String value) {
                                      return (double.parse(value)/10).toStringAsFixed(1);
                                    },
                                    textStyle: TextStyle(fontSize: 17, color: Colors.white),
                                    boxStyle: FlutterSliderTooltipBox(
                                        decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.7)
                                        )
                                    )
                                ),
                                onDragging: (handlerIndex,   lowerValue, upperValue) {
                                  _lowerValue = (double.parse(lowerValue.toString()))/10;
                                  _upperValue = (double.parse(upperValue.toString()))/10;
                                  print(_lowerValue);
                                  //setState(() {});
                                },
                                trackBar: FlutterSliderTrackBar(
                                  centralWidget: Container(height: 30,  padding: EdgeInsets.only(left: 5,right: 5), child: Row(
                                    children: l,
                                  ),),

                                  activeTrackBar: BoxDecoration(
                                      color:  mainColor.withOpacity(0.2)
                                  ),
                                  activeTrackBarHeight: 30,
                                ),
                                handler: FlutterSliderHandler(
                                  decoration: BoxDecoration(),
                                  child: Material(
                                    type: MaterialType.canvas,
                                    color: secondaryColor,
                                    elevation: 3,
                                    child: Container(
                                      height: 50,
                                      width: 10,
                                    ),
                                  ),
                                ),
                                rightHandler:  FlutterSliderHandler(
                                  decoration: BoxDecoration(),
                                  child: Material(
                                    type: MaterialType.canvas,
                                    color: secondaryColor,
                                    elevation: 3,
                                    child: Container(
                                      height: 50,
                                      width: 10,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      ),

                      Container(width: size.width,height: 0.3,color: Colors.white54,),

                      Container(
                        color: Colors.black,
                        height: 40, width: MediaQuery.of(context).size.width,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(icon: Icon(Icons.clear, color: Colors.white,), onPressed: (){





                              hideBorders();
                              setState(() {
                                showTrimmer = false;
                              });

                            }),
                            Spacer(),
                            IconButton(icon: Icon(Icons.done, color: Colors.white,), onPressed: (){

                              print(_lowerValue);
                              print(_upperValue);
                              selectedWidget.endTime = _upperValue;
                              selectedWidget.startTime= _lowerValue;
                               if(!(selectedWidget.startTime==0 && selectedWidget.endTime == widget.duration)) {
                                for (int i = 0; i < listOverlays.length; i++) {
                                  if (selectedWidget.key ==
                                      listOverlays[i].key) {
                                    listOverlays[i].endTime = _upperValue;
                                    listOverlays[i].startTime = _lowerValue;

                                    listOverlays.add(listOverlays[i]);
                                     listOverlays.removeAt(i);
                                  }
                                }
                              }
                              hideBorders();



                              setState(() {
                                showTrimmer = false;
                              });

                            })
                          ],
                        ),
                      )
                    ],
                  ),
                  bottom: 0,
                )
                    :Positioned(child: Container(height: 80,width: size.width,
                child: Row(
                  children: [
                    GestureDetector(
                      child: Container(
                        child: Text(
                           "Add Image" ,
                          style: TextStyle(color: Colors.black),
                        ),
                        padding: EdgeInsets.all(8.0),
                        color: Colors.white,
                      ),
                      onTap: () {

                        OverlayWidget w = OverlayWidget(height: size.height,width: size.width, key: Key(changableKeys.toString()), startTime: 0, endTime: widget.duration.toDouble(),);

                        changableKeys++;
                        w.fx = (){



                          hideBorders(myKey: w.key);

                          w.hideShowBorder();



                        };



                        w.onTapDown = (TapUpDetails details) async{

                          w.tapOffset = Offset(details.globalPosition.dx,details.globalPosition.dy);

                          if(!w.isBorderShown())
                          {

                            bool pressedPlay = false;
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                              pressedPlay = true;
                              setState(() {

                              });
                            }
                         String c= await  Functions.showVideoDialog(context,w.tapOffset, "Set Duration", (){


                           Navigator.pop(context, "duration");



                            for(int i=0;i<listOverlays.length;i++)
                              {
                                if(listOverlays[i].key == w.key)
                                  {

                                      selectedWidget = listOverlays[i];

                                  }
                              }
                            showTrimmer = true;
                            setState(() {

                            });


                            }, "Delete", (){

                            Navigator.pop(context,"delete");

                          });

                            if(pressedPlay)
                              {
                                if (!_controller.value.isPlaying) {
                                  _controller.play();
                                  setState(() {

                                  });
                                }
                              }

                            if(c!="duration")
                              {
                                w.hideShowBorder();
                              }
                            if(c=="delete")
                              {
                                for(int i=0;i<listOverlays.length;i++)
                                  {
                                   if(listOverlays[i].key==w.key)
                                     {
                                       showTrimmer = false;
                                       listOverlays.removeAt(i);
                                       setState(() {

                                       });
                                     }
                                  }
                              }
                          }

                        };



                        listOverlays.add( w);



                        setState(() {});

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
                      /*   offsetColorPicker = Offset(50, MediaQuery.of(context).viewInsets.bottom-200);

                        _textController.text = "";
                        setState(() {
                          showTextfield = !showTextfield;
                        });
                        focusNode.requestFocus(FocusNode());
*/
                      },
                    ),
                    SizedBox(height: 20,),

                    SizedBox(height: 20,),

                    Spacer(),

                    Container(height: 40,width: 100,
                    child: RaisedButton(
                      color: mainColor,
                      child: Text("Next",),
                      textColor: Colors.white,
                      onPressed: () async{
                        hideBorders();
                        setState(() {

                        });


                        if(!isLoading) {

                          isLoading = true;

                          final value = await getApplicationDocumentsDirectory();
                           loadingImage = await parentScreenshotController.capture(
                              path: value.path + "/load" + DateTime
                                  .now()
                                  .millisecondsSinceEpoch
                                  .toString() + ".png", pixelRatio: 1.75);

                           print(loadingImage);

                           await GallerySaver.saveImage(loadingImage.path);
                           setState(() {

                           });

                           String fileName =value.path +  "vid${DateTime
                              .now()
                              .millisecondsSinceEpoch
                              .toString()}.mp4";

                        //  await Future.delayed(const Duration(seconds: 3), (){});

                          File screenshotFile = File(value.path + "/" + DateTime
                              .now()
                              .millisecondsSinceEpoch
                              .toString() + ".png");


                          int l = listOverlays.length;
                          for (int i = 0; i < l; i++) {
                            if (listOverlays[i].startTime != 0 ||
                                listOverlays[i].endTime != widget.duration) {
                              listOverlays[i].hideVisibility();
                             }
                          }


                          List<OverlayDetails> overlayDetails = [];
                          File fScreenShot = await screenshotController.capture(
                              path: screenshotFile.path, pixelRatio: 1.75);
                          overlayDetails.add(OverlayDetails(screenshotFile.path, 0, widget.duration));


                          for (int i = 0; i < l; i++) {
                            if (!(listOverlays[i].startTime == 0 &&
                                listOverlays[i].endTime == widget.duration)) {
                              listOverlays[i].showVisibility();
                              bool tempChange = false;
                              if(!listOverlays[i].isChildVisible()) {
                                listOverlays[i].showChildVisibility();
                                tempChange = true;
                              }
                              String imgPath  =  value.path + "/${i.toString()}" + DateTime
                                  .now().millisecondsSinceEpoch
                                  .toString() + ".png";
                              await listOverlays[i].takeScreenshot(imgPath);

                              overlayDetails.add(OverlayDetails(imgPath, listOverlays[i].startTime, listOverlays[i].endTime));

                              if(tempChange)
                                {
                                  listOverlays[i].hideChildVisibility();
                                }


                            }
                          }
                          setState(() {

                          });


                          MergeImagesWithVideo.mergeImages(finalVideoPath,fileName, overlayDetails);


                          //                          var res = await Functions.unsignPostReq(Variables.base_url+"getUploadUrl", jsonEncode({}));

                          //                            var body = jsonDecode(res.body);

                          //    showFiles(value.path);

                          isLoading=false;
                          setState(() {

                          });

                          var headers = {
                            "Content-Type": "application/octet-stream",
                            "reportProgress": true,
                            'x-amz-acl': 'public'
                          };


                          //     String upload = "-re -i in.ts -f hls -method PUT ${body["url"]}";

                          /*   FlutterFFmpeg _flutterFFmpeg =   FlutterFFmpeg();
                          int r = await _flutterFFmpeg.execute(command);*/

/*var re = await http.put(
    body["url"],
  headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
  },
  body: ""//binary data,
);*/
                        }

                      },
                    ),
                    )


                  ],
                ),
                ), bottom: 0, ),









                Positioned(child: Container(height: 120,width: size.width,
                child: showTextfield?Row(
                  children: [
                    FlatButton(
                      child: Text("CANCEL", style: TextStyle(

                        inherit: false
                      ), ),
                      textColor: Colors.white,
                      color: Colors.transparent,
                      onPressed: (){

                        showTextfield= !showTextfield;
                        setState(() {

                        });
                      },
                    ),
                    Spacer(),
                    FlatButton(
                      child: Text("DONE", style: TextStyle(

                          inherit: false
                      ), ),
                      textColor: Colors.white,
                      color: Colors.transparent,
                      onPressed: ()async{

                        setState(() {

                        });
                      },
                    )
                  ],
                ) : Container(),
                ), top: 0, ),
              ],
            );






          } else {
            // If the VideoPlayerController is still initializing, show a
            // loading spinner.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),




    );
  }



  Future<String> showFiles(dirPath) async {
    final videosDir = Directory(dirPath);

    var playlistUrl = '';

    final files = videosDir.listSync();
    print(files.length);
    int i = 1;
    for (FileSystemEntity file in files) {
      print(file.path);


      i++;

    }
  }




  void mergeVideo() async{
   final value = await getApplicationDocumentsDirectory() ;
      String fileName =
          "outputjunemerge${DateTime.now().toIso8601String()}.mp4";

      fileMerged = new File(value.path + "/" + fileName);
      File fileIntermediate = new File(value.path + "/in" + fileName);

      finalFileWithAudio = new File(value.path +
          "/" +
          "outputjunewithaudio${DateTime.now().toIso8601String()}.mp4");


      finalfilecutAudio = new File(value.path +
          "/" +
          "outputjunecuthaudio${DateTime.now().toIso8601String()}.mp3");


      for (int i = 0; i < widget.listVideo.length; i++) {
        String s =
            "-i ${widget.listVideo[i].filepath} -c copy -bsf:v h264_mp4toannexb -f mpegts ${value.path + "/" + "intermediate$i.ts"}";
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
          " -c copy -bsf:a aac_adtstoasc ${fileIntermediate.path}";  // command for merging video

    var v = await  _flutterFFmpeg.execute(mergefileCommand) ;
        print("June---->video merge $v");

        //String transpose = "-i ${fileIntermediate.path} -vf \"transpose=1\" ${fileMerged.path}";
        File fileMerged0 = new File(value.path + "/aa" + fileName);
        String transpose = "-i ${fileIntermediate.path} -c copy -metadata:s:v:0 rotate=270 -aspect 16:9 ${fileMerged.path}";

        await _flutterFFmpeg.execute(transpose);
      //  await _flutterFFmpeg.execute("-i ${fileMerged0.path} -filter:v fps=fps=30 ${fileMerged.path}");

        if(widget.audioPath.isNotEmpty) {
          String cutAudioCommand = " -i ${widget.audioPath} -ss 00:00:00 -t ${widget.duration} -acodec copy ${finalfilecutAudio.path}"; // command for cut audio


          int code = await _flutterFFmpeg.execute(cutAudioCommand);
          print("June---->cut audio $code");

          String mixiAudioCommand =
              " -i ${fileMerged.path} -i ${finalfilecutAudio
              .path} -c copy -map 0:v:0 -map 1:a:0 ${finalFileWithAudio
              .path}"; // command for mixing audio with merged video

          int r= await  _flutterFFmpeg.execute(mixiAudioCommand) ;
          print("June---->audio merge${r.toString()}");
          _controller = VideoPlayerController.file(finalFileWithAudio);
          _controller.setLooping(true);

          finalVideoPath = finalFileWithAudio.path;
          _initializeVideoPlayerFuture = _controller.initialize();
          setState(() {});
        }
        else {

          finalVideoPath = fileMerged.path;
          _controller = VideoPlayerController.file(fileMerged);

          _controller.setLooping(true);
          _initializeVideoPlayerFuture = _controller.initialize();
          setState(() {});
        }


        generateThumbnails(value);



  }


  List<String> thumbPath = [];

  generateThumbnails(Directory v) async{

    double w = MediaQuery.of(context).size.width - 50;
    int num = (w/30).ceil();



    String path = v.path + "/" +"thumb";
    String command = "-i $finalVideoPath -vf \"select='not(mod(n,$num))',scale=120:120\" -vsync vfr ${v.path}/thum_%d.jpg";
   await _flutterFFmpeg.execute(command);
    for(int i= 1;i<=num;i++)
    {
      thumbPath.add(v.path+"/thum_$i.jpg");
    }
   setState(() {

   });
      print(finalVideoPath);
      print(widget.duration);
      print(num);

  }

  double getImageScale(Matrix4 matr){
    Float64List l = matr.storage;
    final scaleXSq = l[0] * l[0] +
        l[1] * l[1] +
        l[2] * l[2];

    return sqrt(scaleXSq);
  }


  int changableKeys = 0;



  hideBorders({Key myKey}){
    for(int i =0; i<listOverlays.length;i++)
    {
      if(listOverlays[i].isBorderShown())
      {

        if(myKey!=listOverlays[i].key)
          listOverlays[i].hideShowBorder();
      }
    }
  }




}





