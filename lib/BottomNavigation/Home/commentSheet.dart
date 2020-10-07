import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qvid/Components/entry_field.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:qvid/Locale/locale.dart';



class CommentSheet extends StatefulWidget {

  String video_id;
  BuildContext context;
  CommentSheet(this.context, this.video_id);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class Comment{
  final String profile_pic,username,comment,  isLiked, fb_id, video_id;
  final int isVerified;
  String timeString;
  DateTime time;

  Comment({this.profile_pic, this.timeString,this.isVerified, this.fb_id,this.video_id, this.username, this.comment, this.time, this.isLiked});
}
class _MyHomePageState extends State<CommentSheet> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var locale;
  FocusNode _focusNode = FocusNode();
  List<Comment> comments = [];
  ScrollController _scrollController = new ScrollController();
TextEditingController controller  = new TextEditingController();
  @override
  void initState() {
    super.initState();
    locale = AppLocalizations.of(widget.context);

    getData();

    comments.add(Comment(profile_pic: Variables.user_pic, timeString: "DAADAD", username: "trial", fb_id: Variables.fb_id, comment: "HEY"));

    _scrollController.addListener(() {
       if (_scrollController.position.extentAfter < 100) {

         if (!existMore) {
          getData();
        }
        setState(() {
          //   items.addAll(new List.generate(42, (index) => 'Inserted $index'));
        });
      }
    });
  }

  int offset = 0;
  int limit = 25;


  bool isSendingMessage  = false;
  sendMessage(String s) async{

    isSendingMessage = true;
    setState(() {

    });


    try{
      Functions fx = Functions();

      var res = await fx.postReq(Variables.postComment, jsonEncode({
        "video_id":widget.video_id,
        "comment": s

      }), context);
      var re = jsonDecode(res.body);
      if(!re["isError"])
      comments.insert(0,Comment(profile_pic: Variables.user_pic, isVerified: Variables.isVerified,
          fb_id: Variables.fb_id,
          video_id: widget.video_id,
          username: Variables.username,
          comment: s,
          time: DateTime.now(),
          timeString: Functions.dateToReadableString(DateTime.now())

      ));
       else
      Functions.showToast("Unable to post comment");
      //Functions.showSnackBar(_scaffoldKey, message)

    }catch(e)
    {

      print(e);
    }
    setState(() {
      isSendingMessage = false;
    });
  }


  bool isLoading = false;
  bool existMore= true;
  getData() async{

    if(!existMore)
      {
        return;
      }
    setState(() {
      isLoading = true;
    });


    try{

      Functions fx = Functions();

      var res = await fx.postReq(Variables.showVideoComments, jsonEncode({
        "offset": offset
      }), context );

      var s = jsonDecode(res.body);

      if(s["isError"])
        {



        }else{

        if(!Functions.isNullEmptyOrFalse(s['msg']))
          {
            parseData(s['msg']);

            offset = offset + s["msg"].length;
            if(s['msg'].length<limit)
              {
                existMore = false;
                setState(() {
                  isLoading =false;
                });
              }
          }

      }

    }catch(e){

    }


    setState(() {
      isLoading = false;
    });

  }

  parseData(var data){

    for(int i = 0;i<data.length; i++)
      {


        comments.add(Comment(

          username: data[i]["user_info"]["username"],
          profile_pic: data[i]["user_info"]["profile_pic"],
          isVerified: data[i]["user_info"]["verified"],
          //time: DateTime.parse(data[i]["created"]),
          timeString: Functions.dateToReadableString(DateTime.parse(data[i]["created"])),
          comment: data[i]["comments"],
          video_id: data[i]["video_id"],
          fb_id: data[i]["fb_id"],


        ));

      }

  }


  @override
  Widget build(BuildContext context) {
    return  Container(

      height: MediaQuery.of(context).viewInsets.bottom >10?MediaQuery.of(context).size.height
        :
      MediaQuery.of(context).size.height / 1.5,
      child: ClipRRect(

          borderRadius: BorderRadius.vertical(top: Radius.circular(35.0)),
          child: new BackdropFilter(
              filter: new ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
              child:Stack(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(height: 10,),
                      //Container(height: 2, width: 40, color: Colors.white,),

                      Divider(color: Colors.white, endIndent: 170,indent: 170,),
                      MediaQuery.of(context).viewInsets.bottom >10 ?
                      Container(height: 21,): Container(height: 10,),
                      Padding(
                        padding: EdgeInsets.only(left: 20,right: 20, bottom: 20),
                        child: Text(
                          locale.comments,
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(color: Colors.white70, fontSize:MediaQuery.of(context).viewInsets.bottom>10? 24:21),
                        ),
                      ),
                      isLoading?Functions.showLoaderSmall():Container(),
                      Expanded(
                        child: ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            physics: BouncingScrollPhysics(),
                            padding: EdgeInsets.only(bottom: 60.0),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: <Widget>[
                                 /* Divider(
                                    color: darkColor.withOpacity(0.4),
                                    thickness: 1,
                                  ),*/
                                  ListTile(
                                    leading: GestureDetector(
                                      child: Functions.showProfileImage(comments[index].profile_pic,45,comments[index].isVerified),
                                      onTap: (){

                                      },

                                    ),

                                    title: Text(comments[index].username,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            .copyWith(
                                            height: 2,
                                            color: disabledTextColor)),
                                    subtitle: RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                          text: comments[index].comment,
                                        ),
                                        TextSpan(
                                            text: comments[index].timeString,
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption),
                                      ]),
                                    ),

                                  ),
                                ],
                              );
                            }),
                      ),
                      Container(height: MediaQuery.of(context).viewInsets.bottom>10?MediaQuery.of(context).viewInsets.bottom+40:50,
                        //width: 10,
                        color: darkColor,
                      )
                    ],
                  ),
                  Positioned(
                    bottom: MediaQuery.of(context).viewInsets.bottom>10? MediaQuery.of(context).viewInsets.bottom-10:MediaQuery.of(context).viewInsets.bottom
                    ,
                    //  alignment: Alignment.bottomCenter,
                    child: Container(height: 90,
                      width: MediaQuery.of(context).size.width,
                      child: EntryField(
                        onChanged: (s){
                          comment = s;
                        },
                        focusNode: _focusNode,
                        counter: null,
                        padding: EdgeInsets.zero,
                        controller: controller,
                        hint: locale.writeYourComment,
                        fillColor: darkColor,
                        prefix: Padding(
                          padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child:  Functions.showProfileImage(Variables.user_pic,45,0),
                        ),
                        suffixIcon: isSendingMessage ? Container(height: 30,width: 30, child: Functions.showLoaderSmall(),)
                            :IconButton(
                          icon: Icon(Icons.send ,),
                          onPressed: (){

                            if(controller.text!=null)
                              if(controller.text.trim().length>0) {

                                sendMessage(controller.text);
                                controller.text = "";
                              }
                          },

                        ),
                      ),
                    ),
                  ),
                ],
              ),))
    );
  }

  String comment="";
}
