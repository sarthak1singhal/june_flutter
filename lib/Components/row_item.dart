import 'package:flutter/material.dart';
import 'package:qvid/Theme/colors.dart';

class RowItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget route;


  RowItem(this.title, this.subtitle, this.route);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(fontSize: 20, height: 1.5),
          children: [
            TextSpan(
              text: title + '\n',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            TextSpan(
              text: subtitle,
              style: TextStyle(fontSize: 14, color: disabledTextColor),
            ),
          ],
        ),
      ),
      onTap: route == null ?  null :() {
        Navigator.push(context, MaterialPageRoute(builder: (context) => route));
      },
    );
  }
}
