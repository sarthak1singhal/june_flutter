import 'package:flutter/material.dart';
import 'package:qvid/Theme/colors.dart';

class EntryField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String initialValue;
  final bool readOnly;
  final TextInputType keyboardType;
  final int maxLength;
  final bool obscureText;
  final int maxLines;
  final String hint;
  final Widget prefix;
  final Widget suffixIcon;
  final Function onTap;
  final TextCapitalization textCapitalization;
  final Color fillColor;
  final EdgeInsets padding;
  Function onChanged;
  Function onSubmitted;
  Function validator;
  bool autoValidate;
  final Widget counter;
  FocusNode focusNode;

   EntryField({

     this.onChanged,
    this.obscureText,
    this.focusNode,
    this.onSubmitted,
    this.autoValidate,
    this.controller,
    this.label,
    this.initialValue,
    this.readOnly,
    this.keyboardType,
    this.validator,
    this.maxLength,
    this.hint,
    this.prefix,
    this.maxLines,
    this.suffixIcon,
    this.onTap,
    this.textCapitalization,
    this.fillColor,
    this.padding,
    this.counter,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.only(left: 5.0, top: 0, bottom: 13, right: 5),
      child: TextFormField(



        focusNode: focusNode,
        obscureText: obscureText == null ? false : obscureText,
        onChanged: onChanged,
        validator: validator,
        onFieldSubmitted: onSubmitted,
        style: TextStyle(color: secondaryColor),
        enableInteractiveSelection: false,
        textCapitalization: textCapitalization ?? TextCapitalization.sentences,
        cursorColor: mainColor,
        onTap: onTap,
        autofocus: false,


        controller: controller,
        initialValue: initialValue,
        readOnly: readOnly ?? false,
        keyboardType: keyboardType,
        minLines: maxLines == null ? null : 1,
        maxLength: maxLength,
        maxLines: maxLines == 1 ? 1: maxLines,
        decoration: InputDecoration(


            contentPadding: EdgeInsets.all(16.0),
            filled: true,
            fillColor: fillColor ?? Colors.transparent,
            prefixIcon: prefix,
            suffixIcon: suffixIcon,
            labelText: label,
            labelStyle: TextStyle(
              color: Colors.white54
            ),


            hintText: hint,
            hintStyle: TextStyle(fontSize: 13.3, color: lightWhite),
            counter: counter ?? Offstage(),
            border: OutlineInputBorder(borderSide: BorderSide.none)
        ),
      ),
    );
  }
}
