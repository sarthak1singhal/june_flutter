import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MyVideoDownloader{



  static List<String> inQueue = [];

  static downloadAndSaveHls(String url, String id) async {

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


      file = new File(value.path + "/" + fileName);



      print(value.path);
      print(file.path);

      FlutterFFmpeg _flutterFFmpeg =   FlutterFFmpeg();
      String c = "-i "+url+" -codec copy ${file.path}";
      int r = await _flutterFFmpeg.execute(c);

      print(r);

      GallerySaver.saveVideo(file.path).then((bool success) {

        inQueue.removeAt(0);

      });



    }






  }

}



