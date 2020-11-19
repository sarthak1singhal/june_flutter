import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
 import 'package:qvid/BottomNavigation/Home/commentSheet.dart';
import 'package:qvid/BottomNavigation/Home/shareSheet.dart';
import 'package:qvid/BottomNavigation/Home/showVideosByHashTag.dart';
 import 'package:qvid/Components/custom_button.dart';
 import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Model/Videos.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Routes/routes.dart';
import 'package:qvid/Screens/user_profile.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:qvid/hashtags/hashtagText.dart';
import 'package:qvid/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'ShowVideosBySound.dart';
import 'dynamicBottomSheet.dart';

class FollowingTabPage extends StatelessWidget {

  final bool isFollowing;
String k;
  final List<Videos> list;
  int index;
   final int type;  //1 userVideos, 2 for myLikedVideos, 3 for hashtag, 4 for bySound, 5 for searched, 6 homeVideos, 7 following
  final String url; // url to be used to fetch video
  final String tag; // hashtag if type =3 and sound name if type = 5

  String userId;
  int offset = 0;
  FollowingTabPage( this.list, this.index, this.type, this.url,  this.tag,  this.isFollowing , this.offset, {this.userId, this.k});

  FollowingTabBody f ;

  pauseOnTabChange(){
    print("-----------------------------------------------------------------------------------");
    f.pauseVideoOnTabChange();
  }
  @override
  Widget build(BuildContext context) {
    if(k == null) k = "sada";
f = FollowingTabBody(k, isFollowing,  type, url, tag, offset, userId, list, index);
     return f;
  }
}

class FollowingTabBody extends StatefulWidget {

  final bool isFollowing;

  List<Videos> list;
  int index;
   final int type;  //1 userVideos, 2 for myLikedVideos, 3 for hashtag, 4 for bySound, 5 for searched, 6 homeVideos, 7 following
  final String url;

  String userId;
  int offset;
  final String tag;
String k;
  FollowingTabBody(this.k, this.isFollowing,  this.type, this.url, this.tag, this.offset, this.userId, this.list, this.index);
  FollowingTabBodyState f  = FollowingTabBodyState.def() ;

  pauseVideoOnTabChange(){
    print("1111111111111111111111111111111111111111111111111111111111111111111111111111111111");

 //   f.pauseVideoonTabChange();
  }
  @override
  FollowingTabBodyState  createState() {
     f = FollowingTabBodyState (isFollowing, type, url, tag, list, index, offset, userId);

   if(list==null) list = [];
  return  f;
  }
}

