import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:bitpro_hive/home/sales/customer/sideMenuButton.dart';
import 'package:bitpro_hive/model/store_data.dart';
import 'package:bitpro_hive/services/firestore_api/fb_sales/fb_customer_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_sales/fb_receipt_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_settings/fb_store_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_sales_db_service/hive_customer_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_sales_db_service/hive_receipt_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_settings/hive_store_db_service.dart';
import 'package:bitpro_hive/services/providers/fetching_data_provider.dart';
import 'package:bitpro_hive/widget/filter_container.dart';
import 'package:bitpro_hive/widget/filter_text_fileds/fiter_textfield.dart';
import 'package:bitpro_hive/widget/string_related/get_id_number.dart';
import 'package:bitpro_hive/widget/top_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:bitpro_hive/home/sales/receipt/receipt_create_edit_page.dart';
import 'package:bitpro_hive/model/customer_data.dart';
import 'package:bitpro_hive/model/receipt/db_receipt_data.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../../shared/custom_top_nav_bar.dart';
import '../../../shared/global_variables/font_sizes.dart';
import '../../../shared/global_variables/static_text_translate.dart';

class ReceiptPage extends StatefulWidget {
  final UserData userData;

  const ReceiptPage({Key? key, required this.userData}) : super(key: key);

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

var selectedDataGirdListerner = ValueNotifier<DataGridRow?>(null);

class _ReceiptPageState extends State<ReceiptPage> {
  CustomerDataSource? customerDataSource;
  DataGridController dataGridController = DataGridController();
  DateTime? rangeStartDate;
  DateTime? rangeEndDate;
  bool loading = true;
  var receiptIdController = TextEditingController();
  var customerNameController = TextEditingController();
  var customerPhoneController = TextEditingController();
  List<DbReceiptData> dbReceiptDataLst = [];
  List<CustomerData> customerDataLst = [];
  String? regularReturnDropDownFilter;

  String? selectedStoreDocId;
  List<StoreData> allStoreDataLst = [];

  @override
  void initState() {
    super.initState();
    fetchDataFromHive();
  }

  commonInit() async {
    print('comment ${dbReceiptDataLst.length}');
    dbReceiptDataLst.sort((b, a) => a.createdDate.compareTo(b.createdDate));
    //getting default selected store
    int selectedStoreCode = await HiveStoreDbService().getSelectedStoreCode();
    int index = allStoreDataLst.indexWhere(
        (element) => element.storeCode == selectedStoreCode.toString());

    if (index != -1) {
      selectedStoreDocId = allStoreDataLst.elementAt(index).docId;
    } else {
      selectedStoreDocId = allStoreDataLst.first.docId;
    }

    customerDataSource = CustomerDataSource(
        customerDataLst: customerDataLst,
        dbReceiptData: selectedStoreDocId == 'All'
            ? dbReceiptDataLst
            : dbReceiptDataLst
                .where((e) => e.selectedStoreDocId == selectedStoreDocId)
                .toList(),
        allStoreDataLst: allStoreDataLst);
    setState(() {
      loading = false;
    });
  }

  fetchDataFromHive() async {
    //stores data filter
    allStoreDataLst = await HiveStoreDbService().fetchAllStoresData();
    //vendor data
    customerDataLst = await HiveCustomerDbService().fetchAllCustomersData();
    //voucher data
    dbReceiptDataLst = await HiveReceiptDbService().fetchAllReceiptData();

    await commonInit();
  }

  fetchDataFromFb({bool fetchOnlyReceipt = false}) async {
    if (fetchOnlyReceipt == false) {
      //stores data filter
      allStoreDataLst =
          await FbStoreDbService(context: context).fetchAllStoresData();
      //
      //vendor data
      customerDataLst =
          await FbCustomerDbService(context: context).fetchAllCustomersData();
    }
    //voucher data
    dbReceiptDataLst =
        await FbReceiptDbService(context: context).fetchAllReceiptData();

    await commonInit();
  }

