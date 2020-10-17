import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matrix4_transform/matrix4_transform.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:qvid/Functions/LocalColors.dart';
import 'package:screenshot/screenshot.dart';

 class OverlayWidgetTimeScreen extends StatefulWidget {

  final double height, width;
    Matrix4 matrix4;
  final File file;
  double startTime;
  double endTime;
  Offset tapOffset = Offset(0,0);


  OverlayWidgetTimeScreen({Key key, this.height, this.width, this.file,   this.startTime, this.endTime, this.matrix4}) : super(key: key);

  _MyHomePageState _child ;

  @override
  _MyHomePageState createState() {
    _child = _MyHomePageState();
    return _child;
  }


  setPosition(Matrix4 matrix4){
    _child.setPosition(matrix4);
  }

  Matrix4 getPosition(){
    return _child.getPosition();
  }

  addBorder(){
    _child.addBorder();
  }

}

class _MyHomePageState extends State<OverlayWidgetTimeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  void initState() {
    print(widget.key.toString());
    print("KEYYYY");
    matrix = widget.matrix4;
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      matrix = widget.matrix4;

      setState(() {

          });
    });

  }

  Matrix4 matrix = Matrix4.identity();
  ScreenshotController screenshotController = ScreenshotController();


  bool isBorderShowing = false;





  bool isFirstUpdate = false;
  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: true,
        child: Container(
          height: widget.height,
          width: widget.width,
          child: MatrixGestureDetector(
              onMatrixUpdate: (Matrix4 m, Matrix4 tm, Matrix4 sm, Matrix4 rm) {





                if(!isFirstUpdate)
                  {
                    isFirstUpdate = true;
                    m = matrix;
                  }

                if(isBorderShowing)
                {
                  isBorderShowing = false;
                }
                setState(() {
                  matrix = m;
                });
              },
              child :
              Transform(

                  child: Align(
                    heightFactor: 1,
                    child: Container(
                      child:           widget.file==null? Container( child: Text("HEY YOU", style: TextStyle(inherit:false,fontSize: 28),),) :Image.file(

                        widget.file,
                      ), padding: EdgeInsets.all(3/ matrix.getMaxScaleOnAxis()),
                      decoration: BoxDecoration(
                        border: Border.all(color: isBorderShowing?  Colors.white: LocalColors.transparent, width: 0.6/matrix.getMaxScaleOnAxis()),
                        borderRadius: BorderRadius.all(

                          Radius.circular(2.0/matrix.getMaxScaleOnAxis()),

                        ),
                      ),
                    ),
                  ),

                  transform:  matrix
              )
          ),

        ));
  }



  setPosition(Matrix4 matrix4){

    setState(() {
this.matrix = matrix4;
    });
  }



  addBorder(){
    isBorderShowing = true;
    setState(() {

    });
  }




  Matrix4 getPosition(){
    return matrix;
  }

}
