import 'dart:io';
import 'package:bitpro_hive/model/store_data.dart';
import 'package:bitpro_hive/services/hive/hive_settings/hive_store_db_service.dart';
import 'package:bitpro_hive/shared/check_contain_arabic_letters.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:bitpro_hive/model/voucher/db_voucher_data.dart';
import 'package:bitpro_hive/model/vendor_data.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../model/voucher/local_voucher_data.dart';

printVoucher(context, DbVoucherData dbVoucherData, String totalPriceWt,
    VendorData selectedVendorDetails, List<dynamic> localVoucherData) async {
  final doc = pw.Document();

  final arabicNormalFont = await fontFromAssetBundle('assets/Segoe.UI.ttf');

  final txtBoldFont =
      await fontFromAssetBundle('assets/PlusJakartaSans-Bold.ttf');
  final txtNormalFont =
      await fontFromAssetBundle('assets/PlusJakartaSans-Regular.ttf');

  var box = Hive.box('bitpro_app');
  Map? userSettingsData = box.get('user_settings_data');
  var image;

  StoreData seletedStoreData =
      await HiveStoreDbService().getSelectedStoreData();

  try {
    image = pw.MemoryImage(File(seletedStoreData.logoPath).readAsBytesSync());
  } catch (e) {
    image = await imageFromAssetBundle('assets/bitpro_logo.png');
  }

  String calculateVoucherTotal() {
    double t = 0;

    for (LocalVoucherData v in localVoucherData) {
      double d = 0;
      d = double.tryParse(v.cost) ?? 0;
      if (double.tryParse(v.qty) != null) t += d * double.tryParse(v.qty)!;
    }

    //discount value
    if (dbVoucherData.discountValue.isNotEmpty) {
      double dis = double.tryParse(dbVoucherData.discountValue) ?? 0;
      if (dis != 0) {
        t = t - dis;
      }
    }
    return t.toStringAsFixed(2);
  }

  doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      footer: (c) {
        return pw.Row(children: [
          pw.Expanded(child: pw.SizedBox(width: 5)),
          pw.Text('Page ${c.pageNumber}',
              style: pw.TextStyle(font: txtNormalFont, fontSize: 9)),
          pw.SizedBox(width: 20)
        ]);
      },
      margin: const pw.EdgeInsets.all(20),
      build: (context) {
        return [
          pw.Container(
            width: double.maxFinite,
            padding: const pw.EdgeInsets.only(top: 15, bottom: 8),
            decoration: const pw.BoxDecoration(
                border: pw.Border(
                    top: pw.BorderSide(color: PdfColors.black),
                    left: pw.BorderSide(color: PdfColors.black),
                    right: pw.BorderSide(color: PdfColors.black))),
            alignment: pw.Alignment.centerLeft,
            child: pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Align(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Image(image, height: 30),
                          ),
                          pw.SizedBox(
                            height: 10,
                          ),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.SizedBox(
                                width: 130,
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    if (userSettingsData != null)
                                      pw.Text(
                                        userSettingsData['companyName'],
                                        textDirection: RegExp(r'^[a-z]+$')
                                                .hasMatch(userSettingsData[
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
                                            fontSize: 10,
                                            fontWeight: pw.FontWeight.bold),
                                      ),
                                    if (userSettingsData != null)
                                      pw.SizedBox(
                                        height: 4,
                                      ),
                                    pw.Text(seletedStoreData.address1,
                                        textAlign: pw.TextAlign.center,
                                        textDirection: RegExp(r'^[a-z]+$')
                                                .hasMatch(seletedStoreData
                                                    .address1
                                                    .toString())
                                            ? pw.TextDirection.ltr
                                            : pw.TextDirection.rtl,
                                        style: pw.TextStyle(
                                          font: !containsExtendedArabic(
                                                  seletedStoreData.address1
                                                      .toString())
                                              ? txtBoldFont
                                              : arabicNormalFont,
                                          fontSize: 9,
                                        )),
                                    pw.SizedBox(
                                      height: 4,
                                    ),
                                    pw.Text(
                                        'VAT No: ${seletedStoreData.vatNumber}',
                                        style: pw.TextStyle(
                                          fontSize: 9,
                                          font: txtNormalFont,
                                        )),
                                  ],
                                ),
                              ),
                              pw.SizedBox(width: 200),
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                decoration: pw.BoxDecoration(
                                    border:
                                        pw.Border.all(color: PdfColors.black)),
                                child: pw.Column(
                                  children: [
                                    pw.Text(
                                      dbVoucherData.voucherType == 'Regular'
                                          ? 'Regular Voucher'
                                          : 'Return Voucher',
                                      style: pw.TextStyle(
                                          fontSize: 10,
                                          font: txtBoldFont,
                                          fontWeight: pw.FontWeight.bold),
                                    ),
                                    pw.Text(
                                      dbVoucherData.voucherType == 'Regular'
                                          ? 'فاتورة مشتريات'
                                          : '',
                                      textDirection: pw.TextDirection.rtl,
                                      style: pw.TextStyle(
                                          fontSize: 8,
                                          font: arabicNormalFont,
                                          fontWeight: pw.FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(
                            height: 20,
                          ),
                          pw.Row(
                            children: [
                              pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Row(
                                      children: [
                                        pw.Text('Date/',
                                            style: pw.TextStyle(
                                              font: txtNormalFont,
                                              fontSize: 9,
                                            )),
                                        pw.Text(
                                          'تاريخ',
                                          textDirection: pw.TextDirection.rtl,
                                          style: pw.TextStyle(
                                              font: arabicNormalFont,
                                              fontSize: 8,
                                              fontWeight: pw.FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    pw.SizedBox(
                                      height: 4,
                                    ),
                                    pw.Row(children: [
                                      pw.Text('Created Date/',
                                          style: pw.TextStyle(
                                            font: txtNormalFont,
                                            fontSize: 9,
                                          )),
                                      pw.Text(
                                        'انشأ من قبل',
                                        textDirection: pw.TextDirection.rtl,
                                        style: pw.TextStyle(
                                            font: arabicNormalFont,
                                            fontSize: 8,
                                            fontWeight: pw.FontWeight.bold),
                                      ),
                                    ]),
                                    pw.SizedBox(
                                      height: 4,
                                    ),
                                    pw.Row(children: [
                                      pw.Text('Vendor Invoice/',
                                          style: pw.TextStyle(
                                            font: txtNormalFont,
                                            fontSize: 9,
                                          )),
                                      pw.Text(
                                        'قاتورة مورد',
                                        textDirection: pw.TextDirection.rtl,
                                        style: pw.TextStyle(
                                            font: arabicNormalFont,
                                            fontSize: 8,
                                            fontWeight: pw.FontWeight.bold),
                                      ),
                                      pw.Text(' #',
                                          style: pw.TextStyle(
                                            font: txtNormalFont,
                                            fontSize: 9,
                                          )),
                                    ])
                                  ]),
                              pw.SizedBox(
                                width: 20,
                              ),
                              pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                        ': ${DateFormat('dd-MM-yyyy').format(DateTime.parse(dbVoucherData.purchaseInvoiceDate))}',
                                        style: pw.TextStyle(
                                          font: txtNormalFont,
                                          fontSize: 9,
                                        )),
                                    pw.SizedBox(
                                      height: 4,
                                    ),
                                    pw.Text(': ${dbVoucherData.createdBy}',
                                        style: pw.TextStyle(
                                          font: txtNormalFont,
                                          fontSize: 9,
                                        )),
                                    pw.SizedBox(
                                      height: 4,
                                    ),
                                    pw.Text(
                                        ': ${dbVoucherData.purchaseInvoice}',
                                        style: pw.TextStyle(
                                          font: txtNormalFont,
                                          fontSize: 9,
                                        )),
                                  ]),
                            ],
                          ),
                        ],
                      ),
                      pw.Expanded(
                          child: pw.SizedBox(
                        width: 10,
                      )),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.SizedBox(height: 30),
                          pw.Row(
                            children: [
                              pw.Text('Vendor Detalls / ',
                                  style: pw.TextStyle(
                                    fontSize: 9,
                                    font: txtNormalFont,
                                  )),
                              pw.Text(
                                'المورد',
                                textDirection: pw.TextDirection.rtl,
                                style: pw.TextStyle(
                                    font: arabicNormalFont,
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                            ],
                          ),
                          pw.SizedBox(
                            height: 7,
                          ),
                          pw.Text(
                            selectedVendorDetails.vendorName,
                            textAlign: pw.TextAlign.center,
                            textDirection: !containsExtendedArabic(
                                    selectedVendorDetails.vendorName.toString())
                                ? pw.TextDirection.ltr
                                : pw.TextDirection.rtl,
                            style: pw.TextStyle(
                                font: !containsExtendedArabic(
                                        selectedVendorDetails.vendorName
                                            .toString())
                                    ? txtBoldFont
                                    : arabicNormalFont,
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold),
                          ),
                          if (selectedVendorDetails.address1.isNotEmpty)
                            pw.SizedBox(
                              height: 4,
                            ),
                          if (selectedVendorDetails.address1.isNotEmpty)
                            pw.Text(selectedVendorDetails.address1,
                                textDirection: !containsExtendedArabic(
                                        selectedVendorDetails.address1
                                            .toString())
                                    ? pw.TextDirection.ltr
                                    : pw.TextDirection.rtl,
                                style: pw.TextStyle(
                                  font: !containsExtendedArabic(
                                          selectedVendorDetails.address1
                                              .toString())
                                      ? txtBoldFont
                                      : arabicNormalFont,
                                  fontSize: 9,
                                )),
                          if (selectedVendorDetails.address2.isNotEmpty)
                            pw.SizedBox(
                              height: 4,
                            ),
                          if (selectedVendorDetails.address2.isNotEmpty)
                            pw.Text(selectedVendorDetails.address2,
                                textDirection: !containsExtendedArabic(
                                        selectedVendorDetails.address2
                                            .toString())
                                    ? pw.TextDirection.ltr
                                    : pw.TextDirection.rtl,
                                style: pw.TextStyle(
                                  font: !containsExtendedArabic(
                                          selectedVendorDetails.address2
                                              .toString())
                                      ? txtBoldFont
                                      : arabicNormalFont,
                                  fontSize: 9,
                                )),
                          pw.SizedBox(
                            height: 4,
                          ),
                          pw.Text('VendorID: ${selectedVendorDetails.vendorId}',
                              style: pw.TextStyle(
                                font: txtNormalFont,
                                fontSize: 9,
                              )),
                          pw.SizedBox(
                            height: 4,
                          ),
                          pw.Text('VAT No: ${selectedVendorDetails.vatNumber}',
                              style: pw.TextStyle(
                                font: txtNormalFont,
                                fontSize: 9,
                              )),
                          pw.SizedBox(
                            height: 20,
                          ),
                          pw.Text(
                            'Voucher#${dbVoucherData.voucherNo}',
                            style: pw.TextStyle(
                                font: txtBoldFont,
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                      pw.SizedBox(
                        width: 20,
                      ),
                    ])),
          ),
          pw.Container(
            // margin: pw.EdgeInsets.only(left: 20, right: 20, bottom: 20),
            width: double.maxFinite,
            // height: MediaQuery.of(context).size.height - 40,
            // padding: const pw.EdgeInsets.symmetric(vertical: 8),
            decoration: const pw.BoxDecoration(
                border: pw.Border(
                    // bottom: pw.BorderSide(color: PdfColors.black),
                    left: pw.BorderSide(color: PdfColors.black),
                    right: pw.BorderSide(color: PdfColors.black))),
            alignment: pw.Alignment.centerLeft,
            child: pw.Table(
              columnWidths: {
                0: const pw.FlexColumnWidth(4),
                1: const pw.FlexColumnWidth(4),
                2: const pw.FlexColumnWidth(3),
                3: const pw.FlexColumnWidth(2),
                4: const pw.FlexColumnWidth(2),
                5: const pw.FlexColumnWidth(3),
                6: const pw.FlexColumnWidth(3),
              },
              border: const pw.TableBorder(
                top: pw.BorderSide(color: PdfColors.black),
              ),
              children: [
                pw.TableRow(
                    decoration: const pw.BoxDecoration(
                        border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.black),
                    )),
                    children: [
                      pw.Container(
                          height: 40,
                          alignment: pw.Alignment.center,
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(
                                'منتج',
                                textDirection: pw.TextDirection.rtl,
                                style: pw.TextStyle(
                                    font: arabicNormalFont,
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                              pw.SizedBox(
                                height: 4,
                              ),
                              pw.Text('Description',
                                  style: pw.TextStyle(
                                    fontSize: 9,
                                    font: txtNormalFont,
                                  ))
                            ],
                          )),
                      pw.Container(
                          height: 40,
                          alignment: pw.Alignment.center,
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(
                                'باركود',
                                textDirection: pw.TextDirection.rtl,
                                style: pw.TextStyle(
                                    font: arabicNormalFont,
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                              pw.SizedBox(
                                height: 4,
                              ),
                              pw.Text('Barcode',
                                  style: pw.TextStyle(
                                    fontSize: 9,
                                    font: txtNormalFont,
                                  ))
                            ],
                          )),
                      pw.Container(
                          height: 40,
                          alignment: pw.Alignment.center,
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(
                                'التكلفة',
                                textDirection: pw.TextDirection.rtl,
                                style: pw.TextStyle(
                                    font: arabicNormalFont,
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                              pw.SizedBox(
                                height: 4,
                              ),
                              pw.Text('Cost',
                                  style: pw.TextStyle(
                                    fontSize: 9,
                                    font: txtNormalFont,
                                  ))
                            ],
                          )),
                      pw.Container(
                          height: 40,
                          alignment: pw.Alignment.center,
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(
                                'الكمية',
                                textDirection: pw.TextDirection.rtl,
                                style: pw.TextStyle(
                                    font: arabicNormalFont,
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                              pw.SizedBox(
                                height: 4,
                              ),
                              pw.Text('Qty',
                                  style: pw.TextStyle(
                                    font: txtNormalFont,
                                    fontSize: 9,
                                  ))
                            ],
                          )),
                      pw.Container(
                          height: 40,
                          alignment: pw.Alignment.center,
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(
                                'السعر',
                                textDirection: pw.TextDirection.rtl,
                                style: pw.TextStyle(
                                    font: arabicNormalFont,
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                              pw.SizedBox(
                                height: 4,
                              ),
                              pw.Text('Price',
                                  style: pw.TextStyle(
                                    fontSize: 9,
                                    font: txtNormalFont,
                                  ))
                            ],
                          )),
                      pw.Container(
                          height: 40,
                          alignment: pw.Alignment.center,
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(
                                'السعر',
                                textDirection: pw.TextDirection.rtl,
                                style: pw.TextStyle(
                                    font: arabicNormalFont,
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                              pw.SizedBox(
                                height: 4,
                              ),
                              pw.Text('Prcie W/T',
                                  style: pw.TextStyle(
                                    font: txtNormalFont,
                                    fontSize: 9,
                                  ))
                            ],
                          )),
                      pw.Container(
                          height: 40,
                          alignment: pw.Alignment.center,
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(
                                'اجمالي',
                                textDirection: pw.TextDirection.rtl,
                                style: pw.TextStyle(
                                    font: arabicNormalFont,
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                              pw.SizedBox(
                                height: 4,
                              ),
                              pw.Text('Exit Cost',
                                  style: pw.TextStyle(
                                    fontSize: 9,
                                    font: txtNormalFont,
                                  ))
                            ],
                          )),
                    ]),
                for (var v in localVoucherData)
                  if (v.barcode.isNotEmpty)
                    productTile(v, arabicNormalFont, txtNormalFont)
              ],
            ),
          ),
          pw.Container(
            decoration: const pw.BoxDecoration(
                border: pw.Border(
                    left: pw.BorderSide(color: PdfColors.black),
                    right: pw.BorderSide(color: PdfColors.black))),
            height: localVoucherData.length >= 4 ? 20 : 80,
          ),
          pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black)),
              child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    if (dbVoucherData.note.isNotEmpty)
                      pw.Flexible(
                          child: pw.Padding(
                        padding: const pw.EdgeInsets.only(right: 20),
                        child: pw.Text(dbVoucherData.note,
                            textDirection:
                                RegExp(r'^[a-z]+$').hasMatch(dbVoucherData.note)
                                    ? pw.TextDirection.ltr
                                    : pw.TextDirection.rtl,
                            style: pw.TextStyle(
                              font: !containsExtendedArabic(dbVoucherData.note)
                                  ? txtNormalFont
                                  : arabicNormalFont,
                              fontSize: 9,
                            )),
                      )),
                    if (dbVoucherData.note.isEmpty)
                      pw.Expanded(
                          child: pw.SizedBox(
                        width: 10,
                      )),
                    pw.Row(
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Total Quantity',
                                style: pw.TextStyle(
                                  font: txtNormalFont,
                                  fontSize: 9,
                                )),
                            pw.SizedBox(
                              height: 4,
                            ),
                            pw.Text('Total Price W/T',
                                style: pw.TextStyle(
                                  font: txtNormalFont,
                                  fontSize: 9,
                                )),
                            pw.SizedBox(
                              height: 4,
                            ),
                            pw.Text('Discount %',
                                style: pw.TextStyle(
                                  font: txtNormalFont,
                                  fontSize: 9,
                                )),
                            pw.SizedBox(
                              height: 4,
                            ),
                            pw.Text('Discount \$',
                                style: pw.TextStyle(
                                  font: txtNormalFont,
                                  fontSize: 9,
                                )),
                            pw.SizedBox(
                              height: 4,
                            ),
                            pw.Text('Before VAT',
                                style: pw.TextStyle(
                                  font: txtNormalFont,
                                  fontSize: 9,
                                )),
                            pw.SizedBox(
                              height: 4,
                            ),
                            pw.Text('VAT %',
                                style: pw.TextStyle(
                                  font: txtNormalFont,
                                  fontSize: 9,
                                )),
                            pw.SizedBox(
                              height: 4,
                            ),
                            pw.Text('VAT \$',
                                style: pw.TextStyle(
                                  font: txtNormalFont,
                                  fontSize: 9,
                                )),
                            pw.SizedBox(
                              height: 20,
                            ),
                            pw.Text(
                              'Voucher Total',
                              style: pw.TextStyle(
                                  font: txtBoldFont,
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold),
                            ),
                          ],
                        ),
                        pw.SizedBox(width: 20),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(dbVoucherData.qtyRecieved,
                                style: pw.TextStyle(
                                  font: txtNormalFont,
                                  fontSize: 9,
                                )),
                            pw.SizedBox(
                              height: 4,
                            ),
                            pw.Text(
                                double.parse(totalPriceWt).toStringAsFixed(2),
                                style: pw.TextStyle(
                                  font: txtNormalFont,
                                  fontSize: 9,
                                )),
                            pw.SizedBox(
                              height: 4,
                            ),
                            pw.Text(
                                dbVoucherData.discountPercentage.isEmpty
                                    ? '0'
                                    : dbVoucherData.discountPercentage,
                                style: pw.TextStyle(
                                  font: txtNormalFont,
                                  fontSize: 9,
                                )),
                            pw.SizedBox(
                              height: 4,
                            ),
                            pw.Text(
                                double.parse(dbVoucherData.discountValue)
                                    .toStringAsFixed(2),
                                style: pw.TextStyle(
                                  font: txtNormalFont,
                                  fontSize: 9,
                                )),
                            pw.SizedBox(
                              height: 4,
                            ),
                            pw.Text(calculateVoucherTotal(),
                                style: pw.TextStyle(
                                  font: txtNormalFont,
                                  fontSize: 9,
                                )),
                            pw.SizedBox(
                              height: 4,
                            ),
                            pw.Text(dbVoucherData.tax,
                                style: pw.TextStyle(
                                  font: txtNormalFont,
                                  fontSize: 9,
                                )),
                            pw.SizedBox(
                              height: 4,
                            ),
                            pw.Text(
                                (double.parse(dbVoucherData.voucherTotal) -
                                        double.parse(calculateVoucherTotal()))
                                    .toStringAsFixed(2),
                                style: pw.TextStyle(
                                  font: txtNormalFont,
                                  fontSize: 9,
                                )),
                            pw.SizedBox(
                              height: 20,
                            ),
                            pw.Text(
                              double.parse(dbVoucherData.voucherTotal)
                                  .toStringAsFixed(2),
                              style: pw.TextStyle(
                                  font: txtBoldFont,
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold),
                            ),
                          ],
                        ),
                        pw.SizedBox(width: 20),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                              'الكمية',
                              textDirection: pw.TextDirection.rtl,
                              style: pw.TextStyle(
                                  fontSize: 9,
                                  font: arabicNormalFont,
                                  fontWeight: pw.FontWeight.bold),
                            ),
                            pw.SizedBox(
                              height: 3,
                            ),
                            pw.Text(
                              'الاجملي قبل الخصم',
                              textDirection: pw.TextDirection.rtl,
                              style: pw.TextStyle(
                                  fontSize: 9,
                                  font: arabicNormalFont,
                                  fontWeight: pw.FontWeight.bold),
                            ),
                            pw.SizedBox(
                              height: 3,
                            ),
                            pw.Text(
                              'خصم %',
                              textDirection: pw.TextDirection.rtl,
                              style: pw.TextStyle(
                                  fontSize: 9,
                                  font: arabicNormalFont,
                                  fontWeight: pw.FontWeight.bold),
                            ),
                            pw.SizedBox(
                              height: 3,
                            ),
                            pw.Text(
                              'خصم \$',
                              textDirection: pw.TextDirection.rtl,
                              style: pw.TextStyle(
                                  fontSize: 9,
                                  font: arabicNormalFont,
                                  fontWeight: pw.FontWeight.bold),
                            ),
                            pw.SizedBox(
                              height: 3,
                            ),
                            pw.Text(
                              'اجمالي قبل الضريبة',
                              textDirection: pw.TextDirection.rtl,
                              style: pw.TextStyle(
                                  fontSize: 9,
                                  font: arabicNormalFont,
                                  fontWeight: pw.FontWeight.bold),
                            ),
                            pw.SizedBox(
                              height: 3,
                            ),
                            pw.Text(
                              'الضريبة %',
                              textDirection: pw.TextDirection.rtl,
                              style: pw.TextStyle(
                                  fontSize: 9,
                                  font: arabicNormalFont,
                                  fontWeight: pw.FontWeight.bold),
                            ),
                            pw.SizedBox(
                              height: 3,
                            ),
                            pw.Text(
                              'الضريبة \$',
                              textDirection: pw.TextDirection.rtl,
                              style: pw.TextStyle(
                                  fontSize: 9,
                                  font: arabicNormalFont,
                                  fontWeight: pw.FontWeight.bold),
                            ),
                            pw.SizedBox(
                              height: 20,
                            ),
                            pw.Text(
                              'الاجمالي',
                              textDirection: pw.TextDirection.rtl,
                              style: pw.TextStyle(
                                  font: arabicNormalFont,
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ]))
        ];
      }));

  await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save());
}

