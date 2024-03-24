import 'package:bitpro_hive/firebase_backend_setup/firebase_backend_setup.dart';
import 'package:bitpro_hive/model/store_data.dart';
import 'package:bitpro_hive/services/hive/hive_settings/hive_store_db_service.dart';

import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:bitpro_hive/shared/global_variables/font_sizes.dart';
import 'package:bitpro_hive/shared/global_variables/static_text_translate.dart';
import 'package:bitpro_hive/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class SettingStoreTab extends StatefulWidget {
  final Function selectStore;
  final List<StoreData> storeDataList;
  const SettingStoreTab(
      {super.key, required this.selectStore, required this.storeDataList});

  @override
  State<SettingStoreTab> createState() => _SettingStoreTabState();
}

class _SettingStoreTabState extends State<SettingStoreTab> {
  DataGridController dataGridController = DataGridController();
  bool isLoading = false;
  final Color dGvColor = const Color.fromARGB(255, 231, 231, 231);
  late StoreDataSource storeDataSource;
  List<StoreData> tStoreDataList = [];

  Map<String, dynamic>? _firebaseBackendInfo;
  @override
  void initState() {
    initData();
    super.initState();
  }

  initData() async {
    tStoreDataList = widget.storeDataList;
    tStoreDataList.sort((a, b) => a.storeCode.compareTo(b.storeCode));
    storeDataSource = StoreDataSource(storeData: tStoreDataList);

    var box = Hive.box('bitpro_app');
    var b = await box.get('firebase_backend_data');

    if (b != null && b['setupSkipped'] == false) {
      String projectId = b['projectId']; //'bitpro-multi-store';
      String databaseName = b['databaseName']; //'(default)';

      int selectedStoreCode = await HiveStoreDbService().getSelectedStoreCode();

      int workstationNumber = await HiveStoreDbService().getWorkstationNumber();

      int i = tStoreDataList.indexWhere(
          (element) => element.storeCode == selectedStoreCode.toString());
      _firebaseBackendInfo = {
        'projectId': projectId,
        'databaseName': databaseName,
        if (i != -1) 'defaultStore': tStoreDataList.elementAt(i).storeName,
        'workstationNumber': workstationNumber
      };
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.storeDataList != tStoreDataList) {
      tStoreDataList = widget.storeDataList;
      storeDataSource = StoreDataSource(storeData: tStoreDataList);
    }

    if (isLoading) return Expanded(child: showLoading());
    return Column(children: [
      SizedBox(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border:
                  Border.all(color: Color.fromARGB(255, 0, 0, 0), width: 0.3)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/icons/update.png',
                width: 30,
              ),
              SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Cloud Database',
                          style: GoogleFonts.roboto(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Status : ${_firebaseBackendInfo == null ? 'Not Connected' : 'Connected'}',
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (_firebaseBackendInfo != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                                'Project Id : ${_firebaseBackendInfo!['projectId']}'),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                                'Database Name : ${_firebaseBackendInfo!['databaseName']}'),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                                'Default Store : ${_firebaseBackendInfo!['defaultStore']}'),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                                'Workstation Number : ${_firebaseBackendInfo!['workstationNumber']}'),
                            const SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                      TextButton(
                        onPressed: () async {
                          if (_firebaseBackendInfo != null) {
                            //Change Database
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const FirebaseBackendSetupPage(
                                          isChangeDatabase: true,
                                        )));
                          } else {
                            //Add Database
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const FirebaseBackendSetupPage(
                                          isMergeDatabase: true,
                                        )));
                          }
                        },
                        child: Text(
                          staticTextTranslate(_firebaseBackendInfo != null
                              ? 'Change Database'
                              : 'Connect Cloud Database'),
                          style: GoogleFonts.roboto(fontSize: 14),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (_firebaseBackendInfo != null)
                        const Text(
                          'Note: Once you change the database, old data will be overwritten by new data.',
                          style: TextStyle(color: Colors.grey),
                        )
                    ]),
              ),
            ],
          ),
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
                border: Border.all(width: 0.3)),
            child: SfDataGridTheme(
              data: SfDataGridThemeData(
                  headerColor: dGvColor,
                  headerHoverColor: const Color(0xffdddfe8),
                  selectionColor: loginBgColor),
              child: Column(
                children: [
                  Expanded(
                    child: SfDataGrid(
                      isScrollbarAlwaysShown: true,
                      onQueryRowHeight: (details) {
                        // Set the row height as 70.0 to the column header row.
                        return details.rowIndex == 0 ? 25.0 : 25.0;
                      },
                      rowHeight: 28,
                      headerGridLinesVisibility: GridLinesVisibility.both,
                      allowColumnsResizing: true,
                      gridLinesVisibility: GridLinesVisibility.both,
                      controller: dataGridController,
                      selectionMode: SelectionMode.single,
                      source: storeDataSource,
                      columnWidthMode: ColumnWidthMode.lastColumnFill,
                      onSelectionChanged: (addedRows, removedRows) {
                        DataGridRow? dataGrideRow =
                            dataGridController.selectedRow;
                        if (dataGrideRow != null) {
                          String? selectedStoreCode;
                          for (var r in dataGrideRow.getCells()) {
                            if (r.columnName == 'storeCode') {
                              selectedStoreCode = r.value;
                            }
                          }
                          if (selectedStoreCode != null) {
                            StoreData? selectedStoreData;
                            for (var s in tStoreDataList) {
                              if (s.storeCode == selectedStoreCode) {
                                selectedStoreData = s;
                              }
                            }
                            widget.selectStore(selectedStoreData);
                          }
                        }
                        setState(() {});
                      },
                      columns: <GridColumn>[
                        GridColumn(
                            columnName: 'S.No.',
                            visible: false,
                            label: Container(
                                padding: const EdgeInsets.all(0.0),
                                alignment: Alignment.center,
                                color: dGvColor,
                                child: Text(
                                  'S.no.',
                                  style: TextStyle(
                                    fontSize: getMediumFontSize,
                                  ),
                                ))),
                        GridColumn(
                            columnName: 'storeCode',
                            visible: true,
                            label: Container(
                                padding: const EdgeInsets.all(0.0),
                                alignment: Alignment.center,
                                color: dGvColor,
                                child: Text(
                                  'Store code',
                                  style: GoogleFonts.roboto(fontSize: 16),
                                ))),
                        GridColumn(
                            columnName: 'storeName',
                            label: Container(
                                padding: const EdgeInsets.all(0.0),
                                alignment: Alignment.center,
                                color: dGvColor,
                                child: Text(
                                  staticTextTranslate('Store Name'),
                                  style: GoogleFonts.roboto(fontSize: 16),
                                ))),
                        GridColumn(
                            columnName: 'address1',
                            label: Container(
                                padding: const EdgeInsets.all(1.0),
                                alignment: Alignment.center,
                                color: dGvColor,
                                child: Text(
                                  staticTextTranslate('Address 1'),
                                  style: GoogleFonts.roboto(fontSize: 16),
                                ))),
                        GridColumn(
                            columnName: 'address2',
                            label: Container(
                                padding: const EdgeInsets.all(1.0),
                                alignment: Alignment.center,
                                color: dGvColor,
                                child: Text(
                                  staticTextTranslate('Address 2'),
                                  style: GoogleFonts.roboto(fontSize: 16),
                                ))),
                        GridColumn(
                            columnName: 'phone1',
                            label: Container(
                                padding: const EdgeInsets.all(1.0),
                                alignment: Alignment.center,
                                color: dGvColor,
                                child: Text(
                                  staticTextTranslate('Phone 1'),
                                  style: GoogleFonts.roboto(fontSize: 16),
                                ))),
                        GridColumn(
                            columnName: 'phone2',
                            label: Container(
                                padding: const EdgeInsets.all(1.0),
                                alignment: Alignment.center,
                                color: dGvColor,
                                child: Text(
                                  staticTextTranslate('Phone 2'),
                                  style: GoogleFonts.roboto(fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ))),
                        GridColumn(
                            columnName: 'vatNumber',
                            label: Container(
                                padding: const EdgeInsets.all(1.0),
                                color: dGvColor,
                                alignment: Alignment.center,
                                child: Text(
                                  staticTextTranslate('Vat Number'),
                                  style: GoogleFonts.roboto(fontSize: 16),
                                ))),
                        GridColumn(
                            columnName: 'email',
                            label: Container(
                                padding: const EdgeInsets.all(1.0),
                                color: dGvColor,
                                alignment: Alignment.center,
                                child: Text(
                                  staticTextTranslate('Email'),
                                  style: GoogleFonts.roboto(fontSize: 16),
                                ))),
                        GridColumn(
                            columnName: 'bankName',
                            label: Container(
                                padding: const EdgeInsets.all(1.0),
                                color: dGvColor,
                                alignment: Alignment.center,
                                child: Text(
                                  staticTextTranslate('Bank Name'),
                                  style: GoogleFonts.roboto(fontSize: 16),
                                ))),
                        GridColumn(
                            columnName: 'accountNumber',
                            label: Container(
                                padding: const EdgeInsets.all(1.0),
                                color: dGvColor,
                                alignment: Alignment.center,
                                child: Text(
                                  staticTextTranslate('Account Number'),
                                  style: GoogleFonts.roboto(fontSize: 16),
                                ))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      const SizedBox(
        width: 20,
      ),
    ]);
  }
}

class StoreDataSource extends DataGridSource {
  StoreDataSource({required List<StoreData> storeData}) {
    _employeeData = storeData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(
                  columnName: 'S.No.', value: storeData.indexOf(e) + 1),
              DataGridCell<String>(columnName: 'storeCode', value: e.storeCode),
              DataGridCell<String>(columnName: 'storeName', value: e.storeName),
              DataGridCell<String>(columnName: 'address1', value: e.address1),
              DataGridCell<String>(columnName: 'address2', value: e.address2),
              DataGridCell<String>(columnName: 'phone1', value: e.phone1),
              DataGridCell<String>(columnName: 'phone2', value: e.phone2),
              DataGridCell<String>(columnName: 'vatNumber', value: e.vatNumber),
              DataGridCell<String>(columnName: 'email', value: e.email),
              DataGridCell<String>(columnName: 'bankName', value: e.bankName),
              DataGridCell<String>(
                  columnName: 'accountNumber', value: e.ibanAccountNumber),
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
            ? const Color.fromARGB(255, 246, 247, 255)
            : Colors.white,
        cells: row.getCells().map<Widget>((e) {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(0.0),
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
