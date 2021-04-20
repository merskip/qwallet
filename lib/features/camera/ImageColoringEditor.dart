import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qwallet/features/camera/MutableImage.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

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
        return SimpleStreamWidget(
            stream: MutableImage.fromImage(image)
                .then((image) => image.copy())
                .then((image) {
              image.brightness(state.brightness);
              return image.toImage();
            }).asStream(),
            builder: (context, ui.Image image) {
              return CustomPaint(
                painter: _ImageColoringPainter(
                  image: image,
                ),
              );
            });
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
              min: -1.0,
              max: 1.0,
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
