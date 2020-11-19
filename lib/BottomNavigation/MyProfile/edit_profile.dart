import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qvid/Components/entry_field.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:intl/intl.dart';

import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Routes/routes.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as Im;
import 'dart:math' as Math;
class EditProfile extends StatefulWidget {


  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {








  bool isLoadingForms = false;

  bool validatingUsername  = false;

  String username= "", bio= "", gender= "", full_name= "", phoneNumber = "";
  String dob = "";  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  saveData() async
  {
    if(username.trim() == "")
      {
        setState(() {
          usernameErrorMessage = "Enter a username";
          validatingUsername = false;
        });
        return;
       }

    //print(username)
    if(usernameErrorMessage.toLowerCase() == "username available" || username == Variables.username){

        setState(() {
          isLoadingForms = true;
        });
        try{


          print(username);
          Functions fx = Functions();

          var res = await fx.postReq(Variables.edit_profile, jsonEncode({
            "username"  : username.trim(),
            "gender" : gender.trim(),
            "bio" : bio.trim(),
            "phoneNumber"  :phoneNumber.trim(),
             "full_name": full_name.trim(),
            "dob" : dob
          }), context);

          var r = jsonDecode(res.body);

          if(r["isError"])
            {

              if(!Functions.isNullEmptyOrFalse(r["msg"]))
                {
                  Functions.showSnackBar(_scaffoldKey, r["msg"]);
                }
            }else{

            if(!Functions.isNullEmptyOrFalse(r["msg"]))
              {
                r = r["msg"];
                SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                if(!Functions.isNullEmptyOrFalse(r["username"]))
                {
                    sharedPreferences.setString(Variables.usernameString, r["username"]);
                    Variables.username = r["username"];
                }
                if(!Functions.isNullEmptyOrFalse(r["first_name"]))
                {
                  sharedPreferences.setString(Variables.f_nameString, r["first_name"]);
                  Variables.f_name= r["first_name"];
                }
                if(!Functions.isNullEmptyOrFalse(r["last_name"]))
                {
                  sharedPreferences.setString(Variables.l_nameString, r["last_name"]);
                  Variables.l_name = r["last_name"];
                }
                if(!Functions.isNullEmptyOrFalse(r["verified"]))
                {
                  sharedPreferences.setInt(Variables.verifiedString, r["verified"]);
                  Variables.isVerified = r["verified"];
                }

                if(!Functions.isNullEmptyOrFalse(r["gender"]))
                {
                  sharedPreferences.setString(Variables.genderString, r["gender"]);
                  Variables.gender = r["gender"];
                }

                if(!Functions.isNullEmptyOrFalse(r["bio"]))
                {
                  sharedPreferences.setString(Variables.bioString, r["bio"]);
                  Variables.bio= r["bio"];
                }
                if(!Functions.isNullEmptyOrFalse(r["phoneNumber"]))
                {
                  sharedPreferences.setString(Variables.phoneNumberString, r["phoneNumber"]);
                  Variables.phoneNumber = r["phoneNumber"];
                }if(!Functions.isNullEmptyOrFalse(r["dob"]))
                {
                  sharedPreferences.setString(Variables.dobString, r["dob"]);
                  Variables.dob= r["dob"];
                }
              }
            Navigator.pop(context);
          }
        }catch(e)
        {

        }



        setState(() {
          isLoadingForms = false;
        });
      }
  }


  String usernameErrorMessage = "";

  checkUsername() async{

    if(username == Variables.username)
      {
        setState(() {
          usernameErrorMessage = "";
          validatingUsername = false;
        });
        return;
      }
    if(username.contains(" "))
      {
        setState(() {
          usernameErrorMessage = "Username should not contain spaces";
          validatingUsername = false;
        });
        return;
      }

    setState(() {
      usernameErrorMessage = "";
      validatingUsername = true;
    });
    
    
    try{
      
      var res = await Functions.unsignPostReq(Variables.isUsernameExist, json.encode({
        "username" : username.trim()
      }));

      var r = jsonDecode(res.body);

      if(r["isError"])
        {
          setState(() {
            validatingUsername = false;
          });
          usernameErrorMessage =  "Try different username";
        }

      setState(() {
        validatingUsername = false;
      });
      usernameErrorMessage = "Username available";
      return null;

    }catch(e)
    {

      usernameErrorMessage =  "Cannot check username right now";
    }
    setState(() {
      validatingUsername = false;
    });


  }




   final format = DateFormat("dd/MM/yyy");

  DateTime birthDate ;

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return DefaultTabController(
        length: 2,
        child:Scaffold(
          backgroundColor: bottomNavColor,
          key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(280.0),
        child: AppBar(
          leading: Functions.backButtonMain(context, function: () async{
             await DefaultCacheManager().removeFile(Variables.user_pic);
            await CachedNetworkImage.evictFromCache(Variables.user_pic);
            final NetworkImage provider = NetworkImage(Variables.user_pic);

             imageCache.clear();

             provider.evict().then<void>((bool success) {
              if (success)
                debugPrint('removed image!');
            });
            Navigator.pop(context);
          }),
          flexibleSpace: Column(
            children: <Widget>[

              Spacer(),
              Padding(padding: EdgeInsets.only(top: 50),
                child: Functions.showProfileImage(Variables.user_pic, 120,0, isCache: false)
              ),
              FlatButton(onPressed: (){


                getImage();



              }, child: isLoading? Functions.showLoaderSmall(): Text(
                '\n' + locale.changeProfilePic,
                style: TextStyle(color: disabledTextColor, fontSize: 14, letterSpacing: 0),
              )),
              SizedBox(height: 64),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: ()  {
                saveData();
              },
              child: isLoadingForms ? Functions.showLoaderSmall(): Text(
                locale.save,
                style: TextStyle(
                  color: Colors.white
                )
              ),
            ),
           ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(0.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                labelColor: mainColor,
                unselectedLabelColor: secondaryColor,
                labelStyle: Theme.of(context).textTheme.headline6,
                indicator: BoxDecoration(color: transparentColor),
                isScrollable: true,
                tabs: <Widget>[
                  Tab(text: locale.profileInfo),
                  Tab(text: locale.accountInfo),
                ],
              ),
            ),
          ),
        ),
      ),
      body:      TabBarView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          buildProfileInfo(locale),
          buildAccountInfo(locale)
        ],
      ),

    ));
  }

  Widget buildProfileInfo(var locale) {
    return ListView(
      physics: BouncingScrollPhysics(),
      children: <Widget>[
        SizedBox(height: 36.0),
       Form(
         key: _formKey,
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             EntryField(
               onChanged: (s){
                 full_name = s;
               },
               maxLines: 1,
               label: "Full name",
               initialValue: full_name ,
             ),

             Container(height: 5,),

             TextFormField(


               style: TextStyle(color: secondaryColor),

                decoration: InputDecoration(

                   labelText: "Username",
                   labelStyle: TextStyle(color: Colors.white70, fontFamily: Variables.fontName ),
                   hintStyle: TextStyle(color: Colors.white38, fontFamily: Variables.fontName ),
                   suffixIcon: validatingUsername? Container(height: 30,width: 30, child: Functions.showLoaderSmall(),):
                   usernameErrorMessage.toLowerCase() == "username available" ?
                   Container(height: 20, width: 20, child: Icon(Icons.offline_pin, size: 20, color: Colors.green,), )
                       :null,
                   border: InputBorder.none,
                   focusedBorder: InputBorder.none,
                   contentPadding: EdgeInsets.only(left: 20, right: 20)
                 //fillColor: Colors.green

               ),
               keyboardType: TextInputType.emailAddress,
               textCapitalization: TextCapitalization.none,


               validator: (s){


                /* if(usernameErrorMessage.toLowerCase() != "username available" )
                   {
                     return "Username not available";
                   }
                  if(Functions.isNullEmptyOrFalse(username))
                    return "Please enter a username";
                  if(username.trim().length==0)
                    return "Please enter a username";
                 if(usernameErrorMessage == "")
                   return null;*/
                  return null;

               },
               onChanged: (s){
                 username = s;
                 if(s!=null)
                 if(s.trim().length>1)
                 checkUsername();
                 else {
                   validatingUsername = false;
                    usernameErrorMessage = "";
                    setState(() {

                    });
                 }
               },
                initialValue: username,
             ),

             usernameErrorMessage =="" || usernameErrorMessage.toLowerCase() == "username available" ? Container():
                 Padding(padding: EdgeInsets.only(left: 20),child: Text(usernameErrorMessage,
                   style: TextStyle(
                     color: usernameErrorMessage.toLowerCase() == "username available" ? Colors.white38 : Colors.redAccent
                   ),

                 ),),


             Container(height: 30,),


             EntryField(
               maxLines: 5,

               onChanged: (s){
                 bio= s;
               },
               label: "Bio",
               initialValue: bio,
             ),

           ],
         ),
       )
      ],
    );
  }

  Widget buildAccountInfo(var locale) {

     return ListView(
      physics: BouncingScrollPhysics(),
      children: <Widget>[

        Padding(padding: EdgeInsets.only(left: 20,top: 32, right: 20)
         ,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text("Your personal information is not displayed on your public page and also not shared with anyone", style: TextStyle(
                color: Colors.white60
              ),),

              Container(height: 35,),
              Text("Gender", style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w500),),
              Container(height: 12,),


              Container(

                width: MediaQuery.of(context).size.width,
                child: DropdownButton<String>(
                  value: Functions.isNullEmptyOrFalse(gender) ? "1" : Functions.isNullEmptyOrFalse(gender.trim()) ?"1":gender,
                  icon: null,
                  elevation: 16,
                  style: TextStyle(color: Colors.white),

                  onChanged: (String newValue) {
                    FocusScope.of(context).requestFocus(new FocusNode());

                    setState(() {
                      gender = newValue;
                    });
                  },
                  dropdownColor: darkColor,
                  items:Variables.genders
                      .map<DropdownMenuItem<String>>((String value) {
                     if(value == "1")
                    {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text("Not Set", style: TextStyle(color: Colors.white),),
                      );
                    }
                    return DropdownMenuItem<String>(
                      value: value.toLowerCase(),
                      child: Text(value),
                    );
                  }).toList(),
                )
                ,
              ),

              Container(height: 14,),






         /*     Text("Birth Date", style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w500),),

              DateTimeField(
                resetIcon: Icon(Icons.close, color: Colors.white38,),


                initialValue: Variables.dob == null ? null : Variables.dob,
                //   controller: TextEditingController()..text = birtnDate.toUtc().toString(),
                onChanged: (v) {
                  birthDate = v;
                },
                decoration: InputDecoration(

                  contentPadding: EdgeInsets.only(
                      bottom: 11, top: 11),
                    border: InputBorder.none,

                  focusedBorder: InputBorder.none,
                ),
                format: format,

                readOnly: true,
                enableInteractiveSelection: true,
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                      context: context,
                      firstDate: DateTime(1970,1,1),
                      initialDate: DateTime.now().subtract(Duration(days: 6620)),
                      lastDate: DateTime(4000,1,1));
                },

              ),
*/












              ListTile(
                contentPadding:
                EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                leading: Image.asset(
                  'assets/icons/ic_verified.png',
                  scale: 3,
                ),
                title: Text(
                  locale.getVerified,
                  style: Theme.of(context).textTheme.headline6.copyWith(
                      color: disabledTextColor, fontWeight: FontWeight.bold),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: secondaryColor,
                  size: 16,
                ),
                onTap: () =>
                    Navigator.popAndPushNamed(context, PageRoutes.verifiedBadgePage),
              )
            ],
          ),
        )

      ],
    );
  }



  Future getImage() async {
    File compressedImage = await ImagePicker.pickImage(
        source: ImageSource.gallery,

        imageQuality: 90,
        maxHeight: 1280,
        maxWidth: 1280);


    File croppedFile = await ImageCropper.cropImage(
        compressQuality: 70,
        maxWidth: 200,
        maxHeight: 200,
        sourcePath: compressedImage.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop',
            toolbarColor: Colors.white,

            hideBottomControls: true,
            toolbarWidgetColor: Colors.black87,
            activeControlsWidgetColor: Colors.blue,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(

          minimumAspectRatio: 1.0,
        ));
    Uint8List u;
    if (croppedFile != null) u = croppedFile.readAsBytesSync();

    setState(() {
      if (croppedFile != null) {

        submitForm(Variables.uploadProfileImg, croppedFile, compressedImage.path.split('/').last);



      }
    });
  }


  bool isLoading = false;
  submitForm(String link, File _image, name) async {




    isLoading = true;
    setState(() {

    });

    Functions fx  =Functions();
    var req = await fx.postReq(Variables.get_profile_picture_url, jsonEncode({}), context);


    var r = jsonDecode(req.body);
    await DefaultCacheManager().removeFile(Variables.user_pic);
    await CachedNetworkImage.evictFromCache(Variables.user_pic);
     final NetworkImage provider = NetworkImage(Variables.user_pic);
    provider.evict().then<void>((bool success) {
      if (success)
        debugPrint('removed image!');
    });



     //formdata.files.add(MapEntry("file",new MultipartFile.fromBytes(bytes)));
    String uploadBinaryURL = r["url"];
    await http.put(
      Uri.parse(uploadBinaryURL),
      headers: {
        "Content-Type": "application/octet-stream",
        'x-amz-acl': 'public',
        'Connection': 'keep-alive',
      },
      body: _image.readAsBytesSync(),
    );



await fx.postReq(Variables.on_profile_img_upload, jsonEncode({
  "path" : r["fileName"]
}), context);


    Variables.user_pic = r["cdnurl"];

    SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString(Variables.picString, Variables.user_pic);




    setState(() {
      isLoading = false;
    });




  }

  @override
  void initState() {
    super.initState();
    bio = Variables.bio;
    username= Variables.username;
    full_name = Variables.f_name + " " + Variables.l_name;
    gender= Variables.gender==null?"1":Variables.gender;
    dob = Variables.dob;
    phoneNumber = Variables.phoneNumber;
  }


}
