import 'dart:io';
import 'dart:math';
import 'package:bitpro_hive/home/sales/customer/sideMenuButton.dart';
import 'package:bitpro_hive/model/department_data.dart';
import 'package:bitpro_hive/model/store_data.dart';
import 'package:bitpro_hive/model/vendor_data.dart';
import 'package:bitpro_hive/services/firestore_api/fb_merchandise/fb_department_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_merchandise/fb_inventory_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_merchandise/fb_vendor_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_merchandise_db_service/department_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_merchandise_db_service/vendors_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_settings/hive_store_db_service.dart';
import 'package:bitpro_hive/widget/string_related/get_random_barcode_string.dart';
import 'package:bitpro_hive/widget/top_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bitpro_hive/model/inventory_data.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/shared/global_variables/font_sizes.dart';
import 'package:bitpro_hive/shared/loading.dart';
import 'package:bitpro_hive/shared/global_variables/static_text_translate.dart';
import '../../../shared/custom_top_nav_bar.dart';
import '../../../shared/dialogs/discard_changes_dialog.dart';

class CreateEditInventoryPage extends StatefulWidget {
  final UserData userData;
  final bool edit;
  final InventoryData? selectedRowData;
  final List<InventoryData> inventoryDataLst;
  final String newInventoryId;
  final bool hideCustomTab;
  const CreateEditInventoryPage({
    Key? key,
    required this.userData,
    this.edit = false,
    this.hideCustomTab = false,
    this.selectedRowData,
    required this.inventoryDataLst,
    required this.newInventoryId,
  }) : super(key: key);

  @override
  State<CreateEditInventoryPage> createState() =>
      _CreateEditInventoryPageState();
}

class _CreateEditInventoryPageState extends State<CreateEditInventoryPage> {
  String? itemCode;
  String? selectedVendorId;
  String? englishProductName;
  String? selectedDepartmentId;
  String cost = '0';
  String? description;
  String? barcode;
  var formKey = GlobalKey<FormState>();
  bool loading = true;
  File? productImage;
  final GlobalKey _menuKey = GlobalKey();
  TextEditingController _vendorTypeAheadController = TextEditingController();
  TextEditingController _departmenttypeAheadController =
      TextEditingController();
  TextEditingController marginController = TextEditingController(text: '0');
  TextEditingController priceWtController = TextEditingController(text: '0');
  TextEditingController priceController = TextEditingController(text: '0');
  final priceWtfocus = FocusNode();
  final barcodefocus = FocusNode();
  String tax = '10';

  bool productPriceCanChange = false;

  List<VendorData> allVendorDataLst = [];
  List<DepartmentData> allDepartmentDataLst = [];

  late int selectedStoreCode;
  late int workstationNumber;
  @override
  void initState() {
    super.initState();
    hiveInitData();
  }

  commonInit() async {
    selectedStoreCode = await HiveStoreDbService().getSelectedStoreCode();
    workstationNumber = await HiveStoreDbService().getWorkstationNumber();
    //updating tax
    var box = Hive.box('bitpro_app');
    Map? userTaxesData = box.get('user_taxes_settings');

    if (userTaxesData != null) {
      tax = userTaxesData['taxPercentage'].toString();
    }

    barcode = randomBarcodeGenerate();
    if (widget.edit && widget.selectedRowData != null) {
      itemCode = widget.selectedRowData!.itemCode;
      productPriceCanChange = widget.selectedRowData!.productPriceCanChange;
      var vd = allVendorDataLst
          .where((e) => e.vendorId == widget.selectedRowData!.selectedVendorId);
      if (vd.isNotEmpty) {
        selectedVendorId = vd.first.vendorId;
        _vendorTypeAheadController.text = vd.first.vendorName;
      }

      englishProductName = widget.selectedRowData!.productName;

      var dp = allDepartmentDataLst.where((e) =>
          e.departmentId == widget.selectedRowData!.selectedDepartmentId);
      if (dp.isNotEmpty) {
        selectedDepartmentId = dp.first.departmentId;
        _departmenttypeAheadController.text = dp.first.departmentName;
      }

      cost = widget.selectedRowData!.cost;
      description = widget.selectedRowData!.description;
      priceController =
          TextEditingController(text: widget.selectedRowData!.price);

      marginController =
          TextEditingController(text: widget.selectedRowData!.margin);

      priceWtController =
          TextEditingController(text: widget.selectedRowData!.priceWT);
      barcode = widget.selectedRowData!.barcode;
    } else {
      itemCode = widget.newInventoryId;
    }
    setState(() {
      loading = false;
    });
  }

