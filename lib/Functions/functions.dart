import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_web_view/flutter_web_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:qvid/Functions/LocalColors.dart';
import 'package:qvid/authentication/login.dart';
 import 'package:shared_preferences/shared_preferences.dart';

import 'Variables.dart';


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
  //    print(Variables.token);
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
    return Center(child: Container(height: 50, width: 50, child: CircularProgressIndicator(),),);
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






}