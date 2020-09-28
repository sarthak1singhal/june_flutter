import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

import 'package:http/http.dart' as http;
import 'package:qvid/Auth/login_navigator.dart';
import 'package:qvid/Components/continue_button.dart';
import 'package:qvid/Functions/LocalColors.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:qvid/authentication/enterEmail.dart';
import 'package:qvid/authentication/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'enterPassword.dart';
import 'forgotPassword.dart';

class Login extends StatefulWidget {

  final String ScreenPopmessage;

  const Login({Key key, this.ScreenPopmessage}) : super(key: key);


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Login> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void initState(){
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);


    if(widget.ScreenPopmessage != null)
      {

        if(widget.ScreenPopmessage.trim()!="")
          {

            Functions.showSnackBar(_scaffoldKey, widget.ScreenPopmessage);

          }

      }

  }







  @override
  dispose(){

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, //top bar color
      statusBarIconBrightness: Brightness.light, //top bar icons

    ));

    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();


  String number = '', password = "";

  bool isLoading = false;


  signIn() async{

    if(_formKey.currentState.validate())
    {
      isLoading = true;

      setState(() {

      });
      try{


        var res = await  Functions.unsignPostReq(Variables.isUsernameOrEmailExist, jsonEncode({
          "email" : number.trim(),
        //  "password" : password.trim(),


        }));


        print(res.body);

        var s = jsonDecode(res.body);
        print(s);


        if(s["isError"])
        {
          String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

          RegExp regExp = new RegExp(p);

          if(!Functions.isNullEmptyOrFalse(s["email"])) {

            if (regExp.hasMatch(s["email"])){


              var isLoggedIn = await Navigator.push(context, MaterialPageRoute(builder: (context) => Signup(0, s["email"])));

              if(isLoggedIn != null)
                {
                  if(isLoggedIn)
                    {
                      Navigator.pop(context);
                    }
                }

            }
            else if(s["message"]!=null){

              Functions.showSnackBar(_scaffoldKey, s["message"].toString());

            }
          }
        }else{


          var isLoggedIn = await Navigator.push(context, MaterialPageRoute(builder: (context) => EnterPassword(email:s["email"])));

          if(isLoggedIn != null)
          {
            if(isLoggedIn)
            {
              Navigator.pop(context);
            }
          }


        }




        isLoading = false;
        setState(() {

        });







      }catch(e)
    {
      setState(() {
        isLoading = false;

      });
      Functions.showSnackBar(_scaffoldKey, "Some connection error occured");
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











  Widget _body(){
    return   GestureDetector(
      child:    ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          Form(
            key: _formKey,
            child:Padding(
              padding: EdgeInsets.only(left: 26,right: 26,top: 35),
              child: Container(
                //color: Colors.black12,
                height: MediaQuery.of(context).size.height < 500 ? 500 : MediaQuery.of(context).size.height  - 140,
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
//                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[

                    Text("Welcome", style: TextStyle(fontSize: 32, color: LocalColors.textColorDark, fontFamily: Variables.fontName, fontWeight: FontWeight.w700),),
                    Text("Back!", style: TextStyle(fontSize: 32, color: LocalColors.textColorDark, fontFamily: Variables.fontName, fontWeight: FontWeight.w700),),

                    Spacer(),
                    TextFormField(

                      enabled: !isLoading,
                      decoration: InputDecoration(

                          labelText: "Email or username",
                          labelStyle: TextStyle(color: Colors.black54, fontFamily: Variables.fontName),

                          contentPadding: EdgeInsets.only(left: 7, right: 7)
                        //fillColor: Colors.green

                      ),
                      onChanged: (s){
                        number = s;
                      },
                      validator: (s){
                        if(s.isEmpty){
                          return "Enter your email or username";
                        }
                        if(s.trim().length==0){
                          return "Enter correct email or username";
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
*//*
                        if(!_numeric.hasMatch(s)){
                          return "Enter a valid mobile number";
                        }*//*

                        return null;
                      },

                    ),
                    Spacer()                      ,
*/

                    Container(height: 14,),
                    //  Container(height: 50,),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Sign in", style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w600,
                          fontFamily: Variables.fontName,
                        ),
                        ),
                        //Spacer(),
                        Stack(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [LocalColors.secondaryColor,LocalColors.secondaryColorGradient],
                                    stops: [0,0.7],
                                  ),                                    boxShadow: [
                                BoxShadow(
                                    spreadRadius : 1,
                                    color: Color.fromRGBO(0, 0, 0, 0.2),
                                    blurRadius: 3.0,
                                    offset: Offset(-1,1.75)
                                )
                              ],
                                  borderRadius: BorderRadius.circular(50)
                              ),
                              height: 65,width: 65,
                            ),
                            isLoading?

                            Positioned(top: 20, left: 20.2,child: Container(
                              child: CircularProgressIndicator( strokeWidth: 2, valueColor: new AlwaysStoppedAnimation<Color>(Colors.white), ),
                              height: 25,
                              width: 25,
                            ),):


                            Positioned(top: 7,left: 8,child:


                            IconButton(

                              icon: Icon(Icons.arrow_forward, size: 35, color: LocalColors.backgroundLight, ),
                              onPressed: isLoadingFacebook ? null:() {
                                FocusScope.of(context).requestFocus(new FocusNode());

                                signIn();
                              },
                            ),)
                          ],
                        )
                      ],
                    ),

                    Spacer(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[

                        Text("OR", style: TextStyle(color: Colors.black26),),
                      ],
                    ),

                    Spacer(),
                    Container(
                      height: 63,
                      width: MediaQuery.of(context).size.width,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                         ),
                         child: Row(
                          children: <Widget>[
Spacer(),
                           isLoadingFacebook? Container(height: 20, width:20, child: CircularProgressIndicator(
                             strokeWidth: 2, valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                           ),): Image.asset(
                              'assets/icons/ic_fb.png',
                              height: 20,
                            ),
Spacer(),
                            Text('   ${AppLocalizations.of(context).facebookAccount}', style: TextStyle(color: Colors.white),),
                            Spacer()
                          ],
                        ),
                        color: fbColor,
                        onPressed: () async {
                          final facebookLogin = FacebookLogin();
                          final result = await facebookLogin.logIn(['email']);
                          dynamic profile = "";
                          // print(result.accessToken.token);
                          if(result.accessToken.isValid()) {
                            final token = result.accessToken.token;
                            final graphResponse = await http.get(
                                'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,gender,email&access_token=${token}');
                            profile = jsonDecode(graphResponse.body);
                          }


                          print(profile);
                          switch (result.status) {
                            case FacebookLoginStatus.loggedIn:

                              signup(result.accessToken.userId, profile["first_name"], profile["last_name"],
                                  "https://graph.facebook.com/"+result.accessToken.userId+"/picture?width=500&width=500",
                                  "facebook",
                                  profile["gender"], result.accessToken.token, profile['email']

                              );
                              break;
                            case FacebookLoginStatus.cancelledByUser:

                              Functions.showToast("Login cancellled by the user");

                              break;
                            case FacebookLoginStatus.error:
                              Functions.showToast("Some error occured");

                              break;
                          }
                        },
                      ),
                    ),

                    Spacer(flex: 6,),


                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[

                        FlatButton(
                          child:RichText(
                            text: TextSpan(
                              text: 'Dont have an account? ',
                              style: TextStyle(
                                color: LocalColors.textColorDark,
                                fontSize: 14,
                                fontFamily: Variables.fontName,
                              ),
                              children: <TextSpan>[
                                TextSpan(text: ' Sign Up.', style: TextStyle(fontFamily: Variables.fontName, color: LocalColors.secondaryColor,
                                  fontSize: 16,)),
                              ],
                            ),
                          ),
                          padding: EdgeInsets.only(left: 5, right: 8),
                          onPressed: () async{
                            var isLoggedIn = await Navigator.push(context, MaterialPageRoute(builder: (context) =>  EnterEmail( )));
                            if(isLoggedIn != null)
                            {
                              if(isLoggedIn)
                              {
                                Navigator.pop(context);
                              }
                            }
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
      )
      ,
      onTap: (){
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    );
  }


  bool isLoadingFacebook = false;


  signup(String id,
      String f_name,
      String l_name,
      String picture,
      String singnup_type, String gender, String access_token, String em) async{


    try{
      setState(() {
        isLoadingFacebook = true;
      });

      var res = await  Functions.unsignPostReq(Variables.login_fb, jsonEncode({
        "fb_id": id,
        "f_name" : f_name,
        "l_name" : l_name,
        "profile_pic" : picture,
        "signup_type" : singnup_type,
        "gender" : "m",
        "version": "1",
        "device" : Variables.device,
        "email": em,
        "token": access_token
      }));

      var m = jsonDecode(res.body);
      print(m);
      setState(() {
        isLoadingFacebook = false;
      });
      parseData(m);

    }catch(e){
      setState(() {
        isLoadingFacebook = false;
      });
      print(e);
    }


  }



//  {code: 200, msg: [{fb_id: 3180757235310807, username: Sarthak404876624, action: signup, profile_pic: https://graph.facebook.com/3180757235310807/picture?width=500&width=500, first_name: Sarthak, last_name: Singhal, signup_type: facebook, gender: m, tokon: 15987307172018395818}]}
  parseData(var data) async{

    if(data["isError"])
      {
        try{
          Functions.showSnackBar(_scaffoldKey, data["message"]);

        }catch(e){}
        return;
      }else
    //if(map["code"].toString() == "200" )
    {
       SharedPreferences preferences = await SharedPreferences.getInstance();

      preferences.setString(Variables.fbid_String, data["uid"]);
      preferences.setString(Variables.f_nameString, Functions.capitalizeFirst(data["first_name"]));
      preferences.setString(Variables.l_nameString, Functions.capitalizeFirst(data["last_name"]));
      preferences.setString(Variables.username, data["username"]);
      //preferences.setString(Variables.genderString, data["gender"]);
      preferences.setString(Variables.picString, data["profile_pic"]);
      preferences.setString(Variables.tokenString, data["token"]);
      preferences.setString(Variables.refreshTokenString, data["refresh"]);
      preferences.setString(Variables.content_languageString, data["content_language"]);


      Variables.token = data["token"];
      Variables.refreshToken = data["refresh"];
      Variables.fb_id = data["uid"];
      Variables.language = data["content_language"];
      Variables.username= data["username"];
      Variables.user_pic= data["profile_pic"];
      Variables.f_name= Functions.capitalizeFirst(data["first_name"]) ;
      Variables.l_name= Functions.capitalizeFirst(data["last_name"]);


      Navigator.pop(context, true);
    }

  }






}
