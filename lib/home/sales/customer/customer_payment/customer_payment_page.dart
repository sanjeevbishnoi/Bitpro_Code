import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:bitpro_hive/services/firestore_api/fb_sales/fb_customer_payment_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_sales/fb_receipt_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:bitpro_hive/model/customer_data.dart';
import 'package:bitpro_hive/model/customer_payment_data.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/shared/custom_top_nav_bar.dart';
import 'package:bitpro_hive/shared/loading.dart';
import 'package:bitpro_hive/shared/global_variables/static_text_translate.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import '../../../../model/receipt/db_receipt_data.dart';
import '../../../../shared/global_variables/font_sizes.dart';
import '../../../../shared/templates/customer_and_vendor_payment_templates/customer_payment_template.dart';

class CustomerPaymentPage extends StatefulWidget {
  final UserData userData;
  final CustomerData selectedCustomerData;
  final List<CustomerData> customerDataLst;
  const CustomerPaymentPage(
      {Key? key,
      required this.userData,
      required this.selectedCustomerData,
      required this.customerDataLst})
      : super(key: key);

  @override
  State<CustomerPaymentPage> createState() => _CustomerPaymentPageState();
}

var selectedDataGirdListerner = ValueNotifier<DataGridRow?>(null);

class _CustomerPaymentPageState extends State<CustomerPaymentPage> {
  DataGridController dataGridController = DataGridController();
  String searchId = '';
  String searchPhone1 = '';
  String searchName = '';
  DateTime? rangeStartDate;
  DateTime? rangeEndDate;
  bool loading = true;

  List<DbReceiptData> dbReceiptDataLst = [];
  VendorPaymentDataSource? customerPaymentDataSource;
  final TextEditingController _vendorTypeAheadController =
      TextEditingController();
  List<CustomerPaymentData> currentCustomerPaymentLstData = [];
  String receiptTypeDropDownFilter = 'All Document';
  var receiptIdController = TextEditingController();
  List<CustomerPaymentData> allCustomerPaymentdata = [];

  String calculateTotalPaid() {
    double t = 0;
    for (DbReceiptData d in dbReceiptDataLst) {
      if (d.receiptType == 'Regular' && d.tendor.credit == '0') {
        t += double.parse(d.subTotal);
      }
    }
    for (CustomerPaymentData v in currentCustomerPaymentLstData) {
      t += v.amount;
    }
    return t.toStringAsFixed(2);
  }

  String calculateTotalSalesAmt() {
    double regularT = 0;

    for (DbReceiptData d in dbReceiptDataLst) {
      if (d.receiptType == 'Regular') {
        regularT += double.parse(d.subTotal);
      } else {
        regularT -= double.parse(d.subTotal);
      }
    }

    regularT += double.parse(widget.selectedCustomerData.openingBalance);

    return regularT.toStringAsFixed(2);
  }

  filterAccordingSelectedDate() {
    List<DbReceiptData> filteredReceiptDataLst = [];
    List<CustomerPaymentData> filteredCustomerPaymentData = [];
    if (rangeStartDate != null && rangeEndDate != null) {
      for (var r in dbReceiptDataLst) {
        DateTime tmp = DateTime(
            r.createdDate.year, r.createdDate.month, r.createdDate.day);
        if (tmp.compareTo(rangeStartDate!) != -1 &&
            (tmp.compareTo(rangeEndDate!) != 1)) {
          filteredReceiptDataLst.add(r);
        }
      }
      for (var c in currentCustomerPaymentLstData) {
        DateTime tmp = DateTime(
            c.createdDate.year, c.createdDate.month, c.createdDate.day);
        if (tmp.compareTo(rangeStartDate!) != -1 &&
            (tmp.compareTo(rangeEndDate!) != 1)) {
          filteredCustomerPaymentData.add(c);
        }
      }
    } else if (rangeStartDate != null) {
      var res1 = dbReceiptDataLst.where((e) =>
          e.createdDate.day == rangeStartDate!.day &&
          e.createdDate.month == rangeStartDate!.month &&
          e.createdDate.year == rangeStartDate!.year);

      filteredReceiptDataLst = res1.toList();
      var res2 = currentCustomerPaymentLstData.where((e) =>
          e.createdDate.day == rangeStartDate!.day &&
          e.createdDate.month == rangeStartDate!.month &&
          e.createdDate.year == rangeStartDate!.year);

      filteredCustomerPaymentData = res2.toList();
    }

    customerPaymentDataSource = VendorPaymentDataSource(
        receiptDataLst: filteredReceiptDataLst,
        selectedCustomerData: widget.selectedCustomerData,
        customerPaymentData: filteredCustomerPaymentData);
    rangeStartDate = null;
    rangeEndDate = null;
    setState(() {});
  }

