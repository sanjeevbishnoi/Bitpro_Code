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

des0002A4ReceiptTemplate({
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
  required StoreData seletedStoreData,
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
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            if (userPrintingData != null)
                              pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.center,
                                  children: [
                                    pw.Text(
                                      userPrintingData['receiptTitleEng'],
                                      style: pw.TextStyle(
                                          fontSize: 8,
                                          fontBold: txtBoldFont,
                                          fontWeight: pw.FontWeight.bold),
                                    ),
                                    pw.Text(
                                      ' / ',
                                      style: pw.TextStyle(
                                          fontSize: 8,
                                          fontBold: txtBoldFont,
                                          fontWeight: pw.FontWeight.bold),
                                    ),
                                    pw.Text(
                                      userPrintingData['receiptTitleArb'],
                                      textDirection: pw.TextDirection.rtl,
                                      style: pw.TextStyle(
                                          fontSize: 8,
                                          font: arabicNormalFont,
                                          fontWeight: pw.FontWeight.bold),
                                    ),
                                  ]),
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
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                            pw.SizedBox(
                              height: 10,
                            ),
                            pw.Text(
                              seletedStoreData.address1,
                              textAlign: pw.TextAlign.left,
                              textDirection: !containsExtendedArabic(
                                      seletedStoreData.address1.toString())
                                  ? pw.TextDirection.ltr
                                  : pw.TextDirection.rtl,
                              style: pw.TextStyle(
                                font: !containsExtendedArabic(
                                        seletedStoreData.address1.toString())
                                    ? txtNormalFont
                                    : arabicLightFont,
                                fontSize: 8,
                              ),
                            ),
                            pw.SizedBox(
                              height: 10,
                            ),
                            pw.Row(children: [
                              pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      'VAT No. : ',
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                        font: txtNormalFont,
                                      ),
                                    ),
                                    pw.SizedBox(height: 5),
                                    pw.Text(
                                      'Phone : ',
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                        font: txtNormalFont,
                                      ),
                                    ),
                                    pw.SizedBox(height: 5),
                                    pw.Text(
                                      'Email : ',
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                        font: txtNormalFont,
                                      ),
                                    ),
                                  ]),
                              pw.SizedBox(width: 15),
                              pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      seletedStoreData.vatNumber,
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                        font: txtNormalFont,
                                      ),
                                    ),
                                    pw.SizedBox(height: 5),
                                    pw.Text(
                                      seletedStoreData.phone1,
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                        font: txtNormalFont,
                                      ),
                                    ),
                                    pw.SizedBox(height: 5),
                                    pw.Text(
                                      seletedStoreData.email,
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                        font: txtNormalFont,
                                      ),
                                    ),
                                  ])
                            ]),
                            pw.SizedBox(width: 10),
                          ],
                        ),
                        pw.Expanded(child: pw.SizedBox(width: 20)),
                        pw.Container(
                          margin: const pw.EdgeInsets.only(right: 20),
                          width: 170,
                          height: 90,
                          child: pw.Image(image,
                              width: 170, height: 90, fit: pw.BoxFit.contain),
                        ),
                        pw.SizedBox(width: 20),
                      ]),
                  pw.SizedBox(
                    height: 10,
                  ),
                  pw.Container(
                      color: PdfColors.grey400,
                      width: double.maxFinite,
                      height: .5),
                  pw.SizedBox(
                    height: 10,
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (selectedCustomerData != null)
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Bill to',
                              style:
                                  pw.TextStyle(font: txtBoldFont, fontSize: 8),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              selectedCustomerData.customerName,
                              textDirection: !containsExtendedArabic(
                                      selectedCustomerData.customerName
                                          .toString())
                                  ? pw.TextDirection.ltr
                                  : pw.TextDirection.rtl,
                              style: pw.TextStyle(
                                  font: !containsExtendedArabic(
                                          selectedCustomerData.customerName
                                              .toString())
                                      ? txtNormalFont
                                      : arabicLightFont,
                                  fontSize: 8),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              selectedCustomerData.address1,
                              textDirection: !containsExtendedArabic(
                                      selectedCustomerData.address1.toString())
                                  ? pw.TextDirection.ltr
                                  : pw.TextDirection.rtl,
                              style: pw.TextStyle(
                                  font: !containsExtendedArabic(
                                          selectedCustomerData.address1
                                              .toString())
                                      ? txtNormalFont
                                      : arabicLightFont,
                                  fontSize: 8),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Row(children: [
                              pw.Text(
                                'Vat No. : ',
                                style: pw.TextStyle(
                                  font: txtNormalFont,
                                  fontSize: 8,
                                ),
                              ),
                              pw.SizedBox(width: 15),
                              pw.Text(
                                selectedCustomerData.vatNo,
                                textDirection: !containsExtendedArabic(
                                        selectedCustomerData.vatNo.toString())
                                    ? pw.TextDirection.ltr
                                    : pw.TextDirection.rtl,
                                style: pw.TextStyle(
                                  font: !containsExtendedArabic(
                                          selectedCustomerData.vatNo.toString())
                                      ? txtNormalFont
                                      : arabicLightFont,
                                  fontSize: 8,
                                ),
                              ),
                            ])
                          ],
                        ),
                      pw.Expanded(
                          child: pw.SizedBox(
                        width: 10,
                      )),
                      pw.Row(children: [
                        pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Invoice No. : ',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  font: txtNormalFont,
                                ),
                              ),
                              pw.SizedBox(height: 5),
                              pw.Text(
                                'Date : ',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  font: txtNormalFont,
                                ),
                              ),
                              pw.SizedBox(height: 5),
                              pw.Text(
                                'Created : ',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  font: txtNormalFont,
                                ),
                              ),
                              if (dbReceiptData.referenceNo.isNotEmpty)
                                pw.SizedBox(height: 5),
                              if (dbReceiptData.referenceNo.isNotEmpty)
                                pw.Text(
                                  'Reference no : ',
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    font: txtNormalFont,
                                  ),
                                ),
                              pw.SizedBox(height: 5),
                              pw.Text(
                                'Bank acc. number : ',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  font: txtNormalFont,
                                ),
                              ),
                              pw.SizedBox(height: 5),
                              pw.Text(
                                'Bank name : ',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  font: txtNormalFont,
                                ),
                              ),
                            ]),
                        pw.SizedBox(width: 10),
                        pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
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
                                    .format(dbReceiptData.createdDate),
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  font: txtNormalFont,
                                ),
                              ),
                              pw.SizedBox(height: 5),
                              pw.Text(
                                '${userData.username}',
                                textDirection: !containsExtendedArabic(
                                        userData.username.toString())
                                    ? pw.TextDirection.ltr
                                    : pw.TextDirection.rtl,
                                style: pw.TextStyle(
                                  font: !containsExtendedArabic(
                                          userData.username.toString())
                                      ? txtNormalFont
                                      : arabicLightFont,
                                  fontSize: 8,
                                ),
                              ),
                              if (dbReceiptData.referenceNo.isNotEmpty)
                                pw.SizedBox(height: 5),
                              if (dbReceiptData.referenceNo.isNotEmpty)
                                pw.Text(
                                  dbReceiptData.referenceNo,
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    font: txtNormalFont,
                                  ),
                                ),
                              pw.SizedBox(height: 5),
                              pw.Text(
                                seletedStoreData.ibanAccountNumber,
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  font: txtNormalFont,
                                ),
                              ),
                              pw.SizedBox(height: 5),
                              pw.Text(
                                seletedStoreData.bankName,
                                textDirection: !containsExtendedArabic(
                                        seletedStoreData.bankName.toString())
                                    ? pw.TextDirection.ltr
                                    : pw.TextDirection.rtl,
                                style: pw.TextStyle(
                                  font: !containsExtendedArabic(
                                          seletedStoreData.bankName.toString())
                                      ? txtNormalFont
                                      : arabicLightFont,
                                  fontSize: 8,
                                ),
                              ),
                            ]),
                      ]),
                      pw.SizedBox(
                        width: 50,
                      )
                    ],
                  ),
                  if (dbReceiptData.receiptType != 'Regular')
                    pw.Center(
                        child: pw.Container(
                            decoration:
                                pw.BoxDecoration(border: pw.Border.all()),
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            child: pw.Column(children: [
                              pw.Text(
                                'Return Invoice',
                                textDirection: pw.TextDirection.rtl,
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  font: txtBoldFont,
                                ),
                              ),
                              pw.SizedBox(height: 3),
                              pw.Text(
                                'فاتورة الاسترجاع',
                                textDirection: pw.TextDirection.rtl,
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  font: arabicNormalFont,
                                ),
                              ),
                            ]))),
                  pw.SizedBox(
                    height: 15,
                  ),
                ]),
            pw.Container(
              width: double.maxFinite,
              alignment: pw.Alignment.centerLeft,
              child: pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(6.5),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FlexColumnWidth(2),
                  5: const pw.FlexColumnWidth(2)
                },
                children: [
                  pw.TableRow(
                      decoration: const pw.BoxDecoration(
                          border: pw.Border(
                        bottom:
                            pw.BorderSide(color: PdfColors.grey500, width: 2),
                      )),
                      children: [
                        pw.Container(
                            height: 30,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: PdfColors.grey400, width: .6)),
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
                            height: 30,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: PdfColors.grey400, width: .6)),
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
                                pw.Text('Item',
                                    style: pw.TextStyle(
                                        fontSize: 8, font: txtBoldFont))
                              ],
                            )),
                        pw.Container(
                            height: 30,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: PdfColors.grey400, width: .6)),
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
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: PdfColors.grey400, width: .6)),
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
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 2,
                                ),
                                pw.Text('Price',
                                    style: pw.TextStyle(
                                        fontSize: 8, font: txtBoldFont))
                              ],
                            )),
                        pw.Container(
                            height: 30,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: PdfColors.grey400, width: .6)),
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(
                                  'الضريبية',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    font: arabicNormalFont,
                                    fontSize: 8,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 2,
                                ),
                                pw.Text('Tax',
                                    style: pw.TextStyle(
                                        fontSize: 8, font: txtBoldFont))
                              ],
                            )),
                        pw.Container(
                            height: 30,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: PdfColors.grey400, width: .6)),
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
                      dbReceiptData.selectedItems.length - 1),
            pw.SizedBox(height: 10),
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
                            height: 20,
                            width: 90,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: PdfColors.grey400, width: .6)),
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text('Subtotal',
                                style: pw.TextStyle(
                                    fontSize: 8, font: txtBoldFont))),
                        pw.Container(
                          height: 20,
                          width: 90,
                          decoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                  color: PdfColors.grey400, width: .6)),
                          padding: const pw.EdgeInsets.all(4),
                          alignment: pw.Alignment.centerRight,
                          child: pw.Text(
                            (double.parse(dbReceiptData.receiptTotal) -
                                    double.parse(taxValue))
                                .toStringAsFixed(2),
                            style: pw.TextStyle(
                                font: txtBoldFont,
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold),
                          ),
                        )
                      ]),
                      pw.Row(children: [
                        pw.Container(
                            height: 20,
                            width: 90,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: PdfColors.grey400, width: .6)),
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text('VAT',
                                style: pw.TextStyle(
                                    fontSize: 8, font: txtBoldFont))),
                        pw.Container(
                            height: 20,
                            width: 90,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: PdfColors.grey400, width: .6)),
                            padding: const pw.EdgeInsets.all(4),
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(taxValue,
                                style: pw.TextStyle(
                                    fontSize: 8, font: txtBoldFont))),
                      ]),
                      pw.Row(children: [
                        pw.Container(
                            height: 20,
                            width: 90,
                            decoration: pw.BoxDecoration(
                                color: const PdfColor.fromInt(0xfff5f5f5),
                                border: pw.Border.all(
                                    color: PdfColors.grey400, width: .6)),
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text('Total',
                                style: pw.TextStyle(
                                    fontSize: 8, font: txtBoldFont))),
                        pw.Container(
                          height: 20,
                          width: 90,
                          decoration: pw.BoxDecoration(
                              color: const PdfColor.fromInt(0xfff5f5f5),
                              border: pw.Border.all(
                                  color: PdfColors.grey400, width: .6)),
                          alignment: pw.Alignment.centerRight,
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(dbReceiptData.receiptTotal,
                              style: pw.TextStyle(
                                  font: txtBoldFont,
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                      ])
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(
              height: 25,
            ),
            pw.Align(
                alignment: pw.Alignment.topCenter,
                child: pw.SvgImage(
                    svg: buildBarcode(
                        height: 70,
                        width: 70,
                        Barcode.qrCode(),
                        getQrCodeContent(
                          sellerName: userSettingsData == null
                              ? ''
                              : userSettingsData['companyName'],
                          sellerTRN: seletedStoreData.vatNumber,
                          totalWithVat: dbReceiptData.receiptTotal,
                          vatPrice: taxValue,
                        )))),
            pw.SizedBox(
              height: 25,
            ),
          ]));
}

