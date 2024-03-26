import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:bitpro_hive/home/sales/customer/sideMenuButton.dart';
import 'package:bitpro_hive/services/firestore_api/fb_merchandise/fb_vendor_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_merchandise/fb_vendor_payment_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_vouchers/fb_voucher_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_merchandise_db_service/vendors_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_voucher_db_service/hive_voucher_db_service.dart';
import 'package:bitpro_hive/widget/filter_container.dart';
import 'package:bitpro_hive/widget/filter_text_fileds/fiter_textfield.dart';
import 'package:bitpro_hive/widget/top_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/model/vendor_data.dart';
import 'package:bitpro_hive/shared/custom_top_nav_bar.dart';
import 'package:bitpro_hive/shared/loading.dart';
import 'package:bitpro_hive/shared/global_variables/static_text_translate.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../../../model/vendor_payment_data.dart';
import '../../../../model/voucher/db_voucher_data.dart';
import '../../../../shared/global_variables/font_sizes.dart';
import '../../../../shared/templates/customer_and_vendor_payment_templates/vendor_payment_template.dart';

class VendorPaymentPage extends StatefulWidget {
  final UserData userData;
  final VendorData selectedVendorData;

  const VendorPaymentPage(
      {Key? key, required this.userData, required this.selectedVendorData})
      : super(key: key);

  @override
  State<VendorPaymentPage> createState() => _VendorPaymentPageState();
}

var selectedDataGirdListerner = ValueNotifier<DataGridRow?>(null);

class _VendorPaymentPageState extends State<VendorPaymentPage> {
  DataGridController dataGridController = DataGridController();
  String searchId = '';
  String searchPhone1 = '';
  String searchName = '';
  DateTime? rangeStartDate;
  DateTime? rangeEndDate;
  bool loading = true;
  var vendorIdController = TextEditingController();

  var vendorPhoneController = TextEditingController();
  var vendorNameController = TextEditingController();

  //
  List<DbVoucherData> dbVoucherDataLst = [];
  VendorPaymentDataSource? vendorPaymentDataSource;
  final TextEditingController _vendorTypeAheadController =
      TextEditingController();
  List<VendorPaymentData> allVendorPaymentLstData = [];
  List<VendorPaymentData> currentVendorPaymentLstData = [];
  String vendorTypeDropDownFilter = 'All Document';

  List<VendorData> allVendorDataLst = [];
  @override
  void initState() {
    hiveInitInfo();
    super.initState();
  }

  commonInit() async {
    currentVendorPaymentLstData = allVendorPaymentLstData
        .where(
            (element) => element.vendorId == widget.selectedVendorData.vendorId)
        .toList();

    currentVendorPaymentLstData
        .sort((b, a) => a.createdDate.compareTo(b.createdDate));

    vendorPaymentDataSource = VendorPaymentDataSource(
        voucherDataLst: dbVoucherDataLst,
        selectedVendorData: widget.selectedVendorData,
        vendorPaymentData: currentVendorPaymentLstData);
    setState(() {
      loading = false;
    });
  }

  hiveInitInfo() async {
    //voucher data
    List<DbVoucherData> dbVoucherAllDataLst =
        await HiveVoucherDbService().fetchAllVoucherData();
    allVendorDataLst = await HiveVendorDbService().fetchAllVendorsData();
    dbVoucherDataLst = dbVoucherAllDataLst
        .where(
            (element) => element.vendor == widget.selectedVendorData.vendorId)
        .toList();

    allVendorPaymentLstData = await FbVendorPaymentDbService(context: context)
        .fetchAllVendorsPaymentData();
    await commonInit();
  }

  fbInitInfo() async {
    //voucher data
    List<DbVoucherData> dbVoucherAllDataLst =
        await FbVoucherDbService(context: context).fetchAllVoucherData();
    allVendorDataLst =
        await FbVendorDbService(context: context).fetchAllVendorsData();
    dbVoucherDataLst = dbVoucherAllDataLst
        .where(
            (element) => element.vendor == widget.selectedVendorData.vendorId)
        .toList();

    allVendorPaymentLstData = await FbVendorPaymentDbService(context: context)
        .fetchAllVendorsPaymentData();
    await commonInit();
  }