productTile(LocalVoucherData v, arabicNormalFont, txtNormalFont) {
  return pw.TableRow(
      decoration: const pw.BoxDecoration(
          border: pw.Border(
        bottom: pw.BorderSide(width: .5, color: PdfColors.grey),
      )),
      children: [
        pw.Container(
            height: 40,
            alignment: pw.Alignment.center,
            padding: const pw.EdgeInsets.only(left: 5),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(v.itemCode,
                    style: pw.TextStyle(
                      font: txtNormalFont,
                      fontSize: 9,
                    )),
                pw.Text(v.productName,
                    textDirection: RegExp(r'^[a-z]+$').hasMatch(v.productName)
                        ? pw.TextDirection.ltr
                        : pw.TextDirection.rtl,
                    style: pw.TextStyle(
                      font: RegExp(r'^[a-z]+$').hasMatch(v.productName)
                          ? txtNormalFont
                          : arabicNormalFont,
                      fontSize: 9,
                    )),
              ],
            )),
        pw.Container(
            height: 40,
            alignment: pw.Alignment.center,
            child: pw.Text(v.barcode,
                style: pw.TextStyle(
                  font: txtNormalFont,
                  fontSize: 9,
                ))),
        pw.Container(
            height: 40,
            alignment: pw.Alignment.center,
            child: pw.Text(double.parse(v.cost).toStringAsFixed(2),
                style: pw.TextStyle(
                  fontSize: 9,
                  font: txtNormalFont,
                ))),
        pw.Container(
            height: 40,
            alignment: pw.Alignment.center,
            child: pw.Text(v.qty,
                style: pw.TextStyle(
                  font: txtNormalFont,
                  fontSize: 9,
                ))),
        pw.Container(
            height: 40,
            alignment: pw.Alignment.center,
            child: pw.Text(double.parse(v.price).toStringAsFixed(2),
                style: pw.TextStyle(
                  font: txtNormalFont,
                  fontSize: 9,
                ))),
        pw.Container(
            height: 40,
            alignment: pw.Alignment.center,
            child: pw.Text(double.parse(v.priceWt).toStringAsFixed(2),
                style: pw.TextStyle(
                  font: txtNormalFont,
                  fontSize: 9,
                ))),
        pw.Container(
            height: 40,
            alignment: pw.Alignment.center,
            child: pw.Text(double.parse(v.extCost).toStringAsFixed(2),
                style: pw.TextStyle(
                  font: txtNormalFont,
                  fontSize: 9,
                ))),
      ]);
}
