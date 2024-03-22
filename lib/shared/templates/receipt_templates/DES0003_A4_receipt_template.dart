import 'package:barcode_image/barcode_image.dart';
import 'package:bitpro_hive/model/store_data.dart';
import 'package:bitpro_hive/shared/check_contain_arabic_letters.dart';
import 'package:intl/intl.dart';
import 'package:bitpro_hive/model/receipt/db_receipt_data.dart';
import 'package:bitpro_hive/shared/templates/receipt_templates/e_invoice_generator.dart';
import 'package:bitpro_hive/shared/templates/receipt_templates/print_receipt.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../model/customer_data.dart';

des0003A4ReceiptTemplate({
  required image,
  required userData,
  required userSettingsData,
  required userPrintingData,
  required DbReceiptData dbReceiptData,
  required txtBoldFont,
  required arabicLightFont,
  required arabicNormalFont,
  required vatPercentage,
  required taxValue,
  required txtNormalFont,
  required StoreData selectedStoreData,
  CustomerData? selectedCustomerData,
}) {
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
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.SizedBox(
                              height: 10,
                            ),
                            if (userSettingsData != null)
                              pw.Text(
                                userSettingsData['companyName'],
                                textAlign: pw.TextAlign.left,
                                textDirection: !containsExtendedArabic(
                                        userSettingsData['companyName']
                                            .toString())
                                    ? pw.TextDirection.ltr
                                    : pw.TextDirection.rtl,
                                style: pw.TextStyle(
                                    font: !containsExtendedArabic(
                                            userSettingsData['companyName']
                                                .toString())
                                        ? txtBoldFont
                                        : arabicNormalFont,
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                            pw.SizedBox(
                              height: 10,
                            ),
                            pw.Text(
                              selectedStoreData.address1,
                              textAlign: pw.TextAlign.left,
                              textDirection: !containsExtendedArabic(
                                      selectedStoreData.address1.toString())
                                  ? pw.TextDirection.ltr
                                  : pw.TextDirection.rtl,
                              style: pw.TextStyle(
                                font: !containsExtendedArabic(
                                        selectedStoreData.address1.toString())
                                    ? txtNormalFont
                                    : arabicLightFont,
                                fontSize: 8,
                              ),
                            ),
                            pw.Text(
                              'Phone : ${selectedStoreData.phone1}',
                              style: pw.TextStyle(
                                fontSize: 8,
                                font: txtNormalFont,
                              ),
                            ),
                            pw.Text(
                              'E-mail : ${selectedStoreData.email}',
                              style: pw.TextStyle(
                                fontSize: 8,
                                font: txtNormalFont,
                              ),
                            ),
                            pw.Text(
                              'VAT Number : ${selectedStoreData.vatNumber}',
                              style: pw.TextStyle(
                                fontSize: 8,
                                font: txtNormalFont,
                              ),
                            ),
                            pw.Row(children: [
                              pw.Text(
                                'Bank Name : ',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  font: txtNormalFont,
                                ),
                              ),
                              pw.Text(
                                selectedStoreData.bankName,
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  font: txtNormalFont,
                                ),
                              ),
                            ]),
                            pw.Text(
                              'Account Number : ${selectedStoreData.ibanAccountNumber}',
                              style: pw.TextStyle(
                                fontSize: 8,
                                font: txtNormalFont,
                              ),
                            ),
                          ],
                        ),
                        pw.Expanded(child: pw.SizedBox(width: 20)),
                        if (dbReceiptData.receiptType != 'Regular')
                          pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.end,
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Container(
                                  width: 150,
                                  decoration: pw.BoxDecoration(
                                      color: const PdfColor.fromInt(0xffa6a6a3),
                                      border: pw.Border.all(
                                        width: 0.2,
                                      )),
                                  padding: const pw.EdgeInsets.symmetric(
                                      vertical: 5),
                                  alignment: pw.Alignment.center,
                                  child: pw.Text(
                                    'Return Invoice',
                                    style: pw.TextStyle(
                                      fontSize: 10,
                                      font: txtBoldFont,
                                    ),
                                  ),
                                )
                              ]),
                        pw.Expanded(child: pw.SizedBox(width: 20)),
                        pw.Container(
                          alignment: pw.Alignment.center,
                          margin: const pw.EdgeInsets.only(right: 20),
                          width: 170,
                          height: 90,
                          child: pw.Image(image,
                              width: 170, height: 90, fit: pw.BoxFit.contain),
                        ),
                      ]),
                  if (userPrintingData != null) pw.SizedBox(height: 15),
                  if (userPrintingData != null)
                    pw.Container(
                      padding: const pw.EdgeInsets.all(2),
                      width: double.maxFinite,
                      decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                            width: 0.2,
                          ),
                          color: const PdfColor.fromInt(0xffa6a6a3)),
                      child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text(
                              userPrintingData['receiptTitleArb'],
                              textDirection: pw.TextDirection.rtl,
                              style: pw.TextStyle(
                                  fontSize: 10,
                                  font: arabicNormalFont,
                                  fontWeight: pw.FontWeight.bold),
                            ),
                            pw.SizedBox(width: 10),
                            pw.Text(
                              userPrintingData['receiptTitleEng'],
                              style: pw.TextStyle(
                                  fontSize: 10,
                                  fontBold: txtBoldFont,
                                  fontWeight: pw.FontWeight.bold),
                            ),
                          ]),
                    ),
                  pw.SizedBox(
                    height: 5,
                  ),
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(width: 0.2),
                    ),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Container(
                                width: 350,
                                padding: const pw.EdgeInsets.all(3),
                                decoration: pw.BoxDecoration(
                                    border: pw.Border.all(width: 0.2),
                                    color: const PdfColor.fromInt(0xffa6a6a3)),
                                child: pw.Text(
                                  'Customer Details',
                                  style: pw.TextStyle(
                                      font: txtBoldFont, fontSize: 8),
                                )),
                            pw.Container(
                              width: 350,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                width: 0.2,
                              )),
                              padding: const pw.EdgeInsets.only(
                                  left: 8, top: 10, right: 15, bottom: 15),
                              child: pw.Row(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    if (selectedCustomerData != null)
                                      pw.SizedBox(
                                          width: 260,
                                          child: pw.Column(
                                              crossAxisAlignment:
                                                  pw.CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  pw.MainAxisAlignment.start,
                                              children: [
                                                if (selectedCustomerData
                                                    .customerName.isNotEmpty)
                                                  pw.Text(
                                                    selectedCustomerData
                                                        .customerName,
                                                    textDirection:
                                                        !containsExtendedArabic(
                                                                selectedCustomerData
                                                                    .customerName
                                                                    .toString())
                                                            ? pw.TextDirection
                                                                .ltr
                                                            : pw.TextDirection
                                                                .rtl,
                                                    style: pw.TextStyle(
                                                        font: !containsExtendedArabic(
                                                                selectedCustomerData
                                                                    .customerName
                                                                    .toString())
                                                            ? txtNormalFont
                                                            : arabicLightFont,
                                                        fontSize: 8),
                                                  ),
                                                if (selectedCustomerData
                                                    .customerName.isNotEmpty)
                                                  pw.SizedBox(height: 5),
                                                if (selectedCustomerData
                                                    .address1.isNotEmpty)
                                                  pw.Text(
                                                    selectedCustomerData
                                                        .address1,
                                                    textDirection:
                                                        !containsExtendedArabic(
                                                                selectedCustomerData
                                                                    .address1
                                                                    .toString())
                                                            ? pw.TextDirection
                                                                .ltr
                                                            : pw.TextDirection
                                                                .rtl,
                                                    style: pw.TextStyle(
                                                        font: !containsExtendedArabic(
                                                                selectedCustomerData
                                                                    .address1
                                                                    .toString())
                                                            ? txtNormalFont
                                                            : arabicLightFont,
                                                        fontSize: 8),
                                                  ),
                                                if (selectedCustomerData
                                                    .address1.isNotEmpty)
                                                  pw.SizedBox(height: 5),
                                                if (selectedCustomerData
                                                    .address2.isNotEmpty)
                                                  pw.Text(
                                                    selectedCustomerData
                                                        .address2,
                                                    textDirection:
                                                        !containsExtendedArabic(
                                                                selectedCustomerData
                                                                    .address2
                                                                    .toString())
                                                            ? pw.TextDirection
                                                                .ltr
                                                            : pw.TextDirection
                                                                .rtl,
                                                    style: pw.TextStyle(
                                                        font: !containsExtendedArabic(
                                                                selectedCustomerData
                                                                    .address2
                                                                    .toString())
                                                            ? txtNormalFont
                                                            : arabicLightFont,
                                                        fontSize: 8),
                                                  ),
                                                if (selectedCustomerData
                                                    .address2.isNotEmpty)
                                                  pw.SizedBox(height: 5),
                                                if (selectedCustomerData
                                                    .phone1.isNotEmpty)
                                                  pw.Row(children: [
                                                    pw.Text(
                                                      'Phone 1 : ',
                                                      style: pw.TextStyle(
                                                        font: txtNormalFont,
                                                        fontSize: 8,
                                                      ),
                                                    ),
                                                    pw.SizedBox(width: 10),
                                                    pw.Text(
                                                      selectedCustomerData
                                                          .phone1,
                                                      style: pw.TextStyle(
                                                        font: txtNormalFont,
                                                        fontSize: 8,
                                                      ),
                                                    ),
                                                  ]),
                                                if (selectedCustomerData
                                                    .phone1.isNotEmpty)
                                                  pw.SizedBox(height: 5),
                                                if (selectedCustomerData
                                                    .email.isNotEmpty)
                                                  pw.Row(children: [
                                                    pw.Text(
                                                      'Email : ',
                                                      style: pw.TextStyle(
                                                        font: txtNormalFont,
                                                        fontSize: 8,
                                                      ),
                                                    ),
                                                    pw.SizedBox(width: 10),
                                                    pw.Text(
                                                      selectedCustomerData
                                                          .email,
                                                      style: pw.TextStyle(
                                                        font: txtNormalFont,
                                                        fontSize: 8,
                                                      ),
                                                    ),
                                                  ]),
                                                if (selectedCustomerData
                                                    .email.isNotEmpty)
                                                  pw.SizedBox(height: 5),
                                                if (selectedCustomerData
                                                    .vatNo.isNotEmpty)
                                                  pw.Row(children: [
                                                    pw.Text(
                                                      'Vat No. : ',
                                                      style: pw.TextStyle(
                                                        font: txtNormalFont,
                                                        fontSize: 8,
                                                      ),
                                                    ),
                                                    pw.SizedBox(width: 10),
                                                    pw.Text(
                                                      selectedCustomerData
                                                          .vatNo,
                                                      style: pw.TextStyle(
                                                        font: txtNormalFont,
                                                        fontSize: 8,
                                                      ),
                                                    ),
                                                  ])
                                              ])),
                                    pw.Expanded(
                                        child: pw.SizedBox(
                                      width: 10,
                                    )),
                                    pw.Align(
                                        alignment: pw.Alignment.topCenter,
                                        child: pw.SvgImage(
                                            svg: buildBarcode(
                                                height: 90,
                                                width: 70,
                                                Barcode.qrCode(),
                                                getQrCodeContent(
                                                  sellerName:
                                                      userSettingsData == null
                                                          ? ''
                                                          : userSettingsData[
                                                              'companyName'],
                                                  sellerTRN: selectedStoreData
                                                      .vatNumber,
                                                  totalWithVat:
                                                      dbReceiptData.subTotal,
                                                  vatPrice: taxValue,
                                                )))),
                                  ]),
                            ),
                          ],
                        ),
                        pw.Expanded(
                          child: pw.Container(
                              child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                pw.Container(
                                    width: double.maxFinite,
                                    padding: const pw.EdgeInsets.all(3),
                                    decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          width: 0.2,
                                        ),
                                        color:
                                            const PdfColor.fromInt(0xffa6a6a3)),
                                    child: pw.Text(
                                      'Invoice Details',
                                      style: pw.TextStyle(
                                          font: txtBoldFont, fontSize: 8),
                                    )),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Row(children: [
                                    pw.Column(
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Row(children: [
                                            pw.Text(
                                              'فاتورة ',
                                              textDirection:
                                                  pw.TextDirection.rtl,
                                              style: pw.TextStyle(
                                                fontSize: 8,
                                                font: arabicNormalFont,
                                              ),
                                            ),
                                            pw.SizedBox(width: 3),
                                            pw.Text(
                                              'Invoice #',
                                              style: pw.TextStyle(
                                                fontSize: 8,
                                                font: txtNormalFont,
                                              ),
                                            ),
                                          ]),
                                          pw.SizedBox(height: 5),
                                          pw.Row(children: [
                                            pw.Text(
                                              'تاريخ ',
                                              textDirection:
                                                  pw.TextDirection.rtl,
                                              style: pw.TextStyle(
                                                fontSize: 8,
                                                font: arabicNormalFont,
                                              ),
                                            ),
                                            pw.SizedBox(width: 3),
                                            pw.Text(
                                              'Created Date : ',
                                              style: pw.TextStyle(
                                                fontSize: 8,
                                                font: txtNormalFont,
                                              ),
                                            ),
                                          ]),
                                          pw.SizedBox(height: 5),
                                          pw.Row(children: [
                                            pw.Text(
                                              'مستخدم ',
                                              textDirection:
                                                  pw.TextDirection.rtl,
                                              style: pw.TextStyle(
                                                fontSize: 8,
                                                font: arabicNormalFont,
                                              ),
                                            ),
                                            pw.SizedBox(width: 3),
                                            pw.Text(
                                              'User :',
                                              style: pw.TextStyle(
                                                fontSize: 8,
                                                font: txtNormalFont,
                                              ),
                                            ),
                                          ]),
                                          if (dbReceiptData
                                              .referenceNo.isNotEmpty)
                                            pw.SizedBox(height: 5),
                                          if (dbReceiptData
                                              .referenceNo.isNotEmpty)
                                            pw.Text(
                                              'Reference No',
                                              style: pw.TextStyle(
                                                fontSize: 8,
                                                font: txtNormalFont,
                                              ),
                                            ),
                                        ]),
                                    pw.SizedBox(width: 1),
                                    pw.Column(
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Text(
                                            dbReceiptData.receiptNo,
                                            style: pw.TextStyle(
                                              fontSize: 8,
                                              font: txtNormalFont,
                                            ),
                                          ),
                                          pw.SizedBox(height: 5),
                                          pw.Text(
                                            DateFormat('dd-MM-yyyy HH:mm a')
                                                .format(
                                                    dbReceiptData.createdDate),
                                            style: pw.TextStyle(
                                              fontSize: 8,
                                              font: txtNormalFont,
                                            ),
                                          ),
                                          pw.SizedBox(height: 5),
                                          pw.Text(
                                            '${userData.username}',
                                            style: pw.TextStyle(
                                              fontSize: 8,
                                              font: txtNormalFont,
                                            ),
                                          ),
                                          if (dbReceiptData
                                              .referenceNo.isNotEmpty)
                                            pw.SizedBox(height: 5),
                                          if (dbReceiptData
                                              .referenceNo.isNotEmpty)
                                            pw.Text(
                                              dbReceiptData.referenceNo,
                                              style: pw.TextStyle(
                                                fontSize: 8,
                                                font: txtNormalFont,
                                              ),
                                            ),
                                        ]),
                                  ]),
                                ),
                                pw.Padding(
                                    padding: const pw.EdgeInsets.all(8),
                                    child: pw.SvgImage(
                                        svg: buildBarcode(
                                      height: 30,
                                      width: 80,
                                      Barcode.code128(
                                          useCode128B: false,
                                          useCode128C: false),
                                      dbReceiptData.receiptNo.toString(),
                                      filename: 'code-128a',
                                    ))),
                                pw.SizedBox(height: 2),
                              ])),
                        )
                      ],
                    ),
                  ),
                  pw.SizedBox(
                    height: 7,
                  ),
                ]),
            pw.Container(
              width: double.maxFinite,
              alignment: pw.Alignment.centerLeft,
              child: pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(1.5),
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(7),
                  3: const pw.FlexColumnWidth(1),
                  4: const pw.FlexColumnWidth(2.5),
                  5: const pw.FlexColumnWidth(2.5)
                },
                children: [
                  pw.TableRow(
                      decoration: const pw.BoxDecoration(
                          border: pw.Border(
                        bottom:
                            pw.BorderSide(width: 0.2, color: PdfColors.black),
                      )),
                      children: [
                        pw.Container(
                            height: 25,
                            decoration: pw.BoxDecoration(
                                color: const PdfColor.fromInt(0xffa6a6a3),
                                border: pw.Border.all(
                                  width: 0.2,
                                  color: PdfColors.black,
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
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 2,
                                ),
                                pw.Text('Barcode',
                                    style: pw.TextStyle(
                                        fontSize: 8, font: txtBoldFont))
                              ],
                            )),
                        pw.Container(
                            height: 25,
                            decoration: pw.BoxDecoration(
                                color: const PdfColor.fromInt(0xffa6a6a3),
                                border: pw.Border.all(
                                    width: 0.2, color: PdfColors.black)),
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(
                                  'الصنف',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    font: arabicNormalFont,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 2,
                                ),
                                pw.Text('Pr. code',
                                    style: pw.TextStyle(
                                        fontSize: 8, font: txtBoldFont))
                              ],
                            )),
                        pw.Container(
                            height: 25,
                            decoration: pw.BoxDecoration(
                                color: const PdfColor.fromInt(0xffa6a6a3),
                                border: pw.Border.all(
                                    width: 0.2, color: PdfColors.black)),
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(
                                  'اسم الصنف',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    font: arabicNormalFont,
                                    fontSize: 8,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 2,
                                ),
                                pw.Text('Product / Service Description',
                                    style: pw.TextStyle(
                                        fontSize: 8, font: txtBoldFont))
                              ],
                            )),
                        pw.Container(
                            decoration: pw.BoxDecoration(
                                color: const PdfColor.fromInt(0xffa6a6a3),
                                border: pw.Border.all(
                                    width: 0.2, color: PdfColors.black)),
                            height: 25,
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(
                                  'كمية',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    font: arabicNormalFont,
                                    fontSize: 8,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 2,
                                ),
                                pw.Text('Qty',
                                    style: pw.TextStyle(
                                        fontSize: 8, font: txtBoldFont))
                              ],
                            )),
                        pw.Container(
                            height: 25,
                            decoration: pw.BoxDecoration(
                                color: const PdfColor.fromInt(0xffa6a6a3),
                                border: pw.Border.all(
                                    width: 0.2, color: PdfColors.black)),
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(
                                  'السعر',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    font: arabicNormalFont,
                                    fontSize: 8,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 2,
                                ),
                                pw.Text('Unit Price',
                                    style: pw.TextStyle(
                                        fontSize: 8, font: txtBoldFont))
                              ],
                            )),
                        pw.Container(
                            height: 25,
                            decoration: pw.BoxDecoration(
                                color: const PdfColor.fromInt(0xffa6a6a3),
                                border: pw.Border.all(
                                    width: 0.2, color: PdfColors.black)),
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(
                                  'اجمالي',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    font: arabicNormalFont,
                                    fontSize: 8,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 2,
                                ),
                                pw.Text('Total',
                                    style: pw.TextStyle(
                                        fontSize: 8, font: txtBoldFont))
                              ],
                            )),
                      ]),
                ],
              ),
            ),
            for (var localReceiptData in dbReceiptData.selectedItems)
              productTile(
                  txtNormalFont,
                  localReceiptData,
                  arabicLightFont,
                  vatPercentage,
                  dbReceiptData.selectedItems.indexOf(localReceiptData) ==
                      dbReceiptData.selectedItems.length - 1,
                  dbReceiptData),
            pw.Container(
                width: double.maxFinite,
                alignment: pw.Alignment.centerLeft,
                child: pw.Table(columnWidths: {
                  0: const pw.FlexColumnWidth(1.5),
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(7),
                  3: const pw.FlexColumnWidth(1),
                  4: const pw.FlexColumnWidth(2.5),
                  5: const pw.FlexColumnWidth(2.5)
                }, children: [
                  pw.TableRow(
                      verticalAlignment: pw.TableCellVerticalAlignment.top,
                      children: [
                        pw.Container(
                          decoration: const pw.BoxDecoration(
                              border: pw.Border(
                            bottom: pw.BorderSide(
                                width: 0.2, color: PdfColors.white),
                            left: pw.BorderSide(
                                width: 0.2, color: PdfColors.white),
                            right: pw.BorderSide(
                                width: 0.2, color: PdfColors.white),
                            top: pw.BorderSide(
                                width: 0.2, color: PdfColors.black),
                          )),
                          height: 5,
                          alignment: pw.Alignment.center,
                        ),
                        pw.Container(
                          decoration: const pw.BoxDecoration(
                              border: pw.Border(
                            bottom: pw.BorderSide(
                                width: 0.2, color: PdfColors.white),
                            left: pw.BorderSide(
                                width: 0.2, color: PdfColors.white),
                            right: pw.BorderSide(
                                width: 0.2, color: PdfColors.white),
                            top: pw.BorderSide(
                                width: 0.2, color: PdfColors.black),
                          )),
                          height: 5,
                          alignment: pw.Alignment.center,
                        ),
                        pw.Container(
                          decoration: const pw.BoxDecoration(
                              border: pw.Border(
                            bottom: pw.BorderSide(
                                width: 0.2, color: PdfColors.white),
                            left: pw.BorderSide(
                                width: 0.2, color: PdfColors.white),
                            right: pw.BorderSide(
                                width: 0.2, color: PdfColors.white),
                            top: pw.BorderSide(
                                width: 0.2, color: PdfColors.black),
                          )),
                          height: 5,
                          alignment: pw.Alignment.center,
                        ),
                        pw.Container(
                          decoration: const pw.BoxDecoration(
                              border: pw.Border(
                            bottom: pw.BorderSide(
                                width: 0.2, color: PdfColors.white),
                            left: pw.BorderSide(
                                width: 0.2, color: PdfColors.white),
                            right: pw.BorderSide(
                                width: 0.2, color: PdfColors.white),
                            top: pw.BorderSide(
                                width: 0.2, color: PdfColors.black),
                          )),
                          height: 5,
                          alignment: pw.Alignment.center,
                        ),
                        pw.Container(
                          decoration: const pw.BoxDecoration(
                              border: pw.Border(
                            bottom: pw.BorderSide(
                                width: 0.2, color: PdfColors.white),
                            left: pw.BorderSide(
                                width: 0.2, color: PdfColors.white),
                            right: pw.BorderSide(
                                width: 0.2, color: PdfColors.white),
                            top: pw.BorderSide(
                                width: 0.2, color: PdfColors.black),
                          )),
                          height: 5,
                          alignment: pw.Alignment.center,
                        ),
                        pw.Container(
                          decoration: const pw.BoxDecoration(
                              border: pw.Border(
                            bottom: pw.BorderSide(
                                width: 0.2, color: PdfColors.white),
                            left: pw.BorderSide(
                                width: 0.2, color: PdfColors.white),
                            right: pw.BorderSide(
                                width: 0.2, color: PdfColors.white),
                            top: pw.BorderSide(
                                width: 0.2, color: PdfColors.black),
                          )),
                          height: 5,
                          alignment: pw.Alignment.center,
                        ),
                      ]),
                  tableTotalTiles(txtNormalFont, arabicLightFont,
                      dbReceiptData.selectedItems, 1, dbReceiptData),
                ])),
            tableTotalTiles(txtNormalFont, arabicLightFont,
                dbReceiptData.selectedItems, 2, dbReceiptData),
            tableTotalTiles(txtNormalFont, arabicLightFont,
                dbReceiptData.selectedItems, 3, dbReceiptData),
            tableTotalTiles(txtNormalFont, arabicLightFont,
                dbReceiptData.selectedItems, 4, dbReceiptData),
            tableTotalTiles(txtNormalFont, arabicLightFont,
                dbReceiptData.selectedItems, 5, dbReceiptData),
            pw.SizedBox(height: 10),
            if (userPrintingData != null &&
                (userPrintingData['receiptFotterEng'].isNotEmpty ||
                    userPrintingData['receiptFotterArb'].isNotEmpty))
              pw.Container(
                decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                  width: 0.2,
                )),
                padding: const pw.EdgeInsets.all(10),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Expanded(
                        child: pw.Text(userPrintingData['receiptFotterEng'],
                            style: pw.TextStyle(
                                fontSize: 8, font: txtNormalFont))),
                    pw.Expanded(
                        child: pw.SizedBox(
                      width: 20,
                    )),
                    pw.Expanded(
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
                  ],
                ),
              ),
            pw.SizedBox(
              height: 10,
            ),
            pw.Text('Receiver Signature',
                style: pw.TextStyle(fontSize: 8, font: txtNormalFont)),
            pw.SizedBox(
              height: 25,
            ),
          ]));
}

