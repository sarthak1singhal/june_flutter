import 'package:flutter/material.dart';
import 'package:qvid/BottomNavigation/Home/following_tab.dart';
import 'package:qvid/BottomNavigation/Home/home_page.dart';
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
  ScrollController scrollController;
  int type; // 1 for videos by userID, 2 for my liked videos, 3 for by hashtag videos, 4 for by soundVideos


  NewScreenGrid(this.list, {this.isLoading, this.icon, this.onTap, this.viewIcon, this.views, this.scrollController});

  @override
  _MyHomePageState createState() => _MyHomePageState(list);
}

class _MyHomePageState extends State<NewScreenGrid>  {
  final List list;
  bool isLoading = false;

  ScrollController _scrollController = new ScrollController();

  _MyHomePageState(this.list);














  fetchMore(){

  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();



    if(widget.scrollController!=null)
    {
      widget.scrollController.addListener(() {


        print(widget.scrollController.position.extentAfter );
        // double currentScroll = _scrollController.position.pixels;
        if (widget.scrollController.position.extentAfter < 200) {

          fetchMore();

          /*  setState(() {
          //   items.addAll(new List.generate(42, (index) => 'Inserted $index'));
        });*/
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
            SliverGrid(
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
                    },
                    childCount: list.length
                )
            ),
            SliverList(

              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        child: Functions.showLoaderBottom(),
                        padding: EdgeInsets.only(top: 20, bottom: 20),
                      )
                    ],
                  );
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


}