  searchById(String id) {
    List<DbReceiptData> filteredReceiptDataLst = [];
    List<CustomerPaymentData> filteredCustomerPaymentData = [];

    if (id.isEmpty) {
      customerPaymentDataSource = VendorPaymentDataSource(
          receiptDataLst: dbReceiptDataLst,
          selectedCustomerData: widget.selectedCustomerData,
          customerPaymentData: currentCustomerPaymentLstData);
      setState(() {});
      return;
    }

    for (var r in dbReceiptDataLst) {
      if (r.receiptNo.toLowerCase().contains(id.toLowerCase())) {
        filteredReceiptDataLst.add(r);
      }
    }
    for (var c in currentCustomerPaymentLstData) {
      if (('cp${c.customerId}').toLowerCase().contains(id.toLowerCase())) {
        filteredCustomerPaymentData.add(c);
      }
    }
    customerPaymentDataSource = VendorPaymentDataSource(
        receiptDataLst: filteredReceiptDataLst,
        selectedCustomerData: widget.selectedCustomerData,
        customerPaymentData: filteredCustomerPaymentData);
    setState(() {});
  }

  @override
  void initState() {
    hiveFetchInfo();
    super.initState();
  }

  commonInit() async {
    currentCustomerPaymentLstData = allCustomerPaymentdata
        .where((element) =>
            element.customerId == widget.selectedCustomerData.customerId)
        .toList();

    currentCustomerPaymentLstData
        .sort((b, a) => a.createdDate.compareTo(b.createdDate));
    customerPaymentDataSource = VendorPaymentDataSource(
        receiptDataLst: dbReceiptDataLst,
        selectedCustomerData: widget.selectedCustomerData,
        customerPaymentData: currentCustomerPaymentLstData);
    setState(() {
      loading = false;
    });
  }

  fbFetchInfo() async {
    //voucher data
    List<DbReceiptData> dbReceiptAllDataLst =
        await FbReceiptDbService(context: context).fetchAllReceiptData();
    dbReceiptDataLst = dbReceiptAllDataLst
        .where((element) =>
            element.selectedCustomerID ==
            widget.selectedCustomerData.customerId)
        .toList();

    allCustomerPaymentdata = await FbCustomerPaymentDbService(context: context)
        .fetchAllCustomerPaymentData();

    await commonInit();
  }

