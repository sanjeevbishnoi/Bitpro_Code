import 'dart:io';
import 'dart:math';
import 'package:bitpro_hive/home/sales/customer/sideMenuButton.dart';
import 'package:bitpro_hive/model/store_data.dart';
import 'package:bitpro_hive/services/firestore_api/fb_merchandise/fb_inventory_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_settings/fb_store_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_vouchers/fb_voucher_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_merchandise_db_service/inventory_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_settings/hive_store_db_service.dart';
import 'package:bitpro_hive/widget/string_related/get_id_number.dart';
import 'package:bitpro_hive/widget/top_bar.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:bitpro_hive/home/sales/receipt/selectInventoryItemPage.dart';
import 'package:bitpro_hive/model/voucher/db_voucher_data.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bitpro_hive/model/inventory_data.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:bitpro_hive/shared/loading.dart';
import 'package:syncfusion_flutter_datagrid_export/export.dart';
import '../../../model/vendor_data.dart';
import '../../../model/voucher/local_voucher_data.dart';
import '../../../services/hive/import_data_exel/local_voucher_data_excel.dart';
import '../../../shared/custom_top_nav_bar.dart';
import '../../../shared/dialogs/discard_changes_dialog.dart';
import '../../../shared/global_variables/font_sizes.dart';
import '../../../shared/templates/tag/print_tag.dart';
import '../../../shared/templates/voucher_templates/print_voucher.dart';
import '../../../shared/save_file_and_launch.dart';
import '../../../shared/global_variables/static_text_translate.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

class CreateEditVoucherPage extends StatefulWidget {
  final UserData userData;
  final List<VendorData> vendorDataLst;
  final bool viewMode;
  final DbVoucherData? selectedDbVoucherData;
  final String newVoucherId;
  const CreateEditVoucherPage({
    Key? key,
    required this.userData,
    required this.vendorDataLst,
    this.viewMode = false,
    this.selectedDbVoucherData,
    required this.newVoucherId,
  }) : super(key: key);

  @override
  State<CreateEditVoucherPage> createState() => _CreateEditVoucherPageState();
}

class _CreateEditVoucherPageState extends State<CreateEditVoucherPage> {
  late String currentVoucherNumber;
  String tax = '0';
  String discountPercent = '0';
  String discountValue = '0';
  VendorData? selectedVendor;
  String purchaseInvoice = '';
  DateTime? purchaseInvoiceDate;
  String purchaseInvoiceTotal = '';
  String note = '';
  String createdBy = '';
  bool viewMode = false;
  DbVoucherData? selectedDbVoucherData;
  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();

  var formKey = GlobalKey<FormState>();
  bool loading = true;
  bool uploading = false;
  final TextEditingController _vendorTypeAheadController =
      TextEditingController();
  final TextEditingController _f1VendorTypeAheadController =
      TextEditingController();
  final TextEditingController _f2VendorTypeAheadController =
      TextEditingController();
  File? productImage;

  final TextEditingController barcodeFilterController = TextEditingController();
  final TextEditingController vendorInvoiceFilterController =
      TextEditingController();
  VoucherDataSource? voucherDataSource;
  DataGridController dataGridController = DataGridController();
  bool showDateError = false;

  List<dynamic> localVoucherData = [];
  ScrollController scrollController = ScrollController();

  TextEditingController discountPerTextEditingController =
      TextEditingController();

  TextEditingController discountValueTextEditingController =
      TextEditingController();
  DateTime? createdDate;

  FocusNode disPerFocusNode = FocusNode();

  FocusNode disValFocusNode = FocusNode();

  String regularReturnDropDown = 'Regular';

  List<InventoryData> allInventoryDataLst = [];

  List<StoreData> allStoresData = [];
  late StoreData selectedStoreData;

  List<VendorData> allVendorDataLst = [];

  late int selectedStoreCode;
  late int workstationNumber;
  @override
  void initState() {
    super.initState();

    createdBy = widget.userData.username;
    if (widget.viewMode) {
      createdDate = widget.selectedDbVoucherData!.createdDate;
      tax = widget.selectedDbVoucherData!.tax;
      discountPercent = widget.selectedDbVoucherData!.discountPercentage;
      discountValue = widget.selectedDbVoucherData!.discountValue;
      selectedVendor = widget.vendorDataLst.firstWhere((element) =>
          element.vendorId == widget.selectedDbVoucherData!.vendor);

      purchaseInvoice = widget.selectedDbVoucherData!.purchaseInvoice;
      purchaseInvoiceDate =
          DateTime.parse(widget.selectedDbVoucherData!.purchaseInvoiceDate);

      note = widget.selectedDbVoucherData!.note;
      createdBy = widget.selectedDbVoucherData!.createdBy;

      viewMode = widget.viewMode;
      selectedDbVoucherData = widget.selectedDbVoucherData;
      regularReturnDropDown = widget.selectedDbVoucherData!.voucherType;
      currentVoucherNumber = widget.selectedDbVoucherData!.voucherNo;
    } else {
      currentVoucherNumber = widget.newVoucherId;
    }
    localVoucherData = [];
    allVendorDataLst = widget.vendorDataLst;
    voucherDataSource = VoucherDataSource(localVoucherData, context);
    Box box = Hive.box('bitpro_app');
    box.delete('voucher_data');

    box.put('voucher_data', []);

    discountPerTextEditingController =
        TextEditingController(text: discountPercent);

    discountValueTextEditingController =
        TextEditingController(text: discountValue);

    hiveGetStoreInfo();
    storeInit();
  }

  storeInit() async {
    selectedStoreCode = await HiveStoreDbService().getSelectedStoreCode();
    workstationNumber = await HiveStoreDbService().getWorkstationNumber();
  }

  fbGetStoreInfo() async {
    //updating store data
    allStoresData =
        await FbStoreDbService(context: context).fetchAllStoresData();
    allInventoryDataLst =
        await FbInventoryDbService(context: context).fetchAllInventoryData();
    //
    if (widget.viewMode) {
      int index = allStoresData.indexWhere((element) =>
          element.docId == widget.selectedDbVoucherData!.selectedStoreDocId);
      if (index != -1) {
        selectedStoreData = allStoresData.elementAt(index);
      }
    } else {
      //getting default selected store
      int selectedStoreCode = await HiveStoreDbService().getSelectedStoreCode();
      int index = allStoresData.indexWhere(
          (element) => element.storeCode == selectedStoreCode.toString());

      if (index != -1) {
        selectedStoreData = allStoresData.elementAt(index);
      } else {
        selectedStoreData = allStoresData.first;
      }
    }

    setState(() {
      loading = false;
    });
  }

  hiveGetStoreInfo() async {
    //updating store data
    allStoresData = await HiveStoreDbService().fetchAllStoresData();
    allInventoryDataLst =
        await HiveInventoryDbService().fetchAllInventoryData();
    //
    if (widget.viewMode) {
      int index = allStoresData.indexWhere((element) =>
          element.docId == widget.selectedDbVoucherData!.selectedStoreDocId);
      if (index != -1) {
        selectedStoreData = allStoresData.elementAt(index);
      }
    } else {
      //getting default selected store
      int selectedStoreCode = await HiveStoreDbService().getSelectedStoreCode();
      int index = allStoresData.indexWhere(
          (element) => element.storeCode == selectedStoreCode.toString());

      if (index != -1) {
        selectedStoreData = allStoresData.elementAt(index);
      } else {
        selectedStoreData = allStoresData.first;
      }
    }

    setState(() {
      loading = false;
    });
  }

  String randomBarcodeGenerate() {
    String barcode = '1';
    for (int i = 0; i < 6; i++) {
      var n = Random().nextInt(9);
      barcode += n.toString();
    }
    return barcode;
  }

  searchByVoucher(String txt) {
    List<dynamic> filteredInventoryDataLst = [];
    if (txt.isEmpty) {
      voucherDataSource = VoucherDataSource(localVoucherData, context);
      setState(() {});
      return;
    }

    for (var i in localVoucherData) {
      if (i.barcode.toLowerCase().contains(txt.toLowerCase()) ||
          i.itemCode.toLowerCase().contains(txt.toLowerCase())) {
        filteredInventoryDataLst.add(i);
      }
    }

    voucherDataSource = VoucherDataSource(filteredInventoryDataLst, context);

    setState(() {});
  }

