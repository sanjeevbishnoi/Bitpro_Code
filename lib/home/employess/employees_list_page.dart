import 'package:bitpro_hive/home/sales/customer/sideMenuButton.dart';
import 'package:bitpro_hive/services/firestore_api/fb_user_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_user_db_service.dart';
import 'package:bitpro_hive/widget/filter_container.dart';
import 'package:bitpro_hive/widget/filter_text_fileds/fiter_textfield.dart';
import 'package:bitpro_hive/widget/string_related/get_id_number.dart';
import 'package:bitpro_hive/widget/top_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:bitpro_hive/home/employess/create_edit_employess_page.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/model/user_group_data.dart';
import 'package:bitpro_hive/shared/custom_top_nav_bar.dart';
import 'package:bitpro_hive/shared/loading.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../shared/global_variables/font_sizes.dart';
import '../../shared/global_variables/static_text_translate.dart';

class EmployeesListPage extends StatefulWidget {
  final List<UserGroupData> userGroupsDataLst;
  final UserData userData;
  const EmployeesListPage(
      {Key? key, required this.userGroupsDataLst, required this.userData})
      : super(key: key);

  @override
  State<EmployeesListPage> createState() => _EmployeesListPageState();
}

var selectedDataGirdListerner = ValueNotifier<DataGridRow?>(null);

class _EmployeesListPageState extends State<EmployeesListPage> {
  List<UserData> employeesDataLst = [];

  DataGridController dataGridController = DataGridController();
  String? selectedSearchedRole;
  String empId = '';
  String empName = '';
  EmployeeDataSource? employeeDataSource;
  DateTime? rangeStartDate;
  DateTime? rangeEndDate;
  bool loading = true;

  var employeeIdController = TextEditingController();
  var employeeNameController = TextEditingController();
  @override
  void initState() {
    super.initState();
    hiveFetchData();
  }

  commonInit() async {
    employeesDataLst.sort((b, a) => a.createdDate.compareTo(b.createdDate));
    employeeDataSource = EmployeeDataSource(employeeData: employeesDataLst);
    setState(() {
      loading = false;
    });
  }

  hiveFetchData() async {
    employeesDataLst = await HiveUserDbService().fetchAllUserData();
    await commonInit();
  }

  fbFetchData() async {
    employeesDataLst =
        await FbUserDbService(context: context).fetchAllUserData();
    await commonInit();
  }

  searchEmpId(String id) {
    empId = id;
    List<UserData>? filteredEmployeesDataLst = [];
    if (id.isEmpty) {
      employeeDataSource = EmployeeDataSource(employeeData: employeesDataLst);
      setState(() {});
      return;
    }

    for (var ud in employeesDataLst) {
      if (ud.employeeId.toLowerCase().contains(id.toLowerCase())) {
        filteredEmployeesDataLst.add(ud);
      }
    }
    employeeDataSource =
        EmployeeDataSource(employeeData: filteredEmployeesDataLst);
    setState(() {});
  }

  searchEmpRole(String role) {
    List<UserData>? filteredEmployeesDataLst = [];
    if (role.isEmpty || role == staticTextTranslate('All Roles')) {
      employeeDataSource = EmployeeDataSource(employeeData: employeesDataLst);
      setState(() {});
      return;
    }

    for (var ud in employeesDataLst) {
      if (ud.userRole == role) {
        filteredEmployeesDataLst.add(ud);
      }
    }
    employeeDataSource =
        EmployeeDataSource(employeeData: filteredEmployeesDataLst);
    setState(() {});
  }

  searchEmpName(String name) {
    empName = name;
    List<UserData>? filteredEmployeesDataLst = [];
    if (name.isEmpty) {
      employeeDataSource = EmployeeDataSource(employeeData: employeesDataLst);
      setState(() {});
      return;
    }

    for (var ud in employeesDataLst) {
      String nam = '${ud.firstName.toLowerCase()} ${ud.lastName.toLowerCase()}';
      if (nam.contains(name.toLowerCase())) {
        filteredEmployeesDataLst.add(ud);
      }
    }
    employeeDataSource =
        EmployeeDataSource(employeeData: filteredEmployeesDataLst);
    setState(() {});
  }

