import 'dart:convert';

 import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:async';

class ProgressBar extends StatefulWidget {

  final List<double> pauses;
  final bool isProgressing ;

  final Size size;
  ProgressBar(this.size,{Key key, this.pauses, this.isProgressing}) : super(key: key);


  pause(){
    progress.pause();
  }

  removeLastSegmet()
  {
    progress.removeLastSegmet();
  }

  start(){
    progress.start();
  }

  changeSpeed(double speed){
    progress.changeSpeed(speed);
  }


  double getTime(){
    double d = progress.getTime();//.inMilliseconds.toDouble() ;
    return d /1000;
  }


  Progress progress  = Progress();
  @override
  Progress createState() {
    return progress;
  }

  bool isRecording(){
    return progress.isRecording();
  }

  bool isCompleted(){
    return progress.isCompleted();
  }

  setTime(double d){
    progress.setTime(d);
  }
}

class Progress extends State<ProgressBar>  with SingleTickerProviderStateMixin {

  isRecording(){
    if(controller==null) return false;
    return controller.isAnimating;
  }

  isCompleted(){
    if(controller==null) return false;
    return controller.isCompleted;
  }





   AnimationController controller;


  double time = 0;


   static bool isPaused = true;
  double initialWidth = 0;
  double secondEquivalent = 0;
  double maxWidth = 0;
  double height = 4;
 int i =0;

   List<double> stops = [];
   List<double> stopDurations = [];




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




      if(controller.value == maxWidth)
         {
        //   print(controller.isAnimating);
           //print(controller.value.toString() + " ---- " + maxWidth.toString());
              time = 30000;
             stopDurations.add(time);
             stops.add(controller.value);

             //controller.stop();
             // _timer.cancel();
         }

      if(initialWidth<=maxWidth) {
        if(!isPaused)
      {
        setState(() {

        });



      }
      }




    });




 }
   double getTime(){
   if(controller==null) return 0;
     if(controller.isAnimating)
       if(controller.lastElapsedDuration.inMilliseconds!=null) {
         print("SPEEEEEEEEEEEEED  $speed");
         print("SPEEEEEEEEEEEEED  ${controller.lastElapsedDuration.inMilliseconds} ");
         print((controller.lastElapsedDuration.inMilliseconds /speed)/1000);
         return time + (controller.lastElapsedDuration.inMilliseconds / speed);
       }
       else {
         return time;
       }
     else{
       print("returning time = " + (time/1000).toString());
       return time;
     }
   }

   setTime(double d){
      controller.value = ((time/1000)+ d )* secondEquivalent;
      time = time + d*1000;
      stops.add(controller.value);
      stopDurations.add(time);
      setState(() {

});
   }

   start(){

   if(controller.isCompleted)
     {
       return;
     }


   /*if(time/1000>=29.8)
     {
    return;
     }*/

   isPaused = false;

   controller.forward();


 }



   pause() {
     if (!controller.isCompleted) {
       time = time +  (controller.lastElapsedDuration.inMilliseconds / speed);
       stopDurations.add(time);
       controller.stop();
       isPaused = true;
       stops.add(controller.value);
       setState(() {

       });
     }
   }

   removeLastSegmet(){


    if(stops.length==0)return;

   if(stops.length ==1)
     {
       time = 0;
       stopDurations.removeLast();
       controller.value = 0;
       stops.removeLast();

     }
   else{



     controller.value = stops[stops.length-2];
     stops.removeLast();
     time =  stopDurations[stopDurations.length-2];
     stopDurations.removeLast();

   }

   setState(() {

   });


  }

  double speed = 1;

   changeSpeed(double s){

     speed = s;
   //0.3, 0.5, 1, 2, 3
   if(s==2)
    {
      controller.duration = Duration(seconds: 60);
    }

   else if(s == 3) {
     controller.duration = Duration(seconds: 90);
   }
    else if(s == 0.5) {
     controller.duration = Duration(seconds: 15);
   }
   else if(s == 0.3) {
     controller.duration = Duration(seconds: 9);
   }
   else{
     controller.duration = Duration(seconds: 30);
   }



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
            clipBehavior: Clip.hardEdge,

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
