import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:bitpro_hive/home/sales/customer/sideMenuButton.dart';
import 'package:bitpro_hive/services/firestore_api/fb_merchandise/fb_vendor_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_merchandise_db_service/vendors_db_service.dart';
import 'package:bitpro_hive/widget/filter_container.dart';
import 'package:bitpro_hive/widget/fiter_textfield.dart';
import 'package:bitpro_hive/widget/string_related/get_id_number.dart';
import 'package:bitpro_hive/widget/top_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:bitpro_hive/home/merchandise/vendor/vendor_create_edit.dart';
import 'package:bitpro_hive/home/merchandise/vendor/vendor_payment/vendor_payment_page.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/model/vendor_data.dart';
import 'package:bitpro_hive/shared/loading.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../../shared/custom_top_nav_bar.dart';
import '../../../shared/global_variables/font_sizes.dart';
import '../../../shared/global_variables/static_text_translate.dart';

class VendorPage extends StatefulWidget {
  final UserData userData;

  const VendorPage({Key? key, required this.userData}) : super(key: key);

  @override
  State<VendorPage> createState() => _VendorPageState();
}

var selectedDataGirdListerner = ValueNotifier<DataGridRow?>(null);

class _VendorPageState extends State<VendorPage> {
  VendorDataSource? vendorDataSource;
  DataGridController dataGridController = DataGridController();
  String searchId = '';
  String searchPhone1 = '';
  String searchName = '';
  DateTime? rangeStartDate;
  DateTime? rangeEndDate;
  bool loading = true;
  var vendorIdController = TextEditingController();
  var vendorNameController = TextEditingController();
  var vendorPhoneController = TextEditingController();

  List<VendorData> allVendorDataLst = [];
  @override
  void initState() {
    super.initState();
    hiveFetchData();
  }

  hiveFetchData() async {
    allVendorDataLst = await HiveVendorDbService().fetchAllVendorsData();
    vendorDataSource = VendorDataSource(vendorData: allVendorDataLst);
    setState(() {
      loading = false;
    });
  }

  filterAccordingSelectedDate() {
    List<VendorData> filteredEmployeesDataLst = [];
    if (rangeStartDate != null && rangeEndDate != null) {
      for (var ug in allVendorDataLst) {
        DateTime tmp = DateTime(
            ug.createdDate.year, ug.createdDate.month, ug.createdDate.day);
        if (tmp.compareTo(rangeStartDate!) != -1 &&
            (tmp.compareTo(rangeEndDate!) != 1)) {
          filteredEmployeesDataLst.add(ug);
        }
      }
    } else if (rangeStartDate != null) {
      var res = allVendorDataLst.where((e) =>
          e.createdDate.day == rangeStartDate!.day &&
          e.createdDate.month == rangeStartDate!.month &&
          e.createdDate.year == rangeStartDate!.year);

      filteredEmployeesDataLst = res.toList();
    }

    vendorDataSource = VendorDataSource(vendorData: filteredEmployeesDataLst);
    rangeStartDate = null;
    rangeEndDate = null;
    setState(() {});
  }

  searchById(String id) {
    searchId = id;
    List<VendorData> filteredVendorDataLst = [];
    if (id.isEmpty) {
      vendorDataSource = VendorDataSource(vendorData: allVendorDataLst);
      setState(() {});
      return;
    }

    for (var v in allVendorDataLst) {
      if (v.vendorId.toLowerCase().contains(id.toLowerCase())) {
        filteredVendorDataLst.add(v);
      }
    }
    vendorDataSource = VendorDataSource(vendorData: filteredVendorDataLst);
    setState(() {});
  }

  searchByPhone1(String pn) {
    searchPhone1 = pn;
    List<VendorData> filteredVendorDataLst = [];
    if (pn.isEmpty) {
      vendorDataSource = VendorDataSource(vendorData: allVendorDataLst);
      setState(() {});
      return;
    }

    for (var v in allVendorDataLst) {
      if (v.phone1.contains(pn)) {
        filteredVendorDataLst.add(v);
      }
    }
    vendorDataSource = VendorDataSource(vendorData: filteredVendorDataLst);
    setState(() {});
  }

