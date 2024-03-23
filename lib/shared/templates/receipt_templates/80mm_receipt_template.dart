import 'package:barcode_image/barcode_image.dart';
import 'package:bitpro_hive/model/store_data.dart';
import 'package:bitpro_hive/shared/check_contain_arabic_letters.dart';
import 'package:bitpro_hive/shared/constant_data.dart';
import 'package:intl/intl.dart';
import 'package:bitpro_hive/model/receipt/db_receipt_data.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:bitpro_hive/shared/templates/receipt_templates/e_invoice_generator.dart';
import 'package:bitpro_hive/shared/templates/receipt_templates/print_receipt.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

receipt80mmTemplate(
    {required image,
    required userData,
    required userSettingsData,
    required userPrintingData,
    required StoreData seletedStoreData,
    required DbReceiptData dbReceiptData,
    required txtBoldFont,
    required arabicNormalFont,
    required vatPercentage,
    required taxValue}) {
  double totalBeforeDis = double.parse(dbReceiptData.receiptTotal) +
      double.parse(dbReceiptData.discountValue);
  return [
    pw.Container(
        width: double.maxFinite,
        child: pw.Column(children: [
          pw.SizedBox(
            height: 15,
          ),
          pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Image(image, height: 80),
          ),
          pw.SizedBox(
            height: 5,
          ),
          if (userSettingsData != null)
            pw.Text(
              userSettingsData['companyName'],
              textDirection: !containsExtendedArabic(
                      userSettingsData['companyName'].toString())
                  ? pw.TextDirection.ltr
                  : pw.TextDirection.rtl,
              style: pw.TextStyle(
                font: !containsExtendedArabic(
                        userSettingsData['companyName'].toString())
                    ? txtBoldFont
                    : arabicNormalFont,
                fontSize: 9,
              ),
            ),
          pw.Text(
            seletedStoreData.address1,
            textAlign: pw.TextAlign.center,
            textDirection:
                !containsExtendedArabic(seletedStoreData.address1.toString())
                    ? pw.TextDirection.ltr
                    : pw.TextDirection.rtl,
            style: pw.TextStyle(
              font:
                  !containsExtendedArabic(seletedStoreData.address1.toString())
                      ? txtBoldFont
                      : arabicNormalFont,
              fontSize: 9,
            ),
          ),
          pw.Text(
            seletedStoreData.phone1,
            style: pw.TextStyle(
              fontSize: 9,
              font: txtBoldFont,
            ),
          ),
          pw.SizedBox(
            height: 7,
          ),
          if (userPrintingData != null)
            pw.Text(
              userPrintingData['receiptTitleEng'],
              style: pw.TextStyle(
                  fontSize: 8,
                  font: txtBoldFont,
                  fontWeight: pw.FontWeight.bold),
            ),
          if (userPrintingData != null)
            pw.Text(
              userPrintingData['receiptTitleArb'],
              textDirection: pw.TextDirection.rtl,
              style: pw.TextStyle(
                fontSize: 8,
                font: arabicNormalFont,
              ),
            ),
          pw.SizedBox(
            height: 7,
          ),
          if (dbReceiptData.receiptType != 'Regular')
            pw.Container(
                margin: const pw.EdgeInsets.symmetric(horizontal: 42),
                decoration: pw.BoxDecoration(
                    border: pw.Border.all(), color: PdfColors.black),
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 3),
                child: pw.Center(
                  child: pw.Row(children: [
                    pw.Text(
                      'Return Invoice',
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 8,
                        font: txtBoldFont,
                      ),
                    ),
                    pw.SizedBox(width: 3),
                    pw.Text(
                      'فاتورة الاسترجاع',
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 8,
                        font: arabicNormalFont,
                      ),
                    ),
                  ]),
                )),
          pw.SizedBox(
            height: 7,
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text(
                    'RECEIPT #',
                    style: pw.TextStyle(
                        fontSize: 8,
                        font: txtBoldFont,
                        fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'DATE :',
                    style: pw.TextStyle(
                      fontSize: 8,
                      font: txtBoldFont,
                    ),
                  ),
                  pw.Text(
                    'CASHIER :',
                    style: pw.TextStyle(
                      fontSize: 8,
                      font: txtBoldFont,
                    ),
                  ),
                  if (seletedStoreData.vatNumber.isNotEmpty)
                    pw.Text(
                      'VAT No :',
                      style: pw.TextStyle(
                        fontSize: 8,
                        font: txtBoldFont,
                      ),
                    ),
                  // pw.Text(
                  //   'Reference No :',
                  //   style: pw.TextStyle(
                  //     fontSize: 7,
                  //     font: txtBoldFont,
                  //   ),
                  //  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    dbReceiptData.receiptNo.toString(),
                    style: pw.TextStyle(
                      fontSize: 9,
                      font: txtBoldFont,
                    ),
                  ),
                  pw.Text(
                    DateFormat('dd-MM-yyyy HH:mm a')
                        .format(dbReceiptData.createdDate),
                    style: pw.TextStyle(
                      fontSize: 8,
                      font: txtBoldFont,
                    ),
                  ),
                  pw.Text(
                    userData.username,
                    textDirection:
                        !containsExtendedArabic(userData.username.toString())
                            ? pw.TextDirection.ltr
                            : pw.TextDirection.rtl,
                    style: pw.TextStyle(
                      font:
                          !containsExtendedArabic(userData.username.toString())
                              ? txtBoldFont
                              : arabicNormalFont,
                      fontSize: 8,
                    ),
                  ),
                  if (seletedStoreData.vatNumber.isNotEmpty)
                    pw.Text(
                      seletedStoreData.vatNumber,
                      style: pw.TextStyle(
                        fontSize: 8,
                        font: txtBoldFont,
                      ),
                    ),
                  //if (dbReceiptData.referenceNo.isNotEmpty)
                  // pw.Text(
                  //  dbReceiptData.referenceNo,
                  //  style: pw.TextStyle(
                  //     fontSize: 7,
                  //     font: txtBoldFont,
                  //    ),
                  //   ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '# فاتورة',
                    textDirection: pw.TextDirection.rtl,
                    style: pw.TextStyle(
                      fontSize: 8,
                      font: arabicNormalFont,
                    ),
                  ),
                  pw.Text(
                    'تاريخ',
                    textDirection: pw.TextDirection.rtl,
                    style: pw.TextStyle(
                      fontSize: 8,
                      font: arabicNormalFont,
                    ),
                  ),
                  pw.Text(
                    'كاشير',
                    textDirection: pw.TextDirection.rtl,
                    style: pw.TextStyle(
                      fontSize: 8,
                      font: arabicNormalFont,
                    ),
                  ),
                  if (seletedStoreData.vatNumber.isNotEmpty)
                    pw.Text(
                      'رقم الضريبة',
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(
                        fontSize: 8,
                        font: arabicNormalFont,
                      ),
                    ),
                ],
              )
            ],
          ),
          pw.SizedBox(
            height: 5,
          ),
          pw.Align(
              alignment: pw.Alignment.center,
              child: pw.SvgImage(
                  svg: buildBarcode(
                height: 30,
                width: 80,
                Barcode.code128(useCode128B: false, useCode128C: false),
                dbReceiptData.receiptNo.toString(),
                filename: 'code-128a',
              ))),
          pw.Text('------------------------------------------------'),
        ])),
    pw.Container(
      width: double.maxFinite,
      alignment: pw.Alignment.centerLeft,
      child: pw.Table(
        columnWidths: {
          0: const pw.FlexColumnWidth(5),
          2: const pw.FlexColumnWidth(3),
          3: const pw.FlexColumnWidth(3),
          4: const pw.FlexColumnWidth(5)
        },
        children: [
          pw.TableRow(decoration: const pw.BoxDecoration(), children: [
            pw.Container(
                height: 25,
                padding: const pw.EdgeInsets.only(left: 10),
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'باركود',
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(
                          fontSize: 8,
                          font: arabicNormalFont,
                          fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text('BARCODE',
                        style: pw.TextStyle(fontSize: 8, font: txtBoldFont))
                  ],
                )),
            pw.Container(
                height: 25,
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'سعر',
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(
                          font: arabicNormalFont,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text('PRICE',
                        style: pw.TextStyle(fontSize: 8, font: txtBoldFont))
                  ],
                )),
            pw.Container(
                height: 25,
                alignment: pw.Alignment.center,
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      'كمية',
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(
                          font: arabicNormalFont,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text('QTY',
                        style: pw.TextStyle(fontSize: 8, font: txtBoldFont))
                  ],
                )),
            pw.Container(
                height: 25,
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'اجمالي',
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(
                          font: arabicNormalFont,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text('TOTAL',
                        style: pw.TextStyle(fontSize: 8, font: txtBoldFont))
                  ],
                )),
          ]),
          for (var localReceiptData in dbReceiptData.selectedItems)
            productTile(txtBoldFont, localReceiptData, arabicNormalFont),
        ],
      ),
    ),
    pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      decoration: const pw.BoxDecoration(),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('TOTAL QTY',
                  style: pw.TextStyle(fontSize: 8, font: txtBoldFont)),
              pw.SizedBox(
                height: 4,
              ),
              pw.Text('TOTAL W/T',
                  style: pw.TextStyle(fontSize: 8, font: txtBoldFont)),
              pw.SizedBox(
                height: 4,
              ),
              pw.Text('DIS (${dbReceiptData.discountPercentage}%)',
                  style: pw.TextStyle(fontSize: 8, font: txtBoldFont)),
              pw.SizedBox(
                height: 4,
              ),
              pw.Text('BEFORE VAT',
                  style: pw.TextStyle(fontSize: 8, font: txtBoldFont)),
              pw.SizedBox(
                height: 4,
              ),
              pw.Text('${'VAT (' + vatPercentage}%)',
                  style: pw.TextStyle(fontSize: 8, font: txtBoldFont)),
              pw.SizedBox(
                height: 8,
              ),
              pw.Text(
                'TOTAL',
                style: pw.TextStyle(
                    font: txtBoldFont,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                height: -4,
              ),
              pw.Text(dbReceiptData.totalQty,
                  style: pw.TextStyle(fontSize: 8, font: txtBoldFont)),
              pw.SizedBox(
                height: 4,
              ),
              pw.Text(totalBeforeDis.toString(),
                  style: pw.TextStyle(fontSize: 8, font: txtBoldFont)),
              pw.SizedBox(
                height: 4,
              ),
              pw.Text(dbReceiptData.discountValue,
                  style: pw.TextStyle(fontSize: 8, font: txtBoldFont)),
              pw.SizedBox(
                height: 4,
              ),
              pw.Text(
                  (double.parse(dbReceiptData.receiptTotal) -
                          double.parse(taxValue))
                      .toStringAsFixed(2),
                  style: pw.TextStyle(fontSize: 8, font: txtBoldFont)),
              pw.SizedBox(
                height: 4,
              ),
              pw.Text(taxValue,
                  style: pw.TextStyle(fontSize: 8, font: txtBoldFont)),
              pw.SizedBox(
                height: 10,
              ),
              pw.Text(
                dbReceiptData.receiptTotal,
                style: pw.TextStyle(
                    font: txtBoldFont,
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'الكمية',
                textDirection: pw.TextDirection.rtl,
                style: pw.TextStyle(
                    font: arabicNormalFont,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(
                height: 4,
              ),
              pw.Text(
                'الاجملي قبل الخصم',
                textDirection: pw.TextDirection.rtl,
                style: pw.TextStyle(
                    font: arabicNormalFont,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(
                height: 4,
              ),
              pw.Text(
                'خصم ',
                textDirection: pw.TextDirection.rtl,
                style: pw.TextStyle(
                    font: arabicNormalFont,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(
                height: 4,
              ),
              pw.Text(
                'اجمالي قبل الضريبة',
                textDirection: pw.TextDirection.rtl,
                style: pw.TextStyle(
                    font: arabicNormalFont,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(
                height: 4,
              ),
              pw.Text(
                '(15%) الضريبة ',
                textDirection: pw.TextDirection.rtl,
                style: pw.TextStyle(
                    font: arabicNormalFont,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(
                height: 10,
              ),
              pw.Text(
                'الاجمالي',
                textDirection: pw.TextDirection.rtl,
                style: pw.TextStyle(
                    font: arabicNormalFont,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    ),
    pw.Text('------------------------------------------------'),
    pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: const pw.BoxDecoration(),
        child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('CASH',
                      style: pw.TextStyle(fontSize: 8, font: txtBoldFont)),
                  pw.SizedBox(
                    height: 3,
                  ),
                  pw.Text('CREDIT CARD',
                      style: pw.TextStyle(fontSize: 8, font: txtBoldFont)),
                  pw.SizedBox(
                    height: 3,
                  ),
                  pw.Text('CHANGE',
                      style: pw.TextStyle(fontSize: 8, font: txtBoldFont))
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                      dbReceiptData
                          .allPaymentMethodAmountsInfo[PaymentMethodKey().cash],
                      style: pw.TextStyle(fontSize: 7, font: txtBoldFont)),
                  pw.SizedBox(
                    height: 3,
                  ),
                  pw.Text(
                      dbReceiptData.allPaymentMethodAmountsInfo[
                          PaymentMethodKey().creditCard],
                      style: pw.TextStyle(fontSize: 7, font: txtBoldFont)),
                  pw.SizedBox(
                    height: 3,
                  ),
                  pw.Text(dbReceiptData.receiptBalance,
                      style: pw.TextStyle(fontSize: 7, font: txtBoldFont))
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('كاش',
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(fontSize: 8, font: arabicNormalFont)),
                  pw.SizedBox(
                    height: 3,
                  ),
                  pw.Text('شبكة',
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(fontSize: 8, font: arabicNormalFont)),
                  pw.SizedBox(
                    height: 3,
                  ),
                  pw.Text('المتبقي',
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(fontSize: 8, font: arabicNormalFont)),
                ],
              ),
            ])),
    pw.SizedBox(
      height: 0,
    ),
    pw.Text('------------------------------------------------'),
    pw.Align(
        alignment: pw.Alignment.center,
        child: pw.Text(
          'شكرا للتسوق معنا',
          textDirection: pw.TextDirection.rtl,
          style: pw.TextStyle(
            fontSize: 8,
            font: arabicNormalFont,
          ),
        )),
    pw.SizedBox(
      height: 1,
    ),
    pw.Align(
        alignment: pw.Alignment.center,
        child: pw.Text('THANK YOU FOR SHOPPING WITH',
            style: pw.TextStyle(fontSize: 8, font: txtBoldFont))),
    pw.SizedBox(
      height: 0,
    ),
    if (userPrintingData != null)
      pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10),
          child: pw.Text(userPrintingData['receiptFotterEng'],
              style: pw.TextStyle(fontSize: 8, font: txtBoldFont))),
    pw.SizedBox(
      height: 1,
    ),
    if (userPrintingData != null)
      pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10),
          child: pw.Align(
              alignment: pw.Alignment.bottomRight,
              child: pw.Text(
                userPrintingData['receiptFotterArb'],
                textDirection: pw.TextDirection.rtl,
                style: pw.TextStyle(
                  fontSize: 8,
                  font: arabicNormalFont,
                ),
              ))),
    pw.SizedBox(
      height: 1,
    ),
    pw.Text('------------------------------------------------'),
    pw.SizedBox(height: 5),
    pw.Align(
        alignment: pw.Alignment.center,
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
                ))))
  ];
}

