import 'dart:io';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:bitpro_hive/home/sales/customer/sideMenuButton.dart';
import 'package:bitpro_hive/model/department_data.dart';
import 'package:bitpro_hive/model/store_data.dart';
import 'package:bitpro_hive/model/vendor_data.dart';
import 'package:bitpro_hive/services/firestore_api/fb_merchandise/fb_department_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_merchandise/fb_inventory_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_merchandise/fb_vendor_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_settings/fb_store_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_merchandise_db_service/department_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_merchandise_db_service/inventory_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_merchandise_db_service/vendors_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_settings/hive_store_db_service.dart';
import 'package:bitpro_hive/widget/filter_container.dart';
import 'package:bitpro_hive/widget/filter_text_fileds/fiter_textfield.dart';
import 'package:bitpro_hive/widget/string_related/get_id_number.dart';
import 'package:bitpro_hive/widget/string_related/get_random_string.dart';
import 'package:bitpro_hive/widget/top_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bitpro_hive/home/merchandise/inventory/inventory_create_edit.dart';
import 'package:bitpro_hive/model/inventory_data.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/shared/loading.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../../services/hive/import_data_exel/inventory_datat_excel.dart';
import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;
import '../../../shared/custom_top_nav_bar.dart';
import '../../../shared/global_variables/font_sizes.dart';
import '../../../shared/templates/tag/print_tag.dart';
import '../../../shared/save_file_and_launch.dart';
import 'package:excel/excel.dart' hide Border;

import '../../../shared/global_variables/static_text_translate.dart';

class InventoryPage extends StatefulWidget {
  final UserData userData;

  const InventoryPage({Key? key, required this.userData}) : super(key: key);

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

var selectedDataGirdListerner = ValueNotifier<DataGridRow?>(null);

class _InventoryPageState extends State<InventoryPage> {
  List<InventoryData> inventoryDataLst = [];
  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();
  EmployeeDataSource? inventoryDataSource;
  DataGridController dataGridController = DataGridController();
  DateTime? rangeStartDate;
  DateTime? rangeEndDate;
  bool loading = true;
  final TextEditingController _vendorTypeAheadController =
      TextEditingController();
  final TextEditingController _departmenttypeAheadController =
      TextEditingController();

  final TextEditingController barcodeFilterController = TextEditingController();
  final TextEditingController itemNameFilterController =
      TextEditingController();
  bool reload = false;
  List<InventoryData> filteredInventoryDataLst = [];

  String selectedStoreDocId = '';
  List<StoreData> allStoreDataLst = [];
  List<VendorData> allVendorDataLst = [];
  List<DepartmentData> allDepartmentDataLst = [];
  @override
  void initState() {
    super.initState();
    hiveFetchData();
  }

  commonFetch() async {
    //getting default selected store
    int selectedStoreCode = await HiveStoreDbService().getSelectedStoreCode();
    int index = allStoreDataLst.indexWhere(
        (element) => element.storeCode == selectedStoreCode.toString());

    if (index != -1) {
      selectedStoreDocId = allStoreDataLst.elementAt(index).docId;
    } else {
      selectedStoreDocId = allStoreDataLst.first.docId;
    }
    //

    filteredInventoryDataLst = inventoryDataLst;
    filteredInventoryDataLst
        .sort((b, a) => a.createdDate.compareTo(b.createdDate));

    inventoryDataSource = EmployeeDataSource(
        inventoryData: inventoryDataLst,
        selectedStoreDocId: selectedStoreDocId);

    setState(() {
      loading = false;
    });
  }

  hiveFetchData() async {
    //stores data filter
    allStoreDataLst = await HiveStoreDbService().fetchAllStoresData();
    allVendorDataLst = await HiveVendorDbService().fetchAllVendorsData();
    allDepartmentDataLst =
        await HiveDepartmentDbService().fetchAllDepartmentsData();
    inventoryDataLst = await HiveInventoryDbService().fetchAllInventoryData();
    await commonFetch();
  }

  fbFetchData() async {
    //stores data filter
    allStoreDataLst =
        await FbStoreDbService(context: context).fetchAllStoresData();
    allVendorDataLst =
        await FbVendorDbService(context: context).fetchAllVendorsData();
    allDepartmentDataLst =
        await FbDepartmentDbService(context: context).fetchAllDepartmentsData();
    inventoryDataLst =
        await FbInventoryDbService(context: context).fetchAllInventoryData();
    await commonFetch();
  }

