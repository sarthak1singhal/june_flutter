import 'dart:convert';
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qvid/BottomNavigation/Explore/explore_page.dart';
import 'package:qvid/Components/newScreenGrid.dart';
import 'package:qvid/Components/searchGrid.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Functions/VideoDownloader.dart';
import 'package:qvid/Model/Videos.dart';
import 'package:qvid/Functions/functions.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Routes/routes.dart';
import 'package:qvid/Screens/user_profile.dart';
import 'package:qvid/Theme/colors.dart';


class GetSounds extends StatefulWidget {
  @override
  _SearchUsersState createState() => _SearchUsersState();
}

class _SearchUsersState extends State<GetSounds >  with SingleTickerProviderStateMixin,    AutomaticKeepAliveClientMixin<GetSounds > {
  var _controller = TextEditingController();


  ScrollController scrollController = ScrollController();
  bool isLoading = false;



  List<Sounds> list = [];
  List<Sounds> searchList = [];





  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  int offset = 0;
  int offsetSearch = 0;
  bool isSearch = false;
  bool listEnded = false;
  bool searchListEnded = false;

  getData(String v) async{

    if(isLoading)return;
    if(isSearch)
      {
        if(searchListEnded)
          {
            return;
          }
      }
    else{
      if(listEnded)
        {
          return;
        }
    }



    setState(() {
      isLoading = true;
    });



    try{


       Functions fx = Functions();

       var res = await fx.postReq(Variables.allSounds, jsonEncode({
        "keyword" : v.length == 0? "" : v,
         "offset" : isSearch ? offsetSearch: offset
      }), context);

      var data  = jsonDecode(res.body);

      if(data["isError"])
        {

         }else{
        if(isSearch)
          {
             offsetSearch = offsetSearch + data["msg"].length;

            if(data["msg"].length<20)
              {
                searchListEnded = true;
              }
          }else{

           offset = offset + data["msg"].length;

          if(data["msg"].length<20)
          {
            listEnded= true;
          }

        }

         parseData( data);

      }

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

  parseData( data){



    if(Functions.isNullEmptyOrFalse(data["msg"]))
    {
      Functions.showSnackBar(_scaffoldKey, "Some Error Occured");
      return;
    }


    for(int i =0;i<data["msg"].length;i++)
      {
        print("SDAD");
        var d = data["msg"][i];
        Sounds sounds = Sounds(d["id"], d["audio_path"]["mp3"], d["audio_path"]["mp3"], d["sound_name"], d["description"], d["thum"], d["section"].toString(), d["created"]);
        if(isSearch)
          searchList.add(sounds);
        else{
          list.add(sounds);
        }
      }

    print("DONE");


  }




  String mp3Url = "https://www.learningcontainer.com/download/sample-mp3-file/?wpdmdl=1676&refresh=5f7b81dc8d61f1601929692";
  String imageUrl  = "https://i.picsum.photos/id/157/200/200.jpg?hmac=WcY71o73tg2eJc3TmpgdISkTe-p8ZGn-A3Q3jh2h7T4";
  @override
  void initState() {
    super.initState();
     getData("");


    list.add(Sounds(1, mp3Url, mp3Url, "Sample Name", "Sample DEscriptipn", imageUrl, "1", "date"));
    list.add(Sounds(2, mp3Url, mp3Url, "Sample Name2", "Sample DEscriptipn", imageUrl, "1", "date"));
    list.add(Sounds(3, mp3Url, mp3Url, "Sample Name3", "Sample DEscriptipn", imageUrl, "1", "date"));


    scrollController.addListener(() {

       if(scrollController.position.extentAfter<200)
        {
          if(_controller.text.trim().length>1) {

            getData(_controller.text);

          } else{
            getData("");
        }
        }

    });




  }



  @override
  Widget build(BuildContext context) {
    var local = AppLocalizations.of(context);
    return Scaffold(
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
                            if(currentIndexPlaying!=null)
                            {
                              list[currentIndexPlaying].pause();

                              currentIndexPlaying= null;
                            }
                            if(currentSearchIndexPlaying!=null)
                            {
                              searchList[currentSearchIndexPlaying].pause();
                              currentSearchIndexPlaying = null;
                            }

                            if(v.length>2 && v.length<20)
                            {
                              isSearch = true;
                              offsetSearch = 0;
                              searchListEnded = false;
                              getData(v);
                            }else{

                              isSearch = false;
                              setState(() {

                              });
                            }

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
             ],
          ),
        ),
      ),
      body:   ListView.builder(
          controller: scrollController,
          physics: BouncingScrollPhysics(),
          itemCount: isSearch? searchList.length:list.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Column(
              children: <Widget>[

                Container(height: 5,),

                ListTile(
                  leading: Container(
                    child: CircleAvatar(
                      backgroundColor: darkColor,
                      backgroundImage: !Functions.isNullEmptyOrFalse(isSearch? searchList[index].thum:list[index].thum)?
                      Uri.parse(list[index].thum).isAbsolute?
                      NetworkImage(isSearch? searchList[index].thum:list[index].thum) :
                      Functions.defaultProfileImage():
                      Functions.defaultProfileImage(),

                    ),
                    height: 40,
                    width: 40,
                  ),
                  title: Padding(padding: EdgeInsets.only(left: 5),child: Text(
                    Functions.capitalizeFirst(isSearch? searchList[index].sound_name:list[index].sound_name),
                    style: TextStyle(color: Colors.white),
                  ),),





                  onTap: () async{


                    MyAudioDownloader download = MyAudioDownloader();
                    String path = await download.downloadAndSaveHls(isSearch? searchList[index].audioPath:list[index].audioPath,  _scaffoldKey);


                    List<String> l=[];
                    if(path!=null)
                      {
                        l.add(path);
                        l.add( isSearch? searchList[index].sound_name:list[index].sound_name);
                        l.add(isSearch? searchList[index].id.toString():list[index].id.toString());

                        Navigator.pop(context, l);

                      }
                  }
                  ,

                  trailing: IconButton(
                    icon: Icon(!(isSearch? searchList[index].isPlaying:list[index].isPlaying)? Icons.play_arrow : Icons.pause),
                    onPressed: (){

                      if(isSearch)
                      {
                        if(currentSearchIndexPlaying!=null)
                        {

                          list[currentSearchIndexPlaying].pause();
                          if(currentSearchIndexPlaying == index) {
                            currentSearchIndexPlaying = null;

                            setState(() {

                            });
                            return;

                          }

                        }
                        if(list[index].changeAndTellPlayStatus())
                        {
                          currentSearchIndexPlaying = index;
                        }
                        else{
                          currentSearchIndexPlaying = null;
                        }
                      }else{


                        if(currentIndexPlaying!=null)
                        {

                          list[currentIndexPlaying].pause();
                          if(currentIndexPlaying == index) {
                            currentIndexPlaying = null;

                            setState(() {

                            });
                            return;

                          }

                        }
                        if(list[index].changeAndTellPlayStatus())
                        {
                          currentIndexPlaying = index;
                        }
                        else{
                          currentIndexPlaying = null;
                        }
                      }
                      setState(() {

                      });


                    },

                  ),


                ),
              ],
            );
          }),

    );
  }



  int currentIndexPlaying ;
  int currentSearchIndexPlaying ;


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if(currentIndexPlaying!=null)
    {
      list[currentIndexPlaying].pause();
     }
 if(currentSearchIndexPlaying!=null)
    {
      searchList[currentSearchIndexPlaying].pause();
     }

  }


  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