  searchByVendroInvoice(String txt) {
    List<dynamic> filteredInventoryDataLst = [];
    if (txt.isEmpty) {
      voucherDataSource = VoucherDataSource(localVoucherData, context);
      setState(() {});
      return;
    }

    for (var i in localVoucherData) {
      if (i.productName.toLowerCase().contains(txt.toLowerCase())) {
        filteredInventoryDataLst.add(i);
      }
    }

    voucherDataSource = VoucherDataSource(filteredInventoryDataLst, context);
    setState(() {});
  }

  getLocalVoucherDataFromBarcode() {
    for (var b in selectedDbVoucherData!.selectedItems) {
      InventoryData inv = allInventoryDataLst.firstWhere(
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
        localVoucherData.add(LocalVoucherData(
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

    voucherDataSource = VoucherDataSource(localVoucherData, context);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
        valueListenable: Hive.box('bitpro_app').listenable(),
        builder: (context, box, widget) {
          if (!viewMode) {
            var vd = box.get('voucher_data');

            localVoucherData = vd
                .map((e) => LocalVoucherData.fromMap(e))
                .toList() as List<dynamic>;
          }

          if (viewMode &&
              selectedDbVoucherData != null &&
              localVoucherData.isEmpty) {
            getLocalVoucherDataFromBarcode();
            purchaseInvoiceTotal = calculateVoucherTotal();
          }

          return customTopNavBar(
            Scaffold(
              backgroundColor: homeBgColor,
              body: uploading
                  ? Center(
                      child: showLoading(),
                    )
                  : SafeArea(
                      child: Container(
                        child: Column(
                          children: [
                            TopBar(pageName: 'Voucher'),
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    color:
                                        const Color.fromARGB(255, 43, 43, 43),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SideMenuButton(
                                          label: 'Back',
                                          iconPath: 'assets/icons/back.png',
                                          buttonFunction: () {
                                            showDiscardChangesDialog(context);
                                          },
                                        ),
                                        if (viewMode == false)
                                          SideMenuButton(
                                            label: 'Remove item',
                                            iconPath: 'assets/icons/remove.png',
                                            buttonFunction: () {
                                              if (dataGridController
                                                  .selectedRows.isNotEmpty) {
                                                for (var r in dataGridController
                                                    .selectedRows) {
                                                  String b = r
                                                      .getCells()
                                                      .firstWhere((e) =>
                                                          e.columnName ==
                                                          'barcode')
                                                      .value;
                                                  int index = localVoucherData
                                                      .indexWhere((e) =>
                                                          e.barcode == b);
                                                  if (index != -1)
                                                    localVoucherData
                                                        .removeAt(index);
                                                }
                                                dataGridController
                                                    .selectedRows = [];
                                                var box =
                                                    Hive.box('bitpro_app');

                                                box.put(
                                                    'voucher_data',
                                                    localVoucherData
                                                        .map((e) => e.toMap())
                                                        .toList());
                                                voucherDataSource =
                                                    VoucherDataSource(
                                                        localVoucherData,
                                                        context);
                                                setState(() {});
                                              }
                                            },
                                          ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        SideMenuButton(
                                          label: 'Export',
                                          iconPath: 'assets/icons/export.png',
                                          buttonFunction: () async {
                                            if (localVoucherData.isNotEmpty) {
                                              setState(() {
                                                loading = true;
                                              });
                                              final Workbook workbook = _key
                                                  .currentState!
                                                  .exportToExcelWorkbook();
                                              final List<int> bytes =
                                                  workbook.saveAsStream();
                                              workbook.dispose();
                                              await saveAndLaunchFile(
                                                  bytes,
                                                  fileExtension: 'xlsx',
                                                  context);
                                              setState(() {
                                                loading = false;
                                              });
                                            }
                                          },
                                        ),
                                        if (viewMode == false)
                                          SideMenuButton(
                                            label: 'Import items',
                                            iconPath: 'assets/icons/import.png',
                                            buttonFunction: () {
                                              showImportDialog();
                                            },
                                          ),
                                        if (viewMode)
                                          SideMenuButton(
                                            label: 'Print',
                                            iconPath: 'assets/icons/print.png',
                                            buttonFunction: () async {
                                              if (localVoucherData.isNotEmpty) {
                                                setState(() {
                                                  loading = true;
                                                });
                                                // List<DbVoucherData> dbVoucherDataLst =
                                                //     [];

                                                // String voucherNo = viewMode
                                                //     ? selectedDbVoucherData!.voucherNo
                                                //     : widget.;
                                                // dbVoucherDataLst =
                                                //     await FbVoucherDbService(
                                                //             context: context)
                                                //         .fetchAllVoucherData();
                                                // dbVoucherDataLst.sort((a, b) => a
                                                //     .createdDate
                                                //     .compareTo(b.createdDate));

                                                // if (viewMode) {
                                                //   voucherNo ==
                                                //       selectedDbVoucherData!
                                                //           .voucherNo;
                                                // } else if (dbVoucherDataLst
                                                //     .isNotEmpty) {
                                                //   int v = int.parse(dbVoucherDataLst
                                                //           .last.voucherNo) +
                                                //       1;

                                                //   voucherNo = v.toString();
                                                // }

                                                DbVoucherData dbVoucherData =
                                                    DbVoucherData(
                                                        voucherType:
                                                            regularReturnDropDown,
                                                        docId:
                                                            getRandomString(20),
                                                        createdDate:
                                                            DateTime.now(),
                                                        selectedItems:
                                                            localVoucherData
                                                                .map((e) => {
                                                                      'barcode':
                                                                          e.barcode,
                                                                      'qty':
                                                                          e.qty,
                                                                      'cost': e
                                                                          .cost,
                                                                      'price': e
                                                                          .price,
                                                                      'priceWt':
                                                                          e.priceWt
                                                                    })
                                                                .toList(),
                                                        discountPercentage:
                                                            discountPercent,
                                                        discountValue:
                                                            discountValue,
                                                        note: note,
                                                        purchaseInvoiceDate:
                                                            purchaseInvoiceDate
                                                                .toString(),
                                                        tax: tax,
                                                        selectedStoreDocId:
                                                            selectedStoreData
                                                                .docId,
                                                        createdBy: createdBy,
                                                        qtyRecieved:
                                                            calculateTotalQty(),
                                                        vendor: selectedVendor!
                                                            .vendorId,
                                                        purchaseInvoice:
                                                            purchaseInvoice,
                                                        voucherNo:
                                                            currentVoucherNumber,
                                                        voucherTotal:
                                                            calculateVoucherTotal());
                                                printVoucher(
                                                    context,
                                                    dbVoucherData,
                                                    calculateVoucherPriceWt(),
                                                    selectedVendor!,
                                                    localVoucherData);
                                                setState(() {
                                                  loading = false;
                                                });
                                              }
                                            },
                                          ),
                                        SideMenuButton(
                                          label: 'Print Tag',
                                          iconPath: 'assets/icons/tag.png',
                                          buttonFunction: () {
                                            if (dataGridController
                                                    .selectedRow !=
                                                null) {
                                              String selectedRowBarcodeValue =
                                                  '';

                                              for (var c in dataGridController
                                                  .selectedRow!
                                                  .getCells()) {
                                                if (c.columnName == 'barcode') {
                                                  selectedRowBarcodeValue =
                                                      c.value;
                                                }
                                              }

                                              List<PrintTagData>
                                                  allPrintTagDataLst =
                                                  localVoucherData.map((e) {
                                                int ohQty = -1;
                                                String priceWT = '';
                                                for (InventoryData inv
                                                    in allInventoryDataLst) {
                                                  if (inv.barcode ==
                                                      e.barcode) {
                                                    ohQty = int.tryParse(
                                                            inv.ohQtyForDifferentStores[
                                                                selectedStoreData
                                                                    .docId]) ??
                                                        0;
                                                    priceWT = inv.priceWT;
                                                  }
                                                }
                                                return PrintTagData(
                                                    barcodeValue: e.barcode,
                                                    docQty:
                                                        int.tryParse(e.qty) ??
                                                            0,
                                                    itemCode: e.itemCode,
                                                    productName: e.productName,
                                                    onHandQty: ohQty,
                                                    priceWt: priceWT);
                                              }).toList();
                                              int i = allPrintTagDataLst
                                                  .indexWhere((element) =>
                                                      element.barcodeValue ==
                                                      selectedRowBarcodeValue);
                                              PrintTagData
                                                  selectedPrintTagData =
                                                  allPrintTagDataLst
                                                      .elementAt(i);
                                              buildTagPrint(
                                                  context: context,
                                                  allPrintTagDataLst:
                                                      allPrintTagDataLst,
                                                  selectedPrintTagData:
                                                      selectedPrintTagData);
                                            }
                                          },
                                        ),
                                        SideMenuButton(
                                          label: 'Refresh',
                                          iconPath: 'assets/icons/refresh.png',
                                          buttonFunction: () async {
                                            setState(() {
                                              loading = true;
                                            });

                                            await fbGetStoreInfo();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 0,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 0,
                                        ),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        1250
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width -
                                                        500
                                                    : 600,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height -
                                                    90,
                                                child: Card(
                                                    shape: RoundedRectangleBorder(
                                                        side: const BorderSide(
                                                            width: 0.5,
                                                            color: Colors.grey),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    elevation: 0,
                                                    color: Colors.white,
                                                    child: loading
                                                        ? showLoading()
                                                        : Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                width: double
                                                                    .infinity,
                                                                decoration: const BoxDecoration(
                                                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                                                                    gradient: LinearGradient(
                                                                        end: Alignment.bottomCenter,
                                                                        colors: [
                                                                          Color.fromARGB(
                                                                              255,
                                                                              180,
                                                                              180,
                                                                              180),
                                                                          Color.fromARGB(
                                                                              255,
                                                                              105,
                                                                              105,
                                                                              105),
                                                                        ],
                                                                        begin: Alignment.topCenter)),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          10.0,
                                                                      right:
                                                                          10),
                                                                  child: Wrap(
                                                                    children: [
                                                                      SizedBox(
                                                                          width:
                                                                              450,
                                                                          child:
                                                                              filters()),
                                                                      const SizedBox(
                                                                          width:
                                                                              10),
                                                                      SizedBox(
                                                                          width:
                                                                              340,
                                                                          child:
                                                                              regularReturnFilter()),
                                                                      storeFilterWidget()
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    SfDataGridTheme(
                                                                  data: SfDataGridThemeData(
                                                                      headerColor:
                                                                          const Color(
                                                                              0xffF1F1F1),
                                                                      headerHoverColor:
                                                                          const Color(
                                                                              0xffdddfe8),
                                                                      selectionColor:
                                                                          loginBgColor),
                                                                  child: Column(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              6.0),
                                                                          child:
                                                                              Container(
                                                                            decoration:
                                                                                BoxDecoration(border: Border.all(width: 0.3)),
                                                                            child:
                                                                                SfDataGrid(
                                                                              headerRowHeight: 25,
                                                                              rowHeight: 25,
                                                                              isScrollbarAlwaysShown: true,
                                                                              onQueryRowHeight: (details) {
                                                                                // Set the row height as 70.0 to the column header row.
                                                                                return details.rowIndex == 0 ? 25.0 : 25.0;
                                                                              },

                                                                              allowSorting: true,
                                                                              allowTriStateSorting: true,
                                                                              // showCheckboxColumn:
                                                                              //     true,
                                                                              verticalScrollController: scrollController,
                                                                              selectionMode: SelectionMode.single,
                                                                              navigationMode: GridNavigationMode.cell,
                                                                              allowEditing: !viewMode,
                                                                              key: _key,
                                                                              controller: dataGridController,
                                                                              headerGridLinesVisibility: GridLinesVisibility.both,
                                                                              source: voucherDataSource!,
                                                                              editingGestureType: EditingGestureType.tap,
                                                                              columnWidthMode: ColumnWidthMode.lastColumnFill,
                                                                              onSelectionChanging: (addedRows, removedRows) {
                                                                                setState(() {});
                                                                                return true;
                                                                              },
                                                                              onSelectionChanged: (addedRows, removedRows) {
                                                                                setState(() {});
                                                                              },
                                                                              columns: <GridColumn>[
                                                                                GridColumn(
                                                                                    columnName: 'serialNumberForStyleColor',
                                                                                    visible: false,
                                                                                    label: Container(
                                                                                        padding: const EdgeInsets.all(0.0),
                                                                                        alignment: Alignment.center,
                                                                                        child: Text(
                                                                                          'serialNumberForStyleColor',
                                                                                          style: TextStyle(
                                                                                            fontSize: getMediumFontSize,
                                                                                          ),
                                                                                        ))),
                                                                                GridColumn(
                                                                                    allowEditing: false,
                                                                                    columnName: 'barcode',
                                                                                    label: Container(
                                                                                        padding: const EdgeInsets.all(2.0),
                                                                                        alignment: Alignment.center,
                                                                                        child: Text(
                                                                                          staticTextTranslate('Barcode'),
                                                                                          style: GoogleFonts.roboto(
                                                                                            fontSize: getMediumFontSize + 1,
                                                                                          ),
                                                                                        ))),
                                                                                GridColumn(
                                                                                    allowEditing: false,
                                                                                    columnName: 'itemCode',
                                                                                    label: Container(
                                                                                        padding: const EdgeInsets.all(2.0),
                                                                                        alignment: Alignment.center,
                                                                                        child: Text(
                                                                                          staticTextTranslate('Item Code'),
                                                                                          style: GoogleFonts.roboto(
                                                                                            fontSize: getMediumFontSize + 1,
                                                                                          ),
                                                                                        ))),
                                                                                GridColumn(
                                                                                    allowEditing: false,
                                                                                    maximumWidth: 260,
                                                                                    columnName: 'productName',
                                                                                    label: Container(
                                                                                        padding: const EdgeInsets.all(2.0),
                                                                                        alignment: Alignment.center,
                                                                                        child: Text(
                                                                                          staticTextTranslate('Product Name'),
                                                                                          style: GoogleFonts.roboto(
                                                                                            fontSize: getMediumFontSize + 1,
                                                                                          ),
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                        ))),
                                                                                GridColumn(
                                                                                    allowEditing: true,
                                                                                    columnName: 'qty',
                                                                                    label: Container(
                                                                                        padding: const EdgeInsets.all(2.0),
                                                                                        alignment: Alignment.center,
                                                                                        child: Text(
                                                                                          staticTextTranslate('Qty'),
                                                                                          style: GoogleFonts.roboto(
                                                                                            fontSize: getMediumFontSize + 1,
                                                                                          ),
                                                                                        ))),
                                                                                GridColumn(
                                                                                    width: 100,
                                                                                    allowEditing: true,
                                                                                    columnName: 'cost',
                                                                                    label: Container(
                                                                                        padding: const EdgeInsets.all(2.0),
                                                                                        alignment: Alignment.center,
                                                                                        child: Text(
                                                                                          staticTextTranslate('Cost'),
                                                                                          style: GoogleFonts.roboto(
                                                                                            fontSize: getMediumFontSize + 1,
                                                                                          ),
                                                                                        ))),
                                                                                GridColumn(
                                                                                    width: 100,
                                                                                    allowEditing: true,
                                                                                    columnName: 'price',
                                                                                    label: Container(
                                                                                        padding: const EdgeInsets.all(2.0),
                                                                                        alignment: Alignment.center,
                                                                                        child: Text(
                                                                                          staticTextTranslate('Price'),
                                                                                          style: GoogleFonts.roboto(
                                                                                            fontSize: getMediumFontSize + 1,
                                                                                          ),
                                                                                        ))),
                                                                                GridColumn(
                                                                                    width: 100,
                                                                                    allowEditing: true,
                                                                                    columnName: 'priceWT',
                                                                                    label: Container(
                                                                                        padding: const EdgeInsets.all(2.0),
                                                                                        alignment: Alignment.center,
                                                                                        child: Text(
                                                                                          staticTextTranslate('Price W/T'),
                                                                                          style: GoogleFonts.roboto(
                                                                                            fontSize: getMediumFontSize + 1,
                                                                                          ),
                                                                                        ))),
                                                                                GridColumn(
                                                                                    width: 100,
                                                                                    allowEditing: false,
                                                                                    columnName: 'extCost',
                                                                                    label: Container(
                                                                                        padding: const EdgeInsets.all(2.0),
                                                                                        alignment: Alignment.center,
                                                                                        child: Text(
                                                                                          staticTextTranslate('Ext Cost'),
                                                                                          style: GoogleFonts.roboto(
                                                                                            fontSize: getMediumFontSize + 1,
                                                                                          ),
                                                                                        ))),
                                                                              ],
                                                                              gridLinesVisibility: GridLinesVisibility.both,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          )),
                                              ),
                                              SizedBox(
                                                width: 320,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height -
                                                    88,
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 5.0),
                                                        child: Container(
                                                          height: 35,
                                                          width:
                                                              double.maxFinite,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      15,
                                                                  vertical: 5),
                                                          decoration:
                                                              const BoxDecoration(
                                                            borderRadius: BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        4),
                                                                topRight: Radius
                                                                    .circular(
                                                                        4)),
                                                            gradient:
                                                                LinearGradient(
                                                                    end: Alignment
                                                                        .bottomCenter,
                                                                    colors: [
                                                                      Color.fromARGB(
                                                                          255,
                                                                          66,
                                                                          66,
                                                                          66),
                                                                      Color.fromARGB(
                                                                          255,
                                                                          0,
                                                                          0,
                                                                          0),
                                                                    ],
                                                                    begin: Alignment
                                                                        .topCenter),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                'Purchase Invoice Details',
                                                                style: GoogleFonts.roboto(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Colors
                                                                        .white),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 5),
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 5,
                                                                  horizontal:
                                                                      16),
                                                          decoration: BoxDecoration(
                                                              border:
                                                                  Border.all(
                                                                      width:
                                                                          0.3),
                                                              color: const Color(
                                                                  0xffE2E2E2),
                                                              borderRadius: BorderRadius.only(
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          3),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          3))),
                                                          child: Column(
                                                            children: [
                                                              SizedBox(
                                                                width: 300,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      staticTextTranslate(
                                                                          'Tax%'),
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        fontSize:
                                                                            getMediumFontSize +
                                                                                2,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          200,
                                                                      child:
                                                                          TextFormField(
                                                                        style: GoogleFonts.roboto(
                                                                            fontSize:
                                                                                17,
                                                                            height:
                                                                                1.4),
                                                                        enabled:
                                                                            !viewMode,
                                                                        validator:
                                                                            (val) {
                                                                          if (double.tryParse(val ?? '') ==
                                                                              null) {
                                                                            return staticTextTranslate('Enter a valid number');
                                                                          }
                                                                          return null;
                                                                        },
                                                                        initialValue:
                                                                            tax,
                                                                        autovalidateMode:
                                                                            AutovalidateMode.onUserInteraction,
                                                                        decoration: const InputDecoration(
                                                                            fillColor: Colors
                                                                                .white,
                                                                            filled:
                                                                                true,
                                                                            isDense:
                                                                                true,
                                                                            contentPadding:
                                                                                EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                                                            border: OutlineInputBorder(borderSide: BorderSide(width: 0.3, color: Colors.black))),
                                                                        onChanged:
                                                                            (val) {
                                                                          if (double.tryParse(val) !=
                                                                              null) {
                                                                            setState(() {
                                                                              tax = val;
                                                                            });
                                                                          }
                                                                        },
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              SizedBox(
                                                                width: 300,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      staticTextTranslate(
                                                                          'Discount%'),
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        fontSize:
                                                                            getMediumFontSize +
                                                                                2,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          200,
                                                                      child: TextFormField(
                                                                          focusNode: disPerFocusNode,
                                                                          controller: discountPerTextEditingController,
                                                                          validator: (value) {
                                                                            if (double.tryParse(value ?? '') ==
                                                                                null) {
                                                                              return staticTextTranslate('Enter a valid number');
                                                                            }
                                                                            return null;
                                                                          },
                                                                          enabled: !viewMode,
                                                                          style: GoogleFonts.roboto(fontSize: 17, height: 1.4),
                                                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                                                          decoration: const InputDecoration(
                                                                              fillColor: Colors.white,
                                                                              filled: true,
                                                                              isDense: true,
                                                                              contentPadding: EdgeInsets.symmetric(
                                                                                vertical: 10,
                                                                                horizontal: 10,
                                                                              ),
                                                                              border: OutlineInputBorder()),
                                                                          onChanged: (val) {
                                                                            if (double.tryParse(val) !=
                                                                                null) {
                                                                              discountPercent = val;
                                                                              calculateAndUpdatedDiscountValue(val);
                                                                              setState(() {});
                                                                            }
                                                                          }),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              SizedBox(
                                                                width: 300,
                                                                child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      staticTextTranslate(
                                                                          'Discount \$'),
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        fontSize:
                                                                            getMediumFontSize +
                                                                                2,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          35,
                                                                      width:
                                                                          200,
                                                                      child: TextFormField(
                                                                          focusNode: disValFocusNode,
                                                                          controller: discountValueTextEditingController,
                                                                          validator: (val) {
                                                                            if (double.tryParse(val ?? '') ==
                                                                                null) {
                                                                              return staticTextTranslate('Enter a valid number');
                                                                            }
                                                                            return null;
                                                                          },
                                                                          enabled: !viewMode,
                                                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                                                          style: GoogleFonts.roboto(fontSize: 17, height: 1.4),
                                                                          decoration: const InputDecoration(fillColor: Colors.white, filled: true, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10), border: OutlineInputBorder()),
                                                                          onChanged: (val) {
                                                                            if (double.tryParse(val) !=
                                                                                null) {
                                                                              discountValue = val;
                                                                              calculateAndUpdatedDiscountPercentage(val);
                                                                              setState(() {});
                                                                            }
                                                                          }),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              SizedBox(
                                                                width: 300,
                                                                child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      staticTextTranslate(
                                                                          'Vendor'),
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        fontSize:
                                                                            getMediumFontSize +
                                                                                2,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    if (viewMode)
                                                                      Container(
                                                                        width:
                                                                            200,
                                                                        decoration: BoxDecoration(
                                                                            border:
                                                                                Border.all(color: Colors.grey.shade400),
                                                                            borderRadius: BorderRadius.circular(4)),
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                10,
                                                                            vertical:
                                                                                7),
                                                                        child:
                                                                            Text(
                                                                          selectedVendor == null
                                                                              ? ''
                                                                              : selectedVendor!.vendorId,
                                                                          style:
                                                                              GoogleFonts.roboto(
                                                                            fontSize:
                                                                                getMediumFontSize + 2,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    if (!viewMode)
                                                                      SizedBox(
                                                                        width:
                                                                            200,
                                                                        child:
                                                                            TypeAheadFormField(
                                                                          enabled:
                                                                              !viewMode,
                                                                          getImmediateSuggestions:
                                                                              false,
                                                                          textFieldConfiguration:
                                                                              TextFieldConfiguration(
                                                                            style:
                                                                                GoogleFonts.roboto(fontSize: 17, height: 1.4),
                                                                            controller:
                                                                                _vendorTypeAheadController,
                                                                            decoration: InputDecoration(
                                                                                fillColor: Colors.white,
                                                                                filled: true,
                                                                                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                                                                isDense: true,
                                                                                hintStyle: TextStyle(color: Colors.grey[600], fontSize: getSmallFontSize),
                                                                                border: const OutlineInputBorder()),
                                                                          ),
                                                                          noItemsFoundBuilder:
                                                                              (context) {
                                                                            return Padding(
                                                                              padding: const EdgeInsets.all(10.0),
                                                                              child: Text(staticTextTranslate('No Items Found!'),
                                                                                  style: TextStyle(
                                                                                    fontSize: getMediumFontSize,
                                                                                  )),
                                                                            );
                                                                          },
                                                                          validator:
                                                                              (val) {
                                                                            if (val == null ||
                                                                                val.isEmpty ||
                                                                                allVendorDataLst.any((e) => e.vendorName.toLowerCase().contains(val.toLowerCase())) == false) {
                                                                              return staticTextTranslate('Select a vendor');
                                                                            }
                                                                          },
                                                                          suggestionsCallback:
                                                                              (pattern) {
                                                                            return allVendorDataLst.where((e) => e.vendorName.toLowerCase().contains(pattern.toLowerCase())).toList();
                                                                          },
                                                                          itemBuilder:
                                                                              (context, VendorData suggestion) {
                                                                            return ListTile(
                                                                              title: Text(suggestion.vendorName,
                                                                                  style: TextStyle(
                                                                                    fontSize: getMediumFontSize,
                                                                                  )),
                                                                            );
                                                                          },
                                                                          transitionBuilder: (context,
                                                                              suggestionsBox,
                                                                              controller) {
                                                                            return suggestionsBox;
                                                                          },
                                                                          onSuggestionSelected:
                                                                              (VendorData suggestion) {
                                                                            _vendorTypeAheadController.text =
                                                                                suggestion.vendorName;

                                                                            setState(() {
                                                                              selectedVendor = suggestion;
                                                                            });
                                                                          },
                                                                        ),
                                                                      ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              SizedBox(
                                                                width: 300,
                                                                child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      staticTextTranslate(
                                                                          'Invoice#'),
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        fontSize:
                                                                            getMediumFontSize +
                                                                                2,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          35,
                                                                      width:
                                                                          200,
                                                                      child:
                                                                          TextFormField(
                                                                        style: GoogleFonts.roboto(
                                                                            fontSize:
                                                                                17,
                                                                            height:
                                                                                1.4),
                                                                        enabled:
                                                                            !viewMode,
                                                                        initialValue:
                                                                            purchaseInvoice,
                                                                        validator:
                                                                            ((value) {
                                                                          if (value!
                                                                              .isEmpty) {
                                                                            return staticTextTranslate('Enter invoice');
                                                                          }
                                                                          return null;
                                                                        }),
                                                                        decoration: const InputDecoration(
                                                                            fillColor: Colors
                                                                                .white,
                                                                            filled:
                                                                                true,
                                                                            isDense:
                                                                                true,
                                                                            contentPadding:
                                                                                EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                                                            border: OutlineInputBorder()),
                                                                        onChanged:
                                                                            (val) =>
                                                                                setState(() {
                                                                          purchaseInvoice =
                                                                              val;
                                                                        }),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              SizedBox(
                                                                width: 300,
                                                                child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      staticTextTranslate(
                                                                          'Date'),
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        fontSize:
                                                                            getMediumFontSize +
                                                                                2,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          200,
                                                                      child:
                                                                          GestureDetector(
                                                                        onTap:
                                                                            () async {
                                                                          if (!viewMode) {
                                                                            DateTime?
                                                                                dateTime =
                                                                                await showDatePicker(
                                                                              context: context,
                                                                              initialDate: DateTime.now(),
                                                                              firstDate: DateTime(1900),
                                                                              lastDate: DateTime(2050),
                                                                            );
                                                                            if (dateTime !=
                                                                                null) {
                                                                              purchaseInvoiceDate = dateTime;
                                                                              showDateError = false;
                                                                              setState(() {});
                                                                            }
                                                                          }
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              200,
                                                                          decoration: BoxDecoration(
                                                                              color: Colors.white,
                                                                              border: Border.all(color: viewMode ? Colors.grey.shade400 : const Color.fromARGB(255, 0, 0, 0), width: 0.4),
                                                                              borderRadius: BorderRadius.circular(4)),
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal: 10,
                                                                              vertical: 7),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Text(
                                                                                purchaseInvoiceDate == null ? staticTextTranslate('Click to Select Date') : DateFormat('dd / MM / yyyy').format(purchaseInvoiceDate!),
                                                                                style: GoogleFonts.roboto(fontSize: 17, height: 1.3, color: purchaseInvoiceDate == null ? const Color.fromARGB(255, 0, 0, 0) : Colors.black),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              if (showDateError)
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              8,
                                                                          left:
                                                                              15.0),
                                                                  child: Text(
                                                                    staticTextTranslate(
                                                                        'Select a date'),
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          getMediumFontSize,
                                                                      color: Colors
                                                                              .red[
                                                                          700],
                                                                    ),
                                                                  ),
                                                                ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              SizedBox(
                                                                width: 300,
                                                                child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      staticTextTranslate(
                                                                          'Total'),
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        fontSize:
                                                                            getMediumFontSize +
                                                                                2,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          200,
                                                                      child:
                                                                          TextFormField(
                                                                        style: GoogleFonts.roboto(
                                                                            fontSize:
                                                                                17,
                                                                            height:
                                                                                1.4),
                                                                        enabled:
                                                                            !viewMode,
                                                                        initialValue:
                                                                            purchaseInvoiceTotal,
                                                                        autovalidateMode:
                                                                            AutovalidateMode.onUserInteraction,
                                                                        validator:
                                                                            ((value) {
                                                                          if (value!
                                                                              .isEmpty) {
                                                                            return staticTextTranslate('Enter invoice total');
                                                                          } else if (!RegExp(r'^[0-9.]+$').hasMatch(
                                                                              value)) {
                                                                            return staticTextTranslate('Enter a valid number');
                                                                          } else if (double.parse(value) !=
                                                                              double.parse(calculateVoucherTotal())) {
                                                                            return staticTextTranslate('Enter correct total');
                                                                          }
                                                                          return null;
                                                                        }),
                                                                        decoration: const InputDecoration(
                                                                            fillColor: Colors
                                                                                .white,
                                                                            filled:
                                                                                true,
                                                                            isDense:
                                                                                true,
                                                                            contentPadding:
                                                                                EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                                                            border: OutlineInputBorder()),
                                                                        onChanged:
                                                                            (val) =>
                                                                                setState(() {
                                                                          purchaseInvoiceTotal =
                                                                              val;
                                                                        }),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 32,
                                                        width: double.maxFinite,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 15,
                                                                vertical: 5),
                                                        decoration:
                                                            const BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          4),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          4)),
                                                          gradient:
                                                              LinearGradient(
                                                                  end: Alignment
                                                                      .bottomCenter,
                                                                  colors: [
                                                                    Color
                                                                        .fromARGB(
                                                                            255,
                                                                            66,
                                                                            66,
                                                                            66),
                                                                    Color
                                                                        .fromARGB(
                                                                            255,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                  ],
                                                                  begin: Alignment
                                                                      .topCenter),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              'Totals',
                                                              style: GoogleFonts.roboto(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Colors
                                                                      .white),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                width: 0.3),
                                                            color: const Color(
                                                                0xffE2E2E2),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        3)),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                 bottom: 10,top: 10, left: 16, right: 20,),
                                                          child: Form(
                                                            key: formKey,
                                                            child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        staticTextTranslate(
                                                                            'Voucher Price W/T'),
                                                                        style: GoogleFonts
                                                                            .roboto(
                                                                          fontSize:
                                                                              getMediumFontSize + 3,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      Text(
                                                                        calculateVoucherPriceWt(),
                                                                        style: GoogleFonts
                                                                            .roboto(
                                                                          fontSize:
                                                                              getMediumFontSize + 3,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        staticTextTranslate(
                                                                            'Total Qty.'),
                                                                        style: GoogleFonts
                                                                            .roboto(
                                                                          fontSize:
                                                                              getMediumFontSize + 3,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            0,
                                                                      ),
                                                                      Text(
                                                                        calculateTotalQty(),
                                                                        style: GoogleFonts
                                                                            .roboto(
                                                                          fontSize:
                                                                              getMediumFontSize + 3,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        staticTextTranslate(
                                                                            'Line Items'),
                                                                        style: GoogleFonts
                                                                            .roboto(
                                                                          fontSize:
                                                                              getMediumFontSize + 3,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            0,
                                                                      ),
                                                                      Text(
                                                                        calculateLinesItem(),
                                                                        style: GoogleFonts
                                                                            .roboto(
                                                                          fontSize:
                                                                              getMediumFontSize + 3,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        tax.isEmpty
                                                                            ? staticTextTranslate('Tax')
                                                                            : engSelectedLanguage
                                                                                ? 'Tax ($tax%)'
                                                                                : '(%$tax) ${staticTextTranslate('Tax')}',
                                                                        style: GoogleFonts
                                                                            .roboto(
                                                                          fontSize:
                                                                              getMediumFontSize + 3,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            0,
                                                                      ),
                                                                      Text(
                                                                        tax.isEmpty
                                                                            ? '0'
                                                                            : calculateTaxValue(),
                                                                        style: GoogleFonts
                                                                            .roboto(
                                                                          fontSize:
                                                                              getMediumFontSize + 3,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  if (viewMode)
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          staticTextTranslate(
                                                                              'Created Date'),
                                                                          style:
                                                                              GoogleFonts.roboto(
                                                                            fontSize:
                                                                                getMediumFontSize + 3,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              0,
                                                                        ),
                                                                        Text(
                                                                          DateFormat('dd / MM / yyyy')
                                                                              .format(createdDate!),
                                                                          style:
                                                                              GoogleFonts.roboto(
                                                                            fontSize:
                                                                                getMediumFontSize + 3,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  if (viewMode)
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                  Text(
                                                                    '----------------------------------------------------------------',
                                                                    style: GoogleFonts
                                                                        .roboto(
                                                                      fontSize:
                                                                          getMediumFontSize +
                                                                              2,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        staticTextTranslate(
                                                                            'VOUCHER TOTAL'),
                                                                        style: GoogleFonts.roboto(
                                                                            fontSize: getMediumFontSize +
                                                                                4,
                                                                            fontWeight:
                                                                                FontWeight.w500),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            0,
                                                                      ),
                                                                      Text(
                                                                        calculateVoucherTotal(),
                                                                        style: GoogleFonts.roboto(
                                                                            fontSize: getMediumFontSize +
                                                                                5,
                                                                            fontWeight:
                                                                                FontWeight.w500),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: 13,
                                                                  ),
                                                                  // SizedBox(
                                                                  //   width: 280,
                                                                  //   child:
                                                                  //       Column(
                                                                  //     crossAxisAlignment:
                                                                  //         CrossAxisAlignment
                                                                  //             .start,
                                                                  //     children: [
                                                                  //       Text(
                                                                  //           staticTextTranslate(
                                                                  //               'Note'),
                                                                  //           style:
                                                                  //               TextStyle(
                                                                  //             fontSize: getMediumFontSize - 1,
                                                                  //           )),
                                                                  //       const SizedBox(
                                                                  //         height:
                                                                  //             5,
                                                                  //       ),
                                                                  //       TextFormField(
                                                                  //         style:
                                                                  //             const TextStyle(fontSize: 16),
                                                                  //         enabled:
                                                                  //             !viewMode,
                                                                  //         initialValue:
                                                                  //             note,
                                                                  //         autovalidateMode:
                                                                  //             AutovalidateMode.onUserInteraction,
                                                                  //         maxLines:
                                                                  //             2,
                                                                  //         decoration: const InputDecoration(
                                                                  //             isDense: true,
                                                                  //             contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                                                  //             border: OutlineInputBorder()),
                                                                  //         onChanged: (val) =>
                                                                  //             setState(() {
                                                                  //           note =
                                                                  //               val;
                                                                  //         }),
                                                                  //       )
                                                                  //     ],
                                                                  //   ),
                                                                  // ),
                                                                  // const SizedBox(
                                                                  //   height: 10,
                                                                  // ),
                                                                  if (!viewMode)
                                                                    Container(
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(4),
                                                                          gradient: const LinearGradient(
                                                                              end: Alignment.bottomCenter,
                                                                              colors: [
                                                                                Color(0xff092F53),
                                                                                Color(0xff284F70),
                                                                              ],
                                                                              begin: Alignment.topCenter)),
                                                                      height:
                                                                          42,
                                                                      child: ElevatedButton(
                                                                          style: ElevatedButton.styleFrom(
                                                                            backgroundColor:
                                                                                Colors.transparent,
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(3),
                                                                            ),
                                                                          ),
                                                                          onPressed: () async {
                                                                            if (purchaseInvoiceDate ==
                                                                                null) {
                                                                              setState(() {
                                                                                showDateError = true;
                                                                              });
                                                                            }
                                                                            if (formKey.currentState!.validate() &&
                                                                                purchaseInvoiceDate != null) {
                                                                              setState(() {
                                                                                uploading = true;
                                                                              });
                                                                              // var dbVoucherDataLst =
                                                                              //     [];

                                                                              // String
                                                                              //     voucherNo =
                                                                              //     '10001';
                                                                              // dbVoucherDataLst =
                                                                              //     await FbVoucherDbService(context: context).fetchAllVoucherData();
                                                                              // dbVoucherDataLst.sort((a, b) => a
                                                                              //     .voucherNo
                                                                              //     .compareTo(b.voucherNo));
                                                                              // if (dbVoucherDataLst
                                                                              //     .isNotEmpty) {
                                                                              //   int v =
                                                                              //       int.parse(dbVoucherDataLst.last.voucherNo) + 1;

                                                                              //   voucherNo =
                                                                              //       v.toString();
                                                                              // }

                                                                              DbVoucherData dbVoucherData = DbVoucherData(
                                                                                  voucherType: regularReturnDropDown,
                                                                                  selectedStoreDocId: selectedStoreData.docId,
                                                                                  docId: getRandomString(20),
                                                                                  createdDate: DateTime.now(),
                                                                                  selectedItems: localVoucherData
                                                                                      .map((e) => {
                                                                                            'barcode': e.barcode,
                                                                                            'qty': e.qty,
                                                                                            'cost': e.cost,
                                                                                            'price': e.price,
                                                                                            'priceWt': e.priceWt
                                                                                          })
                                                                                      .toList(),
                                                                                  discountPercentage: discountPercent,
                                                                                  discountValue: discountValue,
                                                                                  note: note,
                                                                                  purchaseInvoiceDate: purchaseInvoiceDate.toString(),
                                                                                  tax: tax,
                                                                                  createdBy: createdBy,
                                                                                  qtyRecieved: calculateTotalQty(),
                                                                                  vendor: selectedVendor!.vendorId,
                                                                                  purchaseInvoice: purchaseInvoice,
                                                                                  voucherNo: currentVoucherNumber,
                                                                                  voucherTotal: calculateVoucherTotal());
                                                                              printVoucher(context, dbVoucherData, calculateVoucherPriceWt(), selectedVendor!, localVoucherData);

                                                                              await FbVoucherDbService(context: context).addUpdateVoucher(voucherDataLst: [
                                                                                dbVoucherData
                                                                              ], allInventoryDataLst: allInventoryDataLst);

                                                                              setState(() {
                                                                                uploading = false;
                                                                              });
                                                                              Navigator.pop(context, true);
                                                                            }
                                                                          },
                                                                          child: Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Image.asset(
                                                                                'assets/icons/disk.png',
                                                                                height: 15,
                                                                                color: Colors.white,
                                                                              ),
                                                                              const SizedBox(
                                                                                width: 10,
                                                                              ),
                                                                              Text(staticTextTranslate('Print & Update'),
                                                                                  style: TextStyle(
                                                                                    fontSize: getMediumFontSize,
                                                                                  )),
                                                                            ],
                                                                          )),
                                                                    ),
                                                                ]),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          );
        });
  }

  showSelectItemDialog() async {
    List<InventoryData> selectedInventoryDataLst = await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SelectInventoryItemPage(
            userData: widget.userData,
          ),
        );
      },
    );

    for (var inv in selectedInventoryDataLst) {
      addSearcheSubmittedInvData(inv);
    }
  }

  addSearcheSubmittedInvData(InventoryData inv) {
    localVoucherData.add(LocalVoucherData(
      barcode: inv.barcode,
      cost: inv.cost,
      itemCode: inv.itemCode,
      price: inv.price,
      priceWt: inv.priceWT,
      productName: inv.productName,
      qty: '1',
      extCost: inv.cost,
    ));
    var box = Hive.box('bitpro_app');

    box.put('voucher_data', localVoucherData.map((e) => e.toMap()).toList());
    voucherDataSource = VoucherDataSource(localVoucherData, context);
    setState(() {});
  }

  storeFilterWidget() {
    return Container(
        width: 230,
        height: 35,
        margin: const EdgeInsets.only(top: 0, bottom: 10),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 0.5),
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(4)),
        padding: const EdgeInsets.only(right: 10, left: 10),
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedStoreData.docId,
          underline: const SizedBox(),
          items: allStoresData.map((StoreData value) {
            return DropdownMenuItem<String>(
              value: value.docId,
              child: Text(
                staticTextTranslate(value.storeName),
                style: GoogleFonts.roboto(
                  fontSize: getMediumFontSize + 2,
                ),
              ),
            );
          }).toList(),
          onChanged: widget.viewMode && widget.selectedDbVoucherData != null
              ? null
              : (val) {
                  setState(() {
                    int index = allStoresData
                        .indexWhere((element) => element.docId == val);
                    if (index != -1) {
                      selectedStoreData = allStoresData.elementAt(index);
                      setState(() {});
                    }
                  });
                },
        ));
  }

  regularReturnFilter() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (viewMode == false)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: const LinearGradient(
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xff092F53),
                    Color(0xff284F70),
                  ],
                  begin: Alignment.topCenter),
            ),
            height: 35,
            width: 35,
            margin: const EdgeInsets.only(top: 10),
            child: IconButton(
              icon: const Icon(
                Iconsax.d_square,
                color: Colors.white,
                size: 20,
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: darkBlueColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4))),
              onPressed: () {
                showSelectItemDialog();
              },
            ),
          ),
        const SizedBox(width: 10),
        Container(
            width: 190,
            height: 35,
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                border: Border.all(color: Colors.grey, width: 0.5),
                borderRadius: BorderRadius.circular(4)),
            padding: const EdgeInsets.only(right: 10, left: 10),
            child: DropdownButton<String>(
              isExpanded: true,
              value: regularReturnDropDown,
              underline: const SizedBox(),
              items: <String>['Regular', 'Return'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    staticTextTranslate(value),
                    style: GoogleFonts.roboto(
                      fontSize: getMediumFontSize + 2,
                    ),
                  ),
                );
              }).toList(),
              onChanged: widget.viewMode && widget.selectedDbVoucherData != null
                  ? null
                  : (val) {
                      setState(() {
                        regularReturnDropDown = val ?? 'Regular';
                      });
                    },
            )),
      ],
    );
  }

  showImportDialog() {
    File? importItem;
    Map<String, dynamic> uploadRes = {};
    bool dialogLoading = false;
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) => StatefulBuilder(builder: (context, setState2) {
              return Dialog(
                backgroundColor: homeBgColor,
                child: SizedBox(
                    height: 340,
                    width: 500,
                    child: dialogLoading
                        ? showLoading()
                        : Column(children: [
                            Expanded(
                              child: SizedBox(
                                width: 500,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 15),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                staticTextTranslate(
                                                    'Product Import'),
                                                style: TextStyle(
                                                    fontSize: getMediumFontSize,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                    staticTextTranslate(
                                                        'Download Sample file here.'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize,
                                                    )),
                                                TextButton(
                                                  onPressed: () async {
                                                    setState(() {
                                                      dialogLoading = true;
                                                    });
                                                    setState2(() {});
                                                    final Workbook workbook =
                                                        Workbook();

                                                    final Worksheet sheet =
                                                        workbook.worksheets[0];

                                                    sheet
                                                        .getRangeByName('A1')
                                                        .setText('barcode');
                                                    sheet
                                                        .getRangeByName('B1')
                                                        .setText('qty');
                                                    sheet
                                                        .getRangeByName('C1')
                                                        .setText('cost');
                                                    sheet
                                                        .getRangeByName('D1')
                                                        .setText('price');

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
                                                  width: 30,
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
                                                          localVoucherDataFromExcel(
                                                              excel,
                                                              allInventoryDataLst);
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
                                                    child: Text(
                                                        staticTextTranslate(
                                                            'Select File'),
                                                        style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
                                                        )),
                                                  ),
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
                                                    : '${staticTextTranslate('Items Found')} : ${uploadRes['localVoucherDataLst'].length}',
                                                style: TextStyle(
                                                  fontSize: getMediumFontSize,
                                                )),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                    staticTextTranslate(
                                                        'Note : '),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize,
                                                    )),
                                                Text(
                                                  uploadRes.isNotEmpty
                                                      ? '${uploadRes['dublicate']} ${staticTextTranslate('Duplicate items found')}'
                                                          ' ${uploadRes['dublicate']}'
                                                      : staticTextTranslate(
                                                          '0 Duplicate items found'),
                                                  style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize,
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
                                    horizontal: 30, vertical: 20),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 45,
                                      width: 150,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: uploadRes
                                                          .isEmpty ||
                                                      uploadRes['localVoucherDataLst']
                                                              .length ==
                                                          0
                                                  ? Colors.grey
                                                  : darkBlueColor,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8))),
                                          onPressed: () async {
                                            if (uploadRes.isNotEmpty &&
                                                uploadRes['localVoucherDataLst']
                                                        .length !=
                                                    0) {
                                              setState(() {
                                                dialogLoading = true;
                                              });
                                              setState2(() {});

                                              for (var inv in uploadRes[
                                                  'localVoucherDataLst']) {
                                                addSearcheSubmittedInvData(inv);
                                              }

                                              setState(() {
                                                dialogLoading = false;
                                              });
                                              setState2(() {});
                                              Navigator.pop(context);
                                            }
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                'assets/icons/disk.png',
                                                height: 15,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                  uploadRes['dublicate'] ==
                                                              null ||
                                                          uploadRes[
                                                                  'dublicate'] ==
                                                              0
                                                      ? staticTextTranslate(
                                                          'Import')
                                                      : staticTextTranslate(
                                                          'Skip & Import'),
                                                  style: TextStyle(
                                                    fontSize: getMediumFontSize,
                                                  )),
                                            ],
                                          )),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    SizedBox(
                                      height: 45,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8))),
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
                                  ],
                                ),
                              ),
                            )
                          ])),
              );
            }));
  }

  String calculateTotalQty() {
    double t = 0;
    for (LocalVoucherData v in localVoucherData) {
      t += double.tryParse(v.qty) ?? 0;
    }

    return t.round().toString();
  }

  String calculateVoucherPriceWt() {
    double t = 0;
    for (LocalVoucherData v in localVoucherData) {
      double d = 0;
      d = double.tryParse(v.priceWt) ?? 0;
      if (double.tryParse(v.qty) != null) t += d * double.tryParse(v.qty)!;
    }

    return t.toStringAsFixed(2);
  }

  String calculateTaxValue() {
    double t = 0;
    for (LocalVoucherData v in localVoucherData) {
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

    return taxValue.toStringAsFixed(2);
  }

  String calculateVoucherTotal() {
    double t = 0;

    for (LocalVoucherData v in localVoucherData) {
      double d = 0;
      d = double.tryParse(v.cost) ?? 0;
      if (double.tryParse(v.qty) != null) t += d * double.tryParse(v.qty)!;
    }

    if (t == 0) {
      discountValueTextEditingController.text = '0';
      discountPerTextEditingController.text = '0';
      return t.toStringAsFixed(2);
    }

    //discount value
    if (discountValue.isNotEmpty) {
      double dis = double.tryParse(discountValue) ?? 0;
      if (dis != 0) {
        t = t - dis;
      }
    }
    //tax`
    if (tax.isNotEmpty) {
      double tx = double.tryParse(tax) ?? 0;
      if (tx != 0) t = t + (t * tx / 100);
    }
    // print(discountValue);
    // print(t.toString());
    return t.toStringAsFixed(2);
  }

  String calculateLinesItem() {
    int num = 0;
    for (LocalVoucherData v in localVoucherData) {
      if (v.itemCode.isNotEmpty) num++;
    }
    return num.toString();
  }

  calculateAndUpdatedDiscountPercentage(String disVal) {
    double t = 0;

    for (LocalVoucherData v in localVoucherData) {
      double d = 0;
      d = double.tryParse(v.cost) ?? 0;
      if (double.tryParse(v.qty) != null) t += d * double.tryParse(v.qty)!;
    }
    double dis = double.parse(disVal);
    discountPerTextEditingController.text =
        ((dis * 100) / t).toStringAsFixed(2);
    discountPercent = ((dis * 100) / t).toStringAsFixed(2);
  }

  calculateAndUpdatedDiscountValue(String disPer) {
    double t = 0;

    for (LocalVoucherData v in localVoucherData) {
      double d = 0;
      d = double.tryParse(v.cost) ?? 0;
      if (double.tryParse(v.qty) != null) t += d * double.tryParse(v.qty)!;
    }
    double dis = double.parse(disPer);

    discountValueTextEditingController.text =
        (t * dis / 100).toStringAsFixed(2);
    discountValue = (t * dis / 100).toStringAsFixed(2);
  }

  filters() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        children: [
          Container(
            width: 230,
            height: 35,
            decoration: BoxDecoration(
                border: Border.all(
                    color: viewMode ? Colors.grey : Colors.blue,
                    width: viewMode ? 0.5 : 2),
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(4)),
            padding: const EdgeInsets.only(right: 10, bottom: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  padding: const EdgeInsets.only(top: 3),
                  onPressed: () {
                    _f1VendorTypeAheadController.clear();

                    setState(() {});
                  },
                  splashRadius: 1,
                  icon: Icon(
                      _f1VendorTypeAheadController.text.isEmpty
                          ? CupertinoIcons.search
                          : Icons.clear,
                      size: 18,
                      color: _f1VendorTypeAheadController.text.isEmpty
                          ? Colors.grey[600]
                          : Colors.black),
                ),
                if (viewMode)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        staticTextTranslate('Barcode / Item Code'),
                        style: TextStyle(
                            fontSize: getMediumFontSize + 2,
                            color: Colors.grey[600]),
                      ),
                    ),
                  ),
                if (!viewMode)
                  Flexible(
                    child: TypeAheadFormField(
                      enabled: !viewMode,
                      getImmediateSuggestions: false,
                      textFieldConfiguration: TextFieldConfiguration(
                        // controller: _f1VendorTypeAheadController,
                        decoration: InputDecoration(
                          hintText: staticTextTranslate('Barcode / Item Code'),
                          hintStyle: GoogleFonts.roboto(
                            fontSize: getMediumFontSize + 2,
                          ),
                          contentPadding: const EdgeInsets.only(
                              // left:
                              //     10,
                              bottom: 14,
                              right: 5),
                          border: InputBorder.none,
                        ),
                      ),
                      suggestionsCallback: (pattern) {
                        return allInventoryDataLst
                            .where((e) =>
                                e.barcode
                                    .toLowerCase()
                                    .contains(pattern.toLowerCase()) ||
                                e.itemCode
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
                      itemBuilder: (context, InventoryData suggestion) {
                        return ListTile(
                          title: Text(
                              '${suggestion.barcode} - ${suggestion.itemCode}',
                              style: TextStyle(
                                fontSize: getMediumFontSize,
                              )),
                          subtitle: Text(suggestion.productName,
                              style: TextStyle(
                                fontSize: getMediumFontSize,
                              )),
                        );
                      },
                      transitionBuilder: (context, suggestionsBox, controller) {
                        return suggestionsBox;
                      },
                      onSuggestionSelected: (InventoryData suggestion) {
                        addSearcheSubmittedInvData(suggestion);
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Container(
            width: 210,
            height: 35,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 0.5),
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(4)),
            padding: const EdgeInsets.only(right: 10, bottom: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    _f2VendorTypeAheadController.clear();

                    setState(() {});
                  },
                  splashRadius: 1,
                  padding: const EdgeInsets.only(top: 3),
                  icon: Icon(
                      _f2VendorTypeAheadController.text.isEmpty
                          ? CupertinoIcons.search
                          : Icons.clear,
                      size: 18,
                      color: _f2VendorTypeAheadController.text.isEmpty
                          ? Colors.grey[600]
                          : Colors.black),
                ),
                if (viewMode)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        staticTextTranslate('Search for Items'),
                        style: GoogleFonts.roboto(
                          fontSize: getMediumFontSize + 2,
                        ),
                      ),
                    ),
                  ),
                if (!viewMode)
                  Flexible(
                    child: TypeAheadFormField(
                      getImmediateSuggestions: false,
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _f2VendorTypeAheadController,
                        decoration: InputDecoration(
                          hintText: staticTextTranslate('Search for Items'),
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          contentPadding:
                              const EdgeInsets.only(bottom: 13, right: 5),
                          border: InputBorder.none,
                        ),
                      ),
                      noItemsFoundBuilder: (context) {
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(staticTextTranslate('No Items Found!'),
                              style: TextStyle(
                                fontSize: getMediumFontSize,
                              )),
                        );
                      },
                      suggestionsCallback: (pattern) {
                        return allInventoryDataLst
                            .where((e) => e.productName
                                .toLowerCase()
                                .contains(pattern.toLowerCase()))
                            .toList();
                      },
                      itemBuilder: (context, InventoryData suggestion) {
                        return ListTile(
                          title: Text(suggestion.productName,
                              style: TextStyle(
                                fontSize: getMediumFontSize,
                              )),
                          subtitle: Text(
                              '${suggestion.barcode} - ${suggestion.itemCode}',
                              style: TextStyle(
                                fontSize: getMediumFontSize,
                              )),
                        );
                      },
                      transitionBuilder: (context, suggestionsBox, controller) {
                        return suggestionsBox;
                      },
                      onSuggestionSelected: (InventoryData suggestion) {
                        addSearcheSubmittedInvData(suggestion);
                        setState(() {});
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(
            width: 0,
          ),
        ],
      ),
    );
  }
}

