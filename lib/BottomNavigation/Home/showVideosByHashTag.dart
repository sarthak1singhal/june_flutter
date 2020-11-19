import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qvid/BottomNavigation/AddVideo/add_video2.dart';
import 'package:qvid/BottomNavigation/AddVideo/post_info.dart';
import 'package:qvid/BottomNavigation/AddVideo/sounds.dart';
import 'package:qvid/Components/newScreenGrid.dart';
import 'package:qvid/Components/tab_grid.dart';
import 'package:qvid/Functions/LocalColors.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Functions/VideoDownloader.dart';
import 'package:qvid/Functions/functions.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:qvid/Model/Videos.dart';
import 'package:qvid/Theme/colors.dart';


class VideosByHashtag extends StatefulWidget {
  final String title;
  List<Videos> list;
  String hashtag;

  VideosByHashtag({@required this.title,@required this.list,@required this.hashtag});

  @override
  _MyHomePageState createState() => _MyHomePageState(title,list, hashtag);
}

class _MyHomePageState extends State<VideosByHashtag> {
  final String title;
  List<Videos> list;

  final String hashtag;
   Widget imageWidget = Container();
  String thumbUrl;
  bool isLoading = false;
  bool isError = false;
String errorMessage = "";

int videoCount;
  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, //top bar color
      statusBarIconBrightness: Brightness.light, //top bar icons

    ));



    getD();

  }

  Color color;

  getD() async{
  color = await getData();

    setState(() {

    });



  }
  PaletteGenerator paletteGenerator;

  String hashtagImage;
  bool isExistMore = true;

  int offset = 0;

  Future<Color> getData() async {

    if(!isExistMore)
    {
      return color;
    }
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });




      try {


        var res = await Functions.unsignPostReq(Variables.showVideoByHashtag  , jsonEncode({
          "hashtag": widget.hashtag.replaceAll("#", ''),
           "offset" : offset,
          "limit" : 21,
          "fb_id" : Functions.isNullEmptyOrFalse(Variables.fb_id) ?"" : Variables.fb_id

        }));


        var data = jsonDecode(res.body);

        if(!data["isError"])
        {

          int len = data["msg"].length;
          offset = offset + 21;
          if(len<21)
          {
            isExistMore = false;
          }


            list = Functions.parseVideoList(data["msg"], context);

        Random  rnd = new Random();
        int  r = list.length <2  ? 0 : 0 + rnd.nextInt(list.length-1 );
        if( data["videoCount"]!=null)
        videoCount  = data["videoCount"];
        else
          videoCount = 0;
        hashtagImage = list[r].thumb_url;
        if(!Functions.isNullEmptyOrFalse(data["hashtagDetails"])){
          if(!Functions.isNullEmptyOrFalse(data["section_image"])){
              hashtagImage = data["section_image"];
          }
        }

        }else{
          isError = true;
          errorMessage = "Some error occured";
        }
        if (_dir == null) {
          _dir = (await getApplicationDocumentsDirectory()).path;
        }

       File f=   await _downloadFile(hashtagImage, "hashtagImg", _dir);

        imageWidget = Container(
          height: 100,
          width: 100,
           child: Image(
             image: FileImage(f),
             fit: BoxFit.cover,

           ),
        );
        Size size = Size(300, 300);
        Rect     region = Offset.zero & size;


        print(hashtagImage);

        paletteGenerator = await PaletteGenerator.fromImageProvider(
          FileImage(f),
          size:size,
          maximumColorCount: 20,
        );
        print(hashtagImage);
           isLoading  = false;
         if(paletteGenerator == null)
          {
            return bottomNavColor;
          }
        if(paletteGenerator.mutedColor == null)
          {
            return bottomNavColor;
          }

        return paletteGenerator.mutedColor.color;


      } catch (e) {
        isLoading  = false;
        isError = true;
        errorMessage = Variables.connErrorMessage;
        setState(() {

        });
        print(e);

      }





      setState(() {
        isLoading = false;
      });

      if(color == null) color  = bottomNavColor;
      return color;

    }
  }

  String _dir;
  Future<File> _downloadFile(String url, String filename, String dir) async {
    var req = await http.Client().get(Uri.parse(url));
    var file = File('$dir/$filename');
    return file.writeAsBytes(req.bodyBytes);
  }





  _MyHomePageState(this.title, this.list, this.hashtag);
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  bool isAudioPlaying = false;
  @override
  Widget build(BuildContext context) {
    return     Scaffold(
        backgroundColor: bottomNavColor,
        key: _scaffoldkey,
        body: isLoading? Functions.showLoaderSmall():  isError ? Functions.showError(errorMessage):  Stack(
            children: [

              Container(
                height: MediaQuery.of(context).size.height*0.5,


                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0,0.9,1],
                        colors: [
                          color == null ? Colors.transparent: color,

                          gradientBlack,
                          bottomNavColor,

                        ]
                    )
                ),
              )
              ,Column(

                children: [

                  Container(
                      padding: EdgeInsets.only(top: 33, left: 5, bottom: 10),                    width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: Row(
                          children: [

                            Functions.backButtonMain(context),
                            Text(
                              "Hashtag", style: TextStyle(
                                fontSize: 20, fontFamily: Variables.fontName,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.9),
                                shadows: [
                                  Shadow(
                                      color:  Colors.black38,
                                      blurRadius: 2,

                                      offset: Offset(0, 1))
                                ]

                            ),
                            )

                          ],
                        ),
                      )

                  ),

                  Container(

                    height: 130, width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(height: 100,width: 100,
                              decoration: BoxDecoration(

                                boxShadow:  [  BoxShadow(
                                    color:  Colors.black38,
                                    blurRadius: 7,

                                    offset: Offset(0, 1))    ]

                                ,
                                borderRadius: BorderRadius.all(Radius.circular(6)),

                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(6)),

                                    child: imageWidget,
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: GestureDetector(
                                      child:                               Icon(
                                        isAudioPlaying?Icons.pause:
                                        Icons.play_arrow, color: Colors.white38, size: 50,)
                                      ,
                                      onTap: (){



                                        setState(() {

                                        });
                                      },
                                    ),
                                  )
                                ],
                              )
                          ),
                          Container(width: 14,),
                          Container(
                            width: 200,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(height: 7,),
                                Text(widget.hashtag, style: TextStyle(
                                    shadows: [
                                      Shadow(
                                          color:  Colors.black38,
                                          blurRadius: 2,


                                          offset: Offset(0, 1))
                                    ],
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold

                                ),),
                                Container(height:9,),

                                Text(videoCount == 1 ? "$videoCount video":"$videoCount videos", style: TextStyle(
                                    shadows: [
                                      Shadow(
                                          color:  Colors.black38,
                                          blurRadius: 2,
                                          offset: Offset(0, 1))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30,),
                  Expanded(
                    child: NewScreenGrid(3, _scaffoldkey,soundId: null,hashtag: widget.hashtag, list: list,errorHeight: MediaQuery.of(context).size.height/2,),

                  )

                ],

              ),





            ]
        )
    ) ;
  }


  bool tapDown = false;
  @override
  void dispose() {
    super.dispose();
    }




}