  hiveFetchInfo() async {
    //voucher data
    List<DbReceiptData> dbReceiptAllDataLst =
        await FbReceiptDbService(context: context).fetchAllReceiptData();
    dbReceiptDataLst = dbReceiptAllDataLst
        .where((element) =>
            element.selectedCustomerID ==
            widget.selectedCustomerData.customerId)
        .toList();

    allCustomerPaymentdata = await FbCustomerPaymentDbService(context: context)
        .fetchAllCustomerPaymentData();

    await commonInit();
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
                              Iconsax.wallet_money,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(staticTextTranslate('Pay'),
                                style: TextStyle(
                                    fontSize: getMediumFontSize,
                                    color: const Color.fromARGB(255, 0, 0, 0))),
                          ],
                        ),
                        onPressed: () async {
                          customerPayment(
                              selectedCustomerData: widget.selectedCustomerData,
                              paymentType: 'Cash',
                              amount: 0,
                              comment: '',
                              docId: '',
                              documentNo: '',
                              createdDate: DateTime.now());
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
                              Iconsax.edit,
                              color: dataGridController.selectedRow != null &&
                                      dataGridController.selectedRow!
                                              .getCells()
                                              .indexWhere((e) =>
                                                  e.columnName == 'doc' &&
                                                  e.value == 'Payment') !=
                                          -1
                                  ? const Color.fromARGB(255, 0, 0, 0)
                                  : Colors.grey[500],
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(staticTextTranslate('Edit'),
                                style: TextStyle(
                                    fontSize: getMediumFontSize,
                                    color: dataGridController.selectedRow !=
                                                null &&
                                            dataGridController.selectedRow!
                                                    .getCells()
                                                    .indexWhere((e) =>
                                                        e.columnName == 'doc' &&
                                                        e.value == 'Payment') !=
                                                -1
                                        ? const Color.fromARGB(255, 0, 0, 0)
                                        : Colors.grey[500])),
                          ],
                        ),
                        onPressed: () async {
                          if (dataGridController.selectedRow != null &&
                              dataGridController.selectedRow!
                                      .getCells()
                                      .indexWhere((e) =>
                                          e.columnName == 'doc' &&
                                          e.value == 'Payment') !=
                                  -1) {
                            var id = '';

                            for (var c
                                in dataGridController.selectedRow!.getCells()) {
                              if (c.columnName == 'doc#') {
                                id = c.value;
                              }
                            }
                            int i = currentCustomerPaymentLstData.indexWhere(
                                (element) =>
                                    element.documentNo ==
                                    id.replaceAll('CP', ''));

                            if (i != -1) {
                              customerPayment(
                                  selectedCustomerData:
                                      widget.selectedCustomerData,
                                  paymentType: currentCustomerPaymentLstData
                                      .elementAt(i)
                                      .paymentType,
                                  amount: currentCustomerPaymentLstData
                                      .elementAt(i)
                                      .amount,
                                  comment: currentCustomerPaymentLstData
                                      .elementAt(i)
                                      .comment,
                                  docId: currentCustomerPaymentLstData
                                      .elementAt(i)
                                      .docId,
                                  documentNo: currentCustomerPaymentLstData
                                      .elementAt(i)
                                      .documentNo,
                                  createdDate: currentCustomerPaymentLstData
                                      .elementAt(i)
                                      .createdDate);
                            }
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

                          await fbFetchInfo();
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
                          // showDialog(
                          //     context: context,
                          //     builder: (context) {
                          //       return Dialog(
                          //         child: SizedBox(
                          //           width: 400,
                          //           height: 380,
                          //           child:

                          // SfDateRangePicker(
                          //     onSelectionChanged:
                          //         (DateRangePickerSelectionChangedArgs
                          //             args) {
                          //       if (args.value is PickerDateRange) {
                          //         rangeStartDate = args.value.startDate;
                          //         rangeEndDate = args.value.endDate;
                          //         setState(() {});
                          //       }
                          //     },
                          //     onCancel: () {
                          //       Navigator.pop(context);
                          //     },
                          //     onSubmit: (var p0) {
                          //       filterAccordingSelectedDate();
                          //       Navigator.pop(context);
                          //     },
                          //     showTodayButton: true,
                          //     showActionButtons: true,
                          //     view: DateRangePickerView.month,
                          //     selectionMode:
                          //         DateRangePickerSelectionMode.range),
                          //     ),
                          //   );
                          // });
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
                                Iconsax.export,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(staticTextTranslate('Export'),
                                  style: TextStyle(
                                      fontSize: getMediumFontSize,
                                      color:
                                          const Color.fromARGB(255, 0, 0, 0))),
                            ],
                          ),
                          onPressed: () {},
                        )),
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
                                  Iconsax.printer,
                                  color: Colors.black),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(staticTextTranslate('Print'),
                                  style: TextStyle(
                                      fontSize: getMediumFontSize,
                                      color: Colors.black)),
                            ],
                          ),
                          onPressed: () {
                            List<CustomerPaymentTempModel>
                                allCustomerPaymentData = dbReceiptDataLst
                                        .map<CustomerPaymentTempModel>((e) =>
                                            CustomerPaymentTempModel(
                                                dateTime: e.createdDate,
                                                dbReceiptData: e))
                                        .toList() +
                                    currentCustomerPaymentLstData
                                        .map<CustomerPaymentTempModel>((e) =>
                                            CustomerPaymentTempModel(
                                                dateTime: e.createdDate,
                                                customerPaymentData: e))
                                        .toList();
                            allCustomerPaymentData.sort(
                                (a, b) => a.dateTime.compareTo(b.dateTime));

                            printCustomerPayment(
                                context,
                                allCustomerPaymentData,
                                widget.selectedCustomerData,
                                calculateTotalSalesAmt(),
                                calculateTotalPaid(),
                                (double.parse(calculateTotalSalesAmt()) -
                                        double.parse(calculateTotalPaid()))
                                    .toStringAsFixed(2));
                          },
                        )),
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
                        height: 30,
                        width: 370,
                        child: Row(children: [
                          const SizedBox(width: 10),
                          const Icon(
                            Iconsax.wallet_money,
                            size: 17,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            staticTextTranslate('Customer Payment'),
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
                                      width: 0.5, color: Colors.grey),
                                  borderRadius: BorderRadius.circular(5)),
                              elevation: 0,
                              color: Colors.white,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: ButtonBarSuper(
                                            buttonTextTheme:
                                                ButtonTextTheme.primary,
                                            wrapType: WrapType.fit,
                                            wrapFit: WrapFit.min,
                                            alignment: engSelectedLanguage
                                                ? WrapSuperAlignment.left
                                                : WrapSuperAlignment.right,
                                            lineSpacing: 20,
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
                                                        BorderRadius.circular(
                                                            4)),
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
                                                        if (receiptIdController
                                                            .text.isNotEmpty) {
                                                          receiptIdController
                                                              .clear();

                                                          customerPaymentDataSource = VendorPaymentDataSource(
                                                              receiptDataLst:
                                                                  dbReceiptDataLst,
                                                              selectedCustomerData:
                                                                  widget
                                                                      .selectedCustomerData,
                                                              customerPaymentData:
                                                                  currentCustomerPaymentLstData);
                                                          setState(() {});
                                                        }
                                                      },
                                                      splashRadius: 1,
                                                      icon: Icon(
                                                          receiptIdController
                                                                  .text.isEmpty
                                                              ? CupertinoIcons
                                                                  .search
                                                              : Icons.clear,
                                                          size: 18,
                                                          color:
                                                              receiptIdController
                                                                      .text
                                                                      .isEmpty
                                                                  ? Colors
                                                                      .grey[600]
                                                                  : Colors
                                                                      .black),
                                                    ),
                                                    Flexible(
                                                      child: TextField(
                                                        controller:
                                                            receiptIdController,
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              staticTextTranslate(
                                                                  'Receipt# / RV#'),
                                                          hintStyle: TextStyle(
                                                              color: Colors
                                                                  .grey[600]),
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 15,
                                                                  right: 5),
                                                          border:
                                                              InputBorder.none,
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
                                                        BorderRadius.circular(
                                                            4)),
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
                                                      onPressed: () {},
                                                      splashRadius: 1,
                                                      icon: Icon(
                                                          CupertinoIcons.search,
                                                          size: 18,
                                                          color:
                                                              Colors.grey[600]),
                                                    ),
                                                    Flexible(
                                                        child: Container(
                                                            width: 200,
                                                            height: 29,
                                                            decoration: BoxDecoration(
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    255),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8)),
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 10,
                                                                    left: 10),
                                                            child:
                                                                DropdownButton<
                                                                    String>(
                                                              isExpanded: true,
                                                              value:
                                                                  receiptTypeDropDownFilter,
                                                              underline:
                                                                  const SizedBox(),
                                                              hint: Text(
                                                                  staticTextTranslate(
                                                                      'All Document'),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        getMediumFontSize +
                                                                            2,
                                                                  )),
                                                              items: <String>[
                                                                'All Document',
                                                                'Receipt',
                                                                'Payment'
                                                              ].map((String
                                                                  value) {
                                                                return DropdownMenuItem<
                                                                    String>(
                                                                  value: value,
                                                                  child: Text(
                                                                      staticTextTranslate(
                                                                          value),
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            getMediumFontSize +
                                                                                2,
                                                                      )),
                                                                );
                                                              }).toList(),
                                                              onChanged: (val) {
                                                                setState(() {
                                                                  if (val ==
                                                                      'Receipt') {
                                                                    customerPaymentDataSource = VendorPaymentDataSource(
                                                                        receiptDataLst:
                                                                            dbReceiptDataLst,
                                                                        selectedCustomerData:
                                                                            widget.selectedCustomerData,
                                                                        customerPaymentData: []);
                                                                  } else if (val ==
                                                                      'Payment') {
                                                                    customerPaymentDataSource = VendorPaymentDataSource(
                                                                        receiptDataLst: [],
                                                                        selectedCustomerData:
                                                                            widget
                                                                                .selectedCustomerData,
                                                                        customerPaymentData:
                                                                            currentCustomerPaymentLstData);
                                                                  } else {
                                                                    customerPaymentDataSource = VendorPaymentDataSource(
                                                                        receiptDataLst:
                                                                            dbReceiptDataLst,
                                                                        selectedCustomerData:
                                                                            widget
                                                                                .selectedCustomerData,
                                                                        customerPaymentData:
                                                                            currentCustomerPaymentLstData);
                                                                  }
                                                                  receiptTypeDropDownFilter =
                                                                      val ??
                                                                          'All Document';
                                                                });
                                                              },
                                                            ))),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Iconsax.people,
                                                    size: 19,
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    widget.selectedCustomerData
                                                        .customerName,
                                                    style: TextStyle(
                                                      fontSize:
                                                          getLargeFontSize + 2,
                                                    ),
                                                  ),
                                                ],
                                              )),
                                        )
                                      ],
                                    ),
                                  ),
                                  if (loading)
                                    SizedBox(height: 400, child: showLoading()),
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
                                          isScrollbarAlwaysShown: true,
                                          onQueryRowHeight: (details) {
                                            // Set the row height as 70.0 to the column header row.
                                            return details.rowIndex == 0
                                                ? 25.0
                                                : 24.0;
                                          },
                                          rowHeight: 24,
                                          headerGridLinesVisibility:
                                              GridLinesVisibility.both,
                                          headerRowHeight: 25,
                                          allowSorting: true,
                                          allowTriStateSorting: true,
                                          controller: dataGridController,
                                          selectionMode: SelectionMode.single,
                                          source: customerPaymentDataSource!,
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
                                                columnName: 'doc',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    alignment: Alignment.center,
                                                    color:
                                                        const Color(0xffdddfe8),
                                                    child: Text(
                                                        staticTextTranslate(
                                                            'Document'),
                                                        style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
                                                        )))),
                                            GridColumn(
                                                columnName: 'doc#',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    alignment: Alignment.center,
                                                    color:
                                                        const Color(0xffdddfe8),
                                                    child: Text(
                                                        staticTextTranslate(
                                                            'Document#'),
                                                        style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
                                                        )))),
                                            GridColumn(
                                                columnName: 'doc type',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    alignment: Alignment.center,
                                                    color:
                                                        const Color(0xffdddfe8),
                                                    child: Text(
                                                      staticTextTranslate(
                                                          'Doc Type'),
                                                      style: TextStyle(
                                                        fontSize:
                                                            getMediumFontSize,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ))),
                                            GridColumn(
                                                columnName: 'creadted date',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    color:
                                                        const Color(0xffdddfe8),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                        staticTextTranslate(
                                                            'Created Date'),
                                                        style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
                                                        )))),
                                            GridColumn(
                                                columnName: 'payment',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    color:
                                                        const Color(0xffdddfe8),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                        staticTextTranslate(
                                                            'Payment'),
                                                        style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
                                                        )))),
                                            GridColumn(
                                                columnName: 'comment',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    color:
                                                        const Color(0xffdddfe8),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                        staticTextTranslate(
                                                            'Comment'),
                                                        style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
                                                        )))),
                                            GridColumn(
                                                columnName: 'purchased amount',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    color:
                                                        const Color(0xffdddfe8),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                        staticTextTranslate(
                                                            'Purchased Amount'),
                                                        style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
                                                        )))),
                                            GridColumn(
                                                columnName: 'paid amount',
                                                label: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    color:
                                                        const Color(0xffdddfe8),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                        staticTextTranslate(
                                                            'Paid Amount'),
                                                        style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
                                                        )))),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (!loading)
                                    Container(
                                      height: 110,
                                      color: const Color(0xffdddfe8),
                                      width: double.maxFinite,
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  staticTextTranslate(
                                                      'Total Sales Amt'),
                                                  style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize -
                                                              1),
                                                ),
                                                Text(
                                                  calculateTotalSalesAmt(),
                                                  style: TextStyle(
                                                    fontSize:
                                                        getMediumFontSize + 4,
                                                  ),
                                                ),
                                                const Expanded(
                                                  child: SizedBox(
                                                    height: 20,
                                                  ),
                                                ),
                                                Text(
                                                    staticTextTranslate(
                                                        'Balance'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize - 1,
                                                    )),
                                                Text(
                                                  (double.parse(
                                                              calculateTotalSalesAmt()) -
                                                          double.parse(
                                                              calculateTotalPaid()))
                                                      .toStringAsFixed(2),
                                                  style: TextStyle(
                                                    fontSize:
                                                        getMediumFontSize + 4,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 40,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  staticTextTranslate(
                                                      'Total Paid'),
                                                  style: TextStyle(
                                                    fontSize:
                                                        getMediumFontSize - 1,
                                                  ),
                                                ),
                                                Text(
                                                  calculateTotalPaid(),
                                                  style: TextStyle(
                                                    fontSize:
                                                        getMediumFontSize + 4,
                                                    color: const Color.fromARGB(
                                                        255, 23, 171, 31),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                          ]),
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

  customerPayment(
      {required CustomerData selectedCustomerData,
      required String paymentType,
      required double amount,
      required String comment,
      required String docId,
      required String documentNo,
      required DateTime createdDate}) {
    _vendorTypeAheadController.text = selectedCustomerData.customerName;

    bool showloading = false;
    var formKey = GlobalKey<FormState>();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(builder: (context, setState2) {
              return Dialog(
                backgroundColor: homeBgColor,
                child: SizedBox(
                    height: 385,
                    width: 550,
                    child: showloading
                        ? showLoading()
                        : Column(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Card(
                                    child: Container(
                                      width: 530,
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    staticTextTranslate(
                                                        'Customer Payment'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize + 4,
                                                    )),
                                                const SizedBox(
                                                  height: 15,
                                                ),
                                                Text(
                                                    staticTextTranslate(
                                                        'Customer'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize - 1,
                                                    )),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                SizedBox(
                                                  width: 250,
                                                  child: TypeAheadFormField(
                                                    getImmediateSuggestions:
                                                        false,
                                                    textFieldConfiguration:
                                                        TextFieldConfiguration(
                                                      style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  2,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                      controller:
                                                          _vendorTypeAheadController,
                                                      decoration: InputDecoration(
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 10,
                                                                  horizontal:
                                                                      13),
                                                          isDense: true,
                                                          hintStyle: TextStyle(
                                                              color: Colors
                                                                  .grey[600]),
                                                          border:
                                                              const OutlineInputBorder()),
                                                    ),
                                                    noItemsFoundBuilder:
                                                        (context) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10.0),
                                                        child: Text(
                                                            staticTextTranslate(
                                                                'No Items Found!'),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  getMediumFontSize,
                                                            )),
                                                      );
                                                    },
                                                    validator: (val) {
                                                      if (val!.isEmpty) {
                                                        return staticTextTranslate(
                                                            'Select a customer');
                                                      }
                                                      return null;
                                                    },
                                                    suggestionsCallback:
                                                        (pattern) {
                                                      return widget
                                                          .customerDataLst
                                                          .where((e) => e
                                                              .customerName
                                                              .toLowerCase()
                                                              .contains(pattern
                                                                  .toLowerCase()))
                                                          .toList();
                                                    },
                                                    itemBuilder: (context,
                                                        CustomerData
                                                            suggestion) {
                                                      return ListTile(
                                                        title: Text(
                                                            suggestion
                                                                .customerName,
                                                            style: TextStyle(
                                                              fontSize:
                                                                  getMediumFontSize +
                                                                      2,
                                                            )),
                                                      );
                                                    },
                                                    transitionBuilder: (context,
                                                        suggestionsBox,
                                                        controller) {
                                                      return suggestionsBox;
                                                    },
                                                    onSuggestionSelected:
                                                        (CustomerData
                                                            suggestion) {
                                                      _vendorTypeAheadController
                                                              .text =
                                                          suggestion
                                                              .customerName;

                                                      setState(() {
                                                        int i = widget
                                                            .customerDataLst
                                                            .indexWhere((element) =>
                                                                element
                                                                    .customerId ==
                                                                suggestion
                                                                    .customerId);
                                                        selectedCustomerData =
                                                            widget
                                                                .customerDataLst
                                                                .elementAt(i);
                                                      });
                                                      setState2(() {});
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 15,
                                                ),
                                                Text(
                                                    staticTextTranslate(
                                                        'Payment type'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize - 1,
                                                    )),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Container(
                                                    width: 250,
                                                    height: 35,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                        border: Border.all(
                                                            color:
                                                                Colors.grey)),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10),
                                                    child:
                                                        DropdownButton<String>(
                                                      isExpanded: true,
                                                      value: paymentType,
                                                      underline:
                                                          const SizedBox(),
                                                      itemHeight: 50,
                                                      items: <String>[
                                                        'Cash',
                                                        'Bank'
                                                      ].map((String value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Text(
                                                              staticTextTranslate(
                                                                  value),
                                                              style: TextStyle(
                                                                fontSize:
                                                                    getMediumFontSize +
                                                                        2,
                                                              )),
                                                        );
                                                      }).toList(),
                                                      onChanged: (val) {
                                                        if (val != null) {
                                                          setState(() {
                                                            paymentType = val;
                                                          });
                                                          setState2(() {});
                                                        }
                                                      },
                                                    )),
                                                const SizedBox(
                                                  height: 15,
                                                ),
                                                Text(
                                                    staticTextTranslate(
                                                        'Amount'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize - 1,
                                                    )),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                SizedBox(
                                                  width: 250,
                                                  child: Form(
                                                    key: formKey,
                                                    child: TextFormField(
                                                        autovalidateMode:
                                                            AutovalidateMode
                                                                .onUserInteraction,
                                                        validator: (val) {
                                                          if (val!.isEmpty ||
                                                              double.tryParse(
                                                                      val) ==
                                                                  null ||
                                                              double.parse(val)
                                                                  .isNegative) {
                                                            return staticTextTranslate(
                                                                'Enter a valid amount');
                                                          } else if (double
                                                                  .tryParse(
                                                                      val) ==
                                                              0) {
                                                            return staticTextTranslate(
                                                                'Please enter an amount');
                                                          }
                                                          return null;
                                                        },
                                                        initialValue:
                                                            amount.toString(),
                                                        style: const TextStyle(
                                                            fontSize: 16),
                                                        decoration: const InputDecoration(
                                                            isDense: true,
                                                            contentPadding:
                                                                EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            10,
                                                                        horizontal:
                                                                            15),
                                                            border:
                                                                OutlineInputBorder()),
                                                        onChanged: (val) {
                                                          if (val.isNotEmpty &&
                                                              double.tryParse(
                                                                      val) !=
                                                                  null) {
                                                            setState(() {
                                                              amount =
                                                                  double.parse(
                                                                      val);
                                                            });
                                                            setState2(() {});
                                                          }
                                                        }),
                                                  ),
                                                ),
                                              ]),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                height: 33,
                                              ),
                                              Text(
                                                  staticTextTranslate(
                                                      'Comment'),
                                                  style: TextStyle(
                                                    fontSize:
                                                        getMediumFontSize - 1,
                                                  )),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              SizedBox(
                                                width: 250,
                                                child: TextFormField(
                                                    autofocus: true,
                                                    initialValue: comment,
                                                    maxLines: 4,
                                                    autovalidateMode:
                                                        AutovalidateMode
                                                            .onUserInteraction,
                                                    validator: (val) {
                                                      if (val!.isEmpty) {
                                                        return staticTextTranslate(
                                                            'Please enter a comment');
                                                      }
                                                      return null;
                                                    },
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                    decoration: const InputDecoration(
                                                        isDense: true,
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        10,
                                                                    horizontal:
                                                                        15),
                                                        border:
                                                            OutlineInputBorder()),
                                                    onChanged: (val) {
                                                      if (val.isNotEmpty) {
                                                        setState(() {
                                                          comment = val;
                                                        });
                                                        setState2(() {});
                                                      }
                                                    }),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  width: 550,
                                  height: 60,
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
                                        height: 42,
                                        width: 173,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4))),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                    Icons.cancel_outlined,
                                                    color: Colors.black,
                                                    size: 20),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                    staticTextTranslate(
                                                        'Cancel'),
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
                                        height: 42,
                                        width: 173,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: darkBlueColor,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4))),
                                            onPressed: () async {
                                              if (formKey.currentState!
                                                  .validate()) {
                                                setState(() {
                                                  showloading = true;
                                                });
                                                String docNo = documentNo;
                                                if (documentNo.isEmpty) {
                                                  docNo = '100001';
                                                  List<CustomerPaymentData>
                                                      selectedCustomerPaymentLstData =
                                                      allCustomerPaymentdata
                                                          .where((element) =>
                                                              element
                                                                  .customerId ==
                                                              selectedCustomerData
                                                                  .customerId)
                                                          .toList();
                                                  selectedCustomerPaymentLstData
                                                      .sort((a, b) => a
                                                          .createdDate
                                                          .compareTo(
                                                              b.createdDate));
                                                  if (selectedCustomerPaymentLstData
                                                      .isNotEmpty) {
                                                    docNo = (int.parse(
                                                                selectedCustomerPaymentLstData
                                                                    .last
                                                                    .documentNo) +
                                                            1)
                                                        .toString();
                                                  }
                                                }

                                                await FbCustomerPaymentDbService(
                                                        context: context)
                                                    .addCustomerPaymentData([
                                                  CustomerPaymentData(
                                                      docId: docId.isEmpty
                                                          ? getRandomString(20)
                                                          : docId,
                                                      customerId:
                                                          selectedCustomerData
                                                              .customerId,
                                                      paymentType: paymentType,
                                                      amount: amount,
                                                      createdDate: createdDate,
                                                      comment: comment,
                                                      documentNo: docNo)
                                                ]);

                                                await fbFetchInfo();
                                                setState(() {
                                                  showloading = false;
                                                });
                                                Navigator.pop(context);
                                              }
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(Iconsax.archive),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                    staticTextTranslate('Save'),
                                                    style: TextStyle(
                                                      fontSize:
                                                          getMediumFontSize,
                                                    )),
                                              ],
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )),
              );
            }));
  }
}

