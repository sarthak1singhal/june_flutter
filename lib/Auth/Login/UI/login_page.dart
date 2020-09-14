import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:qvid/Auth/login_navigator.dart';
import 'package:qvid/BottomNavigation/Home/following_tab.dart';
import 'package:qvid/Components/continue_button.dart';
import 'package:http/http.dart' as http;

import 'package:qvid/Components/entry_field.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  String comingFromClass;

  LoginPage(this.comingFromClass);
  @override
  Widget build(BuildContext context) {
    return LoginBody(comingFromClass);
  }
}

class LoginBody extends StatefulWidget {
  String comingFromClass;
  LoginBody(this.comingFromClass);

  @override
  _LoginBodyState createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {



  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: transparentColor),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                AppLocalizations.of(context).youWillNeed,
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: secondaryColor),
              ),
              Spacer(),
              isLoading? Container(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(),
              ) : Container(),

              Container(width: 15,)
            ],
          ),
          Spacer(),
          EntryField(
            label: AppLocalizations.of(context).enterPhone,
          ),
          CustomButton(
            onPressed: () =>
                Navigator.pushNamed(context, LoginRoutes.registration),
          ),
          Spacer(flex: 8),
          Text(
            AppLocalizations.of(context).orContinueWith,
            textAlign: TextAlign.center,
          ),
          Spacer(),
          CustomButton(
            icon: Image.asset(
              'assets/icons/ic_fb.png',
              height: 20,
            ),
            text: '   ${AppLocalizations.of(context).facebookAccount}',
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


              switch (result.status) {
                case FacebookLoginStatus.loggedIn:

                  signup(result.accessToken.userId, profile["first_name"], profile["last_name"],
                      "https://graph.facebook.com/"+result.accessToken.userId+"/picture?width=500&width=500",
                    "facebook",
                    "m"
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
          CustomButton(
            icon: Image.asset(
              'assets/icons/ic_ggl.png',
              height: 20,
            ),
            text: '   ${AppLocalizations.of(context).googleAccount}',
            color: secondaryColor,
            textColor: darkColor,
            onPressed: () =>
                Navigator.pushNamed(context, LoginRoutes.socialLogin),
          ),
        ],
      ),
    );





  }

  bool isLoading  = false;

  signup(String id,
      String f_name,
      String l_name,
      String picture,
      String singnup_type, String gender) async{


    try{
      setState(() {
        isLoading = true;
      });

      var res = await  Functions.unsignPostReq(Variables.SignUp, jsonEncode({
        "fb_id": id,
        "first_name" : f_name,
        "last_name" : l_name,
        "profile_pic" : picture,
        "signup_type" : singnup_type,
        "gender" : "m",
        "version": "1",
        "device" : Variables.device,
      }));

      var m = jsonDecode(res.body);

      parseData(m);

    }catch(e){

      print(e);
    }


  }



//  {code: 200, msg: [{fb_id: 3180757235310807, username: Sarthak404876624, action: signup, profile_pic: https://graph.facebook.com/3180757235310807/picture?width=500&width=500, first_name: Sarthak, last_name: Singhal, signup_type: facebook, gender: m, tokon: 15987307172018395818}]}
  parseData(var map) async{


    if(map["code"].toString() == "200" )
      {
        var data = map["msg"][0];
        SharedPreferences preferences = await SharedPreferences.getInstance();

        preferences.setString(Variables.u_idString, data["fb_id"]);
        preferences.setString(Variables.f_nameString, Functions.capitalizeFirst(data["first_name"]));
        preferences.setString(Variables.l_nameString, Functions.capitalizeFirst(data["last_name"]));
        preferences.setString(Variables.u_nameString, data["username"]);
        preferences.setString(Variables.genderString, data["gender"]);
        preferences.setString(Variables.u_picString, data["profile_pic"]);
        preferences.setString(Variables.api_tokenString, data["tokon"]);
        preferences.setString(Variables.content_languageString, data["content_language"]);
        preferences.setBool(Variables.isloginString, true);


        print(data["tokon"]);

        Variables.token = data["tokon"];
        Variables.user_id = data["fb_id"];
        Variables.language = data["content_language"];
        Variables.username= data["username"];
        Variables.user_pic= data["profile_pic"];
        Variables.user_name= Functions.capitalizeFirst(data["first_name"]) +" "+ Functions.capitalizeFirst(data["last_name"]);


        if(widget.comingFromClass=="following") {
          FollowingTabBodyState.closeSheet();
        }
      }

    isLoading = false;
setState(() {

});

  }



}
