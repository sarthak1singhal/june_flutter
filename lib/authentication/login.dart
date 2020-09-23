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
import 'package:sliding_up_panel/sliding_up_panel.dart';

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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, //top bar color
      statusBarIconBrightness: Brightness.dark, //top bar icons

     ));

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
      statusBarColor: LocalColors.backgroundLight, //top bar color
      statusBarIconBrightness: Brightness.dark, //top bar icons

    ));
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();


  String number = '';

  bool isLoading = false;


  signIn() async{

    if(_formKey.currentState.validate())
    {
      isLoading = true;

      setState(() {

      });
      try{


        var res = await  Functions.unsignPostReq(Variables.loginUrl, jsonEncode({
          "number" : number,

        }));

        var s = jsonDecode(res.body);
        print(s);


        if(s["isError"])
        {
          if(s["message"]!=null){

            Functions.showSnackBar(_scaffoldKey, s["message"].toString());

          }
        }else{


          //SAVE LOGIN DATA HERE
          Navigator.push(context, MaterialPageRoute(builder: (context) =>  Verify()));




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



    }


  }

  String hash = "";





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

                    Text("Welcome", style: TextStyle(fontSize: 32, fontFamily: Variables.fontName, fontWeight: FontWeight.w700),),
                    Text("Back!", style: TextStyle(fontSize: 32, fontFamily: Variables.fontName, fontWeight: FontWeight.w700),),

                    Spacer(),
                    TextFormField(
                      decoration: InputDecoration(

                          labelText: "Mobile number",
                          labelStyle: TextStyle(color: Colors.black54, fontFamily: Variables.fontName),

                          contentPadding: EdgeInsets.only(left: 7, right: 7)
                        //fillColor: Colors.green

                      ),
                      onChanged: (s){
                        number = s;
                      },
                      validator: (s){
                        if(s.isEmpty){
                          return "Enter a mobile number";
                        }
                        if(s.length<9 || s.length>11)
                          return "Enter a valid mobile number";
                        RegExp _numeric = RegExp(r'^-?[0-9]+$');

                        if(!_numeric.hasMatch(s)){
                          return "Enter a valid mobile number";
                        }

                        return null;
                      },

                    ),

                    Spacer()                      ,


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
                              onPressed: (){
                                FocusScope.of(context).requestFocus(new FocusNode());

                                signIn();
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








}
