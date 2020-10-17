import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
 import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lamp/lamp.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qvid/BottomNavigation/AddVideo/ProgressBar.dart';
import 'package:qvid/BottomNavigation/AddVideo/reviewScreenSSbasedLogic.dart';
import 'package:qvid/BottomNavigation/AddVideo/sounds.dart';
import 'package:qvid/BottomNavigation/Home/dynamicBottomSheet.dart';
import 'package:qvid/Functions/Slider.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Model/MediaInfo.dart';
import 'package:qvid/Routes/routes.dart';
import 'package:qvid/Screens/review_screen.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:path/path.dart' as path;
import 'package:qvid/Uploader/FileUploader.dart';
import 'package:torch_compat/torch_compat.dart';

import 'countDownAnimation.dart';
// Import package

class AddVideo2 extends StatefulWidget {
  @override
  _AddVideoState createState() => _AddVideoState();
}

class _AddVideoState extends State<AddVideo2> {
  CameraController controller;
  List<CameraDescription> cameras;
  bool isFront = false;

  bool _hasFlashlight = false;
  bool _lightFlag = false;
  double _MaxScaleZoom = 4;
  String fileName = "";

  bool isRecordingStarted = false;
  double _start = 30;
  Timer _timer;
  Timer countDownTimer;

  var player = AudioPlayer();

  double recordTill ;
  int countdown =3;
  int countdownSelected =3;
  bool isTimerVisible = false;

  List<MediaInfo> list = List();
  String audioPath = "";

