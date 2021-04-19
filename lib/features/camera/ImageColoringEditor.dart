import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ImageColoringPreview extends StatelessWidget {
  final ui.Image image;
  final ValueNotifier<ColoringState> state;

  const ImageColoringPreview({
    Key? key,
    required this.image,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ImageColoringPainter(
        image: image,
      ),
    );
  }
}

class _ImageColoringPainter extends CustomPainter {
  final ui.Image image;

  _ImageColoringPainter({
    required this.image,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset.zero, Paint());
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
