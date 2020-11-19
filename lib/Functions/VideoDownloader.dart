import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:gallery_saver/gallery_saver.dart';
 import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qvid/Functions/Toast.dart';
import 'package:tapioca/tapioca.dart';

import 'functions.dart';

class MyVideoDownloader{



  static List<String> inQueue = [];

  static downloadAndSaveHls(String url, String id, String userId, BuildContext context) async {
    toast("Video downloading");

    inQueue.add(id);

    var status = await Permission.storage.status;
      print(status);
    if (status.isUndetermined) {

      status = await Permission.storage.request(); // We didn't ask for permission yet.
    }

    if(status.isRestricted)
      status = await Permission.storage.request(); // We didn't ask for permission yet.

    if (status.isPermanentlyDenied) {

       // The OS restricts access, for example because of parental controls.
    }


    if (await Permission.storage.request().isGranted) {


      File file;
      final value =    await getApplicationDocumentsDirectory();



      print(value.path);

      String fileName =
          "vid${DateTime.now().millisecondsSinceEpoch.toString()}.mp4";
      String finalPath =
          "june_${DateTime.now().millisecondsSinceEpoch.toString()}.mp4";


      file = new File(value.path + "/" + fileName);
      finalPath = value.path + "/" +finalPath;


      print(value.path);
      print(file.path);

      FlutterFFmpeg _flutterFFmpeg =   FlutterFFmpeg();
      String c = "-i "+url+" -codec copy ${file.path}";
      int r = await _flutterFFmpeg.execute(c);

      print(r);
      final imageBitmap =
      (await rootBundle.load("assets/others/watermarkw.png"))
          .buffer
          .asUint8List();
      final tapiocaBalls = [

         TapiocaBall.imageOverlay(imageBitmap, 20, 5),
        TapiocaBall.textOverlay(
            "@$userId", 20, 93, 36, Color(0xffffffff)),
      ];


      final cup = Cup(Content(file.path), tapiocaBalls);
      cup.suckUp(finalPath).then((_) async {
        print("finished");

        GallerySaver.saveVideo(finalPath, albumName: "Junes").then((bool success) {
          inQueue.removeAt(0);
          toast("Video Saved");
          file.delete();
          File(finalPath).delete();
        });


      });




    }






  }

}





class MyAudioDownloader{




    Future<String> downloadAndSaveHls(String url,  _scaffoldKey) async {


    var status = await Permission.storage.status;
    print(status);
    if (status.isUndetermined) {

      status = await Permission.storage.request(); // We didn't ask for permission yet.
    }

    if(status.isRestricted)
      status = await Permission.storage.request(); // We didn't ask for permission yet.

    if (status.isPermanentlyDenied) {

      // The OS restricts access, for example because of parental controls.
    }


    if (await Permission.storage.request().isGranted) {


      File file;
      final value =    await getApplicationDocumentsDirectory();



      print(value.path);

      String fileName =
          "vid${DateTime.now().millisecondsSinceEpoch.toString()}.mp3";


      file = new File(value.path + "/" + fileName);



      print(value.path);
      print(file.path);

      FlutterFFmpeg _flutterFFmpeg =   FlutterFFmpeg();
      String c = "-i "+url+" -codec copy ${file.path}";

      int r = await _flutterFFmpeg.execute(c);


      if(r==1) {
        Functions.showSnackBar(_scaffoldKey, "Some error occured");
        return null;
      }
      return file.path;

    }






  }

}
