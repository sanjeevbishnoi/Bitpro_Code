import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:bitpro_hive/home/sales/customer/sideMenuButton.dart';
import 'package:bitpro_hive/services/firestore_api/fb_sales/fb_former_z_out_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_sales_db_service/hive_former_z_out_db_service.dart';
import 'package:bitpro_hive/widget/filter_container.dart';
import 'package:bitpro_hive/widget/top_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:bitpro_hive/model/receipt/db_receipt_data.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/shared/custom_top_nav_bar.dart';
import 'package:bitpro_hive/shared/loading.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../../model/former_z_out_data.dart';
import '../../../shared/global_variables/font_sizes.dart';
import '../../../shared/global_variables/static_text_translate.dart';

class FormerZOutPage extends StatefulWidget {
  final UserData userData;

  const FormerZOutPage({Key? key, required this.userData}) : super(key: key);

  @override
  State<FormerZOutPage> createState() => _FormerZOutPageState();
}

var selectedDataGirdListerner = ValueNotifier<DataGridRow?>(null);

class _FormerZOutPageState extends State<FormerZOutPage> {
  FormerZoutDataSource? customerDataSource;
  DataGridController dataGridController = DataGridController();
  DateTime? rangeStartDate;
  DateTime? rangeEndDate;
  bool loading = true;
  var customerIdController = TextEditingController();
  var customerNameController = TextEditingController();
  var customerPhoneController = TextEditingController();
  List<DbReceiptData> dbReceiptDataLst = [];
  List<FormerZOutData> formerZoutDataLst = [];
  @override
  void initState() {
    super.initState();
    hiveFetchData();
  }

  commonInit() async {
    formerZoutDataLst
        .sort(((a, b) => b.formerZoutNo.compareTo(a.formerZoutNo)));
    customerDataSource ??=
        FormerZoutDataSource(formerZOutData: formerZoutDataLst);
    setState(() {
      loading = false;
    });
  }

  hiveFetchData() async {
    formerZoutDataLst =
        await HiveFormerZOutDbService().fetchAllFormerZoutData();

    await commonInit();
  }

  fbFetchData() async {
    formerZoutDataLst =
        await FbFormerZOutDbService(context: context).fetchAllFormerZoutData();

    await commonInit();
  }

  filterAccordingSelectedDate() {
    List<FormerZOutData> filteredEmployeesDataLst = [];
    if (rangeStartDate != null && rangeEndDate != null) {
      for (var ug in formerZoutDataLst) {
        DateTime tmp = DateTime(DateTime.parse(ug.openDate).year,
            DateTime.parse(ug.openDate).month, DateTime.parse(ug.openDate).day);
        if (tmp.compareTo(rangeStartDate!) != -1 &&
            (tmp.compareTo(rangeEndDate!) != 1)) {
          filteredEmployeesDataLst.add(ug);
        }
      }
    } else if (rangeStartDate != null) {
      var res = formerZoutDataLst.where((e) =>
          DateTime.parse(e.openDate).day == rangeStartDate!.day &&
          DateTime.parse(e.openDate).month == rangeStartDate!.month &&
          DateTime.parse(e.openDate).year == rangeStartDate!.year);

      filteredEmployeesDataLst = res.toList();
    }

    customerDataSource =
        FormerZoutDataSource(formerZOutData: filteredEmployeesDataLst);
    rangeStartDate = null;
    rangeEndDate = null;
    setState(() {});
  }

  searchById(String id) {
    List<FormerZOutData> filteredVendorDataLst = [];
    if (id.isEmpty) {
      customerDataSource =
          FormerZoutDataSource(formerZOutData: formerZoutDataLst);
      setState(() {});
      return;
    }

    for (var v in formerZoutDataLst) {
      if (v.formerZoutNo.toLowerCase().contains(id.toLowerCase())) {
        filteredVendorDataLst.add(v);
      }
    }
    customerDataSource =
        FormerZoutDataSource(formerZOutData: filteredVendorDataLst);
    setState(() {});
  }

