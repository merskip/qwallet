import 'dart:ui';

import 'package:image/image.dart';

Image cropImage(Image sourceImage, Rect rect) {
  var resultImage = Image(rect.width.toInt(), rect.height.toInt());

  var i = 0;
  for (var y = rect.top.toInt(); y < rect.bottom; y++) {
    for (var x = rect.left.toInt(); x < rect.right; x++) {
      final pixel = sourceImage.getPixel(x, y);
      resultImage[i] = pixel;
      i++;
    }
  }

  return resultImage;
}

Image adjustContrast(Image image) {
  var resultImage = Image(image.width, image.height, channels: Channels.rgb);

  final len = image.length;
  for (var i = 0; i < len; ++i) {
    var value = pixelToGray(image, i);
    if (value < 96)
      resultImage[i] = 0x0;
    else if (value > 192)
      resultImage[i] = 0xffffff;
    else {
      final v = ((value - 96) / (192 - 96) * 255).toInt();
      resultImage[i] = grayToRgb(v);
    }
  }

  return resultImage;
}

int pixelToGray(Image image, int i) =>
    (getRed(image[i]) + getGreen(image[i]) + getBlue(image[i])) ~/ 3;

int grayToRgb(int i) => i << 16 | i << 8 | i;