  String calculateTotalPaid() {
    double t = 0;

    for (VendorPaymentData v in currentVendorPaymentLstData) {
      t += v.amount;
    }

    return t.toStringAsFixed(2);
  }

  String calculateTotalAmtPurchase() {
    double regularT = 0;

    for (DbVoucherData d in dbVoucherDataLst) {
      if (d.voucherType == 'Regular') {
        regularT += double.parse(d.voucherTotal);
      } else {
        regularT -= double.parse(d.voucherTotal);
      }
    }
    regularT += double.tryParse(widget.selectedVendorData.openingBalance) ?? 0;

    return regularT.toStringAsFixed(2);
  }

  filterAccordingSelectedDate() {
    List<DbVoucherData> filteredVoucherDataLst = [];
    List<VendorPaymentData> filteredVendorPaymentData = [];
    if (rangeStartDate != null && rangeEndDate != null) {
      for (var r in dbVoucherDataLst) {
        DateTime tmp = DateTime(
            r.createdDate.year, r.createdDate.month, r.createdDate.day);
        if (tmp.compareTo(rangeStartDate!) != -1 &&
            (tmp.compareTo(rangeEndDate!) != 1)) {
          filteredVoucherDataLst.add(r);
        }
      }
      for (var c in currentVendorPaymentLstData) {
        DateTime tmp = DateTime(
            c.createdDate.year, c.createdDate.month, c.createdDate.day);
        if (tmp.compareTo(rangeStartDate!) != -1 &&
            (tmp.compareTo(rangeEndDate!) != 1)) {
          filteredVendorPaymentData.add(c);
        }
      }
    } else if (rangeStartDate != null) {
      var res1 = dbVoucherDataLst.where((e) =>
          e.createdDate.day == rangeStartDate!.day &&
          e.createdDate.month == rangeStartDate!.month &&
          e.createdDate.year == rangeStartDate!.year);

      filteredVoucherDataLst = res1.toList();
      var res2 = currentVendorPaymentLstData.where((e) =>
          e.createdDate.day == rangeStartDate!.day &&
          e.createdDate.month == rangeStartDate!.month &&
          e.createdDate.year == rangeStartDate!.year);

      filteredVendorPaymentData = res2.toList();
    }

    vendorPaymentDataSource = VendorPaymentDataSource(
        voucherDataLst: filteredVoucherDataLst,
        selectedVendorData: widget.selectedVendorData,
        vendorPaymentData: filteredVendorPaymentData);
    rangeStartDate = null;
    rangeEndDate = null;
    setState(() {});
  }

