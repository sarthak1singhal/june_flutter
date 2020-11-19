import 'dart:ui';

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

import 'package:qvid/Model/Videos.dart';
import 'package:qvid/Theme/colors.dart';


class VideosBySound extends StatefulWidget {
  final String title;
  List<Videos> list;
  String soundId;
  bool isOriginalAud ;

  VideosBySound({@required this.title,@required this.list,@required this.soundId, @required this.isOriginalAud});

  @override
  _MyHomePageState createState() => _MyHomePageState(title,list, soundId);
}

class _MyHomePageState extends State<VideosBySound> {
  final String title;
  List<Videos> list;

 final String soundId;
  String soundUrl ;
  var player = AudioPlayer();
  Widget imageWidget = Container();
  String thumbUrl;
  bool showPage = false;


  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, //top bar color
      statusBarIconBrightness: Brightness.light, //top bar icons

    ));
    if(list[0].sound == null)
      {
        soundUrl = list[0].vid_url;

      }else if(list[0].sound.streamPath == null)
        {
          soundUrl = list[0].vid_url;
        }
    else{
      soundUrl = list[0].sound.streamPath;
    }


    imageWidget = getThumbnailImage();
    setPlayer(soundUrl);

    getColors();


  }

  PaletteGenerator paletteGenerator;

  getColors() async{
    Size size = Size(300, 300);



    paletteGenerator = await PaletteGenerator.fromImageProvider(
      Functions.isNullEmptyOrFalse(thumbUrl) ? AssetImage(Variables.defaultAudioThumb):CachedNetworkImageProvider(thumbUrl),
      size:size,
       maximumColorCount: 20,
    );


    setState(() {
      showPage = true;
    });
  }
  setPlayer(String url) async{



    var duration = await player.setUrl(url);

    player.setLoopMode(LoopMode.all);



  }
  _MyHomePageState(this.title, this.list, this.soundId);
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  bool isAudioPlaying = false;
  @override
  Widget build(BuildContext context) {
    return     Scaffold(
      backgroundColor: bottomNavColor,
      key: _scaffoldkey,
        body: Stack(
            children: [

              Container(
                height: MediaQuery.of(context).size.height*0.5,


                decoration: BoxDecoration(
                   gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0,0.9,1],
                    colors: [
                      paletteGenerator == null ? Colors.transparent: paletteGenerator.mutedColor ==null ?Colors.blue.shade200: paletteGenerator.mutedColor.color,

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
                                "Audio", style: TextStyle(
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
                                        child:                               Container(
                                          clipBehavior: Clip.hardEdge,
                                          child: Icon(
                                            isAudioPlaying?Icons.pause:
                                            Icons.play_arrow, color: Colors.white54, size: 35,),
                                          width: 50,height: 50,
                                          decoration: BoxDecoration(
                                        //    color: Colors.black12,
                                             borderRadius: BorderRadius.all(Radius.circular(30))
                                          ),

                                        )
                                        ,
                                        onTap: (){

                                          isAudioPlaying ? player.pause() : player.play();

                                          isAudioPlaying = !isAudioPlaying;



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
                                  Text(title, style: TextStyle(
                                      shadows: [
                                        Shadow(
                                            color:  Colors.black38,
                                            blurRadius: 2,

                                            offset: Offset(0, 1))
                                      ]
                                  ),),

                                  Container(height:30,),
                                  //TODO: create a audio player here

                                 
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 30,),

                    Expanded(
                      child: NewScreenGrid(4, _scaffoldkey,soundId: soundId,hashtag: null, list: list,errorHeight: MediaQuery.of(context).size.height/2,),

                    )

                  ],

                ),


              Align(

                alignment: Alignment(0, 0.85),

                  //left: 0,
                  child: GestureDetector(
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 100),

                      
                       
                      //margin: EdgeInsets.only(bottom: tapDown ? 4 :10),
                      height:   tapDown ? 48: 50,
                      padding: EdgeInsets.only(left: tapDown ? 16: 18,right: tapDown ? 6 :8,top: 16,bottom: 16),
                      child: Row(

                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(extractingAudio? "Downloading":"Use this audio", style: TextStyle(color: Colors.white),),
                          Container(width: 10,),
                          extractingAudio ?  Container(
    height: 15,
    width: 15,
    child: CircularProgressIndicator(
    valueColor: new AlwaysStoppedAnimation<Color>(Colors.white38),
    strokeWidth: 2,
    ),
    ): Container(),
                          extractingAudio ? Container(width: 10): Container()

                        ],
                      ),
                      decoration: BoxDecoration(
                         color: tapDown ?  mainColor.withOpacity(0.88): mainColor,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          boxShadow:  [  BoxShadow(
                              color:  Colors.black.withOpacity(0.1),
                              blurRadius: 6.0,
                              offset: Offset(-1,1.75)
                          ),

                          ],
                        gradient: LinearGradient(
                          colors: [mainColor,Color.fromRGBO(106, 197, 241, 1)],
                          stops: [0,0.7],
                        ),
                      ),
                    )
                    ,
                    onTap: (){


                      fetchAudio(soundUrl, context);
                      setState(() {
                        tapDown = false;
                      });
                    },
                    onTapDown: (d){

                      setState(() {
                        tapDown  = true;
                      });
                    },
                    onTapCancel: (){
                      setState(() {
                        tapDown = false;
                      });


                    },

                  )
              ),
              showPage ? Container(height: 0,width: 0, ): Container(width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Functions.showLoaderSmall(),
                color: bottomNavColor,
              ),

            ]
        )
    ) ;
  }


  bool tapDown = false;
  @override
  void dispose() {
    super.dispose();
    player.dispose();
    _flutterFFmpeg.cancel();
  }

  getThumbnailImage(){

    bool showLocalImg  = false;
    if(list == null)
    {
      showLocalImg = true;
    }
    if(list.length==0)
    {
      showLocalImg = true;
    }
    else{
      if(list[0].sound == null)
      {
        bool _validURL = Uri.parse(list[0].profile_pic).isAbsolute;
        if(_validURL)
        {
          thumbUrl = list[0].profile_pic;
          return Container(
            width: 100,
            height: 100,
            child: Image.network(list[0].profile_pic,fit: BoxFit.cover),
          );
        }else{

          showLocalImg = true;
        }

      }else{

        if(Functions.isNullEmptyOrFalse(list[0].sound.thum) )
        {
          bool _validURL = Uri.parse(list[0].profile_pic).isAbsolute;
          if(_validURL)
          {
            thumbUrl = list[0].profile_pic;

            return Container(
              width: 100,
              height: 100,
              child: Image.network(list[0].profile_pic, fit: BoxFit.cover,),
            );
          }else{

            showLocalImg = true;
          }
        }else{

          bool _validURL = Uri.parse(list[0].sound.thum).isAbsolute;
          if(_validURL)
          {
            thumbUrl = list[0].sound.thum;

            return Container(
              width: 100,
              height: 100,
              child: Image.network(list[0].sound.thum, fit: BoxFit.cover,),
            );

          }else{
            showLocalImg = true;

          }
        }
      }

      return Container(
        width: 100,
        child: Image.asset(Variables.defaultAudioThumb),
        height: 100,
      );

    }



  }
  FlutterFFmpeg _flutterFFmpeg =   FlutterFFmpeg();


  bool extractingAudio = false;

  File file;
  File audioFile;
  fetchAudio(String url, BuildContext buildContext) async{

    if(extractingAudio)
      {
        return;
      }

    setState(() {
      extractingAudio = true;
    });
    List<String> l=[];

    String audio =
        "aud${DateTime.now().millisecondsSinceEpoch.toString()}.mp3";

    final value = await getApplicationDocumentsDirectory();
    audioFile = new File(value.path + "/" + audio);

    int result = 0;

    if(widget.isOriginalAud) {
      result = await extractAudFromVid(audio, url, buildContext);
         l.add(audioFile.path);
        l.add(title);
        l.add(soundId);



    }else{
      MyAudioDownloader download = MyAudioDownloader();
      String path = await download.downloadAndSaveHls( url,  _scaffoldkey);


      if(path!=null)
      {
        l.add(path);
        l.add(title);
        l.add(soundId);


      }
    }
    setState(() {
      extractingAudio = false;
    });

    if(player.playing)
      {
        player.pause();
        if(mounted)
        setState(() {

        });
      }
    if(result ==0)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  AddVideo2(l:l)),
    );



  }


  downloadAud() async{

  }


 Future<int> extractAudFromVid(String audio, String url, BuildContext buildContext) async{



    final value = await getApplicationDocumentsDirectory();
    audioFile = new File(value.path + "/" + audio);

    String fileName =
        "vid${DateTime.now().millisecondsSinceEpoch.toString()}.mp4";




    file = new File(value.path + "/" + fileName);



     print(file.path);

    String c = "-i "+url+" -codec copy ${file.path}";
    int r = await _flutterFFmpeg.execute(c);


    print(r);
    String extractAud  = "-i ${file.path} ${audioFile.path}";


    if(r==0)
    {

      int aud = await _flutterFFmpeg.execute(extractAud);

      if(file.existsSync())
        file.delete();

      if(aud==1) {
        Functions.showToast("Some error occured", buildContext);
        return 1;
      }
      return 0;


    }
    else{

      Functions.showToast("Some error occured", buildContext);
      return 1;
    }

  }

}