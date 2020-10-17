import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qvid/Components/entry_field.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Functions/VideoDownloader.dart';
import 'package:qvid/Model/Videos.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:qvid/Locale/locale.dart';



class MyBottomSheet extends StatefulWidget {

  //Videos video;
  final String title;
  final Color textColor;
  final double titleSize;
  final List<Widget> list;
  final bool enableBackDropFilter;
  BuildContext context;
  MyBottomSheet(this.context, {this.titleSize,this.title, this.list, this.enableBackDropFilter, this.textColor});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyBottomSheet> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var locale;
  bool showDelete = false;
  String link = "https://multiplatform-f.akamaihd.net/i/multi/april11/sintel/sintel-hd_,512x288_450_b,640x360_700_b,768x432_1000_b,1024x576_1400_m,.mp4.csmil/master.m3u8";

  String id = "1";

  @override
  void initState() {
    super.initState();
    locale = AppLocalizations.of(widget.context);



  }





  @override
  Widget build(BuildContext context) {
    Widget w = Stack(
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,

          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(height: 10,),
            //Container(height: 2, width: 40, color: Colors.white,),

            Divider(color: Colors.white, endIndent: 170,indent: 170,),
            Container(height: 21,),
            widget.title != null ?Padding(
              padding: EdgeInsets.only(left: 20,right: 20, bottom: 20),
              child: Text(
                widget.title,
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: widget.textColor==null? Colors.white60 : widget.textColor,fontSize:widget.titleSize== null? MediaQuery.of(context).viewInsets.bottom>10? 24:21 :widget.titleSize)  ,
              ),
            ):Container(),
            Padding(padding: EdgeInsets.only(left: 20, right: 20, bottom: 50), child:  Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.list,
            ),)

          ],
        ),
      ],
    );
    return  Container(

        child: ClipRRect(

            borderRadius: BorderRadius.vertical(top: Radius.circular(35.0)),
            child: widget.enableBackDropFilter == null ? new BackdropFilter(
              filter: new ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
              child:w,):   w)
    );
  }




}




class BottomSheetButton extends StatelessWidget {

  final String title;
  final Widget titleWidget;
 final Function onTap;

  const BottomSheetButton({Key key, this.title, this.onTap, this.titleWidget}) : super(key: key);







  @override
  Widget build(BuildContext context) {

    return    Container(height: 48,width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white.withOpacity(0.05),
      ),
      child:

      FlatButton(
          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),

          onPressed: onTap, child:  titleWidget == null ? Text(
        title,
        style: TextStyle(inherit: false),) : titleWidget ),
    );
  }



}