class VoucherDataSource extends DataGridSource {
  VoucherDataSource(List<dynamic> g, context) {
    gVoucherData = g;
    buildDataGridRows();
    this.context = context;
  }
  void buildDataGridRows() {
    dataGridRows = gVoucherData
        .map<DataGridRow>((dealer) =>
            getDataGridRow(dealer, gVoucherData.indexOf(dealer) + 1))
        .toList();
  }

  /// Get datagrid row of the dealer.
  DataGridRow getDataGridRow(dealer, snum) {
    return DataGridRow(cells: <DataGridCell>[
      DataGridCell<int>(columnName: 'serialNumberForStyleColor', value: snum),
      DataGridCell<String>(columnName: 'barcode', value: dealer.barcode),
      DataGridCell<String>(columnName: 'itemCode', value: dealer.itemCode),
      DataGridCell<String>(
          columnName: 'productName', value: dealer.productName),
      DataGridCell<String>(columnName: 'qty', value: dealer.qty),
      DataGridCell<String>(columnName: 'cost', value: dealer.cost),
      DataGridCell<String>(columnName: 'price', value: dealer.price),
      DataGridCell<String>(columnName: 'priceWT', value: dealer.priceWt),
      DataGridCell<String>(columnName: 'extCost', value: dealer.extCost),
    ]);
  }

