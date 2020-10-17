import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class TextPaint extends StatelessWidget {
  final Color color;
  final String text;
  final Float64List matrix4;

  TextPaint(this.color, this.text, this.matrix4);

  @override
  Widget build(BuildContext context) {
    return new CustomPaint(
      painter: new MyPainter(color, text, matrix4),
    );
  }
}


class MyPainter extends CustomPainter {
  final Color color;
  final String text;
  final Float64List matrix4;
  MyPainter(this.color, this.text, this.matrix4);

  @override
  void paint(Canvas canvas, Size size) {

   canvas.transform(matrix4);
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 24,
    );
    final textSpan = TextSpan(
      text: 'Hello, world.',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: 500//size.width,
    );
    final offset = Offset(50, 100);
    textPainter.paint(canvas, offset);
   }

  @override
  bool shouldRepaint(MyPainter oldDelegate) {


    bool x = color != oldDelegate.color;
    bool y = text != oldDelegate.text;
    bool z = matrix4!= oldDelegate.matrix4;

  return  (x||y||z);

  }
}