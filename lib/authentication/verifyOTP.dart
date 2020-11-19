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
import 'package:shared_preferences/shared_preferences.dart';

class VerifyOTP extends StatefulWidget {

  final String email, number, f_name, password, hash;

  const VerifyOTP({Key key, @required this.email, @required this.number, @required this.f_name, @required this.password, @required this.hash}) : super(key: key);


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<VerifyOTP> {
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


    hash = widget.hash;




  }
  String hash;



  @override
  dispose(){
    _errorController.close();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: LocalColors.backgroundLight, //top bar color
      statusBarIconBrightness: Brightness.dark, //top bar icons
    ));

    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();



  bool isLoading = false;


  verifyOtp() async{

    if(_formKey.currentState.validate())
    {
      isLoading = true;

      setState(() {

      });
      try{


        var res = await  Functions.unsignPostReq(Variables.signup, jsonEncode({

          "otp" : currentText,
          "key" : hash,
          "full_name" : widget.f_name,
          "password" : widget.password,
          "email" : widget.email,
          "number" : widget.number
        }));

        var s = jsonDecode(res.body);

        if(s["isError"])
        {

          if(s["message"]!=null){

              Functions.showSnackBar(_scaffoldKey, s["message"].toString());

            }



        }else{


          SharedPreferences preferences = await SharedPreferences.getInstance();
          if(!Functions.isNullEmptyOrFalse(s["first_name"]))
            {

              preferences.setString(Variables.f_nameString, s["first_name"]);
              Variables.f_name = s["first_name"];
            }     if(!Functions.isNullEmptyOrFalse(s["last_name"]))
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
          } if(!Functions.isNullEmptyOrFalse(s["uid"]))
          {
            preferences.setString(Variables.fbid_String, s["uid"]);
            Variables.fb_id= s["uid"];
          }









          if(!s["isUsername"])
          {
            preferences.setString(Variables.usernameString, s["username"]);
            Variables.username= s["username"];
          }


          Navigator.pop(context, true);

        }




        isLoading = false;
        setState(() {

        });







      }catch(e)
      {
        isLoading = false;
        Functions.showSnackBar(_scaffoldKey, "Some connection error occured");
        setState(() {

        });
        debugPrint(e);

      }



    }


  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LocalColors.backgroundLight,
      appBar: AppBar(

        leading: Functions.backButton(context, function: (){
          Navigator.pop(context,false);
        }),
      ),
      key: _scaffoldKey,

      body: _body(),
    );
  }




  resendOTP() async{
    try{


      var res = await  Functions.unsignPostReq(Variables.sendOTP, jsonEncode({
        "number" : widget.number.trim(),
        "email" : widget.email,
        "full_name" : widget.f_name.trim(),
        "password" : widget.password.trim(),
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

        hash= s["key"];



      }









    }catch(e)
    {
      setState(() {
        isLoading = false;

      });

      debugPrint(e);

    }
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

                    Text("Verify OTP", style: TextStyle(fontSize: 32, color: LocalColors.textColorDark, fontFamily: Variables.fontName, fontWeight: FontWeight.w700),),
                    Container(height: 18,),
                    Text("Check your mail ${widget.email}", style: TextStyle(fontSize: 18,color: LocalColors.textColorLight, fontFamily: Variables.fontName, fontWeight: FontWeight.w400),),

                    Spacer(),
                    PinCodeTextField(
                      obscureText: false,

                      appContext: context,
                      keyboardType: TextInputType.numberWithOptions(decimal: false, signed: false),                      length: 4,
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
                    FlatButton(
                      child:RichText(
                        text: TextSpan(
                          text: "Didn't Receive Mail? "  ,
                          style: TextStyle(
                            color: LocalColors.textColorLight,
                            fontSize: 14,
                            fontFamily: Variables.fontName,
                          ),
                          children: <TextSpan>[
                            TextSpan(text: ' Resend', style: TextStyle(fontFamily: Variables.fontName, color: LocalColors.secondaryColor,
                              fontSize: 15,)),
                          ],
                        ),
                      ),
                      padding: EdgeInsets.only(left: 5, right: 8),
                      onPressed: (){

                        resendOTP();
                        //Navigator.push(context, MaterialPageRoute(builder: (context) =>  Login()));

                      },
                    ),

                    Container(height: 20,),
                    Spacer()                      ,


                    //  Container(height: 50,),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Sign Up", style: TextStyle(
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