  searchByName(String name) {
    searchId = name;
    List<VendorData> filteredVendorDataLst = [];
    if (name.isEmpty) {
      vendorDataSource = VendorDataSource(vendorData: allVendorDataLst);
      setState(() {});
      return;
    }

    for (var v in allVendorDataLst) {
      if (v.vendorName.toLowerCase().contains(name.toLowerCase())) {
        filteredVendorDataLst.add(v);
      }
    }
    vendorDataSource = VendorDataSource(vendorData: filteredVendorDataLst);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return customTopNavBar(
      Scaffold(
        backgroundColor: homeBgColor,
        body: SafeArea(
          child: Container(
            color: homeBgColor,
            child: Column(
              children: [
                TopBar(
                  pageName: 'Vendors',
                ),
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
                                Navigator.pop(context);
                              },
                            ),
                            SideMenuButton(
                              label: 'New',
                              iconPath: 'assets/icons/plus.png',
                              buttonFunction: () async {
                                String newVendorId = await getIdNumber(
                                    allVendorDataLst.length + 1);
                                bool? res = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            VendorCreateEditPage(
                                              newVendorId: newVendorId,
                                              userData: widget.userData,
                                              vendorDataLst: allVendorDataLst,
                                            )));
                                if (res != null && res) {
                                  setState(() {
                                    loading = true;
                                  });
                                  allVendorDataLst =
                                      await FbVendorDbService(context: context)
                                          .fetchAllVendorsData();
                                  allVendorDataLst.sort((a, b) =>
                                      b.createdDate.compareTo(a.createdDate));
                                  vendorDataSource = VendorDataSource(
                                      vendorData: allVendorDataLst);

                                  setState(() {
                                    loading = false;
                                  });
                                }
                              },
                            ),
                            SideMenuButton(
                              label: 'Edit',
                              iconPath: 'assets/icons/edit.png',
                              buttonFunction: () async {
                                if (dataGridController.selectedRow != null) {
                                  var id = '';

                                  for (var c in dataGridController.selectedRow!
                                      .getCells()) {
                                    if (c.columnName == 'id') {
                                      id = c.value;
                                    }
                                  }

                                  bool? res = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              VendorCreateEditPage(
                                                newVendorId: id,
                                                vendorDataLst: allVendorDataLst,
                                                userData: widget.userData,
                                                edit: true,
                                                selectedRowData:
                                                    allVendorDataLst
                                                        .where((e) =>
                                                            e.vendorId == id)
                                                        .first,
                                              )));
                                  if (res != null && res) {
                                    setState(() {
                                      loading = true;
                                    });
                                    allVendorDataLst = await FbVendorDbService(
                                            context: context)
                                        .fetchAllVendorsData();
                                    allVendorDataLst.sort((a, b) =>
                                        b.createdDate.compareTo(a.createdDate));
                                    vendorDataSource = VendorDataSource(
                                        vendorData: allVendorDataLst);
                                    setState(() {
                                      loading = false;
                                    });
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

                                allVendorDataLst =
                                    await FbVendorDbService(context: context)
                                        .fetchAllVendorsData();
                                allVendorDataLst.sort((a, b) =>
                                    b.createdDate.compareTo(a.createdDate));
                                vendorDataSource = VendorDataSource(
                                    vendorData: allVendorDataLst);
                                await Future.delayed(
                                    const Duration(seconds: 1));
                                setState(() {
                                  loading = false;
                                });
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
                              label: 'Vendor Payment',
                              iconPath: 'assets/icons/payment.png',
                              buttonFunction: () {
                                if (dataGridController.selectedRow != null) {
                                  var id = '';

                                  for (var c in dataGridController.selectedRow!
                                      .getCells()) {
                                    if (c.columnName == 'id') {
                                      id = c.value;
                                    }
                                  }
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              VendorPaymentPage(
                                                userData: widget.userData,
                                                selectedVendorData:
                                                    allVendorDataLst
                                                        .where((e) =>
                                                            e.vendorId == id)
                                                        .first,
                                              )));
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SizedBox(
                                width: double.maxFinite,
                                height: 120,
                                child: Card(
                                    shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                            width: 0.5, color: Colors.grey),
                                        borderRadius: BorderRadius.circular(4)),
                                    elevation: 0,
                                    color: Colors.white,
                                    child: Column(
                                      children: [
                                        FilterContainer(fiterFields: [
                                          FilterTextField(
                                              icon: Icon(
                                                      vendorIdController
                                                              .text.isEmpty
                                                          ? CupertinoIcons
                                                              .search
                                                          : Icons.clear,
                                                      size: 18,
                                                      color: vendorIdController
                                                              .text.isEmpty
                                                          ? Colors.grey[600]
                                                          : Colors.black),
                                                          controller: vendorIdController,
                                              onPressed: () {
                                                    vendorIdController.clear();

                                                    vendorDataSource =
                                                        VendorDataSource(
                                                            vendorData:
                                                                allVendorDataLst);
                                                    setState(() {});
                                                  },
                                              onChanged: (val) {
                                                      searchById(val);
                                                    },
                                              hintText: 'Vendor Id'),
                                          
                                          const SizedBox(
                                            width: 0,
                                          ),
                                          Container(
                                            width: 230,
                                            height: 32,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.grey,
                                                    width: 0.5),
                                                color: const Color.fromARGB(
                                                    255, 255, 255, 255),
                                                borderRadius:
                                                    BorderRadius.circular(4)),
                                            padding: const EdgeInsets.only(
                                                right: 10, bottom: 3),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 3),
                                                  onPressed: () {
                                                    vendorNameController
                                                        .clear();

                                                    vendorDataSource =
                                                        VendorDataSource(
                                                            vendorData:
                                                                allVendorDataLst);
                                                    setState(() {});
                                                  },
                                                  splashRadius: 1,
                                                  icon: Icon(
                                                      vendorNameController
                                                              .text.isEmpty
                                                          ? CupertinoIcons
                                                              .search
                                                          : Icons.clear,
                                                      size: 18,
                                                      color:
                                                          vendorNameController
                                                                  .text.isEmpty
                                                              ? Colors.grey[600]
                                                              : Colors.black),
                                                ),
                                                Flexible(
                                                  child: TextField(
                                                      controller:
                                                          vendorNameController,
                                                      onChanged: (val) {
                                                        searchByName(val);
                                                      },
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            staticTextTranslate(
                                                                'Vendor Name'),
                                                        hintStyle: TextStyle(
                                                            color: Colors
                                                                .grey[600]),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 14,
                                                                right: 5),
                                                        border:
                                                            InputBorder.none,
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
                                            height: 32,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.grey,
                                                    width: 0.5),
                                                color: const Color.fromARGB(
                                                    255, 255, 255, 255),
                                                borderRadius:
                                                    BorderRadius.circular(4)),
                                            padding: const EdgeInsets.only(
                                                right: 10, bottom: 3),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 3),
                                                  onPressed: () {
                                                    vendorPhoneController
                                                        .clear();

                                                    vendorDataSource =
                                                        VendorDataSource(
                                                            vendorData:
                                                                allVendorDataLst);
                                                    setState(() {});
                                                  },
                                                  splashRadius: 1,
                                                  icon: Icon(
                                                      vendorPhoneController
                                                              .text.isEmpty
                                                          ? CupertinoIcons
                                                              .search
                                                          : Icons.clear,
                                                      size: 18,
                                                      color:
                                                          vendorPhoneController
                                                                  .text.isEmpty
                                                              ? Colors.grey[600]
                                                              : Colors.black),
                                                ),
                                                Flexible(
                                                  child: TextField(
                                                      controller:
                                                          vendorPhoneController,
                                                      onChanged: (val) {
                                                        searchByPhone1(val);
                                                      },
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            staticTextTranslate(
                                                                'Vendor Phone 01'),
                                                        hintStyle: TextStyle(
                                                            color: Colors
                                                                .grey[600]),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 14,
                                                                right: 5),
                                                        border:
                                                            InputBorder.none,
                                                      )),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]),
                                        if (loading)
                                          Expanded(child: showLoading()),
                                        if (!loading)
                                          Expanded(
                                            child: SfDataGridTheme(
                                              data: SfDataGridThemeData(
                                                  headerColor:
                                                        const Color(0xffF1F1F1),
                                                    sortIcon: const Icon(Icons
                                                        .arrow_drop_down_rounded),
                                                    headerHoverColor:
                                                        const Color(0xffdddfe8),
                                                  selectionColor: loginBgColor),
                                              child: Column(
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                width: 0.3)),
                                                        child: SfDataGrid(
                                                          gridLinesVisibility:
                                                              GridLinesVisibility
                                                                  .both,
                                                          isScrollbarAlwaysShown:
                                                              true,
                                                          onQueryRowHeight:
                                                              (details) {
                                                            // Set the row height as 70.0 to the column header row.
                                                            return details
                                                                        .rowIndex ==
                                                                    0
                                                                ? 25.0
                                                                : 25.0;
                                                          },
                                                          rowHeight: 25,
                                                          headerRowHeight: 25,
                                                          headerGridLinesVisibility:
                                                              GridLinesVisibility
                                                                  .both,
                                                          allowFiltering: true,
                                                          allowSorting: true,
                                                          allowTriStateSorting:
                                                              true,
                                                          controller:
                                                              dataGridController,
                                                          selectionMode:
                                                              SelectionMode
                                                                  .single,
                                                          source:
                                                              vendorDataSource!,
                                                          columnWidthMode:
                                                              ColumnWidthMode
                                                                  .lastColumnFill,
                                                          onSelectionChanged:
                                                              (addedRows,
                                                                  removedRows) {
                                                            setState(() {});
                                                          },
                                                          columns: <GridColumn>[
                                                            GridColumn(
                                                                columnName:
                                                                    'serialNumberForStyleColor',
                                                                visible: false,
                                                                label:
                                                                    Container(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            0.0),
                                                                        alignment:
                                                                            Alignment
                                                                                .center,
                                                                        color: Colors
                                                                            .white,
                                                                        child:
                                                                            Text(
                                                                          'serialNumberForStyleColor',
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                getMediumFontSize,
                                                                          ),
                                                                        ))),
                                                            GridColumn(
                                                              width: 150,
                                                                columnName:
                                                                    'id',
                                                                label:
                                                                    Container(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            2.0),
                                                                        alignment:
                                                                            Alignment
                                                                                .center,
                                                                        
                                                                        child: Text(
                                                                            staticTextTranslate(
                                                                                'Vendor Id'),
                                                                            style: GoogleFonts
                                                                        .roboto(
                                                                      fontSize:
                                                                          getMediumFontSize +
                                                                              1,
                                                                    ),))),
                                                            GridColumn(
                                                              width: 200,
                                                              maximumWidth: 360,
                                                                columnName:
                                                                    'name',
                                                                label:
                                                                    Container(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            2.0),
                                                                        alignment:
                                                                            Alignment
                                                                                .center,
                                                                        
                                                                        child: Text(
                                                                            staticTextTranslate(
                                                                                'Vendor Name'),
                                                                            style: GoogleFonts
                                                                        .roboto(
                                                                      fontSize:
                                                                          getMediumFontSize +
                                                                              1,
                                                                    ),))),
                                                            GridColumn(
                                                              width: 200,
                                                                columnName:
                                                                    'vat no',
                                                                label:
                                                                    Container(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            2.0),
                                                                        alignment:
                                                                            Alignment
                                                                                .center,
                                                                        
                                                                        child:
                                                                            Text(
                                                                          staticTextTranslate(
                                                                              'VAT Number'),
                                                                          style: GoogleFonts
                                                                        .roboto(
                                                                      fontSize:
                                                                          getMediumFontSize +
                                                                              1,
                                                                    ),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ))),
                                                            GridColumn(
                                                                columnName:
                                                                    'phone1',
                                                                label:
                                                                    Container(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            2.0),
                                                                        
                                                                        alignment:
                                                                            Alignment
                                                                                .center,
                                                                        child: Text(
                                                                            staticTextTranslate(
                                                                                'Phone 01'),
                                                                            style: GoogleFonts
                                                                        .roboto(
                                                                      fontSize:
                                                                          getMediumFontSize +
                                                                              1,
                                                                    ),))),
                                                            GridColumn(
                                                                columnName:
                                                                    'email',
                                                                label:
                                                                    Container(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            2.0),
                                                                        
                                                                        alignment:
                                                                            Alignment
                                                                                .center,
                                                                        child: Text(
                                                                            staticTextTranslate(
                                                                                'Email'),
                                                                           
                                                                                style: GoogleFonts
                                                                        .roboto(
                                                                      fontSize:
                                                                          getMediumFontSize +
                                                                              1,
                                                                    ),))),
                                                            GridColumn(
                                                                columnName:
                                                                    'created date',
                                                                label:
                                                                    Container(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            2.0),
                                                                        
                                                                        alignment:
                                                                            Alignment
                                                                                .center,
                                                                        child: Text(
                                                                            staticTextTranslate(
                                                                                'Created Date'),
                                                                        
                                                                                style: GoogleFonts
                                                                        .roboto(
                                                                      fontSize:
                                                                          getMediumFontSize +
                                                                              1,
                                                                    ),))),
                                                            GridColumn(
                                                                columnName:
                                                                    'created by',
                                                                label:
                                                                    Container(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            2.0),
                                                                        
                                                                        alignment:
                                                                            Alignment
                                                                                .center,
                                                                        child: Text(
                                                                            staticTextTranslate(
                                                                                'Created by'),
                                                                            style: GoogleFonts
                                                                        .roboto(
                                                                      fontSize:
                                                                          getMediumFontSize +
                                                                              1,
                                                                    ),))),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VendorDataSource extends DataGridSource {
  VendorDataSource({required List<VendorData> vendorData}) {
    _employeeData = vendorData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(
                  columnName: 'serialNumberForStyleColor',
                  value: vendorData.indexOf(e) + 1),
              DataGridCell<String>(columnName: 'id', value: e.vendorId),
              DataGridCell<String>(columnName: 'name', value: e.vendorName),
              DataGridCell<String>(columnName: 'vat no', value: e.vatNumber),
              DataGridCell<String>(columnName: 'phone1', value: e.phone1),
              DataGridCell<String>(columnName: 'email', value: e.emailAddress),
              DataGridCell<String>(
                  columnName: 'created date',
                  value: DateFormat.yMd().add_jm().format(e.createdDate)),
              DataGridCell<String>(
                  columnName: 'created by', value: e.createdBy),
            ]))
        .toList();
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
              style: GoogleFonts.roboto(
                fontSize: getMediumFontSize + 2,
              ),
            ),
          );
        }).toList());
  }
}