  searchByBarcodeAndItemCode(String txt) {
    filteredInventoryDataLst = [];
    if (txt.isEmpty) {
      inventoryDataSource = EmployeeDataSource(
          inventoryData: inventoryDataLst,
          selectedStoreDocId: selectedStoreDocId);
      filteredInventoryDataLst = inventoryDataLst;
      setState(() {});
      return;
    }

    for (var i in inventoryDataLst) {
      if (i.itemCode.toLowerCase().contains(txt.toLowerCase()) ||
          i.barcode.toLowerCase().contains(txt.toLowerCase())) {
        filteredInventoryDataLst.add(i);
      }
    }
    inventoryDataSource = EmployeeDataSource(
        inventoryData: filteredInventoryDataLst,
        selectedStoreDocId: selectedStoreDocId);
    setState(() {});
  }

  searchByVendor(String venId) {
    filteredInventoryDataLst = [];

    for (var i in inventoryDataLst) {
      if (i.selectedVendorId == venId) {
        filteredInventoryDataLst.add(i);
      }
    }
    inventoryDataSource = EmployeeDataSource(
        inventoryData: filteredInventoryDataLst,
        selectedStoreDocId: selectedStoreDocId);
    setState(() {});
  }

  searchByDepartment(String depId) {
    filteredInventoryDataLst = [];

    for (var i in inventoryDataLst) {
      if (i.selectedDepartmentId == depId) {
        filteredInventoryDataLst.add(i);
      }
    }
    inventoryDataSource = EmployeeDataSource(
        inventoryData: filteredInventoryDataLst,
        selectedStoreDocId: selectedStoreDocId);
    setState(() {});
  }

  searchByItemName(String txt) {
    filteredInventoryDataLst = [];
    if (txt.isEmpty) {
      inventoryDataSource = EmployeeDataSource(
          inventoryData: inventoryDataLst,
          selectedStoreDocId: selectedStoreDocId);
      setState(() {});
      return;
    }

    for (var i in inventoryDataLst) {
      if (i.productName.toLowerCase().contains(txt.toLowerCase())) {
        filteredInventoryDataLst.add(i);
      }
    }
    inventoryDataSource = EmployeeDataSource(
        inventoryData: filteredInventoryDataLst,
        selectedStoreDocId: selectedStoreDocId);
    setState(() {});
  }