  filterAccordingSelectedDate() {
    List<UserData>? filteredEmployeesDataLst = [];
    if (rangeStartDate != null && rangeEndDate != null) {
      for (var emp in employeesDataLst) {
        DateTime tmp = DateTime(
            emp.createdDate.year, emp.createdDate.month, emp.createdDate.day);
        if (tmp.compareTo(rangeStartDate!) != -1 &&
            (tmp.compareTo(rangeEndDate!) != 1)) {
          filteredEmployeesDataLst.add(emp);
        }
      }
    } else if (rangeStartDate != null) {
      var res = employeesDataLst.where((e) =>
          e.createdDate.day == rangeStartDate!.day &&
          e.createdDate.month == rangeStartDate!.month &&
          e.createdDate.year == rangeStartDate!.year);

      filteredEmployeesDataLst = res.toList();
    }

    employeeDataSource =
        EmployeeDataSource(employeeData: filteredEmployeesDataLst);
    rangeStartDate = null;
    rangeEndDate = null;
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
            // padding: const EdgeInsets.fromLTRB(5, 0, 5, 2),
            child: Column(
              children: [
                const TopBar(pageName: 'Employees'),
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
                                  if (!loading) {
                                    String newItemId = await getIdNumber(
                                        employeesDataLst.length + 1);
                                    bool? res = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CreateEditEmployeesPage(
                                                  newItemId: newItemId,
                                                  empLstData: employeesDataLst,
                                                  userGroupsDataLst:
                                                      widget.userGroupsDataLst,
                                                  userData: widget.userData,
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
                              SideMenuButton(
                                label: 'Edit',
                                iconPath: 'assets/icons/edit.png',
                                buttonFunction: () async {
                                  if (dataGridController.selectedRow != null) {
                                    if (!loading) {
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
                                                  CreateEditEmployeesPage(
                                                    newItemId: id,
                                                    empLstData:
                                                        employeesDataLst,
                                                    selectedRowData:
                                                        employeesDataLst
                                                            .where((e) =>
                                                                e.employeeId ==
                                                                id)
                                                            .first,
                                                    userGroupsDataLst: widget
                                                        .userGroupsDataLst,
                                                    userData: widget.userData,
                                                    edit: true,
                                                  )));
                                      if (res != null && res) {
                                        setState(() {
                                          loading = true;
                                        });
                                        fbFetchData();
                                      }
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
                                  if (!loading) {
                                    setState(() {
                                      loading = true;
                                    });

                                    await fbFetchData();
                                  }
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
                                            source: employeeDataSource!,
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
                                                  width: 120,
                                                  columnName: 'id',
                                                  label: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        staticTextTranslate(
                                                            'Emp. Id'),
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  1,
                                                        ),
                                                      ))),
                                              GridColumn(
                                                  width: 280,
                                                  columnName: 'name',
                                                  label: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        staticTextTranslate(
                                                            'Employee Name'),
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  1,
                                                        ),
                                                      ))),
                                              GridColumn(
                                                  width: 180,
                                                  columnName: 'role',
                                                  label: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        staticTextTranslate(
                                                            'User Role'),
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
                                                  width: 220,
                                                  columnName: 'username',
                                                  label: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        staticTextTranslate(
                                                            'Username'),
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  1,
                                                        ),
                                                      ))),
                                              GridColumn(
                                                  width: 150,
                                                  columnName: 'discount',
                                                  label: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        staticTextTranslate(
                                                            'Max Discount %'),
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  1,
                                                        ),
                                                      ))),
                                              GridColumn(
                                                  width: 170,
                                                  columnName: 'created date',
                                                  label: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
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
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        staticTextTranslate(
                                                            'Created by'),
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  1,
                                                        ),
                                                      ))),
                                            ],
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
    // });
    // ;
  }

  filterWidget() {
    return FilterContainer(fiterFields: [
      FilterTextField(
        onPressed: () {
          employeeIdController.clear();
          searchEmpId('');
        },
        icon: Icon(
            employeeIdController.text.isEmpty
                ? CupertinoIcons.search
                : Icons.clear,
            size: 18,
            color: employeeIdController.text.isEmpty
                ? Colors.grey[600]
                : Colors.black),
        controller: employeeIdController,
        hintText: 'Employee ID',
        onChanged: (val) {
          searchEmpId(val);
        },
      ),
      FilterTextField(
        onPressed: () {
          employeeNameController.clear();
          searchEmpId('');
        },
        icon: Icon(
            employeeNameController.text.isEmpty
                ? CupertinoIcons.search
                : Icons.clear,
            size: 18,
            color: employeeNameController.text.isEmpty
                ? Colors.grey[600]
                : Colors.black),
        controller: employeeNameController,
        hintText: 'Employee Name',
        onChanged: (val) {
          searchEmpName(val);
        },
      ),
      Container(
        width: 230,
        height: 32,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 0.5),
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(3)),
        padding: const EdgeInsets.only(right: 10, top: 1, bottom: 3),
        child: Row(
          children: [
            const SizedBox(
              width: 12,
            ),
            Icon(
              CupertinoIcons.search,
              size: 18,
              color: Colors.grey[600],
            ),
            const SizedBox(
              width: 10,
            ),
            Flexible(
              child: DropdownButton<String>(
                underline: const SizedBox(),
                isExpanded: true,
                hint: Text(staticTextTranslate('User Role'),
                    style: TextStyle(
                      fontSize: getMediumFontSize + 2,
                    )),
                value: selectedSearchedRole,
                items: [
                      DropdownMenuItem<String>(
                        value: 'All Roles',
                        child: Text(staticTextTranslate('All Roles'),
                            style: TextStyle(
                              fontSize: getMediumFontSize,
                            )),
                      )
                    ] +
                    widget.userGroupsDataLst.map((UserGroupData value) {
                      return DropdownMenuItem<String>(
                        value: value.name,
                        child: Text(staticTextTranslate(value.name),
                            style: TextStyle(
                              fontSize: getMediumFontSize,
                            )),
                      );
                    }).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedSearchedRole = val;
                    searchEmpRole(val!);
                  });
                },
              ),
            ),
          ],
        ),
      )
    ]);
  }
}

