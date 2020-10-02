class Videos{

  String id, vid_url, thumb_url, fb_id, first_name, last_name, profile_pic, username;
  int verified, likeCount, commentCount;
  String  description, created;

  Sounds sound;
  Videos(this.id, this.vid_url, this.thumb_url, this.fb_id, this.first_name,
      this.last_name, this.profile_pic, this.username, this.verified,
      this.likeCount, this.commentCount, this.description, this.created, this.sound);


}



class Sounds{

  String id,streamPath, audioPath, sound_name, description, thum, section, created;

  Sounds(this.id, this.streamPath, this.audioPath, this.sound_name,
      this.description, this.thum, this.section, this.created);


}