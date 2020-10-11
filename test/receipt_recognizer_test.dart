import 'dart:convert';
import 'dart:io';

class CheckReceipt {
  final File photo;
  final ReceiptPattern pattern;

  CheckReceipt(this.photo, this.pattern);
}

class ReceiptPattern {
  final ReceiptPlace shop;
  final ReceiptPlace shopBranch;
  final String nip;
  final String purchaseDate;
  final double totalPrice;

  // TODO: products field

  ReceiptPattern({
    this.shop,
    this.shopBranch,
    this.nip,
    this.purchaseDate,
    this.totalPrice,
  });
}

class ReceiptPlace {
  final String name;
  final String address;

  ReceiptPlace({this.name, this.address});
}

List<CheckReceipt> getCheckReceipts() {
  final receiptsDirectory = Directory("test/receipts");
  final files = receiptsDirectory.listSync();
  final receipts = List<CheckReceipt>();
  for (final file in files) {
    if (file.path.endsWith(".jpg")) {
      final photoFile = file;
      final patternFile =
          File(file.path.substring(0, file.path.length - 3) + "json");
      if (patternFile.existsSync()) {
        final patternJson = jsonDecode(patternFile.readAsStringSync());

        receipts.add(CheckReceipt(
            photoFile,
            ReceiptPattern(
              shop: ReceiptPlace(
                name: patternJson["shop"]["name"],
                address: patternJson["shop"]["address"],
              ),
              shopBranch: patternJson["shop_branch"] != null
                  ? ReceiptPlace(
                      name: patternJson["shop_branch"]["name"],
                      address: patternJson["shop_branch"]["address"],
                    )
                  : null,
              nip: patternJson["nip"],
              purchaseDate: patternJson["purchase_date"],
              totalPrice: patternJson["total_price"],
            )));
      }
    }
  }

  return receipts;
}

// void main() {
//   test('Lorem ipsum', () async {
//     final receipts = getCheckReceipts();
//
//     for (final receipt in receipts) {
//       print("Checking ${receipt.photo}...");
//
//       final receiptRect = await ReceiptDetector().detect(receipt.photo);
//       print("Reeipt rect: $receiptRect");
//
//       final image =
//           copyResize(decodeImage(receipt.photo.readAsBytesSync()), width: 640);
//       final croppedImage = cropImage(image, receiptRect);
//       final adjuestedImage = adjustContrast(croppedImage);
//       final imageBytes = writeJpg(adjuestedImage);
//       final postFile = File(
//           receipt.photo.path.substring(0, receipt.photo.path.length - 4) +
//               "-post.jpg");
//       postFile.writeAsBytesSync(imageBytes);
// //      break;
//     }
//   });
// }
