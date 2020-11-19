import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qvid/BottomNavigation/Explore/explore_page.dart';
import 'package:qvid/Components/newScreenGrid.dart';
import 'package:qvid/Components/profile_page_button.dart';
import 'package:qvid/Components/row_item.dart';
import 'package:qvid/Components/sliver_app_delegate.dart';
import 'package:qvid/Components/tab_grid.dart';
import 'package:qvid/Functions/Variables.dart';
 import 'package:qvid/Model/Videos.dart';
import 'package:qvid/Locale/locale.dart';

import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Routes/routes.dart';
import 'package:qvid/BottomNavigation/MyProfile/followers.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:qvid/BottomNavigation/MyProfile/following.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfilePage extends StatelessWidget {

  final String fb_id;

  const UserProfilePage({Key key, this.fb_id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UserProfileBody(userFb_id: fb_id,);
  }
}

class UserProfileBody extends StatefulWidget {
  final String userFb_id;

  const UserProfileBody({Key key, this.userFb_id}) : super(key: key);

  @override
  _UserProfileBodyState createState() => _UserProfileBodyState();
}

class _UserProfileBodyState extends State<UserProfileBody> {
  bool isFollowed = false;

  var followText;

  final key = UniqueKey();

  ScrollController scrollController = new ScrollController();


  bool isLoading = false;
  bool isError = false;
  String errorMessage = "";
  String fb_id;
  String bio = "", f_name= "", l_name = "", profile_pic = "", username = "";
  int isVerified = 0;
  int offset1 = 0;
   int likes =0, followers =0, following=0;
List<Videos> listMyVideos = [];
  bool isLoadingMyVideos = false;
   bool isExistMyVideos = true;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    fb_id = widget.userFb_id;
    getData();
    scrollController.addListener(() {
      print(scrollController.position.extentAfter );
      if (scrollController.position.extentAfter < 300){

        fetchData();

      }

    });
  }


  fetchData() async{
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
          "fb_id" : widget.userFb_id,
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
        }



      }catch(e)
      {

        isLoading = false;
        isError = true;
        errorMessage = Variables.connErrorMessage;

      }


      setState(() {
        isLoadingMyVideos = false;
      });
    }
  }


  Future<void> getData() async {

    isLoading = true;
    setState(() {});


    try{

      Functions fx = Functions();

      var s = await fx.postReq(Variables.videosByUserId, json.encode({
        "fb_id": widget.userFb_id,
        "offset" : offset1,
        "limit" : 21
      }), context);

      var data = jsonDecode(s.body);
      if(data["isError"])
      {
        isError = true;
        errorMessage = "Some error occured";

      }else{


        var user = data["userData"]["user_info"];
        var follow_status = data["userData"]["follow_Status"];
        SharedPreferences preferences = await SharedPreferences.getInstance();
        if(!Functions.isNullEmptyOrFalse(user["first_name"]))
        {
          f_name = Functions.capitalizeFirst(user["first_name"]);

        }
        if(!Functions.isNullEmptyOrFalse(user["last_name"]))
        {
          l_name = Functions.capitalizeFirst(user["last_name"]);

        }

        if(!Functions.isNullEmptyOrFalse(user["username"]))
        {
          username = user["username"];

        }

        if(!Functions.isNullEmptyOrFalse(user["profile_pic"]))
        {
          profile_pic= user["profile_pic"];

        }

        if(!Functions.isNullEmptyOrFalse(user["bio"]))
        {
          bio = user["bio"];
          //preferences.setString(Variables.picString, user["bio"]);
        }   if(!Functions.isNullEmptyOrFalse(user["verified"]))
        {
          isVerified= user["verified"];
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
        if(!Functions.isNullEmptyOrFalse(data["userData"]["follow_Status"]))
          {

            if(!Functions.isNullEmptyOrFalse(data["userData"]["follow_Status"]["follow"]))
            {

              if(data["userData"]["follow_Status"]["follow"]=="0")
                {
                  isFollow = false;
                }else
                  isFollow = true;
            }
          }

        if(data["msg"]!=null)
          listMyVideos = Functions.parseVideoList(data["msg"], context,list: listMyVideos);


        offset1 = listMyVideos.length;

        if(listMyVideos.length < 21)
        {
          isExistMyVideos = false;
        }

        isError = false;


      }



    }catch(e)
    {

      isError = true;
      errorMessage = Variables.connErrorMessage;
      isLoading = false;

    }



    setState(() {
      isLoading = false;
    });



  }

  bool isFollow = false;


  RefreshController _refreshController =
  RefreshController(initialRefresh: false);


  onRefresh()async {
    await getData();
    _refreshController.refreshCompleted();

  }


  double width;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    var locale = AppLocalizations.of(context);


    final double statusBarHeight = MediaQuery
        .of(context)
        .padding
        .top;
    return Scaffold(
      appBar: AppBar(
        title: (!isLoading && !isError)? Text(
          username == null ? "" : username, style: TextStyle(
            color: Colors.white, fontSize: 18
        ),
        ): Container(),
        leading: Functions.backButtonMain(context),
      ),
      body:   SmartRefresher(
          enablePullDown: true,
          physics: BouncingScrollPhysics(),

          header: Functions.swipeDownHeaderLoader(),
          controller: _refreshController,
          onRefresh: onRefresh,
          child: isLoading   ?
      Functions.showLoaderSmall()
          :   isError? Functions.showError(errorMessage) :
      NestedScrollView(
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

                        Functions.showProfileImage(profile_pic, 75, isVerified)
                        ,
                        Container(
                          width: MediaQuery.of(context).size.width - 22-20-75-22,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              RowItem(
                                  Functions.getRedableNumber(likes),
                                  locale.liked,
                                  null),
                              RowItem(

                                  Functions.getRedableNumber(followers),locale.followers, FollowersPage(fb_id)),
                              RowItem(

                                  Functions.getRedableNumber(following), locale.following, FollowingPage(fb_id)),
                            ],
                          ),
                          height: 120,
                        ),

                        Container(width: 22,),

                        ],
                    ),

                    Container(height: 2,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          f_name + " "  + l_name,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),

                        Container(height: 6,),


                      ],
                    ),
                    Wrap(
                      children: <Widget>[
                        Text(
                          bio,
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    Container(height:  !Functions.isNullEmptyOrFalse(bio) ? bio.trim().length>0 ?14 : 0:0,),
                  Variables.fb_id!=widget.userFb_id?  Container(


                    width: MediaQuery.of(context).size.width,
                      child: RaisedButton(onPressed: () async{

                           isFollow = !isFollow;
                           setState(() {

                           });


                           Functions fx = Functions();
                           var t = await fx.postReq(
                               Variables.follow_users, jsonEncode({
                             "other_userid":widget.userFb_id,
                             "status" : isFollow ? 1 :0
                           }), context);

                      },
                        color: mainColor,

                        child: Text(isFollow ? "Unfollow" : "Follow", style: TextStyle(
                          color: Colors.white,
                          inherit: false,
                          fontFamily: Variables.fontName

                        ),),

                      ),
                    ) : Container(),
                    Container(height: Variables.fb_id!=widget.userFb_id?  21:17,)


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

                  Expanded(

                    child: TabGrid(listMyVideos, fb_id, 1, isLoading: isLoadingMyVideos, scrollController: scrollController , isRequestMade: true,),

                  )
                ],
              );
            },
          )
      )),);
  }


}
