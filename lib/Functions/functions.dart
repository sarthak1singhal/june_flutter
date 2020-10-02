import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_web_view/flutter_web_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:qvid/Functions/LocalColors.dart';
import 'package:qvid/authentication/login.dart';
 import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:qvid/Theme/colors.dart';

import 'Variables.dart';
import 'Videos.dart';


class Functions {


  static Future<http.Response> postReq(String secondUrl, String params, BuildContext context, {Map<String,String> urlParams}) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    Variables.token = prefs.getString(Variables.tokenString);
    Variables.refreshToken = prefs.getString(Variables.refreshTokenString);

    print(Variables.token);
    if(isNullEmptyOrFalse(Variables.token))
    {

      var isLoggedIn = await Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
      print("SIGN IN");
      print(Variables.token);
     // return null;
    }

    print(secondUrl);
     var res = await http.post(
       secondUrl,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'token' : Variables.token,
        'refresh_token' : Variables.refreshToken
      },
      body: params,
    );


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


    print(res.body);


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






  static Future<http.Response> unsignPostReq(String url, String params) {


    print(Variables.base_url + url);
    print(params);
    return http.post(
      Variables.base_url + url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: params,
    );
  }



  static Widget showLoader(){
    return Center(child: Container(height: 40, width: 40, child: CircularProgressIndicator(
      valueColor: new AlwaysStoppedAnimation<Color>(mainColor_transp),

    ),),);
  }

  static Widget showLoaderBottom(){
    return Center(child: Container(height: 20, width: 20, child: CircularProgressIndicator(
      valueColor: new AlwaysStoppedAnimation<Color>(Colors.white30),
      strokeWidth: 2,

    ),),);
  }




  static Widget showError(String message){
    return Center(child: Container(height: 40, width: 40, child: Text(message),),);
  }
  static Widget profileImageLoadEffect(){
    return Container(color: Colors.white, height: 20, width: 20,);
  }
 static Widget profileImageErrorEffect(){
    return Container();
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







  static Widget backButton(context, {Function function}){
    return
      IconButton(
        icon: Icon(Icons.arrow_back_ios,color: LocalColors.textColorDark,  size: 20,),
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






  static  List<Videos> parseVideoList(var data, List<Videos> list){



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

      list.add(Videos(data["id"], data["video"], data["thum"], data["fb_id"], data["user_info"]["first_name"]
          , data["user_info"]["last_name"], data["user_info"]["profile_pic"], data["user_info"]["username"],
          data["user_info"]["verified"], data["count"]["like_count"], data["count"]["video_comment_count"],
          data["description"], data["created"], sound));
    }




    return list;

  }






}