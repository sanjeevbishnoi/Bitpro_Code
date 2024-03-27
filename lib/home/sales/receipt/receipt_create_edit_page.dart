import 'dart:io';
import 'dart:math';
import 'package:bitpro_hive/home/sales/receipt/create_receipt_widgets/tendor_amount_dialog.dart';
import 'package:bitpro_hive/model/store_data.dart';
import 'package:bitpro_hive/services/firestore_api/fb_sales/fb_customer_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_sales/fb_receipt_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_merchandise_db_service/inventory_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_sales_db_service/hive_promo_code_db_serice.dart';
import 'package:bitpro_hive/services/hive/hive_settings/hive_store_db_service.dart';
import 'package:bitpro_hive/services/hive/import_data_exel/local_receipt_data_excel.dart';
import 'package:bitpro_hive/shared/constant_data.dart';
import 'package:bitpro_hive/widget/string_related/get_id_number.dart';
import 'package:bitpro_hive/widget/top_bar.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bitpro_hive/home/sales/receipt/selectInventoryItemPage.dart';
import 'package:bitpro_hive/model/customer_data.dart';
import 'package:bitpro_hive/model/receipt/db_receipt_data.dart';
import 'package:bitpro_hive/model/receipt/local_receipt_data.dart';
import 'package:bitpro_hive/shared/custom_top_nav_bar.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bitpro_hive/model/inventory_data.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:bitpro_hive/shared/loading.dart';
import 'package:syncfusion_flutter_datagrid_export/export.dart';
import '../../../model/promo_code_data.dart';
import '../../../shared/dialogs/discard_changes_dialog.dart';
import '../../../shared/dialogs/discount_overlimt_dialog.dart';
import '../../../shared/global_variables/font_sizes.dart';
import '../../../shared/templates/receipt_templates/print_receipt.dart';
import '../../../shared/templates/tag/print_tag.dart';
import '../../../shared/save_file_and_launch.dart';
import '../../../shared/dialogs/show_product_price_enter_dialog.dart';
import '../../../shared/global_variables/static_text_translate.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;
import '../customer/customer_create_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CreateEditReceiptPage extends StatefulWidget {
  final UserData userData;
  final List<CustomerData> customerDataLst;
  final bool viewMode;
  final DbReceiptData? selectedDbReceiptData;
  final String currentReceiptId;
  const CreateEditReceiptPage({
    Key? key,
    required this.userData,
    this.viewMode = false,
    required this.customerDataLst,
    this.selectedDbReceiptData,
    required this.currentReceiptId,
  }) : super(key: key);

  @override
  State<CreateEditReceiptPage> createState() => _CreateEditReceiptPageState();
}

class _CreateEditReceiptPageState extends State<CreateEditReceiptPage> {
  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();
  final TextEditingController _scanOrEnterBarcodeTypeAheadController =
      TextEditingController();
  FocusNode scanBarcodeFocusNode = FocusNode();
  final TextEditingController _searchForItemsTypeAheadController =
      TextEditingController();
  final TextEditingController _searchCustomerTypeAheadController =
      TextEditingController();
  DataGridController dataGridController = DataGridController();
  List selectedLocalReceiptData = []; //LocalReceiptData
  late List<CustomerData> customerDataLst;
  String regularReturnDropDown = 'Regular';

  String tax = '10';
  bool viewMode = false;
  bool reloadDataOnPop = false;
  DbReceiptData? selectedDbReceiptData;
  CustomerData? selectedCustomerData;
  ReceiptDataSource? receiptDataSource;
  List<PromoData> allPromotionDataLst = [];
  List<InventoryData> allInventoryDataLst = [];
  //receipt payment setting fields
  Map<dynamic, dynamic> paymentTypeList = {};
  Map<dynamic, dynamic> allPaymentMethodAmountsInfo = {};
  String userMaxDiscount = '';
  String selectedProductImg = '';
  List<StoreData> allStoresData = [];
  late StoreData selectedStoreData;

  //need to check
  String createdBy = '';
  bool loading = true;
  bool uploading = false;
  String referenceNo = '';

  getData() async {
    allPromotionDataLst = await HivePromoDbService().fetchPromoData();
    allInventoryDataLst =
        await HiveInventoryDbService().fetchAllInventoryData();
    //updating store data
    allStoresData = await HiveStoreDbService().fetchAllStoresData();
    //
    if (widget.viewMode) {
      int index = allStoresData.indexWhere((element) =>
          element.docId == widget.selectedDbReceiptData!.selectedStoreDocId);
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

  @override
  void initState() {
    super.initState();

    customerDataLst = widget.customerDataLst;

    createdBy = widget.userData.username;
    userMaxDiscount = widget.userData.maxDiscount;
    //updating tax
    var box = Hive.box('bitpro_app');
    Map? userTaxesData = box.get('user_taxes_settings');
    paymentTypeList = box.get('payment_type_list') ?? {};
    if (userTaxesData != null) {
      tax = userTaxesData['taxPercentage'].toString();
    }
    selectedLocalReceiptData = [];
    receiptDataSource = ReceiptDataSource(
        selectedLocalReceiptData, widget.userData.maxDiscount, context);

    box.delete('receipt_data');

    box.put('receipt_data', []);

    if (widget.viewMode && widget.selectedDbReceiptData != null) {
      viewMode = widget.viewMode;
      tax = widget.selectedDbReceiptData!.taxPer;
      allPaymentMethodAmountsInfo =
          widget.selectedDbReceiptData!.allPaymentMethodAmountsInfo;
      selectedDbReceiptData = widget.selectedDbReceiptData!;

      if (widget.selectedDbReceiptData!.selectedCustomerID.isNotEmpty) {
        if (widget.customerDataLst.indexWhere((element) =>
                element.customerId ==
                widget.selectedDbReceiptData!.selectedCustomerID) !=
            -1) {
          selectedCustomerData = widget.customerDataLst.firstWhere((element) =>
              element.customerId ==
              widget.selectedDbReceiptData!.selectedCustomerID);
          _searchCustomerTypeAheadController.text =
              selectedCustomerData!.customerName;
        } else {
          // showToast('Customer not found', context);
        }
      }

      regularReturnDropDown = widget.selectedDbReceiptData!.receiptType;
      referenceNo = widget.selectedDbReceiptData!.referenceNo;
    }
    getData();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => scanBarcodeFocusNode.requestFocus());
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
      receiptDataSource = ReceiptDataSource(
          selectedLocalReceiptData, widget.userData.maxDiscount, context);
      setState(() {});
      return;
    }

    for (var i in selectedLocalReceiptData) {
      if (i.barcode.toLowerCase().contains(txt.toLowerCase()) ||
          i.itemCode.toLowerCase().contains(txt.toLowerCase())) {
        filteredInventoryDataLst.add(i);
      }
    }

    receiptDataSource = ReceiptDataSource(
        filteredInventoryDataLst, widget.userData.maxDiscount, context);

    setState(() {});
  }

  searchByVendroInvoice(String txt) {
    List<dynamic> filteredInventoryDataLst = [];
    if (txt.isEmpty) {
      receiptDataSource = ReceiptDataSource(
          selectedLocalReceiptData, widget.userData.maxDiscount, context);
      setState(() {});
      return;
    }

    for (var i in selectedLocalReceiptData) {
      if (i.productName.toLowerCase().contains(txt.toLowerCase())) {
        filteredInventoryDataLst.add(i);
      }
    }

    receiptDataSource = ReceiptDataSource(
        filteredInventoryDataLst, widget.userData.maxDiscount, context);
    setState(() {});
  }

//only in view mode
  getLocalReceiptDataFromBarcode() {
    for (var b in selectedDbReceiptData!.selectedItems) {
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
        double disOfOneProduct =
            double.parse(b['discountValue']) / double.parse(b['qty']);
        double discountPercentage =
            disOfOneProduct / (double.parse(b['orgPrice']) / 100);
        selectedLocalReceiptData.add(LocalReceiptData(
          barcode: inv.barcode,
          itemCode: inv.itemCode,
          productName: inv.productName,
          cost: inv.cost,
          qty: b['qty'],
          discountValue: b['discountValue'],
          discountPercentage: discountPercentage.toStringAsFixed(2),
          orgPrice: b['orgPrice'],
          total: b['total'],
          priceWt: b['priceWt'],
        ));
      }
    }

