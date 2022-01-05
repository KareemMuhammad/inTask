import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:taskaty/utils/shared.dart';

class MyShimmer extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;
  final Color baseColor;

  const MyShimmer.rectangular({Key key, this.width = double.infinity, this.height, this.shapeBorder = const RoundedRectangleBorder(), this.baseColor}) : super(key: key);

  const MyShimmer.circular({Key key, this.width, this.height, this.shapeBorder = const CircleBorder(), this.baseColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        child: Container(
          width: width,
          height: height,
          decoration: ShapeDecoration(
            color: white,
            shape: shapeBorder,
          ),
        ),
        baseColor: baseColor,
        highlightColor: Colors.grey[100]);
  }
}