  filterAccordingSelectedDate() {
    List<DbReceiptData> filteredEmployeesDataLst = [];
    if (rangeStartDate != null && rangeEndDate != null) {
      for (var ug in selectedStoreDocId == 'All'
          ? dbReceiptDataLst
          : dbReceiptDataLst
              .where((e) => e.selectedStoreDocId == selectedStoreDocId)
              .toList()) {
        DateTime tmp = DateTime(
            ug.createdDate.year, ug.createdDate.month, ug.createdDate.day);
        if (tmp.compareTo(rangeStartDate!) != -1 &&
            (tmp.compareTo(rangeEndDate!) != 1)) {
          filteredEmployeesDataLst.add(ug);
        }
      }
    } else if (rangeStartDate != null) {
      var res = dbReceiptDataLst.where((e) =>
          e.createdDate.day == rangeStartDate!.day &&
          e.createdDate.month == rangeStartDate!.month &&
          e.createdDate.year == rangeStartDate!.year);

      filteredEmployeesDataLst = res.toList();
    }

    customerDataSource = CustomerDataSource(
        customerDataLst: customerDataLst,
        dbReceiptData: filteredEmployeesDataLst,
        allStoreDataLst: allStoreDataLst);
    rangeStartDate = null;
    rangeEndDate = null;
    setState(() {});
  }

  searchById(String id) {
    List<DbReceiptData> filteredVendorDataLst = [];
    if (id.isEmpty) {
      customerDataSource = CustomerDataSource(
          customerDataLst: customerDataLst,
          dbReceiptData: selectedStoreDocId == 'All'
              ? dbReceiptDataLst
              : dbReceiptDataLst
                  .where((e) => e.selectedStoreDocId == selectedStoreDocId)
                  .toList(),
          allStoreDataLst: allStoreDataLst);
      setState(() {});
      return;
    }

    for (var v in selectedStoreDocId == 'All'
        ? dbReceiptDataLst
        : dbReceiptDataLst
            .where((e) => e.selectedStoreDocId == selectedStoreDocId)
            .toList()) {
      if (v.receiptNo.toLowerCase().contains(id.toLowerCase())) {
        filteredVendorDataLst.add(v);
      }
    }
    customerDataSource = CustomerDataSource(
        customerDataLst: customerDataLst,
        dbReceiptData: filteredVendorDataLst,
        allStoreDataLst: allStoreDataLst);
    setState(() {});
  }

  searchByCustomerName(String val) {
    List<DbReceiptData> filteredVendorDataLst = [];
    if (val.isEmpty) {
      customerDataSource = CustomerDataSource(
          customerDataLst: customerDataLst,
          dbReceiptData: selectedStoreDocId == 'All'
              ? dbReceiptDataLst
              : dbReceiptDataLst
                  .where((e) => e.selectedStoreDocId == selectedStoreDocId)
                  .toList(),
          allStoreDataLst: allStoreDataLst);
      setState(() {});
      return;
    }

    for (var v in selectedStoreDocId == 'All'
        ? dbReceiptDataLst
        : dbReceiptDataLst
            .where((e) => e.selectedStoreDocId == selectedStoreDocId)
            .toList()) {
      String c = '';

      try {
        c = customerDataLst
            .firstWhere((element) => element.customerId == v.selectedCustomerID)
            .customerName;
      } catch (e) {}
      if (c.toLowerCase().contains(val.toLowerCase())) {
        filteredVendorDataLst.add(v);
      }
    }
    customerDataSource = CustomerDataSource(
        customerDataLst: customerDataLst,
        dbReceiptData: filteredVendorDataLst,
        allStoreDataLst: allStoreDataLst);
    setState(() {});
  }

