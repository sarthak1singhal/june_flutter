// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:io';

import 'package:flutter_better_camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';



//Zoomer this will be a seprate widget
class ZoomableWidget extends StatefulWidget {
  final Widget child;
  final Function onZoom;
  final Function onTapUp;

  const ZoomableWidget({Key key, this.child, this.onZoom, this.onTapUp})
      : super(key: key);

  @override
  _ZoomableWidgetState createState() => _ZoomableWidgetState();
}

class _ZoomableWidgetState extends State<ZoomableWidget> {
  Matrix4 matrix = Matrix4.identity();
  double zoom = 1;
  double prevZoom = 1;
  bool showZoom = false;
  Timer t1;

  bool handleZoom(newZoom){
    if (newZoom >= 1) {
      if (newZoom > 6) {
        return false;
      }
      setState(() {
        showZoom = true;
        zoom = newZoom;
      });

      if (t1 != null) {
        t1.cancel();
      }

      t1 = Timer(Duration(milliseconds: 2000), () {
        setState(() {
          showZoom = false;
        });
      });
    }
    widget.onZoom(zoom);
    return true;

  }
  @override
  Widget build(BuildContext context) {

    return GestureDetector(
        onScaleStart: (scaleDetails) {
          print('scalStart');
          setState(() => prevZoom = zoom);
          //print(scaleDetails);
        },
        onScaleUpdate: (ScaleUpdateDetails scaleDetails) {
          var newZoom = (prevZoom * scaleDetails.scale);

          handleZoom(newZoom);
        },
        onScaleEnd: (scaleDetails) {
          print('end');
          //print(scaleDetails);
        },
        onTapUp: (TapUpDetails det) {
          final RenderBox box = context.findRenderObject();
          final Offset localPoint = box.globalToLocal(det.globalPosition);
          final Offset scaledPoint =
          localPoint.scale(1 / box.size.width, 1 / box.size.height);
          // TODO IMPLIMENT
          // widget.onTapUp(scaledPoint);
        },
        child: Stack(children: [
          Container(
               child: widget.child,
           ),

        ]));
  }
}