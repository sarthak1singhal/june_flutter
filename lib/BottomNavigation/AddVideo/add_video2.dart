import 'dart:async';
import 'dart:io';

 import 'package:file_picker/file_picker.dart';
 import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_better_camera/camera.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_ffmpeg/media_information.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lamp/lamp.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qvid/BottomNavigation/AddVideo/ProgressBar.dart';
import 'package:qvid/BottomNavigation/AddVideo/reviewScreenSSbasedLogic.dart';
import 'package:qvid/BottomNavigation/AddVideo/sounds.dart';
import 'package:qvid/BottomNavigation/Home/dynamicBottomSheet.dart';
import 'package:qvid/Functions/LocalColors.dart';
import 'package:qvid/Functions/Slider.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Model/MediaInfo.dart';
 import 'package:qvid/Screens/review_screen.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:path/path.dart' as path;
import 'package:qvid/Uploader/FileUploader.dart';
import 'package:torch_compat/torch_compat.dart';
import 'package:video_player/video_player.dart';

import 'add_video3.dart';
import 'countDownAnimation.dart';
// Import package

class AddVideo2 extends StatefulWidget {
  bool startWithAud;
  List<String> l;

  AddVideo2({ this.l});

   @override
  _AddVideoState createState() {
     if(l == null)
     return _AddVideoState();
     if(l.length == 3)
     return _AddVideoState.startWithSoun(l);
     else{
       return _AddVideoState();

     }
   }
}

class _AddVideoState extends State<AddVideo2>   with WidgetsBindingObserver{
  _AddVideoState();
  _AddVideoState.startWithSoun(List<String> l){
    audioPath = l[0];


    audioId = l[2];
   //    picture.renameSync(newPath);

    player.setFilePath(audioPath);

       fileName = l[1];

  }

  CameraController controller;
  List<CameraDescription> cameras;
  bool isFront = false;

  String audioId;

  bool _hasFlashlight = false;
  bool _lightFlag = false;
  double _MaxScaleZoom = 4;
  String fileName = "";