  filterReturnRegularReceipt(String val) {
    List<DbReceiptData> filteredVendorDataLst = [];
    if (val.isEmpty || val == 'All') {
      customerDataSource = CustomerDataSource(
          customerDataLst: customerDataLst,
          dbReceiptData: selectedStoreDocId == 'All'
              ? dbReceiptDataLst
              : dbReceiptDataLst
                  .where((e) => e.selectedStoreDocId == selectedStoreDocId)
                  .toList(),
          allStoreDataLst: allStoreDataLst);
      setState(() {});
      return;
    }

    for (var v in selectedStoreDocId == 'All'
        ? dbReceiptDataLst
        : dbReceiptDataLst
            .where((e) => e.selectedStoreDocId == selectedStoreDocId)
            .toList()) {
      if (v.receiptType == regularReturnDropDownFilter) {
        filteredVendorDataLst.add(v);
      }
    }
    customerDataSource = CustomerDataSource(
        customerDataLst: customerDataLst,
        dbReceiptData: filteredVendorDataLst,
        allStoreDataLst: allStoreDataLst);
    setState(() {});
  }

  final Color dGvColor = const Color.fromARGB(255, 231, 231, 231);

  @override
  Widget build(BuildContext context) {
    return customTopNavBar(Scaffold(
      backgroundColor: homeBgColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const TopBar(
                  pageName: 'Receipt',
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
                              label: 'Create',
                              iconPath: 'assets/icons/plus.png',
                              buttonFunction: () async {
                                if (widget.userData.openRegister == null) {
                                  showRegisterClosedDialog();
                                } else {
                                  String newReceiptId = await getIdNumber(
                                      dbReceiptDataLst.length + 1);
                                  print(newReceiptId);
                                  bool? res = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CreateEditReceiptPage(
                                                currentReceiptId: newReceiptId,
                                                userData: widget.userData,
                                                customerDataLst:
                                                    customerDataLst,
                                              )));
                                  if (res != null && res) {
                                    setState(() {
                                      loading = true;
                                    });
                                    fetchDataFromFb(fetchOnlyReceipt: true);
                                  }
                                }
                              },
                            ),
                            SideMenuButton(
                              label: 'View',
                              iconPath: 'assets/icons/view.png',
                              buttonFunction: () async {
                                if (dataGridController.selectedRow != null) {
                                  var receiptNo = '';

                                  for (var c in dataGridController.selectedRow!
                                      .getCells()) {
                                    if (c.columnName == 'receipt') {
                                      receiptNo = c.value;
                                    }
                                  }

                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CreateEditReceiptPage(
                                                currentReceiptId: receiptNo,
                                                customerDataLst:
                                                    customerDataLst,
                                                selectedDbReceiptData:
                                                    dbReceiptDataLst.firstWhere(
                                                        (element) =>
                                                            element.receiptNo ==
                                                            receiptNo),
                                                viewMode: true,
                                                userData: widget.userData,
                                              )));
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
                                await fetchDataFromFb();
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
                          ],
                        ),
                      ),
                      Expanded(
                        child: Card(
                            shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Colors.grey, width: 0.5),
                                borderRadius: BorderRadius.circular(5)),
                            elevation: 0,
                            color: Colors.white,
                            child: Column(
                              children: [
                                //filter
                                filterWidget(),
                                if (loading) Expanded(child: showLoading()),
                                if (!loading)
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
                                          source: customerDataSource!,
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
                                                columnName: 'receipt',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            0.0),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      staticTextTranslate(
                                                          'Receipt #'),
                                                      style: GoogleFonts.roboto(
                                                        fontSize:
                                                            getMediumFontSize +
                                                                1,
                                                      ),
                                                    ))),
                                            GridColumn(
                                                columnName: 'type',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            1.0),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      staticTextTranslate(
                                                          'Type'),
                                                      style: GoogleFonts.roboto(
                                                        fontSize:
                                                            getMediumFontSize +
                                                                1,
                                                      ),
                                                    ))),
                                            GridColumn(
                                                columnName: 'customer',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            1.0),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      staticTextTranslate(
                                                          'Customer Name'),
                                                      style: GoogleFonts.roboto(
                                                        fontSize:
                                                            getMediumFontSize +
                                                                1,
                                                      ),
                                                    ))),
                                            GridColumn(
                                                columnName: 'orgTotal',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      staticTextTranslate(
                                                          'Original Total'),
                                                      style: GoogleFonts.roboto(
                                                        fontSize:
                                                            getMediumFontSize +
                                                                1,
                                                      ),
                                                    ))),
                                            GridColumn(
                                                columnName: 'disc%',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            1.0),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      staticTextTranslate(
                                                          'Disc %'),
                                                      style: GoogleFonts.roboto(
                                                        fontSize:
                                                            getMediumFontSize +
                                                                1,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ))),
                                            GridColumn(
                                                columnName: 'disc\$',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            1.0),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      staticTextTranslate(
                                                          'Disc \$'),
                                                      style: GoogleFonts.roboto(
                                                        fontSize:
                                                            getMediumFontSize +
                                                                1,
                                                      ),
                                                    ))),
                                            GridColumn(
                                                columnName: 'tax%',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            1.0),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      staticTextTranslate(
                                                          'Tax %'),
                                                      style: GoogleFonts.roboto(
                                                        fontSize:
                                                            getMediumFontSize +
                                                                1,
                                                      ),
                                                    ))),
                                            GridColumn(
                                                columnName: 'Tax \$',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            1.0),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      staticTextTranslate(
                                                          'Tax \$'),
                                                      style: GoogleFonts.roboto(
                                                        fontSize:
                                                            getMediumFontSize +
                                                                1,
                                                      ),
                                                    ))),
                                            GridColumn(
                                                columnName: 'store',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            1.0),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      staticTextTranslate(
                                                          'Store'),
                                                      style: GoogleFonts.roboto(
                                                        fontSize:
                                                            getMediumFontSize +
                                                                1,
                                                      ),
                                                    ))),
                                            GridColumn(
                                                columnName: 'paymentType',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            1.0),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      staticTextTranslate(
                                                          'Payment Type'),
                                                      style: GoogleFonts.roboto(
                                                        fontSize:
                                                            getMediumFontSize +
                                                                1,
                                                      ),
                                                    ))),
                                            GridColumn(
                                                columnName: 'receiptTotal',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            1.0),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      staticTextTranslate(
                                                          'Receipt Total'),
                                                      style: GoogleFonts.roboto(
                                                        fontSize:
                                                            getMediumFontSize +
                                                                1,
                                                      ),
                                                    ))),
                                            GridColumn(
                                                columnName: 'created date',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            1.0),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      staticTextTranslate(
                                                          'Created Date'),
                                                      style: GoogleFonts.roboto(
                                                        fontSize:
                                                            getMediumFontSize +
                                                                1,
                                                      ),
                                                    ))),
                                            GridColumn(
                                                columnName: 'created by',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            1.0),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      staticTextTranslate(
                                                          'Created by'),
                                                      style: GoogleFonts.roboto(
                                                        fontSize:
                                                            getMediumFontSize +
                                                                1,
                                                      ),
                                                    ))),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            )),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

          //loading data in background
          loadingInBgWidget()
        ],
      ),
    ));
  }

  filterWidget() {
    return FilterContainer(fiterFields: [
      FilterTextField(
        onPressed: () {
          receiptIdController.clear();

          customerDataSource = CustomerDataSource(
              customerDataLst: customerDataLst,
              dbReceiptData: selectedStoreDocId == 'All'
                  ? dbReceiptDataLst
                  : dbReceiptDataLst
                      .where((e) => e.selectedStoreDocId == selectedStoreDocId)
                      .toList(),
              allStoreDataLst: allStoreDataLst);
          setState(() {});
        },
        icon: Icon(
            receiptIdController.text.isEmpty
                ? CupertinoIcons.search
                : Icons.clear,
            size: 18,
            color: receiptIdController.text.isEmpty
                ? Colors.grey[600]
                : Colors.black),
        controller: receiptIdController,
        hintText: 'Receipt #',
        onChanged: (val) {
          searchById(val);
        },
      ),
      FilterTextField(
        onPressed: () {
          customerNameController.clear();

          customerDataSource = CustomerDataSource(
              customerDataLst: customerDataLst,
              dbReceiptData: selectedStoreDocId == 'All'
                  ? dbReceiptDataLst
                  : dbReceiptDataLst
                      .where((e) => e.selectedStoreDocId == selectedStoreDocId)
                      .toList(),
              allStoreDataLst: allStoreDataLst);
          setState(() {});
        },
        icon: Icon(
            customerNameController.text.isEmpty
                ? CupertinoIcons.search
                : Icons.clear,
            size: 18,
            color: customerNameController.text.isEmpty
                ? Colors.grey[600]
                : Colors.black),
        controller: customerNameController,
        hintText: 'Customer',
        onChanged: (val) {
          searchByCustomerName(val);
        },
      ),
      Container(
        width: 230,
        height: 32,
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
              onPressed: () {
                customerPhoneController.clear();

                customerDataSource = CustomerDataSource(
                    customerDataLst: customerDataLst,
                    dbReceiptData: selectedStoreDocId == 'All'
                        ? dbReceiptDataLst
                        : dbReceiptDataLst
                            .where((e) =>
                                e.selectedStoreDocId == selectedStoreDocId)
                            .toList(),
                    allStoreDataLst: allStoreDataLst);
                setState(() {});
              },
              splashRadius: 1,
              icon: Icon(
                  customerPhoneController.text.isEmpty
                      ? CupertinoIcons.search
                      : Icons.clear,
                  size: 18,
                  color: customerPhoneController.text.isEmpty
                      ? Colors.grey[600]
                      : Colors.black),
            ),
            Flexible(
                child: Container(
                    width: 200,
                    height: 32,
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.only(right: 10, left: 10),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: regularReturnDropDownFilter,
                      underline: const SizedBox(),
                      hint: Text(
                        staticTextTranslate('Receipt Type'),
                        style: TextStyle(
                          fontSize: getMediumFontSize + 2,
                        ),
                      ),
                      items: <String>['All', 'Regular', 'Return']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            staticTextTranslate(value),
                            style: TextStyle(
                              fontSize: getMediumFontSize + 2,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          regularReturnDropDownFilter = val;
                          filterReturnRegularReceipt(val ?? "");
                        });
                      },
                    ))),
          ],
        ),
      ),
      Container(
        width: 230,
        height: 32,
        decoration: BoxDecoration(
            border: Border.all(width: 0.5, color: Colors.grey),
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(4)),
        padding: const EdgeInsets.only(right: 3, bottom: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            Flexible(
                child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.only(right: 3, left: 5, top: 5, bottom: 5),
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

                          print(val);

                          print(dbReceiptDataLst
                              .map((element) => element.selectedStoreDocId)
                              .toList());
                          customerDataSource = CustomerDataSource(
                              customerDataLst: customerDataLst,
                              dbReceiptData: val == 'All'
                                  ? dbReceiptDataLst
                                  : dbReceiptDataLst
                                      .where((e) => e.selectedStoreDocId == val)
                                      .toList(),
                              allStoreDataLst: allStoreDataLst);
                          setState(() {});
                        }
                      },
                    ))),
          ],
        ),
      ),
    ]);
  }

  Widget loadingInBgWidget() {
    //loading data in background
    if (context.watch<FetchingDataProvider>().fetching) {
      return Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          color: Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Text('${context.watch<FetchingDataProvider>().info}....'),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  showRegisterClosedDialog() {
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(builder: (context, setState2) {
              return Dialog(
                  backgroundColor: homeBgColor,
                  child: Container(
                    height: 160,
                    width: 400,
                    padding: const EdgeInsets.only(
                        top: 25, left: 10, right: 10, bottom: 10),
                    child: Column(children: [
                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.exclamationmark_circle,
                            color: Color.fromARGB(255, 227, 87, 87),
                            size: 30,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                staticTextTranslate('Register is Closed'),
                                style:
                                    TextStyle(fontSize: getMediumFontSize + 5),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                staticTextTranslate(
                                    'Please open the register to start selling'),
                                style: TextStyle(
                                  fontSize: getMediumFontSize - 1,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      const Expanded(
                          child: SizedBox(
                        height: 10,
                      )),
                      SizedBox(
                        height: 45,
                        width: 380,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: darkBlueColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4))),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.cancel_outlined,
                                    color: Color.fromARGB(255, 233, 233, 233),
                                    size: 19),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(staticTextTranslate('Close'),
                                    style: TextStyle(
                                        fontSize: getMediumFontSize,
                                        color: Colors.white)),
                              ],
                            )),
                      ),
                    ]),
                  ));
            }));
  }
}