productTile(txtBoldFont, localReceiptData, arabicFont) {
  double height = 24;

  int nol = (localReceiptData['productName'].toString().length / 13).ceil();

  if (nol != 1) {
    height += 10 * (nol);
  }

  return pw.TableRow(
      verticalAlignment: pw.TableCellVerticalAlignment.top,
      children: [
        pw.Container(
            decoration: const pw.BoxDecoration(
                border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey),
            )),
            height: height,
            width: 40,
            padding: const pw.EdgeInsets.only(left: 10),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  height: 2,
                ),
                pw.Text(
                  localReceiptData['barcode'],
                  style: pw.TextStyle(
                      font: txtBoldFont,
                      fontSize: 7,
                      fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(
                  height: 2,
                ),
                pw.Flexible(
                    child: pw.Text(localReceiptData['productName'],
                        textDirection: !containsExtendedArabic(
                                localReceiptData['productName'].toString())
                            ? pw.TextDirection.ltr
                            : pw.TextDirection.rtl,
                        style: pw.TextStyle(
                          font: !containsExtendedArabic(
                                  localReceiptData['productName'].toString())
                              ? txtBoldFont
                              : arabicFont,
                          fontSize: 7,
                          //
                        )))
              ],
            )),
        pw.Container(
            decoration: const pw.BoxDecoration(
                border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey),
            )),
            height: height,
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  height: 2,
                ),
                pw.Text(
                  '${localReceiptData['priceWt']}',
                  style: pw.TextStyle(
                      font: txtBoldFont,
                      fontSize: 7,
                      fontWeight: pw.FontWeight.bold),
                ),
              ],
            )),
        pw.Container(
            decoration: const pw.BoxDecoration(
                border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey),
            )),
            height: height,
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.SizedBox(
                  height: 2,
                ),
                pw.Text(
                  localReceiptData['qty'],
                  style: pw.TextStyle(
                      font: txtBoldFont,
                      fontSize: 7,
                      fontWeight: pw.FontWeight.bold),
                ),
              ],
            )),
        pw.Container(
            decoration: const pw.BoxDecoration(
                border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey),
            )),
            height: height,
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  height: 2,
                ),
                pw.Text(
                  localReceiptData['total'],
                  style: pw.TextStyle(
                      //
                      fontSize: 7,
                      font: txtBoldFont,
                      fontWeight: pw.FontWeight.bold),
                ),
              ],
            )),
      ]);
}
