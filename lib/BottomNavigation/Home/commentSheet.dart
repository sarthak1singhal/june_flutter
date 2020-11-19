import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qvid/Components/entry_field.dart';
import 'package:qvid/Functions/LocalColors.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:qvid/Locale/locale.dart';



class CommentSheet extends StatefulWidget {

  int video_id;
  String username;
  BuildContext context;
  CommentSheet(this.context, this.video_id, this.username);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class Comment{
  final String profile_pic,username,comment,  isLiked, fb_id;
  final int isVerified,video_id;
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
          username: widget.username,
          comment: s,
          time: DateTime.now(),
          timeString: Functions.dateToReadableString(DateTime.now())

      ));
       else
      Functions.showToast("Unable to post comment", context);
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

    if(!isLoading)
      {
        setState(() {
          isLoading = true;
        });


        try{

          Functions fx = Functions();
          print(widget.video_id);

          var res = await fx.postReq(Variables.showVideoComments, jsonEncode({
            "offset": offset,
            "video_id" : widget.video_id
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

            setState(() {

            });

          }

        }catch(e){

        }


        setState(() {
          isLoading = false;
        });

      }
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
          video_id: widget.video_id,
          fb_id: data[i]["fb_id"],


        ));

      }

  }


  @override
  Widget build(BuildContext context) {
    return  Container(
        decoration: BoxDecoration(
            color: Colors.transparent,
            boxShadow:  [  BoxShadow(
                color:  Colors.black.withOpacity(0.16),
                blurRadius: 13,

                offset: Offset(0, -6))    ]
        ),
      height: MediaQuery.of(context).viewInsets.bottom >10?MediaQuery.of(context).size.height
        :
      MediaQuery.of(context).size.height / 1.5,
      child: ClipRRect(

          borderRadius: BorderRadius.vertical(top: Radius.circular(35.0)),
          child: new BackdropFilter(
              filter: new ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
              child:Stack(
                children: <Widget>[
                  Container(
                    height:20,


                  ),
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
                              .copyWith(color: Colors.white, fontSize:MediaQuery.of(context).viewInsets.bottom>10? 24:21),
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
                              return ListTile(

                                  leading: Container(
                                    child: Center(
                                      child: GestureDetector(
                                        child: Functions.showProfileImage(comments[index].profile_pic,32,comments[index].isVerified),
                                        onTap: (){

                                        },

                                      ),
                                    ),
                                    width: 40,

                                  ),

                                  title: Text(Functions.isNullEmptyOrFalse(comments[index].username)? "":comments[index].username,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                          height: 1.5,
                                          fontWeight: FontWeight.w500,

                                          color: Colors.white)),
                                  subtitle: RichText(
                                    text: TextSpan(children: [
                                      TextSpan(
                                          text: comments[index].comment,
                                          style: TextStyle(
                                              inherit: false,
                                              height: 1,

                                              color: Colors.white.withOpacity(0.8)
                                          )
                                      ),

                                    ]),

                                  ),
                                  trailing: Container(child: Text(
                                      comments[index].timeString,
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption.copyWith(
                                          inherit: false,

                                          color: Colors.white.withOpacity(0.45),
                                          fontSize: 11


                                      )
                                  ),)

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
                      color: darkColor,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding:
                            EdgeInsets.only(left: 22,right: 17,bottom: 5),
                            child:  Functions.showProfileImage(Variables.user_pic,36,0),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width-140,
                            child:  EntryField(
                              textCapitalization: TextCapitalization.sentences,
                              onChanged: (s){
                                comment = s;
setState(() {

});
                              },
                              focusNode: _focusNode,
                              counter: null,
                              contentPadding: EdgeInsets.only(top: 18),
                              padding: EdgeInsets.zero,
                              controller: controller,
                              hint: locale.writeYourComment,
                              fillColor: darkColor,
                              ),
                          ),


                          isSendingMessage ? Container(height: 30,width: 30, child: Functions.showLoaderSmall(),)
                              :Padding(padding: EdgeInsets.only(right: 17,bottom: 5),
                          child: IconButton(
                            icon: Icon(Icons.send , color: Functions.isNullEmptyOrFalse(controller.text) ? Colors.white38 : mainColor.withOpacity(0.9) ),
                            onPressed: (){

                              if(controller.text!=null)
                                if(controller.text.trim().length>0) {

                                  sendMessage(controller.text);
                                  controller.text = "";
                                }
                            },

                          ),
                          )

                        ],
                      ),
                    ),
                  ),
                ],
              ),))
    );
  }

  String comment="";
}