double calculateDiscountPercentage(double t, double dist) {
  double disPer = dist / (t / 100);

  return disPer;
}

String calculateTaxValue(double t, String tax) {
  //tax
  double taxValue = 0;
  if (tax.isNotEmpty) {
    double texPer = double.tryParse(tax) ?? 0;

    double tx = 1 + (texPer / 100);

    if (tx != 0) taxValue = t - (t / tx);
  }

  return taxValue.toStringAsFixed(2);
}

String calculateVatIncludedValue(double t, String tax) {
  //tax
  double taxValue = 0;
  if (tax.isNotEmpty) {
    double texPer = double.tryParse(tax) ?? 0;

    double tx = texPer / 100;

    if (tx != 0) taxValue = t * tx;
  }

  return taxValue.toStringAsFixed(2);
}

tableTotalTiles(txtNormalFont, arabicLightFont, items, tileNo,
    DbReceiptData dbReceiptData) {
  double totalQty = 0;
  double subtotal = 0;
  //discount value & percentage
  double totalDiscountValue = 0;
  double totalDiscountPer = 0;

  for (var i in items) {
    totalQty += double.tryParse(i['qty']) ?? 0;
    double unitPrice = double.parse(i['orgPrice']) -
        double.parse(calculateTaxValue(
            double.parse(i['orgPrice']), dbReceiptData.taxPer));
    subtotal += unitPrice * double.parse(i['qty']);
  }

  // discount calculation
  totalDiscountValue = double.parse(dbReceiptData.discountValue) -
      double.parse(calculateTaxValue(
          double.parse(dbReceiptData.discountValue), dbReceiptData.taxPer));
  //dicount percentage
  totalDiscountPer = calculateDiscountPercentage(subtotal, totalDiscountValue);

  //
  double totalAfterDiscount = 0;
  double total = 0;
  totalAfterDiscount = subtotal - totalDiscountValue;
  total = totalAfterDiscount +
      double.parse(
          calculateVatIncludedValue(totalAfterDiscount, dbReceiptData.taxPer));

  if (tileNo == 1) {
    return pw.TableRow(
        verticalAlignment: pw.TableCellVerticalAlignment.top,
        children: [
          pw.Container(
            decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xffa6a6a3),
                border: pw.Border(
                  bottom: pw.BorderSide(width: 0.2, color: PdfColors.black),
                  left: pw.BorderSide(width: 0.2, color: PdfColors.black),
                  top: pw.BorderSide(width: 0.2, color: PdfColors.black),
                )),
            height: 18,
            width: 100,
            alignment: pw.Alignment.centerLeft,
            padding: const pw.EdgeInsets.all(2),
          ),
          pw.Container(
            decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xffa6a6a3),
                border: pw.Border(
                  bottom: pw.BorderSide(width: 0.2, color: PdfColors.black),
                  top: pw.BorderSide(width: 0.2, color: PdfColors.black),
                )),
            height: 18,
            alignment: pw.Alignment.center,
            padding: const pw.EdgeInsets.all(2),
          ),
          pw.Container(
            decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xffa6a6a3),
                border: pw.Border(
                  bottom: pw.BorderSide(width: 0.2, color: PdfColors.black),
                  top: pw.BorderSide(width: 0.2, color: PdfColors.black),
                )),
            height: 18,
            width: 100,
            padding: const pw.EdgeInsets.all(2),
          ),
          pw.Container(
              decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xffa6a6a3),
                  border: pw.Border.all(width: 0.2, color: PdfColors.black)),
              height: 18,
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.all(2),
              child: pw.Text(
                totalQty.toStringAsFixed(0),
                style: pw.TextStyle(font: txtNormalFont, fontSize: 8),
              )),
          pw.Container(
              decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xffa6a6a3),
                  border: pw.Border.all(width: 0.2, color: PdfColors.black)),
              height: 18,
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.all(2),
              child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text('SubTotal',
                        style: pw.TextStyle(fontSize: 8, font: txtNormalFont)),
                    pw.SizedBox(
                      width: 5,
                    ),
                    pw.Text(
                      'الاجمالي',
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(
                          font: arabicLightFont,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(
                      width: 5,
                    ),
                  ])),
          pw.Container(
              decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xffa6a6a3),
                  border: pw.Border.all(width: 0.2, color: PdfColors.black)),
              height: 18,
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.all(2),
              child: pw.Text(subtotal.toStringAsFixed(2),
                  style: pw.TextStyle(
                    fontSize: 8,
                    font: txtNormalFont,
                  ))),
        ]);
  } else if (tileNo == 2) {
    return pw.Row(children: [
      pw.Expanded(
        child: pw.Container(
            decoration: const pw.BoxDecoration(
                border: pw.Border(
              left: pw.BorderSide(width: 0.2, color: PdfColors.black),
              bottom: pw.BorderSide(width: 0.2, color: PdfColors.black),
              top: pw.BorderSide(width: 0.2, color: PdfColors.black),
            )),
            height: 18,
            width: double.maxFinite,
            alignment: pw.Alignment.center,
            padding: const pw.EdgeInsets.all(3),
            child:
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
              pw.Text('Discount(${totalDiscountPer.toStringAsFixed(2)}%)',
                  style: pw.TextStyle(fontSize: 8, font: txtNormalFont)),
              pw.SizedBox(
                width: 5,
              ),
              pw.Text(
                "خصم",
                textDirection: pw.TextDirection.rtl,
                style: pw.TextStyle(
                    font: arabicLightFont,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(
                width: 5,
              ),
            ])),
      ),
      pw.Container(
          decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 0.2, color: PdfColors.black)),
          height: 18,
          width: 88.5,
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.all(3),
          child: pw.Text(totalDiscountValue.toStringAsFixed(2),
              style: pw.TextStyle(
                fontSize: 8,
                font: txtNormalFont,
              ))),
    ]);
  } else if (tileNo == 3) {
    return pw.Row(children: [
      pw.Expanded(
          child: pw.Container(
              decoration: const pw.BoxDecoration(
                  border: pw.Border(
                left: pw.BorderSide(width: 0.2, color: PdfColors.black),
                bottom: pw.BorderSide(width: 0.2, color: PdfColors.black),
                top: pw.BorderSide(width: 0.2, color: PdfColors.black),
              )),
              height: 18,
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.all(3),
              child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text('Total after Discount',
                        style: pw.TextStyle(fontSize: 8, font: txtNormalFont)),
                    pw.SizedBox(
                      width: 5,
                    ),
                    pw.Text(
                      "المجموع بعد الخصم",
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(
                          font: arabicLightFont,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(
                      width: 5,
                    ),
                  ]))),
      pw.Container(
          decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 0.2, color: PdfColors.black)),
          height: 18,
          width: 88.5,
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.all(3),
          child: pw.Text(totalAfterDiscount.toStringAsFixed(2),
              style: pw.TextStyle(
                fontSize: 8,
                font: txtNormalFont,
              ))),
    ]);
  } else if (tileNo == 4) {
    return pw.Row(children: [
      pw.Expanded(
          child: pw.Container(
              decoration: const pw.BoxDecoration(
                  border: pw.Border(
                left: pw.BorderSide(width: 0.2, color: PdfColors.black),
                bottom: pw.BorderSide(width: 0.2, color: PdfColors.black),
                top: pw.BorderSide(width: 0.2, color: PdfColors.black),
              )),
              height: 18,
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.all(3),
              child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text('Tax (${dbReceiptData.taxPer}%)',
                        style: pw.TextStyle(fontSize: 8, font: txtNormalFont)),
                    pw.SizedBox(
                      width: 5,
                    ),
                    pw.Text(
                      "ضريبة٪",
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(
                          font: arabicLightFont,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(
                      width: 5,
                    ),
                  ]))),
      pw.Container(
          decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 0.2, color: PdfColors.black)),
          height: 18,
          width: 88.5,
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.all(3),
          child: pw.Text(
              calculateVatIncludedValue(
                  totalAfterDiscount, dbReceiptData.taxPer),
              style: pw.TextStyle(
                fontSize: 8,
                font: txtNormalFont,
              ))),
    ]);
  } else if (tileNo == 5) {
    return pw.Row(children: [
      pw.Expanded(
          child: pw.Container(
              decoration: const pw.BoxDecoration(
                  border: pw.Border(
                left: pw.BorderSide(width: 0.2, color: PdfColors.black),
                bottom: pw.BorderSide(width: 0.2, color: PdfColors.black),
                top: pw.BorderSide(width: 0.2, color: PdfColors.black),
              )),
              height: 18,
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.all(3),
              child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text('Total',
                        style: pw.TextStyle(fontSize: 10, font: txtNormalFont)),
                    pw.SizedBox(
                      width: 5,
                    ),
                    pw.Text(
                      "المجموع",
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(
                          font: arabicLightFont,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(
                      width: 5,
                    ),
                  ]))),
      pw.Container(
          decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 0.2, color: PdfColors.black)),
          height: 18,
          width: 88.5,
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.all(3),
          child: pw.Text(total.toStringAsFixed(2),
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 8,
                font: txtNormalFont,
              ))),
    ]);
  }
}

