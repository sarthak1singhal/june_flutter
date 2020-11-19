import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:qvid/BottomNavigation/MyProfile/edit_profile.dart';
   import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Settings/ChangePassword.dart';
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
      backgroundColor: bottomNavColor,
      appBar: AppBar(
        backgroundColor: bottomNavColor,

        leading: Functions.backButtonMain(context),
        elevation: 0,
        title: Text("Settings", style: TextStyle(fontFamily: Variables.fontName),),
      ),
      key: _scaffoldKey,

      body: ListView(


        physics: BouncingScrollPhysics(),
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



          Functions.isNullEmptyOrFalse(Variables.signupType) ?Container():  Variables.signupType != "facebook"? ListTile(
            title: Text("Change Password", style: TextStyle(fontFamily: Variables.fontName, color: Colors.white),),
            onTap: (){
              Navigator.push(context,MaterialPageRoute(builder: (context) => ChangePassword()));
            },
          ):Container(),



          ListTile(
            title: Text("Privacy Policy", style: TextStyle(fontFamily: Variables.fontName, color: Colors.white)),
            onTap: (){
              Functions.openWebView(Variables.privacy_policy, {});
            },),



          ListTile(
            title: Text("Terms and Conditions", style: TextStyle(fontFamily: Variables.fontName, color: Colors.white)),
            onTap: (){
              Functions.openWebView(Variables.termsAndConditionUrl, {});
            },),






          ListTile(
            title: Text("Logout", style: TextStyle(fontFamily: Variables.fontName, color: Colors.white)),
            onTap: () async{


             Functions.showMyDialog(context, "Do you want to logout of June?", "", "Yes", () async{
               Variables.refreshToken = "";
               Variables.token = "";
               SharedPreferences pref = await SharedPreferences.getInstance();
               pref.setString(Variables.tokenString, "");
               pref.setString(Variables.refreshTokenString, "");
               pref.setString(Variables.fbid_String, "");
               Navigator.pop(context);
               Navigator.pop(context);

             }, secondary: (){
               Navigator.pop(context);

             }, secondaryText: "Cancel");


            },

          ),

        ],

      ),

    );
  }
}
