import 'package:barcode/barcode.dart';
import 'package:bitpro_hive/home/sales/customer/sideMenuButton.dart';
import 'package:bitpro_hive/widget/filter_container.dart';
import 'package:bitpro_hive/widget/filter_text_fileds/fiter_textfield.dart';

import 'package:bitpro_hive/widget/string_related/get_id_number.dart';
import 'package:bitpro_hive/widget/top_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

import 'package:bitpro_hive/model/store_data.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/model/voucher/db_voucher_data.dart';
import 'package:bitpro_hive/services/firestore_api/fb_merchandise/fb_vendor_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_settings/fb_store_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_vouchers/fb_voucher_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_merchandise_db_service/vendors_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_settings/hive_store_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_voucher_db_service/hive_voucher_db_service.dart';
import 'package:bitpro_hive/shared/custom_top_nav_bar.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:bitpro_hive/shared/global_variables/font_sizes.dart';
import 'package:bitpro_hive/shared/loading.dart';

import '../../../model/vendor_data.dart';
import '../../../shared/global_variables/static_text_translate.dart';
import '../../../shared/save_file_and_launch.dart';
import 'create_edit_voucher_page.dart';

class VoucherPage extends StatefulWidget {
  final UserData userData;

  const VoucherPage({Key? key, required this.userData}) : super(key: key);

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();
  VoucherDataSource? voucherDataSource;
  DataGridController dataGridController = DataGridController();
  DateTime? rangeStartDate;
  DateTime? rangeEndDate;
  bool loading = true;
  final TextEditingController _vendorTypeAheadController =
      TextEditingController();
  final TextEditingController barcodeFilterController = TextEditingController();
  final TextEditingController vendorInvoiceFilterController =
      TextEditingController();
  List<DbVoucherData> dbVoucherDataLst = [];
  List<VendorData> vendorDataLst = [];

  String? selectedStoreDocId;
  List<StoreData> allStoreDataLst = [];
  @override
  void initState() {
    super.initState();
    hiveFetchData();
  }

  commonInit() async {
    dbVoucherDataLst.sort((b, a) => a.createdDate.compareTo(b.createdDate));
    //getting default selected store
    int selectedStoreCode = await HiveStoreDbService().getSelectedStoreCode();
    int index = allStoreDataLst.indexWhere(
        (element) => element.storeCode == selectedStoreCode.toString());

    if (index != -1) {
      selectedStoreDocId = allStoreDataLst.elementAt(index).docId;
    } else {
      selectedStoreDocId = allStoreDataLst.first.docId;
    }

    voucherDataSource = VoucherDataSource(
        voucherData: selectedStoreDocId == 'All'
            ? dbVoucherDataLst
            : dbVoucherDataLst
                .where((e) => e.selectedStoreDocId == selectedStoreDocId)
                .toList(),
        allStoreDataLst: allStoreDataLst,
        vendorDataLst: vendorDataLst);
    setState(() {
      loading = false;
    });
  }

  hiveFetchData() async {
    //stores data filter
    allStoreDataLst = await HiveStoreDbService().fetchAllStoresData();
    //
    //vendor data
    vendorDataLst = await HiveVendorDbService().fetchAllVendorsData();
    //voucher data
    dbVoucherDataLst = await HiveVoucherDbService().fetchAllVoucherData();
    await commonInit();
  }

  fbFetchData() async {
    //stores data filter
    allStoreDataLst =
        await FbStoreDbService(context: context).fetchAllStoresData();
    //
    //vendor data
    vendorDataLst =
        await FbVendorDbService(context: context).fetchAllVendorsData();
    //voucher data
    dbVoucherDataLst =
        await FbVoucherDbService(context: context).fetchAllVoucherData();

    await commonInit();
  }

