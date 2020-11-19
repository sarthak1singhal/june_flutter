import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qvid/Components/profile_page_button.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Screens/user_profile.dart';
import 'package:qvid/Theme/colors.dart';

import 'followers.dart';



class FollowingPage extends StatelessWidget {
  final String fb_id ;

  FollowingPage(  this.fb_id) ;
  @override
  Widget build(BuildContext context) {
    return FollowingBody(fb_id: fb_id,);
  }
}

class FollowingBody extends StatefulWidget {
  final String fb_id ;

  const FollowingBody({Key key, this.fb_id}) : super(key: key);

  @override
  _FollowingBodyState createState() => _FollowingBodyState();
}

class _FollowingBodyState extends State<FollowingBody> {
  List<User> users = [
   ];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  ScrollController scrollController = new ScrollController();
  bool isLoading = false;
  bool isError = false;
  String errorMessage = "";
  bool doesExist = true;
  int offset = 0;

  @override
  void initState() {
    super.initState();
    getData();
    scrollController.addListener(() {
      if (scrollController.position.extentAfter < 300){

        getData();
      }

    });
  }
  getData() async{
    if(!doesExist)
    {
      return;
    }


    if(!isLoading)
    {
      setState(() {
        isLoading = true;
      });

      try{


        print(widget.fb_id);
        Functions fx= Functions();
        var res = await fx.postReq( Variables.get_followings, jsonEncode({
          "offset" : offset,
          "fb_id" : widget.fb_id
        }), context);

        var data = jsonDecode(res.body);

        if(data["isError"])
        {
          Functions.showSnackBar(_scaffoldKey, "Some error occured");
          isError = true;
          errorMessage = "Some error occured";
          setState(() {
            isLoading = false;
          });
          return;
        }

        if(data["msg"].length <40){
          doesExist = false;
        }
        else {
          offset = offset + 40;
        }


        for(int i=0;i<data["msg"].length; i++)
        {
          var d = data["msg"][i];
          String fb_id = "";
          if(!Functions.isNullEmptyOrFalse(d["fb_id"]))
          {
            fb_id = d["fb_id"];
          }
          String name = "";
          if(!Functions.isNullEmptyOrFalse(d["first_name"]))
          {
            name = Functions.capitalizeFirst(d["first_name"]);
          }
          if(!Functions.isNullEmptyOrFalse(d["last_name"]))
          {
            name = name+ " " +Functions.capitalizeFirst(d["last_name"]);
          }

          DateTime dateTime = DateTime.parse(d["created"]);

          bool isFollowing = false;
          if(d["follow_Status"]["follow"] == 1)
          {
            isFollowing = true;
          }
           users.add(User(name, d["username"],isFollowing, d["profile_pic"] ,fb_id));
        }
        isError = false;

      }catch(e){
        isError = true;
        errorMessage = Variables.connErrorMessage;
        isLoading = false;
        setState(() {

        });
        debugPrint(e);
      }


      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: bottomNavColor,
        appBar: AppBar(          leading: Functions.backButtonMain(context),


          title: Text("Followings", style: TextStyle(
            fontFamily: Variables.fontName
          ),),
          centerTitle: true,
        ),
        body: (isLoading && users.length!=0)? Functions.showLoaderSmall() : isError ? Functions.showError(errorMessage) : ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: users.length,
            itemBuilder: (context, index) {
              if(isLoading && users.length!=0)
              {
                if(index == users.length)
                  return Container(width: MediaQuery.of(context).size.width, height: 50, child: Functions.showLoaderSmall(),);
              }
              return ListTile(
                onTap: (){

                  Navigator.push(context,MaterialPageRoute(builder: (context) =>   UserProfilePage(fb_id: users[index].fb_id,)));

                },
                leading: Functions.showProfileImage(users[index].image, 45, 0),
                title: Text(
                  users[index].name,
                  style: TextStyle(color: secondaryColor),
                ),
                subtitle: Text(
                  users[index].username,
                  style: TextStyle(),
                ),
                trailing: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: users[index].isFollowing
                      ? ProfilePageButton(
                    locale.following,
                        () {


                      users[index].unfollowUser();

                      setState(() {
                        users[index].isFollowing =
                        !users[index].isFollowing;
                      });
                    },
                  )
                      : ProfilePageButton(
                    locale.follow,
                        () {


                      users[index].followUser();
                      setState(() {
                        users[index].isFollowing =
                        !users[index].isFollowing;
                      });
                    },
                    color: mainColor,
                    textColor: secondaryColor,
                  ),
                ),
              );
            }));
  }
}
