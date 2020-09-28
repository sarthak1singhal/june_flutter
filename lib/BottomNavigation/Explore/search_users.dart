import 'dart:convert';
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qvid/BottomNavigation/Explore/explore_page.dart';
import 'package:qvid/Functions/Variables.dart';
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
  List<User> names = [
    User("Food Master", "@georgesmith", "assets/user/user1.png"),

  ];


  bool isLoading = false;




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
          var res = await Functions.postReq(url, jsonEncode({
            "type" : tab == 0? "video" : "users",
            "keyword" : v.length == 0? " " : v
          }), context);

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



     });
  }



  @override
  Widget build(BuildContext context) {
    var local = AppLocalizations.of(context);
    return DefaultTabController(
       length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(66.0),
            child: Column(
              children: <Widget>[
                Container(
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                    controller: primaryTC,

                    indicator: BoxDecoration(color: transparentColor),
                    isScrollable: true,
                    labelColor: mainColor,
                    labelStyle: Theme.of(context).textTheme.headline6,
                    unselectedLabelColor: disabledTextColor,
                    tabs: <Widget>[
                      Tab(text: local.video),
                      Tab(text: local.users),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: primaryTC,

          children: <Widget>[
            TabGrid(
              dance,
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
                      Divider(
                        color: darkColor,
                        height: 1.0,
                        thickness: 1,
                      ),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: darkColor,
                          backgroundImage: !Functions.isNullEmptyOrFalse(users[index]["profile_pic"])? NetworkImage(users[index]["profile_pic"]) : AssetImage(names[index].img),
                        ),
                        title: Text(
                          Functions.capitalizeFirst(users[index]["first_name"]),
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(Functions.isNullEmptyOrFalse(users[index]["username"]) ? "" : users[index]["username"]),
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
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
