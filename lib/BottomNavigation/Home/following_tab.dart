import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qvid/Auth/login_navigator.dart';
import 'package:qvid/BottomNavigation/Home/comment_sheet.dart';
import 'package:qvid/Components/custom_button.dart';
import 'package:qvid/Components/rotated_image.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Routes/routes.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:video_player/video_player.dart';

class FollowingTabPage extends StatelessWidget {
  final List<String> videos;
  final List<String> images;
  final bool isFollowing;

  final int variable;

  FollowingTabPage(this.videos, this.images, this.isFollowing, {this.variable});

  @override
  Widget build(BuildContext context) {
    return FollowingTabBody(videos, images, isFollowing, variable);
  }
}

class FollowingTabBody extends StatefulWidget {
  final List<String> videos;
  final List<String> images;

  final bool isFollowing;
  final int variable;

  FollowingTabBody(this.videos, this.images, this.isFollowing, this.variable);

  @override
  FollowingTabBodyState  createState() => FollowingTabBodyState ();
}

class FollowingTabBodyState extends State<FollowingTabBody> {
  PageController _pageController;
  int current = 0;
  bool isOnPageTurning = false;
  PersistentBottomSheetController _controller;
  bool _open = false;
  GlobalKey<ScaffoldState> _key = GlobalKey();

  void scrollListener() {
    if (isOnPageTurning &&
        _pageController.page == _pageController.page.roundToDouble()) {
      setState(() {
        current = _pageController.page.toInt();
        isOnPageTurning = false;
      });
    } else if (!isOnPageTurning && current.toDouble() != _pageController.page) {
      if ((current.toDouble() - _pageController.page).abs() > 0.1) {
        setState(() {
          isOnPageTurning = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(scrollListener);
  }

  static var c;

  static closeSheet()
  {
     Navigator.pop(c);
  }


  @override
  Widget build(BuildContext context) {
    print("SSS");
    c = context;
    return PageView.builder(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      controller: _pageController,
      itemBuilder: (context, position) {
        return VideoPage(
          widget.videos[position],
          widget.images[position],
          pageIndex: position,
          currentPageIndex: current,
          isPaused: isOnPageTurning,
          isFollowing: widget.isFollowing,
        );
      },
/*      onPageChanged: Variables.token == null
          ? (i) async {
              if (i == 2) {
                await showModalBottomSheet(
                   shape: OutlineInputBorder(
                      borderSide: BorderSide(color: transparentColor),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16.0))),
                  context: context,
                  isScrollControlled: true,
                  isDismissible: false,
                  builder: (context) {
                    return Container(
                        height: MediaQuery.of(context).size.width * 1.5,
                        child: LoginNavigator("following"));
                  },
                );
              }
            }
          : null,*/
      itemCount: widget.videos.length,
    );
  }
}

class VideoPage extends StatefulWidget {
  final String video;
  final String image;
  final int pageIndex;
  final int currentPageIndex;
  final bool isPaused;
  final bool isFollowing;
  final String videoUrl;

  VideoPage(this.video, this.image,
      {this.pageIndex, this.currentPageIndex, this.isPaused, this.isFollowing, this.videoUrl});

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  CachedVideoPlayerController _controller;
  bool initialized = false;
  bool isLiked = false;



  @override
  void initState() {
    super.initState();

    _controller = CachedVideoPlayerController.network("https://multiplatform-f.akamaihd.net/i/multi/april11/sintel/sintel-hd_,512x288_450_b,640x360_700_b,768x432_1000_b,1024x576_1400_m,.mp4.csmil/master.m3u8", )
      ..initialize().then((value) {


        setState(() {
          /*if (widget.pageIndex == widget.currentPageIndex &&
              !widget.isPaused &&
              initialized) {
            _controller.play();
          } else {
            _controller.pause();
          }*/
          print("PLAYED");
          _controller.setLooping(true);
          initialized = true;
          _controller.play();

        });

      });

  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  //  print(initialized);

    var locale = AppLocalizations.of(context);

     return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
          children: <Widget>[


            GestureDetector(
            onTap: () {
               playPause();
            },
              onDoubleTap: (){


              },
            child: _controller.value.initialized
                ?


                Container(
                  color: Colors.transparent,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child:   Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child:             CachedVideoPlayer(_controller)
                      ,
                    ),
                  ),
                )

                : SizedBox.shrink(),
          ),

    _controller.value.isPlaying ?          SizedBox.shrink(): GestureDetector(
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
                  '8.2k',
                  onPressed: () {
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
                    '287', onPressed: () {
                  commentSheet(context);
                }),
                /*Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: RotatedImage(widget.image),
                ),*/
              ],
            ),
          ),
          widget.isFollowing
              ? Positioned.directional(
                  textDirection: Directionality.of(context),
                  end: 27.0,
                  bottom: 320.0,
                  child: CircleAvatar(
                      backgroundColor: mainColor,
                      radius: 8,
                      child: Icon(
                        Icons.add,
                        color: secondaryColor,
                        size: 12.0,
                      )),
                )
              : SizedBox.shrink(),


          Positioned.directional(
            textDirection: Directionality.of(context),
            start: 12.0,
            bottom: 120.0,
            child: Row(
              mainAxisSize: MainAxisSize.min,

              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    _controller.pause();
                    Navigator.pushNamed(context, PageRoutes.userProfilePage);
                  },
                  child: Container(
                    height: 30,
                    width: 30,
                    child: CircleAvatar(

                        backgroundImage: AssetImage('assets/images/user.webp')),
                  ),
                ),
                Container(width: 9,),
                Container(height: 30,

                  child: Padding(
                    padding: EdgeInsets.only(top: 4.5),
                    child: Text(
                        '@emiliwilliamson',
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                          fontSize: 14.0,)),
                  ),)

              ],
            )
          ),


          Positioned.directional(
            textDirection: Directionality.of(context),
            start: 12.0,
            bottom: 72.0,
            child: RichText(
              text: TextSpan(children: [

                TextSpan(text: locale.comment8),
                TextSpan(
                    text: '  ${locale.seeMore}',
                    style: TextStyle(
                        color: secondaryColor.withOpacity(0.5),
                        fontStyle: FontStyle.italic))
              ]),
            ),
          )
        ],
      ),
    );
  }

  playPause(){
    _controller.value.isPlaying
        ? _controller.pause()
        : _controller.play();

    setState(() {

    });

  }


}
