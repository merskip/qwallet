import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PhotoEditorPage extends StatefulWidget {
  final File imageFile;

  const PhotoEditorPage({
    Key? key,
    required this.imageFile,
  }) : super(key: key);

  @override
  _PhotoEditorPageState createState() => _PhotoEditorPageState();
}

class _PhotoEditorPageState extends State<PhotoEditorPage> {
  ui.Image? image;

  var selectedTab = _Tab.cropping;

  late CroppingState croppingState;

  @override
  void initState() {
    _loadImage();
    super.initState();
  }

  void _loadImage() async {
    final bytes = await widget.imageFile.readAsBytes();
    ui.decodeImageFromList(bytes, (image) {
      setState(() {
        this.image = image;
        final imageRect = Rect.fromLTWH(
          0.0,
          0.0,
          image.width.toDouble(),
          image.height.toDouble(),
        );
        croppingState = CroppingState(imageRect);
      });
    });
  }

  void onSelectedCroppingReset(BuildContext context) {
    setState(() {
      croppingState = croppingState.reset();
    });
  }

  void onSelectedRotateLeft(BuildContext context) {
    setState(() {
      croppingState = croppingState.rotateLeft();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: image != null
          ? buildBodyWithImage(context, image!)
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget buildBodyWithImage(BuildContext context, ui.Image image) {
    return Column(
      children: [
        Flexible(
          child: buildImage(context, image),
        ),
        buildToolbar(context),
      ],
    );
  }

  Widget buildImage(BuildContext context, ui.Image image) {
    switch (selectedTab) {
      case _Tab.cropping:
        return buildImageCropping(context, image);
      case _Tab.coloring:
        return buildImageColoring(context, image);
    }
  }

  Widget buildImageCropping(BuildContext context, ui.Image image) {
    return FittedBox(
      child: SizedBox(
        width: image.width.toDouble(),
        height: image.height.toDouble(),
        child: GestureDetector(
          onPanStart: (details) => setState(() {
            croppingState = croppingState.panStart(details, dragRadius: 36);
          }),
          onPanUpdate: (details) => setState(() {
            croppingState = croppingState.panUpdate(details, minSize: 96);
          }),
          onPanEnd: (details) => setState(() {
            croppingState = croppingState.panEnd();
          }),
          child: CustomPaint(
            painter: _ImageCroppingPainter(
              image: image,
              rotate: croppingState.effectiveRotation,
            ),
            foregroundPainter: _CropPainter(
              cropState: croppingState,
              dotRadius: 12,
              normalColor: Colors.white,
              selectedColor: Theme.of(context).accentColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildImageColoring(BuildContext context, ui.Image image) {
    return FittedBox(
      child: SizedBox(
        width: image.width.toDouble(),
        height: image.height.toDouble(),
        child: CustomPaint(
          painter: _ImageColoringPainter(
            image: image,
            croppingState: croppingState,
          ),
        ),
      ),
    );
  }

  Widget buildToolbar(BuildContext context) {
    return Column(
      children: [
        if (selectedTab == _Tab.cropping) buildCroppingTab(context),
        Container(
          height: 64,
          color: Colors.white10,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 16),
              buildToolbarIconButton(
                context,
                Icon(Icons.crop_rotate),
                _Tab.cropping,
              ),
              SizedBox(width: 16),
              buildToolbarIconButton(
                context,
                Icon(Icons.palette_outlined),
                _Tab.coloring,
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.done),
                color: Colors.white,
                onPressed: () {},
              ),
              SizedBox(width: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildToolbarIconButton(
    BuildContext context,
    Widget icon,
    _Tab tab,
  ) {
    final isSelected = tab == selectedTab;
    return IconButton(
      icon: icon,
      iconSize: 28,
      color: isSelected
          ? Theme.of(context).primaryColor
          : Theme.of(context).buttonColor,
      onPressed: () => setState(() {
        selectedTab = tab;
      }),
    );
  }

  Widget buildCroppingTab(BuildContext context) {
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
          onChanged: (value) => setState(() {
            croppingState = croppingState.setRotation(value);
          }),
        ),
      ),
      IconButton(
        icon: Icon(Icons.rotate_left),
        color: Colors.white,
        onPressed: () => onSelectedRotateLeft(context),
        tooltip: "#Rotate left",
      ),
    ]);
  }
}

enum _Tab {
  cropping,
  coloring,
}

class _ImageCroppingPainter extends CustomPainter {
  final ui.Image image;
  final double rotate;

  _ImageCroppingPainter({
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
  bool shouldRepaint(covariant _ImageCroppingPainter oldDelegate) {
    return image != oldDelegate.image || rotate != oldDelegate.rotate;
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
  bool shouldRepaint(covariant _ImageCroppingPainter oldDelegate) {
    return true;
  }
}

class _CropPainter extends CustomPainter {
  final CroppingState cropState;
  final double dotRadius;
  final Color normalColor;
  final Color selectedColor;

  _CropPainter({
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
  bool shouldRepaint(covariant _CropPainter oldDelegate) {
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
