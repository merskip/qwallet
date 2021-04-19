import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ImageCroppingPreview extends StatelessWidget {
  final ui.Image image;
  final ValueNotifier<CroppingState> croppingState;

  const ImageCroppingPreview({
    Key? key,
    required this.image,
    required this.croppingState,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        croppingState.value =
            croppingState.value.panStart(details, dragRadius: 36);
      },
      onPanUpdate: (details) {
        croppingState.value =
            croppingState.value.panUpdate(details, minSize: 96);
      },
      onPanEnd: (details) {
        croppingState.value = croppingState.value.panEnd();
      },
      child: ValueListenableBuilder<CroppingState>(
        valueListenable: croppingState,
        builder: (context, croppingState, child) {
          return CustomPaint(
            painter: ImageCroppingPainter(
              image: image,
              rotate: croppingState.effectiveRotation,
            ),
            foregroundPainter: CropPainter(
              cropState: croppingState,
              dotRadius: 12,
              normalColor: Colors.white,
              selectedColor: Theme.of(context).accentColor,
            ),
          );
        },
      ),
    );
  }
}

class ImageCroppingToolbar extends StatelessWidget {
  final ValueNotifier<CroppingState> croppingState;

  const ImageCroppingToolbar({
    Key? key,
    required this.croppingState,
  }) : super(key: key);

  void onSelectedCroppingReset(BuildContext context) {
    croppingState.value = croppingState.value.reset();
  }

  void onChangedRotation(BuildContext context, double rotation) {
    croppingState.value = croppingState.value.setRotation(rotation);
  }

  void onSelectedRotateLeft(BuildContext context) {
    croppingState.value = croppingState.value.rotateLeft();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CroppingState>(
      valueListenable: croppingState,
      builder: (context, croppingState, child) {
        return Row(children: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.undo, size: 16),
            color: Colors.white,
            onPressed: () => onSelectedCroppingReset(context),
            tooltip: "#Reset cropping",
          ),
          Flexible(
            child: Slider(
              value: croppingState.rotation,
              min: -pi / 2,
              max: pi / 2,
              onChanged: (value) => onChangedRotation(context, value),
            ),
          ),
          IconButton(
            icon: Icon(Icons.rotate_left),
            color: Colors.white,
            onPressed: () => onSelectedRotateLeft(context),
            tooltip: "#Rotate left",
          ),
        ]);
      },
    );
  }
}

class ImageCroppingPainter extends CustomPainter {
  final ui.Image image;
  final double rotate;

  ImageCroppingPainter({
    required this.image,
    required this.rotate,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotate);
    canvas.translate(-size.width / 2, -size.height / 2);

    canvas.drawImage(image, Offset.zero, Paint());
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ImageCroppingPainter oldDelegate) {
    return image != oldDelegate.image || rotate != oldDelegate.rotate;
  }
}

class CropPainter extends CustomPainter {
  final CroppingState cropState;
  final double dotRadius;
  final Color normalColor;
  final Color selectedColor;

  CropPainter({
    required this.cropState,
    required this.dotRadius,
    required this.normalColor,
    required this.selectedColor,
  });

  @override
  void paint(Canvas canvas, ui.Size size) {
    canvas.saveLayer(cropState.imageRect, Paint());
    canvas.drawRect(
      cropState.imageRect,
      Paint()..color = Colors.black54,
    );
    canvas.drawRect(
      cropState.crop,
      Paint()..blendMode = BlendMode.clear,
    );
    canvas.restore();

    if (cropState.isDraggingOffset) {
      canvas.drawRect(
        cropState.crop,
        Paint()..color = selectedColor.withOpacity(0.12),
      );
    }

    canvas.drawLine(
      cropState.crop.bottomLeft,
      cropState.crop.topLeft,
      getEdgePaint(isSelected: cropState.isDraggingLeft),
    );

    canvas.drawLine(
      cropState.crop.topLeft,
      cropState.crop.topRight,
      getEdgePaint(isSelected: cropState.isDraggingTop),
    );

    canvas.drawLine(
      cropState.crop.topRight,
      cropState.crop.bottomRight,
      getEdgePaint(isSelected: cropState.isDraggingRight),
    );

    canvas.drawLine(
      cropState.crop.bottomRight,
      cropState.crop.bottomLeft,
      getEdgePaint(isSelected: cropState.isDraggingBottom),
    );

    canvas.drawCircle(
      cropState.crop.topLeft,
      dotRadius,
      getDotPaint(isSelected: cropState.isDraggingTopLeft),
    );
    canvas.drawCircle(
      cropState.crop.topRight,
      dotRadius,
      getDotPaint(isSelected: cropState.isDraggingTopRight),
    );
    canvas.drawCircle(
      cropState.crop.bottomRight,
      dotRadius,
      getDotPaint(isSelected: cropState.isDraggingBottomRight),
    );
    canvas.drawCircle(
      cropState.crop.bottomLeft,
      dotRadius,
      getDotPaint(isSelected: cropState.isDraggingBottomLeft),
    );
  }

  Paint getEdgePaint({required bool isSelected}) => Paint()
    ..strokeWidth = 4
    ..color = isSelected ? selectedColor : normalColor;

  Paint getDotPaint({required bool isSelected}) =>
      Paint()..color = isSelected ? selectedColor : normalColor;

  @override
  bool shouldRepaint(covariant CropPainter oldDelegate) {
    return cropState != oldDelegate.cropState;
  }
}

class CroppingState {
  final Rect crop;
  final Rect draggingCrop;
  final Rect imageRect;
  final double baseRotation;
  final double rotation;

