import 'dart:io';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:bitpro_hive/home/sales/customer/sideMenuButton.dart';
import 'package:bitpro_hive/services/firestore_api/fb_sales/fb_promo_code_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_sales_db_service/hive_promo_code_db_serice.dart';
import 'package:bitpro_hive/widget/filter_container.dart';
import 'package:bitpro_hive/widget/string_related/get_id_number.dart';
import 'package:bitpro_hive/widget/top_bar.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:bitpro_hive/model/promo_code_data.dart';
import 'package:bitpro_hive/model/promotion_data.dart';
import 'package:bitpro_hive/shared/custom_top_nav_bar.dart';
import 'package:bitpro_hive/shared/loading.dart';
import 'package:bitpro_hive/shared/parse_excel_file.dart';
import 'package:bitpro_hive/shared/save_file_and_launch.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;
import '../../../shared/global_variables/font_sizes.dart';
import '../../../shared/global_variables/static_text_translate.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'excel_import_data_filter.dart';

class PromoCodePage extends StatefulWidget {
  @override
  State<PromoCodePage> createState() => _PromoCodePageState();
}

var selectedDataGirdListerner = ValueNotifier<DataGridRow?>(null);

class _PromoCodePageState extends State<PromoCodePage> {
  PromoDataSource? promoDataSource;
  DataGridController dataGridController = DataGridController();
  DateTime? rangeStartDate;
  DateTime? rangeEndDate;
  bool loading = true;
  var customerIdController = TextEditingController();
  var customerNameController = TextEditingController();
  var customerPhoneController = TextEditingController();

  List<PromoData> allPromotionDataLst = [];
  @override
  void initState() {
    super.initState();
    hiveFetchData();
  }

  commonInit() async {
    allPromotionDataLst.sort((a, b) => a.promoNo.compareTo(b.promoNo));
    promoDataSource = PromoDataSource(promoData: allPromotionDataLst);
    setState(() {
      loading = false;
    });
  }

  fbFetchData() async {
    allPromotionDataLst =
        await FbPromoDbService(context: context).fetchPromoData();

    await commonInit();
  }

  hiveFetchData() async {
    allPromotionDataLst = await HivePromoDbService().fetchPromoData();

    await commonInit();
  }