class VendorPaymentDataSource extends DataGridSource {
  VendorPaymentDataSource(
      {required List<DbReceiptData> receiptDataLst,
      required List<CustomerPaymentData> customerPaymentData,
      required CustomerData selectedCustomerData}) {
    List<CustomerPaymentTempModel> allCustomerPaymentData = receiptDataLst
            .map<CustomerPaymentTempModel>((e) => CustomerPaymentTempModel(
                dateTime: e.createdDate, dbReceiptData: e))
            .toList() +
        customerPaymentData
            .map<CustomerPaymentTempModel>((e) => CustomerPaymentTempModel(
                dateTime: e.createdDate, customerPaymentData: e))
            .toList();
    allCustomerPaymentData.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    _employeeData = [
          DataGridRow(cells: [
            const DataGridCell<int>(
                columnName: 'serialNumberForStyleColor', value: 0),
            const DataGridCell<String>(
                columnName: 'doc', value: 'Opening Balance'),
            const DataGridCell<String>(columnName: 'doc#', value: ''),
            const DataGridCell<String>(columnName: 'doc type', value: ''),
            const DataGridCell<String>(columnName: 'creadted date', value: ''),
            const DataGridCell<String>(columnName: 'payment', value: ''),
            const DataGridCell<String>(columnName: 'comment', value: ''),
            DataGridCell<String>(
                columnName: 'purchased amount',
                value: selectedCustomerData.openingBalance),
            const DataGridCell<String>(columnName: 'paid amount', value: ''),
          ])
        ] +
        allCustomerPaymentData
            .map<DataGridRow>((e) => DataGridRow(cells: [
                  DataGridCell<int>(
                      columnName: 'serialNumberForStyleColor',
                      value: allCustomerPaymentData.indexOf(e) + 2),
                  DataGridCell<String>(
                      columnName: 'doc',
                      value: e.dbReceiptData != null ? 'Receipt' : 'Payment'),
                  DataGridCell<String>(
                      columnName: 'doc#',
                      value: e.dbReceiptData != null
                          ? e.dbReceiptData!.receiptNo
                          : 'CP${e.customerPaymentData!.documentNo}'),
                  DataGridCell<String>(
                      columnName: 'doc type',
                      value: e.dbReceiptData != null
                          ? e.dbReceiptData!.receiptType
                          : ''),
                  DataGridCell<String>(
                      columnName: 'creadted date',
                      value: DateFormat.yMd().add_jm().format(e.dateTime)),
                  DataGridCell<String>(
                      columnName: 'payment',
                      value: e.dbReceiptData != null
                          ? e.dbReceiptData!.tendor.credit != '0'
                              ? 'Credit'
                              : e.dbReceiptData!.tendor.cash != '0' &&
                                      e.dbReceiptData!.tendor.creditCard == '0'
                                  ? 'Cash'
                                  : e.dbReceiptData!.tendor.cash == '0' &&
                                          e.dbReceiptData!.tendor.creditCard !=
                                              '0'
                                      ? 'Credit Card'
                                      : 'Split'
                          : e.customerPaymentData!.paymentType),
                  DataGridCell<String>(
                      columnName: 'comment',
                      value: e.dbReceiptData != null
                          ? ''
                          : e.customerPaymentData!.comment),
                  DataGridCell<String>(
                      columnName: 'purchased amount',
                      value: e.dbReceiptData != null
                          ? e.dbReceiptData!.subTotal
                          : ''),
                  DataGridCell<String>(
                      columnName: 'paid amount',
                      value: e.dbReceiptData != null
                          ? ''
                          : e.customerPaymentData!.amount.toString()),
                ]))
            .toList();
  }

  List<DataGridRow> _employeeData = [];

  @override
  List<DataGridRow> get rows => _employeeData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    bool isReturnVoucher = false;

    if (row.getCells().indexWhere(
            (e) => e.columnName == 'doc type' && e.value == 'Return') !=
        -1) isReturnVoucher = true;
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
                  color: isReturnVoucher ? Colors.red[700] : Colors.black,
                  fontWeight: FontWeight.w400),
            ),
          );
        }).toList());
  }
}