class CustomerDataSource extends DataGridSource {
  CustomerDataSource(
      {required List<DbReceiptData> dbReceiptData,
      required List<CustomerData> customerDataLst,
      required List<StoreData> allStoreDataLst}) {
    _employeeData = dbReceiptData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(
                  columnName: 'serialNumberForStyleColor',
                  value: dbReceiptData.indexOf(e) + 1),
              DataGridCell<String>(columnName: 'receipt', value: e.receiptNo),
              DataGridCell<String>(columnName: 'type', value: e.receiptType),
              DataGridCell<String>(
                  columnName: 'customer',
                  value: e.selectedCustomerID.isEmpty
                      ? ''
                      : customerDataLst.any((element) =>
                                  element.customerId == e.selectedCustomerID) ==
                              false
                          ? 'Customer not found'
                          : customerDataLst
                              .firstWhere((element) =>
                                  element.customerId == e.selectedCustomerID)
                              .customerName),
              DataGridCell<String>(
                  columnName: 'orgTotal', value: e.receiptTotal),
              DataGridCell<String>(
                  columnName: 'disc%', value: e.discountPercentage),
              DataGridCell<String>(
                  columnName: 'disc\$', value: e.discountValue),
              DataGridCell<String>(columnName: 'tax%', value: e.taxPer),
              DataGridCell<String>(columnName: 'tax\$', value: e.taxValue),
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
                  columnName: 'paymentType', value: 'paymentType'

                  // e.tendor.credit != '0' && e.tendor.credit != '0.0'
                  //     ? 'Credit'
                  //     : e.tendor.cash != '0' && e.tendor.creditCard == '0'
                  //         ? 'Cash'
                  //         : e.tendor.cash == '0' && e.tendor.creditCard != '0'
                  //             ? 'Credit Card'
                  //             : 'Split'
                  ),
              DataGridCell<String>(
                  columnName: 'receiptTotal', value: e.receiptTotal),
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
    bool isReturnReceipt = false;

    if (row
            .getCells()
            .indexWhere((e) => e.columnName == 'type' && e.value == 'Return') !=
        -1) isReturnReceipt = true;
    return DataGridRowAdapter(
        color: row.getCells()[0].value.isEven
            ? const Color(0xffF1F1F1)
            : Colors.white,
        cells: row.getCells().map<Widget>((e) {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(0.0),
            child: Text(
              e.value.toString(),
              style: GoogleFonts.roboto(
                  fontSize: getMediumFontSize + 1,
                  color: isReturnReceipt ? Colors.red[700] : Colors.black,
                  fontWeight: FontWeight.w400),
            ),
          );
        }).toList());
  }
}
