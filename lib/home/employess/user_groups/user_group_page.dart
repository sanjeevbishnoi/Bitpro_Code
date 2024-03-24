import 'package:bitpro_hive/home/sales/customer/sideMenuButton.dart';
import 'package:bitpro_hive/services/firestore_api/fb_user_group_db_service.dart';
import 'package:bitpro_hive/widget/filter_container.dart';
import 'package:bitpro_hive/widget/filter_text_fileds/fiter_textfield.dart';
import 'package:bitpro_hive/widget/top_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:bitpro_hive/home/employess/user_groups/create_edit_user_groups_page.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/model/user_group_data.dart';
import 'package:bitpro_hive/shared/loading.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../shared/custom_top_nav_bar.dart';
import '../../../shared/global_variables/font_sizes.dart';
import '../../../shared/global_variables/static_text_translate.dart';

class UserGroupPage extends StatefulWidget {
  final List<UserGroupData> userGroupsDataLst;
  final UserData userData;
  const UserGroupPage(
      {Key? key, required this.userGroupsDataLst, required this.userData})
      : super(key: key);

  @override
  State<UserGroupPage> createState() => _UserGroupPageState();
}

class _UserGroupPageState extends State<UserGroupPage> {
  DataGridController dataGridController = DataGridController();
  late UserGroupsDataSource userGroupsDataSource;
  late List<UserGroupData> userGroupsDataLst;
  DateTime? rangeStartDate;
  DateTime? rangeEndDate;

  bool loading = false;

  TextEditingController groupNameController = TextEditingController();
  @override
  void initState() {
    userGroupsDataLst = widget.userGroupsDataLst;
    userGroupsDataLst.sort((b, a) => a.createdDate.compareTo(b.createdDate));
    userGroupsDataSource =
        UserGroupsDataSource(employeeData: userGroupsDataLst);
    super.initState();
  }

  filterAccordingSelectedDate() {
    List<UserGroupData> filteredEmployeesDataLst = [];
    if (rangeStartDate != null && rangeEndDate != null) {
      for (var ug in userGroupsDataLst) {
        DateTime tmp = DateTime(
            ug.createdDate.year, ug.createdDate.month, ug.createdDate.day);
        if (tmp.compareTo(rangeStartDate!) != -1 &&
            (tmp.compareTo(rangeEndDate!) != 1)) {
          filteredEmployeesDataLst.add(ug);
        }
      }
    } else if (rangeStartDate != null) {
      var res = userGroupsDataLst.where((e) =>
          e.createdDate.day == rangeStartDate!.day &&
          e.createdDate.month == rangeStartDate!.month &&
          e.createdDate.year == rangeStartDate!.year);

      filteredEmployeesDataLst = res.toList();
    }

    userGroupsDataSource =
        UserGroupsDataSource(employeeData: filteredEmployeesDataLst);
    rangeStartDate = null;
    rangeEndDate = null;
    setState(() {});
  }