  searchByVoucher(String txt) {
    List<DbVoucherData> filteredInventoryDataLst = [];
    if (txt.isEmpty) {
      voucherDataSource = VoucherDataSource(
          voucherData: selectedStoreDocId == 'All'
              ? dbVoucherDataLst
              : dbVoucherDataLst
                  .where((e) => e.selectedStoreDocId == selectedStoreDocId)
                  .toList(),
          allStoreDataLst: allStoreDataLst,
          vendorDataLst: vendorDataLst);
      setState(() {});
      return;
    }

    for (var i in selectedStoreDocId == 'All'
        ? dbVoucherDataLst
        : dbVoucherDataLst
            .where((e) => e.selectedStoreDocId == selectedStoreDocId)
            .toList()) {
      if (i.voucherNo.toLowerCase().contains(txt.toLowerCase())) {
        filteredInventoryDataLst.add(i);
      }
    }
    voucherDataSource = VoucherDataSource(
        voucherData: filteredInventoryDataLst,
        allStoreDataLst: allStoreDataLst,
        vendorDataLst: vendorDataLst);

    setState(() {});
  }

  searchByVendor(String venId) {
    List<DbVoucherData> filteredInventoryDataLst = [];

    for (var i in selectedStoreDocId == 'All'
        ? dbVoucherDataLst
        : dbVoucherDataLst
            .where((e) => e.selectedStoreDocId == selectedStoreDocId)
            .toList()) {
      if (i.vendor == venId) {
        filteredInventoryDataLst.add(i);
      }
    }
    voucherDataSource = VoucherDataSource(
        voucherData: filteredInventoryDataLst,
        allStoreDataLst: allStoreDataLst,
        vendorDataLst: vendorDataLst);
    setState(() {});
  }

  searchByVendorInvoice(String txt) {
    List<DbVoucherData> filteredInventoryDataLst = [];
    if (txt.isEmpty) {
      voucherDataSource = VoucherDataSource(
          voucherData: selectedStoreDocId == 'All'
              ? dbVoucherDataLst
              : dbVoucherDataLst
                  .where((e) => e.selectedStoreDocId == selectedStoreDocId)
                  .toList(),
          allStoreDataLst: allStoreDataLst,
          vendorDataLst: vendorDataLst);
      setState(() {});
      return;
    }

    for (var i in selectedStoreDocId == 'All'
        ? dbVoucherDataLst
        : dbVoucherDataLst
            .where((e) => e.selectedStoreDocId == selectedStoreDocId)
            .toList()) {
      if (i.purchaseInvoice.toLowerCase().contains(txt.toLowerCase())) {
        filteredInventoryDataLst.add(i);
      }
    }
    voucherDataSource = VoucherDataSource(
        voucherData: filteredInventoryDataLst,
        allStoreDataLst: allStoreDataLst,
        vendorDataLst: vendorDataLst);
    setState(() {});
  }

