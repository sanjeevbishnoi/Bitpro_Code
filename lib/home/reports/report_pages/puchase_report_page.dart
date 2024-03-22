import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:bitpro_hive/shared/global_variables/static_text_translate.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../model/inventory_data.dart';
import '../../../model/voucher/db_voucher_data.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../../model/voucher/local_voucher_data.dart';

String calculateTaxValue(
    {required DbVoucherData dbVoucherData,
    required List<InventoryData> inventoryDataLst}) {
  double t = 0;
  for (LocalVoucherData v in getFullVoucherData(
      selectedItems: dbVoucherData.selectedItems,
      inventoryDataLst: inventoryDataLst)) {
    double d = 0;
    d = double.tryParse(v.cost) ?? 0;
    if (double.tryParse(v.qty) != null) t += d * double.tryParse(v.qty)!;
  }
  if (dbVoucherData.discountValue.isNotEmpty) {
    double dis = double.tryParse(dbVoucherData.discountValue) ?? 0;
    if (dis != 0) {
      t = t - dis;
    }
  }
  double taxValue = 0;
  //tax
  if (dbVoucherData.tax.isNotEmpty) {
    double tx = double.tryParse(dbVoucherData.tax) ?? 0;

    if (tx != 0) taxValue = (t * tx / 100);
  }

  return taxValue.toStringAsFixed(2);
}

List<LocalVoucherData> getFullVoucherData(
    {selectedItems, required List<InventoryData> inventoryDataLst}) {
  List<LocalVoucherData> fullVoucherData = [];
  for (var b in selectedItems) {
    InventoryData inv = inventoryDataLst.firstWhere(
        (element) => element.barcode == b['barcode'],
        orElse: () => InventoryData(
            createdBy: '',
            createdDate: DateTime.now(),
            description: '',
            margin: '',
            ohQtyForDifferentStores: {},
            priceWT: '',
            productImg: '',
            selectedDepartmentId: '',
            selectedVendorId: '',
            docId: '',
            barcode: '',
            itemCode: '',
            productName: '',
            cost: '',
            price: '',
            productPriceCanChange: false));
    if (inv.barcode.isNotEmpty) {
      fullVoucherData.add(LocalVoucherData(
          barcode: inv.barcode,
          itemCode: inv.itemCode,
          productName: inv.productName,
          qty: b['qty'],
          cost: b['cost'],
          price: b['price'],
          priceWt: inv.priceWT,
          extCost:
              (double.parse(b['qty']) * double.parse(b['cost'])).toString()));
    }
  }

  return fullVoucherData;
}

