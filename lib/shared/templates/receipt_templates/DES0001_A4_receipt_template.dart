import 'package:barcode_image/barcode_image.dart';
import 'package:bitpro_hive/model/store_data.dart';
import 'package:bitpro_hive/shared/check_contain_arabic_letters.dart';
import 'package:intl/intl.dart';
import 'package:bitpro_hive/model/receipt/db_receipt_data.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:bitpro_hive/shared/templates/receipt_templates/e_invoice_generator.dart';
import 'package:bitpro_hive/shared/templates/receipt_templates/print_receipt.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../model/customer_data.dart';

des0001A4ReceiptTemplate({
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
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.5)),
      child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
                padding: const pw.EdgeInsets.all(15),
                width: double.maxFinite,
                child: pw.Column(
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
                                pw.Image(image, height: 35),
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
                                        fontSize: 7,
                                        fontWeight: pw.FontWeight.bold),
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
                                            seletedStoreData.address1
                                                .toString())
                                        ? txtNormalFont
                                        : arabicLightFont,
                                    fontSize: 7,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 10,
                                ),
                                pw.Row(children: [
                                  pw.Text(
                                    'VAT No / ',
                                    style: pw.TextStyle(
                                      fontSize: 7,
                                      font: txtNormalFont,
                                    ),
                                  ),
                                  pw.Text(
                                    'رقم الضريبة',
                                    textDirection: pw.TextDirection.rtl,
                                    style: pw.TextStyle(
                                      fontSize: 7,
                                      font: arabicLightFont,
                                    ),
                                  ),
                                  pw.Text(
                                    ' : ',
                                    textDirection: pw.TextDirection.rtl,
                                    style: pw.TextStyle(
                                      fontSize: 7,
                                      font: arabicLightFont,
                                    ),
                                  ),
                                  pw.SizedBox(width: 10),
                                  pw.Text(
                                    seletedStoreData.vatNumber,
                                    style: pw.TextStyle(
                                      fontSize: 7,
                                      font: txtNormalFont,
                                    ),
                                  ),
                                ]),
                                pw.Row(children: [
                                  pw.Text(
                                    'Phone / ',
                                    style: pw.TextStyle(
                                      fontSize: 7,
                                      font: txtNormalFont,
                                    ),
                                  ),
                                  pw.Text(
                                    "هاتف",
                                    textDirection: pw.TextDirection.rtl,
                                    style: pw.TextStyle(
                                      fontSize: 7,
                                      font: arabicLightFont,
                                    ),
                                  ),
                                  pw.Text(
                                    ' : ',
                                    textDirection: pw.TextDirection.rtl,
                                    style: pw.TextStyle(
                                      fontSize: 7,
                                      font: arabicLightFont,
                                    ),
                                  ),
                                  pw.SizedBox(width: 30),
                                  pw.Text(
                                    seletedStoreData.phone1,
                                    style: pw.TextStyle(
                                      fontSize: 7,
                                      font: txtNormalFont,
                                    ),
                                  ),
                                ]),
                                pw.Row(children: [
                                  pw.Text(
                                    'A/C Number :',
                                    style: pw.TextStyle(
                                      fontSize: 7,
                                      font: txtNormalFont,
                                    ),
                                  ),
                                  pw.SizedBox(width: 30),
                                  pw.Text(
                                    seletedStoreData.ibanAccountNumber,
                                    style: pw.TextStyle(
                                      fontSize: 7,
                                      font: txtNormalFont,
                                    ),
                                  ),
                                ]),
                              ],
                            ),
                            pw.SizedBox(width: 20),
                            pw.SizedBox(width: 20),
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
                                          totalWithVat: dbReceiptData.subTotal,
                                          vatPrice: taxValue,
                                        )))),
                            pw.SizedBox(width: 10),
                            pw.Flexible(
                                child: pw.Column(
                                    mainAxisAlignment: pw.MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                  pw.Row(children: [
                                    pw.Text(
                                      'Customer Info / ',
                                      style: pw.TextStyle(
                                          fontSize: 8,
                                          fontBold: txtBoldFont,
                                          fontWeight: pw.FontWeight.bold),
                                    ),
                                    pw.Text(
                                      'معلومات العميل',
                                      textDirection: pw.TextDirection.rtl,
                                      style: pw.TextStyle(
                                          fontSize: 8,
                                          fontBold: arabicNormalFont,
                                          fontWeight: pw.FontWeight.bold),
                                    ),
                                  ]),
                                  pw.SizedBox(height: 10),
                                  if (selectedCustomerData != null)
                                    pw.Text(
                                      selectedCustomerData.customerName,
                                      textDirection: !containsExtendedArabic(
                                              selectedCustomerData.customerName
                                                  .toString())
                                          ? pw.TextDirection.ltr
                                          : pw.TextDirection.rtl,
                                      style: pw.TextStyle(
                                          font: !containsExtendedArabic(
                                                  selectedCustomerData
                                                      .customerName
                                                      .toString())
                                              ? txtNormalFont
                                              : arabicLightFont,
                                          fontSize: 7),
                                    ),
                                  //address 1
                                  if (selectedCustomerData != null &&
                                      selectedCustomerData.address1.isNotEmpty)
                                    pw.Text(
                                      selectedCustomerData.address1,
                                      textDirection: !containsExtendedArabic(
                                              selectedCustomerData.address1
                                                  .toString())
                                          ? pw.TextDirection.ltr
                                          : pw.TextDirection.rtl,
                                      style: pw.TextStyle(
                                        font: !containsExtendedArabic(
                                                selectedCustomerData.address1
                                                    .toString())
                                            ? txtNormalFont
                                            : arabicLightFont,
                                        fontSize: 7,
                                      ),
                                    ),
                                  //address 2
                                  if (selectedCustomerData != null &&
                                      selectedCustomerData.address1.isEmpty &&
                                      selectedCustomerData.address2.isNotEmpty)
                                    pw.Text(
                                      selectedCustomerData.address2,
                                      textDirection: !containsExtendedArabic(
                                              selectedCustomerData.address2
                                                  .toString())
                                          ? pw.TextDirection.ltr
                                          : pw.TextDirection.rtl,
                                      style: pw.TextStyle(
                                        font: !containsExtendedArabic(
                                                selectedCustomerData.address2
                                                    .toString())
                                            ? txtNormalFont
                                            : arabicLightFont,
                                        fontSize: 7,
                                      ),
                                    ),
                                  pw.SizedBox(height: 10),
                                  pw.Text(
                                    'Invoice# ${dbReceiptData.receiptNo}',
                                    style: pw.TextStyle(
                                      fontSize: 7,
                                      font: txtNormalFont,
                                    ),
                                  ),
                                  pw.Text(
                                    'Date : ${DateFormat('dd-MM-yyyy HH:mm a').format(dbReceiptData.createdDate)}',
                                    style: pw.TextStyle(
                                      fontSize: 7,
                                      font: txtNormalFont,
                                    ),
                                  ),
                                  pw.Row(children: [
                                    pw.Text(
                                      'Created :# ',
                                      style: pw.TextStyle(
                                        fontSize: 7,
                                        font: txtNormalFont,
                                      ),
                                    ),
                                    pw.Text(
                                      userData.username,
                                      textDirection: !containsExtendedArabic(
                                              userData.username.toString())
                                          ? pw.TextDirection.ltr
                                          : pw.TextDirection.rtl,
                                      style: pw.TextStyle(
                                        font: !containsExtendedArabic(
                                                userData.username.toString())
                                            ? txtNormalFont
                                            : arabicLightFont,
                                        fontSize: 7,
                                      ),
                                    ),
                                  ]),
                                  if (dbReceiptData.referenceNo.isNotEmpty)
                                    pw.Text(
                                      'Reference no : ${dbReceiptData.referenceNo}',
                                      style: pw.TextStyle(
                                        fontSize: 7,
                                        font: txtNormalFont,
                                      ),
                                    ),
                                  pw.SizedBox(height: 10),
                                  pw.SvgImage(
                                      svg: buildBarcode(
                                    height: 30,
                                    width: 80,
                                    Barcode.code128(
                                        useCode128B: false, useCode128C: false),
                                    dbReceiptData.receiptNo.toString(),
                                    filename: 'code-128a',
                                  ))
                                ])),
                            pw.SizedBox(width: 10),
                          ]),
                      pw.SizedBox(
                        height: 20,
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
                                      fontSize: 7,
                                      font: txtBoldFont,
                                    ),
                                  ),
                                  pw.SizedBox(height: 3),
                                  pw.Text(
                                    'فاتورة الاسترجاع',
                                    textDirection: pw.TextDirection.rtl,
                                    style: pw.TextStyle(
                                      fontSize: 7,
                                      font: arabicNormalFont,
                                    ),
                                  ),
                                ]))),
                      pw.SizedBox(
                        height: 15,
                      ),
                    ])),
            if (userPrintingData != null)
              pw.Container(
                width: double.maxFinite,
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.5)),
                padding: const pw.EdgeInsets.symmetric(vertical: 5),
                child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        userPrintingData['receiptTitleArb'],
                        textDirection: pw.TextDirection.rtl,
                        style: pw.TextStyle(
                            fontSize: 9,
                            font: arabicNormalFont,
                            fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(width: 10),
                      pw.Text(
                        userPrintingData['receiptTitleEng'],
                        style: pw.TextStyle(
                            fontSize: 9,
                            fontBold: txtBoldFont,
                            fontWeight: pw.FontWeight.bold),
                      ),
                    ]),
              ),
            pw.Container(
              width: double.maxFinite,
              alignment: pw.Alignment.centerLeft,
              child: pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(4),
                  1: const pw.FlexColumnWidth(4),
                  2: const pw.FlexColumnWidth(3),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FlexColumnWidth(2)
                },
                children: [
                  pw.TableRow(
                      decoration: const pw.BoxDecoration(
                          border: pw.Border(
                        bottom:
                            pw.BorderSide(color: PdfColors.black, width: 1.5),
                      )),
                      children: [
                        pw.Container(
                            height: 40,
                            alignment: pw.Alignment.centerLeft,
                            padding: const pw.EdgeInsets.only(left: 20),
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'باركود',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    fontSize: 7,
                                    font: arabicLightFont,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 4,
                                ),
                                pw.Text('Barcode',
                                    style: pw.TextStyle(
                                        fontSize: 7, font: txtNormalFont))
                              ],
                            )),
                        pw.Container(
                            height: 40,
                            alignment: pw.Alignment.centerLeft,
                            padding: const pw.EdgeInsets.only(left: 20),
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'رقم صنف',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    fontSize: 7,
                                    font: arabicLightFont,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 4,
                                ),
                                pw.Text('Product ID',
                                    style: pw.TextStyle(
                                        fontSize: 7, font: txtNormalFont))
                              ],
                            )),
                        pw.Container(
                            height: 40,
                            alignment: pw.Alignment.centerLeft,
                            padding: const pw.EdgeInsets.only(left: 20),
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'سعر',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    font: arabicLightFont,
                                    fontSize: 7,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 4,
                                ),
                                pw.Text('Price',
                                    style: pw.TextStyle(
                                        fontSize: 7, font: txtNormalFont))
                              ],
                            )),
                        pw.Container(
                            height: 40,
                            alignment: pw.Alignment.centerLeft,
                            padding: const pw.EdgeInsets.only(left: 20),
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'كمية',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    font: arabicLightFont,
                                    fontSize: 7,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 4,
                                ),
                                pw.Text('Qty',
                                    style: pw.TextStyle(
                                        fontSize: 7, font: txtNormalFont))
                              ],
                            )),
                        pw.Container(
                            height: 40,
                            alignment: pw.Alignment.centerLeft,
                            padding: const pw.EdgeInsets.only(left: 20),
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'اجمالي',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    font: arabicLightFont,
                                    fontSize: 7,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 4,
                                ),
                                pw.Text('Total',
                                    style: pw.TextStyle(
                                        fontSize: 7, font: txtNormalFont))
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
                  dbReceiptData.selectedItems.indexOf(localReceiptData) ==
                      dbReceiptData.selectedItems.length - 1),
            pw.SizedBox(height: 80),
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: const pw.BoxDecoration(
                  border: pw.Border(
                top: pw.BorderSide(color: PdfColors.black, width: 1.5),
              )),
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
                                          fontSize: 7, font: txtNormalFont))),
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
                                          fontSize: 7,
                                          font: arabicLightFont,
                                        ),
                                      ))),
                            ])),
                  pw.Expanded(
                      child: pw.SizedBox(
                    width: 10,
                  )),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Total Quantity',
                          style:
                              pw.TextStyle(fontSize: 7, font: txtNormalFont)),
                      pw.SizedBox(
                        height: 4,
                      ),
                      pw.Text('Total Price W/T',
                          style:
                              pw.TextStyle(fontSize: 7, font: txtNormalFont)),
                      pw.SizedBox(
                        height: 4,
                      ),
                      pw.Text('Discount %',
                          style:
                              pw.TextStyle(fontSize: 7, font: txtNormalFont)),
                      pw.SizedBox(
                        height: 4,
                      ),
                      pw.Text('Discount \$',
                          style:
                              pw.TextStyle(fontSize: 7, font: txtNormalFont)),
                      pw.SizedBox(
                        height: 4,
                      ),
                      pw.Text('Before VAT',
                          style:
                              pw.TextStyle(fontSize: 7, font: txtNormalFont)),
                      pw.SizedBox(
                        height: 4,
                      ),
                      pw.Text('VAT ($vatPercentage%)',
                          style:
                              pw.TextStyle(fontSize: 7, font: txtNormalFont)),
                      pw.SizedBox(
                        height: 20,
                      ),
                      pw.Text(
                        'Subtotal',
                        style: pw.TextStyle(
                            font: txtBoldFont,
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                  pw.SizedBox(width: 30),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(dbReceiptData.totalQty,
                          style:
                              pw.TextStyle(fontSize: 7, font: txtNormalFont)),
                      pw.SizedBox(
                        height: 4,
                      ),
                      pw.Text(
                          dbReceiptData.subTotal + dbReceiptData.discountValue,
                          style:
                              pw.TextStyle(fontSize: 7, font: txtNormalFont)),
                      pw.SizedBox(
                        height: 4,
                      ),
                      pw.Text(dbReceiptData.discountPercentage,
                          style:
                              pw.TextStyle(fontSize: 7, font: txtNormalFont)),
                      pw.SizedBox(
                        height: 4,
                      ),
                      pw.Text(dbReceiptData.discountValue,
                          style:
                              pw.TextStyle(fontSize: 7, font: txtNormalFont)),
                      pw.SizedBox(
                        height: 4,
                      ),
                      pw.Text(
                          (double.parse(dbReceiptData.subTotal) -
                                  double.parse(taxValue))
                              .toStringAsFixed(2),
                          style:
                              pw.TextStyle(fontSize: 7, font: txtNormalFont)),
                      pw.SizedBox(
                        height: 4,
                      ),
                      pw.Text(taxValue,
                          style:
                              pw.TextStyle(fontSize: 7, font: txtNormalFont)),
                      pw.SizedBox(
                        height: 20,
                      ),
                      pw.Text(
                        dbReceiptData.subTotal,
                        style: pw.TextStyle(
                            font: txtBoldFont,
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                  pw.SizedBox(width: 30),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'الكمية',
                        textDirection: pw.TextDirection.rtl,
                        style:
                            pw.TextStyle(font: arabicNormalFont, fontSize: 7),
                      ),
                      pw.SizedBox(
                        height: 3,
                      ),
                      pw.Text(
                        'الاجملي قبل الخصم',
                        textDirection: pw.TextDirection.rtl,
                        style:
                            pw.TextStyle(font: arabicNormalFont, fontSize: 7),
                      ),
                      pw.SizedBox(
                        height: 3,
                      ),
                      pw.Text(
                        'خصم %',
                        textDirection: pw.TextDirection.rtl,
                        style:
                            pw.TextStyle(font: arabicNormalFont, fontSize: 7),
                      ),
                      pw.SizedBox(
                        height: 3,
                      ),
                      pw.Text(
                        'خصم \$',
                        textDirection: pw.TextDirection.rtl,
                        style:
                            pw.TextStyle(font: arabicNormalFont, fontSize: 7),
                      ),
                      pw.SizedBox(
                        height: 3,
                      ),
                      pw.Text(
                        'اجمالي قبل الضريبة',
                        textDirection: pw.TextDirection.rtl,
                        style:
                            pw.TextStyle(font: arabicNormalFont, fontSize: 7),
                      ),
                      pw.SizedBox(
                        height: 3,
                      ),
                      pw.Text(
                        'الضريبة ($vatPercentage%)',
                        textDirection: pw.TextDirection.rtl,
                        style:
                            pw.TextStyle(font: arabicNormalFont, fontSize: 7),
                      ),
                      pw.SizedBox(
                        height: 20,
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
            pw.SizedBox(
              height: 15,
            ),
          ]));
}

