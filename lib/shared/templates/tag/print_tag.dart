import 'dart:convert';
import 'package:barcode_image/barcode_image.dart';
import 'package:bitpro_hive/shared/check_contain_arabic_letters.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:bitpro_hive/shared/global_variables/static_text_translate.dart';
import 'package:bitpro_hive/shared/toast.dart';
import '../../global_variables/font_sizes.dart';

class PrintTagData {
  String productName;
  String itemCode;
  String barcodeValue;
  String priceWt;
  int onHandQty;
  int docQty;
  PrintTagData({
    required this.productName,
    required this.itemCode,
    required this.barcodeValue,
    required this.priceWt,
    required this.onHandQty,
    required this.docQty,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'productName': productName});
    result.addAll({'itemCode': itemCode});
    result.addAll({'barcodeValue': barcodeValue});
    result.addAll({'priceWt': priceWt});
    result.addAll({'onHandQty': onHandQty});
    result.addAll({'docQty': docQty});

    return result;
  }

  factory PrintTagData.fromMap(Map<dynamic, dynamic> map) {
    return PrintTagData(
      productName: map['productName'] ?? '',
      itemCode: map['itemCode'] ?? '',
      barcodeValue: map['barcodeValue'] ?? '',
      priceWt: map['priceWt'] ?? '',
      onHandQty: map['onHandQty']?.toInt() ?? 0,
      docQty: map['docQty']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory PrintTagData.fromJson(String source) =>
      PrintTagData.fromMap(json.decode(source));
}

void buildTagPrint({
  required List<PrintTagData> allPrintTagDataLst,
  required PrintTagData selectedPrintTagData,
  required BuildContext context,
}) async {
  List<Printer> p = await Printing.listPrinters();
  int printSelectedRecode = 1;
  String copyType = 'normal_copy';
  int copies = 1;
  Printer? selectedPrinter;
  // ignore: use_build_context_synchronously
  showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState2) {
            return Dialog(
              backgroundColor: homeBgColor,
              child: SizedBox(
                  height: 420,
                  width: 550,
                  child: Column(children: [
                    Expanded(
                        child: Card(
                      margin: const EdgeInsets.all(10),
                      color: Colors.white,
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 15),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      staticTextTranslate('Print Tag'),
                                      style: TextStyle(
                                        fontSize: getMediumFontSize + 5,
                                      ),
                                    ),
                                    Text(
                                      staticTextTranslate(
                                          'Selected record to print selected items tag'),
                                      style: TextStyle(
                                        fontSize: getMediumFontSize - 1,
                                      ),
                                    ),
                                    Text(
                                      staticTextTranslate(
                                          'All listed record to print tag of all listed items here'),
                                      style: TextStyle(
                                        fontSize: getMediumFontSize - 1,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 17,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Radio(
                                            value: 1,
                                            splashRadius: 15,
                                            activeColor: darkBlueColor,
                                            groupValue: printSelectedRecode,
                                            onChanged: (value) {
                                              printSelectedRecode =
                                                  value as int;
                                              setState2(() {});
                                              // setState(() {});
                                            }),
                                        Text(
                                          staticTextTranslate(
                                              'Selected Record'),
                                          style: TextStyle(
                                              fontSize: getMediumFontSize),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Radio(
                                            value: 2,
                                            groupValue: printSelectedRecode,
                                            splashRadius: 15,
                                            onChanged: (value) {
                                              printSelectedRecode =
                                                  value as int;
                                              setState2(() {});
                                              // setState(() {});
                                            }),
                                        Text(
                                          staticTextTranslate(
                                              'All Listed Record'),
                                          style: TextStyle(
                                              fontSize: getMediumFontSize),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      height: 37,
                                      width: 490,
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                              width: 0.5, color: Colors.grey)),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          hint: Text(
                                            staticTextTranslate(
                                                'Select Printer'),
                                            style: TextStyle(
                                                fontSize:
                                                    getMediumFontSize + 2),
                                          ),
                                          items: p.map((Printer value) {
                                            return DropdownMenuItem<String>(
                                              value: value.name,
                                              child: Text(
                                                value.name,
                                                style: TextStyle(
                                                    fontSize:
                                                        getMediumFontSize),
                                              ),
                                            );
                                          }).toList(),
                                          value: selectedPrinter == null
                                              ? null
                                              : selectedPrinter!.name,
                                          onChanged: (value) {
                                            selectedPrinter = p.firstWhere(
                                                (element) =>
                                                    element.name == value);
                                            setState2(() {});
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        children: [
                                          Row(children: [
                                            Radio(
                                                activeColor: darkBlueColor,
                                                value: "onHandQuantity",
                                                groupValue: copyType,
                                                onChanged: (String? value) {
                                                  if (value != null) {
                                                    copyType = value;

                                                    setState2(() {});
                                                  }
                                                }),
                                            Text(
                                                staticTextTranslate(
                                                    'On Hand Quantity'),
                                                style: TextStyle(
                                                    fontSize:
                                                        getMediumFontSize)),
                                          ]),
                                          if (selectedPrintTagData.docQty != -1)
                                            Row(children: [
                                              Radio(
                                                  activeColor: darkBlueColor,
                                                  value: "doc_quantity",
                                                  groupValue: copyType,
                                                  onChanged: (String? value) {
                                                    if (value != null) {
                                                      copyType = value;
                                                      setState2(() {});
                                                    }
                                                  }),
                                              Text(staticTextTranslate(
                                                  'Document Quantity')),
                                            ]),
                                          Row(children: [
                                            Radio(
                                                activeColor: darkBlueColor,
                                                value: "normal_copy",
                                                groupValue: copyType,
                                                onChanged: (String? value) {
                                                  if (value != null) {
                                                    copyType = value;

                                                    setState2(() {});
                                                  }
                                                }),
                                            Text(
                                              staticTextTranslate('Copy'),
                                              style: TextStyle(
                                                  fontSize: getMediumFontSize),
                                            ),
                                          ]),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          if (copyType == 'normal_copy')
                                            Row(children: [
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              SizedBox(
                                                  height: 35,
                                                  width: 130,
                                                  child: TextFormField(
                                                      scrollPadding:
                                                          const EdgeInsets.all(
                                                              0),
                                                      initialValue: copies
                                                          .toString(),
                                                      autovalidateMode:
                                                          AutovalidateMode
                                                              .onUserInteraction,
                                                      validator: (value) {
                                                        if (int.tryParse(
                                                                value!) ==
                                                            null) {
                                                          return staticTextTranslate(
                                                              'Enter a valid number');
                                                        }
                                                        return null;
                                                      },
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                      decoration:
                                                          const InputDecoration(
                                                              errorStyle:
                                                                  TextStyle(
                                                                      fontSize:
                                                                          12),
                                                              isDense: true,
                                                              border:
                                                                  OutlineInputBorder()),
                                                      onChanged: (val) {
                                                        setState2(() {
                                                          copies =
                                                              int.parse(val);
                                                        });
                                                        setState2(() {});
                                                      })),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                staticTextTranslate('Copies'),
                                                style: TextStyle(
                                                    fontSize:
                                                        getMediumFontSize),
                                              ),
                                            ]),
                                        ],
                                      ),
                                    ),
                                  ]))),
                    )),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 800,
                        decoration: const BoxDecoration(
                            color: Color(0xffdddfe8),
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(6),
                                bottomRight: Radius.circular(6))),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: 42,
                              width: 173,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          side: const BorderSide(
                                              width: 0.5, color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(4))),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Iconsax.close_circle,
                                          color: Colors.black, size: 20),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(staticTextTranslate('Cancel'),
                                          style: TextStyle(
                                              fontSize: getMediumFontSize,
                                              color: Colors.black)),
                                    ],
                                  )),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              height: 42,
                              width: 173,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: darkBlueColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5))),
                                  onPressed: () async {
                                    if (selectedPrinter != null) {
                                      if (printSelectedRecode == 1) {
                                        await printTag(
                                            selectedPrinter,
                                            copies,
                                            copyType,
                                            [selectedPrintTagData],
                                            context);
                                      } else {
                                        await printTag(
                                            selectedPrinter,
                                            copies,
                                            copyType,
                                            allPrintTagDataLst,
                                            context);
                                      }
                                    } else {
                                      showToast(
                                          staticTextTranslate(
                                              'Select a printer'),
                                          context);
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Iconsax.printer,
                                        size: 20,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        staticTextTranslate('Print'),
                                        style: TextStyle(
                                            fontSize: getMediumFontSize),
                                      ),
                                    ],
                                  )),
                            ),
                          ],
                        ),
                      ),
                    )
                  ])),
            );
          }));
}

