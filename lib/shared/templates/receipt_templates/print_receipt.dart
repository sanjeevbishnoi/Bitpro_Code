import 'dart:io';
import 'dart:typed_data';
import 'package:barcode_image/barcode_image.dart';
import 'package:bitpro_hive/model/store_data.dart';
import 'package:bitpro_hive/services/hive/hive_settings/hive_store_db_service.dart';
import 'package:bitpro_hive/shared/templates/receipt_templates/ecs_pos_printer.dart';
import 'package:bitpro_hive/shared/templates/receipt_templates/usb_printer.dart';
import 'package:hive/hive.dart';
import 'package:bitpro_hive/model/receipt/db_receipt_data.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/shared/templates/receipt_templates/DES0002_A4_receipt_template.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../model/customer_data.dart';
import '../../global_variables/static_text_translate.dart';
import '../../toast.dart';
import '80mm_noVat.dart';
import '80mm_receipt_template.dart';
import 'DES0001_A4_receipt_template.dart';
import 'DES0003_A4_receipt_template.dart';
import 'DES0004_A4_receipt_template.dart';
import 'ECS_POS_80mm_template.dart';

Future<void> printReceipt(
    context,
    DbReceiptData dbReceiptData,
    String taxValue,
    CustomerData? selectedCustomerData,
    // Printer printer,
    String tenderAmount,
    String changeAmount) async {
  //   await Printing.layoutPdf(
  // onLayout: (PdfPageFormat format) async => await Printing.convertHtml(
  //       format: format,
  //       html: '<html><body><p>Hello!</p></body></html>',
  //     ));

  // return ;
  var box = Hive.box('bitpro_app');
  List<Printer> p = await Printing.listPrinters();

  var activePrinter = box.get('active_printer');
  Printer? selectedPrinter;

  if (activePrinter != null) {
    if (Printer.fromMap(activePrinter).name ==
        'Select Printer While Printing') {
      selectedPrinter = const Printer(
          url: 'Select Printer While Printing',
          name: 'Select Printer While Printing');
    } else {
      for (var t in p) {
        if (t.name == Printer.fromMap(activePrinter).name) {
          selectedPrinter = t;
        }
      }
    }
  }
  if (selectedPrinter == null) {
    showToast(staticTextTranslate('Select a printer from printing settings'),
        context);
    return;
  }

  final doc = pw.Document();

  final arabicNormalFont =
      await fontFromAssetBundle('assets/Segoe.UI_.Semibold.ttf');
  final arabicLightFont = await fontFromAssetBundle('assets/Segoe.UI.ttf');

  final txtBoldFont =
      await fontFromAssetBundle('assets/Segoe.UI_.Semibold.ttf');

  final txtNormalFont = await fontFromAssetBundle('assets/Segoe.UI.ttf');

  UserData userData = UserData.fromMap(box.get('user_data'));
  Map? userSettingsData = box.get('user_settings_data');
  Map? userPrintingData = box.get('user_printing_settings');
  Map? userTaxesData = box.get('user_taxes_settings');
  StoreData seletedStoreData =
      await HiveStoreDbService().getSelectedStoreData();

  late var image;
  String vatPercentage = '10';
  try {
    image = pw.MemoryImage(File(seletedStoreData.logoPath).readAsBytesSync());
  } catch (e) {
    image = await imageFromAssetBundle('assets/bitpro_logo.png');
  }
  if (userTaxesData != null) {
    vatPercentage = userTaxesData['taxPercentage'];
  }
  String selectedTemplate = '80 mm';
  if (userPrintingData != null &&
      userPrintingData['selectedReceiptTemplate'] != null) {
    selectedTemplate = userPrintingData['selectedReceiptTemplate'];
  }

  if (selectedTemplate == '80 mm') {
    doc.addPage(pw.MultiPage(
        pageFormat:
            const PdfPageFormat(70 * PdfPageFormat.mm, 297 * PdfPageFormat.mm),
        build: (context) {
          return receipt80mmTemplate(
              arabicNormalFont: arabicNormalFont,
              dbReceiptData: dbReceiptData,
              image: image,
              taxValue: taxValue,
              txtBoldFont: txtBoldFont,
              userData: userData,
              userPrintingData: userPrintingData,
              userSettingsData: userSettingsData,
              seletedStoreData: seletedStoreData,
              vatPercentage: vatPercentage);
        }));
  } else if (selectedTemplate == '80 mm No Vat') {
    doc.addPage(pw.MultiPage(
        pageFormat:
            const PdfPageFormat(70 * PdfPageFormat.mm, 297 * PdfPageFormat.mm),
        build: (context) {
          return receipt80mmNoVatTemplate(
              arabicNormalFont: arabicNormalFont,
              dbReceiptData: dbReceiptData,
              image: image,
              taxValue: taxValue,
              txtBoldFont: txtBoldFont,
              userData: userData,
              seletedStoreData: seletedStoreData,
              userPrintingData: userPrintingData,
              userSettingsData: userSettingsData,
              vatPercentage: vatPercentage);
        }));
  } else if (selectedTemplate == 'ECS-POS-80mm') {
    doc.addPage(pw.MultiPage(
        pageFormat:
            const PdfPageFormat(70 * PdfPageFormat.mm, 297 * PdfPageFormat.mm),
        build: (context) {
          return receiptECSPOS80mmTemplate(
              arabicNormalFont: arabicNormalFont,
              dbReceiptData: dbReceiptData,
              image: image,
              taxValue: taxValue,
              txtBoldFont: txtBoldFont,
              userData: userData,
              seletedStoreData: seletedStoreData,
              userPrintingData: userPrintingData,
              userSettingsData: userSettingsData,
              vatPercentage: vatPercentage);
        }));
  } else if (selectedTemplate == 'DES0001-A4') {
    doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(15),
        build: (pw.Context context) {
          return [
            des0001A4ReceiptTemplate(
              txtNormalFont: txtNormalFont,
              selectedCustomerData: selectedCustomerData,
              arabicNormalFont: arabicNormalFont,
              dbReceiptData: dbReceiptData,
              image: image,
              taxValue: taxValue,
              txtBoldFont: txtBoldFont,
              arabicLightFont: arabicLightFont,
              userData: userData,
              userPrintingData: userPrintingData,
              seletedStoreData: seletedStoreData,
              userSettingsData: userSettingsData,
              vatPercentage: vatPercentage,
            )
          ];
        }));
  } else if (selectedTemplate == 'DES0002-A4') {
    doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(15),
        build: (pw.Context context) {
          return [
            des0002A4ReceiptTemplate(
                txtNormalFont: txtNormalFont,
                selectedCustomerData: selectedCustomerData,
                arabicNormalFont: arabicNormalFont,
                dbReceiptData: dbReceiptData,
                image: image,
                taxValue: taxValue,
                txtBoldFont: txtBoldFont,
                arabicLightFont: arabicLightFont,
                userData: userData,
                seletedStoreData: seletedStoreData,
                userPrintingData: userPrintingData,
                userSettingsData: userSettingsData,
                vatPercentage: vatPercentage)
          ];
        }));
  } else if (selectedTemplate == 'DES0003-A4') {
    doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(15),
        footer: (c) {
          return pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('${c.pageNumber} / ${c.pagesCount}',
                    style: pw.TextStyle(
                        font: txtNormalFont,
                        color: PdfColors.grey,
                        fontSize: 9)),
              ]);
        },
        build: (pw.Context context) {
          return [
            des0003A4ReceiptTemplate(
                txtNormalFont: txtNormalFont,
                selectedCustomerData: selectedCustomerData,
                arabicNormalFont: arabicNormalFont,
                dbReceiptData: dbReceiptData,
                image: image,
                taxValue: taxValue,
                txtBoldFont: txtBoldFont,
                arabicLightFont: arabicLightFont,
                userData: userData,
                userPrintingData: userPrintingData,
                selectedStoreData: seletedStoreData,
                userSettingsData: userSettingsData,
                vatPercentage: vatPercentage)
          ];
        }));
  } else if (selectedTemplate == 'DES0004-A4') {
    doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(15),
        footer: (c) {
          return pw.Row(children: [
            pw.Expanded(child: pw.SizedBox(width: 5)),
            pw.Text('Page ${c.pageNumber}',
                style: pw.TextStyle(font: txtNormalFont, fontSize: 9)),
            pw.SizedBox(width: 20)
          ]);
        },
        build: (pw.Context context) {
          return [
            des0004A4ReceiptTemplate(
                context: context,
                changeAmount: changeAmount,
                tenderAmount: tenderAmount,
                txtNormalFont: txtNormalFont,
                selectedCustomerData: selectedCustomerData,
                arabicNormalFont: arabicNormalFont,
                dbReceiptData: dbReceiptData,
                image: image,
                taxValue: taxValue,
                txtBoldFont: txtBoldFont,
                arabicLightFont: arabicLightFont,
                userData: userData,
                userPrintingData: userPrintingData,
                userSettingsData: userSettingsData,
                selectedStoreData: seletedStoreData,
                vatPercentage: vatPercentage)
          ];
        }));
  }

  if (selectedTemplate == '80 mm') {
    // printTicket2(await doc.save(), selectedPrinter, context);
  } else if (selectedTemplate == 'ECS-POS-80mm') {
    // printTicket2(await doc.save(), selectedPrinter, context);
    Uint8List s = await doc.save();

    // await usbPrintReceipt(context, s);
  } else if (selectedPrinter.url == 'Select Printer While Printing') {
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
  } else {
    await Printing.directPrintPdf(
        printer: selectedPrinter,
        onLayout: (PdfPageFormat format) async => doc.save());
  }

  // final res = await Printing.directPrintPdf(
  //   printer: printer,
  //   // !,
  //   // don't use doc.document.save() - it's not working, even with MS pdf printers
  //   onLayout: (_) => doc.save(),
  //   // format: pageFormat,
  //   usePrinterSettings: true,
  // );
}

String buildBarcode(
  Barcode bc,
  String data, {
  String? filename,
  double? width,
  double? height,
  double? fontHeight,
}) {
  /// Create the Barcode
  final svg = bc.toSvg(
    data,
    width: width ?? 200,
    height: height ?? 80,
    fontHeight: fontHeight,
  );

  return svg;
}

calculateTotalPriceWt(items) {
  double t = 0;
  for (var i in items) {
    t += double.parse(i['priceWt']) * double.parse(i['qty']);
  }
  return t.toStringAsFixed(2);
}