  searchById(String id) {
    List<DbVoucherData> filteredDbVoucherDataLst = [];
    List<VendorPaymentData> filteredVendorPaymentData = [];

    if (id.isEmpty) {
      vendorPaymentDataSource = VendorPaymentDataSource(
          voucherDataLst: dbVoucherDataLst,
          selectedVendorData: widget.selectedVendorData,
          vendorPaymentData: currentVendorPaymentLstData);
      setState(() {});
      return;
    }

    for (var v in dbVoucherDataLst) {
      if (v.voucherNo.toLowerCase().contains(id.toLowerCase())) {
        filteredDbVoucherDataLst.add(v);
      }
    }
    for (var c in allVendorPaymentLstData) {
      if (('VP${c.documentNo}').toLowerCase().contains(id.toLowerCase())) {
        filteredVendorPaymentData.add(c);
      }
    }
    vendorPaymentDataSource = VendorPaymentDataSource(
        voucherDataLst: filteredDbVoucherDataLst,
        selectedVendorData: widget.selectedVendorData,
        vendorPaymentData: filteredVendorPaymentData);
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
              const TopBar(
                pageName: 'Vendor Payment',
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
                            label: 'Pay',
                            iconPath: 'assets/icons/back.png',
                            buttonFunction: () async {
                              vendorPayment(
                                  selectedVendorData: widget.selectedVendorData,
                                  paymentType: 'Cash',
                                  amount: 0,
                                  comment: '',
                                  docId: '',
                                  documentNo: '',
                                  createdDate: DateTime.now());
                            },
                          ),
                          SideMenuButton(
                            label: 'Edit',
                            iconPath: 'assets/icons/edit.png',
                            buttonFunction: () async {
                              if (dataGridController.selectedRow != null &&
                                  dataGridController.selectedRow!
                                          .getCells()
                                          .indexWhere((e) =>
                                              e.columnName == 'doc' &&
                                              e.value == 'Payment') !=
                                      -1) {
                                var id = '';

                                for (var c in dataGridController.selectedRow!
                                    .getCells()) {
                                  if (c.columnName == 'doc#') {
                                    id = c.value;
                                  }
                                }
                                int i = currentVendorPaymentLstData.indexWhere(
                                    (element) =>
                                        element.documentNo ==
                                        id.replaceAll('VP', ''));

                                if (i != -1) {
                                  vendorPayment(
                                      selectedVendorData:
                                          widget.selectedVendorData,
                                      paymentType: currentVendorPaymentLstData
                                          .elementAt(i)
                                          .paymentType,
                                      amount: currentVendorPaymentLstData
                                          .elementAt(i)
                                          .amount,
                                      comment: currentVendorPaymentLstData
                                          .elementAt(i)
                                          .comment,
                                      docId: currentVendorPaymentLstData
                                          .elementAt(i)
                                          .docId,
                                      documentNo: currentVendorPaymentLstData
                                          .elementAt(i)
                                          .documentNo,
                                      createdDate: currentVendorPaymentLstData
                                          .elementAt(i)
                                          .createdDate);
                                }
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
                              await fbInitInfo();
                            },
                          ),
                          const SizedBox(
                            height: 30,
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
                            label: 'Print',
                            iconPath: 'assets/icons/print.png',
                            buttonFunction: () async {
                              List<VendorPaymentTempModel>
                                  allVendorPaymentData = dbVoucherDataLst
                                          .map<VendorPaymentTempModel>((e) =>
                                              VendorPaymentTempModel(
                                                  dateTime: e.createdDate,
                                                  dbVoucherData: e))
                                          .toList() +
                                      currentVendorPaymentLstData
                                          .map<VendorPaymentTempModel>((e) =>
                                              VendorPaymentTempModel(
                                                  dateTime: e.createdDate,
                                                  vendorPaymentData: e))
                                          .toList();
                              allVendorPaymentData.sort(
                                  (a, b) => a.dateTime.compareTo(b.dateTime));

                              printVendorPayment(
                                  context,
                                  allVendorPaymentData,
                                  widget.selectedVendorData,
                                  calculateTotalAmtPurchase(),
                                  calculateTotalPaid(),
                                  (double.parse(calculateTotalAmtPurchase()) -
                                          double.parse(calculateTotalPaid()))
                                      .toStringAsFixed(2));
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
                              borderRadius: BorderRadius.circular(4)),
                          elevation: 0,
                          color: Colors.white,
                          child: Column(
                            children: [
                              filterWidget(),
                              if (loading)
                                Expanded(
                                    child: SizedBox(
                                        height: 300, child: showLoading()))
                              else
                                Expanded(
                                  child: SfDataGridTheme(
                                    data: SfDataGridThemeData(
                                        headerColor: const Color(0xffdddfe8),
                                        headerHoverColor:
                                            const Color(0xffdddfe8),
                                        selectionColor: loginBgColor),
                                    child: SfDataGrid(
                                      gridLinesVisibility:
                                          GridLinesVisibility.both,
                                      isScrollbarAlwaysShown: true,
                                      onQueryRowHeight: (details) {
                                        // Set the row height as 70.0 to the column header row.
                                        return details.rowIndex == 0
                                            ? 25.0
                                            : 24.0;
                                      },
                                      rowHeight: 25,
                                      headerGridLinesVisibility:
                                          GridLinesVisibility.both,
                                      allowSorting: false,
                                      allowTriStateSorting: true,
                                      controller: dataGridController,
                                      selectionMode: SelectionMode.single,
                                      source: vendorPaymentDataSource!,
                                      columnWidthMode: ColumnWidthMode.fill,
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
                                                    const EdgeInsets.all(0.0),
                                                alignment: Alignment.center,
                                                color: Colors.white,
                                                child: Text(
                                                  'serialNumberForStyleColor',
                                                  style: TextStyle(
                                                    fontSize: getMediumFontSize,
                                                  ),
                                                ))),
                                        GridColumn(
                                            columnName: 'doc',
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                alignment: Alignment.center,
                                                color: const Color(0xffdddfe8),
                                                child: Text(
                                                    staticTextTranslate(
                                                        'Document'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize,
                                                    )))),
                                        GridColumn(
                                            columnName: 'doc#',
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                alignment: Alignment.center,
                                                color: const Color(0xffdddfe8),
                                                child: Text(
                                                    staticTextTranslate(
                                                        'Document#'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize,
                                                    )))),
                                        GridColumn(
                                            columnName: 'doc type',
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                alignment: Alignment.center,
                                                color: const Color(0xffdddfe8),
                                                child: Text(
                                                  staticTextTranslate(
                                                      'Doc Type'),
                                                  style: TextStyle(
                                                    fontSize: getMediumFontSize,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ))),
                                        GridColumn(
                                            columnName: 'creadted date',
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                color: const Color(0xffdddfe8),
                                                alignment: Alignment.center,
                                                child: Text(
                                                    staticTextTranslate(
                                                        'Created Date'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize,
                                                    )))),
                                        GridColumn(
                                            columnName: 'payment',
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                color: const Color(0xffdddfe8),
                                                alignment: Alignment.center,
                                                child: Text(
                                                    staticTextTranslate(
                                                        'Payment'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize,
                                                    )))),
                                        GridColumn(
                                            columnName: 'comment',
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                color: const Color(0xffdddfe8),
                                                alignment: Alignment.center,
                                                child: Text(
                                                    staticTextTranslate(
                                                        'Comment'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize,
                                                    )))),
                                        GridColumn(
                                            columnName: 'purchased amount',
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                color: const Color(0xffdddfe8),
                                                alignment: Alignment.center,
                                                child: Text(
                                                    staticTextTranslate(
                                                        'Purchased Amount'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize,
                                                    )))),
                                        GridColumn(
                                            columnName: 'paid amount',
                                            label: Container(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                color: const Color(0xffdddfe8),
                                                alignment: Alignment.center,
                                                child: Text(
                                                    staticTextTranslate(
                                                        'Paid Amount'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize,
                                                    )))),
                                      ],
                                    ),
                                  ),
                                ),
                              if (!loading)
                                Container(
                                  height: 110,
                                  color: const Color(0xffdddfe8),
                                  width: double.maxFinite,
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                staticTextTranslate(
                                                    'Total Amt Purchase'),
                                                style: TextStyle(
                                                  fontSize:
                                                      getMediumFontSize - 1,
                                                )),
                                            Text(
                                              calculateTotalAmtPurchase(),
                                              style: TextStyle(
                                                fontSize: getMediumFontSize + 4,
                                              ),
                                            ),
                                            const Expanded(
                                              child: SizedBox(
                                                height: 10,
                                              ),
                                            ),
                                            Text(staticTextTranslate('Balance'),
                                                style: TextStyle(
                                                  fontSize:
                                                      getMediumFontSize - 1,
                                                )),
                                            Text(
                                              (double.parse(
                                                          calculateTotalAmtPurchase()) -
                                                      double.parse(
                                                          calculateTotalPaid()))
                                                  .toStringAsFixed(2),
                                              style: TextStyle(
                                                fontSize: getMediumFontSize + 4,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 35,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                staticTextTranslate(
                                                    'Total Paid'),
                                                style: TextStyle(
                                                  fontSize:
                                                      getMediumFontSize - 1,
                                                )),
                                            Text(
                                              calculateTotalPaid(),
                                              style: TextStyle(
                                                fontSize: getMediumFontSize + 4,
                                                color: const Color.fromARGB(
                                                    255, 23, 171, 31),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                      ]),
                                )
                            ],
                          )),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  filterWidget() {
    return FilterContainer(
      trailingWidget: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Icon(
                Iconsax.people,
                size: 19,
                color: Colors.white,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                widget.selectedVendorData.vendorName,
                style: TextStyle(
                  fontSize: getLargeFontSize + 2,
                  color: Colors.white,
                ),
              ),
            ],
          )),
      fiterFields: [
        FilterTextField(
          onPressed: () {
            vendorIdController.clear();

            // vendorDataSource =
            //     VendorPaymentDataSource(
            //         vendorData:
            //             globalVendorDataLst);
            setState(() {});
          },
          icon: Icon(
              vendorIdController.text.isEmpty
                  ? CupertinoIcons.search
                  : Icons.clear,
              size: 18,
              color: vendorIdController.text.isEmpty
                  ? Colors.grey[600]
                  : Colors.black),
          controller: vendorIdController,
          hintText: 'Voucher# / PV#',
          onChanged: (val) {
            searchById(val);
          },
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          width: 230,
          height: 30,
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
                onPressed: () {},
                splashRadius: 1,
                icon: Icon(CupertinoIcons.search,
                    size: 18, color: Colors.grey[600]),
              ),
              Flexible(
                  child: Container(
                      width: 200,
                      height: 35,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.only(right: 10, left: 10),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: vendorTypeDropDownFilter,
                        underline: const SizedBox(),
                        hint: Text(staticTextTranslate('All Document'),
                            style: TextStyle(
                              fontSize: getMediumFontSize,
                            )),
                        items: <String>['All Document', 'Voucher', 'Payment']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(staticTextTranslate(value),
                                style: TextStyle(
                                  fontSize: getMediumFontSize + 2,
                                )),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            if (val == 'Voucher') {
                              vendorPaymentDataSource = VendorPaymentDataSource(
                                  voucherDataLst: dbVoucherDataLst,
                                  selectedVendorData: widget.selectedVendorData,
                                  vendorPaymentData: []);
                            } else if (val == 'Payment') {
                              vendorPaymentDataSource = VendorPaymentDataSource(
                                  voucherDataLst: [],
                                  selectedVendorData: widget.selectedVendorData,
                                  vendorPaymentData:
                                      currentVendorPaymentLstData);
                            } else {
                              vendorPaymentDataSource = VendorPaymentDataSource(
                                  voucherDataLst: dbVoucherDataLst,
                                  selectedVendorData: widget.selectedVendorData,
                                  vendorPaymentData:
                                      currentVendorPaymentLstData);
                            }
                            vendorTypeDropDownFilter = val ?? 'All Document';
                          });
                        },
                      )))
            ],
          ),
        ),
      ],
    );
  }

  vendorPayment(
      {required VendorData selectedVendorData,
      required String paymentType,
      required double amount,
      required String comment,
      required String docId,
      required String documentNo,
      required DateTime createdDate}) {
    _vendorTypeAheadController.text = selectedVendorData.vendorName;
    bool showloading = false;
    var formKey = GlobalKey<FormState>();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(builder: (context, setState2) {
              return Dialog(
                backgroundColor: homeBgColor,
                child: SizedBox(
                    height: 405,
                    width: 550,
                    child: showloading
                        ? showLoading()
                        : Column(
                            children: [
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
                                        staticTextTranslate('Vendor Payment'),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: getMediumFontSize + 5,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(
                                                  height: 15,
                                                ),
                                                Text(
                                                    staticTextTranslate(
                                                        'Vendor'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize - 1,
                                                    )),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                SizedBox(
                                                  width: 250,
                                                  child: TypeAheadFormField(
                                                    getImmediateSuggestions:
                                                        false,
                                                    textFieldConfiguration:
                                                        TextFieldConfiguration(
                                                      style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  2,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                      controller:
                                                          _vendorTypeAheadController,
                                                      decoration: InputDecoration(
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 10,
                                                                  horizontal:
                                                                      13),
                                                          isDense: true,
                                                          hintStyle: TextStyle(
                                                              color: Colors
                                                                  .grey[600]),
                                                          border:
                                                              const OutlineInputBorder()),
                                                    ),
                                                    validator: (val) {
                                                      if (val!.isEmpty) {
                                                        return staticTextTranslate(
                                                            'Select a vendor');
                                                      }
                                                      return null;
                                                    },
                                                    noItemsFoundBuilder:
                                                        (context) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10.0),
                                                        child: Text(
                                                            staticTextTranslate(
                                                                'No Items Found!'),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  getMediumFontSize,
                                                            )),
                                                      );
                                                    },
                                                    suggestionsCallback:
                                                        (pattern) {
                                                      return allVendorDataLst
                                                          .where((e) => e
                                                              .vendorName
                                                              .toLowerCase()
                                                              .contains(pattern
                                                                  .toLowerCase()))
                                                          .toList();
                                                    },
                                                    itemBuilder: (context,
                                                        VendorData suggestion) {
                                                      return ListTile(
                                                        title: Text(
                                                            suggestion
                                                                .vendorName,
                                                            style: TextStyle(
                                                              fontSize:
                                                                  getMediumFontSize,
                                                            )),
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
                                                      _vendorTypeAheadController
                                                              .text =
                                                          suggestion.vendorName;

                                                      setState(() {
                                                        int i = allVendorDataLst
                                                            .indexWhere((element) =>
                                                                element
                                                                    .vendorId ==
                                                                suggestion
                                                                    .vendorId);
                                                        selectedVendorData =
                                                            allVendorDataLst
                                                                .elementAt(i);
                                                      });
                                                      setState2(() {});
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 15,
                                                ),
                                                Text(
                                                    staticTextTranslate(
                                                        'Payment type'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize - 1,
                                                    )),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Container(
                                                    width: 250,
                                                    height: 32,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                        border: Border.all(
                                                            color:
                                                                Colors.grey)),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10),
                                                    child:
                                                        DropdownButton<String>(
                                                      isExpanded: true,
                                                      value: paymentType,
                                                      underline:
                                                          const SizedBox(),
                                                      itemHeight: 50,
                                                      items: <String>[
                                                        'Cash',
                                                        'Bank'
                                                      ].map((String value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Text(
                                                              staticTextTranslate(
                                                                  value),
                                                              style: TextStyle(
                                                                fontSize:
                                                                    getMediumFontSize +
                                                                        2,
                                                              )),
                                                        );
                                                      }).toList(),
                                                      onChanged: (val) {
                                                        if (val != null) {
                                                          setState(() {
                                                            paymentType = val;
                                                          });
                                                          setState2(() {});
                                                        }
                                                      },
                                                    )),
                                                const SizedBox(
                                                  height: 15,
                                                ),
                                                Text(
                                                    staticTextTranslate(
                                                        'Amount'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize - 1,
                                                    )),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                SizedBox(
                                                  width: 250,
                                                  child: Form(
                                                    key: formKey,
                                                    child: TextFormField(
                                                        autovalidateMode:
                                                            AutovalidateMode
                                                                .onUserInteraction,
                                                        validator: (val) {
                                                          if (val!.isEmpty ||
                                                              double.tryParse(
                                                                      val) ==
                                                                  null ||
                                                              double.parse(val)
                                                                  .isNegative) {
                                                            return staticTextTranslate(
                                                                'Enter a valid amount');
                                                          } else if (double
                                                                  .tryParse(
                                                                      val) ==
                                                              0) {
                                                            return staticTextTranslate(
                                                                'Please enter an amount');
                                                          }
                                                          return null;
                                                        },
                                                        initialValue:
                                                            amount.toString(),
                                                        style: const TextStyle(
                                                            fontSize: 16),
                                                        decoration: const InputDecoration(
                                                            isDense: true,
                                                            contentPadding:
                                                                EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            10,
                                                                        horizontal:
                                                                            15),
                                                            border:
                                                                OutlineInputBorder()),
                                                        onChanged: (val) {
                                                          if (val.isNotEmpty &&
                                                              double.tryParse(
                                                                      val) !=
                                                                  null) {
                                                            setState(() {
                                                              amount =
                                                                  double.parse(
                                                                      val);
                                                            });
                                                            setState2(() {});
                                                          }
                                                        }),
                                                  ),
                                                ),
                                              ]),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              Text(
                                                  staticTextTranslate(
                                                      'Comment'),
                                                  style: TextStyle(
                                                    fontSize: getMediumFontSize,
                                                  )),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              SizedBox(
                                                width: 250,
                                                child: TextFormField(
                                                    autofocus: true,
                                                    initialValue: comment,
                                                    maxLines: 4,
                                                    autovalidateMode:
                                                        AutovalidateMode
                                                            .onUserInteraction,
                                                    validator: (val) {
                                                      if (val!.isEmpty) {
                                                        return staticTextTranslate(
                                                            'Please enter a comment');
                                                      }
                                                      return null;
                                                    },
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                    decoration: const InputDecoration(
                                                        isDense: true,
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        15,
                                                                    horizontal:
                                                                        15),
                                                        border:
                                                            OutlineInputBorder()),
                                                    onChanged: (val) {
                                                      if (val.isNotEmpty) {
                                                        setState(() {
                                                          comment = val;
                                                        });
                                                        setState2(() {});
                                                      }
                                                    }),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  width: 560,
                                  height: 62,
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
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                    Icons.cancel_outlined,
                                                    color: Colors.black,
                                                    size: 20),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                    staticTextTranslate(
                                                        'Cancel'),
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
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            gradient: const LinearGradient(
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Color(0xff092F53),
                                                  Color(0xff284F70),
                                                ],
                                                begin: Alignment.topCenter)),
                                        height: 42,
                                        width: 173,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4))),
                                            onPressed: () async {
                                              if (formKey.currentState!
                                                  .validate()) {
                                                setState(() {
                                                  showloading = true;
                                                });
                                                String docNo = documentNo;
                                                if (documentNo.isEmpty) {
                                                  docNo = '100001';

                                                  List<VendorPaymentData>
                                                      selectedVendorPaymentLstData =
                                                      allVendorPaymentLstData
                                                          .where((element) =>
                                                              element
                                                                  .vendorId ==
                                                              selectedVendorData
                                                                  .vendorId)
                                                          .toList();
                                                  selectedVendorPaymentLstData
                                                      .sort((a, b) => a
                                                          .createdDate
                                                          .compareTo(
                                                              b.createdDate));
                                                  if (selectedVendorPaymentLstData
                                                      .isNotEmpty) {
                                                    docNo = (int.parse(
                                                                selectedVendorPaymentLstData
                                                                    .last
                                                                    .documentNo) +
                                                            1)
                                                        .toString();
                                                  }
                                                }
                                                await FbVendorPaymentDbService(
                                                        context: context)
                                                    .addVendorPaymentData([
                                                  VendorPaymentData(
                                                      docId: docId.isEmpty
                                                          ? getRandomString(20)
                                                          : docId,
                                                      vendorId:
                                                          selectedVendorData
                                                              .vendorId,
                                                      paymentType: paymentType,
                                                      amount: amount,
                                                      createdDate: createdDate,
                                                      comment: comment,
                                                      documentNo: docNo)
                                                ]);

                                                await fbInitInfo();
                                                Navigator.pop(context);
                                              }
                                            },
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
                                                Text(
                                                    staticTextTranslate('Save'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize,
                                                    )),
                                              ],
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )),
              );
            }));
  }
}

