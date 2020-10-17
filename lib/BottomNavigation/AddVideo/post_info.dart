import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:qvid/Components/continue_button.dart';
import 'package:qvid/Components/entry_field.dart';
import 'package:qvid/Components/post_thumb_list.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Theme/colors.dart';

class PostInfo extends StatefulWidget {
  @override
  _PostInfoState createState() => _PostInfoState();
}

class _PostInfoState extends State<PostInfo> {
  var icon = Icons.check_box_outline_blank;
  bool isSwitched1 = false;
  bool isSwitched2 = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).post),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            EntryField(

              label: '    ' + AppLocalizations.of(context).describeVideo,
            ),
            Spacer(),
            Text(
              AppLocalizations.of(context).selectCover + '\n',
              style: TextStyle(color: secondaryColor, fontSize: 18),
            ),

            SizedBox(height: 12.0),
            ListTile(
              title: Text(
                AppLocalizations.of(context).commentOff,
                style: TextStyle(color: secondaryColor),
              ),
              trailing: Switch(
                value: isSwitched1,
                onChanged: (value) {
                  setState(() {
                    isSwitched1 = value;
                    //print(isSwitched1);
                  });
                },
                inactiveThumbColor: disabledTextColor,
                inactiveTrackColor: darkColor,
                activeTrackColor: darkColor,
                activeColor: mainColor,
              ),
            ),
            ListTile(
              title: Text(
                AppLocalizations.of(context).saveToGallery,
                style: TextStyle(color: secondaryColor),
              ),
              trailing: Switch(
                value: isSwitched2,
                onChanged: (value) {
                  setState(() {
                    isSwitched2 = value;
                    //print(isSwitched2);
                  });
                },
                inactiveThumbColor: disabledTextColor,
                inactiveTrackColor: darkColor,
                activeTrackColor: darkColor,
                activeColor: mainColor,
              ),
            ),
            Spacer(),
            CustomButton(
              text: AppLocalizations.of(context).postVideo,
              onPressed: () {
                Phoenix.rebirth(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
