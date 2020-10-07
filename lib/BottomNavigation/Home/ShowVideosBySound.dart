import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qvid/BottomNavigation/AddVideo/post_info.dart';
import 'package:qvid/BottomNavigation/AddVideo/sounds.dart';
import 'package:qvid/Components/newScreenGrid.dart';
import 'package:qvid/Components/tab_grid.dart';
import 'dart:io';

class VideosBySound extends StatelessWidget {
  final String title;
  final List list;

  VideosBySound({this.title, this.list});
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: _scaffoldkey,
      child: Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: Stack(
            children: [
              NewScreenGrid(4, _scaffoldkey,soundId: title,hashtag: null),

              Positioned(

                  bottom: 30,
                  left: MediaQuery.of(context).size.width/2-45,
                  child: GestureDetector(
                    child: Container(height: 80,width: 90,color: Colors.white70,)
                    ,
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GetSounds ()),
                      );
                     // fetchAudio();
                    },
                  )
              )
,
              Positioned(

                  top: 30,
                  left: MediaQuery.of(context).size.width/2-45,
                  child: GestureDetector(
                    child: Container(height: 80,width: 90,color: Colors.white70,)
                    ,
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PostInfo ()),
                      );
                     // fetchAudio();
                    },
                  )
              )
            ],
          ),
    ));
  }



  File file;
  File audioFile;
  fetchAudio() async{



    final value = await getApplicationDocumentsDirectory();
     String fileName =
        "vid${DateTime.now().millisecondsSinceEpoch.toString()}.mp4";

     String audio =
        "aud${DateTime.now().millisecondsSinceEpoch.toString()}.mp3";


    file = new File(value.path + "/" + fileName);

    audioFile = new File(value.path + "/" + audio);


    print(value.path);
    print(file.path);

    FlutterFFmpeg _flutterFFmpeg =   FlutterFFmpeg();
    String c = "-i "+list[0]+" -codec copy ${file.path}";
    int r = await _flutterFFmpeg.execute(c);


    print(r);
    String extractAud  = "-i ${file.path} ${audioFile.path}";

    if(r==0)
      {
        int aud = await _flutterFFmpeg.execute(extractAud);

        print(aud);

      }

  }


}