class VendorPaymentDataSource extends DataGridSource {
  VendorPaymentDataSource(
      {required List<DbVoucherData> voucherDataLst,
      required List<VendorPaymentData> vendorPaymentData,
      required VendorData selectedVendorData}) {
    List<VendorPaymentTempModel> allVendorPaymentData = voucherDataLst
            .map<VendorPaymentTempModel>((e) => VendorPaymentTempModel(
                dateTime: e.createdDate, dbVoucherData: e))
            .toList() +
        vendorPaymentData
            .map<VendorPaymentTempModel>((e) => VendorPaymentTempModel(
                dateTime: e.createdDate, vendorPaymentData: e))
            .toList();
    allVendorPaymentData.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    _employeeData = [
          DataGridRow(cells: [
            const DataGridCell<int>(
                columnName: 'serialNumberForStyleColor', value: 0),
            const DataGridCell<String>(
                columnName: 'doc', value: 'Opening Balance'),
            const DataGridCell<String>(columnName: 'doc#', value: ''),
            const DataGridCell<String>(columnName: 'doc type', value: ''),
            const DataGridCell<String>(columnName: 'creadted date', value: ''),
            const DataGridCell<String>(columnName: 'payment', value: ''),
            const DataGridCell<String>(columnName: 'comment', value: ''),
            DataGridCell<String>(
                columnName: 'purchased amount',
                value: selectedVendorData.openingBalance),
            const DataGridCell<String>(columnName: 'paid amount', value: ''),
          ])
        ] +
        allVendorPaymentData
            .map<DataGridRow>((e) => DataGridRow(cells: [
                  DataGridCell<int>(
                      columnName: 'serialNumberForStyleColor',
                      value: allVendorPaymentData.indexOf(e) + 0),
                  DataGridCell<String>(
                      columnName: 'doc',
                      value: e.dbVoucherData != null ? 'Voucher' : 'Payment'),
                  DataGridCell<String>(
                      columnName: 'doc#',
                      value: e.dbVoucherData != null
                          ? e.dbVoucherData!.voucherNo
                          : 'VP${e.vendorPaymentData!.documentNo}'),
                  DataGridCell<String>(
                      columnName: 'doc type',
                      value: e.dbVoucherData != null
                          ? e.dbVoucherData!.voucherType
                          : ''),
                  DataGridCell<String>(
                      columnName: 'creadted date',
                      value: DateFormat.yMd().add_jm().format(e.dateTime)),
                  DataGridCell<String>(
                      columnName: 'payment',
                      value: e.dbVoucherData != null
                          ? ''
                          : e.vendorPaymentData!.paymentType),
                  DataGridCell<String>(
                      columnName: 'comment',
                      value: e.dbVoucherData != null
                          ? ''
                          : e.vendorPaymentData!.comment),
                  DataGridCell<String>(
                      columnName: 'purchased amount',
                      value: e.dbVoucherData != null
                          ? e.dbVoucherData!.voucherTotal
                          : ''),
                  DataGridCell<String>(
                      columnName: 'paid amount',
                      value: e.dbVoucherData != null
                          ? ''
                          : e.vendorPaymentData!.amount.toString()

                      //  ''
                      ),
                ]))
            .toList();
  }

  List<DataGridRow> _employeeData = [];

  @override
  List<DataGridRow> get rows => _employeeData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    bool isReturnVoucher = false;

    if (row.getCells().indexWhere(
            (e) => e.columnName == 'doc type' && e.value == 'Return') !=
        -1) isReturnVoucher = true;
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
                  color: isReturnVoucher ? Colors.red[700] : Colors.black,
                  fontWeight: FontWeight.w400),
            ),
          );
        }).toList());
  }
}
