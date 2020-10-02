import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flashlight/flashlight.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Model/MediaInfo.dart';
import 'package:qvid/Routes/routes.dart';
import 'package:qvid/Screens/review_screen.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:path/path.dart' as path;
import 'package:qvid/Uploader/FileUploader.dart';
// Import package

class AddVideo extends StatefulWidget {


  @override
  _AddVideoState createState() => _AddVideoState();
}

class _AddVideoState extends State<AddVideo> {
  CameraController controller;
  List<CameraDescription> cameras;
  bool isFront= false;

  bool _hasFlashlight;
  bool  _lightFlag= false;
  double _MaxScaleZoom = 8;
  String fileName="";

  bool isRecordingStarted = false;
  int _start = 30;
  Timer _timer;

  List<MediaInfo> list = List();
  String audioPath = "";

  double scale = 1.0;

  double _progress = 0.0;

  Directory directory;
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, //top bar color
      statusBarIconBrightness: Brightness.dark, //top bar icons

    ));
    getCamera();
    initFlashlight();

    initliaze();

  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      body: SafeArea(
        child: Stack(
          overflow: Overflow.visible,
          children: <Widget>[

            controller==null?Container():!controller.value.isInitialized?Container():
            InteractiveViewer(child: CameraPreview(controller),
              maxScale: _MaxScaleZoom, ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: secondaryColor,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  _start!=30 ? Padding(
                    padding: const EdgeInsets.only(right:8.0),
                    child: RaisedButton(
                      onPressed: (){
                        controller?.dispose();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReviewScreen(
                                listVideo: list,
                                audioPath: audioPath,
                                duration: 30-_start,
                              )),
                        );
                      },
                      textColor: Colors.white,
                      color: Colors.red,
                      padding: const EdgeInsets.all(8.0),
                      child: new Text(
                        "Next",
                      ),
                    ),
                  ):Container(),

                ],
              ),
            ),
            Align(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [

                    Text("${_start.toString()}sec",style: TextStyle(fontSize: 30),),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        GestureDetector(
                            child: Icon(
                              Icons.music_note,
                              color: secondaryColor,
                            ),
                            onTap: () async{
                              FilePickerResult result = await FilePicker.platform.pickFiles(
                                type: FileType.audio,
                              );
                              audioPath = result.files[0].path;


                              File picture = File(audioPath);

                              String dir = path.dirname(picture.path);
                              String newPath = path.join(dir, 'test.mp3');
                              print('NewPath: ${newPath}');
                              picture.renameSync(newPath);


                              audioPath = newPath;


                              File(audioPath).existsSync();

                              setState(() {
                                fileName = result.files[0].name;
                              });

                              print(result);
                            }
                        ),
                        GestureDetector(
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: isRecordingStarted?Colors.green:Colors.red,
                            foregroundColor:  isRecordingStarted?Colors.green:Colors.red,
                            child: Icon(
                              Icons.fiber_manual_record,
                              color: isRecordingStarted?Colors.green:Colors.red,
                              size: 30,
                            ),
                          ),
                          onTap: ()  {

                            if(!isRecordingStarted) {
                              String fileName = "outputjune${DateTime.now()
                                  .toIso8601String()}.mp4";
                              File file = new File(directory.path + "/" + fileName);
                              controller.startVideoRecording(file.path);
                              isRecordingStarted = !isRecordingStarted;
                              const oneSec = const Duration(seconds: 1);
                              _timer = new Timer.periodic(
                                oneSec,
                                    (Timer timer) => setState(
                                      () {
                                    if (_start < 1) {
                                      controller.stopVideoRecording();
                                      isRecordingStarted = !isRecordingStarted;
                                      timer.cancel();
                                    } else {
                                      _start = _start - 1;
                                      timer.tick;
                                      _progress = 0.034+_progress;
                                    }
                                  },
                                ),
                              );


                              list.add(MediaInfo(-1, file.path));

                              setState(() {

                              });
                            }
                            else
                            {

                              for(int i=0;i<list.length;i++)
                                {
                                  if(list[i].duration == -1)
                                    {
                                      list[i].duration = _start;
                                    }
                                }

                              controller.stopVideoRecording();
                              isRecordingStarted = !isRecordingStarted;
                              _timer.cancel();
                              setState(() {

                              });

                            }

                          },
                        ),
//
//                        IconButton(icon: Icon(Icons.delete_forever,color: Colors.white,), onPressed: (){
//
//                          for(int i =0;i<list.length;i++)
//                            {
//
//                              if(i==list.length-1)
//                                {
//                                  int time  = list[i].duration;
//                                  _start = _start- time ;
//                                }
//
//
//                            }
//
//                          list.removeLast();
//                          setState(() {
//
//                          });
//
//                        }),
                        GestureDetector(
                            child: Icon(
                              Icons.perm_media,
                              color: secondaryColor,
                            ),

                            onTap: () async{

                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => FileUploader()),
                              );
//                              FilePickerResult result = await FilePicker.platform.pickFiles(
//                                type: FileType.video,
//                              );
//                              setState(() {
//                                fileName = result.files[0].name;
//                              });
//                              print(result);
                               }
                        ),

                      ],
                    ),
                  ],
                ),
              ),
              alignment: Alignment.bottomCenter,
            ),
            Align(child: Padding(
              padding: const EdgeInsets.only(left:20.0,right: 20,top: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(fileName)),
                  Column(
                    children: [
                      GestureDetector(child: Icon(Icons.camera_alt,color: Colors.white,),onTap: (){
                        if(isFront) {
                          changeCamera(cameras[0]);
                        }
                        else{
                          changeCamera(cameras[1]);
                        }
                      }),
                      IconButton(icon: Icon(Icons.flash_off,color: Colors.white,), onPressed: null)
                    ],
                  ),
                ],
              ),
            ),alignment: Alignment.topRight,),
            Padding(
              padding: const EdgeInsets.only(bottom:16.0,left: 8.0,right: 8.0,top: 8.0),
              child: LinearProgressIndicator(
                backgroundColor: Colors.white,
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
                value: _progress,
              ),
            ),
          ],
        ),
      ),
    );
  }

  initFlashlight() async {
    bool hasFlash = await Flashlight.hasFlashlight;
    print("Device has flash ? $hasFlash");
    setState(() {
      _hasFlashlight = hasFlash;
    });
  }
  Future<void> getCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  Future<void> changeCamera(CameraDescription camera) async {
    controller = CameraController(camera, ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {

        return;
      }
      isFront = !isFront;
      setState(() {});
    });
  }



  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> initliaze() async {

     directory = await getApplicationDocumentsDirectory();
     await controller.prepareForVideoRecording();
  }
}
