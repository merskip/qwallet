import 'dart:ui';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../receipt_recognizer.dart';

class RecognizedReceiptPainter extends CustomPainter {
  final ReceiptRecognizingResult recognizingResult;
  final RecognizedValue<double> selectedTotalPrice;

  RecognizedReceiptPainter(this.recognizingResult, this.selectedTotalPrice);

  @override
  void paint(Canvas canvas, Size size) {
    _paintVisionText(canvas, recognizingResult.visionText);

    final candidatePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.orange.withAlpha(128)
      ..strokeWidth = 4;
    for (final candidate in recognizingResult.totalPriceCandidates) {
      canvas.drawRect(candidate.textContainer.boundingBox, candidatePaint);
    }

    if (selectedTotalPrice != null) {
      final selectedTotalPricePaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.orange
        ..strokeWidth = 6;
      canvas.drawRect(selectedTotalPrice.textContainer.boundingBox,
          selectedTotalPricePaint);
    }

    if (recognizingResult.taxpayerIdentificationNumber != null) {
      final nipPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.orange
        ..strokeWidth = 6;
      canvas.drawRect(
          recognizingResult
              .taxpayerIdentificationNumber.textContainer.boundingBox,
          nipPaint);
    }

    if (recognizingResult.purchaseDate != null) {
      final datePaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.orange
        ..strokeWidth = 6;
      canvas.drawRect(
          recognizingResult.purchaseDate.textContainer.boundingBox, datePaint);
    }
  }

  _paintVisionText(Canvas canvas, VisionText text) {

    final textLinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.blueGrey
      ..strokeWidth = 2;

    final textElementPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blue.withAlpha(16);

    for (final textBlock in text.blocks) {
      for (final textLine in textBlock.lines) {

        final points = List<Offset>()
          ..addAll(textLine.cornerPoints)
          ..add(textLine.cornerPoints[0]);
        canvas.drawPoints(
            PointMode.polygon, points, textLinePaint);

        for (final textElement in textLine.elements) {
        canvas.drawRect(textElement.boundingBox, textElementPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(RecognizedReceiptPainter oldDelegate) =>
      recognizingResult != oldDelegate.recognizingResult ||
      selectedTotalPrice != oldDelegate.selectedTotalPrice;
}
