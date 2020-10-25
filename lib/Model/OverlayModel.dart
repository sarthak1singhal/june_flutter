import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matrix4_transform/matrix4_transform.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:qvid/Functions/LocalColors.dart';
 import 'package:screenshot/screenshot.dart';

typedef MathF<T extends num> = T Function(T, T);
   class OverlayWidget extends StatefulWidget {

  final double height, width;
  final File file;
    Function fx;
    Function onTapDown;
    double startTime;
    Matrix4 matrix4;

   final Widget child;
    double endTime;
  Offset tapOffset = Offset(0,0);



  OverlayWidget({Key key, this.height, this.width, this.file, this.fx, this.startTime, this.endTime, this.onTapDown, this.matrix4,@required this.child}) : super(key: key);

  _MyHomePageState _child ;

  @override
  _MyHomePageState createState() {
    _child = _MyHomePageState();
   return _child;
  }


  hideShowBorder(){
    _child.showHideBorder();
  }

  Future<void> takeScreenshot(String path) async{
  await  _child.takeScreenshot(path);
  }

  isBorderShown(){
    return _child.isBorderShown();
  }

  Matrix4 getPosition(){
    return _child.getPosition();
  }


  changeVisibility(double currentTime)
  {
    _child.changeVisibility(currentTime);

  }

  bool isChildVisible()
  {
    return _child.isVisible;
  }
  showChildVisibility()
  {
    _child.showChildVisibility();

  }
  hideChildVisibility()
  {
    _child.hideChildVisibility();

  }

  hideVisibility(){
    _child.hideMain();
  }

  showVisibility(){
    _child.showMain();
  }

}

class _MyHomePageState extends State<OverlayWidget> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  double videoLength;
  @override
  void initState() {

    super.initState();
    if(widget.matrix4!=null)
      {
        matrix = widget.matrix4;
      }
    videoLength = widget.endTime;
  }


  Matrix4 matrix = Matrix4.identity();
  ScreenshotController screenshotController = ScreenshotController();

  bool isVisible = true;

  bool mainVisible = true;
  bool isBorderShowing = false;

  double _minMax(num _min, num _max, num actual) {
    if (_min == null && _max == null) {
      return actual.toDouble();
    }

    if (_min == null) {
      return min(_max.toDouble(), actual.toDouble());
    }

    if (_max == null) {
      return max(_min.toDouble(), actual.toDouble());
    }

    return min(_max.toDouble(), max(_min.toDouble(), actual.toDouble()));
  }



   @override
  Widget build(BuildContext context) {
    return mainVisible? Visibility(
        visible: isVisible,
        child: GestureDetector(
      onTapUp: widget.onTapDown,
      child: Screenshot(
        controller: screenshotController,
        child: Container(

          height: widget.height,
          width: widget.width,
          child: MatrixGestureDetector(
              onMatrixUpdate: (Matrix4 m, Matrix4 tm, Matrix4 sm, Matrix4 rm) {


                if(m.getMaxScaleOnAxis()>2.5)
                {

                  //   return;
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

                  child:
                  Align(
                    heightFactor: 1,
                    child:

                    Opacity(
                      opacity: isBorderShowing? 0.67 : 1.0,
                      child:         widget.child!=null?   widget.child :Image.file(

                        widget.file,
                      ),
                    )



                   /* OverflowBox(child: Container(
                       child:           widget.child!=null? widget.child :Image.file(

                        widget.file,
                      ), padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: isBorderShowing?  Colors.blue: LocalColors.transparent, width: 0.6/matrix.getMaxScaleOnAxis()),
                        borderRadius: BorderRadius.all(

                          Radius.circular(2.0/matrix.getMaxScaleOnAxis()),

                        ),
                      ),
                    ),)*/
                  ),

                  transform:  matrix//Matrix4.diagonal3Values(2, 2, 2.0),
              )
          ),

        ),
      ),
      onTap: widget.fx,
    )) : Container(height: 0,width: 0,);
  }





    Future<void> takeScreenshot(String path) async{

      await  screenshotController.capture(path:path,pixelRatio: 1.75);

  }


  showHideBorder(){

    try{
      setState(() {
        isBorderShowing = !isBorderShowing;
      });
    }catch(e){
      print(e);
    }
  }


  bool isBorderShown(){
    return isBorderShowing;
  }


  Matrix4 getPosition(){
    return matrix;
  }


   changeVisibility(double currentTime){

    if(widget.endTime==videoLength && widget.startTime==0)
      {
        return;
      }
    else{

      if(currentTime<widget.startTime)
        {
          if(isVisible)
            {
              setState(() {
                isVisible = false;
              });
            }
          else{
            return;
          }
        }else{
        if(currentTime<widget.endTime){
          if(!isVisible)
          {
            setState(() {
              isVisible = true;
            });
          }else{
            return;
          }
        }else{
          if(isVisible)
          {
            setState(() {
              isVisible = false;
            });
          }
          else{
            return;
          }
        }


      }




    }

  }

  showChildVisibility(){
    isVisible = true;
    setState(() {

    });
  }
  hideChildVisibility(){
    isVisible = false;
    setState(() {

    });
  }


  bool hideMain(){
    mainVisible = false;
    setState(() {

    });
  }

  bool showMain(){
    mainVisible = true;
    setState(() {

    });
  }

}