  bool isRecordingStarted = false;
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
  ProgressBar progressBar = ProgressBar(Size(10,10));
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
    WidgetsBinding.instance.addObserver(this);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
     ]);
  }

  Size size;

  @override
  Widget build(BuildContext context) {


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
                         child:  ZoomableWidget(
                             child: AspectRatio(
                               child:  CameraPreview(controller),
                               aspectRatio: controller.value.aspectRatio,
                             ),
                             onTapUp: (scaledPoint) {
                               controller.setPointOfInterest(scaledPoint);
                             },
                             onZoom: (zoom) {
                                if (zoom < 6) {
                                  scale = zoom;
                                 controller.zoom(zoom);
                               }
                             })
                         ),

           Align(
              alignment: AlignmentDirectional.topCenter,

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
                         //picture.renameSync(newPath);
                        //audioPath = newPath;
                       // File(audioPath).existsSync();
                        player.setFilePath(audioPath);
                        audioId = l[2];

                        setState(() {
                          fileName = l[1];
                        });

                      }

                   },
                ),
              ),
            ),

            align != null && isAligned ? Transform.scale(
              alignment: Alignment.topCenter,
              scale: controller.value.aspectRatio / deviceRatio,
              child: Opacity(
                child: RotatedBox(
                  quarterTurns: 1,
                  child: Container(child: Image.file(align)),
                ),
                opacity: 0.5,

              ),
            ) : Container(width: 0, height: 0,),




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

            Positioned(
              child: isRecordingStarted? Container(): IconButton(
                  icon: Icon(
                    Icons.perm_media,
                    color: secondaryColor,
                  ),
                  onPressed: () async {

                             FilePickerResult result = await FilePicker.platform.pickFiles(
                                type: FileType.video,
                               allowCompression: true,
                               withData: true,
                              );
                              print(result);
                              if(result == null )return;

                             String temp = "outputjune${DateTime.now().toIso8601String()}.${result.files[0].extension}";
                              File file = new File(directory.path + "/" + temp);

                             File newFile =   File(result.files[0].path).copySync(file.path);
                             FlutterFFprobe flutterFFprobe = FlutterFFprobe();
                             MediaInformation mediaInformation = await flutterFFprobe.getMediaInformation(file.path);
                             Map<dynamic, dynamic> mp = mediaInformation.getMediaProperties();
                             String _duration = mp["duration"];
                              print("mp: $_duration ");
                             double d = double.tryParse(_duration );

                             if(progressBar.getTime() + d >30.0){
                               Functions.showToast("Video length is getting longer than 30 sec", context);
                               file.delete();
                               return;
                             };

                             progressBar.setTime(d);


                              double elapsed = progressBar.getTime();
                             list.add(MediaInfo.rotate(  30.0 - elapsed , file.path, 3, directory, 0, cameras[0].sensorOrientation));


                             if(!Functions.isNullEmptyOrFalse(audioPath))
                             {
                               //player.setD;
                               player.seek(Duration(seconds: elapsed.floor(), milliseconds: ((elapsed- elapsed.floor().toDouble())*1000).toInt()));
                               player.pause();
                             }

                          //   progressBar.pause();
                             setState(() {
                               //    fileName = result.files[0].path;
                             });



                             print(result);
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

                    //    Progress.changeSpeed(2);
                        if (list.length == 1) {
                          _progress = 0;
                          player.seek(Duration(seconds: 0));

                          //_start = 30;
                        } else {
                         // _start = list[list.length - 2].duration;
                          _progress = progressBar.getTime();//30 -list[list.length - 2].duration;
                          player.seek(Duration(milliseconds: (progressBar.getTime()*1000).toInt()));

                        }

                        progressBar.removeLastSegmet();
                        list.removeLast();
                        setState(() {});
                      }),
              right: size.width / 5,
              bottom: 50,
            ),
            Positioned(
              child: progressBar.getTime() > 5 && !isRecordingStarted
                  ? IconButton(
                      onPressed: () {

                        if(isRecordingStarted)
                          return;
                        //controller?.dispose();

                        //_timer.cancel();
                        //_timer=null;
                        if(MediaInfo.isProcessing)
                          {
                            Functions.showToast("Please wait. Processing last clip", context);
                            return;
                          }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReviewScreen2(
                                    listVideo: list,
                                    audioPath: audioPath,
                                    audioId: audioId,
                                    duration: progressBar.getTime(),
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



         !isRecordingStarted && recordTill==null ?   Positioned(
              child: Column(
                children: [
                     GestureDetector(
                      child:Padding(
                        child:  Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.only(left: 5,right: 0,bottom: 4,top: 4),

                      ),
                      onTap: () {
                        if (isFront) {
                          onNewCameraSelected(cameras[0]);
                        } else {
                          onNewCameraSelected(cameras[1]);
                        }
                      }),
                  Container(
                    height: 16,
                  ),
                  GestureDetector(
                      child:Padding(
                        child: AnimatedContainer(
                          padding: EdgeInsets.all(9),

                          //height: isAligned ? 50:30,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                              color: recordingSpeed!=1 ? Colors.black12 : Colors.transparent
                          ),
                          duration: Duration(milliseconds: 300),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timelapse,
                                color:   Colors.white,
                                //size: isAligned?25:22,
                              ),


                            ],
                          ),
                        ),
                        padding: EdgeInsets.only(left: 4),

                      ),
                      onTap: () {

                        if(showRecordingSpeed)
                          {
                            recordingSpeed = 1;
                          }
                        showRecordingSpeed = !showRecordingSpeed;
                        setState(() {

                        });
                      }),
                  Container(
                    height: 16,
                  ),
                 // _flashButton(),
                  Container(
                    height: _hasFlashlight?18:0,
                  ),
                  GestureDetector(
                      child: Padding(
                        padding: EdgeInsets.only(left: 5,right: 0,bottom: 4,top: 4),
                        child: Icon(
                          Icons.timer,
                          color: Colors.white,
                        ),
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

                                min: progressBar.getTime().toInt() + 1,//30-_start.toInt()+1,
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
                    height: 16,
                  ),
                list.length>0?  GestureDetector(

                      child:Padding(
                        child: AnimatedContainer(
                          padding: EdgeInsets.all(9),

                          //height: isAligned ? 50:30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                                color: isAligned ? Colors.black12 : Colors.transparent
                          ),
                           duration: Duration(milliseconds: 300),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.phone_android,
                                color:   Colors.white,
                                //size: isAligned?25:22,
                               ),


                            ],
                          ),
                        ),
                        padding: EdgeInsets.only(left:6),

                      ),
                      onTap: () async{


                        int res = 1;
                        if(!isAligned)
                          {
                            isAligned = !isAligned;

                            setState(() {

                            });
                            res = await getLastFrame();

                           if(res == 0)
                             {

                               setState(() {

                               });
                             }
                           else{
                             isAligned = false;


                             setState(() {

                             });
                             if(res == 1)
                             Functions.showToast("Some error occured, try again.", context);
                             if(res == 2)
                             Functions.showToast("Please wait", context);
                             if(res == 3)
                             Functions.showToast("Please wait. Processing last clip", context);
                           }
                          }else{
                          align = null;
                          isAligned = !isAligned;
                          setState(() {

                          });
                        }


                      }):Container(),
                  Container(
                    height: 14,
                  ),

                ],
              ),
              top: 100,
              right: 10,
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

            !showRecordingSpeed ? Container()      :Positioned(

    bottom: 160,
    left: size.width/2 - 125,
    child: Container(
  height: 53,
  width: 250,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(width: 5,),
      GestureDetector(
        child: Padding(
          padding: EdgeInsets.only(top: 5,bottom: 5),

          child: Container(

            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: recordingSpeed == 0.3 ? Colors.white38 : Colors.transparent,

            ),
            width: 42,
            child: Center(
              child: Text("0.3"),
            ),
          ),
        ),
        onTap: (){
          recordingSpeed = 0.3;
          setState(() {

          });
        },
      ),
      GestureDetector(
        child: Padding(
          padding: EdgeInsets.only(top: 5,bottom: 5),

          child: Container(

            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: recordingSpeed == 0.5 ? Colors.white38 : Colors.transparent,

            ),
            width: 42,
            child: Center(
              child: Text("0.5"),
            ),
          ),
        ),
        onTap: (){
          recordingSpeed = 0.5;
          setState(() {

          });
        },
      ),
      GestureDetector(
        child: Padding(
          padding: EdgeInsets.only(top: 5,bottom: 5),

          child: Container(

            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: recordingSpeed == 1 ? Colors.white38 : Colors.transparent,

            ),
            width: 42,
            child: Center(
              child: Text("1"),
            ),
          ),
        ),
        onTap: (){
          recordingSpeed = 1;
          setState(() {

          });
        },
      ),
      GestureDetector(
        child: Padding(
          padding: EdgeInsets.only(top: 5,bottom: 5),

          child: Container(

            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: recordingSpeed == 2? Colors.white38 : Colors.transparent,

            ),
            width: 42,
            child: Center(
              child: Text("2"),
            ),
          ),
        ),
        onTap: (){
          recordingSpeed = 2;
          setState(() {

          });
        },
      ),
      GestureDetector(
        child: Padding(
          padding: EdgeInsets.only(top: 5,bottom: 5),

          child: Container(

            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: recordingSpeed == 3 ? Colors.white38 : Colors.transparent,

            ),
            width: 42,
            child: Center(
              child: Text("3"),
            ),
          ),
        ),
        onTap: (){
          recordingSpeed = 3;
          setState(() {

          });
        },
      ),

      Container(width: 5,),

    ],
  ),

  decoration: BoxDecoration(
    color: Colors.black54,
    borderRadius: BorderRadius.circular(10)
  ),
)),



            Builder(builder: (context){
              if(progressBar.size.height == 10)
                {
                  progressBar = ProgressBar(size);
                }

              return progressBar;
            },)
            ///ProgressBar(size),

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

  Future _turnFlash() async {


    _isOn ?                     TorchCompat.turnOff()
    :                     TorchCompat.turnOn();

    var f = await Lamp.hasLamp;
    setState((){
      _hasFlashlight = f;
      _isOn = !_isOn;
    });
  }



  bool isAligned = false;

  bool isAligning  = false;
  File align;
  Future<int> getLastFrame() async{

    if(MediaInfo.isProcessing)
      return 3;

    if(isAligning) return 2;

    isAligned = true;

    String lf = directory.path + "/" + DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";
    String c = "-sseof -1 -i ${list[list.length-1].filepath} -update 1 -q:v 1 $lf";
    FlutterFFmpeg fFmpeg = FlutterFFmpeg();
    int r = await fFmpeg.execute(c);

    if(r == 0)
      {
        align =  File(lf);
        isAligning = false;

        return 0;
      }else{
      align = null;
      isAligning = false;

      return 1;
    }

  }




  bool showRecordingSpeed = false;
  double recordingSpeed = 1;

  FlashMode flashMode = FlashMode.off;

  Widget _flashButton() {
    IconData iconData = Icons.flash_off;
    Color color = Colors.black;
    if (flashMode == FlashMode.alwaysFlash) {
      iconData = Icons.flash_on;
      color = Colors.blue;
    } else if (flashMode == FlashMode.autoFlash) {
      iconData = Icons.flash_auto;
      color = Colors.red;
    }
    return GestureDetector(
      child: Icon(iconData, color: Colors.white,),
       onTap: controller != null && controller.value.isInitialized
          ? _onFlashButtonPressed
          : null,
    );
  }

  /// Toggle Flash
  Future<void> _onFlashButtonPressed() async {
    bool hasFlash = false;
    if (flashMode == FlashMode.off || flashMode == FlashMode.torch) {
      // Turn on the flash for capture
      flashMode = FlashMode.alwaysFlash;
    } else if (flashMode == FlashMode.alwaysFlash) {
      // Turn on the flash for capture if needed
      flashMode = FlashMode.autoFlash;
    } else {
      // Turn off the flash
      flashMode = FlashMode.off;
    }
    // Apply the new mode
    await controller.setFlashMode(flashMode);

    // Change UI State
    setState(() {});
  }




  Future<void> getCamera() async {
    cameras = await availableCameras();

    print(cameras[0].sensorOrientation);
    print(cameras[0].lensDirection);
     controller = CameraController(cameras[0], ResolutionPreset.high);


    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        onNewCameraSelected(controller.description);
      }
    }
  }
  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
     );

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
       }
    });

    try {

      if(controller!=null)
        {
          await controller.initialize();
          isFront = !isFront;
          setState(() {

          });
        }
    } on CameraException catch (e) {
     }

    debugPrint(controller.description.sensorOrientation.toString());

    if (mounted) {
      setState(() {});
    }
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

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


  playPauseVideo() async{

    if(progressBar.isCompleted() && !isRecordingStarted)
      {
        return;
      }
    if (!isRecordingStarted) {


      if(isAligned)
        {
          isAligned = false;
          setState(() {

          });
        }

      String fileName = "outputjune${DateTime.now().toIso8601String()}.mp4";

      File file = new File(directory.path + "/" + fileName);

      await controller.startVideoRecording(file.path);

      try{

        controller.zoom(scale);

      }catch(e){

      }
      setState(() {

      });

      isRecordingStarted = !isRecordingStarted;
      progressBar.changeSpeed(!isRecordingStarted? 1 : recordingSpeed);
      progressBar.start();

      if(!Functions.isNullEmptyOrFalse(audioPath))    {
          player.play();
        }

      if (_timer == null)  {
        const oneSec = const Duration(milliseconds: 500);

        _timer = new Timer.periodic(
          oneSec,
              (Timer timer) {



                if ( progressBar.isCompleted()) {

              if(isRecordingStarted)
                {

                   playPauseVideo();
                  setState(() {});
                }
            } else {

              if(recordTill!=null )
              {
                if(isRecordingStarted)
                {
                  print(progressBar.getTime());
                  print(recordTill * recordingSpeed);
                  print(recordTill);
                  if(recordTill<=(progressBar.getTime()))
                  {
                    recordTill = null;
                    playPauseVideo();
                  }

                }
              }


              if (isRecordingStarted) {
                _timer.tick;
                 _progress = progressBar.getTime();
                 if (_progress > 4 && _progress < 6) {
                  setState(() {});
                }
                 if(_progress ==1)
                   {
                     setState(() {

                     });
                   }
              }
            }
              },
        );
       }

      list.add(MediaInfo(-1, file.path, isFront?1 :0, showRecordingSpeed ?  recordingSpeed == null ? 1 : recordingSpeed : 1));
    }

    else  {





      if(!Functions.isNullEmptyOrFalse(audioPath))
      {
        player.pause();
      }

      progressBar.pause();

     await controller.stopVideoRecording();


      for (int i = 0; i < list.length; i++) {

         if (list[i].duration == -1) {

           list[i].duration = 30.0 - progressBar.getTime()  ;
           if (list[i].camera == 1) {
             list[i].rotate(directory,
                 cameras.length > 1 ? cameras[1].sensorOrientation : cameras[0]
                     .sensorOrientation, cameras[0].sensorOrientation);
           }
           else{
             list[i].rotate(directory, 0, cameras[0].sensorOrientation);
           }
         }
      }
     isRecordingStarted = !isRecordingStarted;

      setState(() {});

      try{
        controller.zoom(scale);

      }catch(e){

      }
    }
  }

  void _showCameraException(CameraException e) {
    print('Error: ${e.code}\nError Message: ${e.description}');
   }


}
