import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:qvid/Components/continue_button.dart';
import 'package:qvid/Components/entry_field.dart';
import 'package:qvid/Components/post_thumb_list.dart';
import 'package:qvid/Functions/MergeImagesWithVideo.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Functions/VideoUploader.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:video_player/video_player.dart';

class PostInfo extends StatefulWidget {
  final String soundId;

  const PostInfo( this.soundId,{Key key}) : super(key: key);
  @override
  _PostInfoState createState() => _PostInfoState();
}

class _PostInfoState extends State<PostInfo> {
  var icon = Icons.check_box_outline_blank;
  bool isSwitched1 = false;
  bool isSwitched2 = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool isLoading = true;
  Timer countDownTimer;
  String videoPath;
  VideoPlayerController controller ;

  bool isGettingUrl = false;

  @override
  void initState() {
    super.initState();
    if (countDownTimer == null) {
       countDownTimer= new Timer.periodic(
        Duration(milliseconds: 500),
            (Timer timer) {



             if(controller==null)
               {
                 if(!MergeImagesWithVideo.isWorking) {
                   isLoading = false;
                   videoPath = MergeImagesWithVideo.outputPath;
                   print("VIDEOOOOOOPATHHHHHHHHHH   " +  videoPath);
                   if (videoPath != null) {
                     controller = VideoPlayerController.file(File(videoPath));
                     controller.initialize();
                     countDownTimer.cancel();
                     controller.play();
                     setState(() {

                     });
                   }
                 }
               }


        },
      );
    }
  }


  @override
  void dispose() {
    super.dispose();
    if(countDownTimer!=null)
      {
        if(countDownTimer.isActive)
        countDownTimer.cancel();
      }
    if(controller!=null)
      {
        controller.dispose();
      }
  }

  String description = "";
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
          key: _scaffoldKey,

          appBar: AppBar(
            leading: Functions.backButtonMain(context, function: (){
              MergeImagesWithVideo.cancel();
Navigator.pop(context);
            }),
            title: Text(AppLocalizations.of(context).post),
          ),
          body: Stack(
            children: [
              ListView(
                physics: BouncingScrollPhysics(),

                children: <Widget>[


                  Row(
                    children: [
                      Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width/1.5 - 14,
                        child: TextField(

                          style: TextStyle(
                              color: Colors.white54
                          ),

                          scrollPhysics: BouncingScrollPhysics(),
                          onChanged: (s){
                            description = s;
                          },
                          maxLines: 9,
                          keyboardType: TextInputType.multiline,
                          decoration: new InputDecoration(
                              border: InputBorder.none,

                              hintStyle: TextStyle(
                                  color: Colors.white24
                              ),
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                              hintText:  AppLocalizations.of(context).describeVideo
                          ),

                        ),
                      ),
                      Padding(padding: EdgeInsets.only(right: 14),
                      child: Container(

                        clipBehavior: Clip.hardEdge,

                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(6)

                        ),
                        height: 200,
                        child: isLoading ? Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,

                            children: [
                              Spacer(),
                              Functions.showLoaderSmall(),
                              Container(height: 13
                                ,),
                              Text("Processing", style: TextStyle(color: Colors.white54),)
,Spacer(),
                            ],
                          ),
                        ) : AspectRatio(aspectRatio: controller.value.aspectRatio,child: VideoPlayer(controller),),

                         width: MediaQuery.of(context).size.width/3 ,
                      ),
                      )
                    ],
                  ),


                  SizedBox(height: 14.0),

                /*  ListTile(
                    title: Text(
                      AppLocalizations.of(context).saveToGallery,
                      style: TextStyle(color: secondaryColor),
                    ),
                    trailing: Switch(
                      value: isSwitched2,
                      onChanged: (value) {
                        setState(() {
                          isSwitched2 = value;
                          //print(isSwitched2);
                        });
                      },
                      inactiveThumbColor: disabledTextColor,
                      inactiveTrackColor: darkColor,
                      activeTrackColor: darkColor,
                      activeColor: mainColor,
                    ),
                  ),*/

                ],
              ),

              Positioned(child:   Container(
                 height: 55,

                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8)
                ),
                width: MediaQuery.of(context).size.width,
                child: RaisedButton(

                  color: mainColor,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Text(
                          AppLocalizations.of(context).postVideo,
                        style:   Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color:  secondaryColor),
                      ),
                      isGettingUrl ? Container(width: 16,) : Container(),
                      isGettingUrl ? Functions.showLoaderSmall() : Container()


                    ],
                  ),
                  onPressed: () async {


                    if(MergeImagesWithVideo.queue.length>1)
                      {

                        Functions.showSnackBar(_scaffoldKey, "Please wait for previous file to get uploaded");
                        return;
                      }


                    if(MergeImagesWithVideo.queue.length==0) {
                      if (!isGettingUrl) {
                        setState(() {
                          isGettingUrl = true;
                        });
                        Functions fx = Functions();
                        var res = await fx.postReq(
                            Variables.base_url + "getUploadUrl", jsonEncode({}),
                            context);

                        var body = jsonDecode(res.body);


                        Map<String, String> headers = {
                          "Content-Type": "application/octet-stream",
                          'x-amz-acl': 'public'
                        };


                        setState(() {
                          isGettingUrl = false;
                        });

                        Functions.showSnackBar(
                            _scaffoldKey, "Video upload started");
                      //  Phoenix.rebirth(context);
                        String uploadBinaryURL = body["url"];
                        VideoUploader.uploadVideo(
                            video: File(videoPath),
                            headers: headers,
                            url: uploadBinaryURL,
                            binary: true

                        );
                      }
                    }

                    else{
                      Functions.showSnackBar(
                          _scaffoldKey, "Video upload starting soon");
                      MergeImagesWithVideo.uploadAfterProcessing();
                  //    Phoenix.rebirth(context);

                    }












                   },
                ),
              ), bottom: 10,
                left: 14, right: 14,)
            ],
          )
      ),

      onWillPop: () async{
        MergeImagesWithVideo.cancel();

        return true;
      },
    );
  }
}
