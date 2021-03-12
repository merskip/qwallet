import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class VectorImage extends StatelessWidget {
  final String assetName;
  final Size size;
  final Color color;

  const VectorImage(this.assetName, {Key key, this.size, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetName,
      width: size?.width,
      height: size?.height,
      color: color,
    );
  }
}
