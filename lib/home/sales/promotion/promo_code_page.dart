import 'dart:io';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:bitpro_hive/services/firestore_api/fb_sales/fb_promo_code_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_sales_db_service/hive_promo_code_db_serice.dart';
import 'package:bitpro_hive/widget/string_related/get_id_number.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                          importBarcodeData();
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
                          await fbFetchData();
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
                              Icons.delete_forever,
                              color: allPromotionDataLst.isEmpty
                                  ? Colors.grey
                                  : const Color.fromARGB(255, 0, 0, 0),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(staticTextTranslate('Delete All'),
                                style: TextStyle(
                                    fontSize: getMediumFontSize,
                                    color: allPromotionDataLst.isEmpty
                                        ? Colors.grey
                                        : const Color.fromARGB(255, 0, 0, 0))),
                          ],
                        ),
                        onPressed: () {
                          if (allPromotionDataLst.isNotEmpty) {
                            deleteAllConfirmation();
                          }
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
                            Iconsax.discount_circle,
                            size: 17,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            staticTextTranslate('Promotion'),
                            style: TextStyle(
                              fontSize: getMediumFontSize,
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
                          )
                        ]),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Expanded(
                        child: SizedBox(
                          width: double.maxFinite,
                          height: 120,
                          child: Card(
                              shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      color: Colors.grey, width: 0.5),
                                  borderRadius: BorderRadius.circular(4)),
                              elevation: 0,
                              color: Colors.white,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: ButtonBarSuper(
                                      buttonTextTheme: ButtonTextTheme.primary,
                                      wrapType: WrapType.fit,
                                      wrapFit: WrapFit.min,
                                      lineSpacing: 20,
                                      alignment: engSelectedLanguage
                                          ? WrapSuperAlignment.left
                                          : WrapSuperAlignment.right,
                                      children: [
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
                                                  BorderRadius.circular(4)),
                                          padding: const EdgeInsets.only(
                                              right: 10, bottom: 3),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                padding: const EdgeInsets.only(
                                                    top: 3),
                                                onPressed: () {
                                                  customerIdController.clear();

                                                  promoDataSource =
                                                      PromoDataSource(
                                                          promoData:
                                                              allPromotionDataLst);
                                                  setState(() {});
                                                },
                                                splashRadius: 1,
                                                icon: Icon(
                                                    customerIdController
                                                            .text.isEmpty
                                                        ? CupertinoIcons.search
                                                        : Icons.clear,
                                                    size: 18,
                                                    color: customerIdController
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
                                                            'Promo#'),
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
                                      ],
                                    ),
                                  ),
                                  if (loading) Expanded(child: showLoading()),
                                  if (!loading)
                                    Expanded(
                                      child: SfDataGridTheme(
                                        data: SfDataGridThemeData(
                                            headerColor:
                                                const Color(0xffdddfe8),
                                            headerHoverColor:
                                                const Color(0xffdddfe8),
                                            selectionColor: loginBgColor),
                                        child: Column(
                                          children: [
                                            Container(
                                              height: 2,
                                              width: double.infinity,
                                              color: Colors.blue,
                                            ),
                                            Expanded(
                                              child: SfDataGrid(
                                                gridLinesVisibility:
                                                    GridLinesVisibility.both,
                                                headerGridLinesVisibility:
                                                    GridLinesVisibility.both,
                                                headerRowHeight: 25,
                                                isScrollbarAlwaysShown: true,
                                                onQueryRowHeight: (details) {
                                                  // Set the row height as 70.0 to the column header row.
                                                  return details.rowIndex == 0
                                                      ? 25.0
                                                      : 24.0;
                                                },
                                                rowHeight: 24,
                                                allowSorting: true,
                                                allowTriStateSorting: true,
                                                controller: dataGridController,
                                                selectionMode:
                                                    SelectionMode.single,
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
                                                              const EdgeInsets
                                                                  .all(0.0),
                                                          alignment:
                                                              Alignment.center,
                                                          color: Colors.white,
                                                          child: Text(
                                                            'serialNumberForStyleColor',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  getMediumFontSize,
                                                            ),
                                                          ))),
                                                  GridColumn(
                                                      columnName: 'promo#',
                                                      label: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(1.0),
                                                          alignment:
                                                              Alignment.center,
                                                          color: const Color(
                                                              0xffdddfe8),
                                                          child: Text(
                                                              staticTextTranslate(
                                                                  'Promo#'),
                                                              style: TextStyle(
                                                                fontSize:
                                                                    getMediumFontSize,
                                                              )))),
                                                  GridColumn(
                                                      columnName: 'barcode',
                                                      label: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          alignment:
                                                              Alignment.center,
                                                          color: const Color(
                                                              0xffdddfe8),
                                                          child: Text(
                                                              staticTextTranslate(
                                                                  'Barcode'),
                                                              style: TextStyle(
                                                                fontSize:
                                                                    getMediumFontSize,
                                                              )))),
                                                  GridColumn(
                                                      columnName: 'percentage',
                                                      label: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          alignment:
                                                              Alignment.center,
                                                          color: const Color(
                                                              0xffdddfe8),
                                                          child: Text(
                                                              staticTextTranslate(
                                                                  'Percentage'),
                                                              style: TextStyle(
                                                                fontSize:
                                                                    getMediumFontSize,
                                                              )))),
                                                  GridColumn(
                                                      columnName:
                                                          'start date/time',
                                                      label: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          alignment:
                                                              Alignment.center,
                                                          color: const Color(
                                                              0xffdddfe8),
                                                          child: Text(
                                                            staticTextTranslate(
                                                                'Start Date/Time'),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  getMediumFontSize,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ))),
                                                  GridColumn(
                                                      columnName:
                                                          'end date/time',
                                                      label: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          color: const Color(
                                                              0xffdddfe8),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                              staticTextTranslate(
                                                                  'End Date/Time'),
                                                              style: TextStyle(
                                                                fontSize:
                                                                    getMediumFontSize,
                                                              )))),
                                                ],
                                              ),
                                            ),
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
                    height: 350,
                    width: 550,
                    child: dialogLoading
                        ? showLoading()
                        : Column(children: [
                            Expanded(
                              child: SizedBox(
                                width: 550,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 15),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                staticTextTranslate(
                                                    'Product Import'),
                                                style: TextStyle(
                                                  fontSize:
                                                      getMediumFontSize + 5,
                                                )),
                                            const SizedBox(
                                              height: 0,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                    staticTextTranslate(
                                                        'Download Sample file here.'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize - 1,
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
                                                        fontSize:
                                                            getMediumFontSize,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      )),
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                    staticTextTranslate('File'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize,
                                                    )),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(3),
                                                        border: Border.all(
                                                            color:
                                                                Colors.grey)),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                    child: Text(
                                                        importItem != null
                                                            ? importItem!.path
                                                            : staticTextTranslate(
                                                                'No path found'),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
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
                                                                allowMultiple:
                                                                    false,
                                                                dialogTitle:
                                                                    'Import Items',
                                                                allowedExtensions: [
                                                                  'xlsx'
                                                                ],
                                                                type: FileType
                                                                    .custom);
                                                    if (result != null &&
                                                        result
                                                            .paths.isNotEmpty) {
                                                      importItem = File(
                                                          result.paths.first!);
                                                      Uint8List bytes =
                                                          await File(result
                                                                  .files
                                                                  .first
                                                                  .path!)
                                                              .readAsBytes();

                                                      Excel excel =
                                                          await compute(
                                                              parseExcelFile,
                                                              bytes);

                                                      uploadRes =
                                                          excelPromoDataImport(
                                                              excel);
                                                    }
                                                    setState(() {
                                                      dialogLoading = false;
                                                    });
                                                    setState2(() {});
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(3),
                                                        border: Border.all(
                                                            color:
                                                                Colors.grey)),
                                                    padding: const EdgeInsets
                                                        .symmetric(
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          staticTextTranslate(
                                                              'Start Date/Time'),
                                                          style: TextStyle(
                                                            fontSize:
                                                                getMediumFontSize -
                                                                    1,
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
                                                            firstDate:
                                                                DateTime.now(),
                                                            lastDate:
                                                                DateTime(2050),
                                                          );
                                                          if (dateTime !=
                                                              null) {
                                                            TimeOfDay?
                                                                timeOfDay =
                                                                await showTimePicker(
                                                              context: context,
                                                              initialTime:
                                                                  TimeOfDay
                                                                      .now(),
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
                                                            if (timeOfDay !=
                                                                null) {
                                                              startDate =
                                                                  DateTime(
                                                                dateTime.year,
                                                                dateTime.month,
                                                                dateTime.day,
                                                                timeOfDay.hour,
                                                                timeOfDay
                                                                    .minute,
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
                                                                  color: Colors
                                                                      .grey),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4)),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      15,
                                                                  vertical: 7),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                startDate ==
                                                                        null
                                                                    ? staticTextTranslate(
                                                                        'Select Date')
                                                                    : DateFormat(
                                                                            'dd / MM / yyyy  h:mm a')
                                                                        .format(startDate ??
                                                                            DateTime.now()),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        getMediumFontSize,
                                                                    color: startDate ==
                                                                            null
                                                                        ? Colors
                                                                            .grey
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
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 8,
                                                                  left: 15.0),
                                                          child: Text(
                                                            staticTextTranslate(
                                                                'Select a start date/time'),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  getMediumFontSize,
                                                              color: Colors
                                                                  .red[700],
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          staticTextTranslate(
                                                              'End Date/Time'),
                                                          style: TextStyle(
                                                            fontSize:
                                                                getMediumFontSize -
                                                                    1,
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
                                                                startDate ??
                                                                    DateTime
                                                                        .now(),
                                                            firstDate:
                                                                startDate ??
                                                                    DateTime
                                                                        .now(),
                                                            lastDate:
                                                                DateTime(2050),
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
                                                          if (dateTime !=
                                                              null) {
                                                            TimeOfDay?
                                                                timeOfDay =
                                                                await showTimePicker(
                                                              context: context,
                                                              initialTime:
                                                                  TimeOfDay
                                                                      .now(),
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

                                                            if (timeOfDay !=
                                                                null) {
                                                              endDate =
                                                                  DateTime(
                                                                dateTime.year,
                                                                dateTime.month,
                                                                dateTime.day,
                                                                timeOfDay.hour,
                                                                timeOfDay
                                                                    .minute,
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
                                                                  color: Colors
                                                                      .grey),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4)),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      15,
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
                                                                        ? Colors
                                                                            .grey
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
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 8,
                                                                  left: 15.0),
                                                          child: Text(
                                                            staticTextTranslate(
                                                                'Select a end date/time'),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  getMediumFontSize,
                                                              color: Colors
                                                                  .red[700],
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
                                ),
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
                                    SizedBox(
                                      height: 45,
                                      width: 173,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: darkBlueColor,
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
