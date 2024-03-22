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

des0004A4ReceiptTemplate(
    {required image,
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
    required String tenderAmount,
    required String changeAmount,
    required StoreData selectedStoreData,
    CustomerData? selectedCustomerData,
    context}) {
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
                            pw.Row(
                              children: [
                                if (userPrintingData != null)
                                  pw.Text(
                                    userPrintingData['receiptTitleEng'],
                                    textAlign: pw.TextAlign.left,
                                    style: pw.TextStyle(
                                        font: txtBoldFont,
                                        fontSize: 8,
                                        fontWeight: pw.FontWeight.bold),
                                  ),
                                pw.SizedBox(
                                  width: 3,
                                ),
                                if (userPrintingData != null)
                                  pw.Text(
                                    userPrintingData['receiptTitleArb'],
                                    textAlign: pw.TextAlign.left,
                                    textDirection: pw.TextDirection.rtl,
                                    style: pw.TextStyle(
                                      font: arabicNormalFont,
                                      fontSize: 8,
                                    ),
                                  ),
                              ],
                            ),
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
                              height: 5,
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
                            pw.SizedBox(
                              height: 5,
                            ),
                            pw.Text(
                              'Tax No.:          ${selectedStoreData.vatNumber}',
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
                        pw.Align(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Image(image, height: 60),
                        ),
                      ]),
                  if (userPrintingData != null) pw.SizedBox(height: 15),
                  pw.Container(
                      width: double.maxFinite,
                      height: .1,
                      color: PdfColors.grey),
                  pw.SizedBox(
                    height: 5,
                  ),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(
                        width: 200,
                        child: selectedCustomerData == null ||
                                selectedCustomerData.customerName.isEmpty
                            ? pw.SizedBox()
                            : pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                children: [
                                    pw.Text(
                                      'Bill to',
                                      style: pw.TextStyle(
                                          font: txtBoldFont, fontSize: 8),
                                    ),
                                    pw.SizedBox(
                                      height: 5,
                                    ),
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
                                  ]),
                      ),
                      pw.Expanded(
                          child: pw.Container(
                              child: pw.Column(
                        children: [
                          pw.Align(
                              alignment: pw.Alignment.center,
                              child: pw.SvgImage(
                                  svg: buildBarcode(
                                      height: 55,
                                      width: 55,
                                      Barcode.qrCode(),
                                      getQrCodeContent(
                                        sellerName: userSettingsData == null
                                            ? ''
                                            : userSettingsData['companyName'],
                                        sellerTRN: selectedStoreData.vatNumber,
                                        totalWithVat: dbReceiptData.subTotal,
                                        vatPrice: taxValue,
                                      ))))
                        ],
                      ))),
                      pw.Expanded(
                        child: pw.Container(
                            child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Row(children: [
                                  pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(
                                          'Invoice No.:',
                                          style: pw.TextStyle(
                                            fontSize: 8,
                                            font: txtNormalFont,
                                          ),
                                        ),
                                        pw.SizedBox(height: 5),
                                        pw.Text(
                                          'Date:',
                                          style: pw.TextStyle(
                                            fontSize: 8,
                                            font: txtNormalFont,
                                          ),
                                        ),
                                        pw.SizedBox(height: 5),
                                        pw.Text(
                                          'Payment status:',
                                          style: pw.TextStyle(
                                            fontSize: 8,
                                            font: txtNormalFont,
                                          ),
                                        ),
                                      ]),
                                  pw.SizedBox(width: 10),
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
                                          DateFormat('dd/MM/yyyy').format(
                                              dbReceiptData.createdDate),
                                          style: pw.TextStyle(
                                            fontSize: 8,
                                            font: txtNormalFont,
                                          ),
                                        ),
                                        pw.SizedBox(height: 5),
                                        pw.Text(
                                          double.tryParse(dbReceiptData
                                                          .tendor.credit) !=
                                                      null &&
                                                  double.parse(dbReceiptData
                                                          .tendor.credit) !=
                                                      0
                                              ? 'Credit'
                                              : 'Paid',
                                          style: pw.TextStyle(
                                            fontSize: 8,
                                            font: txtNormalFont,
                                          ),
                                        ),
                                      ]),
                                ]),
                              ),
                            ])),
                      )
                    ],
                  ),
                ]),
            pw.SizedBox(
              height: 10,
            ),
            pw.Container(
              width: double.maxFinite,
              alignment: pw.Alignment.centerLeft,
              child: pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(6.5),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                  4: const pw.FlexColumnWidth(1.5),
                  5: const pw.FlexColumnWidth(1.5),
                  6: const pw.FlexColumnWidth(2.5)
                },
                children: [
                  pw.TableRow(children: [
                    pw.Container(
                        height: 18,
                        decoration: const pw.BoxDecoration(
                            border: pw.Border(
                          top: pw.BorderSide(
                              color: PdfColors.grey500, width: .3),
                          left: pw.BorderSide(
                              color: PdfColors.grey500, width: .3),
                          right: pw.BorderSide(
                              color: PdfColors.grey500, width: .3),
                          bottom: pw.BorderSide(
                              color: PdfColors.grey500, width: 3.5),
                        )),
                        alignment: pw.Alignment.center,
                        child: pw.Text('#',
                            style:
                                pw.TextStyle(fontSize: 8, font: txtBoldFont))),
                    pw.Container(
                        height: 18,
                        decoration: const pw.BoxDecoration(
                            border: pw.Border(
                          top: pw.BorderSide(
                              color: PdfColors.grey500, width: .3),
                          left: pw.BorderSide(
                              color: PdfColors.grey500, width: .3),
                          right: pw.BorderSide(
                              color: PdfColors.grey500, width: .3),
                          bottom: pw.BorderSide(
                              color: PdfColors.grey500, width: 3.5),
                        )),
                        alignment: pw.Alignment.center,
                        child: pw.Text('Item',
                            style:
                                pw.TextStyle(fontSize: 8, font: txtBoldFont))),
                    pw.Container(
                        height: 18,
                        decoration: const pw.BoxDecoration(
                            border: pw.Border(
                          top: pw.BorderSide(
                              color: PdfColors.grey500, width: .3),
                          left: pw.BorderSide(
                              color: PdfColors.grey500, width: .3),
                          right: pw.BorderSide(
                              color: PdfColors.grey500, width: .3),
                          bottom: pw.BorderSide(
                              color: PdfColors.grey500, width: 3.5),
                        )),
                        alignment: pw.Alignment.center,
                        child: pw.Text('Quantity',
                            style:
                                pw.TextStyle(fontSize: 8, font: txtBoldFont))),
                    pw.Container(
                        decoration: const pw.BoxDecoration(
                            border: pw.Border(
                          top: pw.BorderSide(
                              color: PdfColors.grey500, width: .3),
                          left: pw.BorderSide(
                              color: PdfColors.grey500, width: .3),
                          right: pw.BorderSide(
                              color: PdfColors.grey500, width: .3),
                          bottom: pw.BorderSide(
                              color: PdfColors.grey500, width: 3.5),
                        )),
                        height: 18,
                        alignment: pw.Alignment.center,
                        child: pw.Text('Unit Price',
                            style:
                                pw.TextStyle(fontSize: 8, font: txtBoldFont))),
                    pw.Container(
                        height: 18,
                        decoration: const pw.BoxDecoration(
                            border: pw.Border(
                          top: pw.BorderSide(
                              color: PdfColors.grey500, width: .3),
                          left: pw.BorderSide(
                              color: PdfColors.grey500, width: .3),
                          right: pw.BorderSide(
                              color: PdfColors.grey500, width: .3),
                          bottom: pw.BorderSide(
                              color: PdfColors.grey500, width: 3.5),
                        )),
                        alignment: pw.Alignment.center,
                        child: pw.Text('Tax',
                            style:
                                pw.TextStyle(fontSize: 8, font: txtBoldFont))),
                    pw.Container(
                        height: 18,
                        decoration: const pw.BoxDecoration(
                            border: pw.Border(
                          top: pw.BorderSide(
                              color: PdfColors.grey500, width: .3),
                          left: pw.BorderSide(
                              color: PdfColors.grey500, width: .3),
                          right: pw.BorderSide(
                              color: PdfColors.grey500, width: .3),
                          bottom: pw.BorderSide(
                              color: PdfColors.grey500, width: 3.5),
                        )),
                        alignment: pw.Alignment.center,
                        child: pw.Text('Discount',
                            style:
                                pw.TextStyle(fontSize: 8, font: txtBoldFont))),
                    pw.Container(
                        height: 18,
                        decoration: const pw.BoxDecoration(
                            border: pw.Border(
                          top: pw.BorderSide(
                              color: PdfColors.grey500, width: .3),
                          left: pw.BorderSide(
                              color: PdfColors.grey500, width: .3),
                          right: pw.BorderSide(
                              color: PdfColors.grey500, width: .3),
                          bottom: pw.BorderSide(
                              color: PdfColors.grey500, width: 3.5),
                        )),
                        alignment: pw.Alignment.center,
                        child: pw.Text('Total',
                            style:
                                pw.TextStyle(fontSize: 8, font: txtBoldFont))),
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
                  dbReceiptData,
                  dbReceiptData.selectedItems.indexOf(localReceiptData)),
            pw.SizedBox(height: 10),
            getBottomTotalCalucations(txtBoldFont, arabicNormalFont,
                dbReceiptData, tenderAmount, changeAmount),
            pw.SizedBox(height: 10),
          ]));
}