    receiptDataSource = ReceiptDataSource(
        selectedLocalReceiptData, widget.userData.maxDiscount, context);
  }

  void _shortcutKeyOnTap(String name) {
    if (name == 'openTendor' && !viewMode) {
      tenderDialog();
    } else if (name == 'printUpdatedOnTap' && !viewMode) {
      printAndUploadOnTap();
    } else if (name == 'updatedOnTap' && !viewMode) {
      printAndUploadOnTap(updateOnly: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
        valueListenable: Hive.box('bitpro_app').listenable(),
        builder: (context, box, widget) {
          if (!viewMode) {
            var vd = box.get('receipt_data');

            selectedLocalReceiptData = vd
                .map((e) => LocalReceiptData.fromMap(e))
                .toList() as List<dynamic>;
          }

          if (viewMode &&
              selectedDbReceiptData != null &&
              selectedLocalReceiptData.isEmpty) {
            getLocalReceiptDataFromBarcode();
          }

          return customTopNavBar(
            Shortcuts(
              shortcuts: <LogicalKeySet, Intent>{
                LogicalKeySet(LogicalKeyboardKey.f8):
                    const ReceiptCallbackShortcutsIntent(name: 'openTendor'),
                LogicalKeySet(LogicalKeyboardKey.f12):
                    const ReceiptCallbackShortcutsIntent(
                        name: 'printUpdatedOnTap'),
                LogicalKeySet(LogicalKeyboardKey.f11):
                    const ReceiptCallbackShortcutsIntent(name: 'updatedOnTap'),
              },
              child: Actions(
                actions: <Type, Action<Intent>>{
                  ReceiptCallbackShortcutsIntent:
                      CallbackAction<ReceiptCallbackShortcutsIntent>(
                          onInvoke: (ReceiptCallbackShortcutsIntent intent) =>
                              _shortcutKeyOnTap(intent.name)),
                },
                child: Scaffold(
                  backgroundColor: homeBgColor,
                  body: uploading
                      ? Center(
                          child: showLoading(),
                        )
                      : Container(
                          color: const Color(0xffE2E2E2),
                          child: Column(
                            children: [
                              const TopBar(
                                pageName: 'Receipt',
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      color:
                                          const Color.fromARGB(255, 43, 43, 43),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                              height: 40,
                                              width: 170,
                                              child: TextButton(
                                                style: TextButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4))),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Image.asset(
                                                      'assets/icons/back.png',
                                                      width: 18,
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                        staticTextTranslate(
                                                            'Back'),
                                                        style: TextStyle(
                                                            fontSize:
                                                                getMediumFontSize,
                                                            color: const Color
                                                                .fromARGB(
                                                                255,
                                                                235,
                                                                235,
                                                                235))),
                                                  ],
                                                ),
                                                onPressed: () {
                                                  if (viewMode) {
                                                    Navigator.pop(context);
                                                  } else {
                                                    showDiscardChangesDialog(
                                                        context,
                                                        receipt:
                                                            reloadDataOnPop);
                                                  }
                                                },
                                              )),
                                          if (!viewMode)
                                            SizedBox(
                                              height: 40,
                                              width: 170,
                                              child: TextButton(
                                                style: TextButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4))),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Image.asset(
                                                      'assets/icons/remove.png',
                                                      width: 20,
                                                      // color: dataGridController
                                                      //               .selectedIndex ==
                                                      //           -1
                                                      //       ? Colors.grey[400]
                                                      //       :const Color
                                                      //           .fromARGB(
                                                      //           255, 0, 0, 0),
                                                    ),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    Text(
                                                      staticTextTranslate(
                                                          'Remove Item'),
                                                      style: TextStyle(
                                                        fontSize:
                                                            getMediumFontSize,
                                                        color: dataGridController
                                                                    .selectedIndex ==
                                                                -1
                                                            ? Colors.grey[400]
                                                            : const Color
                                                                .fromARGB(255,
                                                                255, 255, 255),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                onPressed: () {
                                                  if (dataGridController
                                                      .selectedRows
                                                      .isNotEmpty) {
                                                    for (var r
                                                        in dataGridController
                                                            .selectedRows) {
                                                      String b = r
                                                          .getCells()
                                                          .firstWhere((e) =>
                                                              e.columnName ==
                                                              'barcode')
                                                          .value;
                                                      int index =
                                                          selectedLocalReceiptData
                                                              .indexWhere((e) =>
                                                                  e.barcode ==
                                                                  b);
                                                      if (index != -1) {
                                                        selectedLocalReceiptData
                                                            .removeAt(index);
                                                      }
                                                    }
                                                    dataGridController
                                                        .selectedRows = [];
                                                    var box =
                                                        Hive.box('bitpro_app');

                                                    box.put(
                                                        'receipt_data',
                                                        selectedLocalReceiptData
                                                            .map((e) =>
                                                                e.toMap())
                                                            .toList());
                                                    receiptDataSource =
                                                        ReceiptDataSource(
                                                            selectedLocalReceiptData,
                                                            userMaxDiscount,
                                                            context);

                                                    setState(() {});
                                                    scanBarcodeFocusNode
                                                        .requestFocus();
                                                  }
                                                },
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
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4))),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Image.asset(
                                                    'assets/icons/export.png',
                                                    width: 20,
                                                  ),
                                                  const SizedBox(
                                                    width: 8,
                                                  ),
                                                  Text(
                                                    staticTextTranslate(
                                                        'Exports'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              onPressed: () async {
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
                                              },
                                            ),
                                          ),
                                          if (!viewMode)
                                            SizedBox(
                                              height: 40,
                                              width: 170,
                                              child: TextButton(
                                                style: TextButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4))),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Image.asset(
                                                      'assets/icons/import.png',
                                                      width: 18,
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      staticTextTranslate(
                                                          'Imports Items'),
                                                      style: TextStyle(
                                                        fontSize:
                                                            getMediumFontSize,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                onPressed: () {
                                                  showImportDialog();
                                                },
                                              ),
                                            ),
                                          if (viewMode)
                                            SizedBox(
                                              height: 40,
                                              width: 170,
                                              child: TextButton(
                                                style: TextButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4))),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Image.asset(
                                                      'assets/icons/print.png',
                                                      width: 18,
                                                    ),
                                                    const SizedBox(
                                                      width: 13,
                                                    ),
                                                    Text(
                                                      staticTextTranslate(
                                                          'Print'),
                                                      style: TextStyle(
                                                        fontSize:
                                                            getMediumFontSize,
                                                        color:
                                                            selectedLocalReceiptData
                                                                    .isEmpty
                                                                ? Colors
                                                                    .grey[400]
                                                                : Colors
                                                                    .grey[600],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                onPressed: () {
                                                  printAndUploadOnTap(
                                                      printOnly: true);
                                                },
                                              ),
                                            ),
                                          SizedBox(
                                            height: 40,
                                            width: 170,
                                            child: TextButton(
                                                style: TextButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4))),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Image.asset(
                                                      'assets/icons/tag.png',
                                                      width: 18,
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      staticTextTranslate(
                                                          'Print Tag'),
                                                      style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
                                                          fontFamily: 'arabicf',
                                                          color: dataGridController
                                                                      .selectedRow ==
                                                                  null
                                                              ? Colors.grey[600]
                                                              : Colors.white),
                                                    )
                                                  ],
                                                ),
                                                onPressed: () {
                                                  if (dataGridController
                                                          .selectedRow !=
                                                      null) {
                                                    String
                                                        selectedBarcodeValue =
                                                        '';
                                                    for (var c
                                                        in dataGridController
                                                            .selectedRow!
                                                            .getCells()) {
                                                      if (c.columnName ==
                                                          'barcode') {
                                                        selectedBarcodeValue =
                                                            c.value;
                                                      }
                                                    }

                                                    List<PrintTagData>
                                                        allPrintTagDataLst =
                                                        selectedLocalReceiptData
                                                            .map((e) {
                                                      int ohQty = -1;
                                                      String priceWT = '';
                                                      for (InventoryData inv
                                                          in allInventoryDataLst) {
                                                        if (inv.barcode ==
                                                            e.barcode) {
                                                          ohQty = int.tryParse(inv
                                                                      .ohQtyForDifferentStores[
                                                                  selectedStoreData
                                                                      .docId]) ??
                                                              0;
                                                          priceWT = inv.priceWT;
                                                        }
                                                      }
                                                      return PrintTagData(
                                                          barcodeValue:
                                                              e.barcode,
                                                          docQty: int.tryParse(
                                                                  e.qty) ??
                                                              0,
                                                          itemCode: e.itemCode,
                                                          productName:
                                                              e.productName,
                                                          onHandQty: ohQty,
                                                          priceWt: priceWT);
                                                    }).toList();
                                                    int i = allPrintTagDataLst
                                                        .indexWhere((element) =>
                                                            element
                                                                .barcodeValue ==
                                                            selectedBarcodeValue);
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
                                                }),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          SizedBox(
                                            height: 40,
                                            width: 170,
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4))),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Image.asset(
                                                    'assets/icons/reference.png',
                                                    width: 18,
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    staticTextTranslate(
                                                        'Reference no'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              onPressed: () {
                                                String ref = referenceNo;
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return StatefulBuilder(
                                                          builder: (context,
                                                              setState2) {
                                                        return Dialog(
                                                          child: SizedBox(
                                                            height: 220,
                                                            width: 300,
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                  width: double
                                                                      .maxFinite,
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          18,
                                                                      vertical:
                                                                          10),
                                                                  decoration: const BoxDecoration(
                                                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                                                                      gradient: LinearGradient(
                                                                          end: Alignment.bottomCenter,
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
                                                                          begin: Alignment.topCenter)),
                                                                  child: Text(
                                                                      staticTextTranslate(
                                                                          'Reference no'),
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            getMediumFontSize +
                                                                                5,
                                                                      )),
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      SizedBox(
                                                                        width:
                                                                            250,
                                                                        child: TextFormField(
                                                                            autofocus: true,
                                                                            initialValue: referenceNo,
                                                                            enabled: !viewMode,
                                                                            style: const TextStyle(fontSize: 16),
                                                                            decoration: const InputDecoration(isDense: true, hintText: 'Reference No.', contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15), border: OutlineInputBorder()),
                                                                            onChanged: (val) {
                                                                              if (val.isNotEmpty) {
                                                                                setState(() {
                                                                                  ref = val;
                                                                                });
                                                                                setState2(() {});
                                                                              }
                                                                            }),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .bottomCenter,
                                                                    child: Container(
                                                                        width: 800,
                                                                        decoration: const BoxDecoration(color: Color(0xffdddfe8), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(6), bottomRight: Radius.circular(6))),
                                                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
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
                                                                                45,
                                                                            width:
                                                                                130,
                                                                            child: ElevatedButton(
                                                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                                                                                onPressed: () {
                                                                                  Navigator.pop(context);
                                                                                  referenceNo = ref;
                                                                                  setState(() {});
                                                                                  setState2(() {});
                                                                                },
                                                                                child: Text(staticTextTranslate('Save'),
                                                                                    style: TextStyle(
                                                                                      fontSize: getMediumFontSize,
                                                                                    ))),
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                45,
                                                                            width:
                                                                                130,
                                                                            child: ElevatedButton(
                                                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                                                                                onPressed: () {
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                child: Text(
                                                                                  staticTextTranslate('Cancel'),
                                                                                  style: TextStyle(fontSize: getMediumFontSize, color: Colors.black),
                                                                                )),
                                                                          ),
                                                                        ])))
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      });
                                                    });
                                              },
                                            ),
                                          ),
                                          if (!viewMode)
                                            SizedBox(
                                              height: 40,
                                              width: 170,
                                              child: TextButton(
                                                style: TextButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4))),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Image.asset(
                                                      'assets/icons/update.png',
                                                      width: 20,
                                                    ),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    Text(
                                                      staticTextTranslate(
                                                          'Update Only'),
                                                      style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
                                                          color: selectedLocalReceiptData
                                                                      .isNotEmpty &&
                                                                  double.parse(
                                                                          calculateDueAmount()) ==
                                                                      0
                                                              ? const Color
                                                                  .fromARGB(
                                                                  255, 0, 0, 0)
                                                              : Colors
                                                                  .grey[500]),
                                                    ),
                                                  ],
                                                ),
                                                onPressed: () =>
                                                    printAndUploadOnTap(
                                                        updateOnly: true),
                                              ),
                                            ),
                                          const SizedBox(
                                            width: 0,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
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
                                                          450
                                                      : 700,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height -
                                                      50,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: Container(
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            border: Border.all(
                                                                width: 0.5),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4)),
                                                        child: loading
                                                            ? showLoading()
                                                            : Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Container(
                                                                    decoration: const BoxDecoration(
                                                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                                                                        gradient: LinearGradient(
                                                                            end: Alignment.bottomCenter,
                                                                            colors: [
                                                                              Color.fromARGB(255, 180, 180, 180),
                                                                              Color.fromARGB(255, 105, 105, 105),
                                                                            ],
                                                                            begin: Alignment.topCenter)),
                                                                    width: double
                                                                        .maxFinite,
                                                                    height: 120,
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .symmetric(
                                                                        horizontal:
                                                                            10,
                                                                        vertical:
                                                                            5,
                                                                      ),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(vertical: 0),
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Row(
                                                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                                                  children: [
                                                                                    filters(),
                                                                                    const SizedBox(
                                                                                      width: 10,
                                                                                    ),
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
                                                                                      margin: const EdgeInsets.only(top: 0),
                                                                                      child: ElevatedButton(
                                                                                          style: ElevatedButton.styleFrom(
                                                                                            elevation: 0,
                                                                                            padding: const EdgeInsets.all(0),
                                                                                            backgroundColor: Colors.transparent,
                                                                                            shape: RoundedRectangleBorder(
                                                                                              borderRadius: BorderRadius.circular(4),
                                                                                            ),
                                                                                          ),
                                                                                          onPressed: () {
                                                                                            showSelectItemDialog();
                                                                                          },
                                                                                          child: const Icon(
                                                                                            Iconsax.d_cube_scan,
                                                                                            size: 19,
                                                                                            color: Colors.white,
                                                                                          )),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 0,
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    regularReturnFilter(),
                                                                                    const SizedBox(
                                                                                      width: 10,
                                                                                    ),
                                                                                    storeFilterWidget(),
                                                                                  ],
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              width: 120,
                                                                              height: 120,
                                                                              child: Card(
                                                                                  shape: RoundedRectangleBorder(side: const BorderSide(width: 0.5, color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                                                                                  elevation: 0,
                                                                                  color: Colors.white,
                                                                                  child:
                                                                                      // getLastItemImagePath()
                                                                                      selectedProductImg.isNotEmpty
                                                                                          ? Padding(
                                                                                              padding: const EdgeInsets.all(10.0),
                                                                                              child: Image.file(File(selectedProductImg)),
                                                                                            )
                                                                                          : const Icon(
                                                                                              Icons.image,
                                                                                              size: 40,
                                                                                              color: Color.fromARGB(255, 196, 196, 196),
                                                                                            ))),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        Container(
                                                                      margin: const EdgeInsets
                                                                          .all(
                                                                          6),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                              border: Border.all(width: 0.3)),
                                                                      child:
                                                                          SfDataGridTheme(
                                                                        data: SfDataGridThemeData(
                                                                            headerColor:
                                                                                const Color(0xffF1F1F1),
                                                                            sortIcon: const Icon(Icons.arrow_drop_down_rounded),
                                                                            headerHoverColor: const Color(0xffdddfe8),
                                                                            selectionColor: loginBgColor),
                                                                        child:
                                                                            SfDataGrid(
                                                                          isScrollbarAlwaysShown:
                                                                              true,
                                                                          onQueryRowHeight:
                                                                              (details) {
                                                                            // Set the row height as 70.0 to the column header row.
                                                                            return details.rowIndex == 0
                                                                                ? 25.0
                                                                                : 25.0;
                                                                          },
                                                                          rowHeight:
                                                                              25,
                                                                          headerRowHeight:
                                                                              25,
                                                                          headerGridLinesVisibility:
                                                                              GridLinesVisibility.both,
                                                                          allowSorting:
                                                                              true,
                                                                          allowTriStateSorting:
                                                                              true,
                                                                          controller:
                                                                              dataGridController,
                                                                          source:
                                                                              receiptDataSource!,
                                                                          editingGestureType:
                                                                              EditingGestureType.tap,
                                                                          selectionMode:
                                                                              SelectionMode.single,
                                                                          columnWidthMode:
                                                                              ColumnWidthMode.lastColumnFill,
                                                                          onSelectionChanging:
                                                                              (addedRows, removedRows) {
                                                                            setState(() {});
                                                                            return true;
                                                                          },
                                                                          onSelectionChanged:
                                                                              (addedRows, removedRows) {
                                                                            setState(() {
                                                                              for (var v in addedRows.first.getCells()) {
                                                                                if (v.columnName == 'barcode') {
                                                                                  for (var inv in allInventoryDataLst) {
                                                                                    if (inv.barcode == v.value) {
                                                                                      if (File(inv.productImg).existsSync()) {
                                                                                        selectedProductImg = inv.productImg;
                                                                                      } else {
                                                                                        selectedProductImg = '';
                                                                                      }
                                                                                    }
                                                                                  }
                                                                                }
                                                                              }
                                                                            });
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
                                                                                      style: GoogleFonts.roboto(
                                                                                        fontSize: getMediumFontSize + 1,
                                                                                      ),
                                                                                    ))),
                                                                            GridColumn(
                                                                                allowEditing: false,
                                                                                columnName: 'barcode',
                                                                                label: Container(
                                                                                    padding: const EdgeInsets.all(1.0),
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
                                                                                    padding: const EdgeInsets.all(1.0),
                                                                                    alignment: Alignment.center,
                                                                                    child: Text(
                                                                                      staticTextTranslate('Item Code'),
                                                                                      style: GoogleFonts.roboto(
                                                                                        fontSize: getMediumFontSize + 1,
                                                                                      ),
                                                                                    ))),
                                                                            GridColumn(
                                                                                maximumWidth: 300,
                                                                                allowEditing: false,
                                                                                columnName: 'productName',
                                                                                label: Container(
                                                                                    padding: const EdgeInsets.all(1.0),
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
                                                                                    padding: const EdgeInsets.all(1.0),
                                                                                    alignment: Alignment.center,
                                                                                    child: Text(
                                                                                      staticTextTranslate('Qty'),
                                                                                      style: GoogleFonts.roboto(
                                                                                        fontSize: getMediumFontSize + 1,
                                                                                      ),
                                                                                    ))),
                                                                            GridColumn(
                                                                                allowEditing: false,
                                                                                columnName: 'orgPrice',
                                                                                label: Container(
                                                                                    padding: const EdgeInsets.all(1.0),
                                                                                    alignment: Alignment.center,
                                                                                    child: Text(
                                                                                      staticTextTranslate('Org. Price'),
                                                                                      style: GoogleFonts.roboto(
                                                                                        fontSize: getMediumFontSize + 1,
                                                                                      ),
                                                                                    ))),
                                                                            GridColumn(
                                                                                width: 120,
                                                                                allowEditing: true,
                                                                                columnName: 'discount_percentage',
                                                                                label: Container(
                                                                                    padding: const EdgeInsets.all(1.0),
                                                                                    alignment: Alignment.center,
                                                                                    child: Text(
                                                                                      staticTextTranslate('Discount %'),
                                                                                      style: GoogleFonts.roboto(
                                                                                        fontSize: getMediumFontSize + 1,
                                                                                      ),
                                                                                    ))),
                                                                            GridColumn(
                                                                                allowEditing: true,
                                                                                columnName: 'discount',
                                                                                label: Container(
                                                                                    padding: const EdgeInsets.all(1.0),
                                                                                    alignment: Alignment.center,
                                                                                    child: Text(
                                                                                      staticTextTranslate('Discount \$'),
                                                                                      style: GoogleFonts.roboto(
                                                                                        fontSize: getMediumFontSize + 1,
                                                                                      ),
                                                                                    ))),
                                                                            GridColumn(
                                                                                allowEditing: true,
                                                                                columnName: 'priceWT',
                                                                                label: Container(
                                                                                    padding: const EdgeInsets.all(1.0),
                                                                                    alignment: Alignment.center,
                                                                                    child: Text(
                                                                                      staticTextTranslate('Price W/T'),
                                                                                      style: GoogleFonts.roboto(
                                                                                        fontSize: getMediumFontSize + 1,
                                                                                      ),
                                                                                    ))),
                                                                            GridColumn(
                                                                                allowEditing: false,
                                                                                columnName: 'total',
                                                                                label: Container(
                                                                                    padding: const EdgeInsets.all(1.0),
                                                                                    alignment: Alignment.center,
                                                                                    child: Text(
                                                                                      staticTextTranslate('Total'),
                                                                                      style: GoogleFonts.roboto(
                                                                                        fontSize: getMediumFontSize + 1,
                                                                                      ),
                                                                                    ))),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 275,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height -
                                                      56,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 5),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              border:
                                                                  Border.all(
                                                                      width:
                                                                          0.3),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                              color:
                                                                  Colors.white),
                                                          child: Column(
                                                            children: [
                                                              Container(
                                                                height: 35,
                                                                width: double
                                                                    .maxFinite,
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        15,
                                                                    vertical:
                                                                        5),
                                                                decoration: const BoxDecoration(
                                                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                                                                    gradient: LinearGradient(
                                                                        end: Alignment.bottomCenter,
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
                                                                        begin: Alignment.topCenter)),
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                      'Customer Details',
                                                                      style: GoogleFonts.roboto(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color:
                                                                              Colors.white),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        10),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Flexible(
                                                                          child:
                                                                              SizedBox(
                                                                            height:
                                                                                35,
                                                                            child: viewMode
                                                                                ? Container(
                                                                                    width: double.maxFinite,
                                                                                    decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(2)),
                                                                                    child: Row(
                                                                                      children: [
                                                                                        const SizedBox(width: 10),
                                                                                        Flexible(child: Text(_searchCustomerTypeAheadController.text, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: getMediumFontSize))),
                                                                                      ],
                                                                                    ),
                                                                                  )
                                                                                : TypeAheadFormField(
                                                                                    getImmediateSuggestions: false,
                                                                                    textFieldConfiguration: TextFieldConfiguration(
                                                                                      style: GoogleFonts.roboto(color: const Color.fromARGB(255, 0, 0, 0), fontSize: getMediumFontSize + 2),
                                                                                      controller: _searchCustomerTypeAheadController,
                                                                                      decoration: InputDecoration(
                                                                                        hintText: staticTextTranslate('Search customer'),
                                                                                        hintStyle: GoogleFonts.roboto(color: Colors.grey[600], fontSize: getMediumFontSize + 2),
                                                                                        contentPadding: const EdgeInsets.only(left: 10, right: 5, bottom: 3),
                                                                                        border: const OutlineInputBorder(),
                                                                                      ),
                                                                                    ),
                                                                                    noItemsFoundBuilder: (context) {
                                                                                      return Padding(
                                                                                        padding: const EdgeInsets.all(10.0),
                                                                                        child: Text(staticTextTranslate('No Items Found!'), style: TextStyle(fontSize: getMediumFontSize)),
                                                                                      );
                                                                                    },
                                                                                    suggestionsCallback: (pattern) {
                                                                                      return customerDataLst.where((e) => e.customerName.toLowerCase().contains(pattern.toLowerCase())).toList();
                                                                                    },
                                                                                    itemBuilder: (context, CustomerData suggestion) {
                                                                                      return ListTile(
                                                                                        title: Text(suggestion.customerName, style: TextStyle(fontSize: getMediumFontSize)),
                                                                                      );
                                                                                    },
                                                                                    transitionBuilder: (context, suggestionsBox, controller) {
                                                                                      return suggestionsBox;
                                                                                    },
                                                                                    onSuggestionSelected: (CustomerData e) {
                                                                                      selectedCustomerData = e;
                                                                                      _searchCustomerTypeAheadController.text = e.customerName;

                                                                                      setState(() {});
                                                                                    },
                                                                                  ),
                                                                          ),
                                                                        ),
                                                                        if (viewMode ==
                                                                            false)
                                                                          const SizedBox(
                                                                            width:
                                                                                10,
                                                                          ),
                                                                        if (viewMode ==
                                                                            false)
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
                                                                                35,
                                                                            width:
                                                                                35,
                                                                            child: ElevatedButton(
                                                                                style: ElevatedButton.styleFrom(
                                                                                  elevation: 0,
                                                                                  padding: const EdgeInsets.all(0),
                                                                                  backgroundColor: Colors.transparent,
                                                                                  shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(
                                                                                    4,
                                                                                  )),
                                                                                ),
                                                                                onPressed: () async {
                                                                                  showAddCustomerDialog();
                                                                                },
                                                                                child: const Icon(
                                                                                  Iconsax.add_circle,
                                                                                  size: 19,
                                                                                )),
                                                                          ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    Text(
                                                                      staticTextTranslate(
                                                                              'Name') +
                                                                          ' : ${selectedCustomerData != null ? selectedCustomerData!.customerName : ''}',
                                                                      style: GoogleFonts.roboto(
                                                                          fontSize: getMediumFontSize +
                                                                              1,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Text(
                                                                      staticTextTranslate(
                                                                              'Phone') +
                                                                          ' : ${selectedCustomerData != null ? selectedCustomerData!.phone1 : ''}',
                                                                      style: GoogleFonts.roboto(
                                                                          fontSize: getMediumFontSize +
                                                                              1,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Text(
                                                                      staticTextTranslate(
                                                                              'Address') +
                                                                          ' : ${selectedCustomerData != null ? selectedCustomerData!.address1 : ''}',
                                                                      style: GoogleFonts.roboto(
                                                                          fontSize: getMediumFontSize +
                                                                              1,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          width:
                                                              double.maxFinite,
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                width: 0.5),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                          ),
                                                          child: const Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [],
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            border: Border.all(
                                                                width: 0.5),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4)),
                                                        width: 300,
                                                        child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                height: 35,
                                                                width: double
                                                                    .maxFinite,
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        15,
                                                                    vertical:
                                                                        5),
                                                                decoration: const BoxDecoration(
                                                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                                                                    gradient: LinearGradient(
                                                                        end: Alignment.bottomCenter,
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
                                                                        begin: Alignment.topCenter)),
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                      'Totals',
                                                                      style: GoogleFonts.roboto(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color:
                                                                              Colors.white),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        10.0),
                                                                child: Column(
                                                                  children: [
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          staticTextTranslate(
                                                                              'Total Qty.'),
                                                                          style: GoogleFonts.roboto(
                                                                              fontSize: getMediumFontSize + 1,
                                                                              fontWeight: FontWeight.w500),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              0,
                                                                        ),
                                                                        Text(
                                                                          calculateTotalQty(),
                                                                          style: GoogleFonts.roboto(
                                                                              fontSize: getMediumFontSize + 1,
                                                                              fontWeight: FontWeight.w500),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          staticTextTranslate(
                                                                              'Discount %'),
                                                                          style: GoogleFonts.roboto(
                                                                              fontSize: getMediumFontSize + 1,
                                                                              fontWeight: FontWeight.w500),
                                                                        ),
                                                                        Text(
                                                                          calculateDiscountPercentage(),
                                                                          style: GoogleFonts.roboto(
                                                                              fontSize: getMediumFontSize + 1,
                                                                              fontWeight: FontWeight.w500),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          staticTextTranslate(
                                                                              'Discount \$'),
                                                                          style: GoogleFonts.roboto(
                                                                              fontSize: getMediumFontSize + 1,
                                                                              fontWeight: FontWeight.w500),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              0,
                                                                        ),
                                                                        Text(
                                                                          calculateTotalDiscountValue(),
                                                                          style: GoogleFonts.roboto(
                                                                              fontSize: getMediumFontSize + 1,
                                                                              fontWeight: FontWeight.w500),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          staticTextTranslate(
                                                                              'Total before Tax'),
                                                                          style: GoogleFonts.roboto(
                                                                              fontSize: getMediumFontSize + 1,
                                                                              fontWeight: FontWeight.w500),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              0,
                                                                        ),
                                                                        Text(
                                                                          calculateTotalBeforeTax(),
                                                                          style: GoogleFonts.roboto(
                                                                              fontSize: getMediumFontSize + 1,
                                                                              fontWeight: FontWeight.w500),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          tax.isEmpty
                                                                              ? staticTextTranslate('Tax')
                                                                              : '${staticTextTranslate("Tax")} ($tax%)',
                                                                          style: GoogleFonts.roboto(
                                                                              fontSize: getMediumFontSize + 1,
                                                                              fontWeight: FontWeight.w500),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              0,
                                                                        ),
                                                                        Text(
                                                                          tax.isEmpty
                                                                              ? '0'
                                                                              : calculateTaxValue(),
                                                                          style: GoogleFonts.roboto(
                                                                              fontSize: getMediumFontSize + 1,
                                                                              fontWeight: FontWeight.w500),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Text(
                                                                      staticTextTranslate(
                                                                          '---------------------------------------------------'),
                                                                      style: GoogleFonts.roboto(
                                                                          fontSize: getMediumFontSize +
                                                                              1,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          staticTextTranslate(
                                                                              'TOTAL'),
                                                                          style: GoogleFonts.roboto(
                                                                              fontSize: getMediumFontSize + 3,
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              6,
                                                                        ),
                                                                        Text(
                                                                          regularReturnDropDown == 'Regular'
                                                                              ? calculateReceiptTotal()
                                                                              : '-${calculateReceiptTotal()}',
                                                                          style: GoogleFonts.roboto(
                                                                              fontSize: getExtraLargeFontSize + 3,
                                                                              color: regularReturnDropDown == 'Regular' ? Colors.black : Colors.red[800],
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
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
                                                                          style: ElevatedButton.styleFrom(backgroundColor: viewMode ? Colors.grey : Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                                                                          onPressed: () {
                                                                            if (!viewMode) {
                                                                              tenderDialog();
                                                                            }
                                                                          },
                                                                          child: Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              const Icon(
                                                                                Iconsax.money_2,
                                                                                size: 20,
                                                                              ),
                                                                              const SizedBox(
                                                                                width: 10,
                                                                              ),
                                                                              Text(staticTextTranslate('Tender'), style: TextStyle(fontSize: getMediumFontSize)),
                                                                            ],
                                                                          )),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            ]),
                                                      ),
                                                    ],
                                                  ),
                                                ),
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

  showAddCustomerDialog() async {
    String newCustomerId = await getIdNumber(customerDataLst.length + 1);
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: CustomerCreateEditPage(
              newCustomerId: newCustomerId,
              hideCustomTab: true,
              userData: widget.userData,
              customerDataLst: customerDataLst),
        );
      },
    );

    customerDataLst =
        await FbCustomerDbService(context: context).fetchAllCustomersData();
    setState(() {});
  }

  printAndUploadOnTap({bool updateOnly = false, bool printOnly = false}) async {
    if (selectedLocalReceiptData.isNotEmpty &&
        double.parse(calculateDueAmount()) == 0) {
      setState(() {
        uploading = true;
      });

      DbReceiptData dbReceiptData = DbReceiptData(
        referenceNo: referenceNo,
        selectedStoreDocId: selectedStoreData.docId,
        receiptType: regularReturnDropDown,
        taxPer: tax,
        taxValue: calculateTaxValue(),
        totalQty: calculateTotalQty(),
        receiptNo: widget.currentReceiptId,
        createdBy: createdBy,
        docId: getRandomString(20),
        selectedItems: selectedLocalReceiptData
            .map((e) => {
                  'cost': e.cost,
                  'barcode': e.barcode,
                  'itemCode': e.itemCode,
                  'productName': e.productName,
                  'qty': e.qty,
                  'orgPrice': e.orgPrice,
                  'discountValue': e.discountValue,
                  'discountPercentage': e.discountPercentage,
                  'priceWt': e.priceWt,
                  'total': e.total
                })
            .toList(),
        selectedCustomerID: selectedCustomerData == null
            ? ''
            : selectedCustomerData!.customerId,
        discountPercentage: calculateDiscountPercentage(),
        discountValue: calculateTotalDiscountValue(),
        createdDate: DateTime.now(),
        //
        receiptTotal: calculateReceiptTotal(),
        allPaymentMethodAmountsInfo: allPaymentMethodAmountsInfo,
        receiptBalance: calculateBalanceAmount(),
        receiptDue: calculateDueAmount(),
      );

      //change window calculations
      bool showChangeWindow = true; // cash != '0' ? true : false;
      String tenered = calculateTenderedAmount();
      String receiptTotal = calculateReceiptTotal();
      String change = regularReturnDropDown == 'Regular'
          ? calculateBalanceAmount()
          : receiptTotal;

      //printing
      if (updateOnly == false) {
        await printReceipt(context, dbReceiptData, calculateTaxValue(),
            selectedCustomerData, tenered, change);
      }

      if (printOnly == false) {
        //saving receipt
        await FbReceiptDbService(context: context).addUpdateReceipt(
            receiptDataLst: [dbReceiptData],
            allInventoryDataLst: allInventoryDataLst);

        //resetting data
        scanBarcodeFocusNode.requestFocus();
        selectedCustomerData = null;
        _searchCustomerTypeAheadController.clear();
        selectedLocalReceiptData = [];
        allPaymentMethodAmountsInfo = {};
        receiptDataSource =
            ReceiptDataSource([], widget.userData.maxDiscount, context);
        referenceNo = '';
        var box = Hive.box('bitpro_app');
        box.put('receipt_data', []);
        regularReturnDropDown = 'Regular';
        if (showChangeWindow) {
          changeWindowDialog(receiptTotal, tenered, change);
        }
      }
      setState(() {
        uploading = false;
        if (printOnly == false) {
          reloadDataOnPop = true;
        }
      });
    }
  }

  changeWindowDialog(String subtotal, String tendered, String change) {
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(builder: (context2, setState2) {
              return Shortcuts(
                shortcuts: <LogicalKeySet, Intent>{
                  LogicalKeySet(LogicalKeyboardKey.enter):
                      const ReceiptCallbackShortcutsIntent(
                          name: 'changeWindowDialogEnter'),
                },
                child: Actions(
                  actions: <Type, Action<Intent>>{
                    ReceiptCallbackShortcutsIntent:
                        CallbackAction<ReceiptCallbackShortcutsIntent>(
                            onInvoke: (ReceiptCallbackShortcutsIntent intent) {
                      if (!viewMode) {
                        Navigator.pop(context2);
                      }
                      return;
                    }),
                  },
                  child: Focus(
                    autofocus: true,
                    child: Dialog(
                        backgroundColor: homeBgColor,
                        child: SizedBox(
                            height: 220,
                            width: 530,
                            child: Column(children: [
                              Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Card(
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 28.0,
                                                      vertical: 10),
                                              child: SizedBox(
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                    Text(
                                                        staticTextTranslate(
                                                            'Change Window'),
                                                        style: TextStyle(
                                                            fontSize:
                                                                getMediumFontSize)),
                                                    const SizedBox(
                                                      height: 15,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                staticTextTranslate(
                                                                    'TOTAL'),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        getMediumFontSize)),
                                                            Text(subtotal,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        getExtraLargeFontSize +
                                                                            2,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                          ],
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                staticTextTranslate(
                                                                    'TENDERED'),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        getMediumFontSize)),
                                                            Text(tendered,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        getExtraLargeFontSize +
                                                                            2,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                          ],
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              staticTextTranslate(
                                                                  'CHANGE'),
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      getMediumFontSize,
                                                                  color: Colors
                                                                      .green),
                                                            ),
                                                            Text(change,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        getExtraLargeFontSize +
                                                                            2,
                                                                    color: Colors
                                                                        .green,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                          ],
                                                        )
                                                      ],
                                                    )
                                                  ])))))),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  width: 530,
                                  decoration: const BoxDecoration(
                                      color: Color(0xffdddfe8),
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(6),
                                          bottomRight: Radius.circular(6))),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 42,
                                        width: 510,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: darkBlueColor,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4))),
                                            onPressed: () =>
                                                Navigator.pop(context2),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Iconsax.archive,
                                                  size: 20,
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Text(staticTextTranslate('OK'),
                                                    style: TextStyle(
                                                        fontSize:
                                                            getMediumFontSize)),
                                              ],
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ]))),
                  ),
                ),
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
                    height: 380,
                    width: 500,
                    child: dialogLoading
                        ? showLoading()
                        : Column(children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    // height: 55,
                                    width: double.maxFinite,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 10),
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(4),
                                            topRight: Radius.circular(4)),
                                        gradient: LinearGradient(
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Color.fromARGB(255, 66, 66, 66),
                                              Color.fromARGB(255, 0, 0, 0),
                                            ],
                                            begin: Alignment.topCenter)),
                                    child: Text(
                                      staticTextTranslate('Product Import'),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: getMediumFontSize + 5,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 15),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                  staticTextTranslate(
                                                      'Download Sample file here.'),
                                                  style: TextStyle(
                                                    fontSize: getMediumFontSize,
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
                                                      decoration: TextDecoration
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
                                              Text(staticTextTranslate('File'),
                                                  style: TextStyle(
                                                    fontSize: getMediumFontSize,
                                                  )),
                                              const SizedBox(
                                                width: 30,
                                              ),
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              3),
                                                      border: Border.all(
                                                          color: Colors.grey)),
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
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                                      await FilePicker.platform
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
                                                      result.paths.isNotEmpty) {
                                                    importItem = File(
                                                        result.paths.first!);
                                                    var bytes = File(result
                                                            .files.first.path!)
                                                        .readAsBytesSync();
                                                    var excel =
                                                        Excel.decodeBytes(
                                                            bytes);

                                                    uploadRes =
                                                        localReceiptDataFromExcel(
                                                            excel,
                                                            allInventoryDataLst);
                                                  }
                                                  setState(() {
                                                    dialogLoading = false;
                                                  });
                                                  setState2(() {});
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              3),
                                                      border: Border.all(
                                                          color: Colors.grey)),
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
                                                  : '${staticTextTranslate("Items Found")} : ${uploadRes['localVoucherDataLst'].length}',
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
                                                    fontSize: getMediumFontSize,
                                                  )),
                                              Text(
                                                uploadRes.isNotEmpty
                                                    ? '${uploadRes['dublicate']} ${staticTextTranslate("Duplicate items found")}'
                                                    : staticTextTranslate(
                                                        '0 Duplicate items found'),
                                                style: TextStyle(
                                                    fontSize: getMediumFontSize,
                                                    color: Colors.red[700]),
                                              ),
                                            ],
                                          ),
                                        ]),
                                  ),
                                ],
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
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          gradient: uploadRes.isEmpty ||
                                                  uploadRes['localVoucherDataLst']
                                                          .length ==
                                                      0
                                              ? null
                                              : const LinearGradient(
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Color(0xff092F53),
                                                    Color(0xff284F70),
                                                  ],
                                                  begin: Alignment.topCenter)),
                                      height: 42,
                                      width: 133,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: uploadRes
                                                          .isEmpty ||
                                                      uploadRes['localVoucherDataLst']
                                                              .length ==
                                                          0
                                                  ? Colors.grey
                                                  : Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4))),
                                          onPressed: () async {
                                            if (uploadRes.isNotEmpty &&
                                                uploadRes['localVoucherDataLst']
                                                        .length !=
                                                    0) {
                                              setState(() {
                                                dialogLoading = true;
                                              });
                                              setState2(() {});

                                              selectedLocalReceiptData.addAll(
                                                  uploadRes[
                                                      'localVoucherDataLst']);
                                              var box = Hive.box('bitpro_app');

                                              await box.put(
                                                  'receipt_data',
                                                  selectedLocalReceiptData
                                                      .map((e) => e.toMap())
                                                      .toList());
                                              receiptDataSource =
                                                  ReceiptDataSource(
                                                      selectedLocalReceiptData,
                                                      widget
                                                          .userData.maxDiscount,
                                                      context);
                                              Navigator.pop(context);

                                              setState(() {
                                                dialogLoading = false;
                                              });
                                              setState2(() {});
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
                                  ],
                                ),
                              ),
                            )
                          ])),
              );
            }));
  }

  String calculateDueAmount() {
    double t = double.parse(calculateReceiptTotal());

    double tenderedAmt = double.parse(calculateTenderedAmount());

    if (tenderedAmt < t) {
      return (t - tenderedAmt).toStringAsFixed(2);
    } else {
      return '0';
    }
  }

  String calculateTenderedAmount() {
    double amt = 0;

    for (var v in allPaymentMethodAmountsInfo.values) {
      amt += double.parse(v);
    }

    return amt == 0 ? '0' : amt.toStringAsFixed(2);
  }

  String calculateBalanceAmount() {
    double totalAmt = double.parse(calculateReceiptTotal());
    double tenderedAmt = double.parse(calculateTenderedAmount());

    if (tenderedAmt > totalAmt) {
      return (tenderedAmt - totalAmt).toStringAsFixed(2);
    } else {
      return '0';
    }
  }

  tenderDialog() {
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(builder: (context2, setState2) {
              return Dialog(
                backgroundColor: homeBgColor,
                child: SizedBox(
                    height: 650,
                    width: 650,
                    child: Column(children: [
                      Container(
                        height: 50,
                        width: double.maxFinite,
                        padding: const EdgeInsets.all(15),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(3),
                              topRight: Radius.circular(3)),
                          gradient: LinearGradient(
                              end: Alignment.bottomCenter,
                              colors: [
                                Color.fromARGB(255, 66, 66, 66),
                                Color.fromARGB(255, 0, 0, 0),
                              ],
                              begin: Alignment.topCenter),
                        ),
                        child: Text(
                          'Tender Transaction',
                          style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.white),
                        ),
                      ),
                      Container(
                        height: 368,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Expanded(
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      height: 50,
                                      padding: const EdgeInsets.all(10),
                                      width: 240,
                                      decoration: BoxDecoration(
                                        border: Border.all(width: 0.4),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Take Due: ${calculateDueAmount()}',
                                        style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      width: 240,
                                      decoration: BoxDecoration(
                                        border: Border.all(width: 0.4),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: paymentTypeList.keys
                                                .map((e) =>
                                                    tendorPaymentMethodButton(
                                                        e, setState2))
                                                .toList()),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                    child: Container(
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 336,
                                        decoration: BoxDecoration(
                                          border: Border.all(width: 0.4),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Column(children: [
                                          Container(
                                            height: 35,
                                            width: double.maxFinite,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 7, horizontal: 10),
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(4),
                                                  topRight: Radius.circular(4)),
                                              gradient: LinearGradient(
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Color.fromARGB(
                                                        255, 66, 66, 66),
                                                    Color.fromARGB(
                                                        255, 0, 0, 0),
                                                  ],
                                                  begin: Alignment.topCenter),
                                            ),
                                            child: Text(
                                              'Payments',
                                              style: GoogleFonts.roboto(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 0,
                                          ),
                                          for (var infoKey
                                              in allPaymentMethodAmountsInfo
                                                  .keys)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                height: 50,
                                                width: double.maxFinite,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5,
                                                        horizontal: 10),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border:
                                                        Border.all(width: 0.4),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4)),
                                                child: Row(children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      border:
                                                          Border.all(width: 1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                      gradient:
                                                          const LinearGradient(
                                                              end: Alignment
                                                                  .bottomCenter,
                                                              colors: [
                                                                Color.fromARGB(
                                                                    255,
                                                                    207,
                                                                    39,
                                                                    39),
                                                                Color.fromARGB(
                                                                    255,
                                                                    133,
                                                                    14,
                                                                    14),
                                                              ],
                                                              begin: Alignment
                                                                  .topCenter),
                                                    ),
                                                    height: 40,
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent),
                                                      onPressed: () {
                                                        allPaymentMethodAmountsInfo
                                                            .remove(infoKey);
                                                        setState2(() {});
                                                      },
                                                      child: const Text('X'),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          infoKey,
                                                          style: GoogleFonts.roboto(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: const Color
                                                                  .fromARGB(255,
                                                                  0, 0, 0)),
                                                        ),
                                                        Text(
                                                          allPaymentMethodAmountsInfo[
                                                              infoKey],
                                                          style: GoogleFonts.roboto(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: const Color
                                                                  .fromARGB(255,
                                                                  0, 0, 0)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ]),
                                              ),
                                            ),
                                        ]),
                                      )
                                    ],
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: double.maxFinite,
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  width: 350,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Invoice Total",
                                        style: GoogleFonts.roboto(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                          height: 35,
                                          width: 150,
                                          alignment: Alignment.centerLeft,
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Colors.grey.shade400),
                                              borderRadius:
                                                  BorderRadius.circular(6)),
                                          child: Text(calculateReceiptTotal()))
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: 350,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Tendered Amount",
                                        style: GoogleFonts.roboto(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                          height: 35,
                                          width: 150,
                                          alignment: Alignment.centerLeft,
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Colors.grey.shade400),
                                              borderRadius:
                                                  BorderRadius.circular(6)),
                                          child:
                                              Text(calculateTenderedAmount()))
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: 350,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Balance",
                                        style: GoogleFonts.roboto(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                          height: 35,
                                          width: 150,
                                          alignment: Alignment.centerLeft,
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Colors.grey.shade400),
                                              borderRadius:
                                                  BorderRadius.circular(6)),
                                          child: Text(calculateBalanceAmount()))
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 62,
                        width: double.maxFinite,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(0),
                              topRight: Radius.circular(0)),
                          gradient: LinearGradient(
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.grey,
                                Colors.grey,
                              ],
                              begin: Alignment.topCenter),
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '',
                                style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white),
                              ),
                              Row(children: [
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
                                  width: 120,
                                  height: 42,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
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
                                  width: 120,
                                  height: 42,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      printAndUploadOnTap(updateOnly: true);
                                    },
                                    child: const Text('Update Only'),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
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
                                  height: 42,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      printAndUploadOnTap();
                                    },
                                    child: const Text('Print & Update'),
                                  ),
                                ),
                              ])
                            ]),
                      ),
                    ])),
              );
            }));
  }

  Widget tendorPaymentMethodButton(String key, setState2) {
    if (key == PaymentMethodKey().cash && paymentTypeList[key] != 0) {
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: const LinearGradient(
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xff092F53),
                  Color(0xff284F70),
                ],
                begin: Alignment.topCenter)),
        height: 42,
        width: 220,
        margin: const EdgeInsets.only(bottom: 10),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: viewMode ? Colors.grey : Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4))),
            onPressed: () async {
              String? amount = await showTendorAmountDialog(context,
                  paymentMathodKey: key,
                  previousAmt: allPaymentMethodAmountsInfo[key] ?? '0');
              allPaymentMethodAmountsInfo[key] = amount;
              setState2(() {});
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(staticTextTranslate('Cash'),
                    style: GoogleFonts.roboto(fontSize: getMediumFontSize)),
              ],
            )),
      );
    } else if (key == PaymentMethodKey().creditCard &&
        paymentTypeList[key] != 0) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: const LinearGradient(
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xff092F53),
                  Color(0xff284F70),
                ],
                begin: Alignment.topCenter)),
        height: 42,
        width: 220,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: viewMode ? Colors.grey : Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4))),
            onPressed: () async {
              String? amount = await showTendorAmountDialog(context,
                  paymentMathodKey: key,
                  previousAmt: allPaymentMethodAmountsInfo[key] ?? '0');
              allPaymentMethodAmountsInfo[key] = amount;
              setState2(() {});
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(staticTextTranslate('Credit Card'),
                    style: GoogleFonts.roboto(fontSize: getMediumFontSize)),
              ],
            )),
      );
    } else if (key == PaymentMethodKey().tamara && paymentTypeList[key] != 0) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: const LinearGradient(
                end: Alignment.bottomLeft,
                colors: [
                  Color.fromARGB(255, 211, 164, 8),
                  Color.fromARGB(255, 124, 27, 116),
                ],
                begin: Alignment.topCenter)),
        height: 42,
        width: 220,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: viewMode ? Colors.grey : Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4))),
            onPressed: () async {
              String? amount = await showTendorAmountDialog(context,
                  paymentMathodKey: key,
                  previousAmt: allPaymentMethodAmountsInfo[key] ?? '0');
              allPaymentMethodAmountsInfo[key] = amount;
              setState2(() {});
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/tamara.png',
                  width: 120,
                )
              ],
            )),
      );
    } else if (key == PaymentMethodKey().tabby && paymentTypeList[key] != 0) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: const LinearGradient(
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 30, 199, 171),
                  Color.fromARGB(255, 30, 199, 171),
                ],
                begin: Alignment.topCenter)),
        height: 42,
        width: 220,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: viewMode ? Colors.grey : Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4))),
            onPressed: () async {
              String? amount = await showTendorAmountDialog(context,
                  paymentMathodKey: key,
                  previousAmt: allPaymentMethodAmountsInfo[key] ?? '0');
              allPaymentMethodAmountsInfo[key] = amount;
              setState2(() {});
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/tabby.png',
                  width: 80,
                )
              ],
            )),
      );
    }
    return const SizedBox();
  }

  // String getLastItemImagePath() {
  //   if (selectedLocalReceiptData.isEmpty) return '';

  //   InventoryData? inv;

  //   try {
  //     inv = allInventoryDataLst.firstWhere(
  //         (e) => e.barcode == selectedLocalReceiptData.last.barcode);
  //   } catch (e) {}
  //   if (inv == null || !File(inv.productImg).existsSync()) {
  //     return '';
  //   } else {
  //     return inv.productImg;
  //   }
  // }

  String calculateTotalQty() {
    double t = 0;
    for (LocalReceiptData v in selectedLocalReceiptData) {
      t += double.tryParse(v.qty) ?? 0;
    }

    return t.round().toString();
  }

  String calculateDiscountPercentage() {
    if (selectedLocalReceiptData.isEmpty) return '0';
    double t = 0;
    double dist = 0;

    for (LocalReceiptData v in selectedLocalReceiptData) {
      t += (double.tryParse(v.orgPrice) ?? 0) * (double.tryParse(v.qty) ?? 0);
      dist += double.tryParse(v.discountValue) ?? 0;
    }
    double disPer = (dist * 100) / t;

    return disPer.toStringAsFixed(2);
  }

  String calculateTotalDiscountValue() {
    double dist = 0;

    for (LocalReceiptData v in selectedLocalReceiptData) {
      dist += double.parse(v.discountValue);
    }

    return dist.toStringAsFixed(2);
  }

  String calculateTaxValue() {
    if (widget.viewMode && widget.selectedDbReceiptData != null) {
      return widget.selectedDbReceiptData!.taxValue;
    }
    double t = 0;
    for (LocalReceiptData v in selectedLocalReceiptData) {
      double d = 0;
      d = double.tryParse(v.total) ?? 0;
      t += d;
    }
    double taxValue = 0;
    //tax

    if (tax.isNotEmpty) {
      double texPer = double.tryParse(tax) ?? 0;

      double tx = 1 + (texPer / 100);

      if (tx != 0) taxValue = t - (t / tx);
    }

    return taxValue.toStringAsFixed(2);
  }

  String calculateTotalBeforeTax() {
    double t = 0;
    for (LocalReceiptData v in selectedLocalReceiptData) {
      double d = 0;
      d = double.tryParse(v.total) ?? 0;
      t += d;
    }
    t = t - double.parse(calculateTaxValue());
    return t.toStringAsFixed(2);
  }

  String calculateReceiptTotal() {
    double t = 0;
    for (LocalReceiptData v in selectedLocalReceiptData) {
      double d = 0;
      d = double.tryParse(v.total) ?? 0;
      t += d;
    }

    return t.toStringAsFixed(2);
  }

  String calculateLinesItem() {
    int num = 0;
    for (LocalReceiptData v in selectedLocalReceiptData) {
      if (v.itemCode.isNotEmpty) num++;
    }
    return num.toString();
  }

  storeFilterWidget() {
    return Container(
        width: 220,
        height: 35,
        margin: const EdgeInsets.only(top: 10, bottom: 10),
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
              child: Text(staticTextTranslate(value.storeName),
                  style: TextStyle(fontSize: getMediumFontSize + 1)),
            );
          }).toList(),
          onChanged: widget.viewMode && widget.selectedDbReceiptData != null
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
        if (viewMode == false) const SizedBox(width: 0),
        Container(
            width: 220,
            height: 35,
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 0.5),
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(4)),
            padding: const EdgeInsets.only(right: 10, left: 10),
            child: DropdownButton<String>(
              isExpanded: true,
              value: regularReturnDropDown,
              underline: const SizedBox(),
              items: <String>['Regular', 'Return'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(staticTextTranslate(value),
                      style: TextStyle(fontSize: getMediumFontSize + 2)),
                );
              }).toList(),
              onChanged: widget.viewMode && widget.selectedDbReceiptData != null
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

  filters() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        children: [
          Container(
            width: 220,
            height: 35,
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(3)),
            padding: const EdgeInsets.only(right: 0, bottom: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  padding: const EdgeInsets.only(top: 3),
                  onPressed: () {
                    _scanOrEnterBarcodeTypeAheadController.clear();

                    setState(() {});
                  },
                  splashRadius: 1,
                  icon: _scanOrEnterBarcodeTypeAheadController.text.isEmpty
                      ? const Icon(Iconsax.scan_barcode, size: 19)
                      : Icon(Icons.clear,
                          size: 19,
                          color: _scanOrEnterBarcodeTypeAheadController
                                  .text.isEmpty
                              ? Colors.grey[600]
                              : Colors.black),
                ),
                Flexible(
                    child: TextFormField(
                  enabled: !viewMode,
                  focusNode: scanBarcodeFocusNode,
                  controller: _scanOrEnterBarcodeTypeAheadController,
                  onChanged: (val) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: staticTextTranslate('Scan or enter barcode'),
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    contentPadding: const EdgeInsets.only(bottom: 13, right: 5),
                    border: InputBorder.none,
                  ),
                  onFieldSubmitted: (val) {
                    List res = allInventoryDataLst
                        .where(
                            (e) => e.barcode.toLowerCase() == val.toLowerCase())
                        .toList();
                    if (res.isNotEmpty) {
                      InventoryData inv = res.first;

                      addSearcheSubmittedInvData(inv);
                      _scanOrEnterBarcodeTypeAheadController.clear();
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text(
                                    '${staticTextTranslate("No item with the barcode")} $val',
                                    style:
                                        TextStyle(fontSize: getMediumFontSize)),
                                actions: [
                                  TextButton(
                                      autofocus: true,
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(staticTextTranslate('ok'),
                                          style: TextStyle(
                                              fontSize: getMediumFontSize)))
                                ],
                              ));
                    }
                    scanBarcodeFocusNode.requestFocus();
                  },
                )),
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Container(
            width: 220,
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
                  padding: const EdgeInsets.only(top: 3),
                  onPressed: () {
                    _searchForItemsTypeAheadController.clear();

                    setState(() {});
                  },
                  splashRadius: 1,
                  icon: Icon(
                      _searchForItemsTypeAheadController.text.isEmpty
                          ? CupertinoIcons.search
                          : Icons.clear,
                      size: 18,
                      color: _searchForItemsTypeAheadController.text.isEmpty
                          ? Colors.grey[600]
                          : Colors.black),
                ),
                if (viewMode)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        staticTextTranslate('Search For Items'),
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
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _searchForItemsTypeAheadController,
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
                              style: TextStyle(fontSize: getMediumFontSize)),
                        );
                      },
                      suggestionsCallback: (pattern) {
                        return allInventoryDataLst
                            .where((e) =>
                                e.productName
                                    .toLowerCase()
                                    .contains(pattern.toLowerCase()) ||
                                e.barcode
                                    .toLowerCase()
                                    .contains(pattern.toLowerCase()))
                            .toList();
                      },
                      itemBuilder: (context, InventoryData suggestion) {
                        return ListTile(
                          title: Text(suggestion.productName,
                              style: TextStyle(fontSize: getMediumFontSize)),
                          subtitle: Text(
                              '${suggestion.barcode} - ${suggestion.itemCode}',
                              style: TextStyle(fontSize: getMediumFontSize)),
                        );
                      },
                      transitionBuilder: (context, suggestionsBox, controller) {
                        return suggestionsBox;
                      },
                      onSuggestionSelected: (InventoryData inv) {
                        addSearcheSubmittedInvData(inv);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  addSearcheSubmittedInvData(InventoryData inv) async {
    String priceWT = inv.priceWT;
    if (inv.productPriceCanChange) {
      priceWT = await showProductPriceEnterDialog(
          context: context, productPriceWt: priceWT);
    }
    if (priceWT != '0') {
      double discountValue = 0;
      double discountPercentage = 0;
      PromoData? currentPromo = allPromotionDataLst.indexWhere((element) =>
                  element.barcode == inv.barcode &&
                  DateTime.now().compareTo(element.startDate) != -1 &&
                  DateTime.now().compareTo(element.endDate) != 1) ==
              -1
          ? null
          : allPromotionDataLst.elementAt(allPromotionDataLst.indexWhere(
              (element) =>
                  element.barcode == inv.barcode &&
                  DateTime.now().compareTo(element.startDate) != -1 &&
                  DateTime.now().compareTo(element.endDate) != 1));
      if (currentPromo != null) {
        try {
          discountValue = double.parse(priceWT) *
              (double.parse(currentPromo.percentage) / 100);
          discountPercentage = double.parse(currentPromo.percentage);
        } catch (e) {}
      }
      selectedLocalReceiptData.add(LocalReceiptData(
          cost: inv.cost,
          barcode: inv.barcode,
          itemCode: inv.itemCode,
          productName: inv.productName,
          qty: '1',
          discountValue: discountValue.toString(),
          orgPrice: priceWT.toString(),
          discountPercentage: discountPercentage.toStringAsFixed(2),
          total: (double.parse(priceWT.toString()) - discountValue).toString(),
          priceWt: (double.parse(priceWT.toString()) - discountValue).toString()
          // price: inv.price
          ));
      var box = Hive.box('bitpro_app');
      //updating selected image and check if it exist
      if (inv != null || File(inv.productImg).existsSync()) {
        selectedProductImg = inv.productImg;
      } else {
        selectedProductImg = '';
      }

      box.put('receipt_data',
          selectedLocalReceiptData.map((e) => e.toMap()).toList());
      receiptDataSource = ReceiptDataSource(
          selectedLocalReceiptData, widget.userData.maxDiscount, context);
      setState(() {});
    }
  }
}

