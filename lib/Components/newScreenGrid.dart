import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qvid/BottomNavigation/Home/following_tab.dart';
import 'package:qvid/BottomNavigation/Home/home_page.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Functions/Videos.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Theme/colors.dart';

class Grid {
  Grid(this.imgUrl, this.views);

  String imgUrl;
  String views;
}

class NewScreenGrid extends StatefulWidget {
  final IconData icon;
  final List list;
  final Function onTap;
  final IconData viewIcon;
  final bool isLoading;
  final String views;
  final GlobalKey<ScaffoldState> _scaffoldkey ;

  final String hashtag;
  final String soundId;
  ScrollController scrollController;
  int type; // 3 for videos by hashtag, 4 for my liked soundVideos

  NewScreenGrid(
      this.type,
      this._scaffoldkey,
      {this.list,
        this.isLoading,
       @required this.hashtag,
        @required this.soundId,
      this.icon,
      this.onTap,
      this.viewIcon,
      this.views,
      this.scrollController});

  @override
  _MyHomePageState createState() => _MyHomePageState(list);
}

class _MyHomePageState extends State<NewScreenGrid> {
  List<Videos> list = [];
  bool isLoading = false;
  bool isExistMore = true;
  String errorMessage = "";
  bool isError= false;
  ScrollController _scrollController = new ScrollController();

  int offset = 0;
  _MyHomePageState(this.list);

  fetchMore() async {

    if(!isExistMore)
      {
        return;
      }
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });




      try {


        var res = await Functions.postReq(widget.type == 3 ? Variables.showVideoByHashtag : Variables.showVideosBySound, jsonEncode({
          "hashtag": widget.hashtag,
          "sound_id" : widget.soundId,
          "offset" : offset,
          "limit" : 21
        }), context);


        var data = jsonDecode(res.body);

        if(!data["isError"])
          {

            int len = data["msg"].length;
            offset = offset + 21;
            if(len<21)
              {
                isExistMore = false;
              }

            list.addAll(Functions.parseVideoList(data["msg"]));


          }else{
          isError = true;
          errorMessage = "Some error occured";
        }


      } catch (e) {
        isLoading  = false;
        isError = true;
        errorMessage = Variables.connErrorMessage;
        print(e);

      }





      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(list == null)
      list = [];

    offset = list.length;
    if(!(widget.type ==3 ||widget.type==4) )
      {
        print(widget.type);
        //Functions.showSnackBar(widget._scaffoldkey, "ERROR");
      }
    fetchMore();
    if (_scrollController != null) {
      _scrollController.addListener(() {
        print(_scrollController.position.extentAfter);
        // double currentScroll = _scrollController.position.pixels;
        if (_scrollController.position.extentAfter < 200) {
          fetchMore();

        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overscroll) {
          overscroll.disallowGlow();
          return;
        },
        child: CustomScrollView(
          slivers: <Widget>[
            isError? SliverToBoxAdapter(
              child: Container(
                height: MediaQuery.of(context).size.height-180,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Functions.showError(errorMessage),
                ),
              ),
            ): SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2 / 2.5,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 3,
                ),
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FollowingTabPage(list, index, widget.type, widget.type == 3 ? Variables.showVideoByHashtag : Variables.showVideosBySound,
                                widget.type == 3 ? widget.hashtag : widget.soundId,
                                videos1, imagesInDisc1, false,
                                variable: 1))),
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(list[index].thumb_url), fit: BoxFit.fill),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: EdgeInsets.all(8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                                widget.viewIcon,
                                color: secondaryColor,
                                size: 15,
                              ) ??
                              SizedBox.shrink(),
                          widget.views != null
                              ? Text(' ' + widget.views)
                              : SizedBox.shrink(),
                          Spacer(),
                          Icon(
                                widget.icon,
                                color: mainColor,
                              ) ??
                              SizedBox.shrink(),
                        ],
                      ),
                    ),
                  );
                }, childCount: list.length)),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return isLoading? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        child: Functions.showLoaderBottom(),
                        padding: EdgeInsets.only(top: 20, bottom: 20),
                      )
                    ],
                  ) : Container();
                },
                childCount: 1,
              ),
            )
          ],
        )
        );
  }
}
