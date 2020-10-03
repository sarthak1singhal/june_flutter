import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qvid/BottomNavigation/MyProfile/edit_profile.dart';
   import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qvid/Theme/colors.dart';


class Settings extends StatefulWidget {


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Settings > {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,

        leading: Functions.backButtonMain(context),
        elevation: 0,
        title: Text("Settings", style: TextStyle(fontFamily: Variables.fontName),),
      ),
      key: _scaffoldKey,

      body: ListView(


        children: <Widget>[
          ListTile(
            title: Text("Edit Profile", style: TextStyle(fontFamily: Variables.fontName, color: Colors.white),),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfile()),
              );
            },

          ),
          ListTile(
            title: Text("Privacy Policy", style: TextStyle(fontFamily: Variables.fontName, color: Colors.white)),
            onTap: (){
              Functions.openWebView(Variables.privacy_policy, {});
            },

          ),
          ListTile(
            title: Text("Terms and Conditions", style: TextStyle(fontFamily: Variables.fontName, color: Colors.white)),
            onTap: (){
              Functions.openWebView(Variables.termsAndConditionUrl, {});
            },

          ),    ListTile(
            title: Text("Logout", style: TextStyle(fontFamily: Variables.fontName, color: Colors.white)),
            onTap: (){

             },

          ),

        ],

      ),

    );
  }
}
