import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:qwallet/utils.dart';

class ReceiptRecognizingResult {
  final List<double> totalPriceCandidates;
  final String taxpayerIdentificationNumber;

  ReceiptRecognizingResult(
      {this.totalPriceCandidates, this.taxpayerIdentificationNumber});
}

class ReceiptRecognizer {
  Future<ReceiptRecognizingResult> process(File image) async {
    final text = await _recognizeText(image);
    final numbers = _findNumbers(text);

    return ReceiptRecognizingResult(
        totalPriceCandidates: _getTotalPriceCandidates(numbers),
        taxpayerIdentificationNumber: _findNIP(text),
    );
  }

  Future<VisionText> _recognizeText(File image) async {
    final visionImage = FirebaseVisionImage.fromFile(image);
    final textRecognizer = FirebaseVision.instance.textRecognizer();
    return await textRecognizer.processImage(visionImage);
  }

  List<double> _getTotalPriceCandidates(List<double> numbers) {
    // TODO: Doesn't work correct when real total price is lower than tax
    // eg. Total price 10,00 zł, tax A - 23,00 %
    //     returns 23,00 zł, should [10,00, 23,00] or only 10,00
    return numbers.toSet().toList()..sort((a, b) => b.compareTo(a));
  }

  String _findNIP(VisionText text) {
    for (final textBlock in text.blocks) {
      final match = RegExp(r"NIP.*?((?:\d.?){9})").firstMatch(textBlock.text);
      if (match != null) {
        final nipText = match.group(1);
        return nipText.replaceAll(RegExp(r"[^\d]"), "");
      }
    }
    return null;
  }

  List<double> _findNumbers(VisionText text) {
    return text.blocks
        .map((textBlock) => textBlock.lines)
        .expand((i) => i)
        .map((textLine) => textLine.elements)
        .expand((i) => i)
        .map((textElement) => findNumber(textElement))
        .where((amount) => amount != null)
        .toList();
  }

  double findNumber(TextElement textElement) {
    final match =
        RegExp(r'\d+[\.,]\d{2}([^\d]|$)').firstMatch(textElement.text);
    if (match != null) {
      final numberText = textElement.text.substring(match.start, match.end);
      return parseAmount(numberText);
    }
    return null;
  }
}
