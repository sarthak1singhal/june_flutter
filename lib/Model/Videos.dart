import 'dart:convert';

import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qvid/Functions/Variables.dart';

import '../Functions/functions.dart';

class Videos{

  String id, vid_url, thumb_url, fb_id, first_name, last_name, profile_pic, username;
  int verified, likeCount, commentCount, isLiked ;
  String  description, created;
  int views;
  bool isViewed = false;
  BuildContext context;

  Sounds sound;
  Videos(this.id, this.vid_url, this.thumb_url, this.fb_id, this.isLiked, this.first_name,
      this.last_name, this.profile_pic, this.username, this.verified,
      this.likeCount, this.commentCount, this.views,this.description, this.created, this.sound, this.context);





  bool isVideoLiked(){
    return isLiked == 0 ? false: true;
  }



  likeUnlikeVideo(){

    if(isLiked==1)
      {
        isLiked = 0;
      }
    else{
      isLiked = 1;
    }

    try{
      Functions fx = Functions();
      fx.postReq(Variables.likeDislikeVideo, jsonEncode({
        "action" : isLiked,
        "video_id": id
      }), context);

    }catch(e){

    }

    return;


  }


  likeVideo(){
    if(isLiked==1)
      return;

    isLiked = 1;
    try{
      Functions fx = Functions();
      fx.postReq(Variables.likeDislikeVideo, jsonEncode({
        "action" : isLiked,
        "video_id": id
      }), context);




    }catch(e){

    }
  }




  updateView(){
    if(isViewed)
      return;

    if(Variables.fb_id!=null)
      if(fb_id == Variables.fb_id)
        return;

    isViewed = true;

    try{

      Functions.unsignPostReq(Variables.updateVideoView, jsonEncode({
        "video_id" : id
      }));
    }catch(e)
    {

    }
  }



  bool deletVideo(){

    if(Variables.fb_id==null)
      return false;

    if(Variables.fb_id!=fb_id)
      return false;


    try{

      Functions fx = Functions();
      fx.postReq(Variables.deleteVideo, jsonEncode({
        "video_id" : id
      }), context);

      return true;

    }catch(e)
    {

    }


  }


  reportVideo(String msg){


    try{

      Functions f = Functions();
      f.postReq(Variables.reportVideo, jsonEncode({
        "video_id" : id,
        "action" : msg
      }), context);

    }catch(e){

    }



  }




  copyToClipboard(){

    ClipboardManager.copyToClipBoard("your text to copy").then((result) {
      final snackBar = SnackBar(
        content: Text('Copied to Clipboard'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {},
        ),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    });

  }



}



class Sounds{

  String streamPath, audioPath, sound_name, description, thum, section, created;

  int id;
  bool isPlaying = false;
  var player = AudioPlayer();


  Sounds(this.id, this.streamPath, this.audioPath, this.sound_name,
      this.description, this.thum, this.section, this.created);


  bool changeAndTellPlayStatus(){

    if(isPlaying)
    {
      isPlaying  = false ;
      pause();
    }
    else
    {
      isPlaying = true;
      play();
    }

    return isPlaying;

  }


  pause(){

    isPlaying = false;
    player.pause();
  }

  play() async{
    await player.setUrl(this.streamPath);
    isPlaying = true;
    player.play();
  }



  playAud()async{
    var duration = await player.setUrl(this.streamPath);
    player.play();

    print(duration);
    print("duration");
    // HlsAudioSource(Uri.parse(this.streamPath));

  }

}