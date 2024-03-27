import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:bitpro_hive/home/reports/report_pages/puchase_report_page.dart';
import 'package:bitpro_hive/home/reports/report_pages/sales_report_page.dart';
import 'package:bitpro_hive/home/reports/report_pages/tax_report_summary_page.dart';
import 'package:bitpro_hive/model/inventory_data.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../model/receipt/db_receipt_data.dart';
import '../../model/voucher/db_voucher_data.dart';
import '../../shared/global_variables/font_sizes.dart';

class ReportPdfViewer extends StatefulWidget {
  final String selectedPage;
  final DateTime? fromDate;
  final DateTime? toDate;
  final double totalQty;
  final double tax;
  final double totalDiscount;
  final double total;
  final double taxPer;
  final List<DbVoucherData> sortedDbVoucherDataLst;
  final List<DbReceiptData> sortedDbReceiptDataLst;
  //
  final double totalCost;
  final double salesTaxValue;
  final double salesTotalSalesWithTax;
  final double salesTotalSales;
  final double purTaxValue;
  final double purTotalSalesWithTax;
  final List<InventoryData> inventoryDataLst;

  const ReportPdfViewer(
      {super.key,
      required this.selectedPage,
      required this.fromDate,
      required this.toDate,
      required this.totalQty,
      required this.tax,
      required this.totalDiscount,
      required this.total,
      required this.taxPer,
      required this.sortedDbVoucherDataLst,
      required this.sortedDbReceiptDataLst,
      required this.totalCost,
      required this.salesTaxValue,
      required this.salesTotalSalesWithTax,
      required this.salesTotalSales,
      required this.purTaxValue,
      required this.purTotalSalesWithTax,
      required this.inventoryDataLst});

  @override
  State<ReportPdfViewer> createState() => _ReportPdfViewerState();
}

class _ReportPdfViewerState extends State<ReportPdfViewer> {
  double maxPageWidth = 200;
  Uint8List? bytes;
  final PdfViewerController _pdfViewerController = PdfViewerController();
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  @override
  void initState() {
    initDate();

    super.initState();
  }

  initDate() async {
    if (widget.selectedPage == "Sales Summary") {
      bytes = await salesReportPage(
          totalCost: widget.totalCost,
          fromDate: widget.fromDate,
          toDate: widget.toDate,
          totalQty: widget.totalQty,
          tax: widget.tax,
          totalDiscount: widget.totalDiscount,
          total: widget.total,
          taxPer: widget.taxPer,
          sortedDbReceiptDataLst: widget.sortedDbReceiptDataLst);
    } else if (widget.selectedPage == "Purchase Summary") {
      bytes = await purchaseReportPage(
          inventoryDataLst: widget.inventoryDataLst,
          fromDate: widget.fromDate,
          toDate: widget.toDate,
          totalQty: widget.totalQty,
          tax: widget.tax,
          totalDiscount: widget.totalDiscount,
          total: widget.total,
          taxPer: widget.taxPer,
          sortedDbVoucherDataLst: widget.sortedDbVoucherDataLst);
    } else if (widget.selectedPage == "Tax Summary") {
      bytes = await taxReportPage(
          fromDate: widget.fromDate,
          toDate: widget.toDate,
          purTaxValue: widget.purTaxValue,
          purTotalSalesWithTax: widget.purTotalSalesWithTax,
          salesTaxValue: widget.salesTaxValue,
          salesTotalSales: widget.salesTotalSales,
          salesTotalSalesWithTax: widget.salesTotalSalesWithTax,
          taxPer: widget.taxPer,
          sortedDbReceiptDataLst: widget.sortedDbReceiptDataLst,
          sortedDbVoucherDataLst: widget.sortedDbVoucherDataLst);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: (MediaQuery.of(context).size.height * 0.9) - 8,
        child: bytes == null
            ? const Center(
                child: SizedBox(
                    width: 50, height: 50, child: CircularProgressIndicator()))
            : Column(children: [
                Container(
                  width: double.maxFinite,
                  color: Colors.grey[800],
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '${_pdfViewerController.pageNumber} / ${_pdfViewerController.pageCount}',
                        style: TextStyle(
                            fontSize: getMediumFontSize, color: Colors.white),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        '|',
                        style: TextStyle(
                            fontSize: getMediumFontSize, color: Colors.grey),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.remove,
                          color: _pdfViewerController.zoomLevel == 1
                              ? Colors.grey
                              : Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          _pdfViewerController.zoomLevel =
                              _pdfViewerController.zoomLevel - .1;
                          setState(() {});
                        },
                      ),
                      Text(
                        '${(_pdfViewerController.zoomLevel * 100).toStringAsFixed(0)} %',
                        style: TextStyle(
                            fontSize: getMediumFontSize, color: Colors.white),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.add,
                          color: _pdfViewerController.zoomLevel == 3
                              ? Colors.grey
                              : Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          _pdfViewerController.zoomLevel =
                              _pdfViewerController.zoomLevel + .1;
                          setState(() {});
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.print,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () async {
                          // _pdfViewerController.zoomLevel =
                          //     _pdfViewerController.zoomLevel + 1;
                          // initDate();
                          await Printing.layoutPdf(
                              usePrinterSettings: true,
                              onLayout: (format) async => bytes!);
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SfPdfViewer.memory(
                    pageLayoutMode: PdfPageLayoutMode.continuous,
                    scrollDirection: PdfScrollDirection.vertical,
                    bytes!,
                    key: _pdfViewerKey,
                    controller: _pdfViewerController,
                    enableTextSelection: false,
                    onZoomLevelChanged: (details) => setState(() {}),
                    onPageChanged: (details) => setState(() {}),
                  ),
                ),
              ]));
  }
}
