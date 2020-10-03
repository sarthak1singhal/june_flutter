import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllCampaigns extends StatefulWidget {

  final double topHeight;

  const AllCampaigns( this.topHeight) ;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<AllCampaigns>
    with AutomaticKeepAliveClientMixin<AllCampaigns> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  ScrollController controller = ScrollController();

  bool isMore = true;
  bool moreLoad = false;

  @override
  void initState() {
    super.initState();
     for(int i = 0; i< 100;i++)
{
  list.add("dadad");
}
    controller.addListener(() async {
      double max = controller.position.maxScrollExtent;
      double current = controller.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      if (isMore) {
        if (max - current <= delta) {
          getMore();
        }
      }
    });

     setState(() {

     });
  }

  void getMore() async {

  }

  @override
  void dispose() {
    super.dispose();
  }

  bool isLoading = true;
  int pageNo = 0;

  bool error = false;

  dynamic list = [];

  Future <bool> loadData() async {


    setState(() {
      isLoading = false;
    });

    return true;

  }

  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    pageNo = 0;
    isMore = true;
    await loadData();
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
    setState(() {});
  }
  double width = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    width = MediaQuery.of(context).size.width;

    print(widget.topHeight);

    return SmartRefresher(
      physics: BouncingScrollPhysics(),
        enablePullDown: true,
        header: ClassicHeader(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        // onLoading: isLoading,
        child:Stack(
      children: <Widget>[
         ListView.builder(
         physics: BouncingScrollPhysics(),
                controller: controller,
                itemCount: list.length,
                itemBuilder: (c, i) {
                  return Container(
                      //constraints: BoxConstraints(minHeight: 110, maxHeight: 150),
                      height: 160,
                       child: Stack(
                        children: <Widget>[
                          GestureDetector(
                            child: Stack(
                              children: <Widget>[
                                Positioned(
                                  left: 20,
                                  child: Container(
                                    constraints: BoxConstraints(
                                        minHeight: 140,
                                        maxHeight: 140,
                                        maxWidth: width - 30,
                                        minWidth: width - 30),
                                    child: Text("SASASA"),

                                  ),
                                ),

                              ],
                            ),
                            onTap: () {



                            },
                          ),

                          //type==0 || isSearching ? searchable[i].uploaderName == uid ? getPopup(i,2) : Container():list[i].uploaderName == uid ? getPopup(i,1) : Container()
                        ],
                      ));
                })
      ],
    ));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}