  List<double> timers = [];
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
    Progress.stops = [];
  }

  Size size;

  @override
  Widget build(BuildContext context) {

    if(controller!=null)    print(controller.value.aspectRatio);

    size = MediaQuery.of(context).size;
    var deviceRatio = size.width / size.height;
    return SafeArea(
      child: Scaffold(
        body: Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            controller == null
                ? Container()
                : !controller.value.isInitialized
                    ? Container()
                    : Transform.scale(
                        alignment: Alignment.topCenter,
                        scale: controller.value.aspectRatio / deviceRatio,
                         child: InteractiveViewer(
                          child: AspectRatio(
                           child:  CameraPreview(controller),
                            aspectRatio: controller.value.aspectRatio,
                          ),
                          maxScale: _MaxScaleZoom,
                        )
                         ),
            Positioned(
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: secondaryColor,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              top: 20,
              left: 8,
            ),
           Align(
              alignment: AlignmentDirectional.topCenter,
              //top: 30,
//             left: size.width/2 - 30,
              child: Padding(
                padding: EdgeInsets.only(top: 20),
                child: FlatButton(
                  child: Container(
                    child: Text(
                     Functions.isNullEmptyOrFalse(fileName)? "Add Sound" : fileName,
                      style: TextStyle(
                          inherit: false,
                          color: _progress >0? Colors.white54:Colors.white.withOpacity(0.9),
                          shadows: [
                            Shadow(
                                color: _progress >0 ?Colors.black12:Colors.black38,
                                blurRadius: 2,

                                offset: Offset(0, 1))
                          ]),
                    ),
                  ),
                  onPressed: _progress >0? null: () async {
                    /*FilePickerResult result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.audio,
                    );*/

                    List<String> l = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GetSounds ()),
                    );



                    if(l!=null)
                      {
                        audioPath = l[0];

                        File picture = File(audioPath);
                        String dir = path.dirname(picture.path);
                        String newPath = path.join(dir, 'test.mp3');
                        print('NewPath: ${newPath}');
                        picture.renameSync(newPath);
                        audioPath = newPath;
                        File(audioPath).existsSync();
                        player.setFilePath(audioPath);

                        setState(() {
                          fileName = l[1];
                        });

                      }

                   },
                ),
              ),
            ),
            Positioned(
              child: IconButton(
                  icon: Icon(
                    Icons.perm_media,
                    color: secondaryColor,
                  ),
                  onPressed: () async {
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
                  }),
              bottom: 50,
              left: size.width / 8,
            ),
            Positioned(
              child: GestureDetector(
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor:
                      isRecordingStarted ? Colors.green : Colors.red,
                  foregroundColor:
                      isRecordingStarted ? Colors.green : Colors.red,
                  child: Icon(
                    Icons.fiber_manual_record,
                    color: isRecordingStarted ? Colors.green : Colors.red,
                    size: 30,
                  ),
                ),
                onTap: () {
                  playPauseVideo();
                },
              ),
              bottom: 50,
              left: size.width / 2 - 30,
            ),
            Positioned(
              child: (list.length == 0 || isRecordingStarted)
                  ? Container()
                  : IconButton(
                      icon: Icon(
                        Icons.backspace,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (list.length == 0) {
                          return;
                        }

                        Progress.changeSpeed(2);
                        if (list.length == 1) {
                          _progress = 0;
                          player.seek(Duration(seconds: 0));

                          _start = 30;
                        } else {
                          _start = list[list.length - 2].duration;
                          _progress = 30 -list[list.length - 2].duration;
                          player.seek(Duration(seconds: _progress.toInt()));

                        }

                        Progress.removeLastSegmet();
                        list.removeLast();
                        setState(() {});
                      }),
              right: size.width / 5,
              bottom: 50,
            ),
            Positioned(
              child: _start < 25
                  ? IconButton(
                      onPressed: () {
                        //controller?.dispose();

                        //_timer.cancel();
                        //_timer=null;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReviewScreen2(
                                    listVideo: list,
                                    audioPath: audioPath,
                                    duration: 30 - _start,
                                  )),
                        );
                      },
                      icon: Icon(
                        Icons.navigate_next,
                        color: Colors.white,
                      ),
                    )
                  : Container(),
              right: size.width / 10,
              bottom: 50,
            ),

            /* Positioned(
              //alignment: Alignment.bottomCenter,

              bottom: 50,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child:      Container(
                  width: size.width,
                  child:                Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[


                      Spacer(flex: 2,),
                      Spacer(),



                      Spacer(),


                   */
            /*   GestureDetector(
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
                      ),*/
            /*

                      Spacer()
                    ],
                  ),
                )

              ),
            ),*/

         !isRecordingStarted?   Positioned(
              child: Column(
                children: [
                  GestureDetector(
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                      onTap: () {
                        if (isFront) {
                          changeCamera(cameras[0]);
                        } else {
                          changeCamera(cameras[1]);
                        }
                      }),
                  Container(
                    height: 18,
                  ),
                 _hasFlashlight? GestureDetector(
                      child: Icon(
                      ! _isOn?Icons.flash_on_outlined:  Icons.flash_off_outlined,
                        color: Colors.white,
                      ),
                      onTap: _turnFlash) : Container(),
                  Container(
                    height: _hasFlashlight?18:0,
                  ),
                  GestureDetector(
                      child: Icon(
                        Icons.timer,
                        color: Colors.white,
                      ),
                      onTap: () async {
                        var d= await showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: Colors.white, //backgroundColor.withOpacity(0.3),
                            shape: OutlineInputBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(35.0)),
                                borderSide: BorderSide.none),
                            context: context,
                            builder: (context) {
                               List<Widget> l = [];

                              l.add(Container(height: 10,));

/*
                              l.add(Row(
                                children: [
                                  Spacer(),
                                 GestureDetector(
                                   child:  Container(height: 30,width: 30,
                                     decoration: BoxDecoration(
                                         color: countdownSelected == 3 ? Colors.black54 : Colors.black87,
                                         borderRadius: BorderRadius.circular(20)

                                     ),
                                     child: Center(child: Text("3", style: TextStyle(color: Colors.white70, inherit: false, fontSize: 12),),),

                                   ),onTap: (){
                                     countdownSelected = 3;
                                     setState(() {

                                     });
                                 },
                                 ),
                                  Container(width: 10,),
                                 GestureDetector(
                                   child:  Container(height: 30,width: 30, decoration: BoxDecoration(
                                       color: countdownSelected == 10 ? Colors.black54:Colors.black87,
                                       borderRadius: BorderRadius.circular(20)

                                   ),
                                     child: Center(child: Text("10", style: TextStyle(color: Colors.white70, inherit: false, fontSize: 12),),),
                                   ),onTap: (){
                                     countdownSelected = 10;
                                     setState(() {

                                     });
                                 },
                                 )
                                ],
                              ));
*/

                              l.add(Container(height: 10,));


                              l.add(SliderWidget(

                                min: 30-_start.toInt()+1,
                                max: 30,
                                initial: recordTill,
                                fullWidth: true,

                              ));
                              l.add(Container(height: 30,));
                              l.add(
                                Container(
                                  height: 50,
                                  width: size.width,
                                  child:
                                  FlatButton(onPressed: (){
                                    recordTill =   double.tryParse(SliderWidgetState.sliderValue.toStringAsFixed(3)) ;

                                    Navigator.pop(context, true);






                                  }, child: Text("Start recording", style: TextStyle(inherit: false, color: Colors.black),)),
                                )

                              );



                              return MyBottomSheet(


                                context,
                                list: l,
                                enableBackDropFilter: false,
                                title: "Select time of next snippet",
                                textColor: Colors.black87,
                                titleSize: 14,
                              );
                            });


                       if(d !=null)
                         {
                           if(d==true)
                             {
                               countdown = countdownSelected;
                               isTimerVisible = true;

                               setState(() {

                               });







                               if (countDownTimer == null) {
                                 countDownTimer= new Timer.periodic(
                                   Duration(seconds: 1),
                                       (Timer timer) {
                                     countdown--;
                                      setState(() {

                                     });
                                     if(countdown<1)
                                     {
                                       isTimerVisible = false;

                                       playPauseVideo();


                                       // countDownTimer = null;
                                       countDownTimer.cancel();
                                       countDownTimer = null;

                                     }
                                   },
                                 );
                               }
                             }
                         }

                      }),
                  Container(
                    height: 18,
                  ),
                  GestureDetector(
                      child: Icon(
                        Icons.speed,
                        color: Colors.white,
                      ),
                      onTap: null),
                ],
              ),
              top: 100,
              right: 18,
            ):Container(),

       isTimerVisible?     Align(
              alignment: AlignmentDirectional.center,
              child:             Text(countdown.toString(), style: TextStyle(
                inherit: false, fontSize: 40, color: Colors.white, shadows: [  Shadow(
                  color: Colors.black38,
                  blurRadius: 2,
                  offset: Offset(0, 1))]
              ),)
              ,
            ):Container(),

