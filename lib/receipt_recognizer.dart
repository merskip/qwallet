
import 'dart:io';
import 'dart:math';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:qwallet/utils.dart';

class ReceiptRecognizer {

  Future<double> recognizeTotalPrice(File image) async {
    final text = await _recognizeText(image);
    return _findHighestNumber(text);
  }

  Future<VisionText> _recognizeText(File image) async {
    final visionImage = FirebaseVisionImage.fromFile(image);
    final textRecognizer = FirebaseVision.instance.textRecognizer();
    return await textRecognizer.processImage(visionImage);
  }

  double _findHighestNumber(VisionText text) {
    final numbers = text.blocks
        .map((textBlock) => textBlock.lines)
        .expand((i) => i)
        .map((textLine) => textLine.elements)
        .expand((i) => i)
        .map((textElement) => findNumber(textElement))
        .where((amount) => amount != null)
        .toList();
    if (numbers.isNotEmpty)
      return numbers.reduce(max);
    else
      return null;
  }

  double findNumber(TextElement textElement) {
    final match = RegExp(r'\d+[\.,]\d{2}').firstMatch(textElement.text);
    if (match != null) {
      final numberText = textElement.text.substring(match.start, match.end);
      return parseAmount(numberText);
    }
    return null;
  }

}