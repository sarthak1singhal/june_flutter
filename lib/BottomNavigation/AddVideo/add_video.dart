import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flashlight/flashlight.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Routes/routes.dart';
import 'package:qvid/Theme/colors.dart';
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
  String fileName="";


  @override
  void initState() {
    super.initState();

    getCamera();
initFlashlight();


  }

  @override
  Widget build(BuildContext context) {
    double ht = MediaQuery.of(context).size.height;
    double wt = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          overflow: Overflow.visible,
          children: <Widget>[

          controller==null?Container():!controller.value.isInitialized?Container():CameraPreview(controller),
            IconButton(
              icon: Icon(
                Icons.close,
                color: secondaryColor,
              ),
              onPressed: () => Navigator.pop(context),
            ),
             Text(fileName),

             Align(
               child: Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Row(
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
                        print(result);

                    }
                    ),
                    GestureDetector(
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: videoCall,
                        child: Icon(
                          Icons.fiber_manual_record,
                          color: secondaryColor,
                          size: 30,
                        ),
                      ),
                      onTap: () => Navigator.pushNamed(
                          context, PageRoutes.addVideoFilterPage),
                    ),
                    GestureDetector(
                      child: Icon(
                        Icons.perm_media,
                        color: secondaryColor,
                      ),

                      onTap: () async{

                        FilePickerResult result = await FilePicker.platform.pickFiles(
                          type: FileType.video,
                        );
                        print(result);


                      }
                    ),

                  ],
            ),
               ),
               alignment: Alignment.bottomCenter,
             ),
            Align(child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
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
            ),alignment: Alignment.topRight,)
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
}