class FollowingTabBodyState extends State<FollowingTabBody>  with
AutomaticKeepAliveClientMixin<FollowingTabBody>         {
  FollowingTabBodyState.def({this.type, this.url, this.tag, this.isFollowing});
  PageController _pageController;
  int current = 0;
  String userId;
  bool isOnPageTurning = false;
  PersistentBottomSheetController _controller;
  bool _open = false;

    bool isFollowing;

  List<Videos> list;
  int index;
    int type;  //1 userVideos, 2 for myLikedVideos, 3 for hashtag, 4 for bySound, 5 for searched, 6 homeVideos, 7 following
    String url;
    String tag;
  bool isLoading = false;
  bool isError = false;
  bool doesExistMore = true;
  String errorMessage;
  int offset = 0;
  GlobalKey<ScaffoldState> _key = GlobalKey();

  CachedVideoPlayerController videoPlayerController ;


  FollowingTabBodyState(this.isFollowing, this.type, this.url, this.tag, this.list, this.index, this.offset, this.userId);



  void scrollListener() {
    if (isOnPageTurning && _pageController.page == _pageController.page.roundToDouble()) {
      setState(() {
        current = _pageController.page.toInt();
        isOnPageTurning = false;

        if(current > list.length-5)
          {
            getData();
          }
      });
    } else if (!isOnPageTurning && current.toDouble() != _pageController.page) {
      if ((current.toDouble() - _pageController.page).abs() > 0.1) {

        setState(() {
          isOnPageTurning = true;
        });
      }
    }
  }


  getData(){

    if(type==6){
      getHomeVideos();
    }
    if(type==7)
      {
        getFollowingVideos();
      }
    if(type==5)
      {
        getSearchedVideos();
      }
    if(type==4)
    {
      getVideosBySound();
    }
    if(type==3)
    {
      getVideosByHashTag();
    }
 if(type==2)
    {
      getLikedVideos();
    }
 if(type==1)
    {
      getUserVideos();
    }

  }

  String my_fb_id = '';



  String haveVideoIds = "";
  getHomeVideos() async{

    if(!doesExistMore)
      {

        return;
      }
    if(!isLoading)
      {
        setState(() {
          isLoading = true;
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
              "haveIds" : haveVideoIds.length == 0 ? "" : haveVideoIds.substring(0, haveVideoIds.length-1)
            }));

          }
          else{
            res=  await fx.postReq(Variables.home_videos, jsonEncode({
              "haveIds" : haveVideoIds.length == 0 ? "" : haveVideoIds.substring(0, haveVideoIds.length-1)
            }), context);
          }

          var data  = jsonDecode(res.body);
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

  int offset2 = 0;
  getFollowingVideos() async{

    if(!doesExistMore)
    {

    return;
    }
    if(!isLoading)
    {

      setState(() {
        isLoading = true;
      });


      try{

        Functions fx = Functions();



        var res ;


          res=  await fx.postReq(Variables.videos_following, jsonEncode({
            "offset2" : offset2,
            "offset" : 0
          }), context);


        var data  = jsonDecode(res.body);
        if(data["isError"])
        {
          isError = true;
          errorMessage = "Some error occured";
          isLoading = false;
          setState(() {});
          return;
        }

        var l  = data["msg"];
        isError = false;


        if(l==0)
          {
            doesExistMore = false;
          }else
        if(l.length<20)
        {
          offset2 = offset2+50;
          doesExistMore = true;
        }else {

          offset2 = offset2+30;
          doesExistMore = true;
        }

        list =  Functions.parseVideoList(l, context, list: list);





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

  getSearchedVideos() async{
    if(!doesExistMore)
    {
      return;
    }
    if(!isLoading)
    {
      setState(() {
        isLoading = true;
      });


      try{

        Functions fx = Functions();



        var res ;


        res=  await Functions.unsignPostReq(Variables.search, jsonEncode({
          "type" : "video" ,
          "keyword" : widget.tag,
          "fb_id" : Functions.isNullEmptyOrFalse(Variables.fb_id) ?"" : Variables.fb_id
        }));


        var data  = jsonDecode(res.body);
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

        list =  Functions.parseVideoList(l, context, list: list);





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

  getVideosBySound() async{
    if(!doesExistMore)
    {
      return;
    }
    if(!isLoading)
    {
      setState(() {
        isLoading = true;
      });


      try{

        Functions fx = Functions();



        var res ;


        res=  await Functions.unsignPostReq(Variables.showVideosBySound, jsonEncode({
          "offset" : offset ,
          "sound_id" : widget.tag,
          "fb_id" : Functions.isNullEmptyOrFalse(Variables.fb_id) ?"" : Variables.fb_id

        }));


        var data  = jsonDecode(res.body);
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

        if(l.length<21)
        {
          doesExistMore = false;
        }else {
          offset = offset+21;
          doesExistMore = true;
        }

        list =  Functions.parseVideoList(l, context, list: list);





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

  getVideosByHashTag() async{
    if(!doesExistMore)
    {
      return;
    }
    if(!isLoading)
    {
      setState(() {
        isLoading = true;
      });


      try{

        Functions fx = Functions();



        var res ;


        res=  await Functions.unsignPostReq(Variables.showVideoByHashtag, jsonEncode({
          "offset" : offset ,
          "hashtag" : widget.tag,
          "limit" : 21,
          "fb_id" : Functions.isNullEmptyOrFalse(Variables.fb_id) ?"" : Variables.fb_id

        }));


        var data  = jsonDecode(res.body);
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

        if(l.length<21)
        {
          doesExistMore = false;
        }else {
          offset = offset+21;
          doesExistMore = true;
        }

        list =  Functions.parseVideoList(l, context, list: list);





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

  getUserVideos() async{
    if(!doesExistMore)
    {
      return;
    }
    if(!isLoading)
    {
      setState(() {
        isLoading = true;
      });


      try{

        Functions fx = Functions();



        var res ;


        res=  await fx.postReq(Variables.videosByUserId, jsonEncode({
          "offset" : offset ,
          "fb_id" : userId,
          "my_fb_id" : Variables.fb_id,
          "limit" : 20
        }), context);


        var data  = jsonDecode(res.body);
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
          offset = offset+20;
          doesExistMore = true;
        }



        list =  Functions.parseVideoList(l, context, list: list);





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

  getLikedVideos() async{
    if(!doesExistMore)
    {
      return;
    }
    if(!isLoading)
    {
      setState(() {
        isLoading = true;
      });


      try{

        Functions fx = Functions();



        var res ;


        res=  await fx.postReq(Variables.my_liked_video, jsonEncode({
          "offset" : offset ,

          "limit" : 20
        }), context);


        var data  = jsonDecode(res.body);
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
          offset = offset+20;
          doesExistMore = true;
        }

        list =  Functions.parseVideoList(l, context, list: list);





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





  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(scrollListener);

    if(index == null) index = 0;
    if(index != 0)
      {

        WidgetsBinding.instance.addPostFrameCallback((_) => _pageController.jumpToPage(index));

      }

    getData();
  }



  RefreshController _refreshController =
  RefreshController(initialRefresh: false);


  onRefresh()async {
    await getData();
    _refreshController.refreshCompleted();

  }
  @override
  Widget build(BuildContext context) {

    if(list.length==0 && isLoading && !isError)
      {
        return Scaffold(
            appBar: PreferredSize(

              child: Container(
                child:Padding(
                  padding: EdgeInsets.only(top: 40, left: 5),
                  child:  Row(
                    children: [

                      (type ==6 || type == 7)? Container()  : Functions.backButtonWithGlassEffect(context)
                    ],
                  ),
                ),

              ), preferredSize: Size(MediaQuery.of(context).size.width, 50),),

            body:  SmartRefresher(
                enablePullDown: true,
                header: Functions.swipeDownHeaderLoader(),
                controller: _refreshController,
                onRefresh: onRefresh,
                // onLoading: isLoading,
                child:
                        Container(
                          height: MediaQuery.of(context).size.height-180,

                          width: MediaQuery.of(context).size.width,
                        child: Functions.showLoaderSmall(),
                      ),


            )
        );
      }

    if(isError)
      {

        return Scaffold(
            appBar: PreferredSize(

              child: Container(
                child:Padding(
                  padding: EdgeInsets.only(top: 40, left: 5),
                  child:  Row(
                    children: [

                      (type ==6 || type == 7)? Container()  : Functions.backButtonWithGlassEffect(context)
                    ],
                  ),
                ),

              ), preferredSize: Size(MediaQuery.of(context).size.width, 50),),

            body:   SmartRefresher(
               enablePullDown: true,
               header: Functions.swipeDownHeaderLoader(),
               controller: _refreshController,
               onRefresh: onRefresh,
               // onLoading: isLoading,
               child:  Column(
                 children: [
                   Container(
                   //    padding: EdgeInsets.only(top: 33, left: 5, bottom: 10),



                   ),
                   Expanded(
                     child: Container(
                       height: MediaQuery.of(context).size.height-180,

                       width: MediaQuery.of(context).size.width,
                       child: Functions.showError(errorMessage),
                     ),
                   )
                 ],
               )

           )
        );
      }

    if(type==7 && list.length==0)
      {
        return Scaffold(
            appBar: PreferredSize(

              child: Container(
                child:Padding(
                  padding: EdgeInsets.only(top: 40, left: 5),
                  child:  Row(
                    children: [

                      (type ==6 || type == 7)? Container()  : Functions.backButtonWithGlassEffect(context)
                    ],
                  ),
                ),

              ), preferredSize: Size(MediaQuery.of(context).size.width, 50),),
            body: SmartRefresher(
                enablePullDown: true,
                header: Functions.swipeDownHeaderLoader(),
                controller: _refreshController,
                onRefresh: onRefresh,
                 child:   Container(
                   height: MediaQuery.of(context).size.height-180,
                   child:
                    Functions.showError("Follow some people", code:1),

                 ),


            )
        );
      }


      return Stack(
        children: [

          PageView.builder(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            controller: _pageController,
            itemBuilder: (context, position) {


             return VideoPage(
                widget.k,
                videoData: list[position],
                pageIndex: position,
                currentPageIndex: current,
                isPaused: isOnPageTurning,
                isFollowing: widget.isFollowing,
                removeVideo: (){
                  if(current==list.length-1)
                  {
                    _pageController.previousPage(duration: Duration(seconds: 1, milliseconds: 500), curve: Curves.decelerate).whenComplete(() => list.removeAt(position));

                  }else {
//              list.removeAt(position);

                    _pageController.nextPage(
                        duration: Duration(seconds: 1, milliseconds: 500),
                        curve: Curves.decelerate).whenComplete(() {
                      setState(() {

                      });
                    });
                  }



                },
              );

             },
            itemCount: list.length,
          ),
          Positioned(
            top: 1,
            left: 1,
            child: Container(
              padding: EdgeInsets.only(top: 33, left: 5, bottom: 10),

              child: Center(
                child: Row(
                  children: [

                    (type ==6 || type == 7)? Container()  : Functions.backButtonWithGlassEffect(context)
                  ],
                ),
              )

          ),)
        ],
      );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;


}

class VideoPage extends StatefulWidget {
  String k;

  final Videos videoData;
  final int pageIndex;
  int currentPageIndex;
  final bool isPaused;
  final bool isFollowing;

  CachedVideoPlayerController videoPlayerController;
  Function removeVideo;

  deletePage(){
    removeVideo();
  }


  VideoPage(this.k,
      {this.pageIndex, this.currentPageIndex, this.isPaused, this.isFollowing,   this.videoData, this.removeVideo});

  VideoPageState v ;


  
  CachedVideoPlayerController getVideoController(){
    print("-----------------------------------------------------------------------------------");

  //  return v.getVideoController();
  }

  @override
  VideoPageState  createState() {
    videoPlayerController = CachedVideoPlayerController.network(videoData.vid_url);
    v= VideoPageState(videoPlayerController, k);
    return v;
  }
}




class VideoPageState extends State<VideoPage> with RouteAware  {
  CachedVideoPlayerController controller ;//= new CachedVideoPlayerController.network("");
  bool initialized = false;
  bool isLiked = false;

  String key;

  VideoPageState(CachedVideoPlayerController c, String k){
    controller  = c;

    key  = k;
  }
 
  CachedVideoPlayerController getVideoController(){

    if(controller!=null)
    controller.pause();
    return controller;

  }






  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context));//Subscribe it here
    super.didChangeDependencies();
  }

  /// Called when the current route has been popped off.
  @override
  void didPop() {
    print("didPop");
    super.didPop();
  }

  /// Called when the top route has been popped off, and the current route
  /// shows up.
  @override
  void didPopNext() {
   //  controller.play();
    super.didPopNext();
  }

  /// Called when the current route has been pushed.
  @override
  void didPush() {
    print("didPush");
    super.didPush();
  }

  /// Called when a new route has been pushed, and the current route is no
  /// longer visible.
  @override
  void didPushNext() {
    print("didPushNext");
    controller.pause();
    super.didPushNext();
  }




  @override
  void initState() {
    super.initState();

    isLiked = widget.videoData.isLiked ==1 ?true:false;


    controller 
      ..initialize().then((value) {
        initialized = true;

        if (mounted) {
          controller.setLooping(true);
          setState(() {

            controller.play();
            widget.videoData.updateView();
          });
        }
      });

   }

  @override
  void dispose() {
    routeObserver.unsubscribe(this); //Don't forget to unsubscribe it!!!!!!

    super.dispose();
    controller.dispose();

  }



  @override
  Widget build(BuildContext context) {
  //  print(initialized);

    var locale = AppLocalizations.of(context);

     return SafeArea(
         left: false,
         right: false,

         child: Scaffold(
       resizeToAvoidBottomInset: true,
       body: Stack(
         children: <Widget>[


           GestureDetector(
             onTap: () {
               playPause();
             },
             onDoubleTap: (){


             },
             child: controller.value.initialized
                 ?


             Container(
               clipBehavior: Clip.hardEdge,
               decoration: BoxDecoration(
                   color: Colors.transparent,

                   borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))
               ),
               width: MediaQuery.of(context).size.width,
               height: MediaQuery.of(context).size.height,
               child:   Center(
                 child: AspectRatio(
                   aspectRatio: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height-MediaQuery.of(context).padding.top),
                   child:             VisibilityDetector(
                       key: Key(key),
                       onVisibilityChanged: (VisibilityInfo info) {

                         debugPrint("${info.visibleFraction} of my widget is visible $key");



                         if(info.visibleFraction <0.5){
                           if(controller!=null)
                           if(controller.value.isPlaying) {

                             controller.pause();
                             if(mounted)
                               setState(() {

                               });
                           }
                         }
                         else{
                           if(controller!=null)
                             if(!controller.value.isPlaying) {

                               controller.play();
                               if(mounted)
                                 setState(() {

                                 });
                             }
                         }
                       },
                       child:   CachedVideoPlayer(controller)
                 )
                   ,
                 ),
               ),
             )

                 : SizedBox.shrink(),
           ),

           controller.value.isPlaying ?          SizedBox.shrink(): GestureDetector(
             child:
             Center(
                 child: Container(
                   height: 45,
                   width: 45,
                   child: Icon(Icons.play_arrow, size: 24, color: Colors.white54,),
                   decoration: BoxDecoration(
                       color: Colors.white24,
                       borderRadius:BorderRadius.all( Radius.circular(30))
                   ),
                 )
             ),
             onTap: (){

               playPause();
             },
           ),

           Positioned.directional(
             textDirection: Directionality.of(context),
             end: -10.0,
             bottom: 80.0,
             child: Column(
               children: <Widget>[
                 CustomButton(
                   Icon(
                     isLiked ? Icons.favorite : Icons.favorite_border,
                     color: secondaryColor,
                   ),
                   Functions.getRedableNumber(widget.videoData.likeCount),
                   onPressed: () {

                     widget.videoData.likeUnlikeVideo();
                     setState(() {
                       isLiked = !isLiked;
                     });
                   },
                 ),
                 CustomButton(
                     ImageIcon(
                       AssetImage('assets/icons/ic_comment.png'),
                       color: secondaryColor,
                     ),

                     Functions.getRedableNumber(widget.videoData.commentCount), onPressed: () async {

                   await   showModalBottomSheet(

                       isScrollControlled: true,
                       barrierColor: Colors.black.withOpacity(0.16),
                       backgroundColor: Colors.white.withOpacity(0.1),//backgroundColor.withOpacity(0.3),
                       shape: OutlineInputBorder(
                           borderRadius: BorderRadius.vertical(top: Radius.circular(36.0)),
                           borderSide: BorderSide.none),
                       context: context,
                       builder: (context) {
                         return CommentSheet(context, widget.videoData.id, widget.videoData.username);
                       }
                   );


                 }),
                 CustomButton(
                     ImageIcon(
                       AssetImage('assets/icons/ic_share.png'),
                       color: secondaryColor,
                     ),

                     '', onPressed: () async {

                   String res =    await   showModalBottomSheet(
                       isScrollControlled: true,
                       barrierColor: Colors.black.withOpacity(0.16),
                       backgroundColor: Colors.white.withOpacity(0.02),//backgroundColor.withOpacity(0.3),
                       shape: OutlineInputBorder(
                           borderRadius: BorderRadius.vertical(top: Radius.circular(35.0)),
                           borderSide: BorderSide.none),
                       context: context,
                       builder: (context) {
                         return ShareSheet(context, widget.videoData, );
                       }
                   );

                   if(res == "delete")
                   {
                     int s =  await showModalBottomSheet(
                         isScrollControlled: true,
                         barrierColor: Colors.black.withOpacity(0.16),
                         backgroundColor: Colors.white.withOpacity(0.02),//backgroundColor.withOpacity(0.3),
                         shape: OutlineInputBorder(
                             borderRadius: BorderRadius.vertical(top: Radius.circular(35.0)),
                             borderSide: BorderSide.none),
                         context: context,
                         builder: (context) {
                           List<Widget> l = [];


                           l.add(BottomSheetButton(
                             title: "Confirm",
                             onTap: (){

                               widget.videoData.deletVideo();
                               widget.removeVideo();
                               Navigator.pop(context, 1);




                               Functions.showToast("Video deleting", context);


                             },
                           ));
                           l.add(Container(height: 18,));
                           l.add(BottomSheetButton(
                             title: "Cancel",
                             onTap: (){

                               Navigator.pop(context, 0);

                             },
                           ));
                           return MyBottomSheet(context, list: l, title: "Do you want to delete this video?",
                             textColor: Colors.white,
                             titleSize: 18,
                           );
                         }


                     );

                     if(s == 1)
                     {

                     }


                   }
                   if(res =="report")
                   {
                     int s =  await showModalBottomSheet(
                         isScrollControlled: true,
                         barrierColor: Colors.black.withOpacity(0.16),
                         backgroundColor: Colors.white.withOpacity(0.02),//backgroundColor.withOpacity(0.3),
                         shape: OutlineInputBorder(
                             borderRadius: BorderRadius.vertical(top: Radius.circular(35.0)),
                             borderSide: BorderSide.none),
                         context: context,
                         builder: (context) {
                           List<Widget> l = [];

                           for(int i  =0; i<Variables.reportStatements.length; i++)
                           {
                             l.add(BottomSheetButton(
                               title: Variables.reportStatements[i],
                               onTap: (){

                                 Navigator.pop(context, 1);
                                 widget.videoData.reportVideo(Variables.reportStatements[i]);
                                 widget.removeVideo();

                                 Functions.showToast("Thanks for reporting!", context);
                               },
                             ));
                             l.add(Container(height: 18,));
                           }
                           l.add(BottomSheetButton(
                             title: "Cancel",
                             onTap: (){

                               Navigator.pop(context, 0);

                             },
                           ));
                           return MyBottomSheet(context, list: l,);
                         }


                     );

                     if(s == 1)
                     {

                     }


                   }

                 }),




               ],
             ),
           ),



           Positioned.directional(
             textDirection: Directionality.of(context),
             start: 13.0,
             bottom: 90.0,
             child: TextContainer(description: widget.videoData.description, videoData: widget.videoData,),
           )
         ],
       ),
     ));
  }

  playPause(){
    controller.value.isPlaying
        ? controller.pause()
        : controller.play();

    setState(() {

    });

  }


}






















class TextContainer extends StatefulWidget {

  final String description;
  final Videos videoData;

  const TextContainer({Key key, this.description, this.videoData}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<TextContainer> {

  int maxLines = 1;
  double opacity = 0.30;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
     GestureDetector(
       child:    Row(
         mainAxisSize: MainAxisSize.min,

         crossAxisAlignment: CrossAxisAlignment.center,
         children: <Widget>[
           Container(
               height: 35,
                width: 35,
               decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color:  Colors.black26,
                      blurRadius: 5,
                      //spreadRadius: 20,

                      offset: Offset(0, 1))
                ],
                 borderRadius: BorderRadius.all(Radius.circular(30))
                    
                     
               ),
               child: Center(
                 child: Functions.showProfileImage(widget.videoData.profile_pic, 35, widget.videoData.verified, isCache: true),
               )
             ),
            Container(width: 4,),
            Container(height: 40,

             child: Padding(
               padding: EdgeInsets.only(top: 9 ),
               child: Text(
                   '@${widget.videoData.username}',
                   style: Theme.of(context).textTheme.bodyText1.copyWith(
                       fontSize: 15.0,
                       fontWeight: FontWeight.w600,
                       shadows: [
                         Shadow(
                             color:  Colors.black45,
                             blurRadius: 2,

                             offset: Offset(0, 1))
                       ]
                   )),
             ),)

         ],
       ),
       onTap: () {
         //controller.pause();
         Navigator.push(
           context,
           MaterialPageRoute(builder: (context) =>   UserProfilePage(fb_id: widget.videoData.fb_id,)),
         );
       },
     ),
       Container(height: 7,),
       widget.description.length == 0?Container():Container(
           // height: 51,
            width: MediaQuery.of(context).size.width - 100,
            child: HashTagText(
              text: widget.description,
              normalTextStyle: TextStyle(fontSize: 14.3,
                  shadows: [
                    Shadow(
                        color:  Colors.black.withOpacity(opacity),
                        blurRadius: 2,
                        offset: Offset(0, 1))
                  ]

              ),
                hashTagStyle: TextStyle(fontSize: 14.0,
                    color: Colors.white.withOpacity(0.7),
                    shadows: [
                      Shadow(
                          color:  Colors.black.withOpacity(opacity),
                          blurRadius: 2,
                          offset: Offset(0, 1))
                    ]

                ),
              onHashTagClick: (s){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VideosByHashtag(

                    title:  "Hashtag"  ,
                    list: [],
                    hashtag:s,
                  )),
                );
              },
            )

        )
        ,
        widget.videoData.description.length>20? GestureDetector(
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 1, 4, 5),
            child: Text(maxLines==1? "See More" :"See less", style: TextStyle(
                inherit: false,

              //  fontStyle: FontStyle.italic,
                color: Colors.white70


            ),),
          ),
          onTap:maxLines==1?  () {
            opacity = 0.43;
            setState(() {
              maxLines = 15;
            });

           }:  (){
            opacity = 0.3;
            setState(() {
              maxLines = 1;
            });
          },
        ):

        Container(),

        Container(height: 7,),
        GestureDetector(
          child: Row(
            children: [
              Icon(Icons.music_note, color: Colors.white, size: 19,),
              RichText(
                text: TextSpan(children: [

                  TextSpan(text: widget.videoData.sound ==null?  "Original Sound @${widget.videoData.username}"  :
                  !Functions.isNullEmptyOrFalse(widget.videoData.sound.sound_name) ? widget.videoData.sound.sound_name  :
                  "Original Sound @${widget.videoData.username}", ),

                ]),
              )
            ],
          ),onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VideosBySound(
              isOriginalAud: widget.videoData.sound ==null?  true  :
              !Functions.isNullEmptyOrFalse(widget.videoData.sound.sound_name) ? false :
              true,
              title: widget.videoData.sound ==null?  "Original Sound @${widget.videoData.username}"  :
              !Functions.isNullEmptyOrFalse(widget.videoData.sound.sound_name) ? widget.videoData.sound.sound_name  :
              "Original Sound @${widget.videoData.username}",
              list: [widget.videoData],
              soundId: widget.videoData.sound.id.toString(),
            )),
          );
        },
        ),
      ],
    );
  }



/*  TextSpan getHashTagSpans(){
    Text(widget.description,   textAlign: TextAlign.left,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 14.0,
          shadows: [
            Shadow(
                color:  Colors.black.withOpacity(opacity),
                blurRadius: 2,
                offset: Offset(0, 1))
          ]

      ),
      maxLines: maxLines,);
  }*/
}
