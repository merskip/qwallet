import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../utils/IterableFinding.dart';

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
    return ValueListenableBuilder<ColoringState>(
      valueListenable: state,
      builder: (context, state, child) {
        return CustomPaint(
          painter: _ImageColoringPainter(
            image: image,
            state: state,
          ),
        );
      },
    );
  }
}

class ImageColoringToolbar extends StatelessWidget {
  final ValueNotifier<ColoringState> state;

  const ImageColoringToolbar({
    Key? key,
    required this.state,
  }) : super(key: key);

  void onSelectedReset(BuildContext context) {
    state.value = state.value.reset();
  }

  void onChangedBrightness(BuildContext context, double value) {
    state.value = state.value.setBrightness(value);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ColoringState>(
      valueListenable: state,
      builder: (context, croppingState, child) {
        return Row(children: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.undo, size: 16),
            color: Colors.white,
            onPressed: () => onSelectedReset(context),
            tooltip: "#Reset coloring",
          ),
          Flexible(
            child: Slider(
              value: croppingState.brightness,
              min: -0.5,
              max: 0.5,
              onChanged: (value) => onChangedBrightness(context, value),
            ),
          ),
        ]);
      },
    );
  }
}

class _ImageColoringPainter extends CustomPainter {
  final ui.Image image;
  final ColoringState state;

  _ImageColoringPainter({
    required this.image,
    required this.state,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    final b = state.brightness * 255;

    final List<List<double>> matrix = [
      /* R */ [1, 0, 0, 0, b],
      /* G */ [0, 1, 0, 0, b],
      /* B */ [0, 0, 1, 0, b],
      /* A */ [0, 0, 0, 1, 0],
    ];

    final imagePaint = Paint()
      ..colorFilter = ColorFilter.matrix(matrix.flatten().toList());
    canvas.drawImage(image, Offset.zero, imagePaint);
  }

  @override
  bool shouldRepaint(covariant _ImageColoringPainter oldDelegate) {
    return true;
  }
}

class ColoringState {
  final double brightness;

  ColoringState({
    this.brightness = 0.0,
  });

  ColoringState reset() => ColoringState();

  ColoringState setBrightness(double brightness) => _copy(
        brightness: brightness,
      );

  ColoringState _copy({
    double? brightness,
  }) =>
      ColoringState(
        brightness: brightness ?? this.brightness,
      );
}