  filterAccordingSelectedDate() {
    List<DbVoucherData> filteredInventoryDataLst = [];
    if (rangeStartDate != null && rangeEndDate != null) {
      for (var i in selectedStoreDocId == 'All'
          ? dbVoucherDataLst
          : dbVoucherDataLst
              .where((e) => e.selectedStoreDocId == selectedStoreDocId)
              .toList()) {
        DateTime cd = DateTime.parse(i.purchaseInvoiceDate);
        DateTime tmp = DateTime(cd.year, cd.month, cd.day);
        if (tmp.compareTo(rangeStartDate!) != -1 &&
            (tmp.compareTo(rangeEndDate!) != 1)) {
          filteredInventoryDataLst.add(i);
        }
      }
    } else if (rangeStartDate != null) {
      var res = dbVoucherDataLst.where((e) {
        DateTime cd = DateTime.parse(e.purchaseInvoiceDate);
        return cd.day == rangeStartDate!.day &&
            cd.month == rangeStartDate!.month &&
            cd.year == rangeStartDate!.year;
      });

      filteredInventoryDataLst = res.toList();
    }

    voucherDataSource = VoucherDataSource(
        voucherData: filteredInventoryDataLst,
        allStoreDataLst: allStoreDataLst,
        vendorDataLst: vendorDataLst);
    rangeStartDate = null;
    rangeEndDate = null;
    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return customTopNavBar(
      Scaffold(
        backgroundColor: homeBgColor,
        body: SafeArea(
          child: Column(
            children: [
              const TopBar(pageName: 'Voucher'),
              Expanded(
                child: Container(
                  color: homeBgColor,
                  child: Row(
                    children: [
                      Container(
                        color: const Color.fromARGB(255, 43, 43, 43),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 0,
                            ),
                            SideMenuButton(
                              label: 'Back',
                              iconPath: 'assets/icons/back.png',
                              buttonFunction: () {
                                Navigator.pop(context);
                              },
                            ),
                            SideMenuButton(
                              label: 'Create',
                              iconPath: 'assets/icons/plus.png',
                              buttonFunction: () async {
                                String newVoucherId = await getIdNumber(
                                    dbVoucherDataLst.length + 1);
                                bool? res = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            CreateEditVoucherPage(
                                                newVoucherId: newVoucherId,
                                                userData: widget.userData,
                                                vendorDataLst: vendorDataLst)));

                                if (res != null && res) {
                                  setState(() {
                                    loading = true;
                                  });

                                  fbFetchData();
                                }
                              },
                            ),
                            SideMenuButton(
                              label: 'View',
                              iconPath: 'assets/icons/view.png',
                              buttonFunction: () async {
                                if (dataGridController.selectedRow != null) {
                                  var voucherNo = '';

                                  for (var c in dataGridController.selectedRow!
                                      .getCells()) {
                                    if (c.columnName == 'voucher_no') {
                                      voucherNo = c.value;
                                    }
                                  }

                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CreateEditVoucherPage(
                                                  newVoucherId: voucherNo,
                                                  selectedDbVoucherData:
                                                      dbVoucherDataLst.firstWhere(
                                                          (element) =>
                                                              element
                                                                  .voucherNo ==
                                                              voucherNo),
                                                  viewMode: true,
                                                  userData: widget.userData,
                                                  vendorDataLst:
                                                      vendorDataLst)));
                                }
                              },
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            SideMenuButton(
                              label: 'Refresh',
                              iconPath: 'assets/icons/refresh.png',
                              buttonFunction: () async {
                                setState(() {
                                  loading = true;
                                });

                                await fbFetchData();
                              },
                            ),
                            SideMenuButton(
                              label: 'Date Range',
                              iconPath: 'assets/icons/date.png',
                              buttonFunction: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        child: SizedBox(
                                          width: 400,
                                          height: 380,
                                          child: SfDateRangePicker(
                                              onSelectionChanged:
                                                  (DateRangePickerSelectionChangedArgs
                                                      args) {
                                                if (args.value
                                                    is PickerDateRange) {
                                                  rangeStartDate =
                                                      args.value.startDate;
                                                  rangeEndDate =
                                                      args.value.endDate;
                                                  setState(() {});
                                                }
                                              },
                                              onCancel: () {
                                                Navigator.pop(context);
                                              },
                                              onSubmit: (var p0) {
                                                filterAccordingSelectedDate();
                                                Navigator.pop(context);
                                              },
                                              cancelText: 'CANCEL',
                                              confirmText: 'OK',
                                              showTodayButton: false,
                                              showActionButtons: true,
                                              view: DateRangePickerView.month,
                                              selectionMode:
                                                  DateRangePickerSelectionMode
                                                      .range),
                                        ),
                                      );
                                    });
                              },
                            ),
                            SideMenuButton(
                              label: 'Export',
                              iconPath: 'assets/icons/export.png',
                              buttonFunction: () async {
                                setState(() {
                                  loading = true;
                                });
                                final Workbook workbook =
                                    _key.currentState!.exportToExcelWorkbook();
                                final List<int> bytes = workbook.saveAsStream();
                                workbook.dispose();
                                await saveAndLaunchFile(
                                    bytes, fileExtension: 'xlsx', context);
                                setState(() {
                                  loading = false;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 0,
                      ),
                      Expanded(
                        child: Card(
                            shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    width: 0.5, color: Colors.grey),
                                borderRadius: BorderRadius.circular(5)),
                            elevation: 0,
                            color: Colors.white,
                            child: Column(
                              children: [
                                //filter
                                filterWidget(),
                                if (voucherDataSource == null || loading)
                                  Expanded(child: showLoading()),
                                if (voucherDataSource != null && !loading)
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                          border: Border.all(width: 0.3)),
                                      child: SfDataGridTheme(
                                        data: SfDataGridThemeData(
                                            headerColor:
                                                const Color(0xffF1F1F1),
                                            sortIcon: const Icon(
                                                Icons.arrow_drop_down_rounded),
                                            headerHoverColor:
                                                const Color(0xffdddfe8),
                                            selectionColor: loginBgColor),
                                        child: Expanded(
                                          child: SfDataGrid(
                                            isScrollbarAlwaysShown: true,
                                            onQueryRowHeight: (details) {
                                              // Set the row height as 70.0 to the column header row.
                                              return details.rowIndex == 0
                                                  ? 25.0
                                                  : 25.0;
                                            },
                                            rowHeight: 25,
                                            headerRowHeight: 25,
                                            headerGridLinesVisibility:
                                                GridLinesVisibility.both,
                                            allowSorting: true,
                                            allowTriStateSorting: true,
                                            controller: dataGridController,
                                            selectionMode: SelectionMode.single,
                                            source: voucherDataSource!,
                                            columnWidthMode:
                                                ColumnWidthMode.lastColumnFill,
                                            onSelectionChanged:
                                                (addedRows, removedRows) {
                                              setState(() {});
                                            },
                                            columns: <GridColumn>[
                                              GridColumn(
                                                  columnName:
                                                      'serialNumberForStyleColor',
                                                  visible: false,
                                                  label: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0.0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        'serialNumberForStyleColor',
                                                        style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
                                                        ),
                                                      ))),
                                              GridColumn(
                                                  width: 130,
                                                  columnName: 'voucher_no',
                                                  label: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        staticTextTranslate(
                                                            'Voucher #'),
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  1,
                                                        ),
                                                      ))),
                                              GridColumn(
                                                  width: 100,
                                                  columnName: 'type',
                                                  label: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        staticTextTranslate(
                                                            'Type'),
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  1,
                                                        ),
                                                      ))),
                                              GridColumn(
                                                  width: 300,
                                                  columnName: 'vendor',
                                                  label: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        staticTextTranslate(
                                                            'Vendor'),
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  1,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ))),
                                              GridColumn(
                                                  width: 150,
                                                  columnName: 'qty_received',
                                                  label: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        staticTextTranslate(
                                                            'Qty Received'),
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  1,
                                                        ),
                                                      ))),
                                              GridColumn(
                                                  width: 150,
                                                  columnName: 'voucher_total',
                                                  label: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        staticTextTranslate(
                                                            'Voucher Total'),
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  1,
                                                        ),
                                                      ))),
                                              GridColumn(
                                                  width: 150,
                                                  columnName: 'vendor_inv',
                                                  label: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        staticTextTranslate(
                                                            'Vendor Inv#'),
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  1,
                                                        ),
                                                      ))),
                                              GridColumn(
                                                  maximumWidth: 300,
                                                  minimumWidth: 200,
                                                  columnName: 'store',
                                                  label: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        staticTextTranslate(
                                                            'Store'),
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  1,
                                                        ),
                                                      ))),
                                              GridColumn(
                                                  width: 190,
                                                  columnName: 'created_date',
                                                  label: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        staticTextTranslate(
                                                            'Created Date'),
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  1,
                                                        ),
                                                      ))),
                                              GridColumn(
                                                  width: 150,
                                                  columnName: 'created_by',
                                                  label: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        staticTextTranslate(
                                                            'Created By'),
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  1,
                                                        ),
                                                      ))),
                                            ],
                                            gridLinesVisibility:
                                                GridLinesVisibility.both,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                              ],
                            )),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  filterWidget() {
    return FilterContainer(fiterFields: [
      FilterTextField(
        onPressed: () {
          barcodeFilterController.clear();

          voucherDataSource = VoucherDataSource(
              voucherData: selectedStoreDocId == 'All'
                  ? dbVoucherDataLst
                  : dbVoucherDataLst
                      .where((e) => e.selectedStoreDocId == selectedStoreDocId)
                      .toList(),
              allStoreDataLst: allStoreDataLst,
              vendorDataLst: vendorDataLst);
          setState(() {});
        },
        icon: Icon(
            barcodeFilterController.text.isEmpty
                ? CupertinoIcons.search
                : Icons.clear,
            size: 18,
            color: barcodeFilterController.text.isEmpty
                ? Colors.grey[600]
                : Colors.black),
        controller: barcodeFilterController,
        hintText: 'Voucher #',
        onChanged: (val) {
          searchByVoucher(val);
        },
      ),
      Container(
        width: 230,
        height: 32,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 0.5),
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(5)),
        padding: const EdgeInsets.only(right: 10, bottom: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              padding: const EdgeInsets.only(top: 3),
              onPressed: () {
                _vendorTypeAheadController.clear();

                voucherDataSource = VoucherDataSource(
                    voucherData: selectedStoreDocId == 'All'
                        ? dbVoucherDataLst
                        : dbVoucherDataLst
                            .where((e) =>
                                e.selectedStoreDocId == selectedStoreDocId)
                            .toList(),
                    allStoreDataLst: allStoreDataLst,
                    vendorDataLst: vendorDataLst);
                setState(() {});
              },
              splashRadius: 1,
              icon: Icon(
                  _vendorTypeAheadController.text.isEmpty
                      ? CupertinoIcons.search
                      : Icons.clear,
                  size: 18,
                  color: _vendorTypeAheadController.text.isEmpty
                      ? Colors.grey[600]
                      : Colors.black),
            ),
            Flexible(
              child: TypeAheadFormField(
                getImmediateSuggestions: false,
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _vendorTypeAheadController,
                  decoration: InputDecoration(
                    hintText: staticTextTranslate('Vendor'),
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    contentPadding: const EdgeInsets.only(bottom: 14, right: 5),
                    border: InputBorder.none,
                  ),
                ),
                suggestionsCallback: (pattern) {
                  return vendorDataLst
                      .where((e) => e.vendorName
                          .toLowerCase()
                          .contains(pattern.toLowerCase()))
                      .toList();
                },
                noItemsFoundBuilder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(staticTextTranslate('No Items Found!'),
                        style: TextStyle(
                          fontSize: getMediumFontSize,
                        )),
                  );
                },
                itemBuilder: (context, VendorData suggestion) {
                  return ListTile(
                    title: Text(suggestion.vendorName,
                        style: TextStyle(
                          fontSize: getMediumFontSize,
                        )),
                  );
                },
                transitionBuilder: (context, suggestionsBox, controller) {
                  return suggestionsBox;
                },
                onSuggestionSelected: (VendorData suggestion) {
                  _vendorTypeAheadController.text = suggestion.vendorName;
                  setState(() {
                    searchByVendor(suggestion.vendorId);
                  });
                },
              ),
            ),
          ],
        ),
      ),
      FilterTextField(
        onPressed: () {
          vendorInvoiceFilterController.clear();

          voucherDataSource = VoucherDataSource(
              voucherData: selectedStoreDocId == 'All'
                  ? dbVoucherDataLst
                  : dbVoucherDataLst
                      .where((e) => e.selectedStoreDocId == selectedStoreDocId)
                      .toList(),
              vendorDataLst: vendorDataLst,
              allStoreDataLst: allStoreDataLst);
          setState(() {});
        },
        icon: Icon(
            vendorInvoiceFilterController.text.isEmpty
                ? CupertinoIcons.search
                : Icons.clear,
            size: 18,
            color: vendorInvoiceFilterController.text.isEmpty
                ? Colors.grey[600]
                : Colors.black),
        controller: vendorInvoiceFilterController,
        hintText: 'Vendor Invoice #',
        onChanged: (val) {
          searchByVendorInvoice(val);
        },
      ),
      const SizedBox(
        width: 5,
      ),
      Container(
        width: 230,
        height: 32,
        decoration: BoxDecoration(
            border: Border.all(width: 0.5, color: Colors.grey),
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(4)),
        padding: const EdgeInsets.only(right: 5, bottom: 5, top: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
                child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(4)),
                    padding: const EdgeInsets.only(right: 10, left: 10),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedStoreDocId,
                      underline: const SizedBox(),
                      hint: Text(
                        staticTextTranslate('Stores'),
                        style: TextStyle(
                          fontSize: getMediumFontSize + 1,
                        ),
                      ),
                      items: <String>['All'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                staticTextTranslate(value),
                                style: TextStyle(
                                  fontSize: getMediumFontSize + 1,
                                ),
                              ),
                            );
                          }).toList() +
                          allStoreDataLst.map((StoreData value) {
                            return DropdownMenuItem<String>(
                              value: value.docId,
                              child: Text(
                                staticTextTranslate(value.storeName),
                                style: TextStyle(
                                  fontSize: getMediumFontSize + 1,
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          selectedStoreDocId = val;
                          voucherDataSource = VoucherDataSource(
                              voucherData: val == 'All'
                                  ? dbVoucherDataLst
                                  : dbVoucherDataLst
                                      .where((e) => e.selectedStoreDocId == val)
                                      .toList(),
                              vendorDataLst: vendorDataLst,
                              allStoreDataLst: allStoreDataLst);

                          setState(() {});
                        }
                      },
                    ))),
          ],
        ),
      ),
      const SizedBox(
        width: 5,
      ),
    ]);
  }
}

