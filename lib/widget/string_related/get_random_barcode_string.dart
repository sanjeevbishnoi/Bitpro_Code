import 'dart:math';

String randomBarcodeGenerate() {
  String barcode = '1';
  for (int i = 0; i < 6; i++) {
    var n = Random().nextInt(9);
    barcode += n.toString();
  }
  return barcode;
}