getBottomTotalCalucations(txtBoldFont, arabicNormalFont,
    DbReceiptData dbReceiptData, tendorAmount, changeAmount) {
  double subTotal = 0;
  double vatTotal = 0;
  double total = 0;

  for (var i in dbReceiptData.selectedItems) {
    total += double.parse(i['total']);
  }
  vatTotal = double.parse(calculateTaxValue(total, dbReceiptData.taxPer));
  subTotal = total - vatTotal;

  return pw.Column(children: [
    pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
      pw.Column(children: [
        pw.Container(
            height: 20,
            width: 88,
            decoration: pw.BoxDecoration(
                border: pw.Border.all(
              color: PdfColors.grey500,
              width: .3,
            )),
            padding: const pw.EdgeInsets.all(5),
            alignment: pw.Alignment.centerLeft,
            child: pw.Text('Subtotal',
                style: pw.TextStyle(fontSize: 8, font: txtBoldFont))),
        pw.Container(
            height: 20,
            width: 88,
            decoration: pw.BoxDecoration(
                border: pw.Border.all(
              color: PdfColors.grey500,
              width: .3,
            )),
            padding: const pw.EdgeInsets.all(5),
            alignment: pw.Alignment.centerLeft,
            child: pw.Text('VAT',
                style: pw.TextStyle(fontSize: 8, font: txtBoldFont))),
        pw.Container(
            height: 20,
            width: 88,
            decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xfff5f5f5),
                border: pw.Border.all(
                  color: PdfColors.grey500,
                  width: .3,
                )),
            padding: const pw.EdgeInsets.all(5),
            alignment: pw.Alignment.centerLeft,
            child: pw.Text('Total',
                style: pw.TextStyle(fontSize: 8, font: txtBoldFont))),
      ]),
      pw.Column(children: [
        pw.Container(
            height: 20,
            width: 88,
            decoration: pw.BoxDecoration(
                border: pw.Border.all(
              color: PdfColors.grey500,
              width: .3,
            )),
            padding: const pw.EdgeInsets.all(5),
            alignment: pw.Alignment.centerRight,
            child: pw.Text('SR ${subTotal.toStringAsFixed(2)}',
                style: pw.TextStyle(fontSize: 8, font: txtBoldFont))),
        pw.Container(
            height: 20,
            width: 88,
            decoration: pw.BoxDecoration(
                border: pw.Border.all(
              color: PdfColors.grey500,
              width: .3,
            )),
            padding: const pw.EdgeInsets.all(5),
            alignment: pw.Alignment.centerRight,
            child: pw.Text('SR ${vatTotal.toStringAsFixed(2)}',
                style: pw.TextStyle(fontSize: 8, font: txtBoldFont))),
        pw.Container(
            height: 20,
            width: 88,
            decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xfff5f5f5),
                border: pw.Border.all(
                  color: PdfColors.grey500,
                  width: .3,
                )),
            padding: const pw.EdgeInsets.all(5),
            alignment: pw.Alignment.centerRight,
            child: pw.Text('SR ${total.toStringAsFixed(2)}',
                style: pw.TextStyle(fontSize: 8, font: txtBoldFont))),
      ]),
    ]),
    pw.SizedBox(height: 10),
    pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.SizedBox(
        width: 88 * 2,
        child: pw.Column(children: [
          pw.Row(
            children: List.generate(
                1000 ~/ 10,
                (index) => pw.Expanded(
                      child: pw.Container(
                        color: index % 2 == 0 ? null : PdfColors.grey,
                        height: .5,
                      ),
                    )),
          ),
          pw.SizedBox(height: 4),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Payment method:',
                    style: pw.TextStyle(fontSize: 8, font: txtBoldFont)),
                pw.Text(
                    dbReceiptData.tendor.credit != '0' &&
                            dbReceiptData.tendor.credit != '0.0'
                        ? 'Credit'
                        : dbReceiptData.tendor.cash != '0' &&
                                dbReceiptData.tendor.creditCard == '0'
                            ? 'Cash'
                            : dbReceiptData.tendor.cash == '0' &&
                                    dbReceiptData.tendor.creditCard != '0'
                                ? 'Credit Card'
                                : 'Split',
                    style: pw.TextStyle(fontSize: 8, font: txtBoldFont))
              ]),
          pw.SizedBox(height: 4),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Paid amount:',
                    style: pw.TextStyle(fontSize: 8, font: txtBoldFont)),
                pw.Text(
                    dbReceiptData.tendor.credit != '0' &&
                            dbReceiptData.tendor.credit != '0.0'
                        ? 'SR 0'
                        : 'SR ' + tendorAmount,
                    style: pw.TextStyle(fontSize: 8, font: txtBoldFont))
              ]),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Change:',
                  style: pw.TextStyle(fontSize: 8, font: txtBoldFont)),
              pw.Text(dbReceiptData.tendor.balance,
                  style: pw.TextStyle(fontSize: 8, font: txtBoldFont))
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Amount due:',
                  style: pw.TextStyle(fontSize: 8, font: txtBoldFont)),
              pw.Text(
                  dbReceiptData.tendor.credit != '0' &&
                          dbReceiptData.tendor.credit != '0.0'
                      ? 'SR ${dbReceiptData.tendor.credit}'
                      : 'SR 0',
                  style: pw.TextStyle(fontSize: 8, font: txtBoldFont))
            ],
          ),
        ]),
      ),
    ),
  ]);
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

