import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'package:path_provider/path_provider.dart';

import '../ReceiptDetector.dart';

Future<ReceiptDetectorResult> _detect(CameraImage image) async {
  print("=== Detecting receipt live...");
  print("[1/9] Converting image...");
  final img = await convertYUV420toImageColor(image);
  print("[2/9] Detect receipt...");
  final receiptRect = await ReceiptDetector().detect(img);
  print("--- Result: ${receiptRect.rect}");
  return receiptRect;
}

Future<imglib.Image> convertYUV420toImageColor(CameraImage image) async {
  try {
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel;

    // imgLib -> Image package from https://pub.dartlang.org/packages/image
    var img = imglib.Image(width, height); // Create Image buffer

    // Fill image buffer with plane[0] from YUV420_888
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex =
            uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
        final int index = y * width + x;

        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        // Calculate pixel color
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        img.data[index] = (0xFF << 24) | (b << 16) | (g << 8) | r;
      }
    }

    return img;
  } catch (e) {
    print(">>>>>>>>>>>> ERROR:" + e.toString());
  }
  return null;
}

class ScanReceiptPage extends StatefulWidget {
  @override
  _ScanReceiptPageState createState() => _ScanReceiptPageState();
}

class _ScanReceiptPageState extends State<ScanReceiptPage> {
  CameraController controller;

  ReceiptDetectorResult detectedReceipt;
  File edgeFile;
  bool isProcessing = false;

  @override
  void initState() {
    _initCamera();
    getTemporaryDirectory().then((tmp) {
      edgeFile = File("${tmp.path}/edge.jpg");
    });
    super.initState();
  }

  _initCamera() async {
    final cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.high);
    await controller.initialize();
    setState(() {});

    controller.startImageStream((image) {
      if (!isProcessing) {
        isProcessing = true;
        compute(_detect, image).then((rect) async {
          setState(() {
            detectedReceipt = rect;
          });

          final lines = [
            rect.leftLine,
            rect.topLine,
            rect.rightLine,
            rect.bottomLine
          ].where((line) => line != null);
          if (lines.length >= 2) {
//            _takePhoto();
          }

          isProcessing = false;
        });
      }
    });
  }

  _takePhoto() async {
    controller.stopImageStream();

    final documents = await getApplicationDocumentsDirectory();
    final photoFile = File(
        "${documents.path}/receipt_photo-${Random().nextInt(1 << 32)}.jpg");
    if (await photoFile.exists()) await photoFile.delete();
    await controller.takePicture(photoFile.path);
    // TODO: open ReceiptRecognizingPage
  }

  @override
  void dispose() {
    controller.stopImageStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: controller != null && controller.value.isInitialized
          ? _cameraPreview()
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _cameraPreview() {
    return Center(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: Stack(children: [
          CameraPreview(controller),
          if (detectedReceipt != null)
            FittedBox(
              child: SizedBox(
                width: detectedReceipt?.edgeImage?.width?.toDouble() ?? 0.0,
                height: detectedReceipt?.edgeImage?.height?.toDouble() ?? 0.0,
                child: CustomPaint(
                  foregroundPainter: DetectedReceiptPainter(detectedReceipt),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

class DetectedReceiptPainter extends CustomPainter {
  final ReceiptDetectorResult detectedReceipt;

  DetectedReceiptPainter(this.detectedReceipt);

  @override
  void paint(Canvas canvas, Size size) {
    if (detectedReceipt != null) {
      final receiptPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.orange
        ..strokeWidth = 1;
      canvas.drawRect(detectedReceipt.rect, receiptPaint);

      final edgePaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.blue
        ..strokeWidth = 1;

      _drawEdgeLine(canvas, detectedReceipt.leftLine, edgePaint);
      _drawEdgeLine(canvas, detectedReceipt.topLine, edgePaint);
      _drawEdgeLine(canvas, detectedReceipt.rightLine, edgePaint);
      _drawEdgeLine(canvas, detectedReceipt.bottomLine, edgePaint);
    }
  }

  _drawEdgeLine(Canvas canvas, LineSegment line, Paint paint) {
    if (line != null) canvas.drawLine(line.startOffset, line.endOffset, paint);
  }

  @override
  bool shouldRepaint(DetectedReceiptPainter oldDelegate) =>
      detectedReceipt != oldDelegate.detectedReceipt;
}
