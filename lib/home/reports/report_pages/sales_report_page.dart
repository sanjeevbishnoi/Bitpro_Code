import 'package:intl/intl.dart';
import 'package:bitpro_hive/shared/global_variables/static_text_translate.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../model/receipt/db_receipt_data.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

calculateTotalCost(DbReceiptData d) {
  double totalCost = 0;
  for (var i in d.selectedItems) {
    totalCost += double.parse(i['cost']);
  }
  return totalCost;
}

double repFontSize = 10.0;

salesReportPage(
    {required DateTime? fromDate,
    required DateTime? toDate,
    required double totalQty,
    required double tax,
    required double totalDiscount,
    required double total,
    required double totalCost,
    required double taxPer,
    required List<DbReceiptData> sortedDbReceiptDataLst}) async {
  // print(sortedDbReceiptDataLst.length);
  final doc = pw.Document();

  var image = await imageFromAssetBundle('assets/Bitpro.png');
  final arabicNormalFont =
      await fontFromAssetBundle('assets/Segoe.UI_.Semibold.ttf');

  doc.addPage(pw.MultiPage(
      orientation: pw.PageOrientation.natural,
      pageFormat: PdfPageFormat.a4.landscape,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      margin: const pw.EdgeInsets.all(15),
      header: (c) {
        if (c.pageNumber != 1) {
          return pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 15),
              child: pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(4),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FlexColumnWidth(2),
                  5: const pw.FlexColumnWidth(2),
                  6: const pw.FlexColumnWidth(2),
                  7: const pw.FlexColumnWidth(3),
                },
                children: [
                  pw.TableRow(
                      decoration: const pw.BoxDecoration(
                          border: pw.Border(
                        bottom: pw.BorderSide(color: PdfColors.black, width: 2),
                      )),
                      children: [
                        pw.Container(
                            height: 50,
                            width: 10,
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'فاتورة#',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    fontSize: repFontSize,
                                    font: arabicNormalFont,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 4,
                                ),
                                pw.Text('Receipt#',
                                    style: pw.TextStyle(
                                      fontSize: repFontSize,
                                    ))
                              ],
                            )),
                        pw.Container(
                            height: 50,
                            width: 80,
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'نوع الفاتورة',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    fontSize: repFontSize,
                                    font: arabicNormalFont,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 4,
                                ),
                                pw.Text('Type',
                                    style: pw.TextStyle(
                                      fontSize: repFontSize,
                                    ))
                              ],
                            )),
                        pw.Container(
                            height: 50,
                            width: 150,
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'تاريخ',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    fontSize: repFontSize,
                                    font: arabicNormalFont,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 4,
                                ),
                                pw.Text('Date',
                                    style: pw.TextStyle(
                                      fontSize: repFontSize,
                                    ))
                              ],
                            )),
                        pw.Container(
                            height: 50,
                            width: 95,
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Text(
                                  'كمية',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    fontSize: repFontSize,
                                    font: arabicNormalFont,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 4,
                                ),
                                pw.Text('Qty',
                                    style: pw.TextStyle(
                                      fontSize: repFontSize,
                                    ))
                              ],
                            )),
                        pw.Container(
                            height: 50,
                            width: 85,
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Text(
                                  'تكلفة',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    fontSize: repFontSize,
                                    font: arabicNormalFont,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 4,
                                ),
                                pw.Text('Cost',
                                    style: pw.TextStyle(
                                      fontSize: repFontSize,
                                    ))
                              ],
                            )),
                        pw.Container(
                            height: 50,
                            width: 85,
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Text(
                                  'الضريبة',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    fontSize: repFontSize,
                                    font: arabicNormalFont,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 4,
                                ),
                                pw.Text(
                                    'Tax(${sortedDbReceiptDataLst.first.taxPer}%)',
                                    style: pw.TextStyle(
                                      fontSize: repFontSize,
                                    ))
                              ],
                            )),
                        pw.Container(
                            height: 50,
                            width: 85,
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Text(
                                  'خصم',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    fontSize: repFontSize,
                                    font: arabicNormalFont,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 4,
                                ),
                                pw.Text('Dis. \$',
                                    style: pw.TextStyle(
                                      fontSize: repFontSize,
                                    ))
                              ],
                            )),
                        pw.Container(
                            height: 50,
                            width: 85,
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Text(
                                  'الاجمالي',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    fontSize: repFontSize,
                                    font: arabicNormalFont,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 4,
                                ),
                                pw.Text('Invoice Total',
                                    style: pw.TextStyle(
                                      fontSize: repFontSize,
                                    ))
                              ],
                            )),
                      ]),
                ],
              ));
        }
        return pw.SizedBox();
      },
      footer: (c) {
        return pw.Row(children: [
          pw.Expanded(child: pw.SizedBox(width: 5)),
          pw.Text('Page ${c.pageNumber} of ${c.pagesCount}',
              style: const pw.TextStyle(fontSize: 9)),
          pw.SizedBox(width: 20)
        ]);
      },
      build: (context) {
        return [
          pw.Container(
              color: PdfColors.white,
              child: pw.Container(
                  decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(4)),
                  alignment: pw.Alignment.centerLeft,
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12, vertical: 15),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Image(image, height: 35),
                            pw.Column(
                              children: [
                                pw.Text(
                                  'Sales Journal',
                                  style: pw.TextStyle(
                                    fontSize: repFontSize,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 5,
                                ),
                                pw.Text(
                                  'Date : ${DateFormat('dd-MM-yyyy').format(fromDate!)} to ${DateFormat('dd-MM-yyyy').format(toDate!)}',
                                  style: pw.TextStyle(fontSize: repFontSize),
                                ),
                              ],
                            ),
                            pw.Text(
                              'Printed on : ${DateFormat('dd-MM-yyyy').format(DateTime.now())}',
                              style: pw.TextStyle(fontSize: repFontSize),
                            ),
                          ],
                        ),
                        pw.SizedBox(
                          height: 25,
                        ),
                        pw.Container(
                          color: const PdfColor.fromInt(0xff2a77b5),
                          padding: const pw.EdgeInsets.symmetric(
                              vertical: 5, horizontal: 5),
                          width: double.maxFinite,
                          child: pw.Text(
                            'Sales Journal',
                            style: pw.TextStyle(
                                fontSize: repFontSize, color: PdfColors.white),
                          ),
                        ),
                        pw.Table(
                          columnWidths: {
                            0: const pw.FlexColumnWidth(2),
                            1: const pw.FlexColumnWidth(2),
                            2: const pw.FlexColumnWidth(4),
                            3: const pw.FlexColumnWidth(2),
                            4: const pw.FlexColumnWidth(2),
                            5: const pw.FlexColumnWidth(2),
                            6: const pw.FlexColumnWidth(2),
                            7: const pw.FlexColumnWidth(3),
                          },
                          children: [
                            pw.TableRow(
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                  bottom: pw.BorderSide(
                                      color: PdfColors.black, width: 2),
                                )),
                                children: [
                                  pw.Container(
                                      height: 50,
                                      width: 10,
                                      child: pw.Column(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Text(
                                            'فاتورة#',
                                            textDirection: pw.TextDirection.rtl,
                                            style: pw.TextStyle(
                                              fontSize: repFontSize,
                                              font: arabicNormalFont,
                                            ),
                                          ),
                                          pw.SizedBox(
                                            height: 4,
                                          ),
                                          pw.Text('Receipt#',
                                              style: pw.TextStyle(
                                                fontSize: repFontSize,
                                              ))
                                        ],
                                      )),
                                  pw.Container(
                                      height: 50,
                                      width: 80,
                                      child: pw.Column(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Text(
                                            'نوع الفاتورة',
                                            textDirection: pw.TextDirection.rtl,
                                            style: pw.TextStyle(
                                              fontSize: repFontSize,
                                              font: arabicNormalFont,
                                            ),
                                          ),
                                          pw.SizedBox(
                                            height: 4,
                                          ),
                                          pw.Text('Type',
                                              style: pw.TextStyle(
                                                fontSize: repFontSize,
                                              ))
                                        ],
                                      )),
                                  pw.Container(
                                      height: 50,
                                      width: 150,
                                      child: pw.Column(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Text(
                                            'تاريخ',
                                            textDirection: pw.TextDirection.rtl,
                                            style: pw.TextStyle(
                                              fontSize: repFontSize,
                                              font: arabicNormalFont,
                                            ),
                                          ),
                                          pw.SizedBox(
                                            height: 4,
                                          ),
                                          pw.Text('Date',
                                              style: pw.TextStyle(
                                                fontSize: repFontSize,
                                              ))
                                        ],
                                      )),
                                  pw.Container(
                                      height: 50,
                                      width: 95,
                                      child: pw.Column(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.end,
                                        children: [
                                          pw.Text(
                                            'كمية',
                                            textDirection: pw.TextDirection.rtl,
                                            style: pw.TextStyle(
                                              fontSize: repFontSize,
                                              font: arabicNormalFont,
                                            ),
                                          ),
                                          pw.SizedBox(
                                            height: 4,
                                          ),
                                          pw.Text('Qty',
                                              style: pw.TextStyle(
                                                fontSize: repFontSize,
                                              ))
                                        ],
                                      )),
                                  pw.Container(
                                      height: 50,
                                      width: 85,
                                      child: pw.Column(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.end,
                                        children: [
                                          pw.Text(
                                            'تكلفة',
                                            textDirection: pw.TextDirection.rtl,
                                            style: pw.TextStyle(
                                              fontSize: repFontSize,
                                              font: arabicNormalFont,
                                            ),
                                          ),
                                          pw.SizedBox(
                                            height: 4,
                                          ),
                                          pw.Text('Cost',
                                              style: pw.TextStyle(
                                                fontSize: repFontSize,
                                              ))
                                        ],
                                      )),
                                  pw.Container(
                                      height: 50,
                                      width: 85,
                                      child: pw.Column(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.end,
                                        children: [
                                          pw.Text(
                                            'الضريبة',
                                            textDirection: pw.TextDirection.rtl,
                                            style: pw.TextStyle(
                                              fontSize: repFontSize,
                                              font: arabicNormalFont,
                                            ),
                                          ),
                                          pw.SizedBox(
                                            height: 4,
                                          ),
                                          pw.Text(
                                              'Tax(${sortedDbReceiptDataLst.first.taxPer}%)',
                                              style: pw.TextStyle(
                                                fontSize: repFontSize,
                                              ))
                                        ],
                                      )),
                                  pw.Container(
                                      height: 50,
                                      width: 85,
                                      child: pw.Column(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.end,
                                        children: [
                                          pw.Text(
                                            'خصم',
                                            textDirection: pw.TextDirection.rtl,
                                            style: pw.TextStyle(
                                              fontSize: repFontSize,
                                              font: arabicNormalFont,
                                            ),
                                          ),
                                          pw.SizedBox(
                                            height: 4,
                                          ),
                                          pw.Text('Dis. \$',
                                              style: pw.TextStyle(
                                                fontSize: repFontSize,
                                              ))
                                        ],
                                      )),
                                  pw.Container(
                                      height: 50,
                                      width: 85,
                                      child: pw.Column(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.center,
                                        children: [
                                          pw.Text(
                                            'الاجمالي',
                                            textDirection: pw.TextDirection.rtl,
                                            style: pw.TextStyle(
                                              fontSize: repFontSize,
                                              font: arabicNormalFont,
                                            ),
                                          ),
                                          pw.SizedBox(
                                            height: 4,
                                          ),
                                          pw.Text('Invoice Total',
                                              style: pw.TextStyle(
                                                fontSize: repFontSize,
                                              ))
                                        ],
                                      )),
                                ]),
                          ],
                        ),
                        for (var d in sortedDbReceiptDataLst)
                          pw.Container(
                            decoration: const pw.BoxDecoration(
                                border: pw.Border(
                              bottom: pw.BorderSide(color: PdfColors.black),
                            )),
                            child: pw.Row(children: [
                              pw.Container(
                                  width: 85,
                                  height: 20,
                                  alignment: pw.Alignment.centerLeft,
                                  child: pw.Text(
                                    d.receiptNo,
                                    style: pw.TextStyle(
                                        fontSize: repFontSize,
                                        color: d.receiptType == 'Return'
                                            ? PdfColors.red
                                            : PdfColors.black),
                                  )),
                              pw.Container(
                                  height: 20,
                                  width: 80,
                                  alignment: pw.Alignment.centerLeft,
                                  child: pw.Text(
                                    d.receiptType,
                                    style: pw.TextStyle(
                                        fontSize: repFontSize,
                                        color: d.receiptType == 'Return'
                                            ? PdfColors.red
                                            : PdfColors.black),
                                  )),
                              pw.Container(
                                  height: 20,
                                  width: 168,
                                  alignment: pw.Alignment.centerLeft,
                                  child: pw.Text(
                                    DateFormat('MM-dd-yyyy HH:mm a')
                                        .format(d.createdDate),
                                    style: pw.TextStyle(
                                        fontSize: repFontSize,
                                        color: d.receiptType == 'Return'
                                            ? PdfColors.red
                                            : PdfColors.black),
                                  )),
                              pw.Container(
                                  height: 20,
                                  width: 83,
                                  alignment: pw.Alignment.centerRight,
                                  child: pw.Text(
                                    (d.receiptType == 'Return' ? '-' : '') +
                                        d.totalQty,
                                    style: pw.TextStyle(
                                        fontSize: repFontSize,
                                        color: d.receiptType == 'Return'
                                            ? PdfColors.red
                                            : PdfColors.black),
                                  )),
                              pw.Container(
                                  height: 20,
                                  width: 83,
                                  alignment: pw.Alignment.centerRight,
                                  child: pw.Text(
                                    (d.receiptType == 'Return' ? '-' : '') +
                                        (double.parse(d.totalQty) *
                                                calculateTotalCost(d))
                                            .toStringAsFixed(2),
                                    style: pw.TextStyle(
                                        fontSize: repFontSize,
                                        color: d.receiptType == 'Return'
                                            ? PdfColors.red
                                            : PdfColors.black),
                                  )),
                              pw.Container(
                                  height: 20,
                                  width: 83,
                                  alignment: pw.Alignment.centerRight,
                                  child: pw.Text(
                                    (d.receiptType == 'Return' ? '-' : '') +
                                        d.taxValue,
                                    style: pw.TextStyle(
                                        fontSize: repFontSize,
                                        color: d.receiptType == 'Return'
                                            ? PdfColors.red
                                            : PdfColors.black),
                                  )),
                              pw.Container(
                                  height: 20,
                                  width: 83,
                                  alignment: pw.Alignment.centerRight,
                                  child: pw.Text(
                                    (d.receiptType == 'Return' ? '-' : '') +
                                        d.discountValue,
                                    style: pw.TextStyle(
                                        fontSize: repFontSize,
                                        color: d.receiptType == 'Return'
                                            ? PdfColors.red
                                            : PdfColors.black),
                                  )),
                              pw.Container(
                                  height: 20,
                                  width: 90,
                                  alignment: pw.Alignment.centerRight,
                                  child: pw.Text(
                                    (d.receiptType == 'Return' ? '-' : '') +
                                        d.receiptTotal,
                                    style: pw.TextStyle(
                                        fontSize: repFontSize,
                                        color: d.receiptType == 'Return'
                                            ? PdfColors.red
                                            : PdfColors.black),
                                  )),
                            ]),
                          ),
                        pw.SizedBox(
                          height: 4,
                        ),
                        pw.Table(
                          columnWidths: {
                            //   0: const pw.FlexColumnWidth(2),
                            // 1: const pw.FlexColumnWidth(2),
                            // 2: const pw.FlexColumnWidth(4),
                            // 3: const pw.FlexColumnWidth(2),
                            // 4: const pw.FlexColumnWidth(2),
                            // 5: const pw.FlexColumnWidth(2),
                            // 6: const pw.FlexColumnWidth(2),
                            // 7: const pw.FlexColumnWidth(3),

                            0: const pw.FlexColumnWidth(8),
                            1: const pw.FlexColumnWidth(2),
                            2: const pw.FlexColumnWidth(2),
                            3: const pw.FlexColumnWidth(2),
                            4: const pw.FlexColumnWidth(2),
                            5: const pw.FlexColumnWidth(3),
                          },
                          children: [
                            pw.TableRow(
                                decoration: const pw.BoxDecoration(
                                  color: PdfColor.fromInt(0xff2a77b5),
                                ),
                                children: [
                                  pw.Container(
                                      height: 32,
                                      padding: const pw.EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: pw.Column(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Text(staticTextTranslate('Totals'),
                                              style: pw.TextStyle(
                                                  fontSize: engSelectedLanguage
                                                      ? repFontSize
                                                      : repFontSize,
                                                  color: PdfColors.white,
                                                  fontWeight:
                                                      pw.FontWeight.bold))
                                        ],
                                      )),
                                  pw.Container(
                                      height: 30,
                                      child: pw.Column(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.end,
                                        children: [
                                          pw.Text(
                                            'كمية',
                                            textDirection: pw.TextDirection.rtl,
                                            style: pw.TextStyle(
                                              fontSize: repFontSize,
                                              font: arabicNormalFont,
                                              color: PdfColors.white,
                                            ),
                                          ),
                                          pw.SizedBox(
                                            height: 1,
                                          ),
                                          pw.Text('Tot. Qty',
                                              style: pw.TextStyle(
                                                fontSize: repFontSize,
                                                color: PdfColors.white,
                                              ))
                                        ],
                                      )),
                                  pw.Container(
                                      height: 30,
                                      child: pw.Column(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.end,
                                        children: [
                                          pw.Text(
                                            'تكلفة',
                                            textDirection: pw.TextDirection.rtl,
                                            style: pw.TextStyle(
                                              fontSize: repFontSize,
                                              font: arabicNormalFont,
                                              color: PdfColors.white,
                                            ),
                                          ),
                                          pw.SizedBox(
                                            height: 1,
                                          ),
                                          pw.Text('Tot. Cost',
                                              style: pw.TextStyle(
                                                fontSize: repFontSize,
                                                color: PdfColors.white,
                                              ))
                                        ],
                                      )),
                                  pw.Container(
                                      height: 30,
                                      child: pw.Column(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.end,
                                        children: [
                                          pw.Text(
                                            'ضريبة',
                                            textDirection: pw.TextDirection.rtl,
                                            style: pw.TextStyle(
                                              fontSize: repFontSize,
                                              font: arabicNormalFont,
                                              color: PdfColors.white,
                                            ),
                                          ),
                                          pw.SizedBox(
                                            height: 1,
                                          ),
                                          pw.Text('Tax($taxPer%)',
                                              style: pw.TextStyle(
                                                fontSize: repFontSize,
                                                color: PdfColors.white,
                                              ))
                                        ],
                                      )),
                                  pw.Container(
                                      height: 30,
                                      child: pw.Column(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.end,
                                        children: [
                                          pw.Text(
                                            'خصم',
                                            textDirection: pw.TextDirection.rtl,
                                            style: pw.TextStyle(
                                              fontSize: repFontSize,
                                              font: arabicNormalFont,
                                              color: PdfColors.white,
                                            ),
                                          ),
                                          pw.SizedBox(
                                            height: 1,
                                          ),
                                          pw.Text('Dis. \$',
                                              style: pw.TextStyle(
                                                fontSize: repFontSize,
                                                color: PdfColors.white,
                                              ))
                                        ],
                                      )),
                                  pw.Container(
                                      height: 30,
                                      child: pw.Column(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.center,
                                        children: [
                                          pw.Text(
                                            'الاجمالي',
                                            textDirection: pw.TextDirection.rtl,
                                            style: pw.TextStyle(
                                              fontSize: repFontSize,
                                              font: arabicNormalFont,
                                              color: PdfColors.white,
                                            ),
                                          ),
                                          pw.SizedBox(
                                            height: 1,
                                          ),
                                          pw.Text('Total',
                                              style: pw.TextStyle(
                                                fontSize: repFontSize,
                                                color: PdfColors.white,
                                              ))
                                        ],
                                      ))
                                ]),
                            pw.TableRow(
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                  bottom: pw.BorderSide(color: PdfColors.black),
                                )),
                                children: [
                                  pw.Container(
                                      height: 20,
                                      alignment: pw.Alignment.centerLeft,
                                      child: pw.Text(
                                        '',
                                      )),
                                  pw.Container(
                                      height: 20,
                                      alignment: pw.Alignment.centerRight,
                                      child:
                                          pw.Text(totalQty.toStringAsFixed(2),
                                              style: pw.TextStyle(
                                                fontSize: repFontSize,
                                              ))),
                                  pw.Container(
                                      height: 20,
                                      alignment: pw.Alignment.centerRight,
                                      child:
                                          pw.Text(totalCost.toStringAsFixed(2),
                                              style: pw.TextStyle(
                                                fontSize: repFontSize,
                                              ))),
                                  pw.Container(
                                      height: 20,
                                      alignment: pw.Alignment.centerRight,
                                      child: pw.Text(tax.toStringAsFixed(2),
                                          style: pw.TextStyle(
                                            fontSize: repFontSize,
                                          ))),
                                  pw.Container(
                                      height: 20,
                                      alignment: pw.Alignment.centerRight,
                                      child: pw.Text(
                                          totalDiscount.toStringAsFixed(2),
                                          style: pw.TextStyle(
                                            fontSize: repFontSize,
                                          ))),
                                  pw.Container(
                                      height: 20,
                                      alignment: pw.Alignment.center,
                                      child: pw.Text(total.toStringAsFixed(2),
                                          style: pw.TextStyle(
                                            fontSize: repFontSize,
                                          ))),
                                ])
                          ],
                        ),
                      ])))
        ];
      }));
  return await doc.save();
}
