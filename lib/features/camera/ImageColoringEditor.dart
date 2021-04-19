import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'ImageCroppingEditor.dart';

class ImageColoringPreview extends StatelessWidget {
  final ui.Image image;
  final ValueNotifier<ColoringState> state;
  final CroppingState croppingState;

  const ImageColoringPreview({
    Key? key,
    required this.image,
    required this.state,
    required this.croppingState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ImageColoringPainter(
        image: image,
        croppingState: croppingState,
      ),
    );
  }
}

class _ImageColoringPainter extends CustomPainter {
  final ui.Image image;
  final CroppingState croppingState;

  _ImageColoringPainter({
    required this.image,
    required this.croppingState,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );

    canvas.save();
    canvas.clipRect(croppingState.crop);
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(croppingState.effectiveRotation);
    canvas.translate(-size.width / 2, -size.height / 2);

    canvas.drawImage(image, Offset.zero, Paint());
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ImageColoringPainter oldDelegate) {
    return true;
  }
}

class ColoringState {
  final double brightness;
  final double contrast;

  ColoringState({
    this.brightness = 0.0,
    this.contrast = 1.0,
  });
}
