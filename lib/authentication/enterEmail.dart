import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:qvid/Functions/LocalColors.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:qvid/authentication/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'enterPassword.dart';
import 'forgotPassword.dart';
import 'login.dart';

class EnterEmail extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<EnterEmail> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, //top bar color
      statusBarIconBrightness: Brightness.dark, //top bar icons
    ));
  }

  @override
  dispose() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, //top bar color
      statusBarIconBrightness: Brightness.light, //top bar icons
    ));

    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  String number = '', password = "";

  bool isLoading = false;

  signIn() async {
    if (_formKey.currentState.validate()) {
      isLoading = true;

      setState(() {});
      try {
        var res = await Functions.unsignPostReq(
            Variables.checkEmailExist,
            jsonEncode({
              "email": number.trim(),
              //  "password" : password.trim(),
            }));

        print(res.body);

        var s = jsonDecode(res.body);
        print(s);

        if (s["isError"]) {
          if (s["code"] != null) {
            if(s["code"] == 0)
              {
                Functions.showSnackBar(_scaffoldKey, "Enter an email address");
              }
            else if(s["code"] == 1)
            {
              Functions.showSnackBar(_scaffoldKey, "Invalid Email address");
            }else if(s["code"] == 2)
            {
              Functions.showSnackBar(_scaffoldKey, "Email already registered");
            }
            //Functions.showSnackBar(_scaffoldKey, s["message"].toString());
          }
        } else {

          var isLoggedIn = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Signup(0,number)));

          if(isLoggedIn !=null)
            {
              if(isLoggedIn)
                {
                  Navigator.pop(context, true);
                }
            }

        }

        isLoading = false;
        setState(() {});
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        Functions.showSnackBar(_scaffoldKey, "Some connection error occured");

        var isLoggedIn = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Signup(0,number)));
        debugPrint(e);
      }
    }
  }

  String hash = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LocalColors.backgroundLight,
      appBar: AppBar(
        leading: Functions.backButton(context),
      ),
      key: _scaffoldKey,
      body: _body(),
    );
  }

  Widget _body() {
    return GestureDetector(
      child: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.only(left: 26, right: 26, top: 35),
              child: Container(
                //color: Colors.black12,
                height: MediaQuery.of(context).size.height < 500
                    ? 500
                    : MediaQuery.of(context).size.height - 140,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
//                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Create",
                      style: TextStyle(
                          fontSize: 32,
                          color: LocalColors.textColorDark,
                          fontFamily: Variables.fontName,
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      "Account",
                      style: TextStyle(
                          fontSize: 32,
                          color: LocalColors.textColorDark,
                          fontFamily: Variables.fontName,
                          fontWeight: FontWeight.w700),
                    ),

                    Spacer(),
                    TextFormField(
                      enabled: !isLoading,
                      decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(
                              color: Colors.black54,
                              fontFamily: Variables.fontName),
                          contentPadding: EdgeInsets.only(left: 7, right: 7)
                          //fillColor: Colors.green

                          ),
                      onChanged: (s) {
                        number = s;
                      },
                      validator: (s) {
                        if (s.isEmpty) {
                          return "Enter your email";
                        }
                        String p =
                            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

                        RegExp regExp = new RegExp(p);

                        if (!regExp.hasMatch(s)) {
                          return "Enter correct email";
                        }
                        //if(s.length<9 || s.length>11)
                        //return "Enter a valid mobile number";
                        //RegExp _numeric = RegExp(r'^-?[0-9]+$');
/*
                        if(!_numeric.hasMatch(s)){
                          return "Enter a valid mobile number";
                        }*/

                        return null;
                      },
                    ),
                    Spacer(),
                    /*         TextFormField(
                      decoration: InputDecoration(

                          labelText: "Password",
                          labelStyle: TextStyle(color: Colors.black54, fontFamily: Variables.fontName),

                          contentPadding: EdgeInsets.only(left: 7, right: 7)
                        //fillColor: Colors.green

                      ),
                      onChanged: (s){
                        password = s;
                      },
                      validator: (s){
                        if(s.isEmpty){
                          return "Enter password";
                        }
                        if(s.trim().length<8){
                          return "Enter correct password";
                        }
                        //if(s.length<9 || s.length>11)
                        //return "Enter a valid mobile number";
                        //RegExp _numeric = RegExp(r'^-?[0-9]+$');
*/ /*
                        if(!_numeric.hasMatch(s)){
                          return "Enter a valid mobile number";
                        }*/ /*

                        return null;
                      },

                    ),
                    Spacer()                      ,
*/

                    Container(
                      height: 14,
                    ),
                    //  Container(height: 50,),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[

                         Spacer(),
                        Stack(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      LocalColors.secondaryColor,
                                      LocalColors.secondaryColorGradient
                                    ],
                                    stops: [0, 0.7],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                        spreadRadius: 1,
                                        color: Color.fromRGBO(0, 0, 0, 0.2),
                                        blurRadius: 3.0,
                                        offset: Offset(-1, 1.75))
                                  ],
                                  borderRadius: BorderRadius.circular(50)),
                              height: 65,
                              width: 65,
                            ),
                            isLoading
                                ? Positioned(
                                    top: 20,
                                    left: 20.2,
                                    child: Container(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                      height: 25,
                                      width: 25,
                                    ),
                                  )
                                : Positioned(
                                    top: 7,
                                    left: 8,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.arrow_forward,
                                        size: 35,
                                        color: LocalColors.backgroundLight,
                                      ),
                                      onPressed: () {
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());

                                        signIn();
                                      },
                                    ),
                                  )
                          ],
                        )
                      ],
                    ),

                    Spacer(
                      flex: 6,
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FlatButton(
                          child: RichText(
                            text: TextSpan(
                              text: 'Already have an account? ',
                              style: TextStyle(
                                color: LocalColors.textColorDark,
                                fontSize: 14,
                                fontFamily: Variables.fontName,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: ' Log In.',
                                    style: TextStyle(
                                      fontFamily: Variables.fontName,
                                      color: LocalColors.secondaryColor,
                                      fontSize: 16,
                                    )),
                              ],
                            ),
                          ),
                          padding: EdgeInsets.only(left: 5, right: 8),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    );
  }
}
