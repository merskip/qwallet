import 'dart:async';
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

  static Future<MutableImage> fromImage(Image image) async {
    final data = await image.toByteData();
    return MutableImage(data!.buffer.asUint32List(), image.width, image.height);
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
    final dstData = Uint32List(_width * _height);

    for (var srcY = 0, dstY = y; dstY < _height; ++srcY, ++dstY) {
      for (var srcX = 0, dstX = x; dstX < _width; ++srcX, ++dstX) {
        final dstOffset = dstY * _width + dstX;
        final srcOffset = srcY * width + srcX;
        final pixel = _data[dstOffset];
        dstData[srcOffset] = pixel;
      }
    }
    _data = dstData;
    _width = width;
    _height = height;
  }

  Color getPixel(int x, int y) {
    return Color(_data[_getOffset(x, y)]);
  }

  void setPixel(int x, int y, Color color) {
    _data[_getOffset(x, y)] =
        color.alpha << 24 | color.blue << 16 | color.green << 8 | color.red;
  }

  int _getOffset(int x, int y) => y * _width + x;
}
