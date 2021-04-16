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
  Rect imageRect = Rect.zero;
  double rotation = 0;
  Rect crop = Rect.zero;
  Rect draggingCrop = Rect.zero;

  var isDraggingLeft = false;
  var isDraggingTop = false;
  var isDraggingRight = false;
  var isDraggingBottom = false;
  var isDraggingOffset = false;

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
        imageRect = Rect.fromLTWH(
          0.0,
          0.0,
          image.width.toDouble(),
          image.height.toDouble(),
        );
        this.crop = imageRect;
        this.draggingCrop = imageRect;
      });
    });
  }

  void onPanStart(DragStartDetails details) {
    if ((details.localPosition.dx - crop.left).abs() < 36) {
      isDraggingLeft = true;
    }
    if ((details.localPosition.dy - crop.top).abs() < 36) {
      isDraggingTop = true;
    }
    if ((details.localPosition.dx - crop.right).abs() < 36) {
      isDraggingRight = true;
    }
    if ((details.localPosition.dy - crop.bottom).abs() < 36) {
      isDraggingBottom = true;
    }
    if (crop.contains(details.localPosition) &&
        !isDraggingLeft &&
        !isDraggingTop &&
        !isDraggingRight &&
        !isDraggingBottom) {
      isDraggingOffset = true;
    }
    print("Start pan with "
        "isDraggingLeft=$isDraggingLeft, "
        "isDraggingTop=$isDraggingTop, "
        "isDraggingRight=$isDraggingRight, "
        "isDraggingBottom=$isDraggingBottom, "
        "isDraggingOffset=$isDraggingOffset");
  }

  void onPanUpdate(DragUpdateDetails details) {
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

    if (crop != this.draggingCrop) {
      setState(() {
        this.draggingCrop = crop;
        this.crop = imageRect.intersect(crop);
      });
    }
  }

  void onPanEnd(DragEndDetails details) {
    isDraggingLeft = false;
    isDraggingTop = false;
    isDraggingRight = false;
    isDraggingBottom = false;
    isDraggingOffset = false;
    setState(() {
      this.draggingCrop = crop;
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
                onPanStart: onPanStart,
                onPanUpdate: onPanUpdate,
                onPanEnd: onPanEnd,
                child: CustomPaint(
                  painter: _ImagePainter(
                    image: image,
                    rotate: rotation,
                  ),
                  foregroundPainter: _CropPainter(
                    crop: crop,
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
  final Rect crop;

  _CropPainter({
    required this.crop,
  });

  @override
  void paint(Canvas canvas, ui.Size size) {
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
    return crop != oldDelegate.crop;
  }
}
