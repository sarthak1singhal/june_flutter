import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_view/flutter_web_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:qvid/Functions/LocalColors.dart';
import 'package:qvid/authentication/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:qvid/Theme/colors.dart';

import 'Variables.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../Model/Videos.dart';

class Functions {
    Future<http.Response> postReq(
      String url, String params, BuildContext context,
      {Map<String, String> urlParams, bool isIdChange}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Variables.token = prefs.getString(Variables.tokenString);
    Variables.refreshToken = prefs.getString(Variables.refreshTokenString);

    print(Variables.token);
    if (isNullEmptyOrFalse(Variables.token)) {
      var isLoggedIn = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => Login()));
      print("SIGN IN");
      print(Variables.token);
      if (isIdChange) {
        var m = jsonDecode(params);
        m["fb_id"] = Variables.fb_id;
        params = jsonEncode(m);
      }
      // return null;
    }

    debugPrint(url);

    print("KAWASAKI");

    var res = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'token': Variables.token,
        'refresh_token': Variables.refreshToken
      },
      body: params,
    );
    print("KADLKDNSLKAN");

    print(res.body);

    if (res.statusCode == 403) {
      Navigator.of(context).popUntil(ModalRoute.withName('/'));

      //  Navigator.pop(context);

      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));

      prefs.setString(Variables.tokenString, "");
      prefs.setString(Variables.refreshTokenString, "");
      Variables.refreshToken = "";
      Variables.token = "";

      return null;
    }

    var l = res.headers["set-cookie"].split("HttpOnly,");
    for (int i = 0; i < l.length; i++) {
      if (l[i].split("; ")[0].contains("access_token=")) {
        prefs.setString(Variables.tokenString,
            l[i].split("; ")[0].replaceAll("access_token=", ""));
        Variables.token = l[i].split("; ")[0].replaceAll("access_token=", "");
      }
      if (l[i].split("; ")[0].contains("refresh_token=")) {
        prefs.setString(Variables.refreshTokenString,
            l[i].split("; ")[0].replaceAll("refresh_token=", ""));
        Variables.refreshToken =
            l[i].split("; ")[0].replaceAll("refresh_token=", "");
      }
    }

    return res;
  }

  static Future<http.Response> getReq(String secondUrl, String params) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString(Variables.tokenString);

    if (token == null) {
      print("SIGN IN");
      return null;
    }
    return http.get(
      Variables.domain + secondUrl,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'token': token
      },
    );
  }

  static Future<http.Response> unsignPostReq(String url, String params, ) async {
    print(url);
    print(params);
    var res = await http.post(
       url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: params,
    );
    debugPrint(res.body);
    return res;
  }



  static Widget showProfileImage (String url, double size, int isVerified) {
    bool _validURL = Uri.parse(url).isAbsolute;

    String u = url;
    print(url);
    if (!_validURL) {
      url = Variables.base_url + "local/?p=" + url;

//      return Image.asset("assets/user/user1.png");
    }

    _validURL = Uri.parse(url).isAbsolute;

    if (!_validURL || u.contains("assets")) {
      return
        Stack(
          children: [Container(
              height: size,
              width: size,
              child:  ClipRRect(

                  borderRadius: BorderRadius.circular(60.0),

                  child:Image.asset("assets/user/user1.png")
              )),
            isVerified==1?  Positioned(child: Container(
              height: 15,
              width: 15,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.pink
              ),
            ), right: 0,bottom: 0,):Container(height: 0,width: 0,)

          ],
        )



      ;}

    return Stack(
      children: [
        Container(
          height: size,
          width: size,
          child:  ClipRRect(

              borderRadius: BorderRadius.circular(60.0),

              child:CachedNetworkImage(
                imageUrl: url,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                placeholder: (context, url) => Functions.profileImageLoadEffect(),
                errorWidget: (context, url, error) => Functions.profileImageErrorEffect(),
              )

          ),
        ),
        isVerified==1?  Positioned(child: Container(
          height: 15,
          width: 15,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Colors.pink
          ),
        ), right: 0,bottom: 0,):Container(height: 0,width: 0,)
      ],
    );
  }



  static Widget showLoader() {
    return Center(
      child: Container(
        height: 40,
        width: 40,
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(mainColor_transp),
        ),
      ),
    );
  }

  static Widget showLoaderBottom() {
    return Center(
      child: Container(
        height: 25,
        width: 25,
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white30),
          strokeWidth: 2,
        ),
      ),
    );
  }

  static Widget showLoaderSmall() {
    return Center(
      child: Container(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white38),
          strokeWidth: 2,
        ),
      ),
    );
  }

  static Widget showLoaderWhite() {
    return Center(
      child: Container(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 2,
        ),
      ),
    );
  }

  static Widget showError(String message) {
    return Center(
      child: Container(
        height: 40,
        width: 40,
        child: Text(message),
      ),
    );
  }

  static Widget profileImageLoadEffect() {
    return Container(
      color: Colors.white38,
      height: 20,
      width: 20,
    );
  }

  static Widget profileImageErrorEffect() {
    return Container();
  }

  static ImageProvider defaultProfileImage() {
    return AssetImage("assets/user/user1.png");
  }

  static Widget noVideoByUser(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: MediaQuery.of(context).size.height / 2,
        width: 40,
        child: Center(
          child: Text(
            "No videos",
            style: TextStyle(color: Colors.white54),
          ),
        ),
      ),
    );
  }

  static String capitalizeFirst(String s) {
    if (s.length > 1)
      return s[0].toUpperCase() + s.substring(1);
    else if (s.length == 1) {
      return s.toUpperCase();
    }
    return s;
  }

  static bool isNullEmptyOrFalse(Object o) =>
      o == null || false == o || "" == o || 0 == o;

  static void showToast(message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static Future<void> showMyDialog(context, String title, String message,
      String primaryText, Function mainFunction,
      {String secondaryText, Function secondary}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[

             Align(
               alignment: Alignment.center,
               child: Container(
                 child: ClipRect(
                   child: new BackdropFilter(
                       filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                       child: new Container(
                           width: MediaQuery.of(context).size.width-150,
                          // height: 180.0,
                           decoration: new BoxDecoration(
                              color: Colors.white10,//black.withOpacity(0.5),
                             borderRadius: BorderRadius.circular(20)
                                  

                           ),

                             child: Column(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 Padding(
                             padding: EdgeInsets.all(28),
                                 child: Column(
                                   children: [
                                     new Text(title,
                                         style: TextStyle(
                                             inherit: false,
                                             fontSize: 16
                                         )),
                                     message!=""?Container(height: 10,):Container(),
                                message != ""?     new Text(message,
                                         style: TextStyle(
                                             inherit: false,
                                             fontSize: 12

                                         )):Container(),
                                    ],
                                 ),
                                 ),
                                 Divider(color: Colors.white60,
                                 thickness: 0.2,),
                                 Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                   children: [

                                     FlatButton(onPressed: mainFunction, child: Text(primaryText,  style: TextStyle(
                                         inherit: false,
                                         fontSize: 15

                                     ))) ,
                                     secondaryText == null ? Container():
                                     FlatButton(onPressed: secondary, child: Text(secondaryText,  style: TextStyle(
                                         inherit: false,
                                         fontSize: 15

                                     )))
                                   ],
                                 ),
                                 Container(height: 10,)


                               ],
                             ),

                       )
                   ),
                 ),
               )

             )


          ],
        );

      },
    );
  }




    static Future<String> showVideoDialog(context,Offset offset, String field0, Function field0Tap , String field1, Function field1Tap ) async {
      return showDialog<String>(
        context: context,
        barrierColor: Colors.transparent,
        useSafeArea: true,
         builder: (BuildContext context) {

          double h =MediaQuery.of(context).size.height;
          double w =MediaQuery.of(context).size.width;
          if(w-offset.dx<232)
            {
               offset =  Offset(offset.dx  - (offset.dx + 232- w) , offset.dy);
            }

          if(h-offset.dy<200)
          {
             offset =  Offset(offset.dx , offset.dy  - (offset.dy + 200- h));
          }

          return  Stack(
            alignment: Alignment.center,
            children: <Widget>[

              Positioned(
                  left: offset.dx,
                  top: offset.dy,
                  child: Container(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                      child: new BackdropFilter(
                        filter: new ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                        child:   new Container(
                           decoration: new BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10)


                          ),

                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 13,right: 13,top: 10,bottom: 10),
                                child: Column(
                                  children: [
                                    GestureDetector(child: Container(

                                        width: 200,
                                        height: 37,
                                        color: Colors.transparent,

                                        child: Row(
                                           children: [
                                             Text(field0,
                                                 style: TextStyle(
                                                     inherit: false,
                                                     fontSize: 16
                                                 ))
                                           ],
                                        )
                                    ),
                                      onTap: field0Tap,
                                    ),



                                    GestureDetector(child: Container(
                                        width: 200,
                                        height: 37,
                                        color: Colors.transparent,
                                        child: Row(
                                          children: [
                                            Text(field1,
                                                style: TextStyle(
                                                    inherit: false,
                                                    fontSize: 16
                                                ))
                                          ],
                                        )
                                    ),
                                      onTap: field1Tap,
                                    )


                                  ],
                                ),
                              ),



                            ],
                          ),

                        ),


                      ),
                    ),
                  )

              )


            ],
          );

        },
      );
    }


















    static Widget backButton(context, {Function function}) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios,
        color: LocalColors.textColorDark,
        size: 20,
      ),
      onPressed: function == null
          ? () {
              Navigator.pop(context);
            }
          : function,
    );
  }

  static Widget backButtonMain(context, {Function function}) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios,
        color: Colors.white60,
        size: 20,
      ),
      onPressed: function == null
          ? () {
              Navigator.pop(context);
            }
          : function,
    );
  }

  static Widget backButton2(context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios,
        color: LocalColors.textColorDark,
        size: 20,
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  static openWebView(String url, Map<String, String> header) async {
    FlutterWebView flutterWebView = new FlutterWebView();

    flutterWebView.launch(url,
        headers: header,
        javaScriptEnabled: true,
        toolbarActions: [
          new ToolbarAction("Close", 1),
        ],
        inlineMediaEnabled: false,
        barColor: Colors.black87,
        tintColor: Colors.white);
    flutterWebView.onToolbarAction.listen((identifier) {
      switch (identifier) {
        case 1:
          flutterWebView.dismiss();
          break;

          break;
      }
    });
    flutterWebView.listenForRedirect("mobile://test.com", true);
  }

  static showSnackBar(_scaffoldKey, message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }



  static String dateToReadableString(DateTime dateTime)
  {
    return timeago.format(dateTime);
  }

  static getRedableNumber(numberToFormat) {
    String _formattedNumber;
    if (numberToFormat is int) {
      _formattedNumber = NumberFormat.compactCurrency(
        decimalDigits: 0,
        symbol:
            '', // if you want to add currency symbol then pass that in this else leave it empty.
      ).format(numberToFormat);

      _formattedNumber =
          _formattedNumber.substring(0, _formattedNumber.length - 1) +
              " " +
              _formattedNumber.substring(
                  _formattedNumber.length - 1, _formattedNumber.length);
    } else
      _formattedNumber = numberToFormat;

    return _formattedNumber;
  }

  static List<Videos> parseVideoList(var data, BuildContext context,{List<Videos> list}) {
    if (list == null) {
      list = [];
    }

    for (int i = 0; i < data.length; i++) {
      var s = data["sound"];
      Sounds sound;
      if (s == null) {
        sound = null;
      } else if (s["id"] == null) {
        sound = null;
      } else {
        sound = Sounds(
            s["id"],
            s["audio_path"],
            s["audio_path"],
            s["sound_name"],
            s["description"],
            s["thum"],
            s["section"],
            s["created"]);
      }

      list.add(Videos(
          data["id"],
          data["video"],
          data["thum"],
          data["fb_id"],
          data["liked"],
          data["user_info"]["first_name"],
          data["user_info"]["last_name"],
          data["user_info"]["profile_pic"],
          data["user_info"]["username"],
          data["user_info"]["verified"],
          data["count"]["like_count"],
          data["count"]["video_comment_count"],
          data["count"]["view"],
          data["description"],
          data["created"],
          sound,
          context
      ));
    }

    return list;
  }
}
