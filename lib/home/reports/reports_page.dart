import 'package:bitpro_hive/model/voucher/local_voucher_data.dart';
import 'package:bitpro_hive/services/firestore_api/fb_merchandise/fb_inventory_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_sales/fb_receipt_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_vouchers/fb_voucher_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_merchandise_db_service/inventory_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_sales_db_service/hive_receipt_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_voucher_db_service/hive_voucher_db_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:bitpro_hive/home/reports/report_pages/puchase_report_page.dart';
import 'package:bitpro_hive/model/inventory_data.dart';
import 'package:bitpro_hive/model/receipt/db_receipt_data.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/shared/customer_expanded_tile.dart';
import 'package:bitpro_hive/home/reports/pdf_viewer_page.dart';
import 'package:bitpro_hive/shared/loading.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import '../../model/voucher/db_voucher_data.dart';
import '../../shared/custom_top_nav_bar.dart';
import '../../shared/global_variables/font_sizes.dart';
import '../../shared/global_variables/static_text_translate.dart';

class ReportsPage extends StatefulWidget {
  final UserData userData;

  const ReportsPage({Key? key, required this.userData}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

var selectedDataGirdListerner = ValueNotifier<DataGridRow?>(null);

class _ReportsPageState extends State<ReportsPage> {
  DateTime? fromDate;
  DateTime? toDate;
  bool showFromDateError = false;
  bool showToDateError = false;
  List<DbReceiptData> dbReceiptDataLst = [];
  List<DbVoucherData> dbVoucherDataLst = [];
  List<InventoryData> allInventoryDataLst = [];
  String selectedPage = '';

  bool showPageDetails = false;
  double taxPerForReceipt = 10.0;
  String datatype = 'All Document';

  bool isLoading = true;
  @override
  void initState() {
    var box = Hive.box('bitpro_app');
    Map? userTaxesData = box.get('user_taxes_settings');

    if (userTaxesData != null) {
      taxPerForReceipt =
          double.tryParse(userTaxesData['taxPercentage'].toString()) ?? 10.0;
    }

    hiveFetchData();
    super.initState();
  }

  hiveFetchData() async {
    dbReceiptDataLst = await HiveReceiptDbService().fetchAllReceiptData();
    dbVoucherDataLst = await HiveVoucherDbService().fetchAllVoucherData();
    allInventoryDataLst =
        await HiveInventoryDbService().fetchAllInventoryData();
    setState(() {
      isLoading = false;
    });
  }

  fbFetchData() async {
    dbReceiptDataLst =
        await FbReceiptDbService(context: context).fetchAllReceiptData();
    dbVoucherDataLst =
        await FbVoucherDbService(context: context).fetchAllVoucherData();
    allInventoryDataLst =
        await FbInventoryDbService(context: context).fetchAllInventoryData();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return showLoading(withScaffold: true);
    }

    return customTopNavBar(
      Scaffold(
        backgroundColor: homeBgColor,
        body: SafeArea(
          child: Container(
            color: homeBgColor,
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 2),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 0,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue,
                            darkBlueColor,
                          ],
                        ),
                      ),
                      margin: const EdgeInsets.only(left: 0),
                      padding: const EdgeInsets.all(0),
                      width: 170,
                      height: 45,
                      child: const Center(
                        child: Text(
                          'BitPro',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      height: 40,
                      width: 170,
                      child: TextButton(
                        style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              size: 19,
                              Iconsax.back_square,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(staticTextTranslate('Back'),
                                style: TextStyle(
                                    fontSize: getMediumFontSize,
                                    color: const Color.fromARGB(255, 0, 0, 0))),
                          ],
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      width: 170,
                      child: TextButton(
                        style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              size: 19,
                              Iconsax.refresh5,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(staticTextTranslate('Refresh'),
                                style: TextStyle(
                                    fontSize: getMediumFontSize,
                                    color: const Color.fromARGB(255, 0, 0, 0))),
                          ],
                        ),
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          await fbFetchData();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 0,
                      ),
                      SizedBox(
                        height: 35,
                        width: 370,
                        child: Row(children: [
                          const SizedBox(width: 10),
                          const Icon(
                            Iconsax.chart_1,
                            size: 17,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Text(
                            staticTextTranslate('Reports'),
                            style: TextStyle(
                              fontSize: getMediumFontSize,
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
                          )
                        ]),
                      ),
                      const SizedBox(
                        height: 0,
                      ),
                      Expanded(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * .88,
                          child: Card(
                              shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      width: 0.5, color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4)),
                              elevation: 0,
                              color: Colors.white,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.9,
                                    margin: const EdgeInsets.all(10),
                                    width: 270,
                                    decoration: BoxDecoration(
                                        color: homeBgColor,
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.grey,
                                            blurRadius: 2.0,
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(4)),
                                    child: Column(children: [
                                      CustomExpansionTile(
                                        iconColor: Colors.black,
                                        collapsedIconColor: Colors.black,
                                        leading: null,
                                        trailing: const SizedBox(),
                                        title: Text(
                                          staticTextTranslate("Sales Report"),
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: getMediumFontSize + 2,
                                          ),
                                        ),
                                        expandedAlignment: Alignment.centerLeft,
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedPage = 'Sales Summary';

                                                showPageDetails = false;
                                                fromDate = null;
                                                toDate = null;
                                              });
                                            },
                                            child: Container(
                                              width: double.maxFinite,
                                              padding: const EdgeInsets.only(
                                                  left: 35, top: 0, bottom: 10),
                                              child: Text(
                                                staticTextTranslate(
                                                    "Sales Summary"),
                                                style: TextStyle(
                                                    fontSize: getMediumFontSize,
                                                    color: selectedPage ==
                                                            "Sales Summary"
                                                        ? Colors.blue
                                                        : Colors.black),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      CustomExpansionTile(
                                        iconColor: Colors.black,
                                        collapsedIconColor: Colors.black,
                                        leading: null,
                                        trailing: const SizedBox(),
                                        title: Text(
                                          staticTextTranslate(
                                              "Purchase Report"),
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: getMediumFontSize + 2,
                                          ),
                                        ),
                                        expandedAlignment: Alignment.centerLeft,
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedPage =
                                                    "Purchase Summary";
                                                showPageDetails = false;
                                                fromDate = null;
                                                toDate = null;
                                              });
                                            },
                                            child: Container(
                                              width: double.maxFinite,
                                              padding: const EdgeInsets.only(
                                                  left: 35, top: 0, bottom: 10),
                                              child: Text(
                                                staticTextTranslate(
                                                    "Purchase Summary"),
                                                style: TextStyle(
                                                    fontSize: getMediumFontSize,
                                                    color: selectedPage ==
                                                            "Purchase Summary"
                                                        ? Colors.blue
                                                        : Colors.black),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      CustomExpansionTile(
                                        iconColor: Colors.black,
                                        collapsedIconColor: Colors.black,
                                        leading: null,
                                        trailing: const SizedBox(),
                                        title: Text(
                                          staticTextTranslate("Tax Report"),
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: getMediumFontSize + 2,
                                          ),
                                        ),
                                        expandedAlignment: Alignment.centerLeft,
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedPage = "Tax Summary";
                                                showPageDetails = false;
                                                fromDate = null;
                                                toDate = null;
                                              });
                                            },
                                            child: Container(
                                              width: double.maxFinite,
                                              padding: const EdgeInsets.only(
                                                  left: 35, top: 5, bottom: 10),
                                              child: Text(
                                                staticTextTranslate(
                                                    "Tax Summary"),
                                                style: TextStyle(
                                                    fontSize: getMediumFontSize,
                                                    color: selectedPage ==
                                                            "Tax Summary"
                                                        ? Colors.blue
                                                        : Colors.black),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Expanded(
                                        child: SizedBox(
                                          height: 10,
                                        ),
                                      )
                                    ]),
                                  ),
                                  if (selectedPage.isNotEmpty)
                                    Expanded(child: detailsScreen())
                                ],
                              )),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  detailsScreen() {
    return Container(
        height: MediaQuery.of(context).size.height * 0.9,
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            border: Border.all(
                width: 0.0, color: const Color.fromARGB(255, 255, 255, 255)),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(255, 255, 255, 255),
                blurRadius: 0.0,
              ),
            ],
            color: homeBgColor,
            borderRadius: BorderRadius.circular(4)),
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!showPageDetails) selectDateDialog(),
            Directionality(
                textDirection: TextDirection.ltr,
                child: showPageDetails && selectedPage == "Sales Summary"
                    ? salesJournal()
                    : showPageDetails && selectedPage == "Tax Summary"
                        ? vatSummary()
                        : showPageDetails && selectedPage == "Purchase Summary"
                            ? purchaseJournal()
                            : const SizedBox())
          ],
        ));
  }

  purchaseJournal() {
    List<DbVoucherData> sortedDbVoucherDataLst = [];

    for (DbVoucherData d in dbVoucherDataLst) {
      DateTime date = DateTime(
        d.createdDate.year,
        d.createdDate.month,
        d.createdDate.day,
      );

      if (date.compareTo(fromDate!) != -1 && date.compareTo(toDate!) != 1) {
        if (d.voucherType == datatype || datatype == 'All Document') {
          sortedDbVoucherDataLst.add(d);
        }
      }
    }

    sortedDbVoucherDataLst.sort((a, b) => a.voucherNo.compareTo(b.voucherNo));

    double totalQty = 0;
    double tax = 0;
    double totalDiscount = 0;
    double total = 0;

    for (var s in sortedDbVoucherDataLst) {
      if (s.voucherType == 'Return') {
        totalQty -= double.parse(s.qtyRecieved);
        // for (var i in s.selectedItems)
        //   totalCost -= double.parse(s.totalQty) * double.parse(i['cost']);
        tax -= double.parse(calculateTaxValue(
            dbVoucherData: s, inventoryDataLst: allInventoryDataLst));
        totalDiscount -= double.parse(s.discountValue);
        total -= double.parse(s.voucherTotal);
      } else {
        totalQty += double.parse(s.qtyRecieved);
        // for (var i in s.selectedItems)
        //   totalCost += double.parse(s.totalQty) * double.parse(i['cost']);
        tax += double.parse(calculateTaxValue(
            dbVoucherData: s, inventoryDataLst: allInventoryDataLst));
        totalDiscount += double.parse(s.discountValue);
        total += double.parse(s.voucherTotal);
      }
    }

    return ReportPdfViewer(
      inventoryDataLst: allInventoryDataLst,
      totalCost: 0,
      fromDate: fromDate,
      selectedPage: selectedPage,
      sortedDbVoucherDataLst: sortedDbVoucherDataLst,
      sortedDbReceiptDataLst: const [],
      tax: tax,
      taxPer: taxPerForReceipt,
      toDate: toDate,
      total: total,
      totalDiscount: totalDiscount,
      totalQty: totalQty,
      //
      purTaxValue: -1,
      purTotalSalesWithTax: -1,
      salesTaxValue: -1,
      salesTotalSales: -1,
      salesTotalSalesWithTax: -1,
    );
  }

  calculateTotalCost(DbReceiptData d) {
    double totalCost = 0;
    for (var i in d.selectedItems) {
      totalCost += double.parse(i['cost']);
    }
    return totalCost;
  }

  vatSummary() {
    //sales stuff
    List<DbReceiptData> sortedDbReceiptDataLst = [];
    for (DbReceiptData d in dbReceiptDataLst) {
      DateTime date = DateTime(
        d.createdDate.year,
        d.createdDate.month,
        d.createdDate.day,
      );

      if (date.compareTo(fromDate!) != -1 && date.compareTo(toDate!) != 1) {
        if (d.receiptType == datatype || datatype == 'All Document') {
          sortedDbReceiptDataLst.add(d);
        }
      }
    }

    double salesTaxValue = 10;
    double salesTotalSalesWithTax = 0;
    double salesTotalSales = 0;

    for (var s in sortedDbReceiptDataLst) {
      if (s.receiptType == 'Return') {
        salesTotalSalesWithTax -= double.parse(s.subTotal);
      } else {
        salesTotalSalesWithTax += double.parse(s.subTotal);
      }
    }

    salesTaxValue = double.parse(
        calculateVatTaxForReceipt(salesTotalSalesWithTax.toString()));
    salesTotalSales = salesTotalSalesWithTax - salesTaxValue;

    //Purchase stuff
    List<DbVoucherData> sortedDbVoucherDataLst = [];
    for (DbVoucherData d in dbVoucherDataLst) {
      DateTime date = DateTime(
        DateTime.parse(d.purchaseInvoiceDate).year,
        DateTime.parse(d.purchaseInvoiceDate).month,
        DateTime.parse(d.purchaseInvoiceDate).day,
      );

      if (date.compareTo(fromDate!) != -1 && date.compareTo(toDate!) != 1) {
        if (d.voucherType == datatype || datatype == 'All Document') {
          sortedDbVoucherDataLst.add(d);
        }
      }
    }

    double purTaxValue = 0;
    double purTotalSalesWithTax = 0;
    for (var s in sortedDbVoucherDataLst) {
      if (s.voucherType == 'Return') {
        purTotalSalesWithTax -= double.parse(s.voucherTotal);
        //calculating tax value
        purTaxValue += calculateTaxValueForVoucher(
            s.selectedItems.map((e) => LocalVoucherData.fromMap(e)).toList(),
            s.discountValue,
            s.tax);
      } else {
        purTotalSalesWithTax += double.parse(s.voucherTotal);
        //calculating tax value
        purTaxValue += calculateTaxValueForVoucher(
            s.selectedItems.map((e) => LocalVoucherData.fromMap(e)).toList(),
            s.discountValue,
            s.tax);
      }
    }

    // print(purTotalSalesWithTax);
    return ReportPdfViewer(
      totalCost: 0, inventoryDataLst: allInventoryDataLst,
      fromDate: fromDate,
      selectedPage: selectedPage,
      sortedDbVoucherDataLst: sortedDbVoucherDataLst,
      sortedDbReceiptDataLst: sortedDbReceiptDataLst,
      taxPer: taxPerForReceipt,
      toDate: toDate,
      tax: -1,
      total: -1,
      totalDiscount: -1,
      totalQty: -1,
      //
      purTaxValue: purTaxValue,
      purTotalSalesWithTax: purTotalSalesWithTax,
      salesTaxValue: salesTaxValue,
      salesTotalSales: salesTotalSales,
      salesTotalSalesWithTax: salesTotalSalesWithTax,
    );
  }

  salesJournal() {
    List<DbReceiptData> sortedDbReceiptDataLst = [];

    for (DbReceiptData d in dbReceiptDataLst) {
      // if (fromDate == toDate && d.createdDate.compareTo(fromDate!) != 1) {
      //   sortedDbReceiptDataLst.add(d);
      // } else

      DateTime date = DateTime(
        d.createdDate.year,
        d.createdDate.month,
        d.createdDate.day,
      );

      if (date.compareTo(fromDate!) != -1 && date.compareTo(toDate!) != 1) {
        if (d.receiptType == datatype || datatype == 'All Document') {
          sortedDbReceiptDataLst.add(d);
        }
      }
    }

    sortedDbReceiptDataLst.sort((a, b) => a.receiptNo.compareTo(b.receiptNo));

    double totalQty = 0;
    double totalCost = 0;
    double tax = 0;
    double totalDiscount = 0;
    double total = 0;

    for (var s in sortedDbReceiptDataLst) {
      if (s.receiptType == 'Return') {
        totalQty -= double.parse(s.totalQty);
        for (var i in s.selectedItems) {
          totalCost -= double.parse(s.totalQty) * double.parse(i['cost']);
        }
        tax -= double.parse(s.taxValue
            // calculateVatTax(s.subTotal)
            );
        totalDiscount -= double.parse(s.discountValue);
        total -= double.parse(s.subTotal);
      } else {
        totalQty += double.parse(s.totalQty);
        for (var i in s.selectedItems) {
          totalCost += double.parse(s.totalQty) * double.parse(i['cost']);
        }
        tax += double.parse(s.taxValue
            // calculateVatTax(s.subTotal)
            );
        totalDiscount += double.parse(s.discountValue);
        total += double.parse(s.subTotal);
      }
    }

    return ReportPdfViewer(
      totalCost: totalCost, inventoryDataLst: allInventoryDataLst,
      fromDate: fromDate,
      selectedPage: selectedPage,
      sortedDbVoucherDataLst: const [],
      sortedDbReceiptDataLst: sortedDbReceiptDataLst,
      tax: tax,
      taxPer: taxPerForReceipt,
      toDate: toDate,
      total: total,
      totalDiscount: totalDiscount,
      totalQty: totalQty,
      //
      purTaxValue: -1,
      purTotalSalesWithTax: -1,
      salesTaxValue: -1,
      salesTotalSales: -1,
      salesTotalSalesWithTax: -1,
    );
  }

  selectDateDialog() {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 8.0,
              ),
            ],
            borderRadius: BorderRadius.circular(8)),
        height: 350,
        width: 500,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(
            height: 30,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Text(
              'Reports',
              style: TextStyle(fontSize: 20),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Text(
              'Select date range, document type and click run to show reports',
              style: TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
              child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  SizedBox(
                    width: 170,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(staticTextTranslate('Select Date From'),
                            style: TextStyle(
                              fontSize: getMediumFontSize,
                            )),
                        const SizedBox(
                          height: 5,
                        ),
                        GestureDetector(
                          onTap: () async {
                            DateTime? dateTime = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2050),
                            );

                            if (dateTime != null) {
                              if (toDate != null &&
                                  toDate!.compareTo(dateTime) == -1) {
                                toDate = null;
                                showToDateError = true;
                              }

                              setState(() {
                                fromDate = dateTime;
                                showFromDateError = false;
                              });
                            }
                          },
                          child: Container(
                            width: 200,
                            height: 32,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            child: Row(
                              children: [
                                Text(
                                  fromDate == null
                                      ? staticTextTranslate('Select Date')
                                      : DateFormat('dd / MM / yyyy')
                                          .format(fromDate!),
                                  style: TextStyle(
                                      fontSize: getMediumFontSize + 2,
                                      color: fromDate == null
                                          ? Colors.grey
                                          : Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        if (showFromDateError)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                                staticTextTranslate('Please select from date'),
                                style: TextStyle(
                                    fontSize: getMediumFontSize,
                                    color: Colors.red[700])),
                          )
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 170,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(staticTextTranslate('To'),
                            style: TextStyle(
                              fontSize: getMediumFontSize,
                            )),
                        const SizedBox(
                          height: 5,
                        ),
                        GestureDetector(
                          onTap: () async {
                            DateTime? dateTime = await showDatePicker(
                              context: context,
                              initialDate: fromDate ?? DateTime.now(),
                              firstDate: fromDate ?? DateTime(1900),
                              lastDate: DateTime(2050),
                            );
                            if (dateTime != null) {
                              setState(() {
                                toDate = dateTime;
                                showToDateError = false;
                              });
                            }
                          },
                          child: Container(
                            width: 170,
                            height: 35,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            child: Row(
                              children: [
                                Text(
                                  toDate == null
                                      ? staticTextTranslate('Select Date')
                                      : DateFormat('dd / MM / yyyy')
                                          .format(toDate!),
                                  style: TextStyle(
                                      fontSize: getMediumFontSize + 2,
                                      color: toDate == null
                                          ? Colors.grey
                                          : Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        if (showToDateError)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              staticTextTranslate('Please select to date'),
                              style: TextStyle(
                                  fontSize: getMediumFontSize,
                                  color: Colors.red[700]),
                            ),
                          )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Document type',
                style: TextStyle(
                    fontSize: 14,
                    color: selectedPage == "Tax Summary"
                        ? Colors.grey
                        : Colors.black),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                height: 30,
                width: 168,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 0.6,
                        color: selectedPage == "Tax Summary"
                            ? Colors.grey
                            : Colors.black),
                    borderRadius: BorderRadius.circular(3)),
                child: DropdownButton<String>(
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: <String>['All Document', 'Return', 'Regular']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value,
                          style: TextStyle(
                            fontSize: getMediumFontSize + 2,
                          )),
                    );
                  }).toList(),
                  value: datatype,
                  onChanged: selectedPage == "Tax Summary"
                      ? null
                      : (val) {
                          datatype = val ?? 'All Document';
                          setState(() {});
                        },
                ),
              )
            ]),
          )),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 245, 255, 255),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4))),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 45,
                    width: 120,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: darkBlueColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4))),
                        onPressed: () async {
                          bool showData = true;
                          if (toDate == null) {
                            showToDateError = true;
                            showData = false;
                          }
                          if (fromDate == null) {
                            showFromDateError = true;
                            showData = false;
                          }
                          if (showData) showPageDetails = true;
                          setState(() {});
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Iconsax.shapes,
                              size: 19,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(staticTextTranslate('Run'),
                                style: TextStyle(
                                  fontSize: getMediumFontSize,
                                )),
                          ],
                        )),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 45,
                    width: 120,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.cancel_outlined,
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
                ],
              ),
            ),
          )
        ]));
  }

  String calculateVatTaxForReceipt(String val) {
    double p = double.parse(val);

    return (p / (1 + (100 / taxPerForReceipt))).toStringAsFixed(2);
  }

  double calculateVatTaxForVoucher(
      {required String val, required double percentage}) {
    print('percentage');
    print(percentage);
    double p = double.parse(val);

    return double.tryParse((p / (1 + (100 / percentage))).toStringAsFixed(2)) ??
        0;
  }

  double calculateTaxValueForVoucher(List<LocalVoucherData> fullVoucherData,
      String discountValue, String tax) {
    double t = 0;
    for (LocalVoucherData v in fullVoucherData) {
      double d = 0;
      d = double.tryParse(v.cost) ?? 0;
      if (double.tryParse(v.qty) != null) t += d * double.tryParse(v.qty)!;
    }
    if (discountValue.isNotEmpty) {
      double dis = double.tryParse(discountValue) ?? 0;
      if (dis != 0) {
        // if (!disPerFocusNode.hasFocus) {
        //   discountPerTextEditingController.text =
        //       ((dis * 100) / t).toStringAsFixed(2);
        //   discountValue = ((dis * 100) / t).toStringAsFixed(2);
        // }
        t = t - dis;
      }
    }
    double taxValue = 0;
    //tax
    if (tax.isNotEmpty) {
      double tx = double.tryParse(tax) ?? 0;

      if (tx != 0) taxValue = (t * tx / 100);
    }

    return double.tryParse(taxValue.toStringAsFixed(2)) ?? 0;
  }
}
