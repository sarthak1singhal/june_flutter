import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class MediaInfo {
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  double _duration;
  String _filepath;

  double speed;
  int camera;

  double get duration => _duration;

  set duration(double value) {
    _duration = value;
  }

  MediaInfo(this._duration, this._filepath, this.camera, this.speed);

  MediaInfo.rotate(double d, String f, int c, Directory directory, int degree,
      int mainCameraRotation) {
    this._duration = duration;
    this._filepath = f;
    this.camera = c;

    rotate(directory, degree, mainCameraRotation);
  }

  static bool isProcessing = false;

  rotate(Directory directory, int degree, int mainCameraRotation) async {
    isProcessing = true;
    if (mainCameraRotation == 0 && degree == 0) return;
    print(isProcessing);
    print("PROCESSINGGG");
    print(camera);
    File file = File(_filepath);

    int trans = 0;
    if (degree == 0 && mainCameraRotation == 90) {
      trans = 2;
    }
    if (degree == 270 && mainCameraRotation == 90) {
      trans = 2;
    }

    String newPath = directory.path +
        "/" +
        DateTime.now().millisecondsSinceEpoch.toString() +
        ".mp4";
    String newPath2 = directory.path +
        "/w" +
        DateTime.now().millisecondsSinceEpoch.toString() +
        ".mp4";
    if (camera == 1) {

      if(speed !=1)
        {
          if(speed <0)
            {
              String transpose =
                  "-i $_filepath -vf \"transpose=$trans\" -vcodec libx264 -preset veryfast -acodec copy $newPath";
              await _flutterFFmpeg.execute(transpose);
              await speedUpDown(newPath, newPath2, speed);

              this._filepath = newPath2;
              file.delete();
              File(newPath).delete();
            }
          else{

            await speedUpDown(_filepath, newPath, speed);
            String transpose =
                "-i $newPath -vf \"transpose=$trans\" -vcodec libx264 -preset veryfast -acodec copy $newPath2";
            await _flutterFFmpeg.execute(transpose);

            this._filepath = newPath2;
            file.delete();
            File(newPath).delete();
          }
        }
      else{
        String transpose =
            "-i $_filepath -vf \"transpose=$trans\" -vcodec libx264 -preset veryfast -acodec copy $newPath";
        this._filepath = newPath;
        await _flutterFFmpeg.execute(transpose);
        file.delete();
      }






    }
    if (camera == 0) {
        if (speed != 1) {


          String transpose = "-i $_filepath -c copy -metadata:s:v:0 rotate=0 $newPath";
          await _flutterFFmpeg.execute(transpose);

              await speedUpDown(newPath, newPath2, speed);

        this._filepath = newPath2;


        file.delete();
        File(newPath).delete();
      }
        else{
          String transpose = "-i $_filepath -c copy -metadata:s:v:0 rotate=0 $newPath";

           await _flutterFFmpeg.execute(transpose);

          this._filepath = newPath;
          file.delete();


        }
    }

    if (camera == 3) {
      String transpose =
          "-i $_filepath -vf \"transpose=$trans\" -vcodec libx264 -preset veryfast -acodec copy $newPath";
      this._filepath = newPath;
      await _flutterFFmpeg.execute(transpose);
      file.delete();
    }

    print("file deleted");
    isProcessing = false;
    print(isProcessing);
    print("ProCESSED");
  }

  String get filepath => _filepath;

  set filepath(String value) {
    _filepath = value;
  }

  Future<int> speedUpDown(String input, String output, double speed) async {
    //String newPath = directory.path + "/" + DateTime.now().millisecondsSinceEpoch.toString()+".mp4";
    String command = "";
    if (speed == 0.5)
      command =
          "-i $input -filter_complex \"[0:v]setpts=2.0*PTS[v];[0:a]atempo=0.5[a]\" -map \"[v]\" -map \"[a]\" -strict experimental -vcodec libx264 -preset ultrafast -b:a 128k $output";
    else if (speed == 3) {
      command =
          "-i $input -filter_complex \"[0:v]setpts=0.33*PTS[v];[0:a]atempo=2.0,atempo=1.5[a]\" -map \"[v]\" -map \"[a]\" -strict experimental -vcodec libx264 -preset ultrafast -b:a 128k $output";
    } else if (speed == 2) {
      command =
          "-i $input -filter_complex \"[0:v]setpts=0.5*PTS[v];[0:a]atempo=2.0[a]\" -map \"[v]\" -map \"[a]\" -strict experimental -vcodec libx264 -preset ultrafast -b:a 128k $output";
    } else if (speed == 0.3) {
      command =
          "-i $input -filter_complex \"[0:v]setpts=3.0*PTS[v];[0:a]atempo=0.5,atempo=0.6[a]\" -map \"[v]\" -map \"[a]\" -strict experimental -vcodec libx264 -preset ultrafast -b:a 128k $output";
    }
    return await _flutterFFmpeg.execute(command);
  }



}
