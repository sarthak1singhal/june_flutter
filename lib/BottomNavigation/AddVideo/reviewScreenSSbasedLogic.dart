import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
 import 'package:flutter/cupertino.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:qvid/BottomNavigation/AddVideo/StickerChooser.dart';
import 'package:qvid/BottomNavigation/AddVideo/post_info.dart';
import 'package:qvid/BottomNavigation/AddVideo/sounds.dart';
import 'package:qvid/BottomNavigation/Home/dynamicBottomSheet.dart';
 import 'package:qvid/Functions/MergeImagesWithVideo.dart';
import 'package:qvid/Model/OverlayDeatils.dart';
import 'package:qvid/Theme/colors.dart';

 import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:path_provider/path_provider.dart';

import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Model/MediaInfo.dart';
import 'package:qvid/Model/OverlayModel.dart';
import 'package:qvid/Model/OverlayModelTimeScreen.dart';
 import 'package:screenshot/screenshot.dart';
 import 'package:video_player/video_player.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import 'TextOverlay.dart';
import 'hideShowScreen.dart';


class ReviewScreen2 extends StatefulWidget {
  List<MediaInfo> listVideo;
  String audioPath;
  double duration ;
  String audioId ;
  ReviewScreen2({this.listVideo, this.audioPath,this.duration, this.audioId}) {}

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ReviewState();
  }
}

class ReviewState extends State<ReviewScreen2>  {
  VideoPlayerController _controller;

  GlobalKey key = GlobalKey();
   String finalVideoPath;

   final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

  File fileMerged ;
  File finalFileWithAudio ;
  ScreenshotController screenshotController = ScreenshotController();
  ScreenshotController parentScreenshotController = ScreenshotController();


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

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    mergeVideo();
    super.initState();
    _lowerValue = 0;
    _upperValue = widget.duration;
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
bool isChangingAudio = false;


   String audioName = "";

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    if(firstLoad)
    {
      firstLoad = false;
       initialTextOffset = Offset(size.width/2, size.height/4 );
    }



