import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qvid/Components/entry_field.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:qvid/Functions/Variables.dart';

import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Routes/routes.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(250.0),
          child: AppBar(
            leading: Functions.backButtonMain(context),
            flexibleSpace: Column(
              children: <Widget>[

                Spacer(),
              Padding(padding: EdgeInsets.only(top: 50),
              child:   CircleAvatar(
                backgroundImage: AssetImage('assets/images/user.webp'),
                radius: 45,
              ),
              ),
                FlatButton(onPressed: (){


                  getImage();



                }, child: Text(
                  '\n' + locale.changeProfilePic,
                  style: TextStyle(color: disabledTextColor, fontSize: 14, letterSpacing: 0),
                )),
                SizedBox(height: 64),
              ],
            ),
            actions: <Widget>[
              RawMaterialButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  locale.save,
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(color: mainColor),
                ),
              )
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
        body: TabBarView(
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            buildProfileInfo(locale),
            buildAccountInfo(locale)
          ],
        ),
      ),
    );
  }

  Widget buildProfileInfo(var locale) {
    return ListView(
      children: <Widget>[
        SizedBox(height: 36.0),
        EntryField(
          label: locale.bio,
          initialValue: AppLocalizations.of(context).comment5,
        ),
        EntryField(
          label: locale.instagramID,
          initialValue: "@samanthasmith",
        ),
        EntryField(
          label: locale.facebookID,
          initialValue: "@samanth.asmith1",
        ),
        EntryField(
          label: locale.twitterID,
          initialValue: "@samanth.asmith1",
        ),
      ],
    );
  }

  Widget buildAccountInfo(var locale) {
    return ListView(
      children: <Widget>[
        SizedBox(height: 36.0),
        EntryField(
          label: locale.fullName,
          initialValue: "Samantha Smith",
        ),
        EntryField(
          label: locale.email,
          initialValue: "samanthasmith@mail.com",
        ),
        EntryField(
          label: locale.email,
          initialValue: "+1 987 654 3210",
        ),
        Spacer(),
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
    );
  }



  Future getImage() async {
    File compressedImage = await ImagePicker.pickImage(
        source: ImageSource.gallery,

        imageQuality: 90,
        maxHeight: 1280,
        maxWidth: 1280);


    File croppedFile = await ImageCropper.cropImage(
        compressQuality: 80,
        maxWidth: 1080,
        maxHeight: 1080,
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

      //  submitForm(Variables.baseUrl + Variables.uploadProfileImg, croppedFile, compressedImage.path.split('/').last);



      }
    });
  }


  bool isLoading = false;
  submitForm(String link, File _image, name) async {

    Dio dio = new Dio();

    isLoading = true;
    setState(() {

    });
    FormData formdata = new  FormData.fromMap({"file":  base64Encode(_image.readAsBytesSync()), "name" :name  });
    //formdata.files.add(MapEntry("file",new MultipartFile.fromBytes(bytes)));

    dio.post(link, data: formdata, options: Options(
      method: 'POST',
      responseType: ResponseType.json,
      headers: {
        "token": Variables.token
      },

    ))
        .then((response) async {

      print(response.data.toString());
      if(!response.data["isError"])
      {
        if(response.data["data"]!=null)
          Variables.user_pic = response.data["data"];

        SharedPreferences preferences = await SharedPreferences.getInstance();
      }
      setState(() {
        isLoading = false;
      });

    }
    )
        .catchError((error) {
      setState(() {

        isLoading = false;
      });
    });





  }


}
