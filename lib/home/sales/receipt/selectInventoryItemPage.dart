import 'dart:io';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:bitpro_hive/model/department_data.dart';
import 'package:bitpro_hive/model/store_data.dart';
import 'package:bitpro_hive/services/firestore_api/fb_merchandise/fb_department_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_merchandise/fb_inventory_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_merchandise/fb_vendor_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_settings/fb_store_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_merchandise_db_service/department_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_merchandise_db_service/inventory_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_merchandise_db_service/vendors_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_settings/hive_store_db_service.dart';
import 'package:bitpro_hive/widget/string_related/get_id_number.dart';
import 'package:bitpro_hive/widget/string_related/get_random_string.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import '../../../model/vendor_data.dart';
import '../../../services/hive/import_data_exel/inventory_datat_excel.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;
import '../../../shared/global_variables/font_sizes.dart';
import '../../../shared/save_file_and_launch.dart';
import 'package:excel/excel.dart' hide Border;
import '../../../shared/global_variables/static_text_translate.dart';
import '../../../widget/bitpro_logo_widget.dart';

class SelectInventoryItemPage extends StatefulWidget {
  final UserData userData;

  const SelectInventoryItemPage({Key? key, required this.userData})
      : super(key: key);

  @override
  State<SelectInventoryItemPage> createState() =>
      _SelectInventoryItemPageState();
}

var selectedDataGirdListerner = ValueNotifier<DataGridRow?>(null);

class _SelectInventoryItemPageState extends State<SelectInventoryItemPage> {
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

  late String selectedStoreDocId;
  List<StoreData> allStoreDataLst = [];
  List<VendorData> allVendorDataLst = [];
  List<DepartmentData> allDepartmentDataLst = [];
  @override
  void initState() {
    super.initState();
    hiveFetchData();
  }

