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

  double rotation = 0;
  late CropState cropState;

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
        cropState = CropState(imageRect);
      });
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
          child: buildImagePreview(context, image),
        ),
        buildToolbar(context),
      ],
    );
  }

  Widget buildImagePreview(BuildContext context, ui.Image image) {
    return FittedBox(
      child: SizedBox(
        width: image.width.toDouble(),
        height: image.height.toDouble(),
        child: GestureDetector(
          onPanStart: (details) => setState(() {
            cropState = cropState.panStart(details, dragRadius: 36);
          }),
          onPanUpdate: (details) => setState(() {
            cropState = cropState.panUpdate(details, minSize: 96);
          }),
          onPanEnd: (details) => setState(() {
            cropState = cropState.panEnd();
          }),
          child: CustomPaint(
            painter: _ImagePainter(
              image: image,
              rotate: rotation,
            ),
            foregroundPainter: _CropPainter(
              cropState: cropState,
              dotRadius: 12,
              normalColor: Colors.white,
              selectedColor: Theme.of(context).accentColor,
            ),
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
        onPressed: () {},
      ),
      Flexible(
        child: Slider(
          value: rotation,
          min: -pi / 2,
          max: pi / 2,
          onChanged: (value) => setState(() {
            this.rotation = value;
          }),
        ),
      ),
      IconButton(
        icon: Icon(Icons.rotate_left),
        color: Colors.white,
        onPressed: () {},
      ),
    ]);
  }
}

enum _Tab { cropping, coloring }

class _ImagePainter extends CustomPainter {
  final ui.Image image;
  final double rotate;

  _ImagePainter({
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
  bool shouldRepaint(covariant _ImagePainter oldDelegate) {
    return image != oldDelegate.image || rotate != oldDelegate.rotate;
  }
}

class _CropPainter extends CustomPainter {
  final CropState cropState;
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

class CropState {
  final Rect crop;
  final Rect draggingCrop;
  final Rect imageRect;

  final bool isDraggingLeft;
  final bool isDraggingTop;
  final bool isDraggingRight;
  final bool isDraggingBottom;
  final bool isDraggingOffset;

  bool get isDraggingTopLeft => isDraggingTop && isDraggingLeft;

  bool get isDraggingTopRight => isDraggingTop && isDraggingRight;

  bool get isDraggingBottomRight => isDraggingBottom && isDraggingRight;

  bool get isDraggingBottomLeft => isDraggingBottom && isDraggingLeft;

  CropState(Rect imageRect)
      : crop = imageRect,
        draggingCrop = imageRect,
        imageRect = imageRect,
        isDraggingLeft = false,
        isDraggingTop = false,
        isDraggingRight = false,
        isDraggingBottom = false,
        isDraggingOffset = false;

  CropState._(
    this.crop,
    this.draggingCrop,
    this.imageRect,
    this.isDraggingLeft,
    this.isDraggingTop,
    this.isDraggingRight,
    this.isDraggingBottom,
    this.isDraggingOffset,
  );

  CropState panStart(DragStartDetails details, {required double dragRadius}) {
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

  CropState panUpdate(DragUpdateDetails details, {required double minSize}) {
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

  CropState panEnd() => _copy(
        draggingCrop: crop,
        isDraggingLeft: false,
        isDraggingTop: false,
        isDraggingRight: false,
        isDraggingBottom: false,
        isDraggingOffset: false,
      );

  CropState _copy({
    Rect? crop,
    Rect? draggingCrop,
    Rect? imageRect,
    bool? isDraggingLeft,
    bool? isDraggingTop,
    bool? isDraggingRight,
    bool? isDraggingBottom,
    bool? isDraggingOffset,
  }) =>
      CropState._(
        crop ?? this.crop,
        draggingCrop ?? this.draggingCrop,
        imageRect ?? this.imageRect,
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
