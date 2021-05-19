import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:image/image.dart' as Image;

class MutableImage {
  final Image.Image _image;

  int get width => _image.width;

  int get height => _image.height;

  MutableImage(Image.Image image) : _image = image;

  static Future<MutableImage> fromFile(File file) async {
    final bytes = await file.readAsBytes();
    final image = Image.decodeImage(bytes);
    if (image != null) {
      return MutableImage(image);
    } else {
      throw ("Failed decode image");
    }
  }

  static Future<MutableImage> fromImage(ui.Image uiImage) async {
    final data = await uiImage.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (data == null) throw ("Failed convert image to byte data");
    return Image.Image.fromBytes(
      uiImage.width,
      uiImage.height,
      data.buffer.asUint8List(),
    ).toMutableImage();
  }

  Future<ui.Image> toImage() async {
    final bytes = _image.getBytes();
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
        bytes, width, height, ui.PixelFormat.rgba8888, completer.complete);
    return completer.future;
  }

  Future<void> saveToFile(File file) async {
    final bytes = Image.encodeJpg(_image);
    await file.writeAsBytes(bytes, flush: true);
  }

  MutableImage crop(int x, int y, int width, int height) {
    return Image.copyCrop(_image, x, y, width, height).toMutableImage();
  }

  MutableImage rotate(double angle, {bool keepSize = false}) {
    var image = Image.copyRotate(_image, -angle * 180 / pi);
    if (keepSize) {
      image = Image.copyCrop(
        image,
        (image.width - _image.width) ~/ 2,
        (image.height - _image.height) ~/ 2,
        width,
        height,
      );
    }
    return image.toMutableImage();
  }

  MutableImage resize(int width, int height) {
    return Image.copyResize(_image, width: width, height: height)
        .toMutableImage();
  }

  MutableImage brightness(int brightness) {
    return mapEachPixel(
      (x, y, pixel) => pixel.set(
        red: pixel.red + brightness,
        green: pixel.green + brightness,
        blue: pixel.blue + brightness,
      ),
    );
  }

  MutableImage contrast(int contrast) {
    final factor = (259 * (contrast + 255)) / (255 * (259 - contrast));
    return mapEachPixel(
      (x, y, pixel) => pixel.set(
        red: (factor * (pixel.red - 127) + 128).truncate(),
        green: (factor * (pixel.green - 127) + 128).truncate(),
        blue: (factor * (pixel.blue - 127) + 128).truncate(),
      ),
    );
  }

  MutableImage mapEachPixel(
      ui.Color Function(int x, int y, ui.Color color) mapper) {
    final image = Image.Image.from(_image);
    for (var y = 0; y < height; ++y) {
      for (var x = 0; x < width; ++x) {
        final pixel = ui.Color(image.getPixel(x, y));
        final newPixel = mapper(x, y, pixel);
        image.setPixel(x, y, newPixel.value);
      }
    }
    return image.toMutableImage();
  }
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

extension ImageConverting on Image.Image {
  MutableImage toMutableImage() => MutableImage(this);
}
