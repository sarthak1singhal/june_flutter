import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class MediaInfo{


  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  double _duration;
  String _filepath;

  int camera;
  double get duration => _duration;

  set duration(double value) {
    _duration = value;
  }

  MediaInfo(this._duration, this._filepath, this.camera);
  MediaInfo.rotate(double d,String f,int c){
   this._duration = duration;
   this._filepath = f;
   this.camera = c;



  }

  static bool isProcessing = false;

  rotate(Directory directory) async{
    isProcessing = true;
    print(isProcessing);
    print("PROCESSINGGG");
    File file = File(_filepath);

    String newPath = directory.path + "/" + DateTime.now().millisecondsSinceEpoch.toString()+".mp4";
    if(camera==1){
      String transpose = "-i ${_filepath} -c copy -metadata:s:v:0 rotate=180 -aspect 16:9 $newPath";
      this._filepath = newPath;
    await  _flutterFFmpeg.execute(transpose);
    }if(camera==0){
      String transpose = "-i $_filepath -c copy -metadata:s:v:0 rotate=270 -aspect 16:9 $newPath";
      this._filepath = newPath;
      await _flutterFFmpeg.execute(transpose);
    }
    file.deleteSync();
    print("file deleted");
    isProcessing = false;
    print(isProcessing);
    print("ProCESSED");
  }

  String get filepath => _filepath;

  set filepath(String value) {
    _filepath = value;
  }
}