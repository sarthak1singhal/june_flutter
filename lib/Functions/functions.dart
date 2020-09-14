import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
 import 'package:shared_preferences/shared_preferences.dart';

import 'Variables.dart';


class Functions {


  static Future<http.Response> postReq(String secondUrl, String params) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token');

    if(token == null)
    {
      print("SIGN IN");
      return null;
    }
    return http.post(
      Variables.domain + secondUrl,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'token' : token
      },
      body: params,
    );


  }





  static Future<http.Response> getReq(String secondUrl, String params) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token');

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


    print(Variables.base_url + Variables.middle + url);
    print(params);
    return http.post(
      Variables.base_url + Variables.middle + url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: params,
    );
  }



  static Widget showLoader(){
    return Center(child: Container(height: 50, width: 50, child: CircularProgressIndicator(),),);
  }



  static String capitalizeFirst(String s)
  {
    return s;
  }



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







  static Widget backButton(context){
    return
      IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: (){
          Navigator.pop(context);
        },
      );


    /*GestureDetector(

      onTap: (){
        Navigator.pop(context);

      },
      child: Stack(

        children: <Widget>[
          Positioned(
            child: Container(
              height: 40,
              width: 40,
              decoration: new BoxDecoration(
                color: Colors.black12,
                borderRadius: new BorderRadius.all(
                    const Radius.circular(50.0)),
              ),
            ),
            top: 12,
            left: 12,
          ),
          Positioned(
            child: Icon(Icons.clear),
            top: 20,
            left: 20,
          )
        ],
      ),
    );*/
  }



}