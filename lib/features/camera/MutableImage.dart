import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:image/image.dart' as Image;

class MutableImage {
  Image.Image _image;

  int get width => _image.width;
  int get height => _image.height;

  MutableImage(Image.Image image) : _image = image;

  static Future<MutableImage> fromFile(File file) async {
    final bytes = await file.readAsBytes();
    final image = Image.decodeImage(bytes);
    if (image != null) {
      print("Image size: ${image.width}x${image.height}");
      return MutableImage(image);
    } else {
      return Future.error("Failed decode image");
    }
  }

  Future<MutableImage> copy() async {
    return this;
    // return Future.microtask(() {
    //   return MutableImage(
    //     Uint32List.fromList(_data),
    //     _width,
    //     _height,
    //   );
    // });
  }

  Future<void> saveToFile(File file) async {
    final bytes = Image.encodeJpg(_image);
    await file.writeAsBytes(bytes, flush: true);
  }

  void crop(int x, int y, int width, int height) {
    // final dstData = Uint32List(width * height);
    //
    // for (var srcY = y, dstY = 0; dstY < height; ++srcY, ++dstY) {
    //   for (var srcX = x, dstX = 0; dstX < width; ++srcX, ++dstX) {
    //     final srcOffset = srcY * _width + srcX;
    //     final dstOffset = dstY * width + dstX;
    //     dstData[dstOffset] = _data[srcOffset];
    //   }
    // }
    // _data = dstData;
    // _width = width;
    // _height = height;
  }

  void rotate(double radians) {
    // final dstData = Uint32List(_width * _height);
    // final centerX = _width / 2, centerY = _height / 2;
    //
    // for (var dstY = 0; dstY < _height; ++dstY) {
    //   for (var dstX = 0; dstX < _width; ++dstX) {
    //     final srcX = (dstX - centerX) * cos(radians) -
    //         (dstY - centerY) * sin(radians) +
    //         centerX;
    //     final srcY = (dstX - centerX) * sin(radians) +
    //         (dstY - centerY) * cos(radians) +
    //         centerY;
    //
    //     if (srcX > 0 && srcX < _width && srcY > 0 && srcY < _height) {
    //       final srcOffset = srcY.round() * _width + srcX.round();
    //       if (srcOffset > 0 && srcOffset < _data.length) {
    //         final dstOffset = dstY * _width + dstX;
    //         dstData[dstOffset] = _data[srcOffset];
    //       }
    //     }
    //   }
    // }
    // _data = dstData;
  }

  void resize(int width, int height) {
    // final dstData = Uint32List(width * height);
    // final xRadio = width / _width, yRadio = height / _height;
    //
    // for (var dstY = 0; dstY < _height; ++dstY) {
    //   for (var dstX = 0; dstX < _width; ++dstX) {
    //     final srcX = (dstX * xRadio).round();
    //     final srcY = (dstY * yRadio).round();
    //     final dstOffset = dstY * width + dstX;
    //     final srcOffset = srcY * _width + srcX;
    //     dstData[dstOffset] = _data[srcOffset];
    //   }
    // }
    // _data = dstData;

    _image = Image.copyResize(_image, width: width, height: height);
  }

  void brightness(int brightness) {
    mapEachPixel(
      (x, y, pixel) => pixel.set(
        red: pixel.red + brightness,
        green: pixel.green + brightness,
        blue: pixel.blue + brightness,
      ),
    );
  }

  void contrast(int contrast) {
    final factor = (259 * (contrast + 255)) / (255 * (259 - contrast));
    mapEachPixel(
      (x, y, pixel) => pixel.set(
        red: (factor * (pixel.red - 127) + 128).truncate(),
        green: (factor * (pixel.green - 127) + 128).truncate(),
        blue: (factor * (pixel.blue - 127) + 128).truncate(),
      ),
    );
  }

  // Color getPixelUsingNearestNeighbor(double x, double y) {
  //   return Color(_data[_getOffset(x.round(), y.round())]);
  // }

  // Color getPixelUsingBilinear(double x, double y) {}

  void mapEachPixel(ui.Color Function(int x, int y, ui.Color color) mapper) {
    // for (var y = 0; y < _height; ++y) {
    //   for (var x = 0; x < _width; ++x) {
    //     final pixel = getPixel(x, y);
    //     final newPixel = mapper(x, y, pixel);
    //     setPixel(x, y, newPixel);
    //   }
    // }
  }

  // ui.Color getPixel(int x, int y) {
  //   final pixel = _data[_getOffset(x, y)];
  //   final alpha = pixel >> 24 & 0x0ff;
  //   final blue = pixel >> 16 & 0xff;
  //   final green = pixel >> 8 & 0xff;
  //   final red = pixel & 0xff;
  //   return ui.Color.fromARGB(alpha, red, green, blue);
  // }
  //
  // void setPixel(int x, int y, ui.Color color) {
  //   _data[_getOffset(x, y)] =
  //       color.alpha << 24 | color.blue << 16 | color.green << 8 | color.red;
  // }
  //
  // int _getOffset(int x, int y) => y * _width + x;
}

extension ColorMutating on ui.Color {
  ui.Color set({
    required int red,
    required int green,
    required int blue,
    int? alpha,
  }) {
    return ui.Color.fromARGB(
      _clamp(alpha ?? this.alpha),
      _clamp(red),
      _clamp(green),
      _clamp(blue),
    );
  }

  int _clamp(int value) {
    return min(max(value, 0), 255);
  }
}
