import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qwallet/image_utils.dart';
import 'package:qwallet/utils.dart';

class RecognizedValue<T> {
  final T value;
  final TextContainer textContainer;

  RecognizedValue(this.value, this.textContainer);
}

class ReceiptRecognizingResult {
  final File receiptImage;
  final VisionText visionText;
  final Rect detectedRect;
  final RecognizedValue<double> totalPrice;
  final RecognizedValue<String> nip;
  final RecognizedValue<DateTime> purchaseDate;

  ReceiptRecognizingResult({
    this.receiptImage,
    this.visionText,
    this.detectedRect,
    this.totalPrice,
    this.nip,
    this.purchaseDate,
  });
}

class ReceiptRecognizer {
  Future<ReceiptRecognizingResult> process(File image) {
    return Future.microtask(() async {
      print("Detecting receipt rect...");
      final rawText = await _recognizeText(image);
      final receiptRect = await _detectReceiptRect(rawText);

      print("Cropping image...");
      final sourceImage = decodeImage(image.readAsBytesSync());
      var resultImage = cropImage(sourceImage, receiptRect);

      print("Adjusting contrast...");
      resultImage = adjustContrast(resultImage);

      final tempDir = await getTemporaryDirectory();
      final receiptImage =
          File("${tempDir.path}/receipt-${Random().nextInt(1 << 32)}.jpg");
      await receiptImage.writeAsBytes(encodeJpg(resultImage));

      print("Again detecting text...");
      final text = await _recognizeText(receiptImage);

      print("Recognizing receipt...");
      return ReceiptRecognizingResult(
        receiptImage: receiptImage,
        visionText: text,
        detectedRect: receiptRect,
        totalPrice: _getTotalPrice(text),
        nip: _findNIP(text),
        purchaseDate: _findDate(text),
      );
    });
  }

  Future<VisionText> _recognizeText(File image) async {
    final visionImage = FirebaseVisionImage.fromFile(image);
    final textRecognizer = FirebaseVision.instance.textRecognizer();
    return await textRecognizer.processImage(visionImage);
  }

  Future<Rect> _detectReceiptRect(VisionText text) async {
    final boundingBoxes = text.blocks.map((textBlock) => textBlock.boundingBox);
    final top = boundingBoxes.map((it) => it.top).reduce(min);
    final right = boundingBoxes.map((it) => it.right).reduce(max);
    final bottom = boundingBoxes.map((it) => it.bottom).reduce(max);
    final left = boundingBoxes.map((it) => it.left).reduce(min);
    return Rect.fromLTRB(left, top, right, bottom);
  }

  RecognizedValue<double> _getTotalPrice(VisionText text) {
    final numbers = _findNumbers(text);
    numbers.sort((lhs, rhs) => rhs.textContainer.boundingBox.height
        .compareTo(lhs.textContainer.boundingBox.height));
    return numbers.first;
  }

  RecognizedValue<String> _findNIP(VisionText text) {
    for (final textBlock in text.blocks) {
      for (final textLine in textBlock.lines) {
        for (final textElement in textLine.elements) {
          final match =
              RegExp(r"(?:NIP)?.*?((?:\d.?){9})").firstMatch(textElement.text);
          if (match != null) {
            final nipText = match.group(1);
            final purgedNip = nipText.replaceAll(RegExp(r"[^\d]"), "");
            if (purgedNip.length == 10)
              return RecognizedValue(purgedNip, textElement);
          }
        }
      }
    }
    return null;
  }

  RecognizedValue<DateTime> _findDate(VisionText text) {
    for (final textBlock in text.blocks) {
      for (final textLine in textBlock.lines) {
        for (final textElement in textLine.elements) {
          final match =
              RegExp(r"(\d{4}-\d{2}-\d{2})").firstMatch(textElement.text);
          if (match != null) {
            final dateText = match.group(1);
            final date = DateTime.parse(dateText);
            return RecognizedValue(date, textElement);
          }
        }
      }
    }
    return null;
  }

  List<RecognizedValue<double>> _findNumbers(VisionText text) {
    return text.blocks
        .map((textBlock) => textBlock.lines)
        .expand((i) => i)
        .map((textLine) => textLine.elements)
        .expand((i) => i)
        .map((textElement) => findNumber(textElement))
        .where((amount) => amount != null)
        .toList();
  }

  RecognizedValue<double> findNumber(TextElement textElement) {
    final match =
        RegExp(r'\d+[\.,]\d{2}([^\d]|$)').firstMatch(textElement.text);
    if (match != null) {
      final numberText = textElement.text.substring(match.start, match.end);
      final amountValue = parseAmount(numberText);
      return RecognizedValue(amountValue, textElement);
    }
    return null;
  }
}