/// Custom business object class which contains properties to hold the detailed
/// information about the employee which will be rendered in datagrid.
class Employee {
  /// Creates the employee class with required details.
  Employee(
    this.id,
    this.name,
    this.userRole,
    this.username,
    this.maxDiscount,
    this.createdDate,
    this.createdBy,
  );

  /// Id of an employee.
  final int id;

  /// Name of an employee.
  final String name;

  /// Designation of an employee.
  final String userRole;

  /// Salary of an employee.
  final String username;
  final String maxDiscount;
  final String createdDate;
  final String createdBy;
}

/// An object to set the employee collection data source to the datagrid. This
/// is used to map the employee data to the datagrid widget.
class EmployeeDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  EmployeeDataSource({required List<UserData> employeeData}) {
    _employeeData = employeeData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(
                  columnName: 'serialNumberForStyleColor',
                  value: employeeData.indexOf(e) + 1),
              DataGridCell<String>(columnName: 'id', value: e.employeeId),
              DataGridCell<String>(
                  columnName: 'name', value: '${e.firstName} ${e.lastName}'),
              DataGridCell<String>(columnName: 'role', value: e.userRole),
              DataGridCell<String>(columnName: 'username', value: e.username),
              DataGridCell<String>(
                  columnName: 'discount', value: e.maxDiscount),
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
            padding: const EdgeInsets.all(2.0),
            child: Text(
              e.value.toString(),
              style: GoogleFonts.roboto(
                fontSize: getMediumFontSize + 1,
              ),
            ),
          );
        }).toList());
  }
}