  searchById(String id) {
    List<PromoData> filteredPromoDataLst = [];
    if (id.isEmpty) {
      promoDataSource = PromoDataSource(promoData: allPromotionDataLst);
      setState(() {});
      return;
    }

    for (var v in allPromotionDataLst) {
      if (v.promoNo.toLowerCase().contains(id.toLowerCase())) {
        filteredPromoDataLst.add(v);
      }
    }
    promoDataSource = PromoDataSource(promoData: filteredPromoDataLst);
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
                TopBar(
                  pageName: 'Promotions',
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
                                importBarcodeData();
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
                              label: 'Delete All',
                              iconPath: 'assets/icons/view.png',
                              buttonFunction: () {
                                if (allPromotionDataLst.isNotEmpty) {
                                  deleteAllConfirmation();
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
                                    color: Colors.grey, width: 0.5),
                                borderRadius: BorderRadius.circular(4)),
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
                                          headerColor: const Color(0xffF1F1F1),
                                          sortIcon: const Icon(
                                              Icons.arrow_drop_down_rounded),
                                          headerHoverColor:
                                              const Color(0xffdddfe8),
                                        ),
                                        child: Expanded(
                                          child: SfDataGrid(
                                            gridLinesVisibility:
                                                GridLinesVisibility.both,
                                            headerGridLinesVisibility:
                                                GridLinesVisibility.both,
                                            isScrollbarAlwaysShown: true,
                                            onQueryRowHeight: (details) {
                                              // Set the row height as 70.0 to the column header row.
                                              return details.rowIndex == 0
                                                  ? 25.0
                                                  : 25.0;
                                            },
                                            rowHeight: 25,
                                            headerRowHeight: 25,
                                            allowSorting: true,
                                            allowTriStateSorting: true,
                                            controller: dataGridController,
                                            selectionMode: SelectionMode.single,
                                            source: promoDataSource!,
                                            columnWidthMode:
                                                ColumnWidthMode.fill,
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
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  2,
                                                        ),
                                                      ))),
                                              GridColumn(
                                                  columnName: 'promo#',
                                                  label: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              1.0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        staticTextTranslate(
                                                            'Promo#'),
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  2,
                                                        ),
                                                      ))),
                                              GridColumn(
                                                  columnName: 'barcode',
                                                  label: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        staticTextTranslate(
                                                            'Barcode'),
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  2,
                                                        ),
                                                      ))),
                                              GridColumn(
                                                  columnName: 'percentage',
                                                  label: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        staticTextTranslate(
                                                            'Percentage'),
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  2,
                                                        ),
                                                      ))),
                                              GridColumn(
                                                  columnName: 'start date/time',
                                                  label: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        staticTextTranslate(
                                                            'Start Date/Time'),
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  2,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ))),
                                              GridColumn(
                                                  columnName: 'end date/time',
                                                  label: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        staticTextTranslate(
                                                            'End Date/Time'),
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  2,
                                                        ),
                                                      ))),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                              ],
                            )),
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

  filterWidget() {
    return FilterContainer(fiterFields: [
      Container(
        width: 230,
        height: 32,
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
              onPressed: () {
                customerIdController.clear();

                promoDataSource =
                    PromoDataSource(promoData: allPromotionDataLst);
                setState(() {});
              },
              splashRadius: 1,
              icon: Icon(
                  customerIdController.text.isEmpty
                      ? CupertinoIcons.search
                      : Icons.clear,
                  size: 18,
                  color: customerIdController.text.isEmpty
                      ? Colors.grey[600]
                      : Colors.black),
            ),
            Flexible(
              child: TextField(
                controller: customerIdController,
                decoration: InputDecoration(
                  hintText: staticTextTranslate('Promo#'),
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  contentPadding: const EdgeInsets.only(bottom: 15, right: 5),
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
    ]);
  }

  deleteAllConfirmation() {
    bool dialogLoading = false;
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context2) {
          return StatefulBuilder(builder: (context, setState2) {
            if (dialogLoading) {
              return Dialog(
                  backgroundColor: homeBgColor,
                  child:
                      SizedBox(height: 170, width: 370, child: showLoading()));
            }
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(width: 0.2, color: Colors.grey)),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Iconsax.danger,
                    size: 20,
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Text(staticTextTranslate('Delete All'),
                      style: TextStyle(
                        fontSize: getMediumFontSize + 5,
                      )),
                ],
              ),
              content: Text(
                  staticTextTranslate(
                      'Are you sure you want to delete all data?'),
                  style: TextStyle(
                    fontSize: getMediumFontSize,
                  )),
              actions: [
                SizedBox(
                  height: 42,
                  width: 173,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          side:
                              const BorderSide(width: 0.1, color: Colors.grey),
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4))),
                      onPressed: () {
                        Navigator.pop(context2);
                      },
                      child: Text(staticTextTranslate('Cancel'),
                          style: TextStyle(
                              fontSize: getMediumFontSize,
                              color: Colors.black))),
                ),
                SizedBox(
                  height: 42,
                  width: 173,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        side: const BorderSide(width: 0.1, color: Colors.grey),
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () async {
                        setState2(() {
                          dialogLoading = true;
                        });

                        await FbPromoDbService(context: context)
                            .deleteAllPromoData(allPromotionDataLst);
                        await fbFetchData();

                        setState2(() {
                          dialogLoading = false;
                        });
                        Navigator.pop(context2);
                      },
                      child: Text(
                        staticTextTranslate('Delete All'),
                        style: TextStyle(
                          fontSize: getMediumFontSize,
                          color: Colors.white,
                        ),
                      )),
                ),
              ],
            );
          });
        });
  }

  importBarcodeData() {
    DateTime? startDate;
    DateTime? endDate;

    File? importItem;
    Map<String, dynamic> uploadRes = {};
    bool dialogLoading = false;

    bool showStartDateError = false;
    bool showEndDateError = false;

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => StatefulBuilder(builder: (context, setState2) {
              return Dialog(
                backgroundColor: homeBgColor,
                child: SizedBox(
                    height: 405,
                    width: 550,
                    child: dialogLoading
                        ? showLoading()
                        : Column(children: [
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
                                staticTextTranslate('Product Import'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: getMediumFontSize + 5,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 15),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                              staticTextTranslate(
                                                  'Download Sample file here.'),
                                              style: TextStyle(
                                                fontSize: getMediumFontSize - 1,
                                              )),
                                          TextButton(
                                            onPressed: () async {
                                              setState(() {
                                                dialogLoading = true;
                                              });
                                              setState2(() {});
                                              final Workbook workbook =
                                                  Workbook();

                                              final Worksheet sheet =
                                                  workbook.worksheets[0];

                                              sheet
                                                  .getRangeByName('A1')
                                                  .setText('barcode');
                                              sheet
                                                  .getRangeByName('B1')
                                                  .setText('percentage');

                                              final List<int> bytes =
                                                  workbook.saveAsStream();

                                              workbook.dispose();
                                              await saveAndLaunchFile(
                                                  bytes,
                                                  fileExtension: 'xlsx',
                                                  context);
                                              setState(() {
                                                dialogLoading = false;
                                              });
                                              setState2(() {});
                                            },
                                            child: Text(
                                                staticTextTranslate(
                                                    'Download Now.'),
                                                style: TextStyle(
                                                  fontSize: getMediumFontSize,
                                                  decoration:
                                                      TextDecoration.underline,
                                                )),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        children: [
                                          Text(staticTextTranslate('File'),
                                              style: TextStyle(
                                                fontSize: getMediumFontSize,
                                              )),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  border: Border.all(
                                                      color: Colors.grey)),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              child: Text(
                                                  importItem != null
                                                      ? importItem!.path
                                                      : staticTextTranslate(
                                                          'No path found'),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: getMediumFontSize,
                                                  )),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              setState(() {
                                                dialogLoading = true;
                                              });
                                              setState2(() {});

                                              FilePickerResult? result =
                                                  await FilePicker
                                                      .platform
                                                      .pickFiles(
                                                          allowMultiple: false,
                                                          dialogTitle:
                                                              'Import Items',
                                                          allowedExtensions: [
                                                            'xlsx'
                                                          ],
                                                          type:
                                                              FileType.custom);
                                              if (result != null &&
                                                  result.paths.isNotEmpty) {
                                                importItem =
                                                    File(result.paths.first!);
                                                Uint8List bytes = await File(
                                                        result
                                                            .files.first.path!)
                                                    .readAsBytes();

                                                Excel excel = await compute(
                                                    parseExcelFile, bytes);

                                                uploadRes =
                                                    excelPromoDataImport(excel);
                                              }
                                              setState(() {
                                                dialogLoading = false;
                                              });
                                              setState2(() {});
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  border: Border.all(
                                                      color: Colors.grey)),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              child: const Icon(
                                                Iconsax.folder_open,
                                                size: 19,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 25,
                                      ),
                                      Text(
                                          uploadRes.isEmpty
                                              ? staticTextTranslate(
                                                  'Items Found : 0')
                                              : '${staticTextTranslate("Items Found")} : ${uploadRes['localPromotionDataLst'].length}',
                                          style: TextStyle(
                                            fontSize: getMediumFontSize,
                                          )),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 200,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    staticTextTranslate(
                                                        'Start Date/Time'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize - 1,
                                                    )),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                GestureDetector(
                                                  onTap: () async {
                                                    DateTime? dateTime =
                                                        await showDatePicker(
                                                      context: context,
                                                      initialDate:
                                                          DateTime.now(),
                                                      firstDate: DateTime.now(),
                                                      lastDate: DateTime(2050),
                                                    );
                                                    if (dateTime != null) {
                                                      TimeOfDay? timeOfDay =
                                                          await showTimePicker(
                                                        context: context,
                                                        initialTime:
                                                            TimeOfDay.now(),
                                                        cancelText:
                                                            staticTextTranslate(
                                                                'CANCEL'),
                                                        confirmText:
                                                            staticTextTranslate(
                                                                'OK'),
                                                        helpText:
                                                            staticTextTranslate(
                                                                'SELECT TIME'),
                                                        errorInvalidText:
                                                            staticTextTranslate(
                                                                'Invalid format.'),
                                                      );
                                                      if (timeOfDay != null) {
                                                        startDate = DateTime(
                                                          dateTime.year,
                                                          dateTime.month,
                                                          dateTime.day,
                                                          timeOfDay.hour,
                                                          timeOfDay.minute,
                                                        );

                                                        showStartDateError =
                                                            false;
                                                        setState(() {});
                                                        setState2(() {});
                                                      }
                                                    }
                                                  },
                                                  child: Container(
                                                    width: 280,
                                                    height: 35,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.grey),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4)),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 15,
                                                        vertical: 7),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          startDate == null
                                                              ? staticTextTranslate(
                                                                  'Select Date')
                                                              : DateFormat(
                                                                      'dd / MM / yyyy  h:mm a')
                                                                  .format(startDate ??
                                                                      DateTime
                                                                          .now()),
                                                          style: TextStyle(
                                                              fontSize:
                                                                  getMediumFontSize,
                                                              color: startDate ==
                                                                      null
                                                                  ? Colors.grey
                                                                  : Colors
                                                                      .black),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                if (showStartDateError)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8, left: 15.0),
                                                    child: Text(
                                                      staticTextTranslate(
                                                          'Select a start date/time'),
                                                      style: TextStyle(
                                                        fontSize:
                                                            getMediumFontSize,
                                                        color: Colors.red[700],
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          SizedBox(
                                            width: 200,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    staticTextTranslate(
                                                        'End Date/Time'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize - 1,
                                                    )),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                GestureDetector(
                                                  onTap: () async {
                                                    DateTime? dateTime =
                                                        await showDatePicker(
                                                      context: context,
                                                      initialDate: startDate ??
                                                          DateTime.now(),
                                                      firstDate: startDate ??
                                                          DateTime.now(),
                                                      lastDate: DateTime(2050),
                                                      cancelText:
                                                          staticTextTranslate(
                                                              'CANCEL'),
                                                      confirmText:
                                                          staticTextTranslate(
                                                              'OK'),
                                                      helpText:
                                                          staticTextTranslate(
                                                              'SELECT DATE'),
                                                      errorFormatText:
                                                          staticTextTranslate(
                                                              'Invalid format.'),
                                                      errorInvalidText:
                                                          staticTextTranslate(
                                                              'Invalid format.'),
                                                      fieldLabelText:
                                                          staticTextTranslate(
                                                              'Enter Date'),
                                                      fieldHintText:
                                                          staticTextTranslate(
                                                              'Enter Date'),
                                                    );
                                                    if (dateTime != null) {
                                                      TimeOfDay? timeOfDay =
                                                          await showTimePicker(
                                                        context: context,
                                                        initialTime:
                                                            TimeOfDay.now(),
                                                        cancelText:
                                                            staticTextTranslate(
                                                                'CANCEL'),
                                                        confirmText:
                                                            staticTextTranslate(
                                                                'OK'),
                                                        helpText:
                                                            staticTextTranslate(
                                                                'SELECT TIME'),
                                                        errorInvalidText:
                                                            staticTextTranslate(
                                                                'Invalid format.'),
                                                      );

                                                      if (timeOfDay != null) {
                                                        endDate = DateTime(
                                                          dateTime.year,
                                                          dateTime.month,
                                                          dateTime.day,
                                                          timeOfDay.hour,
                                                          timeOfDay.minute,
                                                        );
                                                        showEndDateError =
                                                            false;
                                                        setState(() {});
                                                        setState2(() {});
                                                      }
                                                    }
                                                  },
                                                  child: Container(
                                                    width: 280,
                                                    height: 35,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.grey),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4)),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 15,
                                                        vertical: 7),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          endDate == null
                                                              ? staticTextTranslate(
                                                                  'Select Date')
                                                              : DateFormat(
                                                                      'dd / MM / yyyy  h:mm a')
                                                                  .format(
                                                                      endDate!),
                                                          style: TextStyle(
                                                              fontSize:
                                                                  getMediumFontSize,
                                                              color: endDate ==
                                                                      null
                                                                  ? Colors.grey
                                                                  : Colors
                                                                      .black),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                if (showEndDateError)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8, left: 15.0),
                                                    child: Text(
                                                      staticTextTranslate(
                                                          'Select a end date/time'),
                                                      style: TextStyle(
                                                        fontSize:
                                                            getMediumFontSize,
                                                        color: Colors.red[700],
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    ]),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: 800,
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
                                      height: 45,
                                      width: 173,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4))),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.cancel_outlined,
                                                  color: Colors.black,
                                                  size: 20),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                  staticTextTranslate('Cancel'),
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
                                            bool saveData = true;

                                            setState(() {
                                              dialogLoading = true;
                                            });
                                            setState2(() {});

                                            if (startDate == null) {
                                              showStartDateError = true;
                                              saveData = false;
                                            }
                                            if (endDate == null) {
                                              showEndDateError = true;
                                              saveData = false;
                                            }
                                            if (uploadRes.isEmpty) {
                                              saveData = false;
                                            }
                                            if (saveData) {
                                              List<PromotionData> pd =
                                                  uploadRes[
                                                      'localPromotionDataLst'];
                                              List<PromotionData> newPd = [];
                                              List<PromotionData> oldPd = [];

                                              for (var p in pd) {
                                                if (allPromotionDataLst
                                                        .indexWhere((element) =>
                                                            element.barcode ==
                                                            p.barcode) ==
                                                    -1) {
                                                  //new promo
                                                  newPd.add(p);
                                                } else {
                                                  oldPd.add(p);
                                                }
                                              }
                                              //adding new promo data
                                              if (newPd.isNotEmpty) {
                                                int lastPromotionCodeNo = 10001;
                                                if (allPromotionDataLst
                                                    .isNotEmpty) {
                                                  lastPromotionCodeNo =
                                                      int.parse(
                                                              allPromotionDataLst
                                                                  .last
                                                                  .promoNo) +
                                                          1;
                                                }
                                                for (int i = 0;
                                                    i < newPd.length;
                                                    i++) {
                                                  String docId =
                                                      getRandomString(20);

                                                  String promoNo =
                                                      await getIdNumber(
                                                          allPromotionDataLst
                                                                  .length +
                                                              1 +
                                                              i);
                                                  await FbPromoDbService(
                                                          context: context)
                                                      .addUpdatePromoData([
                                                    PromoData(
                                                        promoNo: promoNo,
                                                        docId: docId,
                                                        startDate: startDate!,
                                                        endDate: endDate!,
                                                        barcode: newPd
                                                            .elementAt(i)
                                                            .barcode,
                                                        percentage: newPd
                                                            .elementAt(i)
                                                            .percentage)
                                                  ]);
                                                }
                                              }
                                              if (oldPd.isNotEmpty) {
                                                for (int i = 0;
                                                    i < oldPd.length;
                                                    i++) {
                                                  String promoNo = '';
                                                  String docId = '';

                                                  try {
                                                    int index = allPromotionDataLst
                                                        .indexWhere((element) =>
                                                            element.barcode ==
                                                            oldPd
                                                                .elementAt(i)
                                                                .barcode);
                                                    promoNo =
                                                        allPromotionDataLst
                                                            .elementAt(index)
                                                            .promoNo;
                                                    docId = allPromotionDataLst
                                                        .elementAt(index)
                                                        .docId;
                                                  } catch (e) {}
                                                  if (promoNo.isNotEmpty &&
                                                      docId.isNotEmpty) {
                                                    await FbPromoDbService(
                                                            context: context)
                                                        .addUpdatePromoData([
                                                      PromoData(
                                                          promoNo: promoNo,
                                                          docId: docId,
                                                          startDate: startDate!,
                                                          endDate: endDate!,
                                                          barcode: oldPd
                                                              .elementAt(i)
                                                              .barcode,
                                                          percentage: oldPd
                                                              .elementAt(i)
                                                              .percentage)
                                                    ]);
                                                  }
                                                }
                                              }
                                              await fbFetchData();

                                              Navigator.pop(context);
                                            }

                                            setState(() {
                                              dialogLoading = false;
                                            });
                                            setState2(() {});
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
                                              Text(staticTextTranslate('Save'),
                                                  style: TextStyle(
                                                    fontSize: getMediumFontSize,
                                                  )),
                                            ],
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ])),
              );
            }));
  }
}

class PromoDataSource extends DataGridSource {
  PromoDataSource({required List<PromoData>? promoData}) {
    if (promoData != null) {
      for (var p in promoData) {
        _employeeData.add(DataGridRow(cells: [
          DataGridCell<int>(
              columnName: 'serialNumberForStyleColor',
              value: promoData.indexOf(p) + 1),
          DataGridCell<String>(columnName: 'promo#', value: p.promoNo),
          DataGridCell<String>(columnName: 'barcode', value: p.barcode),
          DataGridCell<String>(
              columnName: 'percentage', value: '${p.percentage}%'),
          DataGridCell<String>(
              columnName: 'start date/time',
              value: DateFormat('MM-dd-yyyy h:mm a').format(p.startDate)),
          DataGridCell<String>(
              columnName: 'end date/time',
              value: DateFormat('MM-dd-yyyy h:mm a').format(p.endDate)),
        ]));
      }
    }
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
                fontSize: getMediumFontSize + 2,
              ),
            ),
          );
        }).toList());
  }
}
