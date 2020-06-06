import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:image/image.dart';

import 'image_utils.dart';

class ReceiptDetector {
  Future<Rect> detect(File photoFile) async {
    final photoImage = gaussianBlur(
        copyResize(decodeImage(photoFile.readAsBytesSync()), width: 640), 2);

    final edgeImage = Image(photoImage.width, photoImage.height);
    for (int y = 1; y < photoImage.height; y++) {
      for (int x = 1; x < photoImage.width; x++) {
        final diff = rgbToGray(photoImage.getPixel(x - 1, y - 1)) -
            rgbToGray(photoImage.getPixel(x, y));
        final color = grayToRgb(min(255, diff.abs() * diff.abs()));
        edgeImage.setPixel(x, y, grayToRgb(color));
      }
    }

    final verticalLines = _VerticalLineDetector(edgeImage).detect();
    for (final line in verticalLines) {
      drawLine(edgeImage, line.start.xi, line.start.yi, line.end.xi, line.end.y,
          0xffff0000);
    }

    final horizontalLines = _HorizontalLineDetector(edgeImage).detect();
    for (final line in horizontalLines) {
      drawLine(edgeImage, line.start.xi, line.start.yi, line.end.xi, line.end.y,
          0xff0000ff);
    }

    final postFile = File(
        photoFile.path.substring(0, photoFile.path.length - 4) + "-edges.jpg");
    postFile.writeAsBytesSync(encodeJpg(edgeImage));

    final center = Point(edgeImage.width / 2, edgeImage.height / 2);

    final leftLines = verticalLines
      ..sort((lhs, rhs) => lhs.minX.compareTo(rhs.minX));
    _LineSegment leftLine = leftLines.isNotEmpty && leftLines.first.maxX < center.xi ? leftLines.first : null;
    _LineSegment rightLine = leftLines.isNotEmpty && leftLines.last.minX > center.xi ? leftLines.last : null;

    final topLines = horizontalLines
      ..sort((lhs, rhs) => lhs.minY.compareTo(rhs.minY));
    _LineSegment topLine = topLines.isNotEmpty && topLines.first.maxY < center.yi ? topLines.first : null;
    _LineSegment bottomLine = topLines.isNotEmpty && topLines.last.minY > center.yi ? topLines.last : null;

    final edgeReceiptRect = Rect.fromLTRB(
      leftLine?.minX?.toDouble() ?? 0,
      topLine?.minY?.toDouble() ?? 0,
      rightLine?.maxX?.toDouble() ?? edgeImage.width.toDouble(),
      bottomLine?.maxY?.toDouble() ?? edgeImage.height.toDouble()
    );

    return edgeReceiptRect;
  }
}

class _VerticalLineDetector {
  final Image edgeImage;

  _VerticalLineDetector(this.edgeImage);

  List<_LineSegment> detect() {
    final center = Point(edgeImage.width / 2, edgeImage.height / 2);
    final lines = List<_LineSegment>();
    for (int x = 0; x < edgeImage.width; x += 3) {
      final position = Point(x, center.yi);
      if (_isEdge(position)) {
        final topLeaf = getLeafOfLine(position, 2);
        final downLeaf = getLeafOfLine(position, -2);
        final length = sqrt(
            pow(downLeaf.x - topLeaf.x, 2) + pow(downLeaf.y - topLeaf.y, 2));
        if (length > 128) {
          lines.add(_LineSegment(topLeaf, downLeaf, length));
          x += 3;
        }
      }
    }
    return lines;
  }

  Point getLeafOfLine(Point position, int deltaY) {
    for (int y = position.yi + deltaY;
        y > 0 && y < edgeImage.height;
        y += deltaY) {
      final points = [
        Point(position.x, y),
        Point(position.x - 1, y),
        Point(position.x + 1, y),
        Point(position.x - 2, y),
        Point(position.x + 2, y),
      ];
      bool anyMeets = false;
      for (final point in points) {
        if (_isEdge(point)) {
          position = point;
          anyMeets = true;
          break;
        }
      }
      if (!anyMeets) {
        return position;
      }
    }
    return position;
  }

  bool _isEdge(Point position) {
    return rgbToGray(edgeImage.getPixel(position.x, position.y)) > 128;
  }
}

class _HorizontalLineDetector {
  final Image edgeImage;

  _HorizontalLineDetector(this.edgeImage);

  List<_LineSegment> detect() {
    final center = Point(edgeImage.width / 2, edgeImage.height / 2);
    final lines = List<_LineSegment>();
    for (int y = 0; y < edgeImage.height; y += 3) {
      final position = Point(center.xi, y);
      if (_isEdge(position)) {
        final topLeaf = getLeafOfLine(position, 2);
        final downLeaf = getLeafOfLine(position, -2);
        final length = sqrt(
            pow(downLeaf.x - topLeaf.x, 2) + pow(downLeaf.y - topLeaf.y, 2));
        if (length > 128) {
          lines.add(_LineSegment(topLeaf, downLeaf, length));
          y += 3;
        }
      }
    }
    return lines;
  }

  Point getLeafOfLine(Point position, int deltaX) {
    for (int x = position.xi + deltaX;
        x > 0 && x < edgeImage.width;
        x += deltaX) {
      final points = [
        Point(x, position.y),
        Point(x, position.y - 1),
        Point(x, position.y + 1),
        Point(x, position.y - 2),
        Point(x, position.y + 2),
      ];
      bool anyMeets = false;
      for (final point in points) {
        if (_isEdge(point)) {
          position = point;
          anyMeets = true;
          break;
        }
      }
      if (!anyMeets) {
        return position;
      }
    }
    return position;
  }

  bool _isEdge(Point position) {
    return rgbToGray(edgeImage.getPixel(position.x, position.y)) > 128;
  }
}

class _LineSegment {
  final Point start;
  final Point end;
  final double length;

  int get minX => min(start.x, end.x);

  int get maxX => max(start.x, end.x);

  int get minY => min(start.y, end.y);

  int get maxY => max(start.y, end.y);

  _LineSegment(this.start, this.end, this.length);

  @override
  String toString() {
    return '[(${start.xi},${start.yi}), (${end.xi},${end.yi}), l=$length]';
  }
}