class VoucherDataSource extends DataGridSource {
  VoucherDataSource(
      {required List<DbVoucherData> voucherData,
      required List<VendorData> vendorDataLst,
      required List<StoreData> allStoreDataLst}) {
    String findVendorName(String id) {
      String n = '';

      for (VendorData v in vendorDataLst) {
        if (v.vendorId == id) {
          n = v.vendorName;

          break;
        }
      }

      return n;
    }

    _employeeData = voucherData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(
                  columnName: 'serialNumberForStyleColor',
                  value: voucherData.indexOf(e) + 1),
              DataGridCell<String>(
                  columnName: 'voucher_no', value: e.voucherNo),
              DataGridCell<String>(columnName: 'type', value: e.voucherType),
              DataGridCell<String>(
                  columnName: 'vendor', value: findVendorName(e.vendor)),
              DataGridCell<String>(
                  columnName: 'qty_received', value: e.qtyRecieved),
              DataGridCell<String>(
                  columnName: 'voucher_total', value: e.voucherTotal),
              DataGridCell<String>(
                  columnName: 'vendor_inv', value: e.purchaseInvoice),
              DataGridCell<String>(
                  columnName: 'store',
                  value: allStoreDataLst
                          .any((s) => s.docId == e.selectedStoreDocId)
                      ? allStoreDataLst
                          .where((element) =>
                              element.docId == e.selectedStoreDocId)
                          .first
                          .storeName
                      : 'Store not found'
                  //  e.selectedStoreDocId
                  ),
              DataGridCell<String>(
                  columnName: 'created_date',
                  value: DateFormat.yMd().add_jm().format(e.createdDate)),
              DataGridCell<String>(
                  columnName: 'created_by', value: e.createdBy),
            ]))
        .toList();
  }

  List<DataGridRow> _employeeData = [];

  @override
  List<DataGridRow> get rows => _employeeData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    bool isReturnVoucher = false;

    if (row
            .getCells()
            .indexWhere((e) => e.columnName == 'type' && e.value == 'Return') !=
        -1) isReturnVoucher = true;
    return DataGridRowAdapter(
        color: row.getCells()[0].value.isEven
            ? const Color(0xffF1F1F1)
            : Colors.white,
        cells: row.getCells().map<Widget>((e) {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(3.0),
            child: Text(
              e.value.toString(),
              style: GoogleFonts.roboto(
                  fontSize: getMediumFontSize + 1,
                  color: isReturnVoucher ? Colors.red[700] : Colors.black,
                  fontWeight: FontWeight.w400),
            ),
          );
        }).toList());
  }
}
