import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qvid/Components/continue_button.dart';
import 'package:qvid/Functions/Toast.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:qvid/Theme/style.dart';





class BadgeRequest extends StatefulWidget {


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<BadgeRequest> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


@override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  bool isLoadingMain = false;

String message;
bool isVerified;

getData() async{

  if(isLoadingMain ) return;
  try{
    setState(() {
      isLoadingMain = true;
    });


    Functions fx = Functions();
    var res  = await fx.postReq(Variables.getVerificationStatus, jsonEncode({

    }), context);


    var d = jsonDecode(res.body);

    if(d["message"]!=null)
      {
        message = d["message"];
      }
    if(message.trim().toLowerCase() == "verified")
      {
        message = "Profile Verified";
      }

    isLoadingMain = false;
    setState(() {

    });
  }catch(e){
    isLoadingMain = false;
    setState(() {

    });
  }

  isLoadingMain = false;

}

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: bottomNavColor,
      key: _scaffoldKey,
      appBar: AppBar(
        leading: Functions.backButtonMain(context),

        title: Text(locale.verifiedBadgeRequest, style: TextStyle(
          fontFamily: Variables.fontName
        ),),
        actions: [
          FlatButton(onPressed: (){

            if(!isVerified)
            saveData();

          }, child:  isLoading ? Functions.showLoaderSmall(): Text("SAVE", style: TextStyle(inherit: false),))
        ],
      ),
      body: isLoadingMain ? Functions.showLoaderSmall(): ListView(
        physics: BouncingScrollPhysics(),
        children:  [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              locale.provide,
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20.0),
          ListTile(
            title: Text(
              locale.clickCurrent + '\n',
              style: TextStyle(fontSize: 14),
            ),

            trailing: GestureDetector(
              child: Container(
                width: 50,
                height: 100,
                decoration: BoxDecoration(
                    borderRadius: radius,
                    color: lightTextColor,
                    image: profileImage ==null ? null  : DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(
                            profileImage
                        )
                    )
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 20.0,
                  color: Colors.white54,
                ),
              ),onTap: (){
              getImage(true);

            },
            )
          ),
          SizedBox(height: 20.0),
          ListTile(
            title: Text(
              locale.uploadGovt + '\n',
              style: TextStyle(fontSize: 14),
            ),

            trailing: GestureDetector(
              child: Container(

 width: 50,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    color: lightTextColor,
                    image: document ==null ? null  : DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(
                        document
                      )
                    )
                  ),
                  child: Icon(
                    Icons.file_upload,
                    size: 20.0,
                    color: Colors.white54,
                  ),
              ),
              onTap: (){
                getImage(false);
              },
            )
          ),

          Padding(padding: EdgeInsets.all(20),child: Text(
            '\n' + locale.itWillTake ,
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.subtitle1,
          ),),

          message == null ? Container() : Padding(padding: EdgeInsets.all(20),child: Text(
          "Current Request Status- \n$message",
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.subtitle1,
          ),)
        ],
      ),
    );
  }



File profileImage, document;

  Future getImage(bool isProfile) async {
    File compressedImage = await ImagePicker.pickImage(
        source: ImageSource.gallery,

        imageQuality: 90,
        maxHeight: 1280,
        maxWidth: 1280);


    if(compressedImage==null)return;
    File croppedFile = await ImageCropper.cropImage(
        compressQuality: 70,
        maxWidth: 400,
        maxHeight: 400,
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

        if(isProfile)
          {
            profileImage = croppedFile ;
          }
        else{
            document = croppedFile;

        }


      }
    });

    setState(() {

    });
  }


  bool isLoading  = false;



  saveData() async{
    if(isLoading ) return;
    if(profileImage ==null || document==null)
      {
        Functions.showSnackBar(_scaffoldKey, "Add verification documents");
        return;

      }
    setState(() {
      isLoading = true;
    });

    Functions fx = Functions();


    try{


      var res = await fx.postReq(Variables.getVerificationDocsUrl, jsonEncode({}), context);


      var data  = jsonDecode(res.body);

      if(data["msg"]!=null)
        {
          Functions.showSnackBar(_scaffoldKey, Variables.connErrorMessage);
          setState(() {
            isLoading = false;

          });
          return;
        }

      String profile_url = data["profile_url"];
      String doc_url = data["doc_url"];
      String profile_path = data["profile_path"];
      String document_path = data["document_path"];


      await http.put(
        profile_url,
        headers: {
          "Content-Type": "application/octet-stream",
          'x-amz-acl': 'public',
          'Connection': 'keep-alive',
        },
        body: profileImage.readAsBytesSync(),
      );
      await http.put(
        doc_url,
        headers: {
          "Content-Type": "application/octet-stream",
          'x-amz-acl': 'public',
          'Connection': 'keep-alive',
        },
        body: document.readAsBytesSync(),
      );

      var r = await fx.postReq(Variables.getVerified, jsonEncode({
        "document_path": document_path,
        "profile_path" : profile_path
      }), context);

      var d = jsonDecode(r.body);
      if(d["isError"])
        {

          Functions.showSnackBar(_scaffoldKey, Variables.connErrorMessage);
          setState(() {
            isLoading = false;

          });
          return;
        }


      setState(() {
        isLoading= false;
      });

      Functions.showToast("Request Submitted", context);

      Navigator.pop(context);


    }catch(e){

      print(e);
      Functions.showSnackBar(_scaffoldKey, Variables.connErrorMessage);



      setState(() {
        isLoading = false;
      });
    }


    setState(() {
      isLoading = false;
    });


  }


}









