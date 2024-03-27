import 'package:intl/intl.dart';
import 'package:bitpro_hive/shared/global_variables/static_text_translate.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../model/receipt/db_receipt_data.dart';
import '../../../model/voucher/db_voucher_data.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../../shared/global_variables/font_sizes.dart';

taxReportPage(
    {required DateTime? fromDate,
    required DateTime? toDate,
    required double taxPer,
    required List<DbReceiptData> sortedDbReceiptDataLst,
    required List<DbVoucherData> sortedDbVoucherDataLst,
    required double salesTaxValue,
    required double salesTotalSalesWithTax,
    required double salesTotalSales,
    required double purTaxValue,
    required double purTotalSalesWithTax}) async {
  final doc = pw.Document();

  var image = await imageFromAssetBundle('assets/Bitpro.png');
  final arabicNormalFont =
      await fontFromAssetBundle('assets/Segoe.UI_.Semibold.ttf');
  doc.addPage(pw.MultiPage(
      orientation: pw.PageOrientation.landscape,
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(10),
      footer: (c) {
        return pw.Row(children: [
          pw.Expanded(child: pw.SizedBox(width: 5)),
          pw.Text('Page ${c.pageNumber} of ${c.pagesCount}',
              style: const pw.TextStyle(fontSize: 9)),
          pw.SizedBox(width: 20)
        ]);
      },
      build: (pw.Context context) {
        return [
          pw.Container(
              color: PdfColors.white,
              child: pw.Container(
                  decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(4)),
                  alignment: pw.Alignment.centerLeft,
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 25, vertical: 20),
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
                                'Tax Report',
                                style: pw.TextStyle(
                                    fontSize: EnglishPrintFonts().smallFontSize,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                              pw.SizedBox(
                                height: 5,
                              ),
                              pw.Text(
                                'Date : ${DateFormat('dd-MM-yyyy').format(fromDate!)} to ${DateFormat('dd-MM-yyyy').format(toDate!)}',
                                style: pw.TextStyle(
                                    fontSize:
                                        EnglishPrintFonts().extraSmallFontSize),
                              ),
                            ],
                          ),
                          pw.Text(
                            'Printed on : ${DateFormat('dd-MM-yyyy').format(DateTime.now())}',
                            style: pw.TextStyle(
                                fontSize:
                                    EnglishPrintFonts().extraSmallFontSize),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 10),
                      // pw.Text(
                      //     'Date ${DateFormat('dd-MM-yyyy').format(fromDate!)} to ${DateFormat('dd-MM-yyyy').format(toDate!)}',
                      //     style: pw.TextStyle(
                      //       fontSize: EnglishPrintFonts().extraSmallFontSize,
                      //     )),
                      pw.SizedBox(
                        height: 10,
                      ),
                      pw.Container(
                        width: double.maxFinite,
                        color: const PdfColor.fromInt(0xff2a77b5),
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Text(
                          'Sales Vat Summary',
                          style: pw.TextStyle(
                              fontSize: EnglishPrintFonts().extraSmallFontSize,
                              color: PdfColors.white),
                        ),
                      ),
                      pw.Table(columnWidths: {
                        0: const pw.FlexColumnWidth(4),
                        1: const pw.FlexColumnWidth(4),
                        2: const pw.FlexColumnWidth(3),
                        3: const pw.FlexColumnWidth(3),
                      }, children: [
                        pw.TableRow(
                            decoration: const pw.BoxDecoration(
                                border: pw.Border(
                              bottom: pw.BorderSide(
                                  color: PdfColors.black, width: 1),
                            )),
                            children: [
                              pw.Container(
                                  height: 40,
                                  child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        'إجمالي المبيعات مع الضريبة',
                                        textDirection: pw.TextDirection.rtl,
                                        style: pw.TextStyle(
                                          font: arabicNormalFont,
                                          fontSize: ArabicPrintFonts()
                                              .extraSmallFontSize,
                                        ),
                                      ),
                                      pw.SizedBox(
                                        height: 1,
                                      ),
                                      pw.Text('Total Sales With Tax',
                                          style: pw.TextStyle(
                                            fontSize: EnglishPrintFonts()
                                                .extraSmallFontSize,
                                          ))
                                    ],
                                  )),
                              pw.Container(
                                  height: 40,
                                  child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        'إجمالي المبيعات',
                                        textDirection: pw.TextDirection.rtl,
                                        style: pw.TextStyle(
                                            fontSize: ArabicPrintFonts()
                                                .extraSmallFontSize,
                                            font: arabicNormalFont,
                                            fontWeight: pw.FontWeight.bold),
                                      ),
                                      pw.SizedBox(
                                        height: 1,
                                      ),
                                      pw.Text('Total Sales',
                                          style: pw.TextStyle(
                                            fontSize: EnglishPrintFonts()
                                                .extraSmallFontSize,
                                          ))
                                    ],
                                  )),
                              pw.Container(
                                  height: 40,
                                  child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        'الضريبة %',
                                        textDirection: pw.TextDirection.rtl,
                                        style: pw.TextStyle(
                                            fontSize: ArabicPrintFonts()
                                                .extraSmallFontSize,
                                            font: arabicNormalFont),
                                      ),
                                      pw.SizedBox(
                                        height: 1,
                                      ),
                                      pw.Text('Vat %',
                                          style: pw.TextStyle(
                                            fontSize: EnglishPrintFonts()
                                                .extraSmallFontSize,
                                          ))
                                    ],
                                  )),
                              pw.Container(
                                  height: 40,
                                  child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        'الضريبة \$',
                                        textDirection: pw.TextDirection.rtl,
                                        style: pw.TextStyle(
                                            fontSize: ArabicPrintFonts()
                                                .extraSmallFontSize,
                                            font: arabicNormalFont),
                                      ),
                                      pw.SizedBox(
                                        height: 1,
                                      ),
                                      pw.Text('Vat \$',
                                          style: pw.TextStyle(
                                            fontSize: EnglishPrintFonts()
                                                .extraSmallFontSize,
                                          ))
                                    ],
                                  )),
                            ]),
                        pw.TableRow(
                            decoration:
                                const pw.BoxDecoration(border: pw.Border()),
                            children: [
                              pw.Container(
                                  height: 30,
                                  child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                          salesTotalSalesWithTax
                                              .toStringAsFixed(2),
                                          style: pw.TextStyle(
                                            fontSize: EnglishPrintFonts()
                                                .extraSmallFontSize,
                                          ))
                                    ],
                                  )),
                              pw.Container(
                                  height: 30,
                                  child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                          salesTotalSales.toStringAsFixed(2),
                                          style: pw.TextStyle(
                                            fontSize: EnglishPrintFonts()
                                                .extraSmallFontSize,
                                          ))
                                    ],
                                  )),
                              pw.Container(
                                  height: 30,
                                  child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text('$taxPer%',
                                          style: pw.TextStyle(
                                            fontSize: EnglishPrintFonts()
                                                .extraSmallFontSize,
                                          ))
                                    ],
                                  )),
                              pw.Container(
                                  height: 30,
                                  child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(salesTaxValue.toStringAsFixed(2),
                                          style: pw.TextStyle(
                                            fontSize: EnglishPrintFonts()
                                                .extraSmallFontSize,
                                          ))
                                    ],
                                  )),
                            ]),
                      ]),
                      pw.SizedBox(
                        height: 15,
                      ),
                      pw.Container(
                        width: double.maxFinite,
                        color: const PdfColor.fromInt(0xff2a77b5),
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Text(
                          'Purchase Vat Summary',
                          style: pw.TextStyle(
                              fontSize: EnglishPrintFonts().extraSmallFontSize,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white),
                        ),
                      ),
                      pw.Table(columnWidths: {
                        0: const pw.FlexColumnWidth(4),
                        1: const pw.FlexColumnWidth(4),
                        2: const pw.FlexColumnWidth(3),
                        3: const pw.FlexColumnWidth(3),
                      }, children: [
                        pw.TableRow(
                            decoration: const pw.BoxDecoration(
                                border: pw.Border(
                              bottom: pw.BorderSide(
                                  color: PdfColors.black, width: 1),
                            )),
                            children: [
                              pw.Container(
                                  height: 40,
                                  child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        'الإجمالي مشتريات مع الضريبة',
                                        textDirection: pw.TextDirection.rtl,
                                        style: pw.TextStyle(
                                            fontSize: ArabicPrintFonts()
                                                .extraSmallFontSize,
                                            font: arabicNormalFont),
                                      ),
                                      pw.SizedBox(
                                        height: 1,
                                      ),
                                      pw.Text('Total Purchase With Tax',
                                          style: pw.TextStyle(
                                            fontSize: EnglishPrintFonts()
                                                .extraSmallFontSize,
                                          ))
                                    ],
                                  )),
                              pw.Container(
                                  height: 40,
                                  child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        'الإجمالي مشتريات',
                                        textDirection: pw.TextDirection.rtl,
                                        style: pw.TextStyle(
                                            fontSize: ArabicPrintFonts()
                                                .extraSmallFontSize,
                                            font: arabicNormalFont),
                                      ),
                                      pw.SizedBox(
                                        height: 1,
                                      ),
                                      pw.Text('Total Purchase',
                                          style: pw.TextStyle(
                                            fontSize: EnglishPrintFonts()
                                                .extraSmallFontSize,
                                          ))
                                    ],
                                  )),
                              pw.Container(
                                height: 40,
                                // child: pw.Column(
                                //   mainAxisAlignment:
                                //       pw.MainAxisAlignment.center,
                                //   crossAxisAlignment:
                                //       pw.CrossAxisAlignment.start,
                                //   children: [
                                //     pw.Text(
                                //       'الضريبة %',
                                //       textDirection: pw.TextDirection.rtl,
                                //       style: pw.TextStyle(
                                //           fontSize: ArabicPrintFonts()
                                //               .extraSmallFontSize,
                                //           font: arabicNormalFont),
                                //     ),
                                //     pw.SizedBox(
                                //       height: 1,
                                //     ),
                                //     pw.Text('Vat %',
                                //         style: pw.TextStyle(
                                //           fontSize: EnglishPrintFonts()
                                //               .extraSmallFontSize,
                                //         ))
                                //   ],
                                // )
                              ),
                              pw.Container(
                                  height: 40,
                                  child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        'الضريبة \$',
                                        textDirection: pw.TextDirection.rtl,
                                        style: pw.TextStyle(
                                            fontSize: ArabicPrintFonts()
                                                .extraSmallFontSize,
                                            font: arabicNormalFont),
                                      ),
                                      pw.SizedBox(
                                        height: 1,
                                      ),
                                      pw.Text('Vat \$',
                                          style: pw.TextStyle(
                                            fontSize: EnglishPrintFonts()
                                                .extraSmallFontSize,
                                          ))
                                    ],
                                  )),
                            ]),
                        pw.TableRow(
                            decoration:
                                const pw.BoxDecoration(border: pw.Border()),
                            children: [
                              pw.Container(
                                  height: 30,
                                  child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                          purTotalSalesWithTax
                                              .toStringAsFixed(2),
                                          style: pw.TextStyle(
                                            fontSize: EnglishPrintFonts()
                                                .extraSmallFontSize,
                                          ))
                                    ],
                                  )),
                              pw.Container(
                                  height: 30,
                                  child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                          (purTotalSalesWithTax - purTaxValue)
                                              .toStringAsFixed(2),
                                          style: pw.TextStyle(
                                            fontSize: EnglishPrintFonts()
                                                .extraSmallFontSize,
                                          ))
                                    ],
                                  )),
                              pw.Container(
                                height: 30,
                                // child:
                                //  pw.Column(
                                //   mainAxisAlignment:
                                //       pw.MainAxisAlignment.center,
                                //   crossAxisAlignment:
                                //       pw.CrossAxisAlignment.start,
                                //   children: [
                                //     pw.Text('$taxPer%',
                                //         style: pw.TextStyle(
                                //           fontSize: EnglishPrintFonts()
                                //               .extraSmallFontSize,
                                //         ))
                                //   ],
                                // )
                              ),
                              pw.Container(
                                  height: 30,
                                  child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(purTaxValue.toStringAsFixed(2),
                                          style: pw.TextStyle(
                                            fontSize: EnglishPrintFonts()
                                                .extraSmallFontSize,
                                          ))
                                    ],
                                  )),
                            ]),
                      ]),
                      pw.SizedBox(
                        height: 15,
                      ),
                      pw.Container(
                        width: double.maxFinite,
                        color: const PdfColor.fromInt(0xff2a77b5),
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Text(
                          staticTextTranslate('Payable Vat Summary'),
                          style: pw.TextStyle(
                              fontSize: engSelectedLanguage
                                  ? EnglishPrintFonts().extraSmallFontSize
                                  : ArabicPrintFonts().extraSmallFontSize,
                              color: PdfColors.white),
                        ),
                      ),
                      pw.Table(columnWidths: {
                        0: const pw.FlexColumnWidth(4),
                        1: const pw.FlexColumnWidth(4),
                        2: const pw.FlexColumnWidth(3),
                      }, children: [
                        pw.TableRow(
                            decoration: const pw.BoxDecoration(
                                border: pw.Border(
                              bottom: pw.BorderSide(
                                  color: PdfColors.black, width: 1),
                            )),
                            children: [
                              pw.Container(
                                  height: 40,
                                  child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        'إجمالي ضريبة المحصلة على المبيعات',
                                        textDirection: pw.TextDirection.rtl,
                                        style: pw.TextStyle(
                                            fontSize: ArabicPrintFonts()
                                                .extraSmallFontSize,
                                            font: arabicNormalFont),
                                      ),
                                      pw.SizedBox(
                                        height: 1,
                                      ),
                                      pw.Text('Total vat collected on sales',
                                          style: pw.TextStyle(
                                            fontSize: EnglishPrintFonts()
                                                .extraSmallFontSize,
                                          ))
                                    ],
                                  )),
                              pw.Container(
                                  height: 40,
                                  child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        'إجمالي ضريبة المدفوعة عند الشراء',
                                        textDirection: pw.TextDirection.rtl,
                                        style: pw.TextStyle(
                                          fontSize: ArabicPrintFonts()
                                              .extraSmallFontSize,
                                          font: arabicNormalFont,
                                        ),
                                      ),
                                      pw.SizedBox(
                                        height: 1,
                                      ),
                                      pw.Text('Total Vat Paid on Purchase',
                                          style: pw.TextStyle(
                                            fontSize: EnglishPrintFonts()
                                                .extraSmallFontSize,
                                          ))
                                    ],
                                  )),
                              pw.Container(
                                  height: 40,
                                  width: double.maxFinite,
                                  child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.center,
                                    children: [
                                      pw.Text(
                                        'ضريبة المستحقة',
                                        textDirection: pw.TextDirection.rtl,
                                        style: pw.TextStyle(
                                          fontSize: ArabicPrintFonts()
                                              .extraSmallFontSize,
                                          font: arabicNormalFont,
                                        ),
                                      ),
                                      pw.SizedBox(
                                        height: 1,
                                      ),
                                      pw.Text('Payable Vat Amount',
                                          style: pw.TextStyle(
                                            fontSize: EnglishPrintFonts()
                                                .extraSmallFontSize,
                                          ))
                                    ],
                                  )),
                            ]),
                        pw.TableRow(
                            decoration:
                                const pw.BoxDecoration(border: pw.Border()),
                            children: [
                              pw.Container(
                                  height: 30,
                                  child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(salesTaxValue.toStringAsFixed(2),
                                          style: pw.TextStyle(
                                            fontSize: EnglishPrintFonts()
                                                .extraSmallFontSize,
                                          ))
                                    ],
                                  )),
                              pw.Container(
                                  height: 30,
                                  width: double.maxFinite,
                                  child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(purTaxValue.toStringAsFixed(2),
                                          style: pw.TextStyle(
                                            fontSize: EnglishPrintFonts()
                                                .extraSmallFontSize,
                                          ))
                                    ],
                                  )),
                              pw.Container(
                                  height: 30,
                                  width: double.maxFinite,
                                  child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.center,
                                    children: [
                                      pw.Text(
                                          (salesTaxValue - purTaxValue)
                                              .toStringAsFixed(2),
                                          style: pw.TextStyle(
                                            fontSize: EnglishPrintFonts()
                                                .extraSmallFontSize,
                                          ))
                                    ],
                                  )),
                            ]),
                      ])
                    ],
                  )))
        ];
      }));
  return await doc.save();
}
