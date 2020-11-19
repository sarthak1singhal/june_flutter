
import 'dart:convert';
 import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class TextOverlay extends StatefulWidget {

     Function onDone;
  final Function onCancel;
  final FocusNode focusNode;
  final Offset colorOffset;
    TextOverlay({Key key,   this.onCancel, this.focusNode, this.colorOffset}) : super(key: key);

       MyHomePageState     _child = MyHomePageState();


     @override
  MyHomePageState  createState() {
    return  _child;
    }


    TextStyle getStyle(){
      return  _child.getStyle();
    }

    String getText (){
      return _child.getText();
    }
}

class MyHomePageState  extends State<TextOverlay> {
  List<String> fontNames = [];

  TextEditingController textEditingController = TextEditingController();
  List<Colors> colors = [];

  Color textColor  = Colors.white;
  Color bgColor = Colors.transparent;
  int i = 0;
  int length = 0;
  ScrollController scrollController = ScrollController();
  FocusNode focusNode;
  int calculatedLines = 7;
  int numOfEnters = 5;


  double fontSize = 22;

  double screenHeight ;
  double keyboardHeight ;
  String changedText = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    focusNode  = FocusNode();

   /* scrollController.addListener(() {

      if(scrollController.position.maxScrollExtent>0)
      {

        if(fontSize<8)
        {

          return;
        }

        if(fontSize<=18)
          {
            calculatedLines += 4;
          }   if(fontSize<=14)
          {
            calculatedLines += 4;
          }if(fontSize<=10)
          {
            calculatedLines += 7;
          }


      //  calculatedLines  = ((screenHeight - keyboardHeight - 300) / (fontSize+ 30)).ceil();
         setState(() {
           calculatedLines +=5;
           fontSize = fontSize-4;
          print(fontSize);
        });


      }

    });*/


  }



  TextStyle getStyle(){
    return formTextStyles()[i];
  }

  String getText()
  {

    return changedText;
  }
  List<TextStyle> textStyles = [];

  List<TextStyle> formTextStyles(){

     List<TextStyle> t = [];

     t.add(TextStyle(
        wordSpacing: 2,
        height:2,
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: fontSize,
        background: Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = fontSize+9
          ..strokeJoin = StrokeJoin.miter

    ), );
    t.add(TextStyle(
        wordSpacing: 2,
        height: 1,
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: fontSize,
        background: Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = fontSize+8
          ..strokeJoin = StrokeJoin.round

    ), );
    length = t.length;
    textStyles  = t;

    return textStyles;

  }
  @override
  Widget build(BuildContext context) {
    return   SafeArea(child: Stack(
      overflow: Overflow.visible,

      children: [

        Scaffold(
            backgroundColor: Colors.black12,
            body: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Container(

                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only( top: 80, ),
                child: TextField(

                  controller: textEditingController ,


                  onTap: (){

                    if(MediaQuery.of(context).viewInsets.bottom>20) {
                      i++;
                      i = i % length;
                      setState(() {});
                    }
                  },


                   maxLines:null,//  ((widget.colorOffset.dy - 100)/(fontSize+2)).toInt(),



                  scrollController: scrollController,
                  onChanged: (s){

                    changedText = s;

                    //   print(widget.colorOffset);
                  },
                  cursorColor: Colors.white,

                  decoration: new InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: 40,  right: 49),
                      fillColor: Colors.white
                  ),

                  keyboardType: TextInputType.multiline,
                  textAlign: TextAlign.start,
                  style: formTextStyles()[i],
                  focusNode: focusNode,
                  autofocus: true,
                  //     autofocus:true

                ),
              ),
            )
        ),

        Positioned(child:Container(height:50,width: MediaQuery.of(context).size.width,
            child:  Row(
              children: [
                FlatButton(
                  child: Text("CANCEL", style: TextStyle(

                      inherit: false
                  ), ),
                  textColor: Colors.white,
                  color: Colors.transparent,
                  onPressed: widget.onCancel,
                ),
                Spacer(),
                FlatButton(
                  child: Text("DONE", style: TextStyle(

                      inherit: false
                  ), ),
                  textColor: Colors.white,
                  color: Colors.transparent,
                  onPressed: widget.onDone,

                )
              ],
            )
        ), top: 0, ),
      ],
    ));
  }
}
class MaxLinesTextInputFormatter extends TextInputFormatter {
  MaxLinesTextInputFormatter(this.maxLines)
      : assert(maxLines == null || maxLines == -1 || maxLines > 0);

  final int maxLines;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, // unused.
      TextEditingValue newValue,
      ) {
    if (maxLines != null && maxLines > 0) {
      final regEx = RegExp("^.*((\n?.*){0,${maxLines - 1}})");
      String newString = regEx.stringMatch(newValue.text) ?? "";

      final maxLength = newString.length;
      if (newValue.text.runes.length > maxLength) {
        final TextSelection newSelection = newValue.selection.copyWith(
          baseOffset: min(newValue.selection.start, maxLength),
          extentOffset: min(newValue.selection.end, maxLength),
        );
        final RuneIterator iterator = RuneIterator(newValue.text);
        if (iterator.moveNext())
          for (int count = 0; count < maxLength; ++count)
            if (!iterator.moveNext()) break;
        final String truncated = newValue.text.substring(0, iterator.rawIndex);
        return TextEditingValue(
          text: truncated,
          selection: newSelection,
          composing: TextRange.empty,
        );
      }
      return newValue;
    }
    return newValue;
  }
}