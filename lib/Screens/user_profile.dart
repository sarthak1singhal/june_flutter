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
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart' as extend;
import 'package:qvid/Functions/Videos.dart';
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

        var res= await Functions.postReq(Variables.videosByUserId , jsonEncode({
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

          listMyVideos.addAll(Functions.parseVideoList(d["msg"]));
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


      var s = await Functions.postReq(Variables.videosByUserId, json.encode({
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
          listMyVideos = Functions.parseVideoList(data["msg"], list: listMyVideos);


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


  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    //  pageNo = 0;
    //  isMore = true;
    await getData();
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
    setState(() {});
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

        leading: Functions.backButtonMain(context),
      ),
      body: isLoading   ?
      Functions.showLoader()
          :   isError? Functions.showError(errorMessage) :
      extend.NestedScrollView(
          controller: scrollController,
          headerSliverBuilder:
              (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[


              SliverToBoxAdapter(child: Padding(
                padding: EdgeInsets.only(left: 20, right: 22,top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[

                        Container(height: 65,width: 65,child:

                        ClipRRect(
                          borderRadius: BorderRadius.circular(40.0),

                          child:      CachedNetworkImage(
                            imageUrl: profile_pic== null ? "" : profile_pic,
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
                              f_name + " "  + l_name,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                            ),

                            Container(height: 8,),
                            Text(
                              Functions.isNullEmptyOrFalse(username) ? "" : username,
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
                              null),
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

                    child: TabGrid(listMyVideos, fb_id, 1, isLoading: isLoadingMyVideos, scrollController: scrollController ),

                  )
                ],
              );
            },
          )
      ),);
  }


}
