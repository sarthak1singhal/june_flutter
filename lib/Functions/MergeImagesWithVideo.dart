import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:qvid/Model/OverlayDeatils.dart';

import 'Variables.dart';
import 'VideoUploader.dart';
import 'functions.dart';

class MergeImagesWithVideo{

  static bool isWorking = false;
  static FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  static String outputPath;
  static List<String> queue = [];

  static mergeImages(String videoPath, String op, List<OverlayDetails> l) async
  {


    if(!isWorking) {
      outputPath = op;
      isWorking = true;


       if(l.length==0)
        {


          outputPath = videoPath;
          isWorking = false;

           return;

        }

      queue.add(outputPath);

      String command = "-i $videoPath -i ${l[0]
          .path} -filter_complex \"[0:v][1:v] overlay=0:0:enable='between(t,0,3)'[out]\" -map [out] -pix_fmt yuv420p -c:a copy $outputPath";


      String inputs = "-i $videoPath -i ${l[0].path} ";
      String lstart = l[0].start.toStringAsFixed(3);
      String lend = l[0].end.toStringAsFixed(3);
      String last = "-filter_complex \"[0:v][1:v] overlay=0:0:enable='between(t,$lstart,$lend)'[v1]";

      String end = "\" -map [v${l.length}] -pix_fmt yuv420p -c:a copy $outputPath";

      if (l.length > 1)
      {
        for (int i = 1; i < l.length; i++) {
          inputs = inputs + "-i ${l[i].path} ";
          String start = l[i].start.toStringAsFixed(3);
          String end = l[i].end.toStringAsFixed(3);
          if(l.length == 2)
            {
              last = last + ";[v${i.toString()}][${(i + 1).toString()}:v] overlay=0:0:enable='between(t,$start,$end)'[v${(i+1).toString()}]";

              break;
            }
             if(i==1){
            last = last + ";[v${i.toString()}][${(i + 1).toString()}:v] overlay=0:0:enable='between(t,$start,$end)'[v${(i+1).toString()}];";

          }else if (i == l.length - 1) {
               last = last + "[v${i.toString()}][${(i + 1).toString()}:v] overlay=0:0:enable='between(t,$start,$end)'[v${(i +1).toString()}]";
             }

             else{
            last = last + "[v${i.toString()}][${(i + 1).toString()}:v] overlay=0:0:enable='between(t,$start,$end)'[v${(i+1).toString()}];";
          }
        }
      }


      for(int i=0;i<l.length;i++)
        {
          print(l[i].path);
        }

      String finalCommand = inputs+last+end;
      int r =await _flutterFFmpeg.execute(finalCommand);
      print(finalCommand);
        GallerySaver.saveVideo(outputPath).then((bool success) {
print(l.length);

      });
   //"-map \"[v3]\" -map 0:a  $outputPath";


        isWorking = false;
         if(queue.length>0)
          queue.removeAt(0);

    }
  }

  static cancel() {
    if (isWorking) {
      _flutterFFmpeg.cancel();
      isWorking = false;
    }
  }



  static uploadAfterProcessing() async{
    Timer countDownTimer;
    bool isLoading = false;

    double time = 0;
    if (countDownTimer == null) {
      countDownTimer= new Timer.periodic(
        Duration(milliseconds: 500),
            (Timer timer) {

          time = time+0.5;


          if(!isLoading) {
            if (!isWorking) {
              isLoading = true;

              uploadVideo();

              countDownTimer.cancel();
            }
          }

        },
      );
    }

  }




  static uploadVideo() async{
    Functions fx = Functions();

    var res = await fx.postReq(Variables.base_url + "getUploadUrl", jsonEncode({}), null);

    var body = jsonDecode(res.body);


    Map<String, String> headers = {
      "Content-Type": "application/octet-stream",
      'x-amz-acl': 'public'
    };



     String uploadBinaryURL = body["url"];
    VideoUploader.uploadVideo(
        video: File(outputPath),
        headers: headers,
        url: uploadBinaryURL,
        binary: true

    );
  }
}