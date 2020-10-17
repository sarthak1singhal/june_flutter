import 'dart:convert';

 import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:async';

class ProgressBar extends StatefulWidget {

  final List<double> pauses;
  final bool isProgressing ;

  final Size size;
  const ProgressBar(this.size,{Key key, this.pauses, this.isProgressing}) : super(key: key);




  @override
  Progress createState() => Progress();
}

class Progress extends State<ProgressBar>  with SingleTickerProviderStateMixin {


 static AnimationController controller;




   static bool isPaused = true;
  double initialWidth = 0;
  double secondEquivalent = 0;
  double maxWidth = 0;
  double height = 4;
 int i =0;

 static List<double> stops = [];

 @override
  void initState() {



    // TODO: implement initState
    super.initState();



    maxWidth = widget.size.width-16;
    secondEquivalent = maxWidth/30;


    controller = AnimationController(
      vsync: this,
      value: 0,
      lowerBound: 0,
      upperBound: maxWidth,
      duration: Duration(seconds: 30, ),

    );
    controller.addListener(() {
      if(initialWidth<=maxWidth) {
        if(!isPaused)
      {
        setState(() {

        });

         /*setState(() {
          initialWidth = maxWidth/30 * time;

        })*/;
      }
      }
      else{
        if (controller.status == AnimationStatus.forward) {
          controller.stop();
        // _timer.cancel();
        }
      }



    });




 }


 static start(){

   isPaused = false;

   controller.forward();
  }



 static pause(){

    controller.stop();
    isPaused = true;
    stops.add(controller.value);
  }

 static removeLastSegmet(){


    if(stops.length==0)return;

   if(stops.length ==1)
     {
       controller.value = 0;
       stops.removeLast();

     }
   else{

     controller.value = stops[stops.length-2];
     stops.removeLast();

   }


  }


 static changeSpeed(int speed){

   //0.3, 0.5, 1, 2, 3
   if(speed==2)
     controller.duration = Duration(seconds: 60);

   else if(speed == 3)

     controller.duration = Duration(seconds: 90);

    else if(speed == 0.5)

      controller.duration = Duration(seconds: 15);

   else if(speed == 0.3)

     controller.duration = Duration(seconds: 9);



 }



 List<Widget> widgets = [];
  @override
  Widget build(BuildContext context) {


    widgets.clear();

    widgets.add(  Container(width: controller.value,

      color: Colors.blue,
      height: height,
    ),);


    for(int i=0; i<stops.length; i++)
      {
        widgets.add(Positioned(
          left: stops[i]/*maxWidth/30*(widget.pauses[i]-0.2)*/,
          child:Container(height: height,width: 2, color: Colors.white, )
        ));

      }


     return Padding(padding: EdgeInsets.only(left: 8, right: 8, top: 6),

        child: ClipRect(
          child: Container(
            decoration: BoxDecoration(
                color: isPaused?Colors.white38 :Colors.white54,

                boxShadow: [BoxShadow(
                    color: Colors.black38, blurRadius: 3, offset: Offset(0,1)
                )],
                borderRadius: BorderRadius.all(Radius.circular(4))
            ),
            width: widget.size.width-16,
            height:  height,
            child: Stack(
                children: widgets
            ),
          ),
        )

    );
  }

 @override
 void dispose() {
   super.dispose();
   //_timer.cancel();
   controller.dispose();
  }


}