  searchByCustomerName(String val) {
    List<FormerZOutData> filteredVendorDataLst = [];
    if (val.isEmpty) {
      customerDataSource =
          FormerZoutDataSource(formerZOutData: formerZoutDataLst);
      setState(() {});
      return;
    }

    for (var v in formerZoutDataLst) {
      if (v.cashierName.toLowerCase().contains(val.toLowerCase())) {
        filteredVendorDataLst.add(v);
      }
    }
    customerDataSource =
        FormerZoutDataSource(formerZOutData: filteredVendorDataLst);
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
                  pageName: 'Former ZOut',
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
                              label: 'Refresh',
                              iconPath: 'assets/icons/refresh.png',
                              buttonFunction: () async {
                                setState(() {
                                  loading = true;
                                });
                                await fbFetchData();
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
                                child: Card(
                                    shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                            width: 0.5, color: Colors.grey),
                                        borderRadius: BorderRadius.circular(4)),
                                    elevation: 0,
                                    color: Colors.grey[200],
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        FilterContainer(fiterFields: [
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 3),
                                                  onPressed: () {
                                                    customerIdController
                                                        .clear();

                                                    customerDataSource =
                                                        FormerZoutDataSource(
                                                            formerZOutData:
                                                                formerZoutDataLst);
                                                    setState(() {});
                                                  },
                                                  splashRadius: 1,
                                                  icon: Icon(
                                                      customerIdController
                                                              .text.isEmpty
                                                          ? CupertinoIcons
                                                              .search
                                                          : Icons.clear,
                                                      size: 18,
                                                      color:
                                                          customerIdController
                                                                  .text.isEmpty
                                                              ? Colors.grey[600]
                                                              : Colors.black),
                                                ),
                                                Flexible(
                                                  child: TextField(
                                                    controller:
                                                        customerIdController,
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          staticTextTranslate(
                                                              'Zout#'),
                                                      hintStyle: TextStyle(
                                                          color:
                                                              Colors.grey[600]),
                                                      contentPadding:
                                                          const EdgeInsets.only(
                                                              bottom: 15,
                                                              right: 5),
                                                      border: InputBorder.none,
                                                    ),
                                                    onChanged: (val) {
                                                      searchById(val);
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
                                                    color: Colors.grey,
                                                    width: 0.5),
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 3),
                                                  onPressed: () {
                                                    customerNameController
                                                        .clear();

                                                    customerDataSource =
                                                        FormerZoutDataSource(
                                                            formerZOutData:
                                                                formerZoutDataLst);
                                                    setState(() {});
                                                  },
                                                  splashRadius: 1,
                                                  icon: Icon(
                                                      customerNameController
                                                              .text.isEmpty
                                                          ? CupertinoIcons
                                                              .search
                                                          : Icons.clear,
                                                      size: 18,
                                                      color:
                                                          customerNameController
                                                                  .text.isEmpty
                                                              ? Colors.grey[600]
                                                              : Colors.black),
                                                ),
                                                Flexible(
                                                  child: TextField(
                                                      controller:
                                                          customerNameController,
                                                      onChanged: (val) {
                                                        searchByCustomerName(
                                                            val);
                                                      },
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            staticTextTranslate(
                                                                'Cashier'),
                                                        hintStyle: TextStyle(
                                                            color: Colors
                                                                .grey[600]),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 13,
                                                                right: 5),
                                                        border:
                                                            InputBorder.none,
                                                      )),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]),
                                        ButtonBarSuper(
                                          buttonTextTheme:
                                              ButtonTextTheme.primary,
                                          wrapType: WrapType.fit,
                                          wrapFit: WrapFit.min,
                                          lineSpacing: 20,
                                          alignment: engSelectedLanguage
                                              ? WrapSuperAlignment.left
                                              : WrapSuperAlignment.right,
                                          children: [],
                                        ),
                                        if (loading)
                                          Expanded(
                                            child: Center(
                                              child: showLoading(),
                                            ),
                                          ),
                                        if (!loading)
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Container(
                                                  width: 600,
                                                  decoration: BoxDecoration(
                                                      color: homeBgColor,
                                                      border: Border.all(
                                                          color:  Colors.black, 
                                                          width: 0.3),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4)),
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height -
                                                      160,
                                                  child: SfDataGridTheme(
                                                    data: SfDataGridThemeData(
                                                        headerColor:
                                                            const Color(
                                                                0xffF1F1F1),
                                                        sortIcon: const Icon(Icons
                                                            .arrow_drop_down_rounded),
                                                        headerHoverColor:
                                                            const Color(
                                                                0xffdddfe8),
                                                        selectionColor:
                                                            loginBgColor),
                                                    child: SfDataGrid(
                                                      gridLinesVisibility:
                                                          GridLinesVisibility
                                                              .both,
                                                      headerRowHeight: 25,
                                                      headerGridLinesVisibility:
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
                                                      allowSorting: true,
                                                      allowTriStateSorting:
                                                          true,
                                                      controller:
                                                          dataGridController,
                                                      selectionMode:
                                                          SelectionMode.single,
                                                      allowFiltering: true,
                                                      source:
                                                          customerDataSource!,
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
                                                            label: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        0.0),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Text(
                                                                  'serialNumberForStyleColor',
                                                                  style:
                                                                      GoogleFonts
                                                                          .roboto(
                                                                    fontSize:
                                                                        getMediumFontSize +
                                                                            2,
                                                                  ),
                                                                ))),
                                                        GridColumn(
                                                            columnName: 'zout#',
                                                            label: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        1.0),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Text(
                                                                  staticTextTranslate(
                                                                      'Z out #'),
                                                                  style:
                                                                      GoogleFonts
                                                                          .roboto(
                                                                    fontSize:
                                                                        getMediumFontSize +
                                                                            2,
                                                                  ),
                                                                ))),
                                                        GridColumn(
                                                            columnName: 'total',
                                                            label: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        1.0),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Text(
                                                                  staticTextTranslate(
                                                                      'Total'),
                                                                  style:
                                                                      GoogleFonts
                                                                          .roboto(
                                                                    fontSize:
                                                                        getMediumFontSize +
                                                                            2,
                                                                  ),
                                                                ))),
                                                        GridColumn(
                                                            columnName:
                                                                'cashier_name',
                                                            label: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        1.0),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Text(
                                                                  staticTextTranslate(
                                                                      'Cashier Name'),
                                                                  style:
                                                                      GoogleFonts
                                                                          .roboto(
                                                                    fontSize:
                                                                        getMediumFontSize +
                                                                            2,
                                                                  ),
                                                                ))),
                                                        GridColumn(
                                                            columnName:
                                                                'over/short',
                                                            label: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        1.0),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Text(
                                                                  staticTextTranslate(
                                                                      'Over / Short'),
                                                                  style:
                                                                      GoogleFonts
                                                                          .roboto(
                                                                    fontSize:
                                                                        getMediumFontSize +
                                                                            2,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ))),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                if (dataGridController
                                                        .selectedIndex !=
                                                    -1)
                                                  detailsScreen()
                                              ],
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

  detailsScreen() {
    List<DataGridCell> cells = dataGridController.selectedRow!.getCells();
    int i = cells.indexWhere((e) => e.columnName == 'zout#');
    FormerZOutData? formerZOutData;
    if (i != -1) {
      String zoutd = cells.elementAt(i).value;
      int j = formerZoutDataLst
          .indexWhere((element) => element.formerZoutNo == zoutd);
      if (j != -1) {
        formerZOutData = formerZoutDataLst.elementAt(j);
      }
    }
    if (formerZOutData == null) return const SizedBox();

    return Container(
        width: 500,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 0.5),
            color: Colors.white,
            borderRadius: BorderRadius.circular(4)),
        height: MediaQuery.of(context).size.height - 162,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  staticTextTranslate('Zout: '),
                  style: GoogleFonts.roboto(
                    fontSize: getMediumFontSize + 5, fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(
                  height: 0,
                ),
                Text(
                  formerZOutData.formerZoutNo,
                  style: GoogleFonts.roboto(
                    fontSize: getMediumFontSize + 5,fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(staticTextTranslate('Total Over / Short'),
                          style: TextStyle(
                            fontSize: getMediumFontSize - 1,
                          )),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        formerZOutData.overShort,
                        style: TextStyle(
                          fontSize: getMediumFontSize + 2,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(staticTextTranslate('Close Date'),
                          style: TextStyle(
                            fontSize: getMediumFontSize - 1,
                          )),
                      const SizedBox(
                        height: 0,
                      ),
                      Text(
                        DateFormat(
                          'dd MMM, yyyy h:mm a',
                        ).format(
                          DateTime.parse(formerZOutData.closeDate),
                        ),
                        style: TextStyle(
                          fontSize: getMediumFontSize + 2,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(staticTextTranslate('Open Date'),
                          style: TextStyle(
                            fontSize: getMediumFontSize,
                          )),
                      const SizedBox(
                        height: 0,
                      ),
                      Text(
                        DateFormat('dd MMM, yyyy h:mm a')
                            .format(DateTime.parse(formerZOutData.openDate)),
                        style: TextStyle(
                          fontSize: getMediumFontSize + 2,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(staticTextTranslate('Cashier Name'),
                          style: TextStyle(
                            fontSize: getMediumFontSize - 1,
                          )),
                      const SizedBox(
                        height: 0,
                      ),
                      Text(
                        formerZOutData.cashierName,
                        style: TextStyle(
                          fontSize: getMediumFontSize + 2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 50,
                    child: Center(
                      child: Container(
                        width: 1,
                        height: double.infinity,
                        color: const Color.fromARGB(255, 151, 151, 151),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Text(staticTextTranslate('Credit Card Total On System'),
                          style: TextStyle(
                            fontSize: getMediumFontSize - 1,
                          )),
                      const SizedBox(
                        height: 0,
                      ),
                      Text(
                        formerZOutData.creditCardTotalInSystem,
                        style: TextStyle(
                          fontSize: getMediumFontSize + 2,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(staticTextTranslate('Credit Card Total'),
                          style: TextStyle(
                            fontSize: getMediumFontSize - 1,
                          )),
                      const SizedBox(
                        height: 0,
                      ),
                      Text(
                        formerZOutData.creditCardTotal,
                        style: TextStyle(
                          fontSize: getMediumFontSize + 2,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(staticTextTranslate('Total N/C Difference'),
                          style: TextStyle(
                            fontSize: getMediumFontSize - 1,
                          )),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        formerZOutData.totalNCDifferences,
                        style: TextStyle(
                          fontSize: getMediumFontSize + 2,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                        child: Center(
                          child: Container(
                            height: 1,
                            color: Colors.grey,
                            width: 200,
                          ),
                        ),
                      ),
                      Text(staticTextTranslate('Total Cash On System'),
                          style: TextStyle(
                            fontSize: getMediumFontSize - 1,
                          )),
                      const SizedBox(
                        height: 0,
                      ),
                      Text(
                        formerZOutData.totalCashOnSystem,
                        style: TextStyle(
                          fontSize: getMediumFontSize + 2,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(staticTextTranslate('Total Cash Entered'),
                          style: TextStyle(
                            fontSize: getMediumFontSize - 1,
                          )),
                      const SizedBox(
                        height: 0,
                      ),
                      Text(
                        formerZOutData.totalCashEntered,
                        style: TextStyle(
                          fontSize: getMediumFontSize + 2,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(staticTextTranslate('Total Cash Difference'),
                          style: TextStyle(
                            fontSize: getMediumFontSize - 1,
                          )),
                      const SizedBox(
                        height: 0,
                      ),
                      Text(
                        formerZOutData.overShort,
                        style: TextStyle(
                          fontSize: getMediumFontSize + 2,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ));
  }
}

class FormerZoutDataSource extends DataGridSource {
  FormerZoutDataSource({required List<FormerZOutData> formerZOutData}) {
    _employeeData = formerZOutData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(
                  columnName: 'serialNumberForStyleColor',
                  value: formerZOutData.indexOf(e) + 1),
              DataGridCell<String>(columnName: 'zout#', value: e.formerZoutNo),
              DataGridCell<String>(columnName: 'total', value: e.total),
              DataGridCell<String>(
                  columnName: 'cashier_name', value: e.cashierName),
              DataGridCell<String>(
                  columnName: 'over/short', value: e.overShort),
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
