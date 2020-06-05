import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart' as m;
import 'package:image/image.dart';

import 'image_utils.dart';

class ReceiptDetector {
  Future<Rect> detect(File photoFile) async {
    final photoImage = gaussianBlur(copyResize(decodeImage(photoFile.readAsBytesSync()), width: 640), 2);

//    final edgeImage = convolution(
//      photoImage,
//      [-2, 4, -2,
//       -2, 4, -2,
//       -2, 4, -2],
//    );

    final edgeImage = Image(photoImage.width, photoImage.height);
    for (int y = 1; y < photoImage.height; y++) {
      for (int x = 1; x < photoImage.width; x++) {
        final diff = rgbToGray(photoImage.getPixel(x - 1, y - 1)) - rgbToGray(photoImage.getPixel(x, y));
        final color = grayToRgb(min(255, diff.abs() * diff.abs()));
        edgeImage.setPixel(x, y, grayToRgb(color));
      }
    }

    final verticalLines = detectVerticalLines(edgeImage, 16);
    final horizontalLines = detectHorizontalLines(photoImage);

    final postFile = File(
        photoFile.path.substring(0, photoFile.path.length - 4) + "-edges.jpg");
    postFile.writeAsBytesSync(encodeJpg(edgeImage));

    if (verticalLines.length < 2 || horizontalLines.length < 2) return null;

    return Rect.fromLTRB(
      verticalLines.first.toDouble(),
      horizontalLines.first.toDouble(),
      verticalLines.last.toDouble(),
      horizontalLines.last.toDouble(),
    );
  }


  List<int> detectVerticalLines(Image image, maxSize) {
    final center = Point(image.width / 2, image.height / 2);

    for (int x = maxSize ~/ 2; x < image.width; x += maxSize) {
      final pixel = Point(x, center.yi);
      final edgePoint = getHEdgePoint(image, pixel, maxSize);

      if (edgePoint != null) {
        final length = detectLengthOfLine(image, edgePoint, maxSize);
        if (length > 128) {
          print("x=$x has edge, length=$length");
          for (int y = 0; y < image.height; y++) {
            image.setPixel(x, y, 0xff0000);
          }
        }
      }
    }
    return []; //merge(lines);
  }

  List<int> detectHorizontalLines(Image image) {
    return [];
    final center = Point(image.width / 2, image.height / 2);
    int lastYPixel = rgbToGray(image.getPixel(center.xi, 0));
    final lines = List<int>();

    for (int y = 1; y < image.height; y++) {
      final pixel = rgbToGray(image.getPixel(center.yi, y));
      final delta = (pixel - lastYPixel).toDouble() / 255.0;

      if (delta > 0.05 && checkIsHorizontalLine(image, Point(center.xi, y))) {
        lines.add(y);
      }
    }
    return merge(lines);
  }

  bool checkIsVerticalLine(Image image, Point point) {
    final leftTop = rgbToGray(image.getPixel(point.x - 8, point.y + 8));
    final rightTop = rgbToGray(image.getPixel(point.x + 8, point.y + 8));
    final leftBottom = rgbToGray(image.getPixel(point.x - 8, point.y - 8));
    final rightBottom = rgbToGray(image.getPixel(point.x + 8, point.y - 8));

    return (isDark(leftTop) &&
            isDark(leftBottom) &&
            isLight(rightTop) &&
            isLight(rightBottom)) ||
        ((isLight(leftTop) &&
            isLight(leftBottom) &&
            isDark(rightTop) &&
            isDark(rightBottom)));
  }

  bool checkIsHorizontalLine(Image image, Point point) {
    if (!image.boundsSafe(point.x - 8, point.y - 8) ||
        !image.boundsSafe(point.x + 8, point.y + 8)) return true;

    final leftTop = rgbToGray(image.getPixel(point.x - 8, point.y + 8));
    final rightTop = rgbToGray(image.getPixel(point.x + 8, point.y + 8));
    final leftBottom = rgbToGray(image.getPixel(point.x - 8, point.y - 8));
    final rightBottom = rgbToGray(image.getPixel(point.x + 8, point.y - 8));

    return (isDark(leftTop) &&
            isDark(rightTop) &&
            isLight(leftBottom) &&
            isLight(rightBottom)) ||
        ((isLight(leftTop) &&
            isLight(rightTop) &&
            isDark(leftBottom) &&
            isDark(rightBottom)));
  }

