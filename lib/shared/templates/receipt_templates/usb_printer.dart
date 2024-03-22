// import 'dart:typed_data';
// import 'package:drago_pos_printer/drago_pos_printer.dart';
// import 'package:flutter/material.dart';
// import 'package:printing/printing.dart';

// usbPrintReceipt(context, Uint8List bytes) async {
//   List<USBPrinter> printers = await USBPrinterManager.discover();
//   showDialog(
//     context: context,
//     builder: (context) {
//       return Dialog(
//         child: ListView(
//             children: printers
//                 .map((printer) => ListTile(
//                       title: Text("${printer.name}"),
//                       subtitle: Text("${printer.address}"),
//                       leading: const Icon(Icons.usb),
//                       onTap: () {
//                         _startPrinter(bytes, printer);
//                       },
//                       selected: printer.connected,
//                     ))
//                 .toList()),
//       );
//     },
//   );
// }

// _startPrinter(Uint8List pdfImg, USBPrinter printer) async {
//   USBPrinterManager? manager;
//   //connect
//   var profile = await CapabilityProfile.load();
//   manager = USBPrinterManager(
//       printer, PaperSizeWidth.mm80, PaperSizeMaxPerLine.mm80, profile);
//   await manager.connect();
//   printer.connected = true;

//   //printing
//   var data = await getPdfBytes(
//       pdfImg: pdfImg,
//       paperSizeWidthMM: manager.paperSizeWidthMM,
//       maxPerLine: manager.maxPerLine,
//       profile: manager.profile);

//   print("isConnected ${manager.isConnected}");
//   manager.writeBytes(data, isDisconnect: false);
// }

// Future<List<int>> getPdfBytes(
//     {int paperSizeWidthMM = PaperSizeMaxPerLine.mm80,
//     int maxPerLine = PaperSizeMaxPerLine.mm80,
//     CapabilityProfile? profile,
//     String name = "default",
//     required Uint8List pdfImg}) async {
//   List<int> bytes = [];
//   CapabilityProfile? profile0 =
//       profile ?? (await CapabilityProfile.load(name: name));
//   print(profile0.name);
//   int? paperSizeWidthMM0 = paperSizeWidthMM;
//   int? maxPerLine0 = maxPerLine;

//   Generator generator = Generator(paperSizeWidthMM0, maxPerLine0, profile0);

//   await for (var page in Printing.raster(pdfImg, dpi: 96)) {
//     final image = page.asImage();
//     bytes += generator.image(image);
//     bytes += generator.reset();
//     bytes += generator.cut();
//   }
//   return bytes;
// }