  filterAccordingSelectedDate() {
    filteredInventoryDataLst = [];
    if (rangeStartDate != null && rangeEndDate != null) {
      for (var emp in inventoryDataLst) {
        DateTime tmp = DateTime(
            emp.createdDate.year, emp.createdDate.month, emp.createdDate.day);
        if (tmp.compareTo(rangeStartDate!) != -1 &&
            (tmp.compareTo(rangeEndDate!) != 1)) {
          filteredInventoryDataLst.add(emp);
        }
      }
    } else if (rangeStartDate != null) {
      var res = inventoryDataLst.where((e) =>
          e.createdDate.day == rangeStartDate!.day &&
          e.createdDate.month == rangeStartDate!.month &&
          e.createdDate.year == rangeStartDate!.year);

      filteredInventoryDataLst = res.toList();
    }

    inventoryDataSource = EmployeeDataSource(
        inventoryData: filteredInventoryDataLst,
        selectedStoreDocId: selectedStoreDocId);
    rangeStartDate = null;
    rangeEndDate = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return customTopNavBar(
      Scaffold(
        backgroundColor: homeBgColor,
        body: SafeArea(
          child: Column(
            children: [
              TopBar(pageName: 'Inventory'),
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
                                String newInventoryId = await getIdNumber(
                                    inventoryDataLst.length + 1);
                                bool? res = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            CreateEditInventoryPage(
                                              newInventoryId: newInventoryId,
                                              inventoryDataLst:
                                                  inventoryDataLst,
                                              userData: widget.userData,
                                            )));

                                if (res != null && res) {
                                  setState(() {
                                    loading = true;
                                  });

                                  fbFetchData();
                                }
                              },
                            ),
                            SideMenuButton(
                              label: 'Edit',
                              iconPath: 'assets/icons/edit.png',
                              buttonFunction: () async {
                                if (dataGridController.selectedRow != null) {
                                  var itemcode = '';

                                  for (var c in dataGridController.selectedRow!
                                      .getCells()) {
                                    if (c.columnName == 'itemCode') {
                                      itemcode = c.value;
                                    }
                                  }

                                  bool? res = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CreateEditInventoryPage(
                                                newInventoryId: itemcode,
                                                inventoryDataLst:
                                                    inventoryDataLst,
                                                userData: widget.userData,
                                                edit: true,
                                                selectedRowData:
                                                    inventoryDataLst
                                                        .where((e) =>
                                                            e.itemCode ==
                                                            itemcode)
                                                        .first,
                                              )));
                                  if (res != null && res) {
                                    setState(() {
                                      loading = true;
                                    });

                                    fbFetchData();
                                  }
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
                              buttonFunction: () async {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        child: SizedBox(
                                          width: 400,
                                          height: 380,
                                          child: SfDateRangePicker(
                                              headerStyle:
                                                  DateRangePickerHeaderStyle(
                                                      backgroundColor:
                                                          darkBlueColor,
                                                      textStyle:
                                                          const TextStyle(
                                                        color: Colors.white,
                                                      )),
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
                                label: 'Print Tag',
                                iconPath: 'assets/icons/tag.png',
                                buttonFunction: () async {
                                  if (dataGridController.selectedRow != null) {
                                    String productName = '';
                                    String itemCode = '';
                                    String barcodeValue = '';
                                    String priceWt = '';
                                    int ohQty = -1;

                                    for (var c in dataGridController
                                        .selectedRow!
                                        .getCells()) {
                                      if (c.columnName == 'productName') {
                                        productName = c.value;
                                      } else if (c.columnName == 'itemCode') {
                                        itemCode = c.value;
                                      } else if (c.columnName == 'barcode') {
                                        barcodeValue = c.value;
                                      } else if (c.columnName == 'priceWT') {
                                        priceWt = c.value;
                                      } else if (c.columnName == 'ohQty') {
                                        ohQty = int.tryParse(c.value) ?? 0;
                                      }
                                    }

                                    PrintTagData selectedPrintTagData =
                                        PrintTagData(
                                            barcodeValue: barcodeValue,
                                            docQty: -1,
                                            itemCode: itemCode,
                                            productName: productName,
                                            onHandQty: ohQty,
                                            priceWt: priceWt);

                                    List<PrintTagData> allPrintTagDataLst =
                                        filteredInventoryDataLst.map((e) {
                                      int ohHandQty = e.ohQtyForDifferentStores[
                                              selectedStoreDocId] ??
                                          0;
                                      return PrintTagData(
                                          barcodeValue: e.barcode,
                                          docQty: -1,
                                          itemCode: e.itemCode,
                                          productName: e.productName,
                                          onHandQty: ohHandQty,
                                          priceWt: e.priceWT);
                                    }).toList();

                                    buildTagPrint(
                                      allPrintTagDataLst: allPrintTagDataLst,
                                      selectedPrintTagData:
                                          selectedPrintTagData,
                                      context: context,
                                    );
                                  }
                                }),
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
                            SideMenuButton(
                              label: 'Import Items',
                              iconPath: 'assets/icons/import.png',
                              buttonFunction: () async {
                                showImportDialog();
                              },
                            ),
                            SideMenuButton(
                              label: 'Update Quantity',
                              iconPath: 'assets/icons/date.png',
                              buttonFunction: () async {
                                showImportQuantityDialog();
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
                                // filter
                                filterWidget(),
                                if (inventoryDataSource == null || loading)
                                  Expanded(
                                    child: showLoading(),
                                  ),
                                if (inventoryDataSource != null && !loading)
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
                                          source: inventoryDataSource!,
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
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      'serialNumberForStyleColor',
                                                      style: TextStyle(
                                                        fontSize:
                                                            getMediumFontSize,
                                                      ),
                                                    ))),
                                            GridColumn(
                                                width: 120,
                                                columnName: 'barcode',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            1.0),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                        staticTextTranslate(
                                                            'Barcode'),
                                                        style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
                                                        )))),
                                            GridColumn(
                                                width: 170,
                                                columnName: 'itemCode',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            1.0),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                        staticTextTranslate(
                                                            'Item Code'),
                                                        style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
                                                        )))),
                                            GridColumn(
                                                width: 250,
                                                columnName: 'productName',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            1.0),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      staticTextTranslate(
                                                          'Product Name'),
                                                      style: TextStyle(
                                                        fontSize:
                                                            getMediumFontSize,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ))),
                                            GridColumn(
                                                width: 150,
                                                columnName: 'storeOhQty',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            1.0),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                        staticTextTranslate(
                                                            'Store OH'),
                                                        style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
                                                        )))),
                                            GridColumn(
                                                width: 150,
                                                columnName: 'companyOhQty',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            1.0),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                        staticTextTranslate(
                                                            'Company OH'),
                                                        style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
                                                        )))),
                                            GridColumn(
                                                width: 120,
                                                columnName: 'cost',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            1.0),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                        staticTextTranslate(
                                                            'Cost'),
                                                        style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
                                                        )))),
                                            GridColumn(
                                                width: 120,
                                                columnName: 'price',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            1.0),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                        staticTextTranslate(
                                                            'Price'),
                                                        style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
                                                        )))),
                                            GridColumn(
                                                width: 140,
                                                columnName: 'priceWT',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            1.0),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                        staticTextTranslate(
                                                            'Price W/T'),
                                                        style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
                                                        )))),
                                            GridColumn(
                                                width: 160,
                                                columnName: 'extCost',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            1.0),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                        staticTextTranslate(
                                                            'Ext Cost'),
                                                        style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
                                                        )))),
                                            GridColumn(
                                                width: 160,
                                                columnName: 'extPriceWt',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            1.0),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                        staticTextTranslate(
                                                            'Ext Price W/T'),
                                                        style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
                                                        )))),
                                          ],
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

          inventoryDataSource = EmployeeDataSource(
              inventoryData: inventoryDataLst,
              selectedStoreDocId: selectedStoreDocId);
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
        hintText: 'Barcode / Item Code',
        onChanged: (val) {
          searchByBarcodeAndItemCode(val);
        },
      ),
      FilterTextField(
        onPressed: () {
          itemNameFilterController.clear();

          inventoryDataSource = EmployeeDataSource(
              inventoryData: inventoryDataLst,
              selectedStoreDocId: selectedStoreDocId);
          setState(() {});
        },
        icon: Icon(
            itemNameFilterController.text.isEmpty
                ? CupertinoIcons.search
                : Icons.clear,
            size: 18,
            color: itemNameFilterController.text.isEmpty
                ? Colors.grey[600]
                : Colors.black),
        controller: itemNameFilterController,
        hintText: 'Item Name',
        onChanged: (val) {
          searchByItemName(val);
        },
      ),
      Container(
        width: 230,
        height: 30,
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

                inventoryDataSource = EmployeeDataSource(
                    inventoryData: inventoryDataLst,
                    selectedStoreDocId: selectedStoreDocId);
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
                    contentPadding: const EdgeInsets.only(bottom: 16, right: 5),
                    border: InputBorder.none,
                  ),
                ),
                suggestionsCallback: (pattern) {
                  return allVendorDataLst
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
      Container(
        width: 230,
        height: 30,
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
                _departmenttypeAheadController.clear();

                inventoryDataSource = EmployeeDataSource(
                    inventoryData: inventoryDataLst,
                    selectedStoreDocId: selectedStoreDocId);
                setState(() {});
              },
              splashRadius: 1,
              icon: Icon(
                  _departmenttypeAheadController.text.isEmpty
                      ? CupertinoIcons.search
                      : Icons.clear,
                  size: 18,
                  color: _departmenttypeAheadController.text.isEmpty
                      ? Colors.grey[600]
                      : Colors.black),
            ),
            Flexible(
              child: TypeAheadFormField(
                getImmediateSuggestions: false,
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _departmenttypeAheadController,
                  decoration: InputDecoration(
                    hintText: staticTextTranslate('Department'),
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    contentPadding: const EdgeInsets.only(bottom: 16, right: 5),
                    border: InputBorder.none,
                  ),
                ),
                suggestionsCallback: (pattern) {
                  return allDepartmentDataLst
                      .where((e) => e.departmentName
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
                itemBuilder: (context, DepartmentData suggestion) {
                  return ListTile(
                    title: Text(suggestion.departmentName,
                        style: TextStyle(
                          fontSize: getMediumFontSize,
                        )),
                  );
                },
                transitionBuilder: (context, suggestionsBox, controller) {
                  return suggestionsBox;
                },
                onSuggestionSelected: (DepartmentData suggestion) {
                  _departmenttypeAheadController.text =
                      suggestion.departmentName;
                  setState(() {
                    searchByDepartment(suggestion.departmentId);
                  });
                },
              ),
            ),
          ],
        ),
      ),
      Container(
          width: 230,
          height: 30,
          decoration: BoxDecoration(
              border: Border.all(width: 0.5, color: Colors.grey),
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.only(right: 10, bottom: 3),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  padding: const EdgeInsets.only(top: 2),
                  onPressed: () {},
                  splashRadius: 1,
                  icon: Icon(Icons.filter_alt_outlined,
                      size: 18, color: Colors.grey[600]),
                ),
                Flexible(
                    child: Container(
                        width: 200,
                        height: 30,
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.only(right: 10, left: 10),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedStoreDocId,
                          underline: const SizedBox(),
                          hint: Text(
                            staticTextTranslate('Stores'),
                            style: TextStyle(
                              fontSize: getMediumFontSize + 2,
                            ),
                          ),
                          items: <String>['All'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    staticTextTranslate(value),
                                    style: TextStyle(
                                      fontSize: getMediumFontSize + 2,
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
                                      fontSize: getMediumFontSize + 2,
                                    ),
                                  ),
                                );
                              }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              selectedStoreDocId = val;
                              inventoryDataSource = EmployeeDataSource(
                                  inventoryData: inventoryDataLst,
                                  selectedStoreDocId: val);
                              setState(() {});
                            }
                          },
                        ))),
              ]))
    ]);

    //     ],
    //   ),
    // );
  }

  showImportQuantityDialog() {
    File? importItem;
    Map<String, dynamic> uploadRes = {};
    bool dialogLoading = false;
    showDialog(
        // barrierDismissible: false,
        context: context,
        builder: (context) => StatefulBuilder(builder: (context, setState2) {
              return Dialog(
                backgroundColor: homeBgColor,
                child: SizedBox(
                    height: 360,
                    width: 500,
                    child: dialogLoading
                        ? showLoading()
                        : Column(children: [
                            Expanded(
                              child: SizedBox(
                                width: 500,
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15.0, horizontal: 15),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                staticTextTranslate(
                                                    'Update Quantity'),
                                                style: TextStyle(
                                                  fontSize:
                                                      getMediumFontSize + 5,
                                                )),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            Text(
                                                staticTextTranslate(
                                                    'To update inventory Quantity manually you need to upload excel file with barcode and Quantity as sample file.'),
                                                style: TextStyle(
                                                  fontSize:
                                                      getMediumFontSize - 1,
                                                )),
                                            Row(
                                              children: [
                                                Text(
                                                    staticTextTranslate(
                                                        'Download Sample file here.'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize - 1,
                                                    )),
                                                TextButton(
                                                  onPressed: () async {
                                                    setState(() {
                                                      dialogLoading = true;
                                                    });
                                                    setState2(() {});
                                                    // Create a new Excel document.
                                                    final Workbook workbook =
                                                        Workbook();

                                                    final Worksheet sheet =
                                                        workbook.worksheets[0];

                                                    sheet
                                                        .getRangeByName('A1')
                                                        .setText('barcode');
                                                    sheet
                                                        .getRangeByName('B1')
                                                        .setText('quantity');

                                                    final List<int> bytes =
                                                        workbook.saveAsStream();

                                                    workbook.dispose();
                                                    await saveAndLaunchFile(
                                                        bytes,
                                                        fileExtension: 'xlsx',
                                                        context);
                                                    setState(() {
                                                      dialogLoading = false;
                                                    });
                                                    setState2(() {});
                                                  },
                                                  child: Text(
                                                      staticTextTranslate(
                                                          'Download Now.'),
                                                      style: TextStyle(
                                                        fontSize:
                                                            getMediumFontSize,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      )),
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                    staticTextTranslate('File'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize,
                                                    )),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(3),
                                                        border: Border.all(
                                                            color:
                                                                Colors.grey)),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                    child: Text(
                                                        importItem != null
                                                            ? importItem!.path
                                                            : staticTextTranslate(
                                                                'No path found'),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
                                                        )),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                GestureDetector(
                                                  onTap: () async {
                                                    setState(() {
                                                      dialogLoading = true;
                                                    });
                                                    setState2(() {});
                                                    FilePickerResult? result =
                                                        await FilePicker
                                                            .platform
                                                            .pickFiles(
                                                                allowMultiple:
                                                                    false,
                                                                dialogTitle:
                                                                    'Import Items',
                                                                allowedExtensions: [
                                                                  'xlsx'
                                                                ],
                                                                type: FileType
                                                                    .custom);
                                                    if (result != null &&
                                                        result
                                                            .paths.isNotEmpty) {
                                                      importItem = File(
                                                          result.paths.first!);
                                                      var bytes = File(result
                                                              .files
                                                              .first
                                                              .path!)
                                                          .readAsBytesSync();
                                                      var excel =
                                                          Excel.decodeBytes(
                                                              bytes);

                                                      // uploadRes =
                                                      uploadRes =
                                                          inventoryUpdateQuantityFromExcel(
                                                              excel,
                                                              inventoryDataLst);
                                                      // print(uploadRes);
                                                    }
                                                    setState(() {
                                                      dialogLoading = false;
                                                    });
                                                    setState2(() {});
                                                  },
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(3),
                                                          border: Border.all(
                                                              color:
                                                                  Colors.grey)),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 5),
                                                      child: const Icon(
                                                          Iconsax.folder_open,
                                                          size: 19)),
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 25,
                                            ),
                                            Text(
                                                uploadRes.isEmpty
                                                    ? staticTextTranslate(
                                                        'Items Found : 0')
                                                    : '${staticTextTranslate('Items Found')} : ${uploadRes['itemsFound']}',
                                                style: TextStyle(
                                                  fontSize: getMediumFontSize,
                                                )),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                                uploadRes.isEmpty
                                                    ? staticTextTranslate(
                                                        'Items Not Found : 0')
                                                    : '${staticTextTranslate('Items Not Found')} : ${uploadRes['itemsNotFound']}',
                                                style: TextStyle(
                                                  fontSize: getMediumFontSize,
                                                )),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                          ]),
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4))),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.cancel_outlined,
                                                  color: Colors.black,
                                                  size: 20),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                  staticTextTranslate('Cancel'),
                                                  style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize,
                                                      color: Colors.black)),
                                            ],
                                          )),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    SizedBox(
                                      height: 42,
                                      width: 173,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: uploadRes
                                                          .isEmpty ||
                                                      uploadRes['itemsFound'] ==
                                                          0
                                                  ? Colors.grey
                                                  : darkBlueColor,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4))),
                                          onPressed: () async {
                                            if (uploadRes.isNotEmpty) {
                                              setState(() {
                                                dialogLoading = true;
                                              });
                                              setState2(() {});

                                              for (int i = 0;
                                                  i <
                                                      uploadRes[
                                                              'udpatedQuantityData']
                                                          .length;
                                                  i++) {
                                                int index = inventoryDataLst
                                                    .indexWhere((element) =>
                                                        element.docId ==
                                                        uploadRes[
                                                                'udpatedQuantityData']
                                                            .keys
                                                            .elementAt(i));

                                                if (index != -1) {
                                                  InventoryData invRes =
                                                      inventoryDataLst
                                                          .elementAt(index);
                                                  StoreData storeData =
                                                      await HiveStoreDbService()
                                                          .getSelectedStoreData();

                                                  invRes.ohQtyForDifferentStores[
                                                      storeData.docId] = uploadRes[
                                                          'udpatedQuantityData']
                                                      [invRes.docId];

                                                  await FbInventoryDbService(
                                                          context: context)
                                                      .addUpdateInventoryData(
                                                          inventoryDataLst: [
                                                        invRes
                                                      ]);
                                                }
                                              }
                                            }

                                            await hiveFetchData();
                                            loading = false;
                                            setState(() {});
                                            setState2(() {});
                                            Navigator.pop(context);
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(Iconsax.bill),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                  uploadRes['itemsNotFound'] ==
                                                              null ||
                                                          uploadRes[
                                                                  'itemsNotFound'] ==
                                                              0
                                                      ? staticTextTranslate(
                                                          'Update')
                                                      : staticTextTranslate(
                                                          'Skip & Update'),
                                                  style: TextStyle(
                                                    fontSize: getMediumFontSize,
                                                  )),
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

  showImportDialog() {
    File? importItem;
    Map<String, dynamic> uploadRes = {};
    bool dialogLoading = false;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => StatefulBuilder(builder: (context, setState2) {
              return Dialog(
                backgroundColor: homeBgColor,
                child: SizedBox(
                    height: 370,
                    width: 500,
                    child: dialogLoading
                        ? showLoading()
                        : Column(children: [
                            Expanded(
                              child: SizedBox(
                                width: 500,
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 10),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                staticTextTranslate(
                                                    'Product Import'),
                                                style: TextStyle(
                                                  fontSize:
                                                      getMediumFontSize + 5,
                                                )),
                                            Row(
                                              children: [
                                                Text(
                                                    staticTextTranslate(
                                                        'Download Sample file here.'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize - 1,
                                                    )),
                                                TextButton(
                                                  onPressed: () async {
                                                    setState(() {
                                                      dialogLoading = true;
                                                    });
                                                    setState2(() {});
                                                    // Create a new Excel document.
                                                    final Workbook workbook =
                                                        Workbook();

                                                    final Worksheet sheet =
                                                        workbook.worksheets[0];

                                                    sheet
                                                        .getRangeByName('A1')
                                                        .setText('productname');
                                                    sheet
                                                        .getRangeByName('B1')
                                                        .setText('cost');
                                                    sheet
                                                        .getRangeByName('C1')
                                                        .setText('price');
                                                    sheet
                                                        .getRangeByName('D1')
                                                        .setText('pricewt');
                                                    sheet
                                                        .getRangeByName('E1')
                                                        .setText('margin');
                                                    sheet
                                                        .getRangeByName('F1')
                                                        .setText('description');
                                                    sheet
                                                        .getRangeByName('G1')
                                                        .setText(
                                                            'productimgurl');
                                                    sheet
                                                        .getRangeByName('H1')
                                                        .setText('vendorid');
                                                    sheet
                                                        .getRangeByName('I1')
                                                        .setText(
                                                            'departmentid');

                                                    final List<int> bytes =
                                                        workbook.saveAsStream();

                                                    workbook.dispose();
                                                    await saveAndLaunchFile(
                                                        bytes,
                                                        fileExtension: 'xlsx',
                                                        context);
                                                    setState(() {
                                                      dialogLoading = false;
                                                    });
                                                    setState2(() {});
                                                  },
                                                  child: Text(
                                                      staticTextTranslate(
                                                          'Download Now.'),
                                                      style: TextStyle(
                                                        fontSize:
                                                            getMediumFontSize,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      )),
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                    staticTextTranslate('File'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize,
                                                    )),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(3),
                                                        border: Border.all(
                                                            color:
                                                                Colors.grey)),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                    child: Text(
                                                        importItem != null
                                                            ? importItem!.path
                                                            : staticTextTranslate(
                                                                'No path found'),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
                                                        )),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                GestureDetector(
                                                  onTap: () async {
                                                    setState(() {
                                                      dialogLoading = true;
                                                    });
                                                    setState2(() {});
                                                    FilePickerResult? result =
                                                        await FilePicker
                                                            .platform
                                                            .pickFiles(
                                                                allowMultiple:
                                                                    false,
                                                                dialogTitle:
                                                                    'Import Items',
                                                                allowedExtensions: [
                                                                  'xlsx'
                                                                ],
                                                                type: FileType
                                                                    .custom);
                                                    if (result != null &&
                                                        result
                                                            .paths.isNotEmpty) {
                                                      importItem = File(
                                                          result.paths.first!);
                                                      var bytes = File(result
                                                              .files
                                                              .first
                                                              .path!)
                                                          .readAsBytesSync();
                                                      var excel =
                                                          Excel.decodeBytes(
                                                              bytes);

                                                      uploadRes =
                                                          inventoryDataFromExcel(
                                                              excel,
                                                              widget.userData
                                                                  .createdBy,
                                                              inventoryDataLst,
                                                              allVendorDataLst,
                                                              allDepartmentDataLst);
                                                      print(uploadRes);
                                                    }
                                                    setState(() {
                                                      dialogLoading = false;
                                                    });
                                                    setState2(() {});
                                                  },
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(3),
                                                          border: Border.all(
                                                              color:
                                                                  Colors.grey)),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 5),
                                                      child: const Icon(
                                                          Iconsax.folder_open,
                                                          size: 19)),
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 25,
                                            ),
                                            Text(
                                                uploadRes.isEmpty
                                                    ? staticTextTranslate(
                                                        'Items Found : 0')
                                                    : '${staticTextTranslate('Items Found')} : ${uploadRes['inventoryDataLst'].length}',
                                                style: TextStyle(
                                                  fontSize: getMediumFontSize,
                                                )),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  uploadRes.isNotEmpty
                                                      ? '${uploadRes['wrongVendorIdOrDepartmentId']} Wrong Vendor Id or Department Id Found.'
                                                      : staticTextTranslate(
                                                          '0 Wrong Vendor Id or Department Id Found.'),
                                                  style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize - 1,
                                                      color: Colors.red[700]),
                                                ),
                                              ],
                                            ),
                                          ]),
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4))),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.cancel_outlined,
                                                  color: Colors.black,
                                                  size: 20),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                  staticTextTranslate('Cancel'),
                                                  style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize,
                                                      color: Colors.black)),
                                            ],
                                          )),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    SizedBox(
                                      height: 42,
                                      width: 173,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: uploadRes
                                                          .isEmpty ||
                                                      uploadRes['inventoryDataLst']
                                                              .length ==
                                                          0
                                                  ? Colors.grey
                                                  : darkBlueColor,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4))),
                                          onPressed: () async {
                                            if (uploadRes.isNotEmpty &&
                                                uploadRes['inventoryDataLst']
                                                        .length !=
                                                    0) {
                                              setState(() {
                                                dialogLoading = true;
                                              });
                                              setState2(() {});
                                              print(
                                                  uploadRes['inventoryDataLst']
                                                      .length);
                                              for (int i = 0;
                                                  i <
                                                      uploadRes[
                                                              'inventoryDataLst']
                                                          .length;
                                                  i++) {
                                                String itemCode =
                                                    await getIdNumber(
                                                        inventoryDataLst
                                                                .length +
                                                            1 +
                                                            i);
                                                await FbInventoryDbService(
                                                        context: context)
                                                    .addUpdateInventoryData(
                                                        inventoryDataLst: [
                                                      InventoryData(
                                                          docId: getRandomString(
                                                              20),
                                                          ohQtyForDifferentStores: {},
                                                          productPriceCanChange:
                                                              false,
                                                          proImgUrl: '',
                                                          itemCode: itemCode,
                                                          selectedVendorId:
                                                              uploadRes['inventoryDataLst'][i]
                                                                  .selectedVendorId,
                                                          productName:
                                                              uploadRes['inventoryDataLst'][i]
                                                                  .productName,
                                                          selectedDepartmentId:
                                                              uploadRes['inventoryDataLst'][i]
                                                                  .selectedDepartmentId,
                                                          cost: uploadRes['inventoryDataLst'][i]
                                                              .cost,
                                                          description:
                                                              uploadRes['inventoryDataLst'][i]
                                                                  .description,
                                                          price: uploadRes['inventoryDataLst'][i]
                                                              .price,
                                                          margin: uploadRes['inventoryDataLst'][i]
                                                              .margin,
                                                          priceWT:
                                                              uploadRes['inventoryDataLst'][i]
                                                                  .priceWT,
                                                          createdDate: uploadRes['inventoryDataLst'][i].createdDate,
                                                          createdBy: uploadRes['inventoryDataLst'][i].createdBy,
                                                          barcode: uploadRes['inventoryDataLst'][i].barcode,
                                                          productImg: uploadRes['inventoryDataLst'][i].productImg)
                                                    ]);
                                              }

                                              await hiveFetchData();
                                              loading = false;
                                              setState(() {});
                                              setState2(() {});
                                              Navigator.pop(context);
                                            }
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(Iconsax.import4),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                  staticTextTranslate('Import'),
                                                  style: TextStyle(
                                                    fontSize: getMediumFontSize,
                                                  )),
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
}