productTile(txtNormalFont, localReceiptData, arabicFont, bool last) {
  double height = 35;

  int nol = (localReceiptData['productName'].toString().length / 30).ceil();

  if (nol != 1) {
    height += 10 * (nol - 1);
  }

  return pw.Row(
      // verticalAlignment: pw.TableCellVerticalAlignment.top,
      children: [
        pw.Container(
            decoration: pw.BoxDecoration(
                border: last
                    ? null
                    : const pw.Border(
                        bottom:
                            pw.BorderSide(color: PdfColors.black, width: 1.5),
                      )),
            height: height,
            width: 150,
            alignment: pw.Alignment.centerLeft,
            padding: const pw.EdgeInsets.only(left: 20),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  height: 4,
                ),
                pw.Text(
                  localReceiptData['barcode'],
                  style: pw.TextStyle(font: txtNormalFont, fontSize: 7),
                ),
                pw.SizedBox(
                  height: 4,
                ),
                pw.Flexible(
                    child: pw.Text(localReceiptData['productName'],
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
                          fontSize: 7,
                        ))),
                pw.SizedBox(
                  height: 4,
                ),
              ],
            )),
        pw.Container(
            decoration: pw.BoxDecoration(
                border: last
                    ? null
                    : const pw.Border(
                        bottom:
                            pw.BorderSide(color: PdfColors.black, width: 1.5),
                      )),
            height: height,
            width: 150,
            alignment: pw.Alignment.centerLeft,
            padding: const pw.EdgeInsets.only(left: 20),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  height: 4,
                ),
                pw.Text(
                  localReceiptData['itemCode'],
                  style: pw.TextStyle(font: txtNormalFont, fontSize: 7),
                ),
                pw.SizedBox(
                  height: 4,
                ),
                pw.Text(
                    'Discount %: ${((double.parse(localReceiptData['discountValue']) * 100) / double.parse(localReceiptData['total'])).toStringAsFixed(2)}',
                    style: pw.TextStyle(fontSize: 7, font: txtNormalFont))
              ],
            )),
        pw.Container(
            decoration: pw.BoxDecoration(
                border: last
                    ? null
                    : const pw.Border(
                        bottom:
                            pw.BorderSide(color: PdfColors.black, width: 1.5),
                      )),
            height: height,
            width: 120,
            alignment: pw.Alignment.centerLeft,
            padding: const pw.EdgeInsets.only(left: 20),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  height: 4,
                ),
                pw.Text(
                  '${localReceiptData['priceWt']}',
                  style: pw.TextStyle(
                    font: txtNormalFont,
                    fontSize: 7,
                  ),
                ),
                pw.SizedBox(
                  height: 4,
                ),
                pw.Text('Dicount\$: ${localReceiptData['discountValue']}',
                    style: pw.TextStyle(
                      fontSize: 7,
                      font: txtNormalFont,
                    ))
              ],
            )),
        pw.Container(
            decoration: pw.BoxDecoration(
                border: last
                    ? null
                    : const pw.Border(
                        bottom:
                            pw.BorderSide(color: PdfColors.black, width: 1.5),
                      )),
            height: height,
            width: 70,
            alignment: pw.Alignment.centerLeft,
            padding: const pw.EdgeInsets.only(left: 20),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  height: 4,
                ),
                pw.Text(
                  localReceiptData['qty'],
                  style: pw.TextStyle(font: txtNormalFont, fontSize: 7),
                ),
              ],
            )),
        pw.Container(
            decoration: pw.BoxDecoration(
                border: last
                    ? null
                    : const pw.Border(
                        bottom:
                            pw.BorderSide(color: PdfColors.black, width: 1.5),
                      )),
            height: height,
            width: 75,
            alignment: pw.Alignment.centerLeft,
            padding: const pw.EdgeInsets.only(left: 20),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  height: 4,
                ),
                pw.Text(
                  localReceiptData['total'],
                  style: pw.TextStyle(
                    fontSize: 7,
                    font: txtNormalFont,
                  ),
                ),
              ],
            )),
      ]);
}