  final bool isDraggingLeft;
  final bool isDraggingTop;
  final bool isDraggingRight;
  final bool isDraggingBottom;
  final bool isDraggingOffset;

  double get effectiveRotation => baseRotation + rotation;

  bool get isDraggingTopLeft => isDraggingTop && isDraggingLeft;

  bool get isDraggingTopRight => isDraggingTop && isDraggingRight;

  bool get isDraggingBottomRight => isDraggingBottom && isDraggingRight;

  bool get isDraggingBottomLeft => isDraggingBottom && isDraggingLeft;

  CroppingState(Rect imageRect)
      : crop = imageRect,
        draggingCrop = imageRect,
        imageRect = imageRect,
        baseRotation = 0.0,
        rotation = 0.0,
        isDraggingLeft = false,
        isDraggingTop = false,
        isDraggingRight = false,
        isDraggingBottom = false,
        isDraggingOffset = false;

  CroppingState._(
    this.crop,
    this.draggingCrop,
    this.imageRect,
    this.baseRotation,
    this.rotation,
    this.isDraggingLeft,
    this.isDraggingTop,
    this.isDraggingRight,
    this.isDraggingBottom,
    this.isDraggingOffset,
  );

  CroppingState reset() => CroppingState(imageRect);

  CroppingState rotateLeft() => _copy(
        baseRotation: baseRotation - pi / 2,
        rotation: 0.0,
      );

  CroppingState setRotation(double rotation) => _copy(
        rotation: rotation,
      );

  CroppingState panStart(DragStartDetails details,
      {required double dragRadius}) {
    final dx = details.localPosition.dx;
    final dy = details.localPosition.dy;
    final isDraggingLeft = (dx - crop.left).abs() < dragRadius;
    final isDraggingTop = (dy - crop.top).abs() < dragRadius;
    final isDraggingRight = (dx - crop.right).abs() < dragRadius;
    final isDraggingBottom = (dy - crop.bottom).abs() < dragRadius;
    final isDraggingOffset = crop.contains(details.localPosition) &&
        !isDraggingLeft &&
        !isDraggingTop &&
        !isDraggingRight &&
        !isDraggingBottom;

    print("Pan start: "
        "left=$isDraggingLeft, "
        "top=$isDraggingTop, "
        "right=$isDraggingRight, "
        "bottom=$isDraggingBottom, "
        "offset=$isDraggingOffset");
    return _copy(
      isDraggingLeft: isDraggingLeft,
      isDraggingTop: isDraggingTop,
      isDraggingRight: isDraggingRight,
      isDraggingBottom: isDraggingBottom,
      isDraggingOffset: isDraggingOffset,
    );
  }

  CroppingState panUpdate(DragUpdateDetails details,
      {required double minSize}) {
    var draggingCrop = this.draggingCrop;
    if (isDraggingLeft)
      draggingCrop = draggingCrop.copyLTRB(
        left: draggingCrop.left + details.delta.dx,
      );
    if (isDraggingTop)
      draggingCrop = draggingCrop.copyLTRB(
        top: draggingCrop.top + details.delta.dy,
      );
    if (isDraggingRight)
      draggingCrop = draggingCrop.copyLTRB(
        right: draggingCrop.right + details.delta.dx,
      );
    if (isDraggingBottom)
      draggingCrop = draggingCrop.copyLTRB(
        bottom: draggingCrop.bottom + details.delta.dy,
      );
    if (isDraggingOffset) draggingCrop = draggingCrop.shift(details.delta);

    var effectiveCrop = imageRect.intersect(draggingCrop);
    if (isDraggingLeft)
      effectiveCrop = effectiveCrop.copyLTRB(
        left: min(effectiveCrop.left, effectiveCrop.right - minSize),
      );
    if (isDraggingTop)
      effectiveCrop = effectiveCrop.copyLTRB(
        top: min(effectiveCrop.top, effectiveCrop.bottom - minSize),
      );
    if (isDraggingRight)
      effectiveCrop = effectiveCrop.copyLTRB(
        right: max(effectiveCrop.right, effectiveCrop.left + minSize),
      );
    if (isDraggingBottom)
      effectiveCrop = effectiveCrop.copyLTRB(
        bottom: max(effectiveCrop.bottom, effectiveCrop.top + minSize),
      );

    return _copy(
      draggingCrop: draggingCrop,
      crop: effectiveCrop,
    );
  }

  CroppingState panEnd() => _copy(
        draggingCrop: crop,
        isDraggingLeft: false,
        isDraggingTop: false,
        isDraggingRight: false,
        isDraggingBottom: false,
        isDraggingOffset: false,
      );

  CroppingState _copy({
    Rect? crop,
    Rect? draggingCrop,
    Rect? imageRect,
    double? baseRotation,
    double? rotation,
    bool? isDraggingLeft,
    bool? isDraggingTop,
    bool? isDraggingRight,
    bool? isDraggingBottom,
    bool? isDraggingOffset,
  }) =>
      CroppingState._(
        crop ?? this.crop,
        draggingCrop ?? this.draggingCrop,
        imageRect ?? this.imageRect,
        baseRotation ?? this.baseRotation,
        rotation ?? this.rotation,
        isDraggingLeft ?? this.isDraggingLeft,
        isDraggingTop ?? this.isDraggingTop,
        isDraggingRight ?? this.isDraggingRight,
        isDraggingBottom ?? this.isDraggingBottom,
        isDraggingOffset ?? this.isDraggingOffset,
      );
}

extension RectCoping on Rect {
  Rect copyLTRB({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) =>
      Rect.fromLTRB(
        left ?? this.left,
        top ?? this.top,
        right ?? this.right,
        bottom ?? this.bottom,
      );
}
