// import 'dart:typed_data';
// import 'package:esc_pos_printer/esc_pos_printer.dart';

// import 'package:esc_pos_utils/esc_pos_utils.dart';
// import 'package:bitpro_hive/shared/toast.dart';
// // import 'package:printing/printing.dart';

// // import '../toast.dart';

// // Future<void> printTicket(Uint8List uint8list, Printer p, context) async {
// // final printer = PrinterNetworkManager('192.168.0.123');
// //   final res = await printer.connect();

// //   if (res != PosPrintResult.success) {
// //     showToast('Unable to connect to the printer', context);
// //   }

// //   final profile = await CapabilityProfile.load();
// //   final generator = Generator(PaperSize.mm80, profile);
// //   var ticket = <int>[];

// //   await for (var page in Printing.raster(uint8list)) {
// //     final image = page.asImage();
// //     ticket += generator.image(image);
// //     ticket += generator.feed(2);
// //     ticket += generator.cut();
// //   }

// //   printer.printTicket(ticket);
// //   printer.disconnect();
// // }

// Future<void> printTicket2(Uint8List uint8list, p, context) async {
//   PaperSize paper = PaperSize.mm80;
//   final profile = await CapabilityProfile.load();
//   final printer = NetworkPrinter(paper, profile);

//   final PosPrintResult res = await printer.connect('192.168.0.123', port: 9100);

//   if (res == PosPrintResult.success) {
//     testReceipt(printer);
//     printer.disconnect();
//   }
//   print('Print result: ${res.msg}');
//   showToast('Print result: ${res.msg}', context);
// }

// void testReceipt(NetworkPrinter printer) {
//   printer.text(
//       'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
//   printer.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
//       styles: PosStyles(codeTable: 'CP1252'));
//   printer.text('Special 2: blåbærgrød', styles: PosStyles(codeTable: 'CP1252'));

//   printer.text('Bold text', styles: PosStyles(bold: true));
//   printer.text('Reverse text', styles: PosStyles(reverse: true));
//   printer.text('Underlined text',
//       styles: PosStyles(underline: true), linesAfter: 1);
//   printer.text('Align left', styles: PosStyles(align: PosAlign.left));
//   printer.text('Align center', styles: PosStyles(align: PosAlign.center));
//   printer.text('Align right',
//       styles: PosStyles(align: PosAlign.right), linesAfter: 1);

//   printer.text('Text size 200%',
//       styles: PosStyles(
//         height: PosTextSize.size2,
//         width: PosTextSize.size2,
//       ));

//   printer.feed(2);
//   printer.cut();
// }