Future<Uint8List> purchaseReportPage(
    {required DateTime? fromDate,
    required DateTime? toDate,
    required double totalQty,
    required double tax,
    required double totalDiscount,
    required double total,
    required double taxPer,
    required List<DbVoucherData> sortedDbVoucherDataLst,
    required List<InventoryData> inventoryDataLst}) async {
  final doc = pw.Document();

  const double repFont = 10;
  var image = await imageFromAssetBundle('assets/Bitpro.png');
  final arabicNormalFont =
      await fontFromAssetBundle('assets/Segoe.UI_.Semibold.ttf');
  doc.addPage(pw.MultiPage(
      orientation: pw.PageOrientation.landscape,
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(10),
      header: (c) {
        if (c.pageNumber != 1) {
          return pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 15),
              child: pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(3),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FlexColumnWidth(3),
                  5: const pw.FlexColumnWidth(2),
                  6: const pw.FlexColumnWidth(3),
                },
                children: [
                  pw.TableRow(
                      decoration: const pw.BoxDecoration(
                          border: pw.Border(
                        bottom: pw.BorderSide(color: PdfColors.black, width: 2),
                      )),
                      children: [
                        pw.Container(
                            height: 45,
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'فاتورة#',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    fontSize: repFont,
                                    font: arabicNormalFont,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 4,
                                ),
                                pw.Text('Voucher#',
                                    style: const pw.TextStyle(
                                      fontSize: repFont,
                                    ))
                              ],
                            )),
                        pw.Container(
                            height: 45,
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'نوع الفاتورة',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    fontSize: repFont,
                                    font: arabicNormalFont,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 4,
                                ),
                                pw.Text('Type',
                                    style:
                                        const pw.TextStyle(fontSize: repFont))
                              ],
                            )),
                        pw.Container(
                            height: 45,
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'تاريخ',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    fontSize: repFont,
                                    font: arabicNormalFont,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 4,
                                ),
                                pw.Text('Date',
                                    style: const pw.TextStyle(
                                      fontSize: repFont,
                                    ))
                              ],
                            )),
                        pw.Container(
                            height: 45,
                            width: double.maxFinite,
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Text(
                                  'كمية',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    fontSize: repFont,
                                    font: arabicNormalFont,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 4,
                                ),
                                pw.Text('Qty',
                                    style: const pw.TextStyle(
                                      fontSize: repFont,
                                    ))
                              ],
                            )),
                        pw.Container(
                            height: 45,
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Text(
                                  'الضريبة',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    fontSize: repFont,
                                    font: arabicNormalFont,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 4,
                                ),
                                pw.Text('Tax($taxPer%)',
                                    style: const pw.TextStyle(
                                      fontSize: repFont,
                                    ))
                              ],
                            )),
                        pw.Container(
                            height: 45,
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Text(
                                  'خصم',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    fontSize: repFont,
                                    font: arabicNormalFont,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 4,
                                ),
                                pw.Text('Dis. \$',
                                    style: const pw.TextStyle(
                                      fontSize: repFont,
                                    ))
                              ],
                            )),
                        pw.Container(
                            height: 45,
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Text(
                                  'الاجمالي',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(
                                    fontSize: repFont,
                                    font: arabicNormalFont,
                                  ),
                                ),
                                pw.SizedBox(
                                  height: 4,
                                ),
                                pw.Text('Voucher Total',
                                    style: const pw.TextStyle(
                                      fontSize: repFont,
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
                                  'Purchase Journal',
                                  style: const pw.TextStyle(fontSize: repFont),
                                ),
                                pw.SizedBox(
                                  height: 5,
                                ),
                                pw.Text(
                                  'Date : ${DateFormat('dd-MM-yyyy').format(fromDate!)} to ${DateFormat('dd-MM-yyyy').format(toDate!)}',
                                  style: const pw.TextStyle(fontSize: repFont),
                                ),
                              ],
                            ),
                            pw.Text(
                              'Printed on : ${DateFormat('dd-MM-yyyy').format(DateTime.now())}',
                              style: const pw.TextStyle(fontSize: repFont),
                            ),
                          ],
                        ),
                        pw.SizedBox(
                          height: 10,
                        ),
                        pw.Container(
                          color: const PdfColor.fromInt(0xff2a77b5),
                          padding: const pw.EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          width: double.maxFinite,
                          child: pw.Text(
                            'Purchase Journal',
                            style: const pw.TextStyle(
                                fontSize: repFont, color: PdfColors.white),
                          ),
                        ),
                        pw.Table(
                          columnWidths: {
                            0: const pw.FlexColumnWidth(3),
                            1: const pw.FlexColumnWidth(2),
                            2: const pw.FlexColumnWidth(3),
                            3: const pw.FlexColumnWidth(2),
                            4: const pw.FlexColumnWidth(3),
                            5: const pw.FlexColumnWidth(2),
                            6: const pw.FlexColumnWidth(3),
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
                                      height: 45,
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
                                              fontSize: repFont,
                                              font: arabicNormalFont,
                                            ),
                                          ),
                                          pw.SizedBox(
                                            height: 4,
                                          ),
                                          pw.Text('Voucher#',
                                              style: const pw.TextStyle(
                                                fontSize: repFont,
                                              ))
                                        ],
                                      )),
                                  pw.Container(
                                      height: 45,
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
                                              fontSize: repFont,
                                              font: arabicNormalFont,
                                            ),
                                          ),
                                          pw.SizedBox(
                                            height: 4,
                                          ),
                                          pw.Text('Type',
                                              style: const pw.TextStyle(
                                                  fontSize: repFont))
                                        ],
                                      )),
                                  pw.Container(
                                      height: 45,
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
                                              fontSize: repFont,
                                              font: arabicNormalFont,
                                            ),
                                          ),
                                          pw.SizedBox(
                                            height: 4,
                                          ),
                                          pw.Text('Date',
                                              style: const pw.TextStyle(
                                                fontSize: repFont,
                                              ))
                                        ],
                                      )),
                                  pw.Container(
                                      height: 45,
                                      width: double.maxFinite,
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
                                              fontSize: repFont,
                                              font: arabicNormalFont,
                                            ),
                                          ),
                                          pw.SizedBox(
                                            height: 4,
                                          ),
                                          pw.Text('Qty',
                                              style: const pw.TextStyle(
                                                fontSize: repFont,
                                              ))
                                        ],
                                      )),
                                  pw.Container(
                                      height: 45,
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
                                              fontSize: repFont,
                                              font: arabicNormalFont,
                                            ),
                                          ),
                                          pw.SizedBox(
                                            height: 4,
                                          ),
                                          pw.Text('Tax($taxPer%)',
                                              style: const pw.TextStyle(
                                                fontSize: repFont,
                                              ))
                                        ],
                                      )),
                                  pw.Container(
                                      height: 45,
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
                                              fontSize: repFont,
                                              font: arabicNormalFont,
                                            ),
                                          ),
                                          pw.SizedBox(
                                            height: 4,
                                          ),
                                          pw.Text('Dis. \$',
                                              style: const pw.TextStyle(
                                                fontSize: repFont,
                                              ))
                                        ],
                                      )),
                                  pw.Container(
                                      height: 45,
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
                                              fontSize: repFont,
                                              font: arabicNormalFont,
                                            ),
                                          ),
                                          pw.SizedBox(
                                            height: 4,
                                          ),
                                          pw.Text('Voucher Total',
                                              style: const pw.TextStyle(
                                                fontSize: repFont,
                                              ))
                                        ],
                                      )),
                                ]),
                          ],
                        ),
                        for (var d in sortedDbVoucherDataLst)
                          pw.Container(
                            decoration: const pw.BoxDecoration(
                                border: pw.Border(
                              bottom: pw.BorderSide(color: PdfColors.black),
                            )),
                            child: pw.Row(children: [
                              pw.Container(
                                  height: 20,
                                  width: 128,
                                  alignment: pw.Alignment.centerLeft,
                                  child: pw.Text(
                                    d.voucherNo,
                                    style: pw.TextStyle(
                                        fontSize: repFont,
                                        color: d.voucherType == 'Return'
                                            ? PdfColors.red
                                            : PdfColors.black),
                                  )),
                              pw.Container(
                                  height: 20,
                                  width: 85,
                                  alignment: pw.Alignment.centerLeft,
                                  child: pw.Text(
                                    d.voucherType,
                                    style: pw.TextStyle(
                                        fontSize: repFont,
                                        color: d.voucherType == 'Return'
                                            ? PdfColors.red
                                            : PdfColors.black),
                                  )),
                              pw.Container(
                                  height: 20,
                                  width: 130,
                                  alignment: pw.Alignment.centerLeft,
                                  child: pw.Text(
                                    DateFormat('MM-dd-yyyy HH:mm a')
                                        .format(d.createdDate),
                                    style: pw.TextStyle(
                                        fontSize: repFont,
                                        color: d.voucherType == 'Return'
                                            ? PdfColors.red
                                            : PdfColors.black),
                                  )),
                              pw.Container(
                                  height: 20,
                                  width: 85,
                                  alignment: pw.Alignment.centerRight,
                                  child: pw.Text(
                                    (d.voucherType == 'Return' ? '-' : '') +
                                        d.qtyRecieved,
                                    style: pw.TextStyle(
                                        fontSize: repFont,
                                        color: d.voucherType == 'Return'
                                            ? PdfColors.red
                                            : PdfColors.black),
                                  )),
                              pw.Container(
                                  height: 20,
                                  width: 128,
                                  alignment: pw.Alignment.centerRight,
                                  child: pw.Text(
                                    (d.voucherType == 'Return' ? '-' : '') +
                                        calculateTaxValue(
                                            dbVoucherData: d,
                                            inventoryDataLst: inventoryDataLst),
                                    style: pw.TextStyle(
                                        fontSize: repFont,
                                        color: d.voucherType == 'Return'
                                            ? PdfColors.red
                                            : PdfColors.black),
                                  )),
                              pw.Container(
                                  height: 20,
                                  width: 85,
                                  alignment: pw.Alignment.centerRight,
                                  child: pw.Text(
                                    (d.voucherType == 'Return' ? '-' : '') +
                                        d.discountValue,
                                    style: pw.TextStyle(
                                        fontSize: repFont,
                                        color: d.voucherType == 'Return'
                                            ? PdfColors.red
                                            : PdfColors.black),
                                  )),
                              pw.Container(
                                  height: 20,
                                  width: 85,
                                  alignment: pw.Alignment.centerRight,
                                  child: pw.Text(
                                    (d.voucherType == 'Return' ? '-' : '') +
                                        d.voucherTotal,
                                    style: pw.TextStyle(
                                        fontSize: repFont,
                                        color: d.voucherType == 'Return'
                                            ? PdfColors.red
                                            : PdfColors.black),
                                  )),
                            ]),
                          ),
                        pw.SizedBox(
                          height: 10,
                        ),
                        pw.Table(
                          columnWidths: {
                            0: const pw.FlexColumnWidth(8),
                            1: const pw.FlexColumnWidth(2),
                            2: const pw.FlexColumnWidth(3),
                            3: const pw.FlexColumnWidth(2),
                            4: const pw.FlexColumnWidth(3),
                          },
                          children: [
                            pw.TableRow(
                                decoration: const pw.BoxDecoration(
                                  color: PdfColor.fromInt(0xff2a77b5),
                                ),
                                children: [
                                  pw.Container(
                                      height: 30,
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
                                                      ? repFont
                                                      : repFont,
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
                                              fontSize: repFont,
                                              font: arabicNormalFont,
                                              color: PdfColors.white,
                                            ),
                                          ),
                                          pw.SizedBox(
                                            height: 1,
                                          ),
                                          pw.Text('Tot. Qty',
                                              style: const pw.TextStyle(
                                                fontSize: repFont,
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
                                              fontSize: repFont,
                                              font: arabicNormalFont,
                                              color: PdfColors.white,
                                            ),
                                          ),
                                          pw.SizedBox(
                                            height: 1,
                                          ),
                                          pw.Text('Tax($taxPer%)',
                                              style: const pw.TextStyle(
                                                fontSize: repFont,
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
                                              fontSize: repFont,
                                              font: arabicNormalFont,
                                              color: PdfColors.white,
                                            ),
                                          ),
                                          pw.SizedBox(
                                            height: 1,
                                          ),
                                          pw.Text('Dis. \$',
                                              style: pw.TextStyle(
                                                  fontSize: repFont,
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
                                            pw.CrossAxisAlignment.center,
                                        children: [
                                          pw.Text(
                                            'الاجمالي',
                                            textDirection: pw.TextDirection.rtl,
                                            style: pw.TextStyle(
                                              fontSize: repFont,
                                              font: arabicNormalFont,
                                              color: PdfColors.white,
                                            ),
                                          ),
                                          pw.SizedBox(
                                            height: 1,
                                          ),
                                          pw.Text('Total',
                                              style: pw.TextStyle(
                                                  fontSize: repFont,
                                                  color: PdfColors.white,
                                                  fontWeight:
                                                      pw.FontWeight.bold))
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
                                              style: const pw.TextStyle(
                                                fontSize: repFont,
                                              ))),
                                  pw.Container(
                                      height: 20,
                                      alignment: pw.Alignment.centerRight,
                                      child: pw.Text(tax.toStringAsFixed(2),
                                          style: const pw.TextStyle(
                                            fontSize: repFont,
                                          ))),
                                  pw.Container(
                                      height: 20,
                                      alignment: pw.Alignment.centerRight,
                                      child: pw.Text(
                                          totalDiscount.toStringAsFixed(2),
                                          style: const pw.TextStyle(
                                            fontSize: repFont,
                                          ))),
                                  pw.Container(
                                      height: 20,
                                      alignment: pw.Alignment.center,
                                      child: pw.Text(total.toStringAsFixed(2),
                                          style: const pw.TextStyle(
                                            fontSize: repFont,
                                          ))),
                                ])
                          ],
                        ),
                      ])))
        ];
      }));
  return await doc.save();
}
