import 'dart:convert';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  Future<void> getData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String fb_id = preferences.getString(Variables.fbid_String);

    var s = await Functions.postReq(Variables.videosByUserId, json.encode({
      "fb_id": widget.userFb_id,
      "my_fb_id": fb_id
    }), context);
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
      appBar: AppBar(),
      body: SmartRefresher(
          physics: BouncingScrollPhysics(),
          enablePullDown: true,
          header: ClassicHeader(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          // onLoading: isLoading,
          child: DefaultTabController(
            length: 2,
            child: SafeArea(
              child: NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                     /* AppBar(
                     //   expandedHeight: 40.0,

                        actions: <Widget>[
                          PopupMenuButton(
                            color: backgroundColor,
                            icon: Icon(
                              Icons.more_vert,
                              color: secondaryColor,
                            ),
                            shape: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none),
                            itemBuilder: (BuildContext context) {
                              return [
                                PopupMenuItem(
                                  child: Text(locale.report),
                                  value: locale.report,
                                  textStyle: TextStyle(color: secondaryColor),
                                ),
                                PopupMenuItem(
                                  child: Text(locale.block),
                                  value: locale.block,
                                  textStyle: TextStyle(color: secondaryColor),
                                ),
                              ];
                            },
                          )
                        ],

                      ),*/

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
                                       Container(height: 65,width: 65,
                                         child: CircleAvatar(
                                           radius: 28.0,
                                           backgroundImage:
                                           AssetImage('assets/images/user.webp'),
                                         ),
                                       ),

                                       Container(width: 22,),

                                       Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: <Widget>[
                                           Text(
                                             'Samantha Smith',
                                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                                           ),

                                           Container(height: 10,),
                                           Text(
                                             '@imsamanthasmith',
                                             style: TextStyle(
                                                 fontSize: 14, color: disabledTextColor),
                                           ),

                                         ],
                                       )],
                                   ),

                                   Container(height: 20,),

                                   Wrap(
                                     children: <Widget>[
                                       Text(
                                         locale.comment5,
                                         textAlign: TextAlign.left,
                                         style: TextStyle(fontSize: 14),
                                       ),
                                     ],
                                   ),

                                   Row(
                                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                     children: <Widget>[
                                       RowItem(
                                           '1.2m',
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
                                           '12.8k', locale.followers, FollowersPage()),
                                       RowItem(
                                           '1.9k', locale.following, FollowingPage()),
                                     ],
                                   ),
                                 ],
                               ),
                             )
                            ]
                        ),
                      )

                    ];
                  },



                  body: Column(
                    children: <Widget>[
                      TabBar(
                          labelColor: mainColor,
                          unselectedLabelColor: lightTextColor,
                          indicatorColor: transparentColor,
                          tabs: [
                            Tab(icon: Icon(Icons.dashboard)),
                            Tab(
                                icon: ImageIcon(AssetImage(
                                  'assets/icons/ic_like.png',
                                )))]
                      ),
                      Expanded(
                        child: TabBarView(
                          children: <Widget>[
                            TabGrid(dance, widget.userFb_id,1 ),
                            TabGrid(food + lol,widget.userFb_id, 2),
                          ],
                        ),
                      )
                    ],



                  )
              ),
            )),
    ));
  }


}
