import 'dart:convert';
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qvid/BottomNavigation/Explore/explore_page.dart';
import 'package:qvid/Components/newScreenGrid.dart';
import 'package:qvid/Components/searchGrid.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Functions/Videos.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Routes/routes.dart';
import 'package:qvid/Screens/user_profile.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:qvid/Extension/extensions.dart';
import 'package:qvid/Components/tab_grid.dart';
import 'package:shared_preferences/shared_preferences.dart';



class GetSounds extends StatefulWidget {
  @override
  _SearchUsersState createState() => _SearchUsersState();
}

class _SearchUsersState extends State<GetSounds >  with SingleTickerProviderStateMixin,    AutomaticKeepAliveClientMixin<GetSounds > {
  var _controller = TextEditingController();


  bool isLoading = false;



  List<Sounds> list = [];


  TabController primaryTC;



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



  }


  getData(String v) async{

    setState(() {
      isLoading = true;
    });



    try{


      int tab = primaryTC.index;


       var res = await Functions.postReq(Variables.allSounds, jsonEncode({
        "keyword" : v.length == 0? " " : v
      }), context);

      var data  = jsonDecode(res.body);

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





  @override
  void initState() {
    super.initState();
    primaryTC = new TabController(length: 2, vsync: this);
    getData("");
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
            preferredSize: Size.fromHeight(118.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                 Padding(padding: EdgeInsets.only(left: 22,top: 17),child: Text("Sounds", style: TextStyle(fontSize: 24, color: Colors.white),),
                    ),
                Container(
                    margin:
                    EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
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

                              if(v.length>2 && v.length<20)
                                getData(v);
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
                      Tab(text: "Sounds"),
                      Tab(text: "Local"),
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
            ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: list.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[

                    Container(height: 5,),

                    ListTile(
                        leading: Container(
                          child: CircleAvatar(
                            backgroundColor: darkColor,
                            backgroundImage: !Functions.isNullEmptyOrFalse(list[index].thum)? NetworkImage(list[index].thum) : Functions.defaultProfileImage(),
                          ),
                          height: 55,
                          width: 55,
                        ),
                        title: Padding(padding: EdgeInsets.only(left: 5),child: Text(
                          Functions.capitalizeFirst(list[index].sound_name),
                          style: TextStyle(color: Colors.white),
                        ),),
                        subtitle: Padding(padding: EdgeInsets.only(left: 5,top: 4),
                          child: Text(Functions.isNullEmptyOrFalse(list[index].description) ? "" : list[index].description),
                        ),
                        onTap: () async{


                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>   UserProfilePage(fb_id: list[index].id,)),
                          );

                        }


                    ),
                  ],
                );
              }),

            ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: list.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container();
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
