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
import 'package:qvid/Functions/Videos.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Routes/routes.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart' as extend;

import 'package:qvid/BottomNavigation/MyProfile/edit_profile.dart';
import 'package:qvid/BottomNavigation/MyProfile/followers.dart';
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

class _MyProfileBodyState extends State<MyProfileBody> {
  final key = UniqueKey();

    ScrollController scrollController = new ScrollController();
    ScrollController scrollController2 = new ScrollController();

  List<Videos> list = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();



    getData();

  }


  @override
  void dispose() {
    super.dispose();


  }



  bool isLoading = false;
  bool isError = false;
String errorMessage = "";
  String fb_id;
String bio = "";
 int isVerified = 0;
int likes =0, followers =0, following=0;

  getData() async{

    isLoading = true;
    setState(() {});

    SharedPreferences preferences = await SharedPreferences.getInstance();
    fb_id = preferences.getString(Variables.fbid_String);
    String url = Variables.videosByUserId;

    try{

      var s = await Functions.postReq(url, json.encode({
        "fb_id" : fb_id,
        "my_fb_id" : fb_id,
        "offset" : 0,
        "limit" : 21,

      }), context);

      var data = jsonDecode(s.body);
      if(data["isError"])
        {
          isError = true;
          errorMessage = "Some error occured";

         }
      else{
        var user = data["userData"]["user_info"];
        var follow_status = data["userData"]["follow_Status"];
       // var total_heart = data["userData"]["follow_Status"];
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
          bio = user["bio"];
          //preferences.setString(Variables.picString, user["bio"]);
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
        list = Functions.parseVideoList(data["msg"], list);



        isError = false;

      }

    }catch(e)
    {
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









  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    var locale = AppLocalizations.of(context);



    return Padding(padding: EdgeInsets.only(bottom: 60),
    child: Scaffold(
        appBar: PreferredSize(
          child: Container(
            child: ClipRRect(
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      //   width: MediaQuery.of(context).size.width,
                      //  height: MediaQuery.of(context).padding.top,
                      color: backgroundColor,
                    ))),
          ),
          preferredSize: Size(MediaQuery.of(context).size.width, 22),
        ),
        body: isLoading   ?
        Functions.showLoader()
            :   isError? Functions.showError(errorMessage) :
        DefaultTabController(
            length: 2,

            child: extend.NestedScrollView(
              //  controller: scrollController,
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[


                    SliverList(
                      delegate: SliverChildListDelegate(
                          [

                            Padding(
                              padding: EdgeInsets.only(left: 20, right: 22,top: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[

                                      Container(height: 65,width: 65,child:

                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(40.0),

                                        /* backgroundImage: Functions.isNullEmptyOrFalse(Variables.user_pic) ?
                                              AssetImage('assets/images/user.webp') :
                        */
                                        child:      CachedNetworkImage(
                                          imageUrl: Variables.user_pic,
                                          imageBuilder: (context, imageProvider) => Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(40)),

                                              image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover, ),
                                            ),
                                          ),
                                          placeholder: (context, url) => Functions.profileImageLoadEffect(),
                                          errorWidget: (context, url, error) => Functions.profileImageErrorEffect(),
                                        )
                                        ,

                                      ),
                                      )
                                      ,


                                      Container(width: 22,),

                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            Variables.f_name + " "  + Variables.l_name,
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                                          ),

                                          Container(height: 8,),
                                          Text(
                                            Functions.isNullEmptyOrFalse(Variables.username) ? "" : Variables.username,
                                            style: TextStyle(
                                                fontSize: 14, color: disabledTextColor),
                                          ),

                                        ],
                                      )],
                                  ),

                                  Container(height: 22,),

                                  Wrap(
                                    children: <Widget>[
                                      Text(
                                        bio,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),

                                  Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        RowItem(
                                            Functions.getRedableNumber(likes),
                                            locale.liked,
                                            Scaffold(
                                              appBar: AppBar(
                                                title: Text('Liked'),
                                              ),
                                              body: NewScreenGrid(
                                                food,
                                              ),
                                            )),
                                        RowItem(

                                            Functions.getRedableNumber(followers),locale.followers, FollowersPage()),
                                        RowItem(

                                            Functions.getRedableNumber(following), locale.following, FollowingPage()),
                                      ],
                                    ),
                                    height: 120,
                                  )
                                ],
                              ),
                            )
                          ]
                      ),
                    )

                  ];
                },



                body: Builder(
                  builder: (context){
                         final innerScrollController = PrimaryScrollController.of(context);
                         final innerScrollControllerLiked = PrimaryScrollController.of(context);

                    return Column(
                      children: <Widget>[
                        TabBar(
                            labelColor: mainColor,
                            unselectedLabelColor: lightTextColor,
                            indicatorColor: transparentColor,
                            tabs: [

                              Tab(icon: Icon(Icons.dashboard) , ),

                              Tab(icon: ImageIcon(AssetImage('assets/icons/ic_like.png')))

                            ]
                        ),
                        Expanded(

                          child: TabBarView(

                            children: <Widget>[

                              TabGrid(dance + food + dance , fb_id, 1, isLoading: isLoadingList, scrollController: scrollController ),

                              TabGrid(food + food + dance,fb_id, 2, scrollController: innerScrollController),

                            ],
                          ),
                        )
                      ],
                    );
                  },
                )
            )),),);

  }




  bool isLoadingList = false;
}



