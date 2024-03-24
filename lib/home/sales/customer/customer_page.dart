import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:bitpro_hive/home/sales/customer/sideMenuButton.dart';
import 'package:bitpro_hive/services/firestore_api/fb_sales/fb_customer_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_sales_db_service/hive_customer_db_service.dart';
import 'package:bitpro_hive/widget/filter_container.dart';
import 'package:bitpro_hive/widget/filter_text_fileds/fiter_textfield.dart';
import 'package:bitpro_hive/widget/string_related/get_id_number.dart';
import 'package:bitpro_hive/widget/top_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:bitpro_hive/home/sales/customer/customer_create_page.dart';
import 'package:bitpro_hive/home/sales/customer/customer_payment/customer_payment_page.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/shared/custom_top_nav_bar.dart';
import 'package:bitpro_hive/shared/loading.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../../model/customer_data.dart';
import '../../../shared/global_variables/font_sizes.dart';
import '../../../shared/global_variables/static_text_translate.dart';

class CustomerPage extends StatefulWidget {
  final UserData userData;

  const CustomerPage({Key? key, required this.userData}) : super(key: key);

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

var selectedDataGirdListerner = ValueNotifier<DataGridRow?>(null);

class _CustomerPageState extends State<CustomerPage> {
  CustomerDataSource? customerDataSource;
  DataGridController dataGridController = DataGridController();
  DateTime? rangeStartDate;
  DateTime? rangeEndDate;
  bool loading = true;
  var customerIdController = TextEditingController();
  var customerNameController = TextEditingController();
  var customerPhoneController = TextEditingController();
  List<CustomerData> customerDataLst = [];
  @override
  void initState() {
    super.initState();
    hiveFetchData();
  }

  commonInit() async {
    customerDataLst.sort((b, a) => a.createdDate.compareTo(b.createdDate));
    customerDataSource = CustomerDataSource(customerData: customerDataLst);
    setState(() {
      loading = false;
    });
  }

  hiveFetchData() async {
    customerDataLst = await HiveCustomerDbService().fetchAllCustomersData();
    await commonInit();
  }

  fbFetchData() async {
    customerDataLst =
        await FbCustomerDbService(context: context).fetchAllCustomersData();
    await commonInit();
  }

  filterAccordingSelectedDate() {
    List<CustomerData> filteredEmployeesDataLst = [];
    if (rangeStartDate != null && rangeEndDate != null) {
      for (var ug in customerDataLst) {
        DateTime tmp = DateTime(
            ug.createdDate.year, ug.createdDate.month, ug.createdDate.day);
        if (tmp.compareTo(rangeStartDate!) != -1 &&
            (tmp.compareTo(rangeEndDate!) != 1)) {
          filteredEmployeesDataLst.add(ug);
        }
      }
    } else if (rangeStartDate != null) {
      var res = customerDataLst.where((e) =>
          e.createdDate.day == rangeStartDate!.day &&
          e.createdDate.month == rangeStartDate!.month &&
          e.createdDate.year == rangeStartDate!.year);

      filteredEmployeesDataLst = res.toList();
    }

    customerDataSource =
        CustomerDataSource(customerData: filteredEmployeesDataLst);
    rangeStartDate = null;
    rangeEndDate = null;
    setState(() {});
  }

  searchById(String id) {
    List<CustomerData> filteredVendorDataLst = [];
    if (id.isEmpty) {
      customerDataSource = CustomerDataSource(customerData: customerDataLst);
      setState(() {});
      return;
    }

    for (var v in customerDataLst) {
      if (v.customerId.toLowerCase().contains(id.toLowerCase())) {
        filteredVendorDataLst.add(v);
      }
    }
    customerDataSource =
        CustomerDataSource(customerData: filteredVendorDataLst);
    setState(() {});
  }

  searchByCustomerName(String val) {
    List<CustomerData> filteredVendorDataLst = [];
    if (val.isEmpty) {
      customerDataSource = CustomerDataSource(customerData: customerDataLst);
      setState(() {});
      return;
    }

    for (var v in customerDataLst) {
      if (v.customerName.toLowerCase().contains(val.toLowerCase())) {
        filteredVendorDataLst.add(v);
      }
    }
    customerDataSource =
        CustomerDataSource(customerData: filteredVendorDataLst);
    setState(() {});
  }

