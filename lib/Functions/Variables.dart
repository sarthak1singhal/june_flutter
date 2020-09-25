class Variables{

  static final String fontName = "Roboto";




   static final String device="android";
   static final String pref_nameString="pref_name";
   //static final String u_idString="u_id";
   //static final String u_nameString="u_name";
   static final String picString="u_pic";
   static final String f_nameString="f_name";
   static final String l_nameString="l_name";
   static final String genderString="u_gender";
   static final String usernameString="username";
   static final String emailString="email";
   static final String device_tokenString="device_token";
   static final String tokenString="token";
   static final String refreshTokenString="refresh_token";
   static final String content_languageString="content_language";
   static final String device_idString="device_id";
   static final String fbid_String="fb_id";



   static String user_id;
   static String username;
   static String user_pic;
   static String email;
   static String token;
   static String refreshToken;
   static String f_name;
   static String l_name;
   static String language;
   static String fb_id;



  static final String privacy_policy="https://docs.google.com/document/d/1A4E_egHnUoZdd5_5v0UBpHzbgogeZKvLuGXH71lQFdw/edit?usp=sharing";
  static final String termsAndConditionUrl="https://docs.google.com/document/d/1A4E_egHnUoZdd5_5v0UBpHzbgogeZKvLuGXH71lQFdw/edit?usp=sharing";

  //static String base_url="http://elyisonsocialmedia.com/";
  static String base_url="http://ec2-13-233-22-72.ap-south-1.compute.amazonaws.com:3000/";


  //public static String base_url="https://juneapp.in/API/";
  // public static String base_url="http://ec2-13-234-226-188.ap-south-1.compute.amazonaws.com/";

  // public static String domain=base_url+"index?p=";
    static String domain=base_url+"index.php?p=";
    static String middle= "index.php?p=";



    static final String SignUp = "signup";
    static final String login_fb = "login-fb";
    static final String uploadVideo =domain+"uploadVideo";
    static final String showAllVideos =domain+"showAllVideos";
   static final String showMyAllVideos=domain+"showMyAllVideos";
   static final String likeDislikeVideo=domain+"likeDislikeVideo";
   static final String updateVideoView=domain+"updateVideoView";
   static final String reportVideo=domain+"reportVideo";
   static final String allSounds=domain+"allSounds";
   static final String fav_sound=domain+"fav_sound";
   static final String my_FavSound=domain+"my_FavSound";
   static final String my_liked_video=domain+"my_liked_video";
   static final String follow_users=domain+"follow_users";
   static final String discover=domain+"discover";
   static final String showVideoComments=domain+"showVideoComments";
   static final String postComment=domain+"postComment";
   static final String edit_profile=domain+"edit_profile";
   static final String get_user_data=domain+"get_user_data";
   static final String get_followers=domain+"get_followers";
   static final String get_followings=domain+"get_following";
   static final String SearchByHashTag=domain+"searchByHashTag";
   static final String sendPushNotification=domain+"sendPushNotification";
   static final String uploadImage=domain+"uploadImage";
   static final String DeleteVideo=domain+"DeleteVideo";
   static final String search=domain+"search";
   static final String getNotifications=domain+"getNotifications";
   static final String getVerified=domain+"getVerified";
   static final String updateLanguage = domain + "post_language";
   static final String selectedLanguage = "selected_language";


  static final String loginUrl = "login";
  static final String isUsernameOrEmailExist = "isEmailorUsernameExist";
   //username or email and password
       //if account exist, login
       //else show error

  static final String signup = "signup";//creates an account
  static final String sendOTP = "send-otp";//verify user account details and sends otp to mail

  static final String checkEmailExist = "isEmailExist";//check if email exist
  static final String checkUsernameExist = "isUsernameExist"; //check if username exist and recommend some usernames related to it

  //static final String checkUsername = "checkUsername";//logs user in with password

  //static final String signup = "sendOTP"; //full name, email, password

  static final String connErrorMessage = "Connection Error";

  static final String basicErrorMessage  = "Some error occoured";


}