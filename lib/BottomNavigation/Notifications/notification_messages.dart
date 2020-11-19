import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Routes/routes.dart';
import 'package:qvid/Screens/user_profile.dart';
import 'package:qvid/Theme/colors.dart';

class NotificationMessages extends StatefulWidget {
  @override
  _NotificationMessagesState createState() => _NotificationMessagesState();
}

class Notif {
  final String name;
  final String username;
  final String fb_id;
  final String desc;
  final String time;
  final String image;
  final String notifImage;
  final int videoId;
  final IconData icon;

  Notif(this.name, this.desc, this.time, this.image, this.notifImage, this.icon, this.username, this.fb_id, this.videoId);
}

class _NotificationMessagesState extends State<NotificationMessages>  with AutomaticKeepAliveClientMixin<NotificationMessages>{
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Notif> notification =[];
  bool isLoading = false;
  bool isError = false;
  String errorMessage = "";
  bool doesExist = true;
  int offset = 0;
  ScrollController scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    getData();
    scrollController.addListener(() {
      if (scrollController.position.extentAfter < 300){
        getData();
      }
    });
  }

 Future<void> getData({bool isRefresh}) async{
    if(isRefresh == null) isRefresh = false;

    if(!isRefresh)
    if(!doesExist)
    {
      return;
    }


    if(!isLoading)
    {
      isLoading = true;

      if(!isRefresh)
        setState(() {
        });

      try{


        Functions fx= Functions();
        var res = await fx.postReq( Variables.getNotifications, jsonEncode({
          "offset" :isRefresh?0: offset
        }), context);

        var data = jsonDecode(res.body);
        if(!isRefresh)

        if(data["isError"])
        {
          Functions.showSnackBar(_scaffoldKey, "Some error occured");
          isError = true;
          errorMessage = "Some error occured";
          setState(() {
            isLoading = false;
          });
          return;
        }
        isError = false;
        if(isRefresh){
          notification = [];
          offset = 0;
        }

        if(data["msg"].length <30){
          doesExist = false;
        }
        else {
          offset = offset + 30;
        }


        for(int i=0;i<data["msg"].length; i++)
        {
          var d = data["msg"][i];
          String fb_id = "";
          if(!Functions.isNullEmptyOrFalse(d["fb_id"]))
          {
            fb_id = d["fb_id"];
          }
          String name = "";
          var userDetails = d["fb_id_details"];
          if(!Functions.isNullEmptyOrFalse(userDetails["first_name"]))
          {
            name = Functions.capitalizeFirst(userDetails["first_name"]);
          }
          if(!Functions.isNullEmptyOrFalse(userDetails["last_name"]))
          {
            name = name+ " " +Functions.capitalizeFirst(userDetails["last_name"]);
          }

          DateTime dateTime = DateTime.parse(d["created"]);

          String desc = "";
          if(d["type"]=="video_like")
          {
            desc = "liked your video";
          }
          if(d["type"].toString().contains("comment"))
          {
            desc = "commented on your video";
          }
          if(d["type"].toString().contains("follo"))
          {
            desc = "followed you";
          }
          notification.add(Notif(name, desc,Functions.dateToReadableString(dateTime), userDetails["profile_pic"], d["value_data"]["thum"], Icons.message, userDetails["username"], fb_id, d["id"]));
        }



      }catch(e){
        isError = true;
        errorMessage = Variables.connErrorMessage;
        isLoading = false;
        setState(() {

        });
       }


      setState(() {
        isLoading = false;
      });
    }
  }


  RefreshController _refreshController =
  RefreshController(initialRefresh: false);


  onRefresh()async {
    await getData(isRefresh: true);
    _refreshController.refreshCompleted();

  }





  @override
  Widget build(BuildContext context) {
    super.build(context);

    var locale = AppLocalizations.of(context);



    return Scaffold(
      appBar: AppBar(

        titleSpacing: 0.0,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Padding(child: Text(locale.notifications, style: TextStyle(fontSize: 21, fontFamily: Variables.fontName),),
          padding: EdgeInsets.only(left: 16,top: 3),
          )
        ),
      ),
      body: Padding(
      padding: EdgeInsets.only(bottom: 60),
    child: SmartRefresher(
          enablePullDown: true,
          physics: BouncingScrollPhysics(),

          header: Functions.swipeDownHeaderLoader(),
          controller: _refreshController,
          onRefresh: onRefresh,
          child:  (isLoading && notification.length==0)? Functions.showLoaderSmall() : isError ? Functions.showError(errorMessage) : ListView.builder(
            controller: scrollController,
            itemCount: (isLoading && notification.length!=0) ? notification.length +1:notification.length,
            itemBuilder: (context, index) {

              if(isLoading && notification.length!=0)
              {
                if(index == notification.length)
                  return Container(width: MediaQuery.of(context).size.width, height: 50, child: Functions.showLoaderSmall(),);
              }

              return  ListTile(
                leading: Functions.showProfileImage(notification[index].image, 43, 0),

                /*CircleAvatar(
                  backgroundImage: AssetImage(notification[index].image)),*/
                title: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: notification[index].username + ' ',
                        style: TextStyle(color: secondaryColor, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      TextSpan(
                          text: notification[index].desc,
                          style: TextStyle(color: lightTextColor.withOpacity(0.7),fontSize: 14, fontWeight: FontWeight.w400))
                    ])),
                subtitle: Text(
                    notification[index].time,
                    style: TextStyle(color: lightTextColor.withOpacity(0.35), fontSize: 12)),
                trailing: Container(
                  width: 40,
                  //height: 45,
                  child: notification[index].notifImage != null
                      ? Container(
                      width: 35,
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          image: DecorationImage(

                              image:
                              NetworkImage(notification[index].notifImage),
                              fit: BoxFit.cover)))
                      : Container(),
                ),


                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>   UserProfilePage(fb_id: notification[index].fb_id,)),
                  );
                },
              );
            })
        ,
      ))
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}


