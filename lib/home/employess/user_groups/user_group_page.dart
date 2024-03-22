import 'package:bitpro_hive/services/firestore_api/fb_user_group_db_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
                      height: 0,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue,
                            darkBlueColor,
                          ],
                        ),
                      ),
                      margin: const EdgeInsets.only(left: 0),
                      padding: const EdgeInsets.all(0),
                      width: 170,
                      height: 45,
                      child: const Center(
                        child: Text(
                          'BitPro',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w500),
                        ),
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
                            Icon(
                                size: 19,
                                Iconsax.edit4,
                                color: dataGridController.selectedRow != null
                                    ? const Color.fromARGB(255, 0, 0, 0)
                                    : Colors.grey[500]),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(staticTextTranslate('Edit'),
                                style: TextStyle(
                                    fontSize: getMediumFontSize,
                                    color:
                                        dataGridController.selectedRow != null
                                            ? const Color.fromARGB(255, 0, 0, 0)
                                            : Colors.grey[500])),
                          ],
                        ),
                        onPressed: () async {
                          if (dataGridController.selectedRow != null) {
                            var name = '';

                            for (var c
                                in dataGridController.selectedRow!.getCells()) {
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
                                  await FbUserGroupDbService(context: context)
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

                          // Map userGroups = box.get('UserGroups') ?? {};
                          userGroupsDataLst =
                              await FbUserGroupDbService(context: context)
                                  .fetchAllUserGroups();
                          userGroupsDataLst.sort(
                              (b, a) => a.createdDate.compareTo(b.createdDate));
                          userGroupsDataSource = UserGroupsDataSource(
                              employeeData: userGroupsDataLst);
                          await Future.delayed(const Duration(seconds: 1));
                          setState(() {
                            loading = false;
                          });
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
                                            rangeStartDate =
                                                args.value.startDate;
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
                                        cancelText: 'CANCEL',
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
                        height: 0,
                      ),
                      SizedBox(
                        height: 35,
                        width: 370,
                        child: Row(children: [
                          const SizedBox(width: 10),
                          const Icon(
                            size: 17,
                            Iconsax.lock_1,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            staticTextTranslate('Groups'),
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
                          height: 50,
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
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: 230,
                                      height: 30,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey, width: 0.5),
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      padding: const EdgeInsets.only(
                                          right: 10, top: 1, bottom: 3),
                                      child: TextField(
                                        decoration: InputDecoration(
                                            hintText: staticTextTranslate(
                                                'Group Name'),
                                            hintStyle: TextStyle(
                                                color: Colors.grey[600]),
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    left: 10,
                                                    right: 5,
                                                    bottom: 15),
                                            border: InputBorder.none,
                                            prefixIcon: const Icon(
                                              CupertinoIcons.search,
                                              size: 18,
                                            )),
                                        onChanged: (val) {
                                          searchGroupName(val);
                                        },
                                      ),
                                    ),
                                  ),
                                  if (loading)
                                    Expanded(
                                      child: Center(
                                        child: showLoading(),
                                      ),
                                    ),
                                  if (!loading)
                                    Expanded(
                                      child: SfDataGridTheme(
                                        data: SfDataGridThemeData(
                                            headerColor:
                                                const Color(0xffdddfe8),
                                            headerHoverColor:
                                                const Color(0xffdddfe8),
                                            selectionColor: loginBgColor),
                                        child: SfDataGrid(
                                          gridLinesVisibility:
                                              GridLinesVisibility.both,
                                          allowFiltering: true,
                                          headerGridLinesVisibility:
                                              GridLinesVisibility.both,
                                          isScrollbarAlwaysShown: true,
                                          onQueryRowHeight: (details) {
                                            // Set the row height as 70.0 to the column header row.
                                            return details.rowIndex == 0
                                                ? 25.0
                                                : 25.0;
                                          },
                                          allowTriStateSorting: true,
                                          allowSorting: true,
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
                                                columnName: staticTextTranslate(
                                                    'Group Name'),
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            3.0),
                                                    alignment: Alignment.center,
                                                    color:
                                                        const Color(0xffdddfe8),
                                                    child: Text(
                                                        staticTextTranslate(
                                                            'Group Name'),
                                                        style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
                                                        )))),
                                            GridColumn(
                                                columnName: staticTextTranslate(
                                                    'Group Description'),
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            3.0),
                                                    alignment: Alignment.center,
                                                    color:
                                                        const Color(0xffdddfe8),
                                                    child: Text(
                                                        staticTextTranslate(
                                                            'Group Description'),
                                                        style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
                                                        )))),
                                            GridColumn(
                                                columnName: staticTextTranslate(
                                                    'Created Date'),
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            3.0),
                                                    alignment: Alignment.center,
                                                    color:
                                                        const Color(0xffdddfe8),
                                                    child: Text(
                                                        staticTextTranslate(
                                                            'Created Date'),
                                                        style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
                                                        )))),
                                            GridColumn(
                                                columnName: staticTextTranslate(
                                                    'Created by'),
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            3.0),
                                                    alignment: Alignment.center,
                                                    color:
                                                        const Color(0xffdddfe8),
                                                    child: Text(
                                                        staticTextTranslate(
                                                            'Created by'),
                                                        style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
                                                        )))),
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
        ),
      ),
    );
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
            ? const Color.fromARGB(255, 246, 247, 255)
            : Colors.white,
        cells: row.getCells().map<Widget>((e) {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(3.0),
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