  hiveInitData() async {
    //fetching data
    allVendorDataLst = await HiveVendorDbService().fetchAllVendorsData();
    allDepartmentDataLst =
        await HiveDepartmentDbService().fetchAllDepartmentsData();
    await commonInit();
  }

  fbInitData() async {
    //fetching data
    allVendorDataLst =
        await FbVendorDbService(context: context).fetchAllVendorsData();
    allDepartmentDataLst =
        await FbDepartmentDbService(context: context).fetchAllDepartmentsData();
    await commonInit();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hideCustomTab) {
      return childBody();
    }

    return customTopNavBar(childBody());
  }

  childBody() {
    return Scaffold(
      backgroundColor: homeBgColor,
      body: SafeArea(
        child: Column(
          children: [
            TopBar(pageName: 'Inventory'),
            Expanded(
              child: Row(
                children: [
                  Container(
                    color: const Color.fromARGB(255, 43, 43, 43),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SideMenuButton(
                          label: 'Back',
                          iconPath: 'assets/icons/back.png',
                          buttonFunction: () {
                            showDiscardChangesDialog(context);
                          },
                        ),
                        SideMenuButton(
                            label: 'Refresh',
                            iconPath: 'assets/icons/refresh.png',
                            buttonFunction: () async {
                              setState(() {
                                loading = true;
                              });

                              await fbInitData();
                            },),
                        
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 675,
                                height:
                                    MediaQuery.of(context).size.height - 100,
                                child: Card(
                                    shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                            width: 0.5, color: Colors.grey),
                                        borderRadius: BorderRadius.circular(5)),
                                    elevation: 0,
                                    color: Colors.white,
                                    child: loading
                                        ? showLoading()
                                        : Column(
                                            children: [
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  child: Form(
                                                    key: formKey,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              22.0),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              staticTextTranslate(
                                                                  'General Details'),
                                                              style: TextStyle(
                                                                fontSize:
                                                                    getMediumFontSize,
                                                              )),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Container(
                                                                height: 5,
                                                                width: 100,
                                                                decoration: BoxDecoration(
                                                                    color:
                                                                        darkBlueColor,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8)),
                                                              ),
                                                              Flexible(
                                                                child:
                                                                    Container(
                                                                  height: 1,
                                                                  width: double
                                                                      .maxFinite,
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                              .grey[
                                                                          400],
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8)),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                          ButtonBar(
                                                            alignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                width: 280,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                        staticTextTranslate(
                                                                            'Item Code / SKU'),
                                                                        // maxLines: 1,
                                                                        overflow:
                                                                            TextOverflow
                                                                                .ellipsis,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              getMediumFontSize - 1,
                                                                        )),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    TextFormField(
                                                                      initialValue:
                                                                          itemCode,
                                                                      enabled:
                                                                          false,
                                                                      autovalidateMode:
                                                                          AutovalidateMode
                                                                              .onUserInteraction,
                                                                      validator:
                                                                          ((value) {
                                                                        if (value!
                                                                            .isEmpty) {
                                                                          return staticTextTranslate(
                                                                              'Enter item code');
                                                                        } else if ((widget.edit &&
                                                                                widget.selectedRowData!.itemCode != value) ||
                                                                            !widget.edit) {
                                                                          if (widget
                                                                              .inventoryDataLst
                                                                              .where((e) => e.itemCode == value)
                                                                              .isNotEmpty) {
                                                                            return staticTextTranslate('Item code is already in use');
                                                                          }
                                                                        }
                                                                        return null;
                                                                      }),
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                      decoration: const InputDecoration(
                                                                          isDense:
                                                                              true,
                                                                          contentPadding: EdgeInsets.symmetric(
                                                                              vertical:
                                                                                  10,
                                                                              horizontal:
                                                                                  5),
                                                                          border:
                                                                              OutlineInputBorder()),
                                                                      onChanged:
                                                                          (val) =>
                                                                              setState(() {
                                                                        itemCode =
                                                                            val;
                                                                      }),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 20,
                                                                width: 30,
                                                              ),
                                                              SizedBox(
                                                                width: 280,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                        staticTextTranslate(
                                                                            'Vendor'),
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              getMediumFontSize - 1,
                                                                        )),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    TypeAheadFormField<
                                                                        VendorData>(
                                                                      getImmediateSuggestions:
                                                                          false,
                                                                      enabled:
                                                                          !widget
                                                                              .edit,
                                                                      textFieldConfiguration:
                                                                          TextFieldConfiguration(
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w400),
                                                                        controller:
                                                                            _vendorTypeAheadController,
                                                                        decoration: InputDecoration(
                                                                            isDense:
                                                                                true,
                                                                            contentPadding:
                                                                                const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                                                            hintStyle: TextStyle(color: Colors.grey[600]),
                                                                            border: const OutlineInputBorder()),
                                                                      ),
                                                                      noItemsFoundBuilder:
                                                                          (context) {
                                                                        return Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              5.0),
                                                                          child: Text(
                                                                              staticTextTranslate('No Items Found!'),
                                                                              style: TextStyle(
                                                                                fontSize: getMediumFontSize - 1,
                                                                              )),
                                                                        );
                                                                      },
                                                                      validator:
                                                                          (val) {
                                                                        if (val!
                                                                            .isEmpty) {
                                                                          return staticTextTranslate(
                                                                            'Select a vendor',
                                                                          );
                                                                        }
                                                                        return null;
                                                                      },
                                                                      suggestionsCallback:
                                                                          (pattern) {
                                                                        return allVendorDataLst
                                                                            .where((e) =>
                                                                                e.vendorName.toLowerCase().contains(pattern.toLowerCase()))
                                                                            .toList();
                                                                      },
                                                                      itemBuilder:
                                                                          (context,
                                                                              VendorData suggestion) {
                                                                        return ListTile(
                                                                          title: Text(
                                                                              suggestion.vendorName,
                                                                              style: TextStyle(
                                                                                fontSize: getMediumFontSize,
                                                                              )),
                                                                          subtitle:
                                                                              Text('Vendor Code: ${suggestion.vendorId}'),
                                                                        );
                                                                      },
                                                                      transitionBuilder: (context,
                                                                          suggestionsBox,
                                                                          controller) {
                                                                        return suggestionsBox;
                                                                      },
                                                                      onSuggestionSelected:
                                                                          (VendorData
                                                                              suggestion) {
                                                                        _vendorTypeAheadController.text =
                                                                            suggestion.vendorName;

                                                                        setState(
                                                                            () {
                                                                          selectedVendorId =
                                                                              suggestion.vendorId;
                                                                        });
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          ButtonBar(
                                                            alignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                width: 280,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                        staticTextTranslate(
                                                                            'Product Name'),
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              getMediumFontSize - 1,
                                                                        )),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    TextFormField(
                                                                      initialValue:
                                                                          englishProductName,
                                                                      // validator:
                                                                      //     ((value) {
                                                                      //   if (value!
                                                                      //           .isEmpty &&
                                                                      //       (arabicProductName ==
                                                                      //               null ||
                                                                      //           arabicProductName!.isEmpty)) {
                                                                      //     return staticTextTranslate(
                                                                      //         'Enter product name');
                                                                      //   }
                                                                      // }),
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                      decoration: const InputDecoration(
                                                                          isDense:
                                                                              true,
                                                                          contentPadding: EdgeInsets.symmetric(
                                                                              vertical:
                                                                                  10,
                                                                              horizontal:
                                                                                  5),
                                                                          border:
                                                                              OutlineInputBorder()),
                                                                      onChanged:
                                                                          (val) =>
                                                                              setState(() {
                                                                        englishProductName =
                                                                            val;
                                                                      }),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 20,
                                                                width: 30,
                                                              ),
                                                              SizedBox(
                                                                width: 280,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                        staticTextTranslate(
                                                                            'Department'),
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              getMediumFontSize - 1,
                                                                        )),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    TypeAheadFormField(
                                                                      getImmediateSuggestions:
                                                                          false,
                                                                      enabled:
                                                                          !widget
                                                                              .edit,
                                                                      validator:
                                                                          (val) {
                                                                        if (val!
                                                                            .isEmpty) {
                                                                          return staticTextTranslate(
                                                                              'Select a department');
                                                                        }
                                                                        return null;
                                                                      },
                                                                      noItemsFoundBuilder:
                                                                          (context) {
                                                                        return Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              10.0),
                                                                          child: Text(
                                                                              staticTextTranslate('No Items Found!'),
                                                                              style: TextStyle(
                                                                                fontSize: getMediumFontSize,
                                                                              )),
                                                                        );
                                                                      },
                                                                      textFieldConfiguration:
                                                                          TextFieldConfiguration(
                                                                        controller:
                                                                            _departmenttypeAheadController,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w400),
                                                                        decoration: InputDecoration(
                                                                            isDense:
                                                                                true,
                                                                            contentPadding:
                                                                                const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                                                            hintStyle: TextStyle(color: Colors.grey[600]),
                                                                            border: const OutlineInputBorder()),
                                                                      ),
                                                                      suggestionsCallback:
                                                                          (pattern) {
                                                                        return allDepartmentDataLst
                                                                            .where((e) =>
                                                                                e.departmentName.toLowerCase().contains(pattern.toLowerCase()))
                                                                            .toList();
                                                                      },
                                                                      itemBuilder:
                                                                          (context,
                                                                              DepartmentData suggestion) {
                                                                        return ListTile(
                                                                          title: Text(
                                                                              suggestion.departmentName,
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
                                                                          (DepartmentData
                                                                              suggestion) {
                                                                        _departmenttypeAheadController.text =
                                                                            suggestion.departmentName;
                                                                        setState(
                                                                            () {
                                                                          selectedDepartmentId =
                                                                              suggestion.departmentId;
                                                                        });
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          ButtonBar(
                                                            alignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                width: 280,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                        staticTextTranslate(
                                                                            'Cost'),
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              getMediumFontSize - 1,
                                                                        )),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    SizedBox(
                                                                      // height: 37,
                                                                      child:
                                                                          TextFormField(
                                                                        initialValue:
                                                                            cost ??
                                                                                '0',
                                                                        autovalidateMode:
                                                                            AutovalidateMode.onUserInteraction,
                                                                        validator:
                                                                            (val) {
                                                                          if (double.tryParse(val!) ==
                                                                              null) {
                                                                            return staticTextTranslate('Enter a number');
                                                                          }
                                                                          return null;
                                                                        },
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w400),
                                                                        decoration: const InputDecoration(
                                                                            isDense:
                                                                                true,
                                                                            contentPadding:
                                                                                EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                                                            border: OutlineInputBorder()),
                                                                        onChanged:
                                                                            (val) =>
                                                                                setState(() {
                                                                          cost =
                                                                              val;
                                                                          marginController.text =
                                                                              calculateMargin();
                                                                        }),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 20,
                                                                width: 30,
                                                              ),
                                                              SizedBox(
                                                                width: 280,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                            staticTextTranslate(
                                                                                'Description '),
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: getMediumFontSize - 1,
                                                                            )),
                                                                        Text(
                                                                          staticTextTranslate(
                                                                              '(optional)'),
                                                                          style: TextStyle(
                                                                              fontSize: getMediumFontSize - 2,
                                                                              color: Colors.grey),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    SizedBox(
                                                                      child:
                                                                          TextFormField(
                                                                        initialValue:
                                                                            description,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w400),
                                                                        decoration: const InputDecoration(
                                                                            isDense:
                                                                                true,
                                                                            contentPadding:
                                                                                EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                                                            border: OutlineInputBorder()),
                                                                        onChanged:
                                                                            (val) =>
                                                                                setState(() {
                                                                          description =
                                                                              val;
                                                                        }),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          ButtonBar(
                                                            alignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                width: 280,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                        staticTextTranslate(
                                                                            'Price'),
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              getMediumFontSize - 1,
                                                                        )),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    SizedBox(
                                                                      child:
                                                                          TextFormField(
                                                                        controller:
                                                                            priceController,
                                                                        autovalidateMode:
                                                                            AutovalidateMode.onUserInteraction,
                                                                        validator:
                                                                            (val) {
                                                                          if (double.tryParse(val!) ==
                                                                              null) {
                                                                            return staticTextTranslate('Enter a number');
                                                                          }
                                                                          return null;
                                                                        },
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w400),
                                                                        decoration: const InputDecoration(
                                                                            isDense:
                                                                                true,
                                                                            contentPadding:
                                                                                EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                                                            border: OutlineInputBorder()),
                                                                        onChanged:
                                                                            (val) =>
                                                                                setState(() {
                                                                          marginController.text =
                                                                              calculateMargin();
                                                                          priceWtController.text =
                                                                              calculatePriceWt();
                                                                        }),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 20,
                                                                width: 30,
                                                              ),
                                                              SizedBox(
                                                                width: 280,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                            staticTextTranslate(
                                                                                'Margin '),
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: getMediumFontSize - 1,
                                                                            )),
                                                                        Text(
                                                                          staticTextTranslate(
                                                                              '(optional)'),
                                                                          style: TextStyle(
                                                                              fontSize: getMediumFontSize - 2,
                                                                              color: Colors.grey),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    SizedBox(
                                                                      child:
                                                                          TextFormField(
                                                                        controller:
                                                                            marginController,
                                                                        autovalidateMode:
                                                                            AutovalidateMode.onUserInteraction,
                                                                        maxLines:
                                                                            1,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w400),
                                                                        onFieldSubmitted:
                                                                            (v) {
                                                                          FocusScope.of(context)
                                                                              .requestFocus(priceWtfocus);
                                                                        },
                                                                        decoration: const InputDecoration(
                                                                            isDense:
                                                                                true,
                                                                            contentPadding:
                                                                                EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                                                            border: OutlineInputBorder()),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                            width: 30,
                                                          ),
                                                          ButtonBar(
                                                            alignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                width: 280,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                            staticTextTranslate(
                                                                                'Price W/T '),
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: getMediumFontSize - 1,
                                                                            )),
                                                                        Text(
                                                                          staticTextTranslate(
                                                                              '(optional)'),
                                                                          style: TextStyle(
                                                                              fontSize: getSmallFontSize,
                                                                              color: Colors.grey),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    SizedBox(
                                                                      child:
                                                                          TextFormField(
                                                                        controller:
                                                                            priceWtController,
                                                                        maxLines:
                                                                            1,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w400),
                                                                        onFieldSubmitted:
                                                                            (v) {
                                                                          FocusScope.of(context)
                                                                              .requestFocus(barcodefocus);
                                                                        },
                                                                        decoration: const InputDecoration(
                                                                            isDense:
                                                                                true,
                                                                            contentPadding:
                                                                                EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                                                            border: OutlineInputBorder()),
                                                                        focusNode:
                                                                            priceWtfocus,
                                                                        onChanged:
                                                                            (val) =>
                                                                                setState(() {
                                                                          priceController.text =
                                                                              calculatePrice();

                                                                          marginController.text =
                                                                              calculateMargin();
                                                                        }),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 20,
                                                                width: 30,
                                                              ),
                                                              SizedBox(
                                                                width: 280,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                            staticTextTranslate(
                                                                                'Barcode '),
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: getMediumFontSize - 1,
                                                                            )),
                                                                        Text(
                                                                          staticTextTranslate(
                                                                              '(optional)'),
                                                                          style: TextStyle(
                                                                              fontSize: getSmallFontSize,
                                                                              color: Colors.grey),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    SizedBox(
                                                                      child:
                                                                          TextFormField(
                                                                        focusNode:
                                                                            barcodefocus,
                                                                        initialValue:
                                                                            barcode,
                                                                        maxLines:
                                                                            1,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w400),
                                                                        decoration: const InputDecoration(
                                                                            isDense:
                                                                                true,
                                                                            contentPadding:
                                                                                EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                                                            border: OutlineInputBorder()),
                                                                        onChanged:
                                                                            (val) =>
                                                                                setState(() {
                                                                          barcode =
                                                                              val;
                                                                        }),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                            width: 30,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Switch(
                                                                activeColor:
                                                                    darkBlueColor,
                                                                value:
                                                                    productPriceCanChange,
                                                                onChanged: (newValue) =>
                                                                    setState(() =>
                                                                        productPriceCanChange =
                                                                            newValue),
                                                              ),
                                                              Text(
                                                                  staticTextTranslate(
                                                                      'Price can change'),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        getMediumFontSize,
                                                                  ))
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Container(
                                                  height: 62,
                                                  width: double.maxFinite,
                                                  color:
                                                      const Color(0xffdddfe8),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      SizedBox(
                                                        height: 42,
                                                        width: 173,
                                                        child: ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            4))),
                                                            onPressed: () {
                                                              showDiscardChangesDialog(
                                                                  context);
                                                            },
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Image.asset(
                                                                  'assets/icons/cross-circle.png',
                                                                  height: 18,
                                                                ),
                                                                const SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  staticTextTranslate(
                                                                      'Cancel'),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          getMediumFontSize,
                                                                      color: Colors
                                                                          .black),
                                                                ),
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
                                                                backgroundColor:
                                                                    darkBlueColor,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            4))),
                                                            onPressed:
                                                                () async {
                                                              if (formKey
                                                                  .currentState!
                                                                  .validate()) {
                                                                setState(() {
                                                                  loading =
                                                                      true;
                                                                });

                                                                await FbInventoryDbService(
                                                                        context:
                                                                            context)
                                                                    .addUpdateInventoryData(
                                                                        inventoryDataLst: [
                                                                      InventoryData(
                                                                          itemCode:
                                                                              itemCode!,
                                                                          selectedVendorId:
                                                                              selectedVendorId!,
                                                                          productName:
                                                                              englishProductName!,
                                                                          selectedDepartmentId:
                                                                              selectedDepartmentId!,
                                                                          cost:
                                                                              cost!,
                                                                          description: description ??
                                                                              '',
                                                                          price: priceController
                                                                              .text,
                                                                          margin: marginController
                                                                              .text,
                                                                          priceWT: priceWtController
                                                                              .text,
                                                                          productImg:
                                                                              'productImage',
                                                                          createdDate: widget.edit && widget.selectedRowData != null
                                                                              ? widget
                                                                                  .selectedRowData!.createdDate
                                                                              : DateTime
                                                                                  .now(),
                                                                          createdBy: widget.edit && widget.selectedRowData != null
                                                                              ? widget
                                                                                  .selectedRowData!.createdBy
                                                                              : widget
                                                                                  .userData.username,
                                                                          docId: widget.edit && widget.selectedRowData != null
                                                                              ? widget
                                                                                  .selectedRowData!.docId
                                                                              : getRandomString(
                                                                                  20),
                                                                          proImgUrl: widget.edit && widget.selectedRowData != null
                                                                              ? widget
                                                                                  .selectedRowData!.productImg
                                                                              : null,
                                                                          ohQtyForDifferentStores: widget.edit && widget.selectedRowData != null
                                                                              ? widget
                                                                                  .selectedRowData!.ohQtyForDifferentStores
                                                                              : {},
                                                                          barcode:
                                                                              barcode!,
                                                                          productPriceCanChange:
                                                                              productPriceCanChange)
                                                                    ]);
                                                                Navigator.pop(
                                                                    context,
                                                                    true);
                                                              }
                                                            },
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                const Icon(
                                                                  Iconsax
                                                                      .archive,
                                                                  size: 20,
                                                                ),
                                                                const SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                    staticTextTranslate(
                                                                        'Save'),
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          getMediumFontSize,
                                                                    )),
                                                              ],
                                                            )),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          )),
                              ),
                              SizedBox(
                                width: 280,
                                height: 280,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                          width: 0.5, color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4)),
                                  elevation: 0,
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10,
                                        bottom: 22.0,
                                        left: 22,
                                        right: 10),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  staticTextTranslate(
                                                      'Product Image'),
                                                  style: TextStyle(
                                                    fontSize: getMediumFontSize,
                                                  )),
                                              PopupMenuButton(
                                                  splashRadius: 1,
                                                  key: _menuKey,
                                                  itemBuilder: (_) =>
                                                      <PopupMenuItem<String>>[
                                                        if (productImage !=
                                                            null)
                                                          PopupMenuItem<String>(
                                                              value: 'change',
                                                              child: Text(
                                                                  staticTextTranslate(
                                                                      'Change Image'),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        getMediumFontSize,
                                                                  ))),
                                                        if (productImage ==
                                                            null)
                                                          PopupMenuItem<String>(
                                                              value: 'upload',
                                                              child: Text(
                                                                  staticTextTranslate(
                                                                      'Upload Image'),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        getMediumFontSize,
                                                                  ))),
                                                        if (productImage !=
                                                            null)
                                                          PopupMenuItem<String>(
                                                              value: 'cancel',
                                                              child: Text(
                                                                  staticTextTranslate(
                                                                      'Cancel Image'),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        getMediumFontSize,
                                                                  ))),
                                                      ],
                                                  icon: Image.asset(
                                                    'assets/icons/menu-dots-vertical.png',
                                                    height: 20,
                                                  ),
                                                  onSelected: (val) async {
                                                    if (val == 'cancel') {
                                                      productImage = null;
                                                      setState(() {});
                                                    } else if (val ==
                                                            'upload' ||
                                                        val == 'change') {
                                                      FilePickerResult? result =
                                                          await FilePicker
                                                              .platform
                                                              .pickFiles(
                                                                  allowMultiple:
                                                                      false,
                                                                  dialogTitle:
                                                                      staticTextTranslate(
                                                                          'Product Image'),
                                                                  type: FileType
                                                                      .image);

                                                      if (result != null) {
                                                        productImage = File(
                                                            result.files.first
                                                                .path!);
                                                        setState(() {});
                                                      }
                                                    }
                                                  }),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                height: 5,
                                                width: 93,
                                                decoration: BoxDecoration(
                                                    color: darkBlueColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                              ),
                                              Flexible(
                                                child: Container(
                                                  height: 1,
                                                  width: double.maxFinite,
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey[300],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8)),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 0,
                                          ),
                                          if ((widget.edit &&
                                                  widget.selectedRowData !=
                                                      null &&
                                                  widget.selectedRowData!
                                                      .productImg.isNotEmpty) &&
                                              productImage == null)
                                            if (File(widget.selectedRowData!
                                                    .productImg)
                                                .existsSync())
                                              Image.file(
                                                File(widget.selectedRowData!
                                                    .productImg),
                                                width: 270,
                                                height: 195,
                                                fit: BoxFit.contain,
                                              ),
                                          if (productImage != null)
                                            Image.file(
                                              productImage!,
                                              width: 270,
                                              height: 195,
                                              fit: BoxFit.contain,
                                            ),
                                          if (!widget.edit &&
                                              productImage == null)
                                            SizedBox(
                                              width: 270,
                                              height: 195,
                                              child: Icon(Icons.image,
                                                  size: 100,
                                                  color: Colors.grey.shade200),
                                            )
                                        ]),
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
    );
  }

  String calculateMargin() {
    if (cost == null || priceController.text.isEmpty) return '';
    double c = double.parse(cost!);
    double p = double.parse(priceController.text);

    return (((p - c) / c) * 100).toString();
  }

  String calculatePriceWt() {
    if (priceController.text.isEmpty) return '';

    double p = double.parse(priceController.text);

    //  double p = double.parse(priceWtController.text);
    double texPer = double.tryParse(tax) ?? 0;

    return ((p * (1 + (texPer / 100)))).toStringAsFixed(2);
  }

  String calculatePrice() {
    if (priceWtController.text.isEmpty) return '';

    double p = double.parse(priceWtController.text);
    double texPer = double.tryParse(tax) ?? 0;

    return (p - (p / (1 + (100 / texPer)))).toStringAsFixed(2);
  }
}
