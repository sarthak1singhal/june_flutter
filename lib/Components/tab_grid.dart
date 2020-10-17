import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qvid/BottomNavigation/Home/following_tab.dart';
import 'package:qvid/BottomNavigation/Home/home_page.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Model/Videos.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Theme/colors.dart';

class Grid {
  Grid(this.imgUrl, this.views);
  String imgUrl;
  String views;
}


class TabGrid extends StatefulWidget {
  final IconData icon;
  final List<Videos> list;
  final Function onTap;
  final IconData viewIcon;
  final String userId;
  final bool isLoading;
  final bool isRequestMade;
   ScrollController scrollController;
  int type; // 1 for videos by userID, 2 for my liked videos, 3 for by search videos


  TabGrid(this.list, this.userId, this.type, {this.isLoading, this.icon, this.onTap, this.viewIcon,  this.scrollController, this.isRequestMade});

  @override
  _MyHomePageState createState() => _MyHomePageState(list);
}

class _MyHomePageState extends State<TabGrid> with
    AutomaticKeepAliveClientMixin<TabGrid> {
  final List<Videos> list;


  _MyHomePageState(this.list);








  @override
  void initState() {
    // TODO: implement initState
    super.initState();

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
              widget.isRequestMade && list.length == 0? Functions.noVideoByUser(context): SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,
                  childAspectRatio: 2 / 2.5,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 3,
                ),
                delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      return      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FollowingTabPage(
                                  list, index, widget.type, widget.type==1 ? Variables.videosByUserId : Variables.my_liked_video,null,
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
                              !Functions.isNullEmptyOrFalse(list[index].views.toString()) ? Text(' ' + list[index].views.toString()) : SizedBox.shrink(),
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
                    },
                    childCount: list.length
                )
            ),
            SliverList(

              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  return  widget.isLoading ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        child: Functions.showLoaderBottom(),
                        padding: EdgeInsets.only(top: 20, bottom: 20),
                      )
                    ],
                  ):Container();
                },
                childCount: 1,

              ),
            )
          ],
        )/*GridView.builder(
            controller:              widget.scrollController,
            //    physics: ScrollPhysics(),
            itemCount: list.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2 / 2.5,
              crossAxisSpacing: 3,
              mainAxisSpacing: 3,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FollowingTabPage(
                            videos1, imagesInDisc1, false,
                            variable: 1))),
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(list[index]), fit: BoxFit.fill),
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
                      widget.views != null ? Text(' ' + widget.views) : SizedBox.shrink(),
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
            })*/
    );





  }












  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}


