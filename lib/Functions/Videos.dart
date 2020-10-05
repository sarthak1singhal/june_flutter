import 'package:just_audio/just_audio.dart';

class Videos{

  String id, vid_url, thumb_url, fb_id, first_name, last_name, profile_pic, username;
  int verified, likeCount, commentCount;
  String  description, created;
  int views;
  int isLiked;
  Sounds sound;
  Videos(this.id, this.vid_url, this.thumb_url, this.fb_id, this.isLiked, this.first_name,
      this.last_name, this.profile_pic, this.username, this.verified,
      this.likeCount, this.commentCount, this.views,this.description, this.created, this.sound);


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