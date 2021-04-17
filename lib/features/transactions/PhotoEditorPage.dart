import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

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
          ? buildImage(context, image!)
          : CircularProgressIndicator(),
    );
  }

  Widget buildImage(BuildContext context, ui.Image image) {
    return Column(
      children: [
        Flexible(
          child: FittedBox(
            child: SizedBox(
              width: image.width.toDouble(),
              height: image.height.toDouble(),
              child: GestureDetector(
                onPanStart: (details) => setState(() {
                  cropState = cropState.panStart(details);
                }),
                onPanUpdate: (details) => setState(() {
                  cropState = cropState.panUpdate(details);
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
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 24),
        SizedBox(
          height: 48,
          child: Slider(
            value: rotation,
            min: -pi / 2,
            max: pi / 2,
            label: "$rotation rad",
            onChanged: (value) => setState(() {
              this.rotation = value;
            }),
          ),
        ),
      ],
    );
  }
}

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

  _CropPainter({
    required this.cropState,
  });

  @override
  void paint(Canvas canvas, ui.Size size) {
    final crop = cropState.crop;

    final dimmingPaint = Paint()..color = Colors.black54;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, crop.top), dimmingPaint);
    canvas.drawRect(
        Rect.fromLTWH(0, crop.bottom, size.width, size.height - crop.bottom),
        dimmingPaint);
    canvas.drawRect(
        Rect.fromLTWH(0, crop.top, crop.left, crop.height), dimmingPaint);
    canvas.drawRect(
        Rect.fromLTWH(
            crop.right, crop.top, size.width - crop.right, crop.height),
        dimmingPaint);

    final rectCropPaint = Paint()
      ..strokeWidth = 4
      ..color = Colors.white
      ..style = PaintingStyle.stroke;
    canvas.drawRect(crop, rectCropPaint);

    final cropDotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(crop.topLeft, 12, cropDotPaint);
    canvas.drawCircle(crop.topRight, 12, cropDotPaint);
    canvas.drawCircle(crop.bottomRight, 12, cropDotPaint);
    canvas.drawCircle(crop.bottomLeft, 12, cropDotPaint);
  }

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

  final dragRadius = 36.0;

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

  CropState panStart(DragStartDetails details) {
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

  CropState panUpdate(DragUpdateDetails details) {
    var crop = this.draggingCrop;
    if (isDraggingLeft)
      crop = Rect.fromLTRB(
          crop.left + details.delta.dx, crop.top, crop.right, crop.bottom);
    if (isDraggingTop)
      crop = Rect.fromLTRB(
          crop.left, crop.top + details.delta.dy, crop.right, crop.bottom);
    if (isDraggingRight)
      crop = Rect.fromLTRB(
          crop.left, crop.top, crop.right + details.delta.dx, crop.bottom);
    if (isDraggingBottom)
      crop = Rect.fromLTRB(
          crop.left, crop.top, crop.right, crop.bottom + details.delta.dy);
    if (isDraggingOffset) crop = crop.shift(details.delta);

    return _copy(
      draggingCrop: crop,
      crop: imageRect.intersect(crop),
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
