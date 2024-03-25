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
import 'package:bitpro_hive/widget/bTextField.dart';
import 'package:bitpro_hive/widget/onpage_button.dart';
import 'package:bitpro_hive/widget/onpage_panel.dart';
import 'package:bitpro_hive/widget/string_related/get_random_barcode_string.dart';
import 'package:bitpro_hive/widget/top_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
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

  Color cColor = Colors.red;
  IconData cIcon = Icons.warning;
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
      cColor = Colors.green;
      cIcon = Icons.done;
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
            child: Column(children: [
          TopBar(pageName: 'Inventory'),
          Expanded(
              child: Row(children: [
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
                      label: 'Save',
                      iconPath: 'assets/icons/save.png',
                      buttonFunction: () => onTapSaveButton())
                ],
              ),
            ),
            Expanded(
              child: loading
                  ? showLoading()
                  : Form(
                      key: formKey,
                      child: Row(
                        children: [
                          OnPagePanel(
                            widht: 750,
                              imagePickerWidget: imagePickerWidget(),
                              columnForTextField: Column(
                                children: [
                                  BTextField(
                                    textFieldReadOnly: false,
                                    label: 'Item Code / SKU',
                                    initialValue: itemCode,
                                    validator: ((value) {
                                      if (value!.isEmpty) {
                                        return staticTextTranslate(
                                            'Enter item code');
                                      } else if ((widget.edit &&
                                              widget.selectedRowData!.itemCode !=
                                                  value) ||
                                          !widget.edit) {
                                        if (widget.inventoryDataLst
                                            .where((e) => e.itemCode == value)
                                            .isNotEmpty) {
                                          return staticTextTranslate(
                                              'Item code is already in use');
                                        }
                                      }
                                      return null;
                                    }),
                                    onChanged: (val) => setState(() {
                                      itemCode = val;
                                    }),
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: BTextField(
                                          bradius: 0,
                                          fieldWidth: 205,
                                          textFieldReadOnly: false,
                                          label: 'Product Name',
                                          initialValue: englishProductName,
                                          onChanged: (val) => setState(() {
                                            if (val.isEmpty) {
                                              cColor = Colors.red;
                                              cIcon = Icons.warning;
                                            } else {
                                              cColor = Colors.green;
                                              cIcon = Icons.done;
                                            }
                                            englishProductName = val;
                                          }),
                                          autovalidateMode:
                                              AutovalidateMode.onUserInteraction,
                                        ),
                                      ),
                                      Container(
                                        width: 35,
                                        height: 35,
                                        decoration: BoxDecoration(
                                            color: cColor,
                                            borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(4),
                                              bottomRight: Radius.circular(4),
                                            )),
                                        child: Icon(
                                          cIcon,
                                          color: Colors.white,
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            staticTextTranslate('Vendor'),
                                            style: GoogleFonts.roboto(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 240,
                                          child: TypeAheadFormField<VendorData>(
                                            getImmediateSuggestions: false,
                                            enabled: !widget.edit,
                                            textFieldConfiguration:
                                                TextFieldConfiguration(
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400),
                                              controller:
                                                  _vendorTypeAheadController,
                                              decoration: InputDecoration(
                                                  isDense: true,
                                                  fillColor: Colors.white,
                                                  filled: true,
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                          vertical: 10,
                                                          horizontal: 5),
                                                  hintStyle: TextStyle(
                                                      color: Colors.grey[600]),
                                                  border:
                                                      const OutlineInputBorder()),
                                            ),
                                            noItemsFoundBuilder: (context) {
                                              return Padding(
                                                padding: const EdgeInsets.all(5.0),
                                                child: Text(
                                                    staticTextTranslate(
                                                        'No Items Found!'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize - 1,
                                                    )),
                                              );
                                            },
                                            validator: (val) {
                                              if (val!.isEmpty) {
                                                return staticTextTranslate(
                                                  'Select a vendor',
                                                );
                                              }
                                              return null;
                                            },
                                            suggestionsCallback: (pattern) {
                                              return allVendorDataLst
                                                  .where((e) => e.vendorName
                                                      .toLowerCase()
                                                      .contains(
                                                          pattern.toLowerCase()))
                                                  .toList();
                                            },
                                            itemBuilder:
                                                (context, VendorData suggestion) {
                                              return ListTile(
                                                title: Text(suggestion.vendorName,
                                                    style: TextStyle(
                                                      fontSize: getMediumFontSize,
                                                    )),
                                                subtitle: Text(
                                                    'Vendor Code: ${suggestion.vendorId}'),
                                              );
                                            },
                                            transitionBuilder: (context,
                                                suggestionsBox, controller) {
                                              return suggestionsBox;
                                            },
                                            onSuggestionSelected:
                                                (VendorData suggestion) {
                                              _vendorTypeAheadController.text =
                                                  suggestion.vendorName;
                          
                                              setState(() {
                                                selectedVendorId =
                                                    suggestion.vendorId;
                                              });
                                            },
                                          ),
                                        )
                                      ]),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            staticTextTranslate('Department'),
                                            style: GoogleFonts.roboto(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 240,
                                          child: TypeAheadFormField(
                                            getImmediateSuggestions: false,
                                            enabled: !widget.edit,
                                            validator: (val) {
                                              if (val!.isEmpty) {
                                                return staticTextTranslate(
                                                    'Select a department');
                                              }
                                              return null;
                                            },
                                            noItemsFoundBuilder: (context) {
                                              return Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Text(
                                                    staticTextTranslate(
                                                        'No Items Found!'),
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
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400),
                                              decoration: InputDecoration(
                                                  isDense: true,
                                                  fillColor: Colors.white,
                                                  filled: true,
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                          vertical: 10,
                                                          horizontal: 5),
                                                  hintStyle: TextStyle(
                                                      color: Colors.grey[600]),
                                                  border:
                                                      const OutlineInputBorder()),
                                            ),
                                            suggestionsCallback: (pattern) {
                                              return allDepartmentDataLst
                                                  .where((e) => e.departmentName
                                                      .toLowerCase()
                                                      .contains(
                                                          pattern.toLowerCase()))
                                                  .toList();
                                            },
                                            itemBuilder: (context,
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
                                                suggestionsBox, controller) {
                                              return suggestionsBox;
                                            },
                                            onSuggestionSelected:
                                                (DepartmentData suggestion) {
                                              _departmenttypeAheadController.text =
                                                  suggestion.departmentName;
                                              setState(() {
                                                selectedDepartmentId =
                                                    suggestion.departmentId;
                                              });
                                            },
                                          ),
                                        )
                                      ]),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  
                                  BTextField(
                                    textFieldReadOnly: false,
                                    label: 'Description',
                                    initialValue: description,
                                    onChanged: (val) => setState(() {
                                      description = val;
                                    }),
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  BTextField(
                                    textFieldReadOnly: false,
                                    label: 'Cost',
                                    initialValue: cost,
                                    validator: ((val) {
                                      if (double.tryParse(val!) == null) {
                                        return staticTextTranslate(
                                            'Enter a number');
                                      }
                                      return null;
                                    }),
                                    onChanged: (val) => setState(() {
                                      cost = val;
                                      marginController.text = calculateMargin();
                                    }),
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  BTextField(
                                    textFieldReadOnly: false,
                                    label: 'Price',
                                    controller: priceController,
                                    validator: (val) {
                                      if (double.tryParse(val!) == null) {
                                        return staticTextTranslate(
                                            'Enter a number');
                                      }
                                      return null;
                                    },
                                    onChanged: (val) => setState(() {
                                      marginController.text = calculateMargin();
                                      priceWtController.text = calculatePriceWt();
                                    }),
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  BTextField(
                                    textFieldReadOnly: false,
                                    label: 'Margin',
                                    controller: marginController,
                                    onChanged: (val) => setState(() {
                                      //  FocusScope.of(context)
                                      //                                             .requestFocus(priceWtfocus);
                                    }),
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  BTextField(
                                    textFieldReadOnly: false,
                                    label: 'Price W/T',
                                    controller: priceWtController,
                                    onChanged: (val) => setState(() {
                                      priceController.text = calculatePrice();
                          
                                      marginController.text = calculateMargin();
                                    }),
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  BTextField(
                                    textFieldReadOnly: false,
                                    label: 'Barcode',
                                    initialValue: barcode,
                                    onChanged: (val) => setState(() {
                                      barcode = val;
                                    }),
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  SizedBox(
                                    child: Row(
                                      children: [
                                        Switch(
                                          activeColor: darkBlueColor,
                                          value: productPriceCanChange,
                                          onChanged: (newValue) => setState(
                                              () => productPriceCanChange = newValue),
                                        ),
                                        Text(staticTextTranslate('Price can change'),
                                            style: TextStyle(
                                              fontSize: getMediumFontSize,
                                            ))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              rowForButton: Row(
                                children: [
                                  OnPageButton(
                                    icon: Iconsax.archive,
                                    label: 'Save',
                                    onPressed: () {
                                      onTapSaveButton();
                                    },
                                  ),
                                ],
                              ),
                              topLabel: 'Inventory Details'),
                        ],
                      ),
                    ),
            )
          ]))
        ])));
  }

  imagePickerWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 14.0),
      child: SizedBox(
        width: 220,
        height: 220,
        child: Card(
          shape: RoundedRectangleBorder(
              side: const BorderSide(width: 0.5, color: Colors.grey),
              borderRadius: BorderRadius.circular(4)),
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(
                top: 10, bottom: 22.0, left: 22, right: 10),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(staticTextTranslate('Product Image'),
                          style: TextStyle(
                            fontSize: getMediumFontSize,
                          )),
                      PopupMenuButton(
                          splashRadius: 1,
                          key: _menuKey,
                          itemBuilder: (_) => <PopupMenuItem<String>>[
                                if (productImage != null)
                                  PopupMenuItem<String>(
                                      value: 'change',
                                      child: Text(
                                          staticTextTranslate('Change Image'),
                                          style: TextStyle(
                                            fontSize: getMediumFontSize,
                                          ))),
                                if (productImage == null)
                                  PopupMenuItem<String>(
                                      value: 'upload',
                                      child: Text(
                                          staticTextTranslate('Upload Image'),
                                          style: TextStyle(
                                            fontSize: getMediumFontSize,
                                          ))),
                                if (productImage != null)
                                  PopupMenuItem<String>(
                                      value: 'cancel',
                                      child: Text(
                                          staticTextTranslate('Remove Image'),
                                          style: TextStyle(
                                            fontSize: getMediumFontSize,
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
                            } else if (val == 'upload' || val == 'change') {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                      allowMultiple: false,
                                      dialogTitle:
                                          staticTextTranslate('Product Image'),
                                      type: FileType.image);

                              if (result != null) {
                                productImage = File(result.files.first.path!);
                                setState(() {});
                              }
                            }
                          }),
                    ],
                  ),
                 
                  const SizedBox(
                    height: 0,
                  ),
                  if ((widget.edit &&
                          widget.selectedRowData != null &&
                          widget.selectedRowData!.productImg.isNotEmpty) &&
                      productImage == null)
                    if (File(widget.selectedRowData!.productImg).existsSync())
                      Image.file(
                        File(widget.selectedRowData!.productImg),
                        width: 200,
                        height: 140,
                        fit: BoxFit.contain,
                      ),
                  if (productImage != null)
                    Image.file(
                      productImage!,
                      width: 200,
                      height: 140,
                      fit: BoxFit.contain,
                    ),
                  if (!widget.edit && productImage == null)
                    SizedBox(
                      width: 200,
                      height: 140,
                      child: Icon(Icons.image,
                          size: 100, color: Colors.grey.shade200),
                    )
                ]),
          ),
        ),
      ),
    );
  }

  onTapSaveButton() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });

      await FbInventoryDbService(context: context)
          .addUpdateInventoryData(inventoryDataLst: [
        InventoryData(
            itemCode: itemCode!,
            selectedVendorId: selectedVendorId!,
            productName: englishProductName!,
            selectedDepartmentId: selectedDepartmentId!,
            cost: cost!,
            description: description ?? '',
            price: priceController.text,
            margin: marginController.text,
            priceWT: priceWtController.text,
            productImg: 'productImage',
            createdDate: widget.edit && widget.selectedRowData != null
                ? widget.selectedRowData!.createdDate
                : DateTime.now(),
            createdBy: widget.edit && widget.selectedRowData != null
                ? widget.selectedRowData!.createdBy
                : widget.userData.username,
            docId: widget.edit && widget.selectedRowData != null
                ? widget.selectedRowData!.docId
                : getRandomString(20),
            proImgUrl: widget.edit && widget.selectedRowData != null
                ? widget.selectedRowData!.productImg
                : null,
            ohQtyForDifferentStores:
                widget.edit && widget.selectedRowData != null
                    ? widget.selectedRowData!.ohQtyForDifferentStores
                    : {},
            barcode: barcode!,
            productPriceCanChange: productPriceCanChange)
      ]);
      Navigator.pop(context, true);
    }
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