Future<void> printTag(Printer? printer, int copies, String copyType,
    List<PrintTagData> printTagDataLst, BuildContext constext) async {
  final doc = pw.Document();
  var box = Hive.box('bitpro_app');

  final arabicNormalFont =
      await fontFromAssetBundle('assets/Segoe.UI_.Semibold.ttf');

  double headerFontSize = 10;
  double productIdFontSize = 8;
  double productNameFontSize = 8;
  double priceFontSize = 8;
  double barcodeHeight = 30;
  double barcodeWidth = 50;

  double pageWidth = 2;
  double pageHeight = 1;
  double marginTop = 4;
  double marginBottom = 4;
  double marginLeft = 4;
  double marginRight = 4;
  //
  bool enablePrice = true;
  bool enableProdId = true;
  String customHeader = 'Store Name';
  double spaceAfterProdName = 7;
  double spaceAfterProdId = 16;
  double sizeAfterPrice = 21;
  String priceAnnotation = 'SR';

  Map? inventoryTagSize;

  if (printer == null) {
    inventoryTagSize = await box.get('test_inventory_tag_size');
  } else {
    inventoryTagSize = await box.get('inventory_tag_size');
  }

  if (inventoryTagSize != null) {
    headerFontSize = inventoryTagSize['headerFontSize'];
    productIdFontSize = inventoryTagSize['productIdFontSize'];
    productNameFontSize = inventoryTagSize['productNameFontSize'];
    priceFontSize = inventoryTagSize['priceFontSize'];
    barcodeWidth = inventoryTagSize['barcodeWidth'];
    barcodeHeight = inventoryTagSize['barcodeHeight'];

    // sizedboxHeight = inventoryTagSize['sizedboxHeight'];
    pageWidth = inventoryTagSize['pageWidth'];
    pageHeight = inventoryTagSize['pageHeight'];
    marginTop = inventoryTagSize['marginTop'];
    marginBottom = inventoryTagSize['marginBottom'];
    marginLeft = inventoryTagSize['marginLeft'];
    marginRight = inventoryTagSize['marginRight'];

    enablePrice = inventoryTagSize['enablePrice'];
    enableProdId = inventoryTagSize['enableProdId'];
    customHeader = inventoryTagSize['customHeader'];
    spaceAfterProdId = inventoryTagSize['spaceAfterProdId'];
    spaceAfterProdName = inventoryTagSize['spaceAfterProdName'];
    priceAnnotation = inventoryTagSize['priceAnnotation'];
    sizeAfterPrice = inventoryTagSize['sizeAfterPrice'];
  }

  for (int j = 0; j < printTagDataLst.length; j++) {
    int noOfCopies = 1;
    if (copyType == 'normal_copy') {
      noOfCopies = copies;
    } else if (copyType == 'onHandQuantity') {
      noOfCopies = printTagDataLst.elementAt(j).onHandQty;
    } else if (copyType == 'doc_quantity') {
      noOfCopies = printTagDataLst.elementAt(j).docQty;
    }
    for (int i = 0; i < noOfCopies; i++) {
      doc.addPage(pw.Page(
          pageFormat: PdfPageFormat(
              pageWidth * PdfPageFormat.inch, pageHeight * PdfPageFormat.inch),
          build: (pw.Context context) {
            return pw.Container(
                width: double.maxFinite,
                height: double.maxFinite,
                decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black)),
                alignment: pw.Alignment.centerLeft,
                padding: pw.EdgeInsets.fromLTRB(
                    marginLeft, marginTop, marginRight, marginBottom),
                child: pw.Expanded(
                    child: pw.Stack(
                  children: [
                    if (printer == null)
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Text(customHeader,
                                textDirection:
                                    !containsExtendedArabic(customHeader)
                                        ? pw.TextDirection.ltr
                                        : pw.TextDirection.rtl,
                                style: pw.TextStyle(
                                    fontSize: headerFontSize,
                                    font: !containsExtendedArabic(customHeader)
                                        ? null
                                        : arabicNormalFont,
                                    fontWeight: pw.FontWeight.bold)),
                          ]),
                    pw.Positioned(
                      top: spaceAfterProdName,
                      child: pw.Text(printTagDataLst.elementAt(j).productName,
                          textDirection: !containsExtendedArabic(
                                  printTagDataLst.elementAt(j).productName)
                              ? pw.TextDirection.ltr
                              : pw.TextDirection.rtl,
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                              font: !containsExtendedArabic(
                                      printTagDataLst.elementAt(j).productName)
                                  ? null
                                  : arabicNormalFont,
                              fontSize: productNameFontSize,
                              fontWeight: pw.FontWeight.bold)),
                    ),
                    if (enableProdId)
                      pw.Positioned(
                        top: spaceAfterProdId,
                        child: pw.Text(printTagDataLst.elementAt(j).itemCode,
                            style: pw.TextStyle(
                                fontSize: productIdFontSize,
                                fontWeight: pw.FontWeight.bold)),
                      ),
                    if (enablePrice)
                      pw.Positioned(
                        top: sizeAfterPrice,
                        child: pw.Text(
                            printer == null
                                ? '$priceAnnotation : 10.00'
                                : '$priceAnnotation : ${double.tryParse(printTagDataLst.elementAt(j).priceWt) == null ? '0' : double.parse(printTagDataLst.elementAt(j).priceWt).toStringAsFixed(2)}',
                            textDirection:
                                !containsExtendedArabic(priceAnnotation)
                                    ? pw.TextDirection.ltr
                                    : pw.TextDirection.rtl,
                            style: pw.TextStyle(
                                font: arabicNormalFont,
                                fontSize: priceFontSize,
                                fontWeight: pw.FontWeight.bold)),
                      ),
                    pw.Align(
                        alignment: pw.Alignment.bottomCenter,
                        child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.SvgImage(
                                  svg: buildBarcode(
                                      Barcode.code128(
                                          useCode128B: false,
                                          useCode128C: false),
                                      printTagDataLst.elementAt(j).barcodeValue,
                                      filename: 'code-128a',
                                      fontHeight: priceFontSize,
                                      height: barcodeHeight,
                                      width: barcodeWidth))
                            ]))
                  ],
                )));
          }));
    }
  }

  if (printer != null) {
    var d = await doc.save();

    await Printing.directPrintPdf(
        usePrinterSettings: true,
        printer: printer,
        onLayout: (PdfPageFormat format) => d);
  } else {
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
  }
}

String buildBarcode(
  Barcode bc,
  String data, {
  String? filename,
  double? width,
  double? height,
  double? fontHeight,
}) {
  /// Create the Barcode
  final svg = bc.toSvg(
    data,
    width: width ?? 200,
    height: height ?? 80,
    fontHeight: fontHeight,
  );

  return svg;
}
