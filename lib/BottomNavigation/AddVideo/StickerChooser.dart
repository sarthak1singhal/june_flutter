import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
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



class StickerChooser extends StatefulWidget {

  //Videos video;
  final String title;
  final Color textColor;
  final double titleSize;
   final bool enableBackDropFilter;
  BuildContext context;
  StickerChooser(this.context, {this.titleSize,this.title,  this.enableBackDropFilter, this.textColor});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<StickerChooser> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var locale;
  bool showDelete = false;

  String id = "1";

  bool isLoading = false;
  bool isExist = true;
  bool isError = false;
  String errorMessage = "";
  List<Widget> urls = [];
  bool isFullScreen = false;

  @override
  void initState() {
    super.initState();
    locale = AppLocalizations.of(widget.context);

    getStickers();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {

      print("RANDI DARINIAND");
      print(containerKey.currentContext.size.height );
      if(containerKey.currentContext.size.height >= MediaQuery.of(context).size.height-20){


        isFullScreen = true;
        setState(() {

        });
      }



    });


    urls.add(

      Padding(padding: EdgeInsets.all(14),
      child:  GestureDetector(


        child: AnimatedContainer(
          duration: Duration(milliseconds: 100),



          //margin: EdgeInsets.only(bottom: tapDown ? 4 :10),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.image, color: Colors.white,size: 24,),
                //Text("Gallery", style: TextStyle(color: Colors.white),)
              ],
            ),
          ),

          decoration: BoxDecoration(
              color:   mainColor,
              borderRadius: BorderRadius.all(Radius.circular(8)),
              boxShadow:  [  BoxShadow(
                  color:  Colors.black38,
                  blurRadius: 7,

                  offset: Offset(0, 1))
              ]
          ),
        )
        ,
        onTap: () async{
          FilePickerResult result = await FilePicker.platform.pickFiles(
            type: FileType.image,
            allowCompression: true,
            withData: true,
          );

          if(result == null )return;

          Navigator.pop(context, Image.file(File(result.files[0].path)));


        },





      ),)

    );
  }


  getStickers() async{
    if(isLoading) return;

    setState(() {
      isLoading = true;
    });

    Functions fx = Functions();




    try{
      var res = await fx.postReq(Variables.get_stickers, jsonEncode({}), context);
      var data = jsonDecode(res.body);

      if(data["isError"]){
        isError  = true;
        errorMessage = "Some error occured";
        setState(() {
          isLoading = false;
        });
        return;
      }

      for(int i=0;i<data["msg"].length; i++)
      {
        urls.add(
         GestureDetector(
           child:  Container(
             child: CachedNetworkImage(imageUrl: data["msg"][i]["url"]),
           ),
           onTap: (){
             Navigator.pop(context, data["msg"][i]["url"]);
           },
         )
        );

      }

    }catch(e){

      isError = true;
      errorMessage = Variables.connErrorMessage;
      setState(() {
        isLoading = false;
      });

    }


    setState(() {
      isLoading  = false;
    });
  }

  ScrollController _scrollController = ScrollController();
  GlobalKey containerKey = GlobalKey();


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
            Container(height: 21,

            ),
            widget.title != null ?Padding(
              padding: EdgeInsets.only(left: 20,right: 15, bottom: 20, ),
              child:
              Row(
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(color: widget.textColor==null? Colors.white60 : widget.textColor,fontSize:widget.titleSize== null? MediaQuery.of(context).viewInsets.bottom>10? 24:21 :widget.titleSize)  ,
                  ),
                  Spacer(),
                isFullScreen?  IconButton(
                    icon: Icon(Icons.close, color: Colors.white.withOpacity(0.8), size: 21,),
                    onPressed: (){
                      Navigator.pop(context);
                    },

                  ):Container()
                  ],
              )
            ):Container(),


           Flexible(child:  GridView.count(
             crossAxisCount: 4,
             childAspectRatio: 1.0,
             padding: const EdgeInsets.all(4.0),
             mainAxisSpacing: 7.0,
             crossAxisSpacing: 7.0,
             controller: _scrollController,
              shrinkWrap: true,
             physics: BouncingScrollPhysics(),
             children:
             urls
             ,
           )
           ),
            isLoading?Functions.showLoaderSmall():Container(),


            Container(height: 40,)

          ],
        ),
      ],
    );
    return  Container(
      key: containerKey,
        decoration: BoxDecoration(
            color: Colors.transparent,
            boxShadow:  [  BoxShadow(
                color:  Colors.black.withOpacity(0.14),
                blurRadius: 14,

                offset: Offset(0, -6))    ]
        ),
        child: ClipRRect(

            borderRadius: BorderRadius.vertical(top: Radius.circular(35.0)),
            child: widget.enableBackDropFilter == null ? new BackdropFilter(
              filter: new ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
              child:w,):   w)
    );
  }




}


