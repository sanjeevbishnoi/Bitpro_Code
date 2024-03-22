import 'dart:io';
import 'package:bitpro_hive/model/store_data.dart';
import 'package:bitpro_hive/services/hive/hive_settings/hive_store_db_service.dart';
import 'package:bitpro_hive/shared/check_contain_arabic_letters.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../model/vendor_data.dart';
import '../../../model/vendor_payment_data.dart';
import '../../global_variables/static_text_translate.dart';
import '../../toast.dart';

Future<void> printVendorPayment(
    context,
    List<VendorPaymentTempModel> vendorPaymentTempModelList,
    VendorData selectedVendorData,
    String totalPurchaseAmt,
    String totalPaidAmt,
    String balanceAmt) async {
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
      await fontFromAssetBundle('assets/PlusJakartaSans-Bold.ttf');

  final txtNormalFont =
      await fontFromAssetBundle('assets/PlusJakartaSans-Regular.ttf');

  UserData userData = UserData.fromMap(box.get('user_data'));
  Map? userSettingsData = box.get('user_settings_data');
  Map? userPrintingData = box.get('user_printing_settings');
  Map? userTaxesData = box.get('user_taxes_settings');
  StoreData selectedStoreData =
      await HiveStoreDbService().getSelectedStoreData();
  late var image;
  try {
    image = pw.MemoryImage(File(selectedStoreData.logoPath).readAsBytesSync());
  } catch (e) {
    image = await imageFromAssetBundle('assets/bitpro_logo.png');
  }
  if (userTaxesData != null) {}

  doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      footer: (c) {
        return pw.Row(children: [
          pw.Expanded(child: pw.SizedBox(width: 5)),
          pw.Text('Page ${c.pageNumber}',
              style: pw.TextStyle(font: txtNormalFont, fontSize: 9)),
          pw.SizedBox(width: 20)
        ]);
      },
      margin: const pw.EdgeInsets.all(15),
      build: (pw.Context context) {
        return [
          customerPaymentTemplate(
              txtNormalFont: txtNormalFont,
              selectedVendorData: selectedVendorData,
              arabicNormalFont: arabicNormalFont,
              vendorPaymentTempModelList: vendorPaymentTempModelList,
              image: image,
              txtBoldFont: txtBoldFont,
              arabicLightFont: arabicLightFont,
              userData: userData,
              userPrintingData: userPrintingData,
              userSettingsData: userSettingsData,
              selectedStoreData: selectedStoreData,
              balanceAmt: balanceAmt,
              totalPaidAmt: totalPaidAmt,
              totalPurchaseAmt: totalPurchaseAmt)
        ];
      }));

  if (selectedPrinter.url == 'Select Printer While Printing') {
    await Printing.layoutPdf(
        format: PdfPageFormat.a4.landscape,
        onLayout: (PdfPageFormat format) async => doc.save());
  } else {
    await Printing.directPrintPdf(
        printer: selectedPrinter,
        format: PdfPageFormat.a4.landscape,
        onLayout: (PdfPageFormat format) async => doc.save());
  }
}

