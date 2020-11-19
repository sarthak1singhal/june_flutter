import 'dart:convert';
import 'dart:core';
import 'dart:core';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qvid/Components/newScreenGrid.dart';
import 'package:qvid/Components/profile_page_button.dart';
import 'package:qvid/Components/row_item.dart';
import 'package:qvid/Components/sliver_app_delegate.dart';
import 'package:qvid/Components/tab_grid.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Model/Videos.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Locale/locale.dart';

import 'package:qvid/BottomNavigation/MyProfile/edit_profile.dart';
import 'package:qvid/BottomNavigation/MyProfile/followers.dart';
import 'package:qvid/Settings/Settings.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:qvid/BottomNavigation/Explore/explore_page.dart';
import 'package:qvid/BottomNavigation/MyProfile/following.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyProfileBody();
  }
}

class MyProfileBody extends StatefulWidget {
  @override
  _MyProfileBodyState createState() => _MyProfileBodyState();
}

class _MyProfileBodyState extends State<MyProfileBody>  with SingleTickerProviderStateMixin,    AutomaticKeepAliveClientMixin<MyProfileBody>  {
  final key = UniqueKey();

    ScrollController scrollController = new ScrollController();
    ScrollController scrollController2 = new ScrollController();

  TabController primaryTC;



  List<Videos> listMyVideos = [];
  List<Videos> listLikedVideos = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    primaryTC = new TabController(length: 2, vsync: this);


    scrollController.addListener(() {
       if (scrollController.position.extentAfter < 300){

        fetchData(primaryTC.index);

      }

    });

    primaryTC.addListener(() {

     // if(primaryTC.indexIsChanging)
        {
          print(primaryTC.index);
          print("changing");
          print(listLikedVideos.length);
          if(scrollController.position.extentAfter < 300 || listLikedVideos.length == 0)
            fetchData(primaryTC.index);
        }


    });

    getData();

  }


  @override
  void dispose() {
    super.dispose();


  }


  fetchData(int index){

    print("fetchData");
    if(primaryTC.index ==0)
      {
        fetchMyVideos(index);
      }else{

      fetechLikedVideos(index);
    }

    

  }

  fetechLikedVideos(int index) async{
    print("fetching liked videos");
    print(isLoadingLiked);

    if(!isExistLiked)
    {
      return ;
    }
    if(!isLoadingLiked)
    {
      setState(() {
        isLoadingLiked= true;
      });

      try{
        Functions fx = Functions();

        var res = await fx.postReq(Variables.my_liked_video , jsonEncode({
          "fb_id" : fb_id,
          "limit" : 21,
          "offset" : offset2



        }), context);


        var d = jsonDecode(res.body);
        print(res);
        if(!d["isError"])
        {

          int len = d["msg"].length;
          if(len<21)
          {
            isExistLiked= false;
          }
          offset2 = offset2 + len;
          isLoadingLiked = false;
          isRequestMade = true;
          listLikedVideos.addAll(Functions.parseVideoList(d["msg"], context));

          if(primaryTC.index==index){
            setState(() {

            });
            return;
          }
          return;


        }



      }catch(e)
      {


        print(e);
      }


      setState(() {
        isRequestMade = true;
        isLoadingLiked = false;
      });
    }
  }

  bool isRequestMade = false;

  fetchMyVideos(int index) async{


    if(!isExistMyVideos)
      {
        return ;
      }
    if(!isLoadingMyVideos)
    {
      setState(() {
        isLoadingMyVideos = true;
      });

      try{
        Functions fx = Functions();

        var res = await fx.postReq(Variables.videosByUserId , jsonEncode({
          "fb_id" : fb_id,
          "my_fb_id" : Variables.fb_id,
          "limit" : 21,
          "offset" : offset1



        }), context);


        var d = jsonDecode(res.body);
        print(res);
        if(!d["isError"])
          {

            int len = d["msg"].length;
            if(len<21)
              {
                isExistMyVideos = false;
              }
            offset1 = offset1 + len;
            isLoadingMyVideos = false;
            listMyVideos.addAll(Functions.parseVideoList(d["msg"], context));

            if(primaryTC.index==index){
               setState(() {

              });
              return;
            }
            return;
            
            
          }
        
        

      }catch(e)
      {


      }


      setState(() {
        isLoadingMyVideos = false;
      });
    }
  }





  bool isLoading = false;
  bool isError = false;
String errorMessage = "";
  String fb_id;
String bio = "";
 int isVerified = 0;
 int offset1 = 0;
 int offset2 = 0;
int likes =0, followers =0, following=0;

