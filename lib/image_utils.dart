import 'dart:ui';

import 'package:image/image.dart';

Image cropImage({Image sourceImage, Rect rect}) {
  var resultImage = new Image(rect.width.toInt(), rect.height.toInt());

  for (final y in Iterable<int>.generate(rect.height.toInt())) {
    for (final x in Iterable<int>.generate(rect.width.toInt())) {
      final pixel = sourceImage.getPixelCubic(rect.left + x, rect.top + y);
      resultImage.setPixel(x, y, pixel);
    }
  }
  return resultImage;
}