customerPaymentTemplate(
    {required image,
    required userData,
    required userSettingsData,
    required userPrintingData,
    required List<VendorPaymentTempModel> vendorPaymentTempModelList,
    required txtBoldFont,
    required arabicLightFont,
    required arabicNormalFont,
    required txtNormalFont,
    required VendorData selectedVendorData,
    required StoreData selectedStoreData,
    required String totalPurchaseAmt,
    required String totalPaidAmt,
    required String balanceAmt}) {
  return pw.Container(
      width: double.maxFinite,
      child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                            decoration: const pw.BoxDecoration(
                                color: PdfColor.fromInt(0xfff5f5f3)),
                            padding: const pw.EdgeInsets.all(8),
                            height: 120,
                            width: 185,
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                if (userSettingsData != null)
                                  pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(
                                          'Name',
                                          style: pw.TextStyle(
                                            fontSize: 8,
                                            font: txtNormalFont,
                                          ),
                                        ),
                                        pw.SizedBox(width: 10),
                                        pw.Container(
                                            width: 90,
                                            child: pw.Flexible(
                                                child: pw.Column(children: [
                                              pw.Text(
                                                userSettingsData['companyName'],
                                                textAlign: pw.TextAlign.left,
                                                textDirection:
                                                    !containsExtendedArabic(
                                                            userSettingsData[
                                                                    'companyName']
                                                                .toString())
                                                        ? pw.TextDirection.ltr
                                                        : pw.TextDirection.rtl,
                                                style: pw.TextStyle(
                                                  font: !containsExtendedArabic(
                                                          userSettingsData[
                                                                  'companyName']
                                                              .toString())
                                                      ? txtBoldFont
                                                      : arabicNormalFont,
                                                  fontSize: 7,
                                                ),
                                              ),
                                            ]))),
                                        pw.SizedBox(width: 10),
                                        pw.Text(
                                          'باركود',
                                          textDirection: pw.TextDirection.rtl,
                                          style: pw.TextStyle(
                                            fontSize: 8,
                                            font: arabicNormalFont,
                                          ),
                                        ),
                                      ]),
                                if (selectedStoreData.address1
                                    .toString()
                                    .isNotEmpty)
                                  pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(
                                          'Address',
                                          style: pw.TextStyle(
                                              fontSize: 8,
                                              fontBold: txtNormalFont),
                                        ),
                                        pw.SizedBox(width: 10),
                                        pw.Container(
                                            width: 90,
                                            child: pw.Flexible(
                                                child: pw.Column(children: [
                                              pw.Text(
                                                selectedStoreData.address1,
                                                textAlign: pw.TextAlign.center,
                                                maxLines: 2,
                                                textDirection:
                                                    !containsExtendedArabic(
                                                            selectedStoreData
                                                                .address1
                                                                .toString())
                                                        ? pw.TextDirection.ltr
                                                        : pw.TextDirection.rtl,
                                                style: pw.TextStyle(
                                                  font: !containsExtendedArabic(
                                                          selectedStoreData
                                                              .address1
                                                              .toString())
                                                      ? txtNormalFont
                                                      : arabicLightFont,
                                                  fontSize: 8,
                                                ),
                                              ),
                                            ]))),
                                        pw.SizedBox(width: 10),
                                        pw.Text(
                                          'باركود',
                                          textDirection: pw.TextDirection.rtl,
                                          style: pw.TextStyle(
                                              fontSize: 8,
                                              font: arabicNormalFont,
                                              fontWeight: pw.FontWeight.bold),
                                        ),
                                      ]),
                                if (selectedStoreData.vatNumber
                                    .toString()
                                    .isNotEmpty)
                                  pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(
                                          'VAT No.',
                                          style: pw.TextStyle(
                                            fontSize: 8,
                                            font: txtNormalFont,
                                          ),
                                        ),
                                        pw.SizedBox(width: 10),
                                        pw.Container(
                                            width: 90,
                                            child: pw.Flexible(
                                                child: pw.Column(children: [
                                              pw.Text(
                                                selectedStoreData.vatNumber,
                                                textAlign: pw.TextAlign.center,
                                                style: pw.TextStyle(
                                                  fontSize: 8,
                                                  font: txtNormalFont,
                                                ),
                                              ),
                                            ]))),
                                        pw.SizedBox(width: 10),
                                        pw.Text(
                                          'باركود',
                                          textDirection: pw.TextDirection.rtl,
                                          style: pw.TextStyle(
                                            fontSize: 8,
                                            font: arabicNormalFont,
                                          ),
                                        ),
                                      ]),
                                if (selectedStoreData.phone1
                                    .toString()
                                    .isNotEmpty)
                                  pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(
                                          'Phone No.',
                                          style: pw.TextStyle(
                                            fontSize: 8,
                                            font: txtNormalFont,
                                          ),
                                        ),
                                        pw.SizedBox(width: 10),
                                        pw.Container(
                                            width: 90,
                                            child: pw.Flexible(
                                                child: pw.Column(children: [
                                              pw.Text(
                                                selectedStoreData.phone1,
                                                textAlign: pw.TextAlign.center,
                                                style: pw.TextStyle(
                                                  fontSize: 8,
                                                  font: txtNormalFont,
                                                ),
                                              ),
                                            ]))),
                                        pw.SizedBox(width: 10),
                                        pw.Text(
                                          'باركود',
                                          textDirection: pw.TextDirection.rtl,
                                          style: pw.TextStyle(
                                              fontSize: 8,
                                              color: const PdfColor.fromInt(
                                                  0xfff5f5f3),
                                              font: arabicNormalFont,
                                              fontWeight: pw.FontWeight.bold),
                                        ),
                                      ]),
                                if (selectedStoreData.email
                                    .toString()
                                    .isNotEmpty)
                                  pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(
                                          'Email',
                                          style: pw.TextStyle(
                                            fontSize: 8,
                                            font: txtNormalFont,
                                          ),
                                        ),
                                        pw.SizedBox(width: 10),
                                        pw.Container(
                                            width: 90,
                                            child: pw.Flexible(
                                                child: pw.Column(children: [
                                              pw.Text(
                                                selectedStoreData.email,
                                                textAlign: pw.TextAlign.center,
                                                style: pw.TextStyle(
                                                  fontSize: 8,
                                                  font: txtNormalFont,
                                                ),
                                              ),
                                            ]))),
                                        pw.SizedBox(width: 10),
                                        pw.Text(
                                          'باركود',
                                          textDirection: pw.TextDirection.rtl,
                                          style: pw.TextStyle(
                                              fontSize: 8,
                                              color: const PdfColor.fromInt(
                                                  0xfff5f5f3),
                                              font: arabicNormalFont,
                                              fontWeight: pw.FontWeight.bold),
                                        ),
                                      ])
                              ],
                            )),
                        pw.SizedBox(width: 10),
                        pw.Container(
                            decoration: const pw.BoxDecoration(
                                color: PdfColor.fromInt(0xfff5f5f3)),
                            padding: const pw.EdgeInsets.all(8),
                            height: 120,
                            width: 185,
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Row(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text(
                                        'Vendor Info',
                                        style: pw.TextStyle(
                                            fontSize: 10,
                                            fontBold: txtBoldFont,
                                            fontWeight: pw.FontWeight.bold),
                                      ),
                                      pw.Text(
                                        'باركود',
                                        textDirection: pw.TextDirection.rtl,
                                        style: pw.TextStyle(
                                            fontSize: 12,
                                            font: arabicNormalFont,
                                            fontWeight: pw.FontWeight.bold),
                                      ),
                                    ]),
                                pw.SizedBox(height: 5),
                                pw.Row(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        'Name',
                                        style: pw.TextStyle(
                                          fontSize: 8,
                                          fontBold: txtNormalFont,
                                        ),
                                      ),
                                      pw.SizedBox(width: 10),
                                      pw.Container(
                                          width: 90,
                                          child: pw.Flexible(
                                              child: pw.Column(children: [
                                            pw.Text(
                                              selectedVendorData.vendorName,
                                              textAlign: pw.TextAlign.center,
                                              textDirection:
                                                  !containsExtendedArabic(
                                                          selectedVendorData
                                                              .vendorName
                                                              .toString())
                                                      ? pw.TextDirection.ltr
                                                      : pw.TextDirection.rtl,
                                              maxLines: 2,
                                              style: pw.TextStyle(
                                                font: !containsExtendedArabic(
                                                        selectedVendorData
                                                            .vendorName
                                                            .toString())
                                                    ? txtNormalFont
                                                    : arabicLightFont,
                                                fontSize: 8,
                                              ),
                                            ),
                                          ]))),
                                      pw.SizedBox(width: 10),
                                      pw.Text(
                                        'باركود',
                                        textDirection: pw.TextDirection.rtl,
                                        style: pw.TextStyle(
                                          fontSize: 8,
                                          font: arabicNormalFont,
                                        ),
                                      ),
                                    ]),
                                if (selectedVendorData.address1.isNotEmpty)
                                  pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(
                                          'Address',
                                          style: pw.TextStyle(
                                            fontSize: 8,
                                            fontBold: txtNormalFont,
                                          ),
                                        ),
                                        pw.SizedBox(width: 10),
                                        pw.Container(
                                            width: 90,
                                            child: pw.Flexible(
                                                child: pw.Column(children: [
                                              pw.Text(
                                                selectedVendorData.address1,
                                                textAlign: pw.TextAlign.left,
                                                textDirection:
                                                    !containsExtendedArabic(
                                                            selectedStoreData
                                                                .address1
                                                                .toString())
                                                        ? pw.TextDirection.ltr
                                                        : pw.TextDirection.rtl,
                                                maxLines: 2,
                                                style: pw.TextStyle(
                                                  font: !containsExtendedArabic(
                                                          selectedStoreData
                                                              .address1
                                                              .toString())
                                                      ? txtNormalFont
                                                      : arabicLightFont,
                                                  fontSize: 8,
                                                ),
                                              ),
                                            ]))),
                                        pw.SizedBox(width: 10),
                                        pw.Text(
                                          'باركود',
                                          textDirection: pw.TextDirection.rtl,
                                          style: pw.TextStyle(
                                              fontSize: 8,
                                              font: arabicNormalFont),
                                        ),
                                      ]),
                                if (selectedVendorData.vatNumber.isNotEmpty)
                                  pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(
                                          'VAT No.',
                                          style: pw.TextStyle(
                                              fontSize: 8,
                                              fontBold: txtBoldFont),
                                        ),
                                        pw.SizedBox(width: 10),
                                        pw.Container(
                                            width: 90,
                                            child: pw.Flexible(
                                                child: pw.Column(children: [
                                              pw.Text(
                                                selectedVendorData.vatNumber,
                                                style: pw.TextStyle(
                                                  fontSize: 8,
                                                  font: txtNormalFont,
                                                ),
                                              ),
                                            ]))),
                                        pw.SizedBox(width: 10),
                                        pw.Text(
                                          'باركود',
                                          textDirection: pw.TextDirection.rtl,
                                          style: pw.TextStyle(
                                              fontSize: 8,
                                              font: arabicNormalFont),
                                        ),
                                      ]),
                                if (selectedVendorData.emailAddress.isNotEmpty)
                                  pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(
                                          'Email',
                                          style: pw.TextStyle(
                                              fontSize: 8,
                                              fontBold: txtBoldFont),
                                        ),
                                        pw.SizedBox(width: 10),
                                        pw.Container(
                                            width: 90,
                                            child: pw.Flexible(
                                                child: pw.Column(children: [
                                              pw.Text(
                                                selectedVendorData.emailAddress,
                                                style: pw.TextStyle(
                                                  fontSize: 8,
                                                  font: txtNormalFont,
                                                ),
                                              ),
                                            ]))),
                                        pw.SizedBox(width: 10),
                                        pw.Text(
                                          'باركود',
                                          textDirection: pw.TextDirection.rtl,
                                          style: pw.TextStyle(
                                              fontSize: 8,
                                              font: arabicNormalFont),
                                        ),
                                      ])
                              ],
                            )),
                        pw.Expanded(child: pw.SizedBox(width: 20)),
                        pw.Container(
                          margin: const pw.EdgeInsets.only(right: 20),
                          width: 120,
                          height: 90,
                          child: pw.Image(image,
                              width: 120, height: 90, fit: pw.BoxFit.contain),
                        ),
                        pw.SizedBox(width: 10),
                      ]),
                  pw.SizedBox(
                    height: 10,
                  ),
                ]),
            pw.Container(
              width: double.maxFinite,
              alignment: pw.Alignment.centerLeft,
              child: pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(4),
                  4: const pw.FlexColumnWidth(2),
                  5: const pw.FlexColumnWidth(2),
                  6: const pw.FlexColumnWidth(2)
                },
                children: [
                  pw.TableRow(
                      decoration: const pw.BoxDecoration(
                          border: pw.Border(
                        top: pw.BorderSide(color: PdfColors.black, width: .6),
                        left: pw.BorderSide(color: PdfColors.black, width: .6),
                        bottom:
                            pw.BorderSide(color: PdfColors.black, width: .6),
                      )),
                      children: [
                        pw.Container(
                            height: 30,
                            decoration: const pw.BoxDecoration(
                                color: PdfColor.fromInt(0xff165343),
                                border: pw.Border(
                                  top: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                  left: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                  bottom: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                )),
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(
                                  'باركود',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    font: arabicNormalFont,
                                    color: PdfColors.white,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 2,
                                ),
                                pw.Text('Document',
                                    style: pw.TextStyle(
                                        color: PdfColors.white,
                                        fontSize: 8,
                                        font: txtBoldFont))
                              ],
                            )),
                        pw.Container(
                            height: 30,
                            decoration: const pw.BoxDecoration(
                                color: PdfColor.fromInt(0xff165343),
                                border: pw.Border(
                                  top: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                  left: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                  bottom: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                )),
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(
                                  'الصنف',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    color: PdfColors.white,
                                    font: arabicNormalFont,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 2,
                                ),
                                pw.Text('Type',
                                    style: pw.TextStyle(
                                        color: PdfColors.white,
                                        fontSize: 8,
                                        font: txtBoldFont))
                              ],
                            )),
                        pw.Container(
                            height: 30,
                            decoration: const pw.BoxDecoration(
                                color: PdfColor.fromInt(0xff165343),
                                border: pw.Border(
                                  top: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                  left: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                  bottom: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                )),
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(
                                  'كمية',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    color: PdfColors.white,
                                    font: arabicNormalFont,
                                    fontSize: 8,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 2,
                                ),
                                pw.Text('Date',
                                    style: pw.TextStyle(
                                        color: PdfColors.white,
                                        fontSize: 8,
                                        font: txtBoldFont))
                              ],
                            )),
                        pw.Container(
                            decoration: const pw.BoxDecoration(
                                color: PdfColor.fromInt(0xff165343),
                                border: pw.Border(
                                  top: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                  left: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                  bottom: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                )),
                            height: 30,
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(
                                  'سعر',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    font: arabicNormalFont,
                                    fontSize: 8,
                                    color: PdfColors.white,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 2,
                                ),
                                pw.Text('Description',
                                    style: pw.TextStyle(
                                        color: PdfColors.white,
                                        fontSize: 8,
                                        font: txtBoldFont))
                              ],
                            )),
                        pw.Container(
                            height: 30,
                            decoration: const pw.BoxDecoration(
                                color: PdfColor.fromInt(0xff165343),
                                border: pw.Border(
                                  top: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                  left: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                  bottom: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                )),
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(
                                  'الضريبية',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    font: arabicNormalFont,
                                    fontSize: 8,
                                    color: PdfColors.white,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 2,
                                ),
                                pw.Text('Purchased',
                                    style: pw.TextStyle(
                                        color: PdfColors.white,
                                        fontSize: 8,
                                        font: txtBoldFont))
                              ],
                            )),
                        pw.Container(
                            height: 30,
                            decoration: const pw.BoxDecoration(
                                color: PdfColor.fromInt(0xff165343),
                                border: pw.Border(
                                  top: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                  left: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                  bottom: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                )),
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(
                                  'اجمالي',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    font: arabicNormalFont,
                                    color: PdfColors.white,
                                    fontSize: 8,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 2,
                                ),
                                pw.Text('Paid',
                                    style: pw.TextStyle(
                                        color: PdfColors.white,
                                        fontSize: 8,
                                        font: txtBoldFont))
                              ],
                            )),
                        pw.Container(
                            height: 30,
                            decoration: const pw.BoxDecoration(
                                color: PdfColor.fromInt(0xff165343),
                                border: pw.Border(
                                  top: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                  right: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                  bottom: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                )),
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(
                                  'اجمالي',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    font: arabicNormalFont,
                                    fontSize: 8,
                                    color: PdfColors.white,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 2,
                                ),
                                pw.Text('Balance',
                                    style: pw.TextStyle(
                                        color: PdfColors.white,
                                        fontSize: 8,
                                        font: txtBoldFont))
                              ],
                            )),
                      ]),
                ],
              ),
            ),
            productTile(txtNormalFont, null, selectedVendorData,
                arabicLightFont, false, true),
            for (VendorPaymentTempModel d in vendorPaymentTempModelList)
              productTile(txtNormalFont, d, selectedVendorData, arabicLightFont,
                  vendorPaymentTempModelList.last == d, false),
            pw.SizedBox(height: 30),
            pw.Container(
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  if (userPrintingData != null)
                    pw.SizedBox(
                        width: 200,
                        child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: pw.Text(
                                      userPrintingData['receiptFotterEng'],
                                      style: pw.TextStyle(
                                          fontSize: 8, font: txtNormalFont))),
                              pw.SizedBox(
                                height: 5,
                              ),
                              pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: pw.Align(
                                      alignment: pw.Alignment.bottomRight,
                                      child: pw.Text(
                                        userPrintingData['receiptFotterArb'],
                                        textDirection: pw.TextDirection.rtl,
                                        style: pw.TextStyle(
                                          fontSize: 8,
                                          font: arabicLightFont,
                                        ),
                                      ))),
                            ])),
                  pw.Expanded(
                      child: pw.SizedBox(
                    width: 10,
                  )),
                  pw.Column(
                    children: [
                      pw.Row(children: [
                        pw.Container(
                            height: 30,
                            width: 70,
                            decoration: const pw.BoxDecoration(
                                color: PdfColor.fromInt(0xff165343),
                                border: pw.Border(
                                  top: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                  left: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                  bottom: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                )),
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(
                                  'اجمالي',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    font: arabicNormalFont,
                                    fontSize: 8,
                                    color: PdfColors.white,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 2,
                                ),
                                pw.Text('Purchased',
                                    style: pw.TextStyle(
                                        color: PdfColors.white,
                                        fontSize: 8,
                                        font: txtBoldFont))
                              ],
                            )),
                        pw.Container(
                            height: 30,
                            width: 70,
                            decoration: const pw.BoxDecoration(
                                color: PdfColor.fromInt(0xff165343),
                                border: pw.Border(
                                  top: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                  left: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                  bottom: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                )),
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'اجمالي',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    font: arabicNormalFont,
                                    fontSize: 8,
                                    color: PdfColors.white,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 2,
                                ),
                                pw.Text('Paid',
                                    style: pw.TextStyle(
                                        color: PdfColors.white,
                                        fontSize: 8,
                                        font: txtBoldFont))
                              ],
                            )),
                        pw.Container(
                            height: 30,
                            width: 70,
                            decoration: const pw.BoxDecoration(
                                color: PdfColor.fromInt(0xff165343),
                                border: pw.Border(
                                  top: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                  left: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                  right: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                  bottom: pw.BorderSide(
                                      color: PdfColors.black, width: .6),
                                )),
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'اجمالي',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    font: arabicNormalFont,
                                    fontSize: 8,
                                    color: PdfColors.white,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 2,
                                ),
                                pw.Text('Balance',
                                    style: pw.TextStyle(
                                        color: PdfColors.white,
                                        fontSize: 8,
                                        font: txtBoldFont))
                              ],
                            )),
                      ]),
                      pw.Row(children: [
                        pw.Container(
                            height: 20,
                            width: 70,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: PdfColors.black, width: .6)),
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(totalPurchaseAmt,
                                style: pw.TextStyle(
                                    fontSize: 8, font: txtBoldFont))),
                        pw.Container(
                            height: 20,
                            width: 70,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: PdfColors.black, width: .6)),
                            padding: const pw.EdgeInsets.all(4),
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(totalPaidAmt,
                                style: pw.TextStyle(
                                    fontSize: 8, font: txtBoldFont))),
                        pw.Container(
                            height: 20,
                            width: 70,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: PdfColors.black, width: .6)),
                            padding: const pw.EdgeInsets.all(4),
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(balanceAmt,
                                style: pw.TextStyle(
                                    fontSize: 8, font: txtBoldFont))),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(
              height: 25,
            ),
            pw.SizedBox(
              height: 25,
            ),
          ]));
}