bool isLoadingMyVideos = false;
bool isLoadingLiked = false;
bool isExistMyVideos = true;
bool isExistLiked= true;





















  getData() async{

    isLoading = true;
    setState(() {});



    SharedPreferences preferences = await SharedPreferences.getInstance();
    fb_id = preferences.getString(Variables.fbid_String);
    String url = Variables.videosByUserId;

    Variables.fb_id = fb_id;
     try{
      Functions fx = Functions();

      var s = await fx.postReq(url, json.encode({
        "fb_id" : Variables.fb_id,
        "offset" : 0,
        "limit" : 21,

      }), context, isIdChange: true);

      fb_id = Variables.fb_id;
      var data = jsonDecode(s.body);
      if(data["isError"])
        {
          isError = true;
          errorMessage = "Some error occured";

         }
      else{
        var user = data["userData"]["user_info"];
        var follow_status = data["userData"]["follow_Status"];
         SharedPreferences preferences = await SharedPreferences.getInstance();
        if(!Functions.isNullEmptyOrFalse(user["first_name"]))
          {
            Variables.f_name = Functions.capitalizeFirst(user["first_name"]);
            preferences.setString(Variables.f_nameString, Functions.capitalizeFirst(user["first_name"]));
          }else{
          Variables.f_name = "";
          preferences.setString(Variables.f_nameString, "");

        }
        if(!Functions.isNullEmptyOrFalse(user["last_name"]))
        {
          Variables.l_name = Functions.capitalizeFirst(user["last_name"]);
          preferences.setString(Variables.l_nameString, Functions.capitalizeFirst(user["last_name"]));
        }else{
          Variables.l_name = "";
          preferences.setString(Variables.l_nameString, "");

        }

        if(!Functions.isNullEmptyOrFalse(user["username"]))
        {
          Variables.username = user["username"];
          preferences.setString(Variables.usernameString,user["username"]  );
        }else{
          Variables.username = "";
          preferences.setString(Variables.usernameString, "");

        }

        if(!Functions.isNullEmptyOrFalse(user["profile_pic"]))
        {
          Variables.user_pic= user["profile_pic"];
          preferences.setString(Variables.picString, user["profile_pic"]);
        }else{
          Variables.user_pic = "";
          preferences.setString(Variables.picString, "");

        }

        if(!Functions.isNullEmptyOrFalse(user["bio"]))
        {
          Variables.bio = user["bio"];
          preferences.setString(Variables.bioString, user["bio"]);
        }else{
          Variables.bio = "";
          preferences.setString(Variables.bioString, "");
        }




        if(!Functions.isNullEmptyOrFalse(user["gender"]))
        {
          Variables.gender= user["gender"];
          preferences.setString(Variables.genderString, user["gender"]);
        }else{
          Variables.gender= "";
          preferences.setString(Variables.genderString, "");
        }







        if(!Functions.isNullEmptyOrFalse(data["userData"]["personal"]))
          {

            var personal = data["userData"];
            if(!Functions.isNullEmptyOrFalse(personal["email"]))
            {
              Variables.email= personal["email"];
              preferences.setString(Variables.emailString, personal["email"]);
            }else{
              Variables.email= "";
              preferences.setString(Variables.emailString, "");
            }



            if(!Functions.isNullEmptyOrFalse(personal["phoneNumber"]))
            {
              Variables.phoneNumber= personal["phoneNumber"];
              preferences.setString(Variables.phoneNumberString, personal["phoneNumber"]);
            }else{
              Variables.phoneNumber= "";
              preferences.setString(Variables.phoneNumberString, "");
            }



            if(!Functions.isNullEmptyOrFalse(personal["dob"]))
            {
              Variables.dob= personal["dob"];
              preferences.setString(Variables.dobString, personal["dob"]);
            }else{
              Variables.dob= "";
              preferences.setString(Variables.dobString, "");
            }



            if(!Functions.isNullEmptyOrFalse(personal["signup_type"]))
            {
              Variables.signupType= personal["signup_type"];
              preferences.setString(Variables.signupTypeString, personal["signup_type"]);
            }else{
              Variables.signupType= "";
              preferences.setString(Variables.signupTypeString, "");
            }




          }




        if(!Functions.isNullEmptyOrFalse(data["userData"]["total_heart"]))
        {
          likes = data["userData"]["total_heart"];
          //preferences.setString(Variables.picString, user["bio"]);
        }
        if(!Functions.isNullEmptyOrFalse(data["userData"]["total_fans"]))
        {
          followers = data["userData"]["total_fans"];
          //preferences.setString(Variables.picString, user["bio"]);
        }
        if(!Functions.isNullEmptyOrFalse(data["userData"]["total_following"]))
        {
          following = data["userData"]["total_following"];
          //preferences.setString(Variables.picString, user["bio"]);
        }



        if(data["msg"]!=null)
        listMyVideos = Functions.parseVideoList(data["msg"],context, list: listMyVideos);


        offset1 = listMyVideos.length;

        if(listMyVideos.length < 21)
          {
            isExistMyVideos = false;
          }

        isError = false;


        if(user["verified"]!=null)
          if(user["verified"] == 0|| user["verified"] == 1)
          {
            Variables.isVerified = user["verified"];
            preferences.setInt(Variables.verifiedString, user["verified"]);
          }else{
            Variables.isVerified = 0;
            preferences.setInt(Variables.verifiedString, 0);
          }
      }

    }catch(e)
    {
      print(e);
      isError = true;
      errorMessage = Variables.connErrorMessage;
      isLoading = false;
      setState(() {

      });
    }









    isLoading = false;
    setState(() {

    });


   }









  double width;



  RefreshController _refreshController =
  RefreshController(initialRefresh: false);


  onRefresh()async {
    await getData();
    _refreshController.refreshCompleted();

  }





  @override
  Widget build(BuildContext context) {
    super.build(context);


    width = MediaQuery.of(context).size.width;
    var locale = AppLocalizations.of(context);



    return Padding(padding: EdgeInsets.only(bottom: 60),
    child: Scaffold(

        appBar: AppBar(

          title: Text(
            Variables.username == null ? "" : "${Variables.username}", style: TextStyle(
            color: Colors.white, fontSize: 18,
            fontFamily: Variables.fontName,
            fontWeight: FontWeight.w600
          ),
          ),
          actions: [
        IconButton(icon: Icon(Icons.menu, color: Colors.white70,),onPressed: (){



    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Settings()),
    );



    })
          ],
        ),
        body: SmartRefresher(
            enablePullDown: true,
            physics: BouncingScrollPhysics(),

            header: Functions.swipeDownHeaderLoader(),
            controller: _refreshController,
            onRefresh: onRefresh,
            child: isLoading   ?
        Functions.showLoaderSmall()
            :   isError? Functions.showError(errorMessage) :
        DefaultTabController(
            length: 2,

            child: NestedScrollView(
                 controller: scrollController,
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[


                    SliverToBoxAdapter(child: Padding(
                      padding: EdgeInsets.only(left: 20, right: 22,top: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[

                              Functions.showProfileImage(Variables.user_pic,75, Variables.isVerified)
                              ,


                              Container(width: 22,),
                              Container(

                                width: MediaQuery.of(context).size.width - 22-20-75-22,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    RowItem(
                                        Functions.getRedableNumber(likes),
                                        locale.liked,
                                        null),
                                    RowItem(

                                        Functions.getRedableNumber(followers),locale.followers, FollowersPage(Variables.fb_id)),
                                    RowItem(

                                        Functions.getRedableNumber(following), locale.following, FollowingPage(Variables.fb_id)),
                                  ],
                                ),
                                height: 120,
                              ),

                              //Spacer()
                            ],
                          ),

                          Container(height: 2,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                Variables.f_name + " "  + Variables.l_name,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),

                              Container(height: 6,),

                            ],
                          ),
                          Wrap(
                            children: <Widget>[
                              Text(
                                Variables.bio,
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),

                          Container(height: Functions.isNullEmptyOrFalse(Variables.bio) ? 8: Variables.bio.trim().length> 0? 12:6,)

                        ],
                      ),
                    ),),


                  ];
                },



                body: Builder(
                  builder: (context){
                         final innerScrollController = PrimaryScrollController.of(context);
                         //innerScrollController.

                         final innerScrollControllerLiked = PrimaryScrollController.of(context);

                    return Column(
                      children: <Widget>[
                        TabBar(
                          controller: primaryTC,
                            labelColor: mainColor,
                            unselectedLabelColor: lightTextColor,
                            indicatorColor: transparentColor,
                            tabs: [

                              Tab(icon: Icon(Icons.dashboard) , ),

                              Tab(icon: ImageIcon(AssetImage('assets/icons/ic_like.png')))

                            ]
                        ),
                        Divider(color: Colors.white24,),
                        Expanded(

                          child: TabBarView(
                            controller: primaryTC,

                            children: <Widget>[


                              TabGrid(listMyVideos, fb_id, 1, isLoading: isLoadingMyVideos, scrollController: scrollController, isRequestMade: true, ),

                              TabGrid(listLikedVideos,fb_id, 2,  isLoading: isLoadingLiked, isRequestMade: isRequestMade,),

                            ],
                          ),
                        )
                      ],
                    );
                  },
                )
            ))),),);

  }





  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}



