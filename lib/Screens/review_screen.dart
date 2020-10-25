import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:gallery_saver/gallery_saver.dart';
import 'package:http/http.dart' as http;

 import 'package:flutter/material.dart';
 import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
 import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qvid/Functions/EncodingProvider.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Functions/VideoDownloader.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Model/MediaInfo.dart';
import 'package:screenshot/screenshot.dart';
 import 'package:video_player/video_player.dart';

import 'TextPainter.dart';

class ReviewScreen extends StatefulWidget {
  List<MediaInfo> listVideo;
  String audioPath;
  int duration ;
  ReviewScreen({this.listVideo, this.audioPath,this.duration}) {}

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ReviewState();
  }
}

class ReviewState extends State<ReviewScreen>  {
  VideoPlayerController _controller;

  GlobalKey key = GlobalKey();
  GlobalKey parentKey = GlobalKey();
  String finalVideoPath;

   final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

  File fileMerged ;
  File finalFileWithAudio ;
  ScreenshotController screenshotController = ScreenshotController();

  Offset offset = Offset(0.0, 50.0);

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

  Matrix4 matrix = Matrix4.identity();

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
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    print(MediaQuery.of(context).size.height.toString() +" "+ MediaQuery.of(context).size.width.toString());

    if(firstLoad)
      {
        firstLoad = false;
        offset = Offset(size.width /2-10, size.height/5);
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

            return  Container(
              height: MediaQuery.of(context).size.height,
              child: Center(child: AspectRatio(
                child:  Stack(
                  children: [
                    VideoPlayer(_controller),



/*
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
                          padding:   EdgeInsets.all(8.0),
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
                ),*/

                    Screenshot(
                      controller: screenshotController,
                      child: Container(
                        child: Stack(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              child: MatrixGestureDetector(
                                  onMatrixUpdate: (Matrix4 m, Matrix4 tm, Matrix4 sm, Matrix4 rm) {
                                    if(m.getMaxScaleOnAxis()>2)
                                    {
                                      //m.scale(1);

                                      return;
                                    }

                                    print(getImageScale(m));
                                    final RenderBox box = key.currentContext.findRenderObject();
                                    // final RenderBox parent = parentKey.currentContext.findRenderObject();
//                            var translation = box?.getTransformTo(null)?.getTranslation();



                                    o  =box.localToGlobal(Offset.zero);

                                    double h = size.width *16/9;
                                    double p =  o.dy+ (size.height-h)/2;
                                    o = Offset(o.dx,p);
                                    // o  = parent.globalToLocal(o);
                                    print(o);
                                    //                          o= box.paintBounds
//                                .shift(Offset(translation.x, translation.y));

                                    //print(o.left);
                                    //    print(m.getMaxScaleOnAxis());
                                    //   print(m.getTranslation());
                                    setState(() {
                                      print("JAH");
                                      matrix = m;
                                    });
                                  },
                                  child :
                                  Transform(

                                    child:   pngFilePath==null?
                                    Container(height: 100, width: 100 ,
                                      child:  CustomPaint(
                                        painter: new MyPainter(

                                            Colors.white, "SASASA", matrix.storage),
                                      ) ,
                                    )
                                        :  Image.file(

                                      file,                 key: key,
                                    ),

                                    transform: matrix,
                                  )
                              ),

                            ),

                            Positioned(
                              child: Container(height: 30,width: 30, color: Colors.greenAccent,),
                              top: o== null ?0 : o.dy,
                              left: o== null ? 0 : o.dx,
                            )
                          ],
                        ),

                      ),
                    ),



                    /*     Container(
                  decoration: BoxDecoration(

                  ),
                  child:   Positioned(
                         top: offsetSec.dy,
                      left: offsetSec.dx,
                      child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                            offsetSec = Offset(
                            offsetSec.dx + details.delta.dx, offsetSec.dy + details.delta.dy);
                            });
                      },
                      child: Container(
                    //    child: TextPaint(Colors.white, "KMASKMASM"),
                        color: Colors.pink,
                      ),
          ),

          ),
                ),*/



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


                              offsetColorPicker = Offset(50, MediaQuery.of(context).viewInsets.bottom-200);

                              _textController.text = "";
                              setState(() {
                                showTextfield = !showTextfield;
                              });
                              focusNode.requestFocus(FocusNode());

                            },
                          ),
                          SizedBox(height: 20,),
                          GestureDetector(
                            child: Container(
                              child: Text(
                                "Save Img on video",
                                style: TextStyle(color: Colors.black),
                              ),
                              padding: EdgeInsets.all(8.0),
                              color: Colors.white,
                            ),
                            onTap: () async{

                              final value =    await getApplicationDocumentsDirectory();



                              print(finalVideoPath);

                              String fileName =
                                  "vid${DateTime.now().millisecondsSinceEpoch.toString()}.mp4";
                              File f = new File(value.path + "/" + fileName);


                              double height  = MediaQuery.of(context).size.height;
                              double width  = MediaQuery.of(context).size.width;

                              double h = width *16/9;
                              double p = 1280/h * (o.dy- (height-h-90)/2);
                              double w = 720/width * (o.dx-100);

                              double x1 = w;//- height*0.72;
                              double y1 = p;

                              print(x1  );
                              print(o.dx);


                              
                               double rotation = atan2(-matrix.getRotation().row0[1], matrix.getRotation().row1[1]);
                           //   print(acos((matrix.getRotation().trace()-1)/2));
                              print("details");






                              File screenshotFile = File(value.path+"/"+DateTime.now().millisecondsSinceEpoch.toString()+".png");
                              File screenshotFile2 = File(value.path+"/"+DateTime.now().millisecondsSinceEpoch.toString()+"2.png");
                             await  screenshotController.capture(path:screenshotFile.path,pixelRatio: 1.75);


                              String cropImageTo720p = "-i ${screenshotFile.path} -vf \"crop=720:1280:0:0\" ${screenshotFile2.path}";

                              FlutterFFmpeg _flutterFFmpeg =   FlutterFFmpeg();
                            //  int r0 = await _flutterFFmpeg.execute(cropImageTo720p);
                              print("CROPPED");
                            //  await GallerySaver.saveImage(screenshotFile2.path);
                              await GallerySaver.saveImage(screenshotFile.path);


                              // String command = "-i $finalVideoPath -i ${screenshotFile.path} -filter_complex \"[1:v] rotate=0:c=none:ow=rotw(iw):oh=roth(ih) [rotate];[rotate]scale=823:-1[scale];[0:v][scale] overlay=main_w-overlay_w+51:main_h-overlay_h-10:enable='between(t,0,3)'[out]\" -map [out] -pix_fmt yuv420p -c:a copy ${f.path}";
                               String command = "-i $finalVideoPath -i ${screenshotFile.path} -filter_complex \"[0:v][1:v] overlay=0:0:enable='between(t,0,3)'[out]\" -map [out] -pix_fmt yuv420p -c:a copy ${f.path}";
                                //String command = "-i $finalVideoPath -i ${file.path} -filter_complex \"[1:v] rotate=$rotation:c=none:ow=rotw(iw):oh=roth(ih) [rotate];[rotate]scale=${(getImageScale(matrix)*1080).toStringAsFixed(2)}:-1[scale];[0:v][scale] overlay=${x1.toStringAsFixed(2)}:${y1.toStringAsFixed(2)}:enable='between(t,0,2)'[out]\" -map [out] -pix_fmt yuv420p -c:a copy ${f.path}";

                               print( _controller.value.size);


                               int r = await _flutterFFmpeg.execute(command);
                              //  String p = await EncodingProvider.encodeHLS(finalVideoPath, value.path, fileName);






                              GallerySaver.saveVideo(f.path).then((bool success) {});



    //                          var res = await Functions.unsignPostReq(Variables.base_url+"getUploadUrl", jsonEncode({}));

  //                            var body = jsonDecode(res.body);

                          //    showFiles(value.path);


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

                            },
                          ),
                          SizedBox(height: 20,),



                        ],
                      ),
                      alignment: Alignment.bottomCenter,
                    ),


                    showTextfield? Container(
                      color:Colors.black26,
                    ) : Positioned(top: 0,left: 0,child: Container(height: 0,width: 0,),),


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
                    ) :Container(),

                    showTextfield ? Positioned(
                      top: 30,
                      right: 7,
                      child: FlatButton(
                        child: Text("DONE", style: TextStyle(

                        ), ),
                        textColor: Colors.white,
                        color: Colors.transparent,
                        onPressed: ()async{

                          pngFilePath = await  _generateImage();
//                      textOverlayList.add();

                          file = File(pngFilePath);


                          setState(() {

                          });
                        },
                      ),
                    ):Container(),
                    showTextfield ? Positioned(
                      top: 30,
                      left: 7,
                      child: FlatButton(
                        child: Text("CANCEL", style: TextStyle(

                        ), ),
                        textColor: Colors.white,
                        color: Colors.transparent,
                        onPressed: (){

                          showTextfield= !showTextfield;
                          setState(() {

                          });
                        },
                      ),
                    ):Container(),


                  ],
                ),

                aspectRatio: 0.5625,
              ),),
            ) ;






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


  getTextLayouts(){

  }



  Future<String> _generateImage({double height, double width, Color textColor, Color backgroundColor, double fontSize}) async {
    // Get this size from your video
    final videoSize = Size(1080.0, 1080.0);

    final textStyle = TextStyle(
      fontFamily: 'Roboto',
      fontSize: 24.0,
      color: Colors.red,
    );
    final text = TextSpan(text: 'Hello World', style: textStyle);

    // Generate the image
    final imageInfo = await createTextImage(videoSize, text);

    // Convert to png
    final imageBytes =await
    imageInfo.toByteData(format: ui.ImageByteFormat.png) ;
    File file;
    final value =    await getApplicationDocumentsDirectory();



    print(value.path);

    String fileName =
        "im${DateTime.now().millisecondsSinceEpoch.toString()}.mp4";


    file = new File(value.path + "/" + fileName);

    File(file.path)
        .writeAsBytesSync(imageBytes.buffer.asInt8List());

    return file.path;
    }
    String  pngFilePath;
    File  file;



  void mergeVideo() {
    getApplicationDocumentsDirectory().then((value) async {
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

      _flutterFFmpeg.execute(mergefileCommand).then((value) async {
        print("June---->video merge $value");

        //String transpose = "-i ${fileIntermediate.path} -vf \"transpose=1\" ${fileMerged.path}";
        String transpose = "-i ${fileIntermediate.path} -c copy -metadata:s:v:0 rotate=270 -aspect 16:9 ${fileMerged.path}";

        await _flutterFFmpeg.execute(transpose);

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



      });
    });

  }




  double getImageScale(Matrix4 matr){
    Float64List l = matr.storage;
    final scaleXSq = l[0] * l[0] +
        l[1] * l[1] +
        l[2] * l[2];

    return sqrt(scaleXSq);
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

Future<ui.Image> createTextImage(Size size, TextSpan text)async {
  final recorder = ui.PictureRecorder();
  final cullRect = Offset.zero & size;
  final canvas = Canvas(recorder, cullRect);
  canvas.scale(7);

  final textPainter = TextPainter(textDirection: TextDirection.ltr, text: text);
  textPainter.layout();

  // draw text in center of canvas, you can adjust this as you like
  final textOffset = cullRect.center.translate(-textPainter.width / 2, textPainter.height / 2);
  textPainter.paint(canvas, textOffset);

  // you can also draw other geometrical shapes, gradients, paths...
  canvas.drawRect(Offset(0, 0) & Size(1080, 1080), Paint()..color = Color(0xffff00ff));

  final picture = recorder.endRecording();
  final image = await picture.toImage(size.width.toInt(), size.height.toInt());

  return image;
}