class ReceiptDataSource extends DataGridSource {
  ReceiptDataSource(List g, String maxDiscount, context) {
    gReceiptData = g;
    userMaxDiscountPer = double.tryParse(maxDiscount) ?? 0;
    buildDataGridRows();
    this.context = context;
  }
  void buildDataGridRows() {
    dataGridRows = gReceiptData
        .map<DataGridRow>(
            (dealer) => getDataGridRow(dealer, gReceiptData.indexOf(dealer)))
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
      DataGridCell<String>(columnName: 'orgPrice', value: dealer.orgPrice),
      DataGridCell<String>(
          columnName: 'discount_percentage', value: dealer.discountPercentage),
      DataGridCell<String>(columnName: 'discount', value: dealer.discountValue),
      DataGridCell<String>(columnName: 'priceWT', value: dealer.priceWt),
      DataGridCell<String>(columnName: 'total', value: dealer.total),
    ]);
  }

  late Function voucherRefersh;
  late BuildContext context;
  @override
  List<DataGridRow> get rows => dataGridRows;

  late List<dynamic> gReceiptData;
  late List<DataGridRow> dataGridRows;
  late double userMaxDiscountPer;
  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        color: row.getCells()[0].value.isEven
            ? const Color(0xffF1F1F1)
            : Colors.white,
        cells: row.getCells().map<Widget>((e) {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3),
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
              newCellValue = double.parse(value);
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
      double disOfOneProduct =
          double.parse(gReceiptData[dataRowIndex].discountValue) /
              double.parse(gReceiptData[dataRowIndex].qty);

      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<String>(columnName: 'qty', value: newCellValue);
      gReceiptData[dataRowIndex].qty = newCellValue;

      //updating discout value
      dataGridRows[dataRowIndex].getCells()[7] = DataGridCell<String>(
          columnName: 'discount',
          value: (disOfOneProduct * double.parse(newCellValue))
              .toStringAsFixed(2));
      gReceiptData[dataRowIndex].discountValue =
          (disOfOneProduct * double.parse(newCellValue)).toStringAsFixed(2);

      //updating total
      dataGridRows[dataRowIndex].getCells()[9] = DataGridCell<String>(
          columnName: 'total',
          value: (double.parse(newCellValue) *
                  double.parse(gReceiptData[dataRowIndex].priceWt))
              .toStringAsFixed(2));
      gReceiptData[dataRowIndex].total = (double.parse(newCellValue) *
              double.parse(gReceiptData[dataRowIndex].priceWt))
          .toStringAsFixed(2);
    } else if (column.columnName == 'discount') {
      double disOfOneProduct = double.parse(newCellValue) /
          double.parse(gReceiptData[dataRowIndex].qty);
      double discountPercentage = disOfOneProduct /
          (double.parse(gReceiptData[dataRowIndex].orgPrice) / 100);

      if (discountPercentage > userMaxDiscountPer) {
        showDiscountOverLimitDialog(context, userMaxDiscountPer);
      } else {
        // print('yo');
        dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
            DataGridCell<String>(columnName: 'discount', value: newCellValue);
        gReceiptData[dataRowIndex].discountValue = newCellValue;

        //updating dicount percentage

        dataGridRows[dataRowIndex].getCells()[6] = DataGridCell<String>(
            columnName: 'discount_percentage',
            value: discountPercentage.toStringAsFixed(2));
        gReceiptData[dataRowIndex].discountPercentage =
            discountPercentage.toStringAsFixed(2);

        //updating price wt
        dataGridRows[dataRowIndex].getCells()[8] = DataGridCell<String>(
            columnName: 'priceWT',
            value: (double.parse(gReceiptData[dataRowIndex].orgPrice) -
                    disOfOneProduct)
                .toStringAsFixed(2));
        gReceiptData[dataRowIndex].priceWt =
            (double.parse(gReceiptData[dataRowIndex].orgPrice) -
                    disOfOneProduct)
                .toStringAsFixed(2);
        //updating total
        dataGridRows[dataRowIndex].getCells()[9] = DataGridCell<String>(
            columnName: 'total',
            value: (double.parse(gReceiptData[dataRowIndex].qty) *
                    double.parse(gReceiptData[dataRowIndex].priceWt))
                .toStringAsFixed(2));
        gReceiptData[dataRowIndex].total =
            (double.parse(gReceiptData[dataRowIndex].qty) *
                    double.parse(gReceiptData[dataRowIndex].priceWt))
                .toStringAsFixed(2);
      }
    } else if (column.columnName == 'discount_percentage') {
      if (double.parse(newCellValue) > userMaxDiscountPer) {
        showDiscountOverLimitDialog(context, userMaxDiscountPer);
      } else {
        dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
            DataGridCell<String>(
                columnName: 'discount_percentage', value: newCellValue);
        gReceiptData[dataRowIndex].discountPercentage = newCellValue;

        double priceOfOneProduct =
            double.parse(gReceiptData[dataRowIndex].orgPrice) /
                double.parse(gReceiptData[dataRowIndex].qty);

        double disOfOneProduct =
            priceOfOneProduct * (double.parse(newCellValue) / 100);

        //updating discout value
        dataGridRows[dataRowIndex].getCells()[7] = DataGridCell<String>(
            columnName: 'discount',
            value:
                (disOfOneProduct * double.parse(gReceiptData[dataRowIndex].qty))
                    .toStringAsFixed(2));
        gReceiptData[dataRowIndex].discountValue =
            (disOfOneProduct * double.parse(gReceiptData[dataRowIndex].qty))
                .toStringAsFixed(2);

        //updating price wt
        dataGridRows[dataRowIndex].getCells()[8] = DataGridCell<String>(
            columnName: 'priceWT',
            value: (double.parse(gReceiptData[dataRowIndex].orgPrice) -
                    disOfOneProduct)
                .toStringAsFixed(2));
        gReceiptData[dataRowIndex].priceWt =
            (double.parse(gReceiptData[dataRowIndex].orgPrice) -
                    disOfOneProduct)
                .toStringAsFixed(2);

        //updating total
        dataGridRows[dataRowIndex].getCells()[9] = DataGridCell<String>(
            columnName: 'total',
            value: (double.parse(gReceiptData[dataRowIndex].qty) *
                    double.parse(gReceiptData[dataRowIndex].priceWt))
                .toStringAsFixed(2));
        gReceiptData[dataRowIndex].total =
            (double.parse(gReceiptData[dataRowIndex].qty) *
                    double.parse(gReceiptData[dataRowIndex].priceWt))
                .toStringAsFixed(2);
      }
    } else if (column.columnName == 'priceWT') {
      double disOfOneProduct =
          double.parse(gReceiptData[dataRowIndex].orgPrice) -
              double.parse(newCellValue);
      double discountPercentage = disOfOneProduct /
          (double.parse(gReceiptData[dataRowIndex].orgPrice) / 100);
      if (discountPercentage > userMaxDiscountPer) {
        showDiscountOverLimitDialog(context, userMaxDiscountPer);
      } else {
        dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
            DataGridCell<String>(columnName: 'priceWT', value: newCellValue);
        gReceiptData[dataRowIndex].priceWt = newCellValue;

        //updating discout value
        dataGridRows[dataRowIndex].getCells()[7] = DataGridCell<String>(
            columnName: 'discount',
            value:
                (disOfOneProduct * double.parse(gReceiptData[dataRowIndex].qty))
                    .toStringAsFixed(2));
        gReceiptData[dataRowIndex].discountValue =
            (disOfOneProduct * double.parse(gReceiptData[dataRowIndex].qty))
                .toStringAsFixed(2);

        //updating dicount percentage

        dataGridRows[dataRowIndex].getCells()[6] = DataGridCell<String>(
            columnName: 'discount_percentage',
            value: discountPercentage.toStringAsFixed(2));
        gReceiptData[dataRowIndex].discountPercentage =
            discountPercentage.toStringAsFixed(2);

        //updating total
        dataGridRows[dataRowIndex].getCells()[9] = DataGridCell<String>(
            columnName: 'total',
            value: ((double.parse(gReceiptData[dataRowIndex].qty) *
                    double.parse(newCellValue)))
                .toStringAsFixed(2));
        gReceiptData[dataRowIndex].total =
            ((double.parse(gReceiptData[dataRowIndex].qty) *
                    double.parse(newCellValue)))
                .toStringAsFixed(2);
      }
    }
    var box = Hive.box('bitpro_app');

    box.put('receipt_data', gReceiptData.map((e) => e.toMap()).toList());
  }
}

class ReceiptCallbackShortcutsIntent extends Intent {
  const ReceiptCallbackShortcutsIntent({required this.name});

  final String name;
}
