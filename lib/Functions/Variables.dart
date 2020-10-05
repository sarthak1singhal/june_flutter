class Variables{

  static final String fontName = "Roboto";




   static final String device="android";
   static final String pref_nameString="pref_name";
   //static final String u_idString="u_id";
   //static final String u_nameString="u_name";
   static final String picString="u_pic";
   static final String f_nameString="f_name";
   static final String l_nameString="l_name";
   static final String verifiedString="isVerified";
   static final String blockString="isBlocked";
   static final String genderString="u_gender";
   static final String usernameString="username";
   static final String emailString="email";
   static final String device_tokenString="device_token";
   static final String tokenString="token";
   static final String refreshTokenString="refresh_token";
   static final String content_languageString="content_language";
   static final String device_idString="device_id";
   static final String fbid_String="fb_id";
   static final String bioString="bio";
   static final String phoneNumberString="phone";
   static final String dobString="dob";
   static final String signupTypeString="signupType";



   //static String user_id;
   static String username;
   static String user_pic;
   static String bio;
   static String phoneNumber;
   static String dob;
   static String email;
   static String gender;
   static String token;
   static String refreshToken;
   static String f_name;
   static String l_name;
   static String language;
   static String fb_id;
   static String signupType;
   static int isVerified;



  static final String privacy_policy="https://docs.google.com/document/d/1A4E_egHnUoZdd5_5v0UBpHzbgogeZKvLuGXH71lQFdw/edit?usp=sharing";
  static final String termsAndConditionUrl="https://docs.google.com/document/d/1A4E_egHnUoZdd5_5v0UBpHzbgogeZKvLuGXH71lQFdw/edit?usp=sharing";

  //static String base_url="http://elyisonsocialmedia.com/";
  static String base_url="http://ec2-13-233-22-72.ap-south-1.compute.amazonaws.com:3000/";


  //public static String base_url="https://juneapp.in/API/";
  // public static String base_url="http://ec2-13-234-226-188.ap-south-1.compute.amazonaws.com/";

  // public static String domain=base_url+"index?p=";
    static String domain=base_url+"index?p=";
    static String middle= "index?p=";




    static final String uploadVideo =domain+"uploadVideo";
   // static final String showVideos =domain+"showAllVideos";


  //POST PARAMETERS
  static final String home_videos = base_url+"showAllVideos"; //gives at max 20 video data
  static final String videos_following = base_url+"show-videos-following"; //offset and offset2. gives at max 20 video data
  static final String showVideosBySound = base_url+"videos-by-sound"; //sound_id, offset, limit is set to 21.

  static final String showVideoByHashtag = base_url+"videos-by-hashtag"; //hashtag (without #), offset, limit is set to 21.

  static final String videosByUserId= base_url+"videos-by-user"; //fb_id, my_fb_id, offset, limit.  If offset = 0, then user profile data is shown too
  // else users new videos are shown

  static final String my_liked_video=base_url+"my-liked-video"; //offset, limit. shows the videos liked by user

  static final String allSounds=base_url+"allSounds"; //offset to view or search sounds. if keyword == "" then it shows all sounds
  //else shows searched shounds by keyword
  //Parameters - keyword, offset. Limit is already set to 30
  static final String search=base_url+"search";
  static final String mark_unmark_sound_fav=base_url+"mark-s-fav"; //parameter- sound_id, fav(0 or 1, 0 for unfavourite, 1 for favourite)
  static final String showVideoComments=base_url+"showVideoComments"; //offset, video_id, limit = 25
  static final String my_FavSound=base_url+"my_FavSound"; //offset, limit is already set to 30
  static final String follow_users=base_url+"follow-user";//other_userid, status (0 for unfollow, 1 for follow)
  static final String edit_profile=base_url+"edit-profile"; //full_name, username, gender, bio  ||dob phoneNumber
  static final String get_followers=base_url+"get-followers";//fb_id, offset. Default limit is 40
  static final String get_followings=base_url+"get-following";//fb_id, offset. Default limit is 40
  static final String postComment=base_url+"post-comment";// video_id, comment
  static final String likeDislikeVideo=base_url+"likeDislikeVideo";//action (0 for delete like, 1 for like), video_id
  static final String reportVideo=base_url+"reportVideo"; //action, video_id
  static final String DeleteVideo=base_url+"delete-video";//video_id
  static final String updateVideoView=base_url+"updateVideoView";//video_id
  static final String getNotifications=base_url+"getNotifications"; //offset, limit is set to 30
  static final String uploadProfileImg=base_url+"uploadProfileImage_app";
  static final String changePassword=base_url+"change-password";  //password, confirm_password, new_password
  static final String getVerified=base_url+"get-verified"; //


    //TODO: Set username at the time of signup

  //static final String showMyAllVideos=domain+"showMyAllVideos";


//GET PARAMETERS
   static final String discover=domain+"discover";


   //static final String get_user_data=domain+"get_user_data";
   //static final String SearchByHashTag=domain+"searchByHashTag";
   static final String sendPushNotification=domain+"sendPushNotification";
   //static final String uploadImage=domain+"uploadImage";
   //static final String updateLanguage = domain + "post_language";
   //static final String selectedLanguage = "selected_language";





  static final String loginUrl = "login";
  static final String login_fb = "login-fb";
  static final String isUsernameOrEmailExist = "isEmailorUsernameExist";
   //username or email and password
       //if account exist, login
       //else show error

  static final String signup = "signup";//creates an account
  static final String sendOTP = "send-otp";//verify user account details and sends otp to mail

  static final String checkEmailExist = "isEmailExist";//check if email exist
  static final String isUsernameExist = "isUsernameExist"; //check if username exist and recommend some usernames related to it

  //static final String checkUsername = "checkUsername";//logs user in with password

  //static final String signup = "sendOTP"; //full name, email, password

  static final String connErrorMessage = "Connection Error";

  static List<String> genders = ["Male", "Female", "Prefer not to say","1"];

  static final String basicErrorMessage  = "Some error occoured";


}