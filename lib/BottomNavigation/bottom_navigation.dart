import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qvid/BottomNavigation/Explore/explore_page.dart';
import 'package:qvid/BottomNavigation/Home/home_page.dart';
import 'package:qvid/BottomNavigation/MyProfile/my_profile_page.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Routes/routes.dart';
import 'package:qvid/BottomNavigation/Notifications/notification_messages.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:qvid/Theme/style.dart';

import 'Explore/explore_page_current.dart';
import 'Home/following_tab.dart';

class BottomNavigation extends StatefulWidget {

   @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;


  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

  }

  final List<Widget> _children = [
    HomePage(),
    CurrentExplorePage(),//ExplorePage(),
    Container(),
    NotificationMessages(),
    MyProfilePage(),
  ];

  void onTap(int index) {
    if (index == 2) {

      Navigator.pushNamed(context, PageRoutes.addVideoPage);
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }
  final pageController = PageController();

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    final List<BottomNavigationBarItem> _bottomBarItems = [
      BottomNavigationBarItem(
        icon: ImageIcon(AssetImage('assets/icons/ic_home.png')),
        activeIcon: ImageIcon(AssetImage('assets/icons/ic_homeactive.png')),
        title: Text(locale.home),
      ),
      BottomNavigationBarItem(
        icon: ImageIcon(AssetImage('assets/icons/ic_explore.png')),
        activeIcon: ImageIcon(AssetImage('assets/icons/ic_exploreactive.png')),
        title: Text(locale.explore),
      ),
      BottomNavigationBarItem(
        icon: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            decoration: BoxDecoration(
              borderRadius: radius,
              color: mainColor,
            ),
            child: Icon(Icons.add)),
        title: SizedBox.shrink(),
      ),
      BottomNavigationBarItem(
        icon: ImageIcon(AssetImage('assets/icons/ic_notification.png')),
        activeIcon: ImageIcon(AssetImage('assets/icons/ic_notificationactive.png')),
        title: Text(locale.notification),
      ),
      BottomNavigationBarItem(
        icon: ImageIcon(AssetImage('assets/icons/ic_profile.png')),
        activeIcon: ImageIcon(AssetImage('assets/icons/ic_profileactive.png')),
        title: Text(locale.profile),
      ),
    ];
    return Scaffold(
      body: Stack(
        children: <Widget>[
          PageView(
            physics: NeverScrollableScrollPhysics(),
             children: _children,
            controller: pageController,
            onPageChanged: onTap,
          ),
           Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 60,
              decoration: BoxDecoration(

                border: _currentIndex == 0? null : Border(
                  top: BorderSide(
                    color: Colors.white38,
                    width: 0.2,
                  ),
                ),
              ),
               child: _currentIndex ==2? Container():BottomNavigationBar(
                // key: widget.navigatorKey,
                currentIndex: _currentIndex,
                backgroundColor: _currentIndex == 0? Colors.black12:bottomNavColor,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                iconSize: 22.0,
                selectedItemColor: secondaryColor,
                selectedFontSize: 12,
                unselectedFontSize: 10,
                unselectedItemColor: secondaryColor,
                items: _bottomBarItems,
                onTap: (index){
                  if (index == 2) {

                    Navigator.pushNamed(context, PageRoutes.addVideoPage);
                  } else {
                    pageController.jumpToPage(index);

                  }

                },
              ),
            )
          ),


        ],
      ),
    );
  }
}
