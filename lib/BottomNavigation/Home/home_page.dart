import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qvid/BottomNavigation/Home/following_tab.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Theme/colors.dart';



class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HomeBody();
  }
}

class HomeBody extends StatefulWidget {
  @override
  _HomeBodyState createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> with SingleTickerProviderStateMixin ,
AutomaticKeepAliveClientMixin<HomeBody> {


  TabController _tabController;

   @override
  Widget build(BuildContext context) {
    List<Tab> tabs = [
      Tab(text: AppLocalizations.of(context).following,  ),
      Tab(text: AppLocalizations.of(context).related),
    ];
    return DefaultTabController(

      length: tabs.length,
      child: Stack(
        children: <Widget>[
          TabBarView(
            controller: _tabController,


            children: <Widget>[
              FollowingTabPage([], 0, 6, Variables.home_videos,"", false, 0, k: Functions.generateRandomString(4),),
              FollowingTabPage([], 0, 7, Variables.videos_following,"", true, 0, k: Functions.generateRandomString(4),),
            ],
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Stack(
                children: [
                  TabBar(
                    controller: _tabController,

                    isScrollable: true,
                    labelStyle: Theme.of(context).textTheme.bodyText1.copyWith(
                      inherit: false,
                        fontSize: 17,
                        shadows: [
                          Shadow(
                              color:  Colors.black45,
                              blurRadius: 2,

                              offset: Offset(0, 1))
                        ]
                    ),
                    unselectedLabelStyle: Theme.of(context).textTheme.bodyText1.copyWith(
                        inherit: false,
                        fontSize: 15,
                        shadows: [
                          Shadow(
                              color:  Colors.black26,
                              blurRadius: 2,

                              offset: Offset(0, 1))
                        ]
                    ),
                    indicator: BoxDecoration(color: transparentColor),
                    tabs: tabs,

                  ),
                 /* Positioned.directional(
                    textDirection: Directionality.of(context),
                    top: 14,
                    start: 84,
                    child: CircleAvatar(
                      backgroundColor: mainColor,
                      radius: 3,
                    ),
                  ),*/
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int current = 0;
  @override
  void initState() {

    super.initState();
    _tabController = new TabController(vsync: this, length: 2);
    _tabController.addListener((){

      if(_tabController.index != current)
        {
          print(current);
          print(_tabController.index);
          if(_tabController.index == 1) {
         //   tab1.pauseOnTabChange();
          }
          else{
       //     tab2.pauseOnTabChange();
          }
          current= _tabController.index;
        }

    });


  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;


}
