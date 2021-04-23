import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'MutableImage.dart';

class ImageColoringPreview extends StatefulWidget {
  final ui.Image originalImage;
  final ValueNotifier<ColoringState> state;

  const ImageColoringPreview({
    Key? key,
    required this.originalImage,
    required this.state,
  }) : super(key: key);

  @override
  _ImageColoringPreviewState createState() => _ImageColoringPreviewState();
}

class _ImageColoringPreviewState extends State<ImageColoringPreview> {
  late ui.Image image;

  var _isProcessing = false;

  @override
  void initState() {
    image = widget.originalImage;
    widget.state.addListener(_onChangedState);
    super.initState();
  }

  @override
  void dispose() {
    widget.state.removeListener(_onChangedState);
    super.dispose();
  }

  void _onChangedState() {
    if (_isProcessing) return;
    _isProcessing = true;

    Future(() async {
      final mutableImage = await MutableImage.fromImage(widget.originalImage);
      mutableImage.brightness((widget.state.value.brightness * 255).round());
      mutableImage.contrast((widget.state.value.contrast * 255).round());

      final image = await mutableImage.toImage();
      setState(() {
        this.image = image;
      });
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ImageColoringPainter(
        image: image,
      ),
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

  void onChangedContrast(BuildContext context, double value) {
    state.value = state.value.setContrast(value);
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
            child: Column(
              children: [
                Slider(
                  value: croppingState.brightness,
                  min: -1.0,
                  max: 1.0,
                  onChanged: (value) => onChangedBrightness(context, value),
                ),
                Slider(
                  value: croppingState.contrast,
                  min: -1.0,
                  max: 1.0,
                  onChanged: (value) => onChangedContrast(context, value),
                ),
              ],
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
  final double contrast;

  ColoringState({
    this.brightness = 0.0,
    this.contrast = 0.0,
  });

  ColoringState reset() => ColoringState();

  ColoringState setBrightness(double brightness) => _copy(
        brightness: brightness,
      );

  ColoringState setContrast(double contrast) => _copy(
        contrast: contrast,
      );

  ColoringState _copy({
    double? brightness,
    double? contrast,
  }) =>
      ColoringState(
        brightness: brightness ?? this.brightness,
        contrast: contrast ?? this.contrast,
      );
}
