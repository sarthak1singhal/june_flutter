import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:qvid/Model/OverlayDeatils.dart';

class MergeImagesWithVideo{

  static bool isWorking = false;
  static FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  static String outputPath;

  static mergeImages(String videoPath, String outputPath, List<OverlayDetails> l) async
  {

    if(!isWorking) {
      outputPath = outputPath;
      isWorking = true;


      String command = "-i $videoPath -i ${l[0]
          .path} -filter_complex \"[0:v][1:v] overlay=0:0:enable='between(t,0,3)'[out]\" -map [out] -pix_fmt yuv420p -c:a copy $outputPath";


      String inputs = "-i $videoPath -i ${l[0].path} ";
      String last = "-filter_complex \"[0:v][1:v] overlay=0:0[v1]";

      String end = "\" -map [v${l.length}] -pix_fmt yuv420p -c:a copy $outputPath";

      if (l.length > 1)
      {
        for (int i = 1; i < l.length; i++) {
          inputs = inputs + "-i ${l[i].path} ";
          String start = l[i].start.toStringAsFixed(3);
          String end = l[i].end.toStringAsFixed(3);
          if (i == l.length - 1) {
            last = last + "[v${i.toString()}][${(i + 1).toString()}:v] overlay=0:0:enable='between(t,$start,$end)'[v${(i +1).toString()}]";
          } else if(i==1){
            last = last + ";[v${i.toString()}][${(i + 1).toString()}:v] overlay=0:0:enable='between(t,$start,$end)'[v${(i+1).toString()}];";

          }else{
            last = last + "[v${i.toString()}][${(i + 1).toString()}:v] overlay=0:0:enable='between(t,$start,$end)'[v${(i+1).toString()}];";
          }
        }
    }


      for(int i=0;i<l.length;i++)
        {
          print(l[i].path);
        }
 //     await GallerySaver.saveImage(l[0].path);
 //     await GallerySaver.saveImage(l[1].path);
 //     await GallerySaver.saveImage(l[2].path);
      String finalCommand = inputs+last+end;
      int r =await _flutterFFmpeg.execute(finalCommand);
      print(finalCommand);
        GallerySaver.saveVideo(outputPath).then((bool success) {
print(l.length);

      });
   //"-map \"[v3]\" -map 0:a  $outputPath";


        isWorking = false;
      }
  }

  static cancel(){
    _flutterFFmpeg.cancel();
  }
}