import 'package:bitpro_hive/home/sales/receipt/receipt_page.dart';
import 'package:bitpro_hive/services/firestore_api/fb_sales/fb_former_z_out_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_sales/fb_register_db_serivce.dart';
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:bitpro_hive/shared/toast.dart';
import 'package:bitpro_hive/widget/string_related/get_id_number.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:bitpro_hive/home/sales/customer/customer_page.dart';
import 'package:bitpro_hive/home/sales/former_z_out/former_z_out_page.dart';
import 'package:bitpro_hive/home/sales/promotion/promo_code_page.dart';
import 'package:bitpro_hive/model/former_z_out_data.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/model/user_group_data.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:bitpro_hive/shared/loading.dart';
import '../../model/receipt/db_receipt_data.dart';

import '../../shared/global_variables/font_sizes.dart';
import '../../shared/global_variables/static_text_translate.dart';

class SalesPage extends StatefulWidget {
  UserData userData;
  final UserGroupData currentUserRole;

  SalesPage({
    Key? key,
    required this.userData,
    required this.currentUserRole,
  }) : super(key: key);

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  DataGridController dataGridController = DataGridController();
  DataGridController dataGridController2 = DataGridController();
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (widget.currentUserRole.receipt)
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xff092F53),
                      Color(0xff284F70),
                    ],
                    begin: Alignment.topCenter)),
            height: 45,
            width: 150,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4))),
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ReceiptPage(userData: widget.userData)));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Iconsax.receipt,
                      size: 19,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      staticTextTranslate('Receipt'),
                      style: TextStyle(
                        fontSize: getMediumFontSize,
                      ),
                    ),
                  ],
                )),
          ),
        if (widget.currentUserRole.customers)
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xff092F53),
                      Color(0xff284F70),
                    ],
                    begin: Alignment.topCenter)),
            height: 45,
            width: 150,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4))),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CustomerPage(
                                userData: widget.userData,
                              )));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Iconsax.people,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      staticTextTranslate('Customer'),
                      style: TextStyle(
                        fontSize: getMediumFontSize,
                      ),
                    ),
                  ],
                )),
          ),
        if (widget.currentUserRole.registers)
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xff092F53),
                      Color(0xff284F70),
                    ],
                    begin: Alignment.topCenter)),
            height: 45,
            width: 160,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4))),
                onPressed: () {
                  mainRegisterDialog();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Iconsax.keyboard_open,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      staticTextTranslate('Register'),
                      style: TextStyle(
                        fontSize: getMediumFontSize,
                      ),
                    ),
                  ],
                )),
          ),
        if (widget.currentUserRole.formerZout)
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xff092F53),
                      Color(0xff284F70),
                    ],
                    begin: Alignment.topCenter)),
            height: 45,
            width: 150,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4))),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FormerZOutPage(
                                userData: widget.userData,
                              )));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Iconsax.book,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      staticTextTranslate('Former Z out'),
                      style: TextStyle(
                        fontSize: getMediumFontSize,
                      ),
                    ),
                  ],
                )),
          ),
        if (widget.currentUserRole.promotion)
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xff092F53),
                      Color(0xff284F70),
                    ],
                    begin: Alignment.topCenter)),
            height: 45,
            width: 150,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4))),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => PromoCodePage()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Iconsax.discount_circle,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      staticTextTranslate('Promotion'),
                      style: TextStyle(
                        fontSize: getMediumFontSize,
                      ),
                    ),
                  ],
                )),
          ),
        // SizedBox(
        //   height: 45,
        //   width: 150,
        //   child: ElevatedButton(
        //       style: ElevatedButton.styleFrom(
        //           backgroundColor: darkBlueColor,
        //           shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.circular(4))),
        //       onPressed: () {
        //         Navigator.push(context,
        //             MaterialPageRoute(builder: (context) => HomeScreen()));
        //       },
        //       child: Row(
        //         mainAxisAlignment: MainAxisAlignment.start,
        //         children: [
        //           const Icon(
        //             Iconsax.discount_circle,
        //             size: 20,
        //           ),
        //           const SizedBox(
        //             width: 10,
        //           ),
        //           Text(staticTextTranslate('test 2')),
        //         ],
        //       )),
        // ),
      ],
    );
  }

  openRegisterDialog() {
    bool dialogLoading = false;
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(builder: (context, setState2) {
              return Dialog(
                backgroundColor: homeBgColor,
                child: SizedBox(
                    height: 400,
                    width: 600,
                    child: dialogLoading
                        ? showLoading()
                        : Column(children: [
                            Expanded(
                                child: SizedBox(
                              width: 600,
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 15),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              staticTextTranslate(
                                                  'Open Register'),
                                              style: TextStyle(
                                                  fontSize:
                                                      getLargeFontSize + 5,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              staticTextTranslate(
                                                  'All Sales transactions will be counted till the closing of this register.'),
                                              style: TextStyle(
                                                fontSize: getMediumFontSize - 1,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 0,
                                            ),
                                            Text(
                                              staticTextTranslate(
                                                  'Click Open Register to Open a Register'),
                                              style: TextStyle(
                                                fontSize: getMediumFontSize - 1,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 35,
                                            ),
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 100,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        staticTextTranslate(
                                                            'Cashier :'),
                                                        style: TextStyle(
                                                            fontSize:
                                                                getMediumFontSize +
                                                                    2,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        staticTextTranslate(
                                                            'Date / Time :'),
                                                        style: TextStyle(
                                                            fontSize:
                                                                getMediumFontSize +
                                                                    2,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      widget.userData.username,
                                                      style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  2,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  2,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                      DateFormat(
                                                              'dd-MM-yyyy hh:mm a')
                                                          .format(
                                                              DateTime.now()),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            )
                                          ]))),
                            )),
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
                                      width: 170,
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
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      height: 45,
                                      width: 170,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: darkBlueColor,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4))),
                                          onPressed: () async {
                                            setState2(() {
                                              dialogLoading = true;
                                            });
                                            await FbRegisterDbService(
                                                    context: context)
                                                .openRegister(widget.userData);
                                            showToast(
                                                'Register Opened Successfully',
                                                context);
                                            setState2(() {
                                              dialogLoading = false;
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Iconsax.folder_open,
                                                size: 19,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                staticTextTranslate('Finish'),
                                                style: TextStyle(
                                                    fontSize:
                                                        getMediumFontSize),
                                              ),
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

  String calculateCreditCardTotal(List<DbReceiptData> lst) {
    double t = 0;
    for (var l in lst) {
      t += double.tryParse(l.allPaymentMethodAmountsInfo['Credit Card']) ?? 0;
    }
    return t.toStringAsFixed(2);
  }

  String calculateCashTotal(List<DbReceiptData> lst) {
    double t = 0;
    for (var l in lst) {
      var a = double.tryParse(l.allPaymentMethodAmountsInfo['Cash']) ?? 0;
      var b = double.tryParse(l.receiptBalance) ?? 0;

      t += a - b;
    }
    return t.toStringAsFixed(2);
  }

  c3Screen(lst, enterCashTotal) {
    bool loading = false;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => StatefulBuilder(builder: (context, setState2) {
              return Dialog(
                backgroundColor: homeBgColor,
                child: SizedBox(
                    height: 400,
                    width: 600,
                    child: loading
                        ? showLoading()
                        : Column(children: [
                            Expanded(
                                child: SizedBox(
                              width: 600,
                              child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15.0, horizontal: 15),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              staticTextTranslate(
                                                  'Register Closing'),
                                              style: TextStyle(
                                                fontSize: getLargeFontSize + 5,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              staticTextTranslate('Totals'),
                                              style: TextStyle(
                                                fontSize: getMediumFontSize + 2,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Expanded(
                                              child: Container(
                                                width: 600,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    border: Border.all(
                                                        color: Colors.grey)),
                                                child: SfDataGridTheme(
                                                  data: SfDataGridThemeData(
                                                      headerColor: const Color(
                                                          0xffdddfe8),
                                                      headerHoverColor:
                                                          const Color(
                                                              0xffdddfe8),
                                                      selectionColor:
                                                          loginBgColor),
                                                  child: SfDataGrid(
                                                    controller:
                                                        dataGridController,
                                                    headerRowHeight: 50,
                                                    rowHeight: 25,
                                                    gridLinesVisibility:
                                                        GridLinesVisibility
                                                            .both,
                                                    headerGridLinesVisibility:
                                                        GridLinesVisibility
                                                            .both,
                                                    selectionMode:
                                                        SelectionMode.single,
                                                    source: CloseRegisterScreenB(
                                                        cashEnteredAmount:
                                                            enterCashTotal,
                                                        cashAmount:
                                                            calculateCashTotal(
                                                                lst),
                                                        creditCardAmount:
                                                            calculateCreditCardTotal(
                                                                lst)),
                                                    columnWidthMode:
                                                        ColumnWidthMode.fill,
                                                    onSelectionChanged:
                                                        (addedRows,
                                                            removedRows) {
                                                      setState(() {});
                                                    },
                                                    columns: <GridColumn>[
                                                      GridColumn(
                                                          columnName: 'type',
                                                          label: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(1.0),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              color:
                                                                  Colors.white,
                                                              child: Text(
                                                                staticTextTranslate(
                                                                    'Type'),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        getMediumFontSize,
                                                                    color: Colors
                                                                        .black),
                                                              ))),
                                                      GridColumn(
                                                          columnName:
                                                              'amount_on_system',
                                                          label: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(1.0),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              color:
                                                                  Colors.white,
                                                              child: Text(
                                                                staticTextTranslate(
                                                                    'Amount on system'),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      getMediumFontSize,
                                                                ),
                                                              ))),
                                                      GridColumn(
                                                          columnName:
                                                              'entered_amount',
                                                          label: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(1.0),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              color:
                                                                  Colors.white,
                                                              child: Text(
                                                                  staticTextTranslate(
                                                                      'Entered Amount'),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        getMediumFontSize,
                                                                  )))),
                                                      GridColumn(
                                                          columnName:
                                                              'over_short',
                                                          label: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(1.0),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              color:
                                                                  Colors.white,
                                                              child: Text(
                                                                  staticTextTranslate(
                                                                      'Over / Short'),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        getMediumFontSize,
                                                                  )))),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            Text(
                                              staticTextTranslate(
                                                  'Total Over / Short'),
                                              style: TextStyle(
                                                fontSize: getMediumFontSize,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Container(
                                              width: 230,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                      color: Colors.grey),
                                                  borderRadius:
                                                      BorderRadius.circular(4)),
                                              padding: const EdgeInsets.only(
                                                  right: 10,
                                                  left: 10,
                                                  bottom: 3),
                                              child: TextFormField(
                                                  initialValue: (double.parse(
                                                              enterCashTotal) -
                                                          double.parse(
                                                              calculateCashTotal(
                                                                  lst)))
                                                      .toStringAsFixed(2),
                                                  onChanged: (val) {},
                                                  decoration:
                                                      const InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            bottom: 13,
                                                            right: 5),
                                                    border: InputBorder.none,
                                                  )),
                                            )
                                          ]))),
                            )),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: 800,
                                decoration: const BoxDecoration(
                                    color: Color(0xffdddfe8),
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(4),
                                        bottomRight: Radius.circular(4))),
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
                                              backgroundColor: darkBlueColor,
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
                                              const Icon(
                                                Iconsax.previous,
                                                size: 19,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(staticTextTranslate('Back'),
                                                  style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize,
                                                      color: Colors.white)),
                                            ],
                                          )),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    SizedBox(
                                      height: 45,
                                      width: 170,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: darkBlueColor,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4))),
                                          onPressed: () async {
                                            setState(() {
                                              loading = true;
                                            });
                                            setState2(() {});
                                            String docId = getRandomString(20);
                                            List<FormerZOutData> resLst =
                                                await FbFormerZOutDbService(
                                                        context: context)
                                                    .fetchAllFormerZoutData();
                                            String newFormerZoutNo =
                                                await getIdNumber(
                                                    resLst.length + 1);
                                            // await FbFormerZOutDbService(
                                            //         context: context)
                                            //     .getNewZoutNo();
                                            await FbFormerZOutDbService(
                                                    context: context)
                                                .addUpdateFormerZOutReceipt([
                                              FormerZOutData(
                                                  docId: docId,
                                                  formerZoutNo: newFormerZoutNo,
                                                  creditCardTotal:
                                                      calculateCreditCardTotal(
                                                          lst), //credit card total and in system is same for now
                                                  creditCardTotalInSystem:
                                                      calculateCreditCardTotal(
                                                          lst),
                                                  total: (double.parse(calculateCreditCardTotal(lst)) +
                                                          double.parse(
                                                              calculateCashTotal(
                                                                  lst)))
                                                      .toStringAsFixed(2),
                                                  cashierName:
                                                      widget.userData.username,
                                                  overShort:
                                                      (double.parse(enterCashTotal) - double.parse(calculateCashTotal(lst)))
                                                          .toStringAsFixed(2),
                                                  totalCashOnSystem:
                                                      calculateCashTotal(lst),
                                                  totalCashEntered:
                                                      enterCashTotal,
                                                  totalCashDifferences: '0',
                                                  totalNCDifferences: '0',
                                                  openDate: widget
                                                      .userData.openRegister
                                                      .toString(),
                                                  closeDate:
                                                      DateTime.now().toString())
                                            ]);
                                            await FbRegisterDbService(
                                                    context: context)
                                                .closeRegister(widget.userData);
                                            showToast(
                                                'Register Closed Successfully',
                                                context);
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                Iconsax.pen_close,
                                                size: 19,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                  staticTextTranslate(
                                                      'Close Register'),
                                                  style: TextStyle(
                                                    fontSize: getMediumFontSize,
                                                  )),
                                            ],
                                          )),
                                    ),
                                    const SizedBox(width: 20),
                                  ],
                                ),
                              ),
                            )
                          ])),
              );
            }));
  }

  closeRegisterDialog() async {
    int dialogNo = 1;
    String enterCashTotal = '';

    // ignore: use_build_context_synchronously
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(builder: (context, setState2) {
              if (dialogNo == 2) {
                return FutureBuilder(
                    future: FbRegisterDbService(context: context)
                        .closeRegisterData(widget.userData.username,
                            widget.userData.openRegister!),
                    builder: (context, sp) {
                      List<DbReceiptData> lst = [];

                      if (sp.hasData) {
                        lst = sp.data ?? [];
                      }

                      return Dialog(
                          backgroundColor: homeBgColor,
                          child: SizedBox(
                              height: 400,
                              width: 600,
                              child: sp.hasData == false
                                  ? showLoading()
                                  : Column(children: [
                                      Expanded(
                                          child: SizedBox(
                                        width: 600,
                                        child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 15.0,
                                                        horizontal: 15),
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        staticTextTranslate(
                                                            'Register Closing'),
                                                        style: TextStyle(
                                                            fontSize:
                                                                getLargeFontSize +
                                                                    4,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        staticTextTranslate(
                                                            'Non Currency'),
                                                        style: TextStyle(
                                                            fontSize:
                                                                getMediumFontSize +
                                                                    2,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          width: 500,
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          1),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey)),
                                                          child:
                                                              SfDataGridTheme(
                                                            data: SfDataGridThemeData(
                                                                selectionColor:
                                                                    loginBgColor),
                                                            child: SfDataGrid(
                                                              rowHeight: 25,
                                                              gridLinesVisibility:
                                                                  GridLinesVisibility
                                                                      .both,
                                                              headerGridLinesVisibility:
                                                                  GridLinesVisibility
                                                                      .both,
                                                              controller:
                                                                  dataGridController,
                                                              headerRowHeight:
                                                                  27,
                                                              selectionMode:
                                                                  SelectionMode
                                                                      .single,
                                                              source: CloseRegisterScreenA(
                                                                  creditCardAmount:
                                                                      calculateCreditCardTotal(
                                                                          lst)),
                                                              columnWidthMode:
                                                                  ColumnWidthMode
                                                                      .fill,
                                                              onSelectionChanged:
                                                                  (addedRows,
                                                                      removedRows) {
                                                                setState(() {});
                                                              },
                                                              columns: <GridColumn>[
                                                                GridColumn(
                                                                    columnName:
                                                                        'type',
                                                                    label: Container(
                                                                        padding: const EdgeInsets.all(1.0),
                                                                        alignment: Alignment.center,
                                                                        color: Colors.white,
                                                                        child: Text(
                                                                          staticTextTranslate(
                                                                              'Type'),
                                                                          style: TextStyle(
                                                                              fontSize: getMediumFontSize,
                                                                              color: Colors.black),
                                                                        ))),
                                                                GridColumn(
                                                                    columnName:
                                                                        'amount',
                                                                    label: Container(
                                                                        padding: const EdgeInsets.all(1.0),
                                                                        alignment: Alignment.center,
                                                                        color: Colors.white,
                                                                        child: Text(
                                                                          staticTextTranslate(
                                                                              'Amount'),
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                getMediumFontSize,
                                                                          ),
                                                                        ))),
                                                                GridColumn(
                                                                    columnName:
                                                                        'reference',
                                                                    label: Container(
                                                                        padding: const EdgeInsets.all(1.0),
                                                                        alignment: Alignment.center,
                                                                        color: Colors.white,
                                                                        child: Text(staticTextTranslate('Reference #'),
                                                                            style: TextStyle(
                                                                              fontSize: getMediumFontSize,
                                                                            )))),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 15,
                                                      ),
                                                      Text(
                                                        staticTextTranslate(
                                                          'Non Currency Total',
                                                        ),
                                                        style: TextStyle(
                                                            fontSize:
                                                                getMediumFontSize +
                                                                    2,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Container(
                                                        width: 230,
                                                        height: 35,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4)),
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 3,
                                                                left: 3,
                                                                bottom: 3),
                                                        child: TextFormField(
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                            initialValue:
                                                                calculateCreditCardTotal(
                                                                    lst),
                                                            onChanged: (val) {},
                                                            decoration:
                                                                const InputDecoration(
                                                              contentPadding:
                                                                  EdgeInsets.only(
                                                                      bottom:
                                                                          13,
                                                                      right: 5),
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                            )),
                                                      )
                                                    ]))),
                                      )),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          width: 800,
                                          decoration: const BoxDecoration(
                                              color: Color(0xffdddfe8),
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(6),
                                                  bottomRight:
                                                      Radius.circular(6))),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              SizedBox(
                                                height: 45,
                                                width: 173,
                                                child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            darkBlueColor,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4))),
                                                    onPressed: () {
                                                      setState(() {
                                                        dialogNo = 1;
                                                      });
                                                      setState2(() {});
                                                    },
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Icon(
                                                            Icons.skip_previous,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    255),
                                                            size: 20),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                            staticTextTranslate(
                                                                'Back'),
                                                            style: TextStyle(
                                                                fontSize:
                                                                    getMediumFontSize,
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    255))),
                                                      ],
                                                    )),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              SizedBox(
                                                height: 45,
                                                width: 170,
                                                child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            darkBlueColor,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4))),
                                                    onPressed: () async {
                                                      c3Screen(
                                                          lst, enterCashTotal);
                                                    },
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Icon(
                                                          Iconsax.next,
                                                          size: 19,
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                            staticTextTranslate(
                                                                'Next'),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  getMediumFontSize,
                                                            )),
                                                      ],
                                                    )),
                                              ),
                                              const SizedBox(width: 10),
                                            ],
                                          ),
                                        ),
                                      )
                                    ])));
                    });
              } else {
                return Dialog(
                  backgroundColor: homeBgColor,
                  child: SizedBox(
                      height: 400,
                      width: 600,
                      child: Form(
                        key: formKey,
                        child: Column(children: [
                          Expanded(
                              child: SizedBox(
                            width: 600,
                            child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15.0, horizontal: 15),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            staticTextTranslate(
                                                'Register Closing'),
                                            style: TextStyle(
                                                fontSize: getLargeFontSize + 5,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(
                                            height: 0,
                                          ),
                                          Text(
                                              staticTextTranslate(
                                                  'Enter the Closing totals to finish the Register Closing'),
                                              style: TextStyle(
                                                fontSize: getMediumFontSize - 1,
                                              )),
                                          const SizedBox(
                                            height: 25,
                                          ),
                                          Text(
                                              staticTextTranslate(
                                                  'Enter cash total'),
                                              style: TextStyle(
                                                fontSize: getMediumFontSize,
                                              )),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          SizedBox(
                                            width: 230,
                                            // height: 35,
                                            child: TextFormField(
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w400),
                                                autovalidateMode:
                                                    AutovalidateMode
                                                        .onUserInteraction,
                                                initialValue: enterCashTotal,
                                                validator: (val) {
                                                  if (val!.isEmpty) {
                                                    return staticTextTranslate(
                                                        'Enter cash total');
                                                  } else if (double.tryParse(
                                                          val) ==
                                                      null) {
                                                    return staticTextTranslate(
                                                        'Enter a valid value');
                                                  }
                                                  return null;
                                                },
                                                onChanged: (val) {
                                                  setState(() {
                                                    enterCashTotal = val;
                                                  });
                                                  setState2(() {});
                                                },
                                                decoration: InputDecoration(
                                                  isDense: true,

                                                  // contentPadding:
                                                  //     const EdgeInsets.all(14),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4)),
                                                )),
                                          ),
                                        ]))),
                          )),
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
                                                    BorderRadius.circular(4))),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Iconsax.close_circle,
                                              size: 20,
                                              color: Colors.black,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(staticTextTranslate('Cancel'),
                                                style: TextStyle(
                                                    fontSize: getMediumFontSize,
                                                    color: Colors.black)),
                                          ],
                                        )),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    height: 45,
                                    width: 173,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: darkBlueColor,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4))),
                                        onPressed: () async {
                                          if (formKey.currentState!
                                              .validate()) {
                                            setState(() {
                                              dialogNo = 2;
                                            });
                                            setState2(() {});
                                          }
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Iconsax.next,
                                              size: 19,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(staticTextTranslate('Next'),
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
                        ]),
                      )),
                );
              }
            }));
  }

  mainRegisterDialog() {
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(builder: (context, setState2) {
              return Dialog(
                backgroundColor: homeBgColor,
                child: SizedBox(
                    height: 400,
                    width: 600,
                    child: Column(children: [
                      Expanded(
                          child: SizedBox(
                        width: 600,
                        child: Padding(
                            padding: const EdgeInsets.only(top: 15.0, left: 5),
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 15),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        staticTextTranslate(
                                            'Register Open / Close'),
                                        style: TextStyle(
                                            fontSize: getLargeFontSize + 5,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        staticTextTranslate(
                                            'All Sales transactions will be counted till closing this register.'),
                                        style: TextStyle(
                                          fontSize: getMediumFontSize - 1,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 0,
                                      ),
                                      Text(
                                        staticTextTranslate(
                                            'Click Open Register to Start making Sales. If Register is Open.'),
                                        style: TextStyle(
                                          fontSize: getMediumFontSize - 1,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 0,
                                      ),
                                      Text(
                                        staticTextTranslate(
                                            'Click Close Register to Complete.'),
                                        style: TextStyle(
                                          fontSize: getMediumFontSize - 1,
                                        ),
                                      ),
                                      const Expanded(
                                        child: SizedBox(
                                          height: 10,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            height: 45,
                                            width: 170,
                                            child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: widget
                                                                .userData
                                                                .openRegister ==
                                                            null
                                                        ? darkBlueColor
                                                        : Colors.grey,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4))),
                                                onPressed: () {
                                                  if (widget.userData
                                                          .openRegister ==
                                                      null) {
                                                    Navigator.pop(context);
                                                    openRegisterDialog();
                                                  }
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    const Icon(
                                                      Iconsax.folder_open,
                                                      size: 19,
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      staticTextTranslate(
                                                          'Open Register'),
                                                      style: TextStyle(
                                                        fontSize:
                                                            getMediumFontSize,
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          SizedBox(
                                            height: 45,
                                            width: 170,
                                            child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: widget
                                                                .userData
                                                                .openRegister ==
                                                            null
                                                        ? Colors.grey
                                                        : darkBlueColor,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4))),
                                                onPressed: () {
                                                  if (widget.userData
                                                          .openRegister !=
                                                      null) {
                                                    Navigator.pop(context);
                                                    closeRegisterDialog();
                                                  }
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    const Icon(
                                                      Iconsax.pen_close,
                                                      size: 19,
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      staticTextTranslate(
                                                          'Close Register'),
                                                      style: TextStyle(
                                                        fontSize:
                                                            getMediumFontSize,
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 25,
                                      ),
                                    ]))),
                      )),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 800,
                          decoration: const BoxDecoration(
                              color: Color(0xffdddfe8),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(4),
                                  bottomRight: Radius.circular(4))),
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
                                                BorderRadius.circular(4))),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.cancel_outlined,
                                            color: Colors.black, size: 20),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(staticTextTranslate('Close'),
                                            style: TextStyle(
                                                fontSize: getMediumFontSize,
                                                color: Colors.black)),
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

class CloseRegisterScreenA extends DataGridSource {
  CloseRegisterScreenA({required String creditCardAmount}) {
    _employeeData = [creditCardAmount]
        .map<DataGridRow>((e) => DataGridRow(cells: [
              const DataGridCell<String>(
                  columnName: 'type', value: 'Credit Card'),
              DataGridCell<String>(
                  columnName: 'amount', value: creditCardAmount),
              const DataGridCell<String>(columnName: 'reference', value: '0'),
            ]))
        .toList();
  }

  List<DataGridRow> _employeeData = [];

  @override
  List<DataGridRow> get rows => _employeeData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(1.0),
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

class CloseRegisterScreenB extends DataGridSource {
  CloseRegisterScreenB(
      {required String creditCardAmount,
      required String cashAmount,
      required String cashEnteredAmount}) {
    _employeeData = [
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'type', value: 'Cash'),
        DataGridCell<String>(columnName: 'amount_on_system', value: cashAmount),
        DataGridCell<String>(
            columnName: 'entered_amount', value: cashEnteredAmount),
        DataGridCell<String>(
            columnName: 'over_short',
            value: (double.parse(cashEnteredAmount) - double.parse(cashAmount))
                .toStringAsFixed(2)),
      ]),
      DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'type', value: 'Credit Card'),
        DataGridCell<String>(
            columnName: 'amount_on_system', value: creditCardAmount),
        DataGridCell<String>(
            columnName: 'entered_amount', value: creditCardAmount),
        const DataGridCell<String>(columnName: 'over_short', value: '0'),
      ]),
    ];
  }

  List<DataGridRow> _employeeData = [];

  @override
  List<DataGridRow> get rows => _employeeData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(1.0),
        child: Text(
          e.value.toString(),
          style: TextStyle(
              fontSize: getMediumFontSize,
              color: e.columnName == 'over_short' &&
                      !double.parse(e.value).isNegative &&
                      e.value != '0'
                  ? Colors.green
                  : e.columnName == 'over_short' &&
                          double.parse(e.value).isNegative
                      ? Colors.red
                      : Colors.black,
              fontWeight: FontWeight.w400),
        ),
      );
    }).toList());
  }
}