Positioned(

    bottom: 160,
    left: size.width/2 - 125,
    child: Container(
  height: 60,
  width: 250,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(width: 10,),
      GestureDetector(
        child: Container(
          width: 40,
          child: Center(
            child: Text("0.3"),
          ),
        ),
      ),
      GestureDetector(
        child: Container(
          width: 40,
          child: Center(
            child: Text("0.5"),
          ),
        ),
      ),
      GestureDetector(
        child: Container(
          width: 30,
          child: Center(
            child: Text("1"),
          ),
        ),
      ),
      GestureDetector(
        child: Container(
          width: 40,
          child: Center(
            child: Text("2"),
          ),
        ),
      ),
      GestureDetector(
        child: Container(
          width: 40,
          child: Center(
            child: Text("3"),
          ),
        ),
      ),

      Container(width: 10,),

    ],
  ),

  decoration: BoxDecoration(
    color: Colors.black54,
    borderRadius: BorderRadius.circular(10)
  ),
))



,            ProgressBar(size),

          ],
        ),
      ),
    );
  }

  initFlashlight() async {
    bool hasFlash = await Lamp.hasLamp;
   // print("Device has flash ? $hasFlash");
 //   setState(() { _hasFlashlight = hasFlash; });
  }

  bool _isOn = false;
  double _intensity = 1.0;

  Future _turnFlash() async {


    _isOn ?                     TorchCompat.turnOff()
    :                     TorchCompat.turnOn();

    var f = await Lamp.hasLamp;
    setState((){
      _hasFlashlight = f;
      _isOn = !_isOn;
    });
  }


  Future<void> getCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.high);


    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  Future<void> changeCamera(CameraDescription camera) async {
    controller = CameraController(camera, ResolutionPreset.high);
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
    print("DISPOSE");
    controller?.dispose();
    player.dispose();
    if(_timer!=null)
    _timer.cancel();
    if(countDownTimer!=null)
      countDownTimer.cancel();
     super.dispose();
  }

  Future<void> initliaze() async {
    directory = await getApplicationDocumentsDirectory();
    await controller.prepareForVideoRecording();
  }


  playPauseVideo(){
      if (!isRecordingStarted) {
      String fileName =
          "outputjune${DateTime.now().toIso8601String()}.mp4";
      File file = new File(directory.path + "/" + fileName);
      controller.startVideoRecording(file.path);
      isRecordingStarted = !isRecordingStarted;
      const oneSec = const Duration(milliseconds: 500);
      Progress.start();
      if(!Functions.isNullEmptyOrFalse(audioPath))
        {
          player.play();

        }
      if (_timer == null) {
        _timer = new Timer.periodic(
          oneSec,
              (Timer timer) {


            if (_start < 0.6) {
              controller.stopVideoRecording();
              Progress.pause();

              isRecordingStarted = !isRecordingStarted;
              _timer.cancel();
              setState(() {});
            } else {

              if(recordTill!=null )
              {
                if(isRecordingStarted)
                {
                  if(recordTill<=(30-_start))
                  {



                    recordTill = null;
                    playPauseVideo();
                  }

                }
              }


              if (isRecordingStarted) {
                _start = _start - 0.5;
                _timer.tick;
                _progress = 0.5 + _progress;
                if (_progress > 4 && _progress < 6) {
                  setState(() {});
                }
              }
            }
          },
        );
      }
      list.add(MediaInfo(-1, file.path));

      setState(() {});
    } else {

      for (int i = 0; i < list.length; i++) {
        if (list[i].duration == -1) {
          list[i].duration = _start;
        }
      }

      if(!Functions.isNullEmptyOrFalse(audioPath))
      {
        player.pause();
      }

      Progress.pause();

      controller.stopVideoRecording();
      isRecordingStarted = !isRecordingStarted;
      setState(() {});
    }
  }
}
