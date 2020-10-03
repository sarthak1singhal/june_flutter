import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:qvid/BottomNavigation/bottom_navigation.dart';
import 'package:qvid/Functions/Variables.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Routes/routes.dart';
import 'package:qvid/Theme/style.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, //top bar color
    statusBarIconBrightness: Brightness.light, //top bar icons

  ));

  runApp(Phoenix(child: Qvid()));
}



class Qvid extends StatelessWidget {

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
    print("LAUDA LASSUN");
  }*/


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      theme: appTheme,
      home: BottomNavigation(),
      routes: PageRoutes().routes(),
    );
  }
}
