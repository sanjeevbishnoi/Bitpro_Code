import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:bitpro_hive/home/sales/customer/sideMenuButton.dart';
import 'package:bitpro_hive/services/firestore_api/fb_merchandise/fb_department_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_merchandise_db_service/department_db_service.dart';
import 'package:bitpro_hive/widget/filter_container.dart';
import 'package:bitpro_hive/widget/filter_text_fileds/fiter_textfield.dart';
import 'package:bitpro_hive/widget/string_related/get_id_number.dart';
import 'package:bitpro_hive/widget/top_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:bitpro_hive/home/merchandise/department/department_create.dart';
import 'package:bitpro_hive/model/department_data.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/shared/loading.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../../shared/custom_top_nav_bar.dart';
import '../../../shared/global_variables/font_sizes.dart';
import '../../../shared/global_variables/static_text_translate.dart';

class DepartmentPage extends StatefulWidget {
  final UserData userData;

  const DepartmentPage({Key? key, required this.userData}) : super(key: key);

  @override
  State<DepartmentPage> createState() => _DepartmentPageState();
}

var selectedDataGirdListerner = ValueNotifier<DataGridRow?>(null);

class _DepartmentPageState extends State<DepartmentPage> {
  DataGridController dataGridController = DataGridController();

  DepartmentDataSource? departmentDataSource;
  DateTime? rangeStartDate;
  DateTime? rangeEndDate;

  final departmentIdFilterController = TextEditingController();
  final departmentNameFilterController = TextEditingController();
  bool loading = true;
  List<DepartmentData> allDepartmentDataLst = [];
  @override
  void initState() {
    super.initState();
    hiveFetchData();
  }

  commonInit() async {
    departmentDataSource =
        DepartmentDataSource(departmentData: allDepartmentDataLst);
    setState(() {
      loading = false;
    });
  }

  hiveFetchData() async {
    allDepartmentDataLst =
        await HiveDepartmentDbService().fetchAllDepartmentsData();
    await commonInit();
  }

  fbFetchData() async {
    allDepartmentDataLst =
        await FbDepartmentDbService(context: context).fetchAllDepartmentsData();
    await commonInit();
  }

  filterAccordingSelectedDate() {
    List<DepartmentData> filteredEmployeesDataLst = [];
    if (rangeStartDate != null && rangeEndDate != null) {
      for (var ug in allDepartmentDataLst) {
        DateTime tmp = DateTime(
            ug.createdDate.year, ug.createdDate.month, ug.createdDate.day);
        if (tmp.compareTo(rangeStartDate!) != -1 &&
            (tmp.compareTo(rangeEndDate!) != 1)) {
          filteredEmployeesDataLst.add(ug);
        }
      }
    } else if (rangeStartDate != null) {
      var res = allDepartmentDataLst.where((e) =>
          e.createdDate.day == rangeStartDate!.day &&
          e.createdDate.month == rangeStartDate!.month &&
          e.createdDate.year == rangeStartDate!.year);

      filteredEmployeesDataLst = res.toList();
    }

    departmentDataSource =
        DepartmentDataSource(departmentData: filteredEmployeesDataLst);
    rangeStartDate = null;
    rangeEndDate = null;
    setState(() {});
  }

  searchById(String id) {
    List<DepartmentData> filteredDepartmentDataLst = [];
    if (id.isEmpty) {
      departmentDataSource =
          DepartmentDataSource(departmentData: allDepartmentDataLst);
      setState(() {});
      return;
    }

    for (var d in allDepartmentDataLst) {
      if (d.departmentId.toLowerCase().contains(id.toLowerCase())) {
        filteredDepartmentDataLst.add(d);
      }
    }
    departmentDataSource =
        DepartmentDataSource(departmentData: filteredDepartmentDataLst);
    setState(() {});
  }