productTile(txtNormalFont, VendorPaymentTempModel? vendorPaymentTempData,
    VendorData selectedVendorData, arabicFont, bool last, bool first) {
  double height = 30;
  // int nol = (
  //         // '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890'
  //         customerPaymentData.toString().length / 50)
  //     .ceil();

  // if (nol != 1) {
  //   height += 10 * (nol - 1);
  // }

  String doc = '';
  String type = '';
  String date = '';
  String description = '';
  String purchased = '';
  String paid = '';

  String balance = '';

  if (first) {
    doc = 'Opening Balance';
    type = '';

    date = '';
    description = '';
    purchased = selectedVendorData.openingBalance;
    paid = '';
  } else {
    doc = vendorPaymentTempData!.dbVoucherData != null ? 'Voucher' : 'Payment';
    type = vendorPaymentTempData.dbVoucherData != null
        ? vendorPaymentTempData.dbVoucherData!.voucherType
        : '';

    date = DateFormat.yMd().add_jm().format(vendorPaymentTempData.dateTime);
    description = vendorPaymentTempData.dbVoucherData != null
        ? ''
        : vendorPaymentTempData.vendorPaymentData!.comment;
    purchased = vendorPaymentTempData.dbVoucherData != null
        ? vendorPaymentTempData.dbVoucherData!.voucherTotal
        : '';
    paid = vendorPaymentTempData.dbVoucherData != null
        ? ''
        : vendorPaymentTempData.vendorPaymentData!.amount.toString();
  }

  return pw.Row(children: [
    pw.Container(
        decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: .6)),
        height: height,
        width: 101.5,
        alignment: pw.Alignment.centerLeft,
        padding: const pw.EdgeInsets.all(3),
        child: pw.Text(
          first ? 'Opening Balance' : doc,
          textAlign: pw.TextAlign.left,
          style: pw.TextStyle(font: txtNormalFont, fontSize: 8),
        )),
    pw.Container(
        decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: .6)),
        height: height,
        width: 101.5,
        alignment: pw.Alignment.centerLeft,
        padding: const pw.EdgeInsets.all(3),
        child: pw.Text(
          type,
          textAlign: pw.TextAlign.left,
          style: pw.TextStyle(font: txtNormalFont, fontSize: 8),
        )),
    pw.Container(
      decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.black, width: .6)),
      height: height,
      width: 101.5,
      alignment: pw.Alignment.centerLeft,
      padding: const pw.EdgeInsets.all(3),
      child: pw.Text(
        date,
        textAlign: pw.TextAlign.left,
        style: pw.TextStyle(
          font: txtNormalFont,
          fontSize: 8,
        ),
      ),
    ),
    pw.Container(
        decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: .6)),
        height: height,
        width: 202.5,
        alignment: pw.Alignment.centerLeft,
        padding: const pw.EdgeInsets.all(3),
        child: pw.Text(description,
            textAlign: pw.TextAlign.left,
            style: pw.TextStyle(fontSize: 8, font: txtNormalFont))),
    pw.Container(
        decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: .6)),
        height: height,
        width: 101.5,
        alignment: pw.Alignment.centerLeft,
        padding: const pw.EdgeInsets.all(3),
        child: pw.Text(purchased,
            textAlign: pw.TextAlign.left,
            style: pw.TextStyle(
              fontSize: 8,
              font: txtNormalFont,
            ))),
    pw.Container(
      decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.black, width: .6)),
      height: height,
      width: 101.5,
      padding: const pw.EdgeInsets.all(3),
      child: pw.Text(paid,
          softWrap: true,
          textAlign: pw.TextAlign.left,
          style: pw.TextStyle(
            font: txtNormalFont,
            fontSize: 8,
            //
          )),
    ),
    pw.Container(
      decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.black, width: .6)),
      height: height,
      width: 101.5,
      padding: const pw.EdgeInsets.all(3),
      child: pw.Text(balance,
          softWrap: true,
          textAlign: pw.TextAlign.left,
          style: pw.TextStyle(
            font: txtNormalFont,
            fontSize: 8,
            //
          )),
    )
  ]);
}