productTile(txtNormalFont, localReceiptData, arabicFont, vatPercentage,
    bool last, dbReceiptData) {
  double height = 30;
  int nol = (localReceiptData['productName'].toString().length / 50).ceil();

  if (nol != 1) {
    height += 10 * (nol - 1);
  }

  return pw.Row(children: [
    pw.Container(
      decoration: pw.BoxDecoration(
          border: pw.Border.all(width: 0.2, color: PdfColors.black)),
      height: height,
      width: 53,
      alignment: pw.Alignment.centerLeft,
      padding: const pw.EdgeInsets.all(3),
      child: pw.Text(
        localReceiptData['barcode'],
        style: pw.TextStyle(font: txtNormalFont, fontSize: 8),
      ),
    ),
    pw.Container(
      decoration: pw.BoxDecoration(
          border: pw.Border.all(width: 0.2, color: PdfColors.black)),
      height: height,
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.all(3),
      width: 53,
      child: pw.Text(
        localReceiptData['itemCode'],
        style: pw.TextStyle(
          font: txtNormalFont,
          fontSize: 8,
        ),
      ),
    ),
    pw.Container(
      decoration: pw.BoxDecoration(
          border: pw.Border.all(width: 0.2, color: PdfColors.black)),
      height: height,
      width: 248,
      padding: const pw.EdgeInsets.all(3),
      child: pw.Text(
          // '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890',
          localReceiptData['productName'],
          textDirection: !containsExtendedArabic(
                  localReceiptData['productName'].toString())
              ? pw.TextDirection.ltr
              : pw.TextDirection.rtl,
          softWrap: true,
          style: pw.TextStyle(
            font: !containsExtendedArabic(
                    localReceiptData['productName'].toString())
                ? txtNormalFont
                : arabicFont,
            fontSize: 8,
            //
          )),
    ),
    pw.Container(
        decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 0.2, color: PdfColors.black)),
        height: height,
        alignment: pw.Alignment.center,
        width: 35,
        padding: const pw.EdgeInsets.all(3),
        child: pw.Text(
          localReceiptData['qty'],
          style: pw.TextStyle(font: txtNormalFont, fontSize: 8),
        )),
    pw.Container(
        decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 0.2, color: PdfColors.black)),
        height: height,
        alignment: pw.Alignment.center,
        width: 88,
        padding: const pw.EdgeInsets.all(3),
        child: pw.Text(
            (double.parse(localReceiptData['orgPrice']) -
                    double.parse(calculateTaxValue(
                        double.parse(localReceiptData['orgPrice']),
                        dbReceiptData.taxPer)))
                .toStringAsFixed(2),
            style: pw.TextStyle(fontSize: 8, font: txtNormalFont))),
    pw.Container(
        decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 0.2, color: PdfColors.black)),
        height: height,
        alignment: pw.Alignment.center,
        width: 88,
        padding: const pw.EdgeInsets.all(3),
        child: pw.Text(
            ((double.parse(localReceiptData['orgPrice']) -
                        double.parse(calculateTaxValue(
                            double.parse(localReceiptData['orgPrice']),
                            dbReceiptData.taxPer))) *
                    double.parse(localReceiptData['qty']))
                .toStringAsFixed(2),
            style: pw.TextStyle(
              fontSize: 8,
              font: txtNormalFont,
            ))),
  ]);
}
