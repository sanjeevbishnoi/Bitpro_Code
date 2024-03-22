import 'dart:convert';
import 'dart:typed_data';

String getQrCodeContent(
    {required String sellerName,
    required String sellerTRN,
    required String vatPrice,
    required String totalWithVat}) {
  var dateTime = DateTime.now();
  final invoiceDate = dateTime.toString();
  // "${dateTime.year}-${dateTime.month}-${dateTime.day}T${dateTime.hour}:${dateTime.minute}";
  final bytesBuilder = BytesBuilder();
  // 1. Seller Name
  bytesBuilder.addByte(1);
  final sellerNameBytes = utf8.encode(sellerName);
  bytesBuilder.addByte(sellerNameBytes.length);
  bytesBuilder.add(sellerNameBytes);
  // 2. VAT Registration
  bytesBuilder.addByte(2);
  final vatRegistrationBytes = utf8.encode(sellerTRN);
  bytesBuilder.addByte(vatRegistrationBytes.length);
  bytesBuilder.add(vatRegistrationBytes);
  // 3. Time
  bytesBuilder.addByte(3);
  final time = utf8.encode(invoiceDate);
  bytesBuilder.addByte(time.length);
  bytesBuilder.add(time);
  // 4. total with vat
  bytesBuilder.addByte(4);
  final p1 = utf8.encode(totalWithVat);
  bytesBuilder.addByte(p1.length);
  bytesBuilder.add(p1);
  // 5.  vat
  bytesBuilder.addByte(5);
  final p2 = utf8.encode(vatPrice);
  bytesBuilder.addByte(p2.length);
  bytesBuilder.add(p2);

  final qrCodeAsBytes = bytesBuilder.toBytes();
  const b64Encoder = Base64Encoder();
  return b64Encoder.convert(qrCodeAsBytes);
}
