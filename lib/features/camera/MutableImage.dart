import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

class MutableImage {
  final ByteData data;
  final int width;
  final int height;

  MutableImage(this.data, this.width, this.height);

  static Future<MutableImage> fromImage(Image image) async {
    final data = await image.toByteData();
    return MutableImage(data!, image.width, image.height);
  }

  Future<Image> toImage() {
    final completer = Completer<Image>();
    decodeImageFromPixels(
      data.buffer.asUint8List(),
      width,
      height,
      PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }

  void setPixel(int x, int y, Color color) {
    data.setInt8(_getOffset(x, y), color.value);
  }

  int _getOffset(int x, int y) => y * width + x;
}
