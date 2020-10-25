import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qvid/Model/OverlayModel.dart';
import 'package:video_player/video_player.dart';


class ShowHideScreen extends StatefulWidget {


  List<OverlayWidget> list ;
  final double startTime;
  final double endTime;

  VideoPlayerController controller;
  final bool isPlaying ;
  ShowHideScreen({Key key, this.list, this.startTime, this.endTime, this.isPlaying, this.controller}) : super(key: key);



  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ShowHideScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  double time = 0;

  @override
  void initState() {
    super.initState();
    if (countDownTimer == null) {
     /* countDownTimer= new Timer.periodic(
        Duration(milliseconds: 500),
            (Timer timer) {


          if(widget.isPlaying)
            {

              time = time+0.5;
              if(time >= widget.endTime.floor().toDouble())
              {
                time=0;
              }

              for(int i=0;i<widget.list.length;i++)
              {

                    widget.list[i].changeVisibility(time);
               }
              print(time);

            }

        },
      );*/
    }

    widget.controller.addListener(() {
       //print("LSITENING");

       if(widget.controller.value.isPlaying)
        {
          for(int i=0;i<widget.list.length;i++)
          {

            widget.list[i].changeVisibility(widget.controller.value.position.inMilliseconds.toDouble()/1000);
          }
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Container(
        child: Stack(
          overflow: Overflow.visible,

          children: widget.list,
        )
    );
  }


  Timer countDownTimer;




  @override
  void dispose() {
    if(countDownTimer!=null)
    countDownTimer.cancel();
    super.dispose();

  }
}