productTile(txtNormalFont, localReceiptData, arabicFont, vatPercentage,
    bool last, dbReceiptData, int i) {
  double height = 15;
  int nol = (localReceiptData['productName'].toString().length / 50).ceil();

  if (nol != 1) {
    height += 10 * (nol - 1);
  }
  return pw.Row(children: [
    pw.Container(
      decoration: pw.BoxDecoration(
          color: i.isOdd ? const PdfColor.fromInt(0xfff5f5f5) : null,
          border: pw.Border.all(width: 0.2, color: PdfColors.grey)),
      height: height,
      width: 35,
      alignment: pw.Alignment.centerLeft,
      padding: const pw.EdgeInsets.all(3),
      child: pw.Text(
        '${i + 1}',
        style: pw.TextStyle(font: txtNormalFont, fontSize: 8),
      ),
    ),
    pw.Container(
      decoration: pw.BoxDecoration(
          color: i.isOdd ? const PdfColor.fromInt(0xfff5f5f5) : null,
          border: pw.Border.all(width: 0.2, color: PdfColors.grey)),
      height: height,
      width: 230,
      padding: const pw.EdgeInsets.all(3),
      child: pw.Text(localReceiptData['productName'],
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
            color: i.isOdd ? const PdfColor.fromInt(0xfff5f5f5) : null,
            border: pw.Border.all(width: 0.2, color: PdfColors.grey)),
        height: height,
        alignment: pw.Alignment.centerRight,
        width: 53,
        padding: const pw.EdgeInsets.all(3),
        child: pw.Text(
          localReceiptData['qty'],
          style: pw.TextStyle(font: txtNormalFont, fontSize: 8),
        )),
    pw.Container(
        decoration: pw.BoxDecoration(
            color: i.isOdd ? const PdfColor.fromInt(0xfff5f5f5) : null,
            border: pw.Border.all(width: 0.2, color: PdfColors.grey)),
        height: height,
        alignment: pw.Alignment.centerRight,
        width: 53,
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
            color: i.isOdd ? const PdfColor.fromInt(0xfff5f5f5) : null,
            border: pw.Border.all(width: 0.2, color: PdfColors.grey)),
        height: height,
        alignment: pw.Alignment.centerRight,
        width: 53,
        padding: const pw.EdgeInsets.all(3),
        child: pw.Text('${dbReceiptData.taxPer}%',
            style: pw.TextStyle(
              fontSize: 8,
              font: txtNormalFont,
            ))),
    pw.Container(
        decoration: pw.BoxDecoration(
            color: i.isOdd ? const PdfColor.fromInt(0xfff5f5f5) : null,
            border: pw.Border.all(width: 0.2, color: PdfColors.grey)),
        height: height,
        alignment: pw.Alignment.centerRight,
        width: 53,
        padding: const pw.EdgeInsets.all(3),
        child: pw.Text(localReceiptData['discountPercentage'] + '%',
            style: pw.TextStyle(
              fontSize: 8,
              font: txtNormalFont,
            ))),
    pw.Container(
        decoration: pw.BoxDecoration(
            color: i.isOdd ? const PdfColor.fromInt(0xfff5f5f5) : null,
            border: pw.Border.all(width: 0.2, color: PdfColors.grey)),
        height: height,
        alignment: pw.Alignment.centerRight,
        width: 88,
        padding: const pw.EdgeInsets.all(3),
        child:
            pw.Text(double.parse(localReceiptData['total']).toStringAsFixed(2),
                style: pw.TextStyle(
                  fontSize: 8,
                  font: txtNormalFont,
                ))),
  ]);
}