  searchGroupName(String name) {
    List<UserGroupData> filteredEmployeesDataLst = [];
    if (name.isEmpty) {
      userGroupsDataSource =
          UserGroupsDataSource(employeeData: userGroupsDataLst);
      setState(() {});
      return;
    }

    filteredEmployeesDataLst = [];
    for (var ud in userGroupsDataLst) {
      if (ud.name.toLowerCase().contains(name.toLowerCase())) {
        filteredEmployeesDataLst.add(ud);
      }
    }
    userGroupsDataSource =
        UserGroupsDataSource(employeeData: filteredEmployeesDataLst);
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
                pageName: 'User Group',
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
                              bool? res = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CreateEditUserGroupsPage(
                                            userData: widget.userData,
                                          )));

                              if (res != null && res == true) {
                                setState(() {
                                  loading = true;
                                });

                                // Map userGroups = box.get('UserGroups') ?? {};
                                userGroupsDataLst =
                                    await FbUserGroupDbService(context: context)
                                        .fetchAllUserGroups();
                                userGroupsDataLst.sort((b, a) =>
                                    a.createdDate.compareTo(b.createdDate));
                                userGroupsDataSource = UserGroupsDataSource(
                                    employeeData: userGroupsDataLst);

                                // dataGridController.selectedRow = null;
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
                                var name = '';

                                for (var c in dataGridController.selectedRow!
                                    .getCells()) {
                                  if (c.columnName ==
                                      staticTextTranslate('Group Name')) {
                                    name = c.value;
                                  }
                                }
                                bool? res = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            CreateEditUserGroupsPage(
                                              selectedRowData: userGroupsDataLst
                                                  .where((e) => e.name == name)
                                                  .first,
                                              userData: widget.userData,
                                              edit: true,
                                            )));

                                if (res != null && res) {
                                  setState(() {
                                    loading = true;
                                  });

                                  // Map userGroups = box.get('UserGroups') ?? {};
                                  userGroupsDataLst =
                                      await FbUserGroupDbService(
                                              context: context)
                                          .fetchAllUserGroups();
                                  userGroupsDataLst.sort((b, a) =>
                                      a.createdDate.compareTo(b.createdDate));
                                  userGroupsDataSource = UserGroupsDataSource(
                                      employeeData: userGroupsDataLst);

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

                              // Map userGroups = box.get('UserGroups') ?? {};
                              userGroupsDataLst =
                                  await FbUserGroupDbService(context: context)
                                      .fetchAllUserGroups();
                              userGroupsDataLst.sort((b, a) =>
                                  a.createdDate.compareTo(b.createdDate));
                              userGroupsDataSource = UserGroupsDataSource(
                                  employeeData: userGroupsDataLst);
                              await Future.delayed(const Duration(seconds: 1));
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
                              borderRadius: BorderRadius.circular(3)),
                          elevation: 0,
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //filter
                              filterWidget(),
                              if (loading)
                                Expanded(
                                  child: Center(
                                    child: showLoading(),
                                  ),
                                ),
                              if (!loading)
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                        border: Border.all(width: 0.3)),
                                    child: SfDataGridTheme(
                                      data: SfDataGridThemeData(
                                          headerColor: const Color(0xffF1F1F1),
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
                                        source: userGroupsDataSource,
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
                                                  child: Text(
                                                    'serialNumberForStyleColor',
                                                     style: GoogleFonts.roboto(
                fontSize: getMediumFontSize + 1,
              ),
                                                  ))),
                                          GridColumn(
                                              columnName: staticTextTranslate(
                                                  'Group Name'),
                                              label: Container(
                                                  padding:
                                                      const EdgeInsets.all(3.0),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                      staticTextTranslate(
                                                          'Group Name'),
                                                       style: GoogleFonts.roboto(
                fontSize: getMediumFontSize + 1,
              ),))),
                                          GridColumn(
                                              columnName: staticTextTranslate(
                                                  'Group Description'),
                                              label: Container(
                                                  padding:
                                                      const EdgeInsets.all(3.0),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                      staticTextTranslate(
                                                          'Group Description'),
                                                       style: GoogleFonts.roboto(
                fontSize: getMediumFontSize + 1,
              ),))),
                                          GridColumn(
                                              columnName: staticTextTranslate(
                                                  'Created Date'),
                                              label: Container(
                                                  padding:
                                                      const EdgeInsets.all(3.0),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                      staticTextTranslate(
                                                          'Created Date'),
                                                      style: GoogleFonts.roboto(
                fontSize: getMediumFontSize + 1,
              ),))),
                                          GridColumn(
                                              columnName: staticTextTranslate(
                                                  'Created by'),
                                              label: Container(
                                                  padding:
                                                      const EdgeInsets.all(3.0),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                      staticTextTranslate(
                                                          'Created by'),
                                                       style: GoogleFonts.roboto(
                fontSize: getMediumFontSize + 1,
              ),))),
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
            ],
          ),
        ),
      ),
    );
  }

  filterWidget() {
    return FilterContainer(fiterFields: [
      FilterTextField(
        onPressed: () {
          groupNameController.clear();

          searchGroupName('');
          setState(() {});
        },
        icon: Icon(
            groupNameController.text.isEmpty
                ? CupertinoIcons.search
                : Icons.clear,
            size: 18,
            color: groupNameController.text.isEmpty
                ? Colors.grey[600]
                : Colors.black),
        controller: groupNameController,
        hintText: 'Group Name',
        onChanged: (val) {
          searchGroupName(val);
        },
      ),
    ]);
  }
}

/// An object to set the employee collection data source to the datagrid. This
/// is used to map the employee data to the datagrid widget.
class UserGroupsDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  UserGroupsDataSource({required List<UserGroupData> employeeData}) {
    _employeeData = employeeData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(
                  columnName: 'serialNumberForStyleColor',
                  value: employeeData.indexOf(e) + 1),
              DataGridCell<String>(
                  columnName: staticTextTranslate('Group Name'), value: e.name),
              DataGridCell<String>(
                  columnName: staticTextTranslate('Group Description'),
                  value: e.description),
              DataGridCell<String>(
                  columnName: staticTextTranslate('Created Date'),
                  value: DateFormat.yMd().add_jm().format(e.createdDate)),
              DataGridCell<String>(
                  columnName: staticTextTranslate('Created by'),
                  value: e.createdBy),
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
            padding: const EdgeInsets.all(3.0),
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
