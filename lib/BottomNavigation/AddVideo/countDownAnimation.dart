import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class CountDownTimer extends StatefulWidget {


  @override
  CountTimer createState() => CountTimer ();
}

class CountTimer extends State<CountDownTimer>  with SingleTickerProviderStateMixin{


  double scale  = 1;
  static AnimationController controller ;


  int number=3;
  static bool isPaused = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = AnimationController(vsync: this, value: 1, lowerBound: 1,upperBound: 10, duration: Duration(milliseconds: 500));

    controller.addListener(() {

      if(!isPaused)
      {

        if(controller.isCompleted) {

          controller.animateBack(1);
          number--;

        }
        setState(() {



        });

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
   }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Transform.scale(scale: controller.value, child: Text(number.toString()),),
    );
  }
}
