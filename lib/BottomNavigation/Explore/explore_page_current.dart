import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qvid/BottomNavigation/Explore/more_page.dart';
import 'package:qvid/BottomNavigation/Home/following_tab.dart';
import 'package:qvid/Components/thumb_list.dart';
import 'package:qvid/Components/thumb_tile.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Model/Videos.dart';
import 'package:qvid/Routes/routes.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';



class CurrentExplorePage extends StatefulWidget {
  @override
  _ExploreBodyState createState() => _ExploreBodyState();
}

class _ExploreBodyState extends State<CurrentExplorePage>  with AutomaticKeepAliveClientMixin<CurrentExplorePage>{


  @override
  void initState() {
    super.initState();
    getHomeVideos();
    scrollController.addListener(() {
      if (scrollController.position.extentAfter < 300){

        getHomeVideos();
      }

    });
  }

  ScrollController scrollController = ScrollController();

  String haveVideoIds = "";
    List<Videos> list= [];

  int _current = 0;
  double width = 0;


  bool doesExistMore = true;
  bool isLoading = false;

  bool isError = false;
  String errorMessage = "";

  Map<int, String> map = Map();
  String my_fb_id;
 Future<void> getHomeVideos({bool isRefresh}) async{
   if(isRefresh == null) isRefresh = false;

   if(!isRefresh)
   if(!doesExistMore )
    {

        return;
    }

    if(!isLoading)
    {
      isLoading = true;

      if(!isRefresh)
        setState(() {
        });


      try{

        Functions fx = Functions();

        if(Functions.isNullEmptyOrFalse(Variables.token));
        {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          Variables.token = preferences.getString(Variables.tokenString);
        }


        var res ;
        my_fb_id = Variables.fb_id;

        if(Functions.isNullEmptyOrFalse(Variables.token))
        {
          res=  await Functions.unsignPostReq(Variables.home_videosNotLoggedIn, jsonEncode({
            "haveIds" : isRefresh ? "":haveVideoIds.length == 0 ? haveVideoIds : haveVideoIds.substring(0, haveVideoIds.length-1)
          }));

        }
        else{
          res=  await fx.postReq(Variables.home_videos, jsonEncode({
            "haveIds" :isRefresh ? "": haveVideoIds.length == 0 ? haveVideoIds : haveVideoIds.substring(0, haveVideoIds.length-1)
          }), context);
        }

        var data  = jsonDecode(res.body);
        if(!isRefresh)

          if(data["isError"])
        {
          isError = true;
          errorMessage = "Some error occured";
          isLoading = false;
          setState(() {});
          return;
        }

        isError = false;

        var l  = data["msg"];

        if(l.length<20)
        {
          doesExistMore = false;

        }else {

          doesExistMore = true;
        }

        List<Videos> v =  Functions.parseVideoList(l, context);

        if(isRefresh) list = [];

          for(int i =0;i<v.length;i++)
          {
            haveVideoIds = haveVideoIds + v[i].id.toString() + ",";
            list.add(v[i]);
          }





      }catch(e)
      {
        isError = true;
        errorMessage = Variables.connErrorMessage;

        setState(() {
          isLoading = false;

        });
        debugPrint(e);
      }


      setState(() {
        isLoading = false;
      });
    }






  }




  RefreshController _refreshController =
  RefreshController(initialRefresh: false);


  onRefresh()async {
    await getHomeVideos(isRefresh: true);
    _refreshController.refreshCompleted();

  }



  @override
  Widget build(BuildContext context) {
    super.build(context);

    width = MediaQuery.of(context).size.width;
    var locale = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 60.0),
      child: Scaffold(
         appBar: PreferredSize(
          preferredSize: Size.fromHeight(120.0),
          child:Container(

            decoration: BoxDecoration(
                color: bottomNavColor,


            ),
            child:  Container(

              margin: EdgeInsets.only(left: 20,right: 20, top: 56, bottom: 26),
              padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 24.0),
              decoration: BoxDecoration(
                color: darkColor,
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: TextField(
                readOnly: true,
                onTap: () => Navigator.pushNamed(context, PageRoutes.searchPage),
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: secondaryColor),
                  border: InputBorder.none,
                  hintText: AppLocalizations.of(context).search,
                  hintStyle: Theme.of(context).textTheme.subtitle1,
                ),
              ),
            ),
          ),
        ),
        body:    SmartRefresher(

            enablePullDown: true,
            header: Functions.swipeDownHeaderLoader(),
            controller: _refreshController,
            onRefresh: onRefresh,
            child:isLoading? Functions.showLoaderSmall() : isError?  Functions.showError(errorMessage):
        GridView.builder(

                itemCount: list.length,
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2 / 3,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 3,
                ),
                itemBuilder: (context, index) {
                  return  GestureDetector(
                    onTap: () {

                      if(list[index].description==null) list[index].description = "";
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FollowingTabPage(
                                  list, index, 3, Variables.showVideoByHashtag, Functions.getHashTags(list[index].description).length>0? Functions.getHashTags(list[index].description)[0]:"june",
                                  false, list.length)));},
                    child: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          image: DecorationImage(

                              image: NetworkImage(list[index].thumb_url), fit: BoxFit.cover),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Stack(
                          children: [

                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(height: 35, width: double.maxFinite,

                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(width: 8,),

                                    !Functions.isNullEmptyOrFalse(list[index].views.toString()) ? Text(Functions.getRedableNumber(list[index].views)) : SizedBox.shrink(),
                                    Container(width: 4,),
                                    Icon(
                                      Variables.viewIcon,
                                      color: Colors.white,
                                      size: 12,
                                    )
                                  ],
                                ),

                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.3),

                                      Colors.black.withOpacity(0.0),

                                    ],
                                    stops: [0, 1],

                                  ),
                                ),                                    ),

                            )


                          ],
                        )
                    ),
                  );
                }

            )

        )

      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;


}

class TitleRow extends StatelessWidget {
  final String title;
  final String subTitle;
  final List list;
   final double screenWidth;

  TitleRow(this.title, this.subTitle, this.list , this.screenWidth);



  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
            leading: CircleAvatar(
              backgroundColor: darkColor,
              child: Text(
                '#',
                style: TextStyle(color: mainColor),
              ),
            ),
            title: Container(
                height: 60,
                child: Padding(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  padding: EdgeInsets.only(top: 20),
                )
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                /*  Text(
              subTitle + ' ' + AppLocalizations.of(context).video,
              style: Theme.of(context).textTheme.caption,
            ),*/
                //Spacer(),
                Text(
                  "${AppLocalizations.of(context).viewAll}",
                  style: Theme.of(context).textTheme.caption,
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: secondaryColor,
                  size: 10,
                ),
              ],
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MorePage(
                    title: title,
                    list: list,
                  )),
            )),





        Container(
          margin: EdgeInsets.only(left: 8.0),
          height: screenWidth / 3,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: list.length,
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return ThumbTile(list[index]);
              }),
        )
      ],
    );
  }
}