  searchByCompanyName(String name) {
    List<CustomerData> filteredVendorDataLst = [];
    if (name.isEmpty) {
      customerDataSource = CustomerDataSource(customerData: customerDataLst);
      setState(() {});
      return;
    }

    for (var v in customerDataLst) {
      if (v.companyName.toLowerCase().contains(name.toLowerCase())) {
        filteredVendorDataLst.add(v);
      }
    }
    customerDataSource =
        CustomerDataSource(customerData: filteredVendorDataLst);
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
                TopBar(pageName: 'Customers'),
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
                                  String newCustomerId = await getIdNumber(
                                      customerDataLst.length + 1);
                                  bool? res = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CustomerCreateEditPage(
                                                customerDataLst:
                                                    customerDataLst,
                                                userData: widget.userData,
                                                newCustomerId: newCustomerId,
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
                                    var id = '';

                                    for (var c in dataGridController
                                        .selectedRow!
                                        .getCells()) {
                                      if (c.columnName == 'id') {
                                        id = c.value;
                                      }
                                    }

                                    bool? res = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CustomerCreateEditPage(
                                                  newCustomerId: id,
                                                  customerDataLst:
                                                      customerDataLst,
                                                  userData: widget.userData,
                                                  edit: true,
                                                  selectedRowData:
                                                      customerDataLst
                                                          .where((e) =>
                                                              e.customerId ==
                                                              id)
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
                                label: 'Customer Payment',
                                iconPath: 'assets/icons/back.png',
                                buttonFunction: () {
                                  if (dataGridController.selectedRow != null) {
                                    var id = '';

                                    for (var c in dataGridController
                                        .selectedRow!
                                        .getCells()) {
                                      if (c.columnName == 'id') {
                                        id = c.value;
                                      }
                                    }
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CustomerPaymentPage(
                                                  userData: widget.userData,
                                                  customerDataLst:
                                                      customerDataLst,
                                                  selectedCustomerData:
                                                      customerDataLst
                                                          .where((e) =>
                                                              e.customerId ==
                                                              id)
                                                          .first,
                                                )));
                                  }
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
                                  //filters
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
                                              sortIcon: const Icon(Icons
                                                  .arrow_drop_down_rounded),
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
                                                  width: 140,
                                                  columnName: 'id',
                                                  label: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              3.0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        staticTextTranslate(
                                                            'Customer Id'),
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  1,
                                                        ),
                                                      ))),
                                              GridColumn(
                                                  width: 250,
                                                  columnName: 'name',
                                                  label: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              1.0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        staticTextTranslate(
                                                            'Customer Name'),
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  1,
                                                        ),
                                                      ))),
                                              GridColumn(
                                                  width: 180,
                                                  columnName: 'vat no',
                                                  label: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              1.0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        staticTextTranslate(
                                                            'VAT Number'),
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
                                                  columnName: 'company',
                                                  label: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              1.0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        staticTextTranslate(
                                                            'Company'),
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  1,
                                                        ),
                                                      ))),
                                              GridColumn(
                                                  width: 180,
                                                  columnName: 'phone1',
                                                  label: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              1.0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        staticTextTranslate(
                                                            'Phone 01'),
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  1,
                                                        ),
                                                      ))),
                                              GridColumn(
                                                  width: 220,
                                                  columnName: 'created date',
                                                  label: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              1.0),
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
                                                width: 200,
                                                columnName: 'created by',
                                                label: Container(
                                                  padding:
                                                      const EdgeInsets.all(1.0),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    staticTextTranslate(
                                                        'Created by'),
                                                    style: GoogleFonts.roboto(
                                                      fontSize:
                                                          getMediumFontSize + 1,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                            gridLinesVisibility:
                                                GridLinesVisibility.both,
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
      ),
    );
  }

  filterWidget() {
    return FilterContainer(fiterFields: [
      FilterTextField(
        onPressed: () {
          customerIdController.clear();

          customerDataSource =
              CustomerDataSource(customerData: customerDataLst);
          setState(() {});
        },
        icon: Icon(
            customerIdController.text.isEmpty
                ? CupertinoIcons.search
                : Icons.clear,
            size: 18,
            color: customerIdController.text.isEmpty
                ? Colors.grey[600]
                : Colors.black),
        controller: customerIdController,
        hintText: 'Customer Id',
        onChanged: (val) {
          searchById(val);
        },
      ),
      FilterTextField(
        icon: Icon(
            customerNameController.text.isEmpty
                ? CupertinoIcons.search
                : Icons.clear,
            size: 18,
            color: customerNameController.text.isEmpty
                ? Colors.grey[600]
                : Colors.black),
        hintText: 'Customer Name',
        onPressed: () {
          customerNameController.clear();

          customerDataSource =
              CustomerDataSource(customerData: customerDataLst);
          setState(() {});
        },
        onChanged: (val) {
          searchByCustomerName(val);
        },
      ),
      FilterTextField(
        icon: Icon(
            customerPhoneController.text.isEmpty
                ? CupertinoIcons.search
                : Icons.clear,
            size: 20,
            color: customerPhoneController.text.isEmpty
                ? Colors.grey[600]
                : Colors.black),
        onPressed: () {
          customerPhoneController.clear();

          customerDataSource =
              CustomerDataSource(customerData: customerDataLst);
          setState(() {});
        },
        onChanged: (val) {
          searchByCompanyName(val);
        },
        hintText: 'Company',
        controller: customerPhoneController,
      ),
    ]);
  }
}

class CustomerDataSource extends DataGridSource {
  CustomerDataSource({required List<CustomerData> customerData}) {
    _employeeData = customerData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(
                  columnName: 'serialNumberForStyleColor',
                  value: customerData.indexOf(e) + 1),
              DataGridCell<String>(columnName: 'id', value: e.customerId),
              DataGridCell<String>(columnName: 'name', value: e.customerName),
              DataGridCell<String>(columnName: 'vat no', value: e.vatNo),
              DataGridCell<String>(columnName: 'company', value: e.companyName),
              DataGridCell<String>(columnName: 'phone1', value: e.phone1),
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
