import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

class MutableImage {
  Uint32List _data;
  int _width;
  int _height;

  MutableImage(Uint32List data, int width, int height)
      : _data = data,
        _width = width,
        _height = height;

  static Future<MutableImage> fromFile(File file) async {
    final bytes = await file.readAsBytes();
    final completer = Completer<Image>();
    decodeImageFromList(bytes, (image) {
      completer.complete(image);
    });
    final image = await completer.future;
    return MutableImage.fromImage(image);
  }

  static Future<MutableImage> fromImage(Image image) async {
    final data = await image.toByteData();
    return MutableImage(data!.buffer.asUint32List(), image.width, image.height);
  }

  Future<MutableImage> copy() {
    return Future.microtask(() {
      return MutableImage(
        Uint32List.fromList(_data),
        _width,
        _height,
      );
    });
  }

  Future<Image> toImage() {
    final completer = Completer<Image>();
    decodeImageFromPixels(
      _data.buffer.asUint8List(),
      _width,
      _height,
      PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }

  void crop(int x, int y, int width, int height) {
    final dstData = Uint32List(width * height);

    for (var srcY = y, dstY = 0; dstY < height; ++srcY, ++dstY) {
      for (var srcX = x, dstX = 0; dstX < width; ++srcX, ++dstX) {
        final srcOffset = srcY * _width + srcX;
        final dstOffset = dstY * width + dstX;
        dstData[dstOffset] = _data[srcOffset];
      }
    }
    _data = dstData;
    _width = width;
    _height = height;
  }

  void rotate(double radians) {
    final dstData = Uint32List(_width * _height);
    final centerX = _width / 2, centerY = _height / 2;

    for (var dstY = 0; dstY < _height; ++dstY) {
      for (var dstX = 0; dstX < _width; ++dstX) {
        final srcX = (dstX - centerX) * cos(radians) -
            (dstY - centerY) * sin(radians) +
            centerX;
        final srcY = (dstX - centerX) * sin(radians) +
            (dstY - centerY) * cos(radians) +
            centerY;

        if (srcX > 0 && srcX < _width && srcY > 0 && srcY < _height) {
          final srcOffset = srcY.round() * _width + srcX.round();
          if (srcOffset > 0 && srcOffset < _data.length) {
            final dstOffset = dstY * _width + dstX;
            dstData[dstOffset] = _data[srcOffset];
          }
        }
      }
    }
    _data = dstData;
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

  Color getLinearPixel(double x, double y) {
    return Color(_data[_getOffset(x.toInt(), y.toInt())]);
  }

  void mapEachPixel(Color Function(int x, int y, Color color) mapper) {
    for (var y = 0; y < _height; ++y) {
      for (var x = 0; x < _width; ++x) {
        final pixel = getPixel(x, y);
        final newPixel = mapper(x, y, pixel);
        setPixel(x, y, newPixel);
      }
    }
  }

  Color getPixel(int x, int y) {
    final pixel = _data[_getOffset(x, y)];
    final alpha = pixel >> 24 & 0x0ff;
    final blue = pixel >> 16 & 0xff;
    final green = pixel >> 8 & 0xff;
    final red = pixel & 0xff;
    return Color.fromARGB(alpha, red, green, blue);
  }

  void setPixel(int x, int y, Color color) {
    _data[_getOffset(x, y)] =
        color.alpha << 24 | color.blue << 16 | color.green << 8 | color.red;
  }

  int _getOffset(int x, int y) => y * _width + x;
}

extension ColorMutating on Color {
  Color set({
    required int red,
    required int green,
    required int blue,
    int? alpha,
  }) {
    return Color.fromARGB(
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
