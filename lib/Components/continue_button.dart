import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Theme/colors.dart';
import 'package:qvid/Theme/style.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final Color borderColor;
  final Color color;
  final TextStyle style;
  final Widget icon;
  final Color textColor;

  CustomButton({
    this.text,
    this.onPressed,
    this.borderColor,
    this.color,
    this.style,
    this.icon,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(top: 16.0),
      child: FlatButton.icon(
        icon: icon ?? SizedBox.shrink(),
        padding: EdgeInsets.symmetric(vertical: 16),
        onPressed: onPressed,
        disabledColor: disabledTextColor.withOpacity(0.5),
        color: color ?? mainColor,
        shape: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: borderColor ?? Colors.transparent),
        ),
        label: Text(
          text ?? locale.continueText,
          style: style ??
              Theme.of(context)
                  .textTheme
                  .button
                  .copyWith(color: textColor ?? secondaryColor),
        ),
      ),
    );
  }
}