    return Scaffold(key: _scaffoldKey ,
      resizeToAvoidBottomInset : false,
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the VideoPlayerController has finished initialization, use
            // the data it provides to limit the aspect ratio of the VideoPlayer.

            return  Stack(
              overflow: Overflow.visible,

              children: [
             Screenshot(
               controller: parentScreenshotController,
               child:   SafeArea(
                 left: false,
                 right: false,
                 child:  Container(

                   height:size.height,
                   width: size.width,
                   child:  Align(
                       alignment: Alignment.topCenter,
                       child:
                        AspectRatio(


                         child: Stack(
                           overflow: Overflow.visible,

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

                                   if(isChangingAudio)
                                   {
                                    return;
                                   }
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





                           ],
                         ),

                         aspectRatio: 9/16,
                       )),
                 ),),
             ),

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


                              selectedWidget.endTime = _upperValue;
                              selectedWidget.startTime= _lowerValue;
                              if(!(selectedWidget.startTime==0 && selectedWidget.endTime == widget.duration)) {
                                for (int i = 0; i < listOverlays.length; i++) {
                                  if (selectedWidget.key == listOverlays[i].key) {
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

                              _lowerValue = 0;
                              _upperValue = widget.duration;
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
                    Container(width: 20,),
                    GestureDetector(
                      child: Container(
                        child: IconButton(
                          icon: Icon(Icons.music_note, color: Colors.white,),
                          onPressed: () async {


                            if(isChangingAudio)
                            {
                              Functions.showToast("Please wait a second", context);

                            }
                            _controller.pause();
                            List<String> l = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => GetSounds ()),
                            );


                           
                            if(l!=null)
                            {
                            String  audioPath = l[0];

                               widget.audioId = l[2];


                               isChangingAudio = true;

                              final value = await getApplicationDocumentsDirectory() ;
                              String fileName =value.path + "/june${DateTime.now().toIso8601String()}.mp4";
                              String ap =value.path + "/${DateTime.now().toIso8601String()}.mp3";

                              String cutAudioCommand = " -i $audioPath -ss 00:00:00 -t ${widget.duration} -acodec copy $ap"; // command for cut audio

                              int r = await _flutterFFmpeg.execute(cutAudioCommand);
                              int h = await _flutterFFmpeg.execute(" -i $finalVideoPath -i $ap -c copy -map 0:v:0 -map 1:a:0 $fileName");

                              String tbd =finalVideoPath;
                              finalVideoPath = fileName;
                              _controller = VideoPlayerController.file(File(fileName));

                              await _controller.initialize();
                              _controller.setLooping(true);


                              isChangingAudio = false;


                              setState(() {
                                audioName = l[1];
                              });

                              _controller.play();

                              File(tbd).deleteSync();
                              File(audioPath).deleteSync();
                              File(ap).deleteSync();

                            }

                          },
                        ),
                      ),


                    ),

                    SizedBox(width: 5,),
                    GestureDetector(
                      child: Container(
                        child: IconButton(
                          icon: Icon(Icons.image, color: Colors.white,),
                          onPressed: () async {
                            Widget  stickerWidget =  await showModalBottomSheet(
                                isScrollControlled: true,
                                barrierColor: Colors.black.withOpacity(0.16),
                                backgroundColor: Colors.white.withOpacity(0.02),//backgroundColor.withOpacity(0.3),
                                shape: OutlineInputBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(35.0)),
                                    borderSide: BorderSide.none),
                                context: context,
                                builder: (context) {


                                  return StickerChooser(context,  title: "Stickers",
                                    textColor: Colors.white,
                                  );
                                }


                            );

                            if(stickerWidget!=null)
                            {
                              EdgeInsets p = EdgeInsets.all(14);

                              getOverlayWidget(size, Container(color: Colors.transparent,  child: Container(
                                child: stickerWidget,
                              ), padding: p, ));
                            }


                          },
                        ),
                       ),


                    ),

                    SizedBox(width: 5,),
                    Container(
                        child: IconButton(
          icon: Icon(Icons.text_fields, color: Colors.white,),
                          onPressed: () async{
            showBackButton = false;
            setState(() {

            });
                            offsetColorPicker = Offset(50, size.height- MediaQuery.of(context).viewInsets.bottom-200);

                            _textController.text = "";


                            TextOverlay w = TextOverlay(
                              onCancel: (){
                                Navigator.pop(context);
                                showBackButton = true;
                                setState(() {

                                });

                              },

                              focusNode: focusNode,
                              colorOffset: offsetColorPicker,
                            );

                            w.onDone = (){
                              TextStyle style = w.getStyle();
                              String t= w.getText();

                              print(style);
                              print(t);
                              double scale = 1.0;
                              if(t.length >300)
                              {
                                scale = 0.5;
                              }
                              else if(('\n'.allMatches(t).length + 1) > 12)
                              {
                                if(('\n'.allMatches(t).length + 1) < 30)
                                  scale = scale*12/('\n'.allMatches(t).length + 1) +0.13 ;
                                else
                                  scale = scale*10/('\n'.allMatches(t).length + 4) ;
                              }


                              if(scale==1.0) {

                                EdgeInsets p = EdgeInsets.all(14);
                                if(t.length<10)
                                {
                                  p = EdgeInsets.all(20);
                                }
                                if(t.length<=4)
                                {
                                  p = EdgeInsets.all(34);
                                }
                                getOverlayWidget(size, Container(color: Colors.transparent,  child: Text(t, style: style,
                                  overflow: TextOverflow.visible, ), padding: p, ));
                              }
                              else{
                                getOverlayWidget(size, Container(
                                  color: Colors.transparent,

                                  child: Transform.scale(scale: scale, alignment: Alignment.topCenter, child: Text(t, style: style,
                                    overflow: TextOverflow.visible,),),
                                  padding: EdgeInsets.all(14),

                                ));
                              }
                              Navigator.pop(context);
                              showBackButton = true;
                              setState(() {

                              });


                            };
                             await Navigator.of(context).push(
                              PageRouteBuilder(
                                opaque: false, // set to false
                                pageBuilder: (context, a, a2) => w,
                              ),
                            );


             showBackButton = true;
            setState(() {

            });

                           },
          ),
                       ),


                    SizedBox(height: 20,),


                    Spacer(),

                    Container(height: 40,width: 90,
                    child: RaisedButton(
                      color: mainColor,
                      child: Text("Next",),
                      textColor: Colors.white,
                      onPressed: () async{


                        if(isChangingAudio)
                          {
                            Functions.showToast("Please wait a second", context);

                          }


                        hideBorders();
                        setState(() {

                        });
                        if(MergeImagesWithVideo.queue.length>1)
                        {

                          Functions.showToast("Please wait for previous file to get uploaded", context);
                          return;
                        }


                        if(!isLoading) {

                          isLoading = true;

                          final value = await getApplicationDocumentsDirectory();
                          _controller.pause();
                         /* loadingImage = await parentScreenshotController.capture(
                              path: value.path + "/load" + DateTime
                                  .now()
                                  .millisecondsSinceEpoch
                                  .toString() + ".png", pixelRatio: 1.75);*/


                           setState(() {

                           });

                          // GallerySaver.saveImage(loadingImage.path);
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


                          print( 1/_controller.value.aspectRatio);
                          List<OverlayDetails> overlayDetails = [];
                          if(listOverlays.length!=0) {

                            if ((listOverlays[0].startTime == 0 &&
                                listOverlays[0].endTime == widget.duration)) {
                              File fScreenShot = await screenshotController
                                  .capture(
                                  path: screenshotFile.path, pixelRatio: 1/_controller.value.aspectRatio);
                              overlayDetails.add(OverlayDetails(
                                  screenshotFile.path, 0, widget.duration));
                            }


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
                                await listOverlays[i].takeScreenshot(imgPath, 1/_controller.value.aspectRatio);

                                overlayDetails.add(OverlayDetails(imgPath, listOverlays[i].startTime, listOverlays[i].endTime));

                                if(tempChange)
                                {
                                  listOverlays[i].hideChildVisibility();
                                }

                              }
                            }



                          }


                          print(_controller.value.size.width);
                          MergeImagesWithVideo.mergeImages(finalVideoPath,fileName, overlayDetails, _controller.value.size);

                          isLoading=false;

                          await  Navigator.push(context, MaterialPageRoute(builder: (context)=>PostInfo(widget.audioId)));

                          setState(() {

                          });
                    }

                      },
                    ),
                    )


                  ],
                ),
                ), bottom: 0, ),






























          showBackButton?    Positioned(child: Functions.backButtonWithGlassEffect(context),
                top: 43,
                left: 5,
              ) :Container(width: 0,height: 0,),




              isLoading ?                                  Container(height: size.height, width: size.width, color: backgroundColor, child: Center(child: Functions.showLoaderSmall(),),)
                  : Container(height: 0,width: 0,)





              ],
            );






          } else {
            // If the VideoPlayerController is still initializing, show a
            // loading spinner.
            return Functions.showLoaderSmall();
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

bool showBackButton = true;



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

        //String transpose = "-i ${fileIntermediate.path} -vf \"transpose=1\" ${fileMerged.path}";
        File fileMerged0 = new File(value.path + "/aa" + fileName);
        String transpose = "-i ${fileIntermediate.path} -c copy -metadata:s:v:0 rotate=270 -aspect 16:9 ${fileMerged.path}";
   /*if(widget.listVideo[0].camera==1) {
        */   /*String  transpose = "-i ${fileIntermediate
              .path} -c copy -metadata:s:v:0 rotate=90 -aspect 16:9 ${fileMerged
              .path}";*/
        await _flutterFFmpeg.execute(transpose);
        //fileMerged  = File(fileIntermediate.path);



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
          _initializeVideoPlayerFuture = _controller.initialize().whenComplete(() {
            widget.duration = _controller.value.duration.inSeconds.toDouble() + _controller.value.duration.inMilliseconds%1000;
            print(widget.duration);

          });
          setState(() {});
        }
        else {

          finalVideoPath = fileMerged.path;
          _controller = VideoPlayerController.file(fileMerged);

          _controller.setLooping(true);
          _initializeVideoPlayerFuture =  _controller.initialize().whenComplete(() {
            widget.duration =  _controller.value.duration.inMilliseconds/1000;
            print(widget.duration.toString() + "DURation");

          });
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



  getOverlayWidget(Size size, Widget wid){
    OverlayWidget w = OverlayWidget(height: size.height,width: size.width, key: Key(changableKeys.toString()), startTime: 0, endTime: widget.duration.toDouble(), child: wid,);

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

  }





}





