import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qvid/Functions/LocalColors.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:qvid/authentication/verifyOTP.dart';

class Signup extends StatefulWidget {


  final int screen;
  final String email;

  Signup(this.screen,this.email) ;

  @override

  _MyHomePageState createState() => _MyHomePageState();

}


class _MyHomePageState extends State<Signup> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();

  String s_name = "";
  String username = '';
  String number= '';

  String password = "";
  bool isLoading = false;

  int screen = 0; //0 for email/phone and password. 1 for first name and last name.



  @override
  void initState() {
    super.initState();

  }




  signUp() async {

    if(_formKey.currentState.validate())
    {
      isLoading = true;

      setState(() {

      });
      try{


        var res = await  Functions.unsignPostReq(Variables.sendOTP, jsonEncode({
          "number" : number.trim(),
          "email" : widget.email,
          "full_name" : s_name.trim(),
          "password" : password.trim(),
          //  "password" : password.trim(),


        }));


        print(res.body);

        var s = jsonDecode(res.body);
        print(s);


        if(s["isError"])
        {
          if(s["message"]!=null){

            Functions.showSnackBar(_scaffoldKey, s["message"].toString());

          }

          isLoading = false;
          setState(() {

          });


        }else{

          isLoading = false;
          setState(() {

          });
          var isLoggedIn = await Navigator.push(context, MaterialPageRoute(builder: (context) => VerifyOTP(email:widget.email, password: password,
          f_name: s_name,number: number,hash: s["key"]
          )));


          if(isLoggedIn!=null)
            {
              if(isLoggedIn){
                Navigator.pop(context,true);

                return;
              }
            }



        }









      }catch(e)
      {
        setState(() {
          isLoading = false;

        });
        Functions.showSnackBar(_scaffoldKey, "Some connection error occured");
        var isLoggedIn = await Navigator.push(context, MaterialPageRoute(builder: (context) => VerifyOTP(email:widget.email, password: password,
          f_name: s_name,number: number,
        )));
        debugPrint(e);

      }



    }

  }

  @override
  Widget build(BuildContext context) {

    //MediaQuery.of(context).size.height * .80 < 370 ? ;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar:  PreferredSize(
        child: Container(),
        preferredSize: Size(MediaQuery.of(context).size.width, 30),
      ),
      key: _scaffoldKey,

      body: _body() // This trailing comma makes auto-formatting nicer for build methods.
    );
  }





  _body(){
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
                    height: MediaQuery.of(context).size.height < 550
                        ? 550
                        : MediaQuery.of(context).size.height - 114,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[

Spacer(flex: 1,),

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
                           textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(

                              labelText: "Full Name",
                              labelStyle: TextStyle(color: Colors.black54, fontFamily: Variables.fontName),

                              contentPadding: EdgeInsets.only(left: 7, right: 7)

                          ),

                          onChanged: (s) {
                            s_name = s;
                          },
                          validator: (s) {
                            if (s.isEmpty) {
                              return "Enter a valid name";
                            }

                            if (s.length < 3)
                              return "Enter a valid name";

                            return null;
                          },
                        ),
                        Spacer(),

                         TextFormField(

                           enabled: !isLoading,
                          keyboardType: TextInputType.numberWithOptions(decimal: false,signed: false),
                          decoration: InputDecoration(

                              labelText: "Mobile Number",
                              labelStyle: TextStyle(color: Colors.black54, fontFamily: Variables.fontName),

                              contentPadding: EdgeInsets.only(left: 7, right: 7)
                            //fillColor: Colors.green

                          ),

                          onChanged: (s) {
                            number = s;
                          },
                          validator: (s) {
                            if (s.isEmpty) {

                                return null;
                            }

                             if(s.length<8 || s.length>12 )
                            return "Enter a valid mobile number";
                            RegExp _numeric = RegExp(r'^-?[0-9]+$');

                        if(!_numeric.hasMatch(s)){
                          return "Enter a valid mobile number";
                        }

                        //    String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

                        //    RegExp regExp = new RegExp(p);

                        //   if(!regExp.hasMatch(s))
                          //   return "Enter a valid email address";


                            return null;
                          },
                        ),

                        Spacer(),


                        TextFormField(

                          enabled: !isLoading,
                          obscureText: true,
                          decoration: InputDecoration(

                              labelText: "Password",
                              labelStyle: TextStyle(color: Colors.black54, fontFamily: Variables.fontName),

                              contentPadding: EdgeInsets.only(left: 7, right: 7)
                            //fillColor: Colors.green

                          ),

                          onChanged: (s) {
                            password = s;
                          },
                          validator: (s) {
                            if (s.isEmpty) {
                              return "Enter a valid password";
                            }
                            if (s.length < 8)
                              return "Password length is short";
                            return null;
                          },
                        ),


                        Spacer(),

                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(

                              labelText: "What you would like to be called?",
                              labelStyle: TextStyle(color: Colors.black54, fontFamily: Variables.fontName),

                              contentPadding: EdgeInsets.only(left: 7, right: 7)
                            //fillColor: Colors.green

                          ),

                          onChanged: (s) {
                            username = s;
                          },
                          validator: (s) {


                            return null;
                          },
                        ),


                        Spacer(flex: 2,),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(),
                            Text(
                              "Sign Up", style: TextStyle(
                              fontSize: 27,
                              color: LocalColors.textColorDark,
                              fontWeight: FontWeight.w600,
                              fontFamily: Variables.fontName,
                            ),
                            ),
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
                                            color:
                                            Color.fromRGBO(0, 0, 0, 0.2),
                                            blurRadius: 3.0,
                                            offset: Offset(-1, 1.75))
                                      ],
                                      borderRadius:
                                      BorderRadius.circular(50)),
                                  height: 65,
                                  width: 65,
                                ),
                                isLoading //&& !slideController.isPanelOpen
                                    ? Positioned(
                                  top: 20,
                                  left: 20.2,
                                  child: Container(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                      new AlwaysStoppedAnimation<
                                          Color>(Colors.white),
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
                                      color:
                                      LocalColors.backgroundLight,
                                    ),
                                    onPressed: () {

                                       FocusScope.of(context)
                                          .requestFocus(
                                          new FocusNode());

                                      signUp();
                                    },
                                  ),
                                )
                              ],
                            )
                          ],
                        ),

                        Container(height: 20,),
                        Spacer(flex: 5,),



                        Container(height: 2,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(
                              onTap: (){
                                Functions.openWebView(Variables.privacy_policy, {});
                              },
                              child: Text("Privacy Policy",  style: TextStyle(
                                color: Colors.black38,
                                fontSize: 12,
                                decoration: TextDecoration.underline,

                                fontFamily: Variables.fontName,
                              ),),
                            )
                            ,
                            Text(" and ",  style: TextStyle(
                              color: Colors.black38,
                              fontSize: 12,
                              fontFamily: Variables.fontName,
                            ),)
                            ,GestureDetector(

                              onTap: (){
                                Functions.openWebView(Variables.termsAndConditionUrl, {});
                              },
                              child: Text("T&C",  style: TextStyle(
                                color: Colors.black38,
                                fontSize: 12,    decoration: TextDecoration.underline,

                                fontFamily: Variables.fontName,
                              ),),
                            )
                            ,

                          ],
                        )

                      ],
                    ),
                  ))),
        ],
      ),
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    );
  }




  @override
  void dispose() {

    super.dispose();
  }



}









