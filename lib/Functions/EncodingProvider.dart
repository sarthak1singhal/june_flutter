import 'dart:io';

 import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_ffmpeg/media_information.dart';

removeExtension(String path) {
  final str = path.substring(0, path.length - 4);
  return str;
}

class EncodingProvider {
  static final FlutterFFmpeg _encoder = FlutterFFmpeg();

  static final FlutterFFprobe _probe = FlutterFFprobe();
  static final FlutterFFmpegConfig _config = FlutterFFmpegConfig();





  static Future<String> getThumb(videoPath, width, height) async {
     assert(File(videoPath).existsSync());


     final String outPath = '$videoPath.jpg';
     final arguments =
         '-y -i $videoPath -vframes 1 -an -s ${width}x${height} -ss 1 $outPath';

     final int rc = await _encoder.execute(arguments);
     assert(rc == 0);
     assert(File(outPath).existsSync());

     return outPath;
   }



   static Future<MediaInformation> getMediaInformation(String path) async {
     return await _probe.getMediaInformation(path);
   }

   static double getAspectRatio(Map<dynamic, dynamic> info) {
     final int width = info['streams'][0]['width'];
     final int height = info['streams'][0]['height'];
     final double aspect = height / width;
     return aspect;
   }

   static int getDuration(Map<dynamic, dynamic> info) {
     return info['duration'];
   }








  static Future<String> encodeHLS(String videoPath, String outDirPath, String fileName) async {
    assert(File(videoPath).existsSync());








    String arguments = "-y -i $videoPath -preset veryfast -g 35 -sc_threshold 0 "+
    "-map 0:0 -map 0:1 -map 0:0 -map 0:1 -s:v:0 360x640 -c:v:0 libx264 -b:v:0 365k "+
        "-s:v:1 670x1200 -c:v:1 libx264 -b:v:1 2000k -c:a copy -var_stream_map \"v:0,a:0 v:1,a:1\" "+
    "-master_pl_name master.m3u8 -f hls -hls_time 5 -hls_list_size 0 "+
        "-hls_segment_filename \"$outDirPath/%v_$fileName%d.ts\" $outDirPath/%v_$fileName.m3u8";










/*

    String arguments = "-i $videoPath -c:v libx264 -crf 35 -preset slow -g 25 -sc_threshold 0"+
    " -c:a aac -b:a 128k -ac 1 -f hls -hls_time 6 -hls_playlist_type event $outDirPath/$fileName.m3u8";
*/







/*
     final arguments =
        '-y -i $videoPath '+
            '-preset vryfast -g 30 -sc_threshold 0 '+
            '-map 0:0 -map 0:1 -map 0:0 -map 0:1 '+
            '-c:0 libx264 -b:0 2000k '+
            '-c:1 libx264 -b:1 365k '+
            '-c:a copy '+
            '-var_stream_map "v:0,a:0 v:1,a:1" '+
            '-master_pl_name master.m3u8 '+
            '-f hls -hls_time 6 -hls_list_size 0 '+
            '-hls_segment_filename "$outDirPath/%v_${fileName}_%d.ts" '+
            '$outDirPath/%v_${fileName}.m3u8';
*/

    final int rc = await _encoder.execute(arguments);
    assert(rc== 0);

    return outDirPath;
  }




  static void enableStatisticsCallback(Function cb) {
    return _config.enableStatisticsCallback(cb);
  }

  static Future<void> cancel() async {
    await _encoder.cancel();
  }




}