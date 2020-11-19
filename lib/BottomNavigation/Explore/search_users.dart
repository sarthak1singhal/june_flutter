import 'dart:convert';
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qvid/BottomNavigation/Explore/explore_page.dart';
import 'package:qvid/Components/newScreenGrid.dart';
import 'package:qvid/Components/searchGrid.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Model/Videos.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Routes/routes.dart';
import 'package:qvid/Screens/user_profile.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:qvid/Extension/extensions.dart';
import 'package:qvid/Components/tab_grid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  String name;
  String id;
  String img;
  User(this.name, this.id, this.img);
}

class SearchUsers extends StatefulWidget {
  @override
  _SearchUsersState createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers>  with SingleTickerProviderStateMixin,    AutomaticKeepAliveClientMixin<SearchUsers> {
  var _controller = TextEditingController();


  bool isLoading = false;


  List<Videos> videos = [];



  search(String v) async{

    setState(() {
      isLoading = true;
    });


    if(primaryTC.index == 1)
      {
        if(v.length==0)
          {
            users = [];
          }
      }
    try{


      int tab = primaryTC.index;

          String url = Variables.search;
          url = Uri.encodeFull(url);

          print(url);
      Functions fx = Functions();

      var res = await Functions.unsignPostReq(url, jsonEncode({
            "type" : tab == 0? "video" : "users",
            "keyword" : v.length == 0? " " : v
          }));

          var data  = jsonDecode(res.body);
          print(data);

          parseData(tab, data);





    }catch(e)
    {   setState(() {
      isLoading = false;
    });
      debugPrint(e);
    }

    setState(() {
      isLoading = false;
    });


    //print();

  }

  List users = [];

  TabController primaryTC;


  String prevText = "";


  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  parseData(int reqTab, data){
    int currentTab  = primaryTC.index;
    if(currentTab != reqTab)
      return;



    if(Functions.isNullEmptyOrFalse(data["msg"]))
      {
        Functions.showSnackBar(_scaffoldKey, "Some Error Occured");
        return;
      }


    if(reqTab == 0)
      {

        videos = Functions.parseVideoList(data["msg"],context);

      }
    if(reqTab==1)
      {

        users = data["msg"];
        print(users);
      }

  }






  @override
  void initState() {
    super.initState();
    primaryTC = new TabController(length: 2, vsync: this);
    primaryTC.addListener(() {


      if(prevText!=_controller.text)
        {
          prevText = _controller.text;
          search(_controller.text);
        }


     });
  }



  @override
  Widget build(BuildContext context) {
    var local = AppLocalizations.of(context);
    return DefaultTabController(
       length: 2,
      child: Scaffold(
        backgroundColor: bottomNavColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(30),
            child:Container(
             // color: bottomNavColor,
              child:  Container(
                  margin:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: darkColor,
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: Row(
                    children: <Widget>[

                      Container(
                        height: 45,
                        width: MediaQuery.of(context).size.width-100,
                        child:  TextField(
                          controller: _controller,

                          onChanged: (v){

                            if(v.length>2 && v.length<23)
                              search(v);
                          },
                          decoration: InputDecoration(
                            icon: IconButton(
                              icon: Icon(Icons.arrow_back),
                              color: secondaryColor,
                              onPressed: () => Navigator.pop(context),
                            ),
                            border: InputBorder.none,

                            hintText: AppLocalizations.of(context).search,
                            hintStyle: Theme.of(context).textTheme.subtitle1,

                          ),
                        ),
                      ),
                      Spacer(),
                      isLoading ? Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: Container(height: 15,width: 15, child: CircularProgressIndicator(strokeWidth: 2,),),
                      ) : Container(
                        width: 20,
                      )

                    ],
                  )
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Container(height: 6,),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
              child: TabBar(
                controller: primaryTC,

                indicator: BoxDecoration(color: transparentColor),
                isScrollable: true,
                labelColor: Colors.white,

                 labelStyle: Theme.of(context).textTheme.headline6.copyWith(
                    fontSize: 18.7,  fontWeight: FontWeight.bold
                ),unselectedLabelStyle: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.w400),
                unselectedLabelColor: disabledTextColor,
                tabs: <Widget>[
                  Tab(text: local.video),
                  Tab(text: local.users),
                ],
              ),)
            )
,
            Expanded(
              child: TabBarView(
                controller: primaryTC,

                children: <Widget>[
                  SearchGrid(
                    videos, _controller.text,
                    onTap: () =>
                        Navigator.pushNamed(context, PageRoutes.videoOptionPage),

                  ),
                  ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: users.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Column(
                          children: <Widget>[

                            Container(height: 5,),

                            ListTile(
                                leading: Functions.showProfileImage(users[index]["profile_pic"] , 55, users[index]["verified"] ),

                                title: Padding(padding: EdgeInsets.only(left: 5),child: Text(
                                  Functions.capitalizeFirst(users[index]["first_name"]),
                                  style: TextStyle(color: Colors.white),
                                ),),
                                subtitle: Padding(padding: EdgeInsets.only(left: 5,top: 4),
                                  child: Text(Functions.isNullEmptyOrFalse(users[index]["username"]) ? "" : users[index]["username"]),
                                ),
                                onTap: () async{


                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) =>   UserProfilePage(fb_id: users[index]["fb_id"],)),
                                  );

                                }


                            ),
                          ],
                        );
                      })
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
