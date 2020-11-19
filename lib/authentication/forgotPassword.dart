import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:qvid/Functions/LocalColors.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Verify extends StatefulWidget {

  final String usernameOrEmail;
    String hashKey;

    Verify({Key key, this.usernameOrEmail, this.hashKey}) : super(key: key);


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Verify> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void initState(){
    super.initState();
    _errorController = StreamController<ErrorAnimationType>();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, //top bar color
      statusBarIconBrightness: Brightness.dark, //top bar icons

    ));

  }




  @override
  dispose(){
    _errorController.close();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: LocalColors.transparent, //top bar color
      statusBarIconBrightness: Brightness.light, //top bar icons

    ));

    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();



  bool isLoading = false;


  verifyOtp() async{

    if(attempts>=5)
      {
        Functions.showSnackBar(_scaffoldKey, "Finished with attempts, resend OTP instead.");

        return;
      }
    if(_formKey.currentState.validate())
    {
      isLoading = true;

      setState(() {

      });
      try{


        var res = await  Functions.unsignPostReq(Variables.forgortPasswordLogin, jsonEncode({

          "otp" : currentText,
          "email": widget.usernameOrEmail,
          "key" : widget.hashKey

        }));

        var s = jsonDecode(res.body);

        if(s["isError"])
        {


          attempts ++ ;

          if(!Functions.isNullEmptyOrFalse(s["message"])) {

              Functions.showSnackBar(_scaffoldKey, s["message"].toString());

           }




        }else{







          SharedPreferences preferences = await SharedPreferences.getInstance();
          if(!Functions.isNullEmptyOrFalse(s["first_name"]))
          {
            preferences.setString(Variables.f_nameString, s["first_name"]);
            Variables.f_name = s["first_name"];
          }
          if(!Functions.isNullEmptyOrFalse(s["last_name"]))
          {
            preferences.setString(Variables.l_nameString, s["last_name"]);
            Variables.l_name = s["last_name"];
          }
          if(!Functions.isNullEmptyOrFalse(s["email"]))
          {
            preferences.setString(Variables.emailString, s["email"]);
            Variables.email= s["email"];
          }
          if(!Functions.isNullEmptyOrFalse(s["token"]))
          {
            preferences.setString(Variables.tokenString, s["token"]);
            Variables.token= s["token"];
          }
          if(!Functions.isNullEmptyOrFalse(s["refresh"]))
          {
            preferences.setString(Variables.refreshTokenString, s["refresh"]);
            Variables.refreshToken= s["refresh"];
          }
          if(!Functions.isNullEmptyOrFalse(s["uid"]))
          {
            preferences.setString(Variables.fbid_String, s["uid"]);
            Variables.fb_id= s["uid"];
          }
          if(!s["isUsername"])
          {
            preferences.setString(Variables.usernameString, s["username"]);
            Variables.username= s["username"];
          }



          Navigator.pop(context);
          Navigator.pop(context);




        }




        isLoading = false;
        setState(() {

        });







      }catch(e)
      {
        debugPrint(e);
        isLoading = false;
        Functions.showSnackBar(_scaffoldKey, "Some connection error occured");
        setState(() {

        });
      }


      setState(() {
        isLoading = false;
      });



    }


  }

  String hash = "";



  bool isResending = false;

  resendOtp() async{
    if(isResending) return;

    setState(() {
      isResending = true;
    });
    try{

      var res =  await Functions.unsignPostReq(Variables.forgortPasswordSendOtp, jsonEncode({
        "email" : widget.usernameOrEmail.trim()

      }));

      var s = jsonDecode(res.body);
      print(s);


      if(s["isError"]) {

        if(!Functions.isNullEmptyOrFalse(s["message"]))
        {
          Functions.showSnackBar(_scaffoldKey, s["message"]);
        }

        setState(() {
          isResending  = false;
        });

        return;

      }

      attempts = 0;

      widget.hashKey = s["key"];



      setState(() {
        isResending  = false;
      });

    }catch(e){
      setState(() {
        isResending  = false;
      });
    }


    setState(() {
      isResending = false;
    });

  }


  @override
  Widget build(BuildContext context) {
       return Scaffold(
      backgroundColor: LocalColors.backgroundLight,
      appBar: PreferredSize(
        child: Container(

        ),
        preferredSize: Size(MediaQuery.of(context).size.width, 30),
      ),
      key: _scaffoldKey,

      body: _body(),
    );
  }





  int attempts = 0;






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

                    Text("Forgot Password?", style: TextStyle(fontSize: 32, color: LocalColors.textColorDark, fontFamily: Variables.fontName, fontWeight: FontWeight.w600),),
                    Container(height: 4,),
                    Text("Check your mail", style: TextStyle(fontSize: 20, fontFamily: Variables.fontName, fontWeight: FontWeight.w500, color: LocalColors.textColorDark),),

                    Spacer(),
                    PinCodeTextField(
                      obscureText: false,

                      appContext: context,
                      keyboardType: TextInputType.numberWithOptions(decimal: false, signed: false),
                      length: 4,
                       animationType: AnimationType.fade,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.underline,
                        fieldHeight: 50,
                        fieldWidth: 40,
                        activeFillColor: Colors.white,
                      ),
                      animationDuration: Duration(milliseconds: 200),
                      backgroundColor: Colors.white,
                      enableActiveFill: false,

                      errorAnimationController: _errorController,
                      controller: textEditingController,
                      onCompleted: (v) {

                        verifyOtp();
                        //  print(textEditingController.text);
                      },
                      onChanged: (value) {
                        //print(value);

                        if(!isOtpRight)
                          setState(() {
                            isOtpRight = true;
                          });

                        currentText = value;

                      },
                      beforeTextPaste: (text) {
                        // print("Allowing to paste $text");
                        return true;
                      },
                    ),

                    Spacer()                      ,
                    RichText(
                      text: TextSpan(
                        text: attempts>1 ?"Didn't Receive Mail? Check your spam folder \n":"Didn't Receive Mail? "   ,
                        style: TextStyle(
                          color: LocalColors.textColorLight,
                          fontSize: 14,
                          fontFamily: Variables.fontName,
                        ),
                        children: <TextSpan>[

                          isResending? TextSpan(text: 'Resending OTP\n', style: TextStyle(fontFamily: Variables.fontName, color: LocalColors.secondaryColor.withOpacity(0.9),
                           fontSize: 15, ),           
                         ):TextSpan(text: 'Resend\n', style: TextStyle(fontFamily: Variables.fontName, color: LocalColors.secondaryColor,
                            fontSize: 15, ),           recognizer: new TapGestureRecognizer()..onTap = () {
                            resendOtp();
                          },
                          ),
                          attempts>2 ?TextSpan(text: (5-attempts).toString() + " attempts left",  style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 14,
                            fontFamily: Variables.fontName,
                          ), ):TextSpan(text:  "",  style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 14,
                            fontFamily: Variables.fontName,
                          ), )

                        ],
                      ),
                    ),

                    Container(height: 20,),
                                   Spacer()                      ,


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
                              onPressed: (){
                                FocusScope.of(context).requestFocus(new FocusNode());

                                verifyOtp();
                              },
                            ),)
                          ],
                        )
                      ],
                    ),

                    Spacer(flex: 6,),




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

  String currentText = "";

  bool isVerifyingOtp = false;
  bool isOtpRight = true;

  StreamController<ErrorAnimationType> _errorController;
  TextEditingController textEditingController = TextEditingController();






  String errorText = "Invalid OTP";

}
