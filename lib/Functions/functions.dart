import 'dart:convert';
import 'dart:io';

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
import 'Videos.dart';


class Functions {


  static Future<http.Response> postReq(String secondUrl, String params, BuildContext context, {Map<String,String> urlParams, bool isIdChange}) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    Variables.token = prefs.getString(Variables.tokenString);
    Variables.refreshToken = prefs.getString(Variables.refreshTokenString);

    print(Variables.token);
    if(isNullEmptyOrFalse(Variables.token))
    {

      var isLoggedIn = await Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
      print("SIGN IN");
      print(Variables.token);
      if( isIdChange )
        {
          var m = jsonDecode(params);
          m["fb_id"] = Variables.fb_id;
          params = jsonEncode(m);
        }
     // return null;
    }

    debugPrint(secondUrl);

    print("KAWASAKI");


    var res = await http.post(
       secondUrl,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'token' : Variables.token,
        'refresh_token' : Variables.refreshToken
      },
      body: params,
    );
    print("KADLKDNSLKAN");

    print(res.body);


    if(res.statusCode == 403)
    {
      Navigator.of(context).popUntil(ModalRoute.withName('/'));

      //  Navigator.pop(context);

      Navigator.push(context, MaterialPageRoute(builder: (context) =>  Login()));

      prefs.setString(Variables.tokenString, "");
      prefs.setString(Variables.refreshTokenString, "");
      Variables.refreshToken = "";
      Variables.token= "";

      return null;
    }



    var l = res.headers["set-cookie"].split("HttpOnly,");
    for(int i= 0; i< l.length; i++)
    {


      if(l[i].split("; ")[0].contains("access_token=")) {

        prefs.setString(Variables.tokenString, l[i].split("; ")[0].replaceAll("access_token=", ""));
        Variables.token = l[i].split("; ")[0].replaceAll("access_token=", "");


      }
      if(l[i].split("; ")[0].contains("refresh_token=")) {

        prefs.setString(Variables.refreshTokenString, l[i].split("; ")[0].replaceAll("refresh_token=", ""));
        Variables.refreshToken = l[i].split("; ")[0].replaceAll("refresh_token=", "");


      }


    }




    return res;


  }





  static Future<http.Response> getReq(String secondUrl, String params) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString(Variables.tokenString);

    if(token == null)
    {
      print("SIGN IN");
      return null;
    }
    return http.get(
      Variables.domain + secondUrl,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'token' : token
      },
    );


  }






  static Future<http.Response> unsignPostReq(String url, String params) async{


    print(Variables.base_url + url);
    print(params);
    var res= await http.post(
      Variables.base_url + url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: params,
    );
    debugPrint(res.body);
    return res;
  }





  static Widget showProfileImage(String url){

    bool _validURL = Uri.parse(url).isAbsolute;

    print(url);
    if(!_validURL){
      url = Variables.base_url + "local/?p=" +url;

//      return Image.asset("assets/user/user1.png");
    }

 _validURL = Uri.parse(url).isAbsolute;

    if(!_validURL){

      return Image.asset("assets/user/user1.png");
    }

    return CachedNetworkImage(
      imageUrl:   url,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(40)),

          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover, ),
        ),
      ),
      placeholder: (context, url) => Functions.profileImageLoadEffect(),
      errorWidget: (context, url, error) => Functions.profileImageErrorEffect(),
    );

  }



  static Widget showLoader(){
    return Center(child: Container(height: 40, width: 40, child: CircularProgressIndicator(
      valueColor: new AlwaysStoppedAnimation<Color>(mainColor_transp),

    ),),);
  }

  static Widget showLoaderBottom(){
    return Center(child: Container(height: 25, width: 25, child: CircularProgressIndicator(
      valueColor: new AlwaysStoppedAnimation<Color>(Colors.white30),
      strokeWidth: 2,

    ),),);
  }

  static Widget showLoaderSmall(){
    return Center(child: Container(height: 20, width: 20, child: CircularProgressIndicator(
      valueColor: new AlwaysStoppedAnimation<Color>(Colors.white38),
      strokeWidth: 2,

    ),),);
  }
  static Widget showLoaderWhite(){
    return Center(child: Container(height: 20, width: 20, child: CircularProgressIndicator(
      valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
      strokeWidth: 2,

    ),),);
  }



  static Widget showError(String message){
    return Center(child: Container(height: 40, width: 40, child: Text(message),),);
  }


  static Widget profileImageLoadEffect(){
    return Container(color: Colors.white38, height: 20, width: 20,);
  }

  static Widget profileImageErrorEffect(){
    return Container();
  }


  static ImageProvider defaultProfileImage(){
    return AssetImage("assets/user/user1.png");
  }



  static Widget noVideoByUser(BuildContext context){
    return SliverToBoxAdapter(
      child: Container(
        height: MediaQuery.of(context).size.height/2,
        width: 40,
        child: Center(
          child: Text("No videos", style: TextStyle(color: Colors.white54),),
        ),
      ),
    );
  }


  static   String capitalizeFirst(String s) {
    if(s.length>1)
      return s[0].toUpperCase() + s.substring(1);

    else if(s.length == 1)
    {
      return s.toUpperCase();
    }
    return s;
  }


  static bool isNullEmptyOrFalse(Object o) =>
      o == null || false == o || "" == o || 0==o;


  static void showToast(message){
     Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }


  static Future<void> showMyDialog(context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This is a demo alert dialog.'),
                Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }




  static Widget backButton(context, {Function function}){
    return
      IconButton(
        icon: Icon(Icons.arrow_back_ios,color: LocalColors.textColorDark,  size: 20,),
        onPressed: function == null ? (){
          Navigator.pop(context);
        } : function,
      );
  }
  static Widget backButtonMain(context, {Function function}){
    return
      IconButton(
        icon: Icon(Icons.arrow_back_ios,color: Colors.white60,  size: 20,),
        onPressed: function == null ? (){
          Navigator.pop(context);
        } : function,
      );
  }

  static Widget backButton2(context){
    return
      IconButton(
        icon: Icon(Icons.arrow_back_ios,color: LocalColors.textColorDark,  size: 20,),
        onPressed: (){
          Navigator.pop(context);
        },
      );
  }



  static openWebView(String url,Map<String, String> header) async{
    FlutterWebView flutterWebView = new FlutterWebView();


    flutterWebView.launch(

        url,
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



  static showSnackBar(_scaffoldKey, message){
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }


  static getRedableNumber(numberToFormat)
  {
    String _formattedNumber;
    if (numberToFormat is int) {
      _formattedNumber = NumberFormat.compactCurrency(
        decimalDigits: 0,
        symbol: '', // if you want to add currency symbol then pass that in this else leave it empty.
      ).format(numberToFormat);

      _formattedNumber = _formattedNumber.substring(0, _formattedNumber.length-1) +" "+
          _formattedNumber.substring(_formattedNumber.length-1, _formattedNumber.length);

    }
    else
      _formattedNumber = numberToFormat;

    return _formattedNumber;
  }






  static  List<Videos> parseVideoList(var data, {List<Videos> list}){


    if(list == null)
      {
        list = [];
      }

    for(int i =0; i<data.length; i++)
    {
      var s = data["sound"];
      Sounds sound ;
      if(s==null)
      {
        sound = null;
      }
      else if(s["id"] == null)
      {
        sound = null;
      }else{
        sound = Sounds(s["id"] , s["audio_path"] , s["audio_path"], s["sound_name"], s["description"], s["thum"], s["section"], s["created"]);

      }

      list.add(Videos(data["id"], data["video"], data["thum"], data["fb_id"], data["liked"], data["user_info"]["first_name"]
          , data["user_info"]["last_name"], data["user_info"]["profile_pic"], data["user_info"]["username"],
          data["user_info"]["verified"], data["count"]["like_count"], data["count"]["video_comment_count"],
          data["count"]["view"],data["description"], data["created"], sound));
    }




    return list;

  }






}