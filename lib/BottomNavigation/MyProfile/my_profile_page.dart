import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:qvid/Components/profile_page_button.dart';
import 'package:qvid/Components/row_item.dart';
import 'package:qvid/Components/sliver_app_delegate.dart';
import 'package:qvid/Components/tab_grid.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Routes/routes.dart';
import 'package:qvid/BottomNavigation/MyProfile/edit_profile.dart';
import 'package:qvid/BottomNavigation/MyProfile/followers.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:qvid/BottomNavigation/Explore/explore_page.dart';
import 'package:qvid/BottomNavigation/MyProfile/following.dart';

class MyProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyProfileBody();
  }
}

class MyProfileBody extends StatefulWidget {
  @override
  _MyProfileBodyState createState() => _MyProfileBodyState();
}

class _MyProfileBodyState extends State<MyProfileBody> {
  final key = UniqueKey();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }



  getData(){

  }





  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);

    if(Variables.token == null)
      {
        return(Container());
      }

    return  Padding(
      padding: EdgeInsets.only(bottom: 64.0),
      child: Scaffold(
        backgroundColor: darkColor,
        body: DefaultTabController(
          length: 3,
          child: SafeArea(
            child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: 404.0,
                    floating: false,
                    actions: <Widget>[
                      Theme(
                        data: Theme.of(context).copyWith(
                          cardColor: backgroundColor,
                        ),
                        child: PopupMenuButton(
                          icon: Icon(
                            Icons.more_vert,
                            color: secondaryColor,
                          ),
                          shape: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none),
                          onSelected: (value) {
                            if (value == locale.help) {
                              Navigator.pushNamed(context, PageRoutes.helpPage);
                            } else if (value == locale.termsOfUse) {
                              Navigator.pushNamed(context, PageRoutes.tncPage);
                            } else if (value == locale.logout) {
                              Phoenix.rebirth(context);
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem(
                                child: Text(locale.help),
                                value: locale.help,
                                textStyle: TextStyle(color: secondaryColor),
                              ),
                              PopupMenuItem(
                                child: Text(locale.termsOfUse),
                                value: locale.termsOfUse,
                                textStyle: TextStyle(color: secondaryColor),
                              ),
                              PopupMenuItem(
                                child: Text(locale.logout),
                                value: locale.logout,
                                textStyle: TextStyle(color: secondaryColor),
                              )
                            ];
                          },
                        ),
                      )
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Column(
                        children: <Widget>[
                          Spacer(flex: 10),


                          CircleAvatar(
                            radius: 28.0,
                            backgroundImage:
                            AssetImage('assets/images/user.webp'),
                          ),
                          Spacer(),
                          Text(
                            'Samantha Smith',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '@imsamanthasmith',
                            style: TextStyle(
                                fontSize: 10, color: disabledTextColor),
                          ),
                          Spacer(),
/*
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ImageIcon(
                                AssetImage("assets/icons/ic_fb.png"),
                                color: secondaryColor,
                                size: 10,
                              ),
                              SizedBox(width: 16),
                              ImageIcon(
                                AssetImage("assets/icons/ic_twt.png"),
                                color: secondaryColor,
                                size: 10,
                              ),
                              SizedBox(width: 16),
                              ImageIcon(
                                AssetImage("assets/icons/ic_insta.png"),
                                color: secondaryColor,
                                size: 10,
                              ),
                            ],
                          ),
*/
                          Spacer(),
                          Text(
                            locale.comment5,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 8),
                          ),
                          Spacer(),
                          ProfilePageButton(
                            locale.editProfile,
                                () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditProfile()));
                            },
                            width: 120,
                          ),
                          Spacer(),
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
                                    body: TabGrid(
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
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: SliverAppBarDelegate(
                      TabBar(
                        labelColor: mainColor,
                        unselectedLabelColor: lightTextColor,
                        indicatorColor: transparentColor,
                        tabs: [
                          Tab(icon: Icon(Icons.dashboard)),
                          Tab(icon: Icon(Icons.favorite_border)),
                          Tab(icon: Icon(Icons.bookmark_border)),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                children: <Widget>[
                  TabGrid(
                    food + food,
                    viewIcon: Icons.remove_red_eye,
                    views: '2.2k',
                    onTap: () => Navigator.pushNamed(
                        context, PageRoutes.videoOptionPage),
                  ),
                  TabGrid(
                    dance,
                    icon: Icons.favorite,
                  ),
                  TabGrid(
                    lol,
                    icon: Icons.bookmark,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

  }
}
