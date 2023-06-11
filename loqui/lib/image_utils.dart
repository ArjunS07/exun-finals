import 'dart:ui';

import 'package:bitmap/bitmap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:typed_data';

Future<Uint8List?> svgToPng(BuildContext context, String svgString,
    {int svgWidth = 100, int svgHeight = 100}) async {
  DrawableRoot svgDrawableRoot = await svg.fromSvgString(svgString, 'svg');

  // to have a nice rendering it is important to have the exact original height and width,
  // the easier way to retrieve it is directly from the svg string
  // but be careful, this is an ugly fix for a flutter_svg problem that works
  // with my images
  String temp = svgString.substring(svgString.indexOf('height="') + 8);
  int originalHeight = svgHeight;
  temp = svgString.substring(svgString.indexOf('width="') + 7);
  int originalWidth = svgWidth;

  // toPicture() and toImage() don't seem to be pixel ratio aware, so we calculate the actual sizes here
  double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

  double width = originalHeight *
      devicePixelRatio; // where 32 is your SVG's original width
  double height = originalWidth * devicePixelRatio; // same thing

  // Convert to ui.Picture
  final picture = svgDrawableRoot.toPicture(size: Size(width, height));

  // Convert to ui.Image. toImage() takes width and height as parameters
  // you need to find the best size to suit your needs and take into account the screen DPI
  final image = await picture.toImage(width.toInt(), height.toInt());
  ByteData? bytes = await image.toByteData(format: ImageByteFormat.png);

  return bytes?.buffer.asUint8List();
}

String uint8ListTob64(Uint8List uint8list) {
  String base64String = base64Encode(uint8list);
  String header = "data:image/png;base64,";
  return header + base64String;
}