productTile(
    txtNormalFont, localReceiptData, arabicFont, vatPercentage, bool last) {
  double height = 30;
  int nol = (
          // '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890'
          localReceiptData['productName'].toString().length / 50)
      .ceil();

  if (nol != 1) {
    height += 10 * (nol - 1);
  }

  // print(localReceiptData['productName']);
  // print(RegExp(r'^[a-zA-Z]+$').hasMatch(
  //     'REPAIR OF HADID CHANNEL WITH FLATBAR CUTTING AND WELDING WITH GRINDING SKECHERS NIKE ADIDAS GO RUN PUMA SHOES FOR MEN AND WOMEN AND KID'));
  return pw.Row(
      // verticalAlignment: pw.TableCellVerticalAlignment.top,
      children: [
        pw.Container(
            decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400, width: .6)),
            height: height,
            width: 71,
            alignment: pw.Alignment.centerLeft,
            padding: const pw.EdgeInsets.all(3),
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    localReceiptData['barcode'],
                    style: pw.TextStyle(font: txtNormalFont, fontSize: 8),
                  ),
                  pw.SizedBox(
                    height: 2,
                  ),
                  pw.Text(
                    localReceiptData['itemCode'],
                    style: pw.TextStyle(font: txtNormalFont, fontSize: 8),
                  ),
                ])),
        pw.Container(
          decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400, width: .6)),
          height: height,
          width: 230,
          padding: const pw.EdgeInsets.all(3),
          child: pw.Text(
              // '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890',
              localReceiptData['productName'],
              textDirection:
                  !containsExtendedArabic(localReceiptData['productName'])
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
                border: pw.Border.all(color: PdfColors.grey400, width: .6)),
            height: height,
            width: 54,
            alignment: pw.Alignment.centerRight,
            padding: const pw.EdgeInsets.all(3),
            child: pw.Text(
              localReceiptData['qty'],
              style: pw.TextStyle(font: txtNormalFont, fontSize: 8),
            )),
        pw.Container(
          decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400, width: .6)),
          height: height,
          width: 70,
          alignment: pw.Alignment.centerRight,
          padding: const pw.EdgeInsets.all(3),
          child: pw.Text(
            '${localReceiptData['priceWt']}',
            style: pw.TextStyle(
              font: txtNormalFont,
              fontSize: 8,
            ),
          ),
        ),
        pw.Container(
            decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400, width: .6)),
            height: height,
            width: 71,
            alignment: pw.Alignment.centerRight,
            padding: const pw.EdgeInsets.all(3),
            child: pw.Text('$vatPercentage%',
                style: pw.TextStyle(fontSize: 8, font: txtNormalFont))),
        pw.Container(
            decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400, width: .6)),
            height: height,
            width: 71,
            alignment: pw.Alignment.centerRight,
            padding: const pw.EdgeInsets.all(3),
            child: pw.Text(localReceiptData['total'],
                style: pw.TextStyle(
                  fontSize: 8,
                  font: txtNormalFont,
                ))),
      ]);
}