  searchByName(String name) {
    List<DepartmentData> filteredDepartmentDataLst = [];
    if (name.isEmpty) {
      departmentDataSource =
          DepartmentDataSource(departmentData: allDepartmentDataLst);
      setState(() {});
      return;
    }

    for (var d in allDepartmentDataLst) {
      if (d.departmentName.toLowerCase().contains(name.toLowerCase())) {
        filteredDepartmentDataLst.add(d);
      }
    }
    departmentDataSource =
        DepartmentDataSource(departmentData: filteredDepartmentDataLst);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return customTopNavBar(
      Scaffold(
        backgroundColor: homeBgColor,
        body: SafeArea(
          child: Container(
            child: Column(
              children: [
                const TopBar(pageName: 'Department'),
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
                                String newDepartmentId = await getIdNumber(
                                    allDepartmentDataLst.length + 1);
                                bool? res = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DepartmentCreatePage(
                                              newDepartmentId: newDepartmentId,
                                              allDepartmentDataLst:
                                                  allDepartmentDataLst,
                                              userData: widget.userData,
                                            )));

                                if (res != null && res) {
                                  setState(() {
                                    loading = true;
                                  });
                                  allDepartmentDataLst =
                                      await FbDepartmentDbService(
                                              context: context)
                                          .fetchAllDepartmentsData();
                                  allDepartmentDataLst.sort((a, b) =>
                                      b.createdDate.compareTo(a.createdDate));
                                  departmentDataSource = DepartmentDataSource(
                                      departmentData: allDepartmentDataLst);

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
                                              DepartmentCreatePage(
                                                newDepartmentId: id,
                                                userData: widget.userData,
                                                allDepartmentDataLst:
                                                    allDepartmentDataLst,
                                                edit: true,
                                                selectedRowData:
                                                    allDepartmentDataLst
                                                        .where((e) =>
                                                            e.departmentId ==
                                                            id)
                                                        .first,
                                              )));

                                  if (res != null && res) {
                                    setState(() {
                                      loading = true;
                                    });
                                    allDepartmentDataLst =
                                        await FbDepartmentDbService(
                                                context: context)
                                            .fetchAllDepartmentsData();
                                    allDepartmentDataLst.sort((a, b) =>
                                        b.createdDate.compareTo(a.createdDate));
                                    departmentDataSource = DepartmentDataSource(
                                        departmentData: allDepartmentDataLst);

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
                                fbFetchData();
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
                                              headerStyle:
                                                  DateRangePickerHeaderStyle(
                                                backgroundColor: darkBlueColor,
                                                textStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: getLargeFontSize),
                                              ),
                                              selectionColor: Colors.blue,
                                              startRangeSelectionColor:
                                                  const Color.fromARGB(
                                                      255, 39, 53, 176),
                                              endRangeSelectionColor:
                                                  const Color.fromARGB(
                                                      255, 39, 53, 176),
                                              rangeSelectionColor:
                                                  const Color.fromARGB(
                                                      255, 112, 124, 231),
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
                                              showTodayButton: true,
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
                                    width: 0.5, color: Colors.grey),
                                borderRadius: BorderRadius.circular(4)),
                            elevation: 0,
                            color: Colors.white,
                            child: Column(
                              children: [
                                //filter
                                filterWidget(),
                                if (loading)
                                  Expanded(
                                    child: showLoading(),
                                  ),
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
                                          source: departmentDataSource!,
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
                                                        const EdgeInsets.all(
                                                            0.0),
                                                    alignment: Alignment.center,
                                                    color: Colors.white,
                                                    child: Text(
                                                      'serialNumberForStyleColor',
                                                      style: TextStyle(
                                                        fontSize:
                                                            getMediumFontSize,
                                                      ),
                                                    ))),
                                            GridColumn(
                                                columnName: 'id',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      staticTextTranslate(
                                                        'Department Id',
                                                      ),
                                                      style: GoogleFonts.roboto(
                                                        fontSize:
                                                            getMediumFontSize +
                                                                1,
                                                      ),
                                                    ))),
                                            GridColumn(
                                                columnName: 'name',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      staticTextTranslate(
                                                          'Department Name'),
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
                                                            2.0),
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
                                                            2.0),
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
          icon: Icon(
              departmentIdFilterController.text.isEmpty
                  ? CupertinoIcons.search
                  : Icons.clear,
              size: 18,
              color: departmentIdFilterController.text.isEmpty
                  ? Colors.grey[600]
                  : Colors.black),
          onPressed: () {
            departmentIdFilterController.clear();

            departmentDataSource = DepartmentDataSource(
              departmentData: allDepartmentDataLst,
            );
            setState(() {});
          },
          onChanged: (val) {
            searchById(val);
          },
          controller: departmentIdFilterController,
          hintText: 'Department Id'),
      FilterTextField(
          icon: Icon(
              departmentNameFilterController.text.isEmpty
                  ? CupertinoIcons.search
                  : Icons.clear,
              size: 18,
              color: departmentNameFilterController.text.isEmpty
                  ? Colors.grey[600]
                  : Colors.black),
          onPressed: () {
            departmentNameFilterController.clear();

            departmentDataSource =
                DepartmentDataSource(departmentData: allDepartmentDataLst);
            setState(() {});
          },
          onChanged: (val) {
            searchByName(val);
          },
          controller: departmentNameFilterController,
          hintText: 'Department Name'),
    ]);
  }
}

class DepartmentDataSource extends DataGridSource {
  DepartmentDataSource({required List<DepartmentData> departmentData}) {
    _employeeData = departmentData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(
                  columnName: 'serialNumberForStyleColor',
                  value: departmentData.indexOf(e) + 1),
              DataGridCell<String>(columnName: 'id', value: e.departmentId),
              DataGridCell<String>(columnName: 'name', value: e.departmentName),
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
            ? const Color(0xffF1F1F1)
            : Colors.white,
        cells: row.getCells().map<Widget>((e) {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(1.0),
            child: Text(
              e.value.toString(),
               style: GoogleFonts.roboto(
                  fontSize: getMediumFontSize + 1,
                  color:  Colors.black,
                  fontWeight: FontWeight.w400),

            ),
          );
        }).toList());
  }
}