/// An object to set the employee collection data source to the datagrid. This
/// is used to map the employee data to the datagrid widget.
class EmployeeDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  EmployeeDataSource(
      {required List<InventoryData> inventoryData,
      required String selectedStoreDocId}) {
    inventoryData.sort((a, b) => b.createdDate.compareTo(a.createdDate));
    _employeeData = inventoryData.map<DataGridRow>((e) {
      int companyOH = 0;
      int storeOh = int.parse(
          (e.ohQtyForDifferentStores[selectedStoreDocId] ?? 0).toString());
      for (var o in e.ohQtyForDifferentStores.values) {
        companyOH += int.tryParse(o.toString()) ?? 0;
      }

      return DataGridRow(cells: [
        DataGridCell<int>(
            columnName: 'serialNumberForStyleColor',
            value: inventoryData.indexOf(e) + 1),
        DataGridCell<String>(columnName: 'barcode', value: e.barcode),
        DataGridCell<String>(columnName: 'itemCode', value: e.itemCode),
        DataGridCell<String>(columnName: 'productName', value: e.productName),
        DataGridCell<String>(columnName: 'storeOH', value: storeOh.toString()),
        DataGridCell<String>(
            columnName: 'companyOH', value: companyOH.toString()),
        DataGridCell<String>(columnName: 'cost', value: e.cost),
        DataGridCell<String>(columnName: 'price', value: e.price),
        DataGridCell<String>(columnName: 'priceWT', value: e.priceWT),
        DataGridCell<String>(
            columnName: 'extCost',
            value: (storeOh * double.parse(e.cost)).toString()),
        DataGridCell<String>(
            columnName: 'extPriceWt',
            value: (storeOh * (double.tryParse(e.priceWT) ?? 0)).toString()),
      ]);
    }).toList();
  }

  List<DataGridRow> _employeeData = [];

  @override
  List<DataGridRow> get rows => _employeeData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        color: row.getCells()[0].value.isEven
            ? const Color.fromARGB(255, 246, 247, 255)
            : Colors.white,
        cells: row.getCells().map<Widget>((e) {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(1.0),
            child: Text(
              e.value.toString(),
              style: TextStyle(
                  fontSize: getMediumFontSize,
                  color: Colors.black,
                  fontWeight: FontWeight.w400),
            ),
          );
        }).toList());
  }
}
