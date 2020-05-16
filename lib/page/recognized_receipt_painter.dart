import 'dart:ui';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../receipt_recognizer.dart';

class RecognizedReceiptPainter extends CustomPainter {
  final ReceiptRecognizingResult recognizingResult;

  RecognizedReceiptPainter(this.recognizingResult);

  @override
  void paint(Canvas canvas, Size size) {
    _paintVisionText(canvas, recognizingResult.visionText);

    if (recognizingResult.totalPrice != null) {
      final tTotalPricePaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.orange
        ..strokeWidth = 3;
      canvas.drawRect(recognizingResult.totalPrice.textContainer.boundingBox.inflate(3),
          tTotalPricePaint);
    }

    if (recognizingResult.nip != null) {
      final nipPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.orange
        ..strokeWidth = 3;
      canvas.drawRect(
          recognizingResult
              .nip.textContainer.boundingBox.inflate(3),
          nipPaint);
    }

    if (recognizingResult.purchaseDate != null) {
      final datePaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.orange
        ..strokeWidth = 3;
      canvas.drawRect(
          recognizingResult.purchaseDate.textContainer.boundingBox.inflate(3), datePaint);
    }
  }

  _paintVisionText(Canvas canvas, VisionText text) {
    final textLinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.blueGrey
      ..strokeWidth = 2;

    final textElementPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blue.withAlpha(32);

    for (final textBlock in text.blocks) {
      for (final textLine in textBlock.lines) {
        final points = List<Offset>()
          ..addAll(textLine.cornerPoints)
          ..add(textLine.cornerPoints[0]);
        canvas.drawPoints(PointMode.polygon, points, textLinePaint);

        for (final textElement in textLine.elements) {
          canvas.drawRect(textElement.boundingBox, textElementPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(RecognizedReceiptPainter oldDelegate) =>
      recognizingResult != oldDelegate.recognizingResult;
}