  bool isDark(int color) => color < 127;

  bool isLight(int color) => color > 127;

  int detectLengthOfLine(Image image, Point baseEdgePoint, int maxSize) {
    int upLength = 0;
    int upX = baseEdgePoint.x;
    int upNo = 0;
    for (int y = baseEdgePoint.yi; y >= 0; y--) {
      final pixel = Point(upX, y);
      final edgePoint = getHEdgePoint(image, pixel, maxSize);
      if (edgePoint == null) {
        upNo++;
        if (upNo > maxSize ~/ 2) {
          break;
        }
      }
      else {
        upX = edgePoint.x;
        upLength += upNo + 1;
        upNo = 0;
        upNo = 0;
      }
    }

    int downLength = 0;
    int downX = baseEdgePoint.x;
    for (int y = baseEdgePoint.yi; y < image.height; y++) {
      final pixel = Point(downX, y);
      final edgePoint = getHEdgePoint(image, pixel, maxSize);
      if (edgePoint == null) break;
      downX = edgePoint.x;
      downLength++;
    }

//    print("point: $point upLenght: $upLength downLenght: $downLength");
    return upLength + downLength;
  }

  Point getHEdgePoint(Image image, Point point, int maxSize) {
    final chunkPoint = Point(point.x - maxSize ~/ 2, point.y);
    final chunk = getHChunk(image, chunkPoint, maxSize);

    int risingIndex = -1;
    for (int i = 1; i < chunk.length; i++) {
      if (chunk[i - 1] < chunk[i] && chunk[i] > 127) {
        risingIndex = i - 1;
        break;
      }
    }

    int fallingIndex = -1;
    for (int i = 1; i < chunk.length; i++) {
      if (chunk[i - 1] > chunk[i] && chunk[i - 1] > 127) {
        fallingIndex = i;
        break;
      }
    }

    if (risingIndex != -1 && fallingIndex != -1) {
      final middleIndex = risingIndex + (fallingIndex - risingIndex) ~/ 2;
      final point =  Point(chunkPoint.x + middleIndex, chunkPoint.y);
      image.setPixel(point.x, point.y, m.Colors.red.value);
      return point;
    }
    else {
      return null;
    }
//
//    for (int i = 1; i < chunk.length; i++) {
//      final delta = (chunk[i] - lastPixel).toDouble() / 255.0;
//
//      deltaSum += delta;
//      if (delta > maxDelta) {
//        maxDelta = delta;
//        deltaIndex = i;
//      }
//    }
//    if (deltaSum > 0.05) {
//      image.setPixel(
//          chunkPoint.x + deltaIndex, chunkPoint.y, m.Colors.red.value);
//      return Point(chunkPoint.x + deltaIndex, chunkPoint.y);
//    }
//    return null;
  }

  List<int> getHChunk(Image image, Point point, int maxSize) {
    final pixels = List<int>();
    final minX = max(0, point.x);
    final maxX = min(image.width, point.x + maxSize);
    for (int x = minX; x < maxX; x++)
      pixels.add(rgbToGray(image.getPixel(x, point.yi)));
    return pixels;
  }

  List<int> merge(List<int> list) {
    if (list.isEmpty) return [];
    final result = List<List<int>>();
    final values = List<int>();

    for (final value in list) {
      if (values.isEmpty) {
        values.add(value);
      } else {
        if ((values.last - value).abs() < 4) {
          values.add(value);
        } else {
          result.add(List.from(values));
          values.clear();
          values.add(value);
        }
      }
    }
    result.add(List.from(values));

    return result.fold(List<int>(), (value, element) {
      final minValue = element[element.length ~/ 2];
      value.add(minValue);
      return value;
    });
  }
}
