import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:qvid/BottomNavigation/bottom_navigation.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Routes/routes.dart';
import 'package:qvid/Theme/style.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, //top bar color
    statusBarIconBrightness: Brightness.light, //top bar icons

  ));
  runApp(Phoenix(child: Qvid()));
}

class Qvid extends StatelessWidget {
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
