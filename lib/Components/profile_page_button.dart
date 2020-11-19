import 'package:flutter/material.dart';
import 'package:qvid/Theme/colors.dart';

class ProfilePageButton extends StatelessWidget {
  final String text;
  final Function onTap;
  final Color color;
  final Color textColor;
  final double width;

  ProfilePageButton(this.text, this.onTap,
      {this.color, this.textColor, this.width});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.0),
        width: width ?? 84.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: color ?? backgroundColor,
            borderRadius: BorderRadius.circular(5.0)),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 12,
              color: textColor ?? mainColor.withOpacity(0.9),
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
