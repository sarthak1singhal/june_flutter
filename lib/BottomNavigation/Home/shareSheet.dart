import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qvid/BottomNavigation/MyProfile/edit_profile.dart';
import 'package:qvid/Components/entry_field.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Functions/VideoDownloader.dart';
import 'package:qvid/Model/Videos.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:qvid/Locale/locale.dart';

import 'dynamicBottomSheet.dart';



class ShareSheet extends StatefulWidget {

  Videos video;
  BuildContext context;
   ShareSheet(this.context, this.video, );
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ShareSheet> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var locale;
  bool showDelete = false;


    @override
  void initState() {
    super.initState();
    locale = AppLocalizations.of(widget.context);

    if(Variables.fb_id!=null)
      {
        if(widget.video!=null)
          {

            if(Variables.fb_id == widget.video.fb_id )
            {
               showDelete = true;
            }
          }
      }

  }





  @override
  Widget build(BuildContext context) {
    return  Container(
        decoration: BoxDecoration(
            color: Colors.transparent,
            boxShadow:  [  BoxShadow(
                color:  Colors.black.withOpacity(0.14),
                blurRadius: 14,

                offset: Offset(0, -6))    ]
        ),

        child: ClipRRect(

            borderRadius: BorderRadius.vertical(top: Radius.circular(35.0)),
            child: new BackdropFilter(
              filter: new ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
              child:Stack(
                children: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.min,

                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(height: 10,),
                      //Container(height: 2, width: 40, color: Colors.white,),

                      Divider(color: Colors.white, endIndent: 170,indent: 170,),
                       Container(height: 21,),
                     /* Padding(
                        padding: EdgeInsets.only(left: 20,right: 20, bottom: 20),
                        child: Text(
                          "Share",
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(color: Colors.white60, fontSize:MediaQuery.of(context).viewInsets.bottom>10? 24:21),
                        ),
                      ),*/
                      Padding(padding: EdgeInsets.only(left: 20, right: 20, bottom: 50), child:  Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          showDelete?   BottomSheetButton(
                            title: "Delete Video",
                            onTap: (){

                              Navigator.pop(context, "delete");

                            },


                          ): BottomSheetButton(
                            onTap: ()async{


                                  Navigator.pop(context, "report");

                            },
                            title: "Report",

                          ),


                          Container(height: 17,),



                          BottomSheetButton(
                            title: "Copy Link",
                            onTap: (){

                              Navigator.pop(context);
                              widget.video.copyToClipboard();
                            },
                          )

                         ,
                          Container(height: 17,),


                          BottomSheetButton(
                            onTap: MyVideoDownloader.inQueue.contains(widget.video.id.toString()) ? null :(){


                              MyVideoDownloader.downloadAndSaveHls(widget.video.vid_url, widget.video.id.toString(), widget.video.username, widget.context);


                              setState(() {

                              });

                              Navigator.pop(context);


                            },
                              titleWidget: MyVideoDownloader.inQueue.contains(widget.video.id.toString()) ?
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:
                                [
                                  Text("Downloading", style: TextStyle(inherit: false),),
                                  Container(width: 20,),
                                  Functions.showLoaderSmall()
                                ],)
                                  :Text("Download", style: TextStyle(inherit: false),),
                          )




                        ],
                      ),)

                    ],
                  ),
                 ],
              ),))
    );
  }




 }
