import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:qvid/BottomNavigation/bottom_navigation.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Routes/routes.dart';
import 'package:qvid/Theme/style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qvid/Functions/Variables.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, //top bar color
    statusBarIconBrightness: Brightness.light, //top bar icons

  ));

  runApp(Phoenix(child: MyApp()));
}


RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {


  /* getData() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Variables.fb_id = preferences.getString(Variables.fbid_String);
    Variables.token = preferences.getString(Variables.tokenString);
    Variables.user_pic= preferences.getString(Variables.picString);
    Variables.refreshToken= preferences.getString(Variables.refreshTokenString);
    Variables.username= preferences.getString(Variables.usernameString);
    Variables.f_name= preferences.getString(Variables.f_nameString);
    Variables.l_name= preferences.getString(Variables.l_nameString);

    print(Variables.token)
;  }


  Qvid(){
    getData();
   }*/
final navigatorKey= GlobalKey<NavigatorState>();

final Key key = UniqueKey();


final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

_register() {
  _firebaseMessaging.getToken().then((token) => print(token));
}



Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }

  // Or do other work.
}
@override
void initState() {
  // TODO: implement initState
  super.initState();
  getMessage();
}

String _message = '';

void getMessage(){
  _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        setState(() => _message = message["notification"]["title"]);
      },

      onResume: (Map<String, dynamic> message) async {
    print('on resume $message');
    setState(() => _message = message["notification"]["title"]);
  },

      onLaunch: (Map<String, dynamic> message) async {
    print('on launch $message');
    setState(() => _message = message["notification"]["title"]);
  });
}




@override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child:MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en'),
          const Locale('ar'),
          const Locale('id'),
          const Locale('fr'),
          const Locale('pt'),
          const Locale('es'),
        ],
        navigatorObservers: [routeObserver], //HERE

        theme: appTheme,
        home: BottomNavigation( ),
        routes: PageRoutes().routes(),
      )
    );
  }
}