  late Function voucherRefersh;
  late BuildContext context;
  @override
  List<DataGridRow> get rows => dataGridRows;

  late List<dynamic> gVoucherData;
  late List<DataGridRow> dataGridRows;
  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        color: row.getCells()[0].value.isEven
            ? const Color(0xffF1F1F1)
            : Colors.white,
        cells: row.getCells().map<Widget>((e) {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
            child: Text(
              e.value.toString(),
              style: GoogleFonts.roboto(
                fontSize: getMediumFontSize + 2,
              ),
            ),
          );
        }).toList());
  }

  dynamic newCellValue;

  /// Help to control the editable text in [TextField] widget.
  TextEditingController editingController = TextEditingController();

  @override
  Future<void> onCellSubmit(DataGridRow dataGridRow,
      RowColumnIndex rowColumnIndex, GridColumn column) async {
    final dynamic oldValue = dataGridRow
            .getCells()
            .firstWhere((DataGridCell dataGridCell) =>
                dataGridCell.columnName == column.columnName)
            .value ??
        '';

    final int dataRowIndex = dataGridRows.indexOf(dataGridRow);

    if (newCellValue == null || oldValue == newCellValue) {
      return;
    }

    if (column.columnName == 'qty') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<String>(columnName: 'qty', value: newCellValue);
      gVoucherData[dataRowIndex].qty = newCellValue;
      //updating ext cost
      dataGridRows[dataRowIndex].getCells()[8] = DataGridCell<String>(
          columnName: 'extCost',
          value: (double.parse(newCellValue) *
                  double.parse(gVoucherData[dataRowIndex].cost))
              .toString());
      gVoucherData[dataRowIndex].extCost = (double.parse(newCellValue) *
              double.parse(gVoucherData[dataRowIndex].cost))
          .toString();
    } else if (column.columnName == 'cost') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<String>(columnName: 'cost', value: newCellValue);
      gVoucherData[dataRowIndex].cost = newCellValue;

      //updating ext cost
      dataGridRows[dataRowIndex].getCells()[8] = DataGridCell<String>(
          columnName: 'extCost',
          value: (double.parse(newCellValue) *
                  double.parse(gVoucherData[dataRowIndex].qty))
              .toString());
      gVoucherData[dataRowIndex].extCost = (double.parse(newCellValue) *
              double.parse(gVoucherData[dataRowIndex].qty))
          .toString();
    } else if (column.columnName == 'price') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<String>(columnName: 'price', value: newCellValue);
      gVoucherData[dataRowIndex].price = newCellValue;
    } else if (column.columnName == 'priceWT') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<String>(columnName: 'priceWT', value: newCellValue);
      gVoucherData[dataRowIndex].priceWt = newCellValue;
    }
    var box = Hive.box('bitpro_app');

    box.put('voucher_data', gVoucherData.map((e) => e.toMap()).toList());
  }

  @override
  Widget? buildEditWidget(DataGridRow dataGridRow,
      RowColumnIndex rowColumnIndex, GridColumn column, CellSubmit submitCell) {
    // Text going to display on editable widget
    final String displayText = dataGridRow
            .getCells()
            .firstWhere((DataGridCell dataGridCell) =>
                dataGridCell.columnName == column.columnName)
            .value
            ?.toString() ??
        '';

    newCellValue = null;

    final bool isNumericType =
        column.columnName == 'id' || column.columnName == 'salary';

    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: isNumericType ? Alignment.centerRight : Alignment.centerLeft,
      child: TextField(
        autofocus: true,
        controller: editingController..text = displayText,
        textAlign: isNumericType ? TextAlign.right : TextAlign.left,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 16.0),
        ),
        keyboardType: isNumericType ? TextInputType.number : TextInputType.text,
        onChanged: (String value) {
          if (value.isNotEmpty) {
            if (isNumericType) {
              newCellValue = int.parse(value);
            } else {
              newCellValue = value;
            }
          } else {
            newCellValue = null;
          }
        },
        onSubmitted: (String value) {
          // In Mobile Platform.
          // Call [CellSubmit] callback to fire the canSubmitCell and
          // onCellSubmit to commit the new value in single place.
          submitCell();
        },
      ),
    );
  }
}
