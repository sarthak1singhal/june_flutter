import 'dart:math';

import 'package:flutter/material.dart';
import 'SliderThumb.dart';

class SliderWidget extends StatefulWidget {
  final double sliderHeight;
  final double initial;
  final int min;
  final int max;
  final fullWidth;

  SliderWidget(
       {this.sliderHeight = 48,
        this.max = 10,
        this.min = 0,
         this.initial,
        this.fullWidth = false});

  @override
  SliderWidgetState  createState() => SliderWidgetState ();
}

class SliderWidgetState extends State<SliderWidget> {
   double value = 0;
   static double sliderValue = 0;

   @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.initial != null )

    value = widget.min.ceilToDouble()<widget.initial?  widget.initial:widget.min.ceilToDouble() ;
    else
      value= widget.min.ceilToDouble();

    value = (value -widget.min )/(widget.max-widget.min);
     print(value);
  }
  @override
  Widget build(BuildContext context) {
    double paddingFactor = .2;

    if (this.widget.fullWidth) paddingFactor = .3;

    return Container(
      width: this.widget.fullWidth
          ? double.infinity
          : (this.widget.sliderHeight) * 5.5,
      height: (this.widget.sliderHeight),
      decoration: new BoxDecoration(
        borderRadius: new BorderRadius.all(Radius.circular((10)),),
        gradient: new LinearGradient(
            colors: [

             // Colors.white10,
             // Colors.white24
              const Color(0xFF00c6ff),
              const Color(0xFF0072ff),
            ],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(1.0, 1.00),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(this.widget.sliderHeight * paddingFactor,
            2, this.widget.sliderHeight * paddingFactor, 2),
        child:           Row(
          children: <Widget>[
            Text(
              '${this.widget.min}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: this.widget.sliderHeight * .3,
                fontWeight: FontWeight.w700,
                color: Colors.white,

              ),
            ),
            SizedBox(
              width: this.widget.sliderHeight * .1,
            ),
            Expanded(
              child: Center(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.white.withOpacity(1),
                    inactiveTrackColor: Colors.white.withOpacity(.5),

                    trackHeight: 4.0,
                    thumbShape: CustomSliderThumbCircle(
                      thumbRadius: this.widget.sliderHeight * .4,
                      min: this.widget.min,
                      max: this.widget.max,
                    ),
                    overlayColor: Colors.white.withOpacity(.4),
                    //valueIndicatorColor: Colors.white,
                    activeTickMarkColor: Colors.white,
                    inactiveTickMarkColor: Colors.red.withOpacity(.7),
                  ),
                  child: Slider(

                      value: value ,
                      onChanged: (val) {

                        sliderValue = (widget.min+(widget.max-widget.min)*value);
                        setState(() {
                          value  = val;
                        });
                      }),
                ),
              ),
            ),
            SizedBox(
              width: this.widget.sliderHeight * .1,
            ),
            Text(
              '${this.widget.max}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: this.widget.sliderHeight * .3,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),

      ),
    );
  }
}