  hiveFetchData() async {
    //stores data filter
    allStoreDataLst = await HiveStoreDbService().fetchAllStoresData();
    allVendorDataLst = await HiveVendorDbService().fetchAllVendorsData();
    allDepartmentDataLst =
        await HiveDepartmentDbService().fetchAllDepartmentsData();
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
    inventoryDataLst = await HiveInventoryDbService().fetchAllInventoryData();
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

  fbFetchData() async {
    //stores data filter
    allStoreDataLst =
        await FbStoreDbService(context: context).fetchAllStoresData();
    allVendorDataLst =
        await FbVendorDbService(context: context).fetchAllVendorsData();
    allDepartmentDataLst =
        await FbDepartmentDbService(context: context).fetchAllDepartmentsData();
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
    inventoryDataLst =
        await FbInventoryDbService(context: context).fetchAllInventoryData();
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
  // fetchData() async {
  //   inventoryDataLst =
  //       await FbInventoryDbService(context: context).fetchAllInventoryData();
  //   allVendorDataLst =
  //       await FbVendorDbService(context: context).fetchAllVendorsData();

  //   allDepartmentDataLst =
  //       await FbDepartmentDbService(context: context).fetchAllDepartmentsData();
  //   filteredInventoryDataLst = inventoryDataLst;
  //   filteredInventoryDataLst
  //       .sort((b, a) => a.createdDate.compareTo(b.createdDate));

  //   inventoryDataSource = EmployeeDataSource(
  //       inventoryData: inventoryDataLst,
  //       selectedStoreDocId: selectedStoreDocId);

  //   //stores data filter
  //   allStoreDataLst =
  //       await FbStoreDbService(context: context).fetchAllStoresData();

  //   //getting default selected store
  //   int selectedStoreCode = await HiveStoreDbService().getStoreCode();
  //   int index = allStoreDataLst.indexWhere(
  //       (element) => element.storeCode == selectedStoreCode.toString());

  //   if (index != -1) {
  //     selectedStoreDocId = allStoreDataLst.elementAt(index).docId;
  //   } else {
  //     selectedStoreDocId = allStoreDataLst.first.docId;
  //   }

  //   setState(() {
  //     loading = false;
  //   });
  // }

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
    return Scaffold(
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
                    height: 15,
                  ),
                  getBitproLogo(),
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
                            Iconsax.add_square4,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(staticTextTranslate('Create'),
                              style: TextStyle(
                                  fontSize: getMediumFontSize,
                                  color: const Color.fromARGB(255, 0, 0, 0))),
                        ],
                      ),
                      onPressed: () async {
                        String newInventoryId =
                            await getIdNumber(inventoryDataLst.length + 1);
                        bool? res = await showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: CreateEditInventoryPage(
                                newInventoryId: newInventoryId,
                                hideCustomTab: true,
                                inventoryDataLst: inventoryDataLst,
                                userData: widget.userData,
                              ),
                            );
                          },
                        );

                        if (res != null && res) {
                          setState(() {
                            loading = true;
                          });

                          fbFetchData();
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
                          loading = true;
                        });
                        await fbFetchData();
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
                            Iconsax.calendar_1,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(staticTextTranslate('Date Range'),
                              style: TextStyle(
                                  fontSize: getMediumFontSize,
                                  color: const Color.fromARGB(255, 0, 0, 0))),
                        ],
                      ),
                      onPressed: () {
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
                                        if (args.value is PickerDateRange) {
                                          rangeStartDate = args.value.startDate;
                                          rangeEndDate = args.value.endDate;
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
                                      cancelText: 'Close',
                                      confirmText: 'OK',
                                      showTodayButton: false,
                                      showActionButtons: true,
                                      view: DateRangePickerView.month,
                                      selectionMode:
                                          DateRangePickerSelectionMode.range),
                                ),
                              );
                            });
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
                      height: 5,
                    ),
                    SizedBox(
                      height: 35,
                      width: 370,
                      child: Row(children: [
                        const SizedBox(width: 10),
                        const Icon(
                          size: 19,
                          Iconsax.d_square,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          staticTextTranslate('Inventory'),
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
                        width: double.maxFinite,
                        height: 40,
                        child: Card(
                            shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    width: 0.5, color: Colors.grey),
                                borderRadius: BorderRadius.circular(5)),
                            elevation: 0,
                            color: Colors.white,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: ButtonBarSuper(
                                    buttonTextTheme: ButtonTextTheme.primary,
                                    wrapType: WrapType.fit,
                                    wrapFit: WrapFit.min,
                                    lineSpacing: 20,
                                    alignment: engSelectedLanguage
                                        ? WrapSuperAlignment.left
                                        : WrapSuperAlignment.right,
                                    children: [
                                      Container(
                                        width: 230,
                                        height: 30,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey, width: 0.5),
                                            color: const Color.fromARGB(
                                                255, 255, 255, 255),
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        padding: const EdgeInsets.only(
                                            right: 10,
                                            // top: 3,
                                            bottom: 3),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                barcodeFilterController.clear();

                                                inventoryDataSource =
                                                    EmployeeDataSource(
                                                        inventoryData:
                                                            inventoryDataLst,
                                                        selectedStoreDocId:
                                                            selectedStoreDocId);
                                                setState(() {});
                                              },
                                              splashRadius: 1,
                                              icon: Icon(
                                                  barcodeFilterController
                                                          .text.isEmpty
                                                      ? CupertinoIcons.search
                                                      : Icons.clear,
                                                  size: 18,
                                                  color: barcodeFilterController
                                                          .text.isEmpty
                                                      ? Colors.grey[600]
                                                      : Colors.black),
                                            ),
                                            Flexible(
                                              child: TextField(
                                                controller:
                                                    barcodeFilterController,
                                                decoration: InputDecoration(
                                                  hintText: staticTextTranslate(
                                                      'Barcode / Item Code'),
                                                  hintStyle: TextStyle(
                                                      color: Colors.grey[600]),
                                                  contentPadding:
                                                      const EdgeInsets.only(
                                                          bottom: 14, right: 5),
                                                  border: InputBorder.none,
                                                ),
                                                onChanged: (val) {
                                                  searchByBarcodeAndItemCode(
                                                      val);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 0,
                                      ),
                                      Container(
                                        width: 230,
                                        height: 30,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey, width: 0.5),
                                            color: const Color.fromARGB(
                                                255, 255, 255, 255),
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        padding: const EdgeInsets.only(
                                            right: 10, bottom: 3),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                itemNameFilterController
                                                    .clear();

                                                inventoryDataSource =
                                                    EmployeeDataSource(
                                                        inventoryData:
                                                            inventoryDataLst,
                                                        selectedStoreDocId:
                                                            selectedStoreDocId);
                                                setState(() {});
                                              },
                                              splashRadius: 1,
                                              icon: Icon(
                                                  itemNameFilterController
                                                          .text.isEmpty
                                                      ? CupertinoIcons.search
                                                      : Icons.clear,
                                                  size: 18,
                                                  color:
                                                      itemNameFilterController
                                                              .text.isEmpty
                                                          ? Colors.grey[600]
                                                          : Colors.black),
                                            ),
                                            Flexible(
                                              child: TextField(
                                                  controller:
                                                      itemNameFilterController,
                                                  onChanged: (val) {
                                                    searchByItemName(val);
                                                  },
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        staticTextTranslate(
                                                            'Item Name'),
                                                    hintStyle: TextStyle(
                                                        color:
                                                            Colors.grey[600]),
                                                    contentPadding:
                                                        const EdgeInsets.only(
                                                            bottom: 14,
                                                            right: 5),
                                                    border: InputBorder.none,
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 0,
                                      ),
                                      Container(
                                        width: 230,
                                        height: 30,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey, width: 0.5),
                                            color: const Color.fromARGB(
                                                255, 255, 255, 255),
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        padding: const EdgeInsets.only(
                                            right: 10, bottom: 3),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                _vendorTypeAheadController
                                                    .clear();

                                                inventoryDataSource =
                                                    EmployeeDataSource(
                                                        inventoryData:
                                                            inventoryDataLst,
                                                        selectedStoreDocId:
                                                            selectedStoreDocId);
                                                setState(() {});
                                              },
                                              splashRadius: 1,
                                              icon: Icon(
                                                  _vendorTypeAheadController
                                                          .text.isEmpty
                                                      ? CupertinoIcons.search
                                                      : Icons.clear,
                                                  size: 18,
                                                  color:
                                                      _vendorTypeAheadController
                                                              .text.isEmpty
                                                          ? Colors.grey[600]
                                                          : Colors.black),
                                            ),
                                            Flexible(
                                              child: TypeAheadFormField(
                                                getImmediateSuggestions: false,
                                                textFieldConfiguration:
                                                    TextFieldConfiguration(
                                                  controller:
                                                      _vendorTypeAheadController,
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        staticTextTranslate(
                                                            'Vendor'),
                                                    hintStyle: TextStyle(
                                                        color:
                                                            Colors.grey[600]),
                                                    contentPadding:
                                                        const EdgeInsets.only(
                                                            bottom: 14,
                                                            right: 5),
                                                    border: InputBorder.none,
                                                  ),
                                                ),
                                                suggestionsCallback: (pattern) {
                                                  return allVendorDataLst
                                                      .where((e) => e.vendorName
                                                          .toLowerCase()
                                                          .contains(pattern
                                                              .toLowerCase()))
                                                      .toList();
                                                },
                                                noItemsFoundBuilder: (context) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Text(
                                                        staticTextTranslate(
                                                            'No Items Found!'),
                                                        style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
                                                        )),
                                                  );
                                                },
                                                itemBuilder: (context,
                                                    VendorData suggestion) {
                                                  return ListTile(
                                                    title: Text(
                                                      suggestion.vendorName,
                                                      style: TextStyle(
                                                        fontSize:
                                                            getMediumFontSize,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                transitionBuilder: (context,
                                                    suggestionsBox,
                                                    controller) {
                                                  return suggestionsBox;
                                                },
                                                onSuggestionSelected:
                                                    (VendorData suggestion) {
                                                  _vendorTypeAheadController
                                                          .text =
                                                      suggestion.vendorName;
                                                  setState(() {
                                                    searchByVendor(
                                                        suggestion.vendorId);
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 0,
                                      ),
                                      Container(
                                        width: 230,
                                        height: 30,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey, width: 0.5),
                                            color: const Color.fromARGB(
                                                255, 255, 255, 255),
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        padding: const EdgeInsets.only(
                                            right: 10, bottom: 3),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                _departmenttypeAheadController
                                                    .clear();

                                                inventoryDataSource =
                                                    EmployeeDataSource(
                                                        inventoryData:
                                                            inventoryDataLst,
                                                        selectedStoreDocId:
                                                            selectedStoreDocId);
                                                setState(() {});
                                              },
                                              splashRadius: 1,
                                              icon: Icon(
                                                  _departmenttypeAheadController
                                                          .text.isEmpty
                                                      ? CupertinoIcons.search
                                                      : Icons.clear,
                                                  size: 18,
                                                  color:
                                                      _departmenttypeAheadController
                                                              .text.isEmpty
                                                          ? Colors.grey[600]
                                                          : Colors.black),
                                            ),
                                            Flexible(
                                              child: TypeAheadFormField(
                                                getImmediateSuggestions: false,
                                                textFieldConfiguration:
                                                    TextFieldConfiguration(
                                                  controller:
                                                      _departmenttypeAheadController,
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        staticTextTranslate(
                                                            'Department'),
                                                    hintStyle: TextStyle(
                                                        color:
                                                            Colors.grey[600]),
                                                    contentPadding:
                                                        const EdgeInsets.only(
                                                            bottom: 14,
                                                            right: 5),
                                                    border: InputBorder.none,
                                                  ),
                                                ),
                                                suggestionsCallback: (pattern) {
                                                  return allDepartmentDataLst
                                                      .where((e) => e
                                                          .departmentName
                                                          .toLowerCase()
                                                          .contains(pattern
                                                              .toLowerCase()))
                                                      .toList();
                                                },
                                                noItemsFoundBuilder: (context) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Text(
                                                      staticTextTranslate(
                                                          'No Items Found!'),
                                                      style: TextStyle(
                                                        fontSize:
                                                            getMediumFontSize,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                itemBuilder: (context,
                                                    DepartmentData suggestion) {
                                                  return ListTile(
                                                    title: Text(
                                                      suggestion.departmentName,
                                                      style: TextStyle(
                                                        fontSize:
                                                            getMediumFontSize,
                                                      ),
                                                    ),
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
                                                  _departmenttypeAheadController
                                                          .text =
                                                      suggestion.departmentName;
                                                  setState(() {
                                                    searchByDepartment(
                                                        suggestion
                                                            .departmentId);
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (inventoryDataSource == null || loading)
                                  Expanded(
                                    child: showLoading(),
                                  ),
                                if (inventoryDataSource != null && !loading)
                                  Expanded(
                                    child: SfDataGridTheme(
                                      data: SfDataGridThemeData(
                                          headerColor: const Color(0xffdddfe8),
                                          headerHoverColor:
                                              const Color(0xffdddfe8),
                                          selectionColor: loginBgColor),
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 2,
                                            width: double.infinity,
                                            color: Colors.blue,
                                          ),
                                          Expanded(
                                            child: SfDataGrid(
                                              headerGridLinesVisibility:
                                                  GridLinesVisibility.both,
                                              gridLinesVisibility:
                                                  GridLinesVisibility.both,
                                              isScrollbarAlwaysShown: true,
                                              onQueryRowHeight: (details) {
                                                // Set the row height as 70.0 to the column header row.
                                                return details.rowIndex == 0
                                                    ? 25.0
                                                    : 23.0;
                                              },
                                              allowSorting: true,
                                              allowTriStateSorting: true,
                                              key: _key,
                                              controller: dataGridController,
                                              showCheckboxColumn: true,
                                              allowFiltering: true,
                                              selectionMode:
                                                  SelectionMode.multiple,
                                              source: inventoryDataSource!,
                                              columnWidthMode: ColumnWidthMode
                                                  .lastColumnFill,
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
                                                            const EdgeInsets
                                                                .all(0.0),
                                                        alignment:
                                                            Alignment.center,
                                                        color: Colors.white,
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
                                                            const EdgeInsets
                                                                .all(1.0),
                                                        alignment:
                                                            Alignment.center,
                                                        color: const Color(
                                                            0xffdddfe8),
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
                                                            const EdgeInsets
                                                                .all(1.0),
                                                        alignment:
                                                            Alignment.center,
                                                        color: const Color(
                                                            0xffdddfe8),
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
                                                            const EdgeInsets
                                                                .all(1.0),
                                                        alignment:
                                                            Alignment.center,
                                                        color: const Color(
                                                            0xffdddfe8),
                                                        child: Text(
                                                          staticTextTranslate(
                                                              'Product Name'),
                                                          style: TextStyle(
                                                            fontSize:
                                                                getMediumFontSize,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ))),
                                                GridColumn(
                                                    width: 150,
                                                    columnName: 'storeOhQty',
                                                    label: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(1.0),
                                                        color: const Color(
                                                            0xffdddfe8),
                                                        alignment:
                                                            Alignment.center,
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
                                                            const EdgeInsets
                                                                .all(1.0),
                                                        color: const Color(
                                                            0xffdddfe8),
                                                        alignment:
                                                            Alignment.center,
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
                                                            const EdgeInsets
                                                                .all(1.0),
                                                        color: const Color(
                                                            0xffdddfe8),
                                                        alignment:
                                                            Alignment.center,
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
                                                            const EdgeInsets
                                                                .all(1.0),
                                                        color: const Color(
                                                            0xffdddfe8),
                                                        alignment:
                                                            Alignment.center,
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
                                                            const EdgeInsets
                                                                .all(1.0),
                                                        color: const Color(
                                                            0xffdddfe8),
                                                        alignment:
                                                            Alignment.center,
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
                                                            const EdgeInsets
                                                                .all(1.0),
                                                        color: const Color(
                                                            0xffdddfe8),
                                                        alignment:
                                                            Alignment.center,
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
                                                            const EdgeInsets
                                                                .all(1.0),
                                                        color: const Color(
                                                            0xffdddfe8),
                                                        alignment:
                                                            Alignment.center,
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
                                        ],
                                      ),
                                    ),
                                  )
                              ],
                            )),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 40,
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                            color: const Color(0xffdddfe8),
                            borderRadius: BorderRadius.circular(4)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              height: 30,
                              width: 150,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4))),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Iconsax.close_circle,
                                        color: Colors.black,
                                        size: 19,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        staticTextTranslate('Close'),
                                        style: TextStyle(
                                            fontSize: getMediumFontSize,
                                            color: Colors.black),
                                      ),
                                    ],
                                  )),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              height: 30,
                              width: 150,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 36, 109, 39),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4))),
                                  onPressed: () async {
                                    List<InventoryData>
                                        selectedInventoryDataLst = [];

                                    for (var r
                                        in dataGridController.selectedRows) {
                                      for (var c in r.getCells()) {
                                        if (c.columnName == 'barcode' &&
                                            inventoryDataLst.any((element) =>
                                                element.barcode == c.value)) {
                                          try {
                                            selectedInventoryDataLst.add(
                                                inventoryDataLst.firstWhere(
                                                    (element) =>
                                                        element.barcode ==
                                                        c.value));
                                          } catch (e) {}
                                        }
                                      }
                                    }

                                    Navigator.pop(
                                        context, selectedInventoryDataLst);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Iconsax.tag_right,
                                        size: 20,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(staticTextTranslate('OK'),
                                          style: TextStyle(
                                            fontSize: getMediumFontSize,
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
                    ),
                    const SizedBox(
                      height: 5,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
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
            value: (storeOh * double.parse(e.priceWT)).toString()),
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
