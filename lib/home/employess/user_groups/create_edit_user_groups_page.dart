import 'package:bitpro_hive/home/sales/customer/sideMenuButton.dart';
import 'package:bitpro_hive/services/firestore_api/fb_user_group_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:bitpro_hive/widget/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/model/user_group_data.dart';
import 'package:bitpro_hive/shared/custom_top_nav_bar.dart';
import 'package:bitpro_hive/shared/loading.dart';
import '../../../shared/dialogs/discard_changes_dialog.dart';
import '../../../shared/global_variables/font_sizes.dart';
import '../../../shared/global_variables/static_text_translate.dart';

class CreateEditUserGroupsPage extends StatefulWidget {
  final UserData userData;
  final bool edit;
  final UserGroupData? selectedRowData;
  const CreateEditUserGroupsPage(
      {Key? key,
      required this.userData,
      this.edit = false,
      this.selectedRowData})
      : super(key: key);

  @override
  State<CreateEditUserGroupsPage> createState() =>
      _CreateEditUserGroupsPageState();
}

class _CreateEditUserGroupsPageState extends State<CreateEditUserGroupsPage> {
  String? groupName;
  String? groupDiscription;
  bool employees = false;
  bool registers = false;
  bool groups = false;
  bool salesReceipt = false;
  bool vendors = false;
  bool reports = false;
  bool department = false;
  bool settings = false;
  bool inventory = false;
  bool purchaseVoucher = false;
  bool customers = false;
  bool receipt = false;
  bool formerZout = false;
  bool adjustment = false;
  bool backupReset = false;
  bool promotion = false;

  bool loading = false;
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.edit && widget.selectedRowData != null) {
      groupName = widget.selectedRowData!.name;
      groupDiscription = widget.selectedRowData!.description;
      employees = widget.selectedRowData!.employees;
      registers = widget.selectedRowData!.registers;
      groups = widget.selectedRowData!.groups;
      salesReceipt = widget.selectedRowData!.salesReceipt;
      vendors = widget.selectedRowData!.vendors;
      reports = widget.selectedRowData!.reports;
      department = widget.selectedRowData!.departments;
      settings = widget.selectedRowData!.settings;
      inventory = widget.selectedRowData!.inventory;
      purchaseVoucher = widget.selectedRowData!.purchaseVoucher;
      customers = widget.selectedRowData!.customers;
      receipt = widget.selectedRowData!.receipt;
      formerZout = widget.selectedRowData!.formerZout;
      adjustment = widget.selectedRowData!.adjustment;
      backupReset = widget.selectedRowData!.backupReset;
      promotion = widget.selectedRowData!.promotion;
    }
    super.initState();
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
                  pageName: 'Security Group',
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
                                  showDiscardChangesDialog(context,
                                      receipt: false);
                                },
                            ),
                           
                          ],
                        ),
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
                            
                            Expanded(
                              child: SizedBox(
                                width: double.maxFinite,
                                height: 120,
                                child: Card(
                                    shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                            width: 0.5, color: Colors.grey),
                                        borderRadius: BorderRadius.circular(4)),
                                    elevation: 0,
                                    color: Colors.white,
                                    child: loading
                                        ? showLoading()
                                        : Form(
                                            key: formKey,
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  child: SingleChildScrollView(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              15.0),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              staticTextTranslate(
                                                                  'Module Permission'),
                                                              style: TextStyle(
                                                                fontSize:
                                                                    getMediumFontSize,
                                                              )),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Container(
                                                                height: 5,
                                                                width: 120,
                                                                decoration: BoxDecoration(
                                                                    color:
                                                                        darkBlueColor,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8)),
                                                              ),
                                                              Flexible(
                                                                child:
                                                                    Container(
                                                                  height: 1,
                                                                  width: double
                                                                      .maxFinite,
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                              .grey[
                                                                          300],
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8)),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                          ButtonBar(
                                                            alignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                width: 210,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                        staticTextTranslate(
                                                                            'Group Name'),
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              getMediumFontSize - 1,
                                                                        )),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    TextFormField(
                                                                      initialValue:
                                                                          groupName,
                                                                      validator: (value) => value!
                                                                              .isEmpty
                                                                          ? staticTextTranslate(
                                                                              'Enter group name')
                                                                          : null,
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                      decoration: const InputDecoration(
                                                                          isDense:
                                                                              true,
                                                                          contentPadding: EdgeInsets.symmetric(
                                                                              vertical:
                                                                                  10,
                                                                              horizontal:
                                                                                  15),
                                                                          border:
                                                                              OutlineInputBorder()),
                                                                      onChanged:
                                                                          (val) =>
                                                                              setState(() {
                                                                        groupName =
                                                                            val;
                                                                      }),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 20,
                                                                width: 5,
                                                              ),
                                                              SizedBox(
                                                                width: 280,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                        staticTextTranslate(
                                                                            'Group Description'),
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              getMediumFontSize - 1,
                                                                        )),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    TextFormField(
                                                                      initialValue:
                                                                          groupDiscription,
                                                                      validator: (value) => value!
                                                                              .isEmpty
                                                                          ? staticTextTranslate(
                                                                              'Enter group description')
                                                                          : null,
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                      decoration: const InputDecoration(
                                                                          isDense:
                                                                              true,
                                                                          contentPadding: EdgeInsets.symmetric(
                                                                              vertical:
                                                                                  10,
                                                                              horizontal:
                                                                                  15),
                                                                          border:
                                                                              OutlineInputBorder()),
                                                                      onChanged:
                                                                          (val) =>
                                                                              setState(() {
                                                                        groupDiscription =
                                                                            val;
                                                                      }),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 15,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                staticTextTranslate(
                                                                    '  All active permission can be assigned to this Group.'),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      getMediumFontSize -
                                                                          1,
                                                                ),
                                                              ),
                                                              TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    employees =
                                                                        true;

                                                                    registers =
                                                                        true;
                                                                    groups =
                                                                        true;
                                                                    salesReceipt =
                                                                        true;
                                                                    vendors =
                                                                        true;
                                                                    reports =
                                                                        true;
                                                                    department =
                                                                        true;
                                                                    settings =
                                                                        true;

                                                                    inventory =
                                                                        true;

                                                                    purchaseVoucher =
                                                                        true;

                                                                    customers =
                                                                        true;
                                                                    receipt =
                                                                        true;
                                                                    formerZout =
                                                                        true;
                                                                    adjustment =
                                                                        true;
                                                                    backupReset =
                                                                        true;
                                                                    promotion =
                                                                        true;

                                                                    setState(
                                                                        () {});
                                                                  },
                                                                  child: Text(
                                                                    'Select All',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          getMediumFontSize -
                                                                              1,
                                                                    ),
                                                                  ))
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          SizedBox(
                                                            width: 470,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          Checkbox(
                                                                              activeColor: darkBlueColor,
                                                                              side: const BorderSide(width: 0.7),
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                              value: employees,
                                                                              onChanged: (val) {
                                                                                setState(() {
                                                                                  employees = val!;
                                                                                });
                                                                              }),
                                                                          Text(
                                                                              staticTextTranslate('  Employees'),
                                                                              style: TextStyle(
                                                                                fontSize: getMediumFontSize,
                                                                              )),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Checkbox(
                                                                              activeColor: darkBlueColor,
                                                                              side: const BorderSide(width: 0.7),
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                                                                              value: groups,
                                                                              onChanged: (val) {
                                                                                setState(() {
                                                                                  groups = val!;
                                                                                });
                                                                              }),
                                                                          Text(
                                                                              staticTextTranslate('  Groups'),
                                                                              style: TextStyle(
                                                                                fontSize: getMediumFontSize,
                                                                              )),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Checkbox(
                                                                              activeColor: darkBlueColor,
                                                                              side: const BorderSide(width: 0.7),
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                                                                              value: vendors,
                                                                              onChanged: (val) {
                                                                                setState(() {
                                                                                  vendors = val!;
                                                                                });
                                                                              }),
                                                                          Text(
                                                                              staticTextTranslate('  Vendors'),
                                                                              style: TextStyle(
                                                                                fontSize: getMediumFontSize,
                                                                              )),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Checkbox(
                                                                              activeColor: darkBlueColor,
                                                                              side: const BorderSide(width: 0.7),
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                                                                              value: department,
                                                                              onChanged: (val) {
                                                                                setState(() {
                                                                                  department = val!;
                                                                                });
                                                                              }),
                                                                          Text(
                                                                              staticTextTranslate('  Departments'),
                                                                              style: TextStyle(
                                                                                fontSize: getMediumFontSize,
                                                                              )),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Checkbox(
                                                                              activeColor: darkBlueColor,
                                                                              side: const BorderSide(width: 0.7),
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                                                                              value: inventory,
                                                                              onChanged: (val) {
                                                                                setState(() {
                                                                                  inventory = val!;
                                                                                });
                                                                              }),
                                                                          Text(
                                                                              staticTextTranslate('  Inventory'),
                                                                              style: TextStyle(
                                                                                fontSize: getMediumFontSize,
                                                                              )),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Checkbox(
                                                                              activeColor: darkBlueColor,
                                                                              side: const BorderSide(width: 0.7),
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                                                                              value: customers,
                                                                              onChanged: (val) {
                                                                                setState(() {
                                                                                  customers = val!;
                                                                                });
                                                                              }),
                                                                          Text(
                                                                              staticTextTranslate('  Customers'),
                                                                              style: TextStyle(
                                                                                fontSize: getMediumFontSize,
                                                                              )),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Checkbox(
                                                                              activeColor: darkBlueColor,
                                                                              side: const BorderSide(width: 0.7),
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                                                                              value: formerZout,
                                                                              onChanged: (val) {
                                                                                setState(() {
                                                                                  formerZout = val!;
                                                                                });
                                                                              }),
                                                                          Text(
                                                                              staticTextTranslate('  Former Z Out'),
                                                                              style: TextStyle(
                                                                                fontSize: getMediumFontSize,
                                                                              )),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Checkbox(
                                                                              activeColor: darkBlueColor,
                                                                              side: const BorderSide(width: 0.7),
                                                                              shape: RoundedRectangleBorder(side: const BorderSide(width: 0.7), borderRadius: BorderRadius.circular(3)),
                                                                              value: backupReset,
                                                                              onChanged: (val) {
                                                                                setState(() {
                                                                                  backupReset = val!;
                                                                                });
                                                                              }),
                                                                          Text(
                                                                              staticTextTranslate('  Backup & Reset'),
                                                                              style: TextStyle(
                                                                                fontSize: getMediumFontSize,
                                                                              )),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          Checkbox(
                                                                              activeColor: darkBlueColor,
                                                                              side: const BorderSide(width: 0.7),
                                                                              shape: RoundedRectangleBorder(side: const BorderSide(width: 0.7), borderRadius: BorderRadius.circular(3)),
                                                                              value: registers,
                                                                              onChanged: (val) {
                                                                                setState(() {
                                                                                  registers = val!;
                                                                                });
                                                                              }),
                                                                          Text(
                                                                              staticTextTranslate('  Registers'),
                                                                              style: TextStyle(
                                                                                fontSize: getMediumFontSize,
                                                                              )),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Checkbox(
                                                                              activeColor: darkBlueColor,
                                                                              side: const BorderSide(width: 0.7),
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                                                                              value: salesReceipt,
                                                                              onChanged: (val) {
                                                                                setState(() {
                                                                                  salesReceipt = val!;
                                                                                });
                                                                              }),
                                                                          Text(
                                                                              staticTextTranslate('  Sales Receipt'),
                                                                              style: TextStyle(
                                                                                fontSize: getMediumFontSize,
                                                                              )),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Checkbox(
                                                                              activeColor: darkBlueColor,
                                                                              side: const BorderSide(width: 0.7),
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                                                                              value: reports,
                                                                              onChanged: (val) {
                                                                                setState(() {
                                                                                  reports = val!;
                                                                                });
                                                                              }),
                                                                          Text(
                                                                              staticTextTranslate('  Reports'),
                                                                              style: TextStyle(
                                                                                fontSize: getMediumFontSize,
                                                                              )),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Checkbox(
                                                                              activeColor: darkBlueColor,
                                                                              side: const BorderSide(width: 0.7),
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                                                                              value: settings,
                                                                              onChanged: (val) {
                                                                                setState(() {
                                                                                  settings = val!;
                                                                                });
                                                                              }),
                                                                          Text(
                                                                              staticTextTranslate('  Settings'),
                                                                              style: TextStyle(
                                                                                fontSize: getMediumFontSize,
                                                                              )),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Checkbox(
                                                                              activeColor: darkBlueColor,
                                                                              side: const BorderSide(width: 0.7),
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                                                                              value: purchaseVoucher,
                                                                              onChanged: (val) {
                                                                                setState(() {
                                                                                  purchaseVoucher = val!;
                                                                                });
                                                                              }),
                                                                          Text(
                                                                              staticTextTranslate('  Purchase voucher'),
                                                                              style: TextStyle(
                                                                                fontSize: getMediumFontSize,
                                                                              )),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Checkbox(
                                                                              activeColor: darkBlueColor,
                                                                              side: const BorderSide(width: 0.7),
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                                                                              value: receipt,
                                                                              onChanged: (val) {
                                                                                setState(() {
                                                                                  receipt = val!;
                                                                                });
                                                                              }),
                                                                          Text(
                                                                              staticTextTranslate('  Receipt'),
                                                                              style: TextStyle(
                                                                                fontSize: getMediumFontSize,
                                                                              )),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Checkbox(
                                                                              activeColor: darkBlueColor,
                                                                              side: const BorderSide(width: 0.7),
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                                                                              value: adjustment,
                                                                              onChanged: (val) {
                                                                                setState(() {
                                                                                  adjustment = val!;
                                                                                });
                                                                              }),
                                                                          Text(
                                                                              staticTextTranslate('  Adjustment'),
                                                                              style: TextStyle(
                                                                                fontSize: getMediumFontSize,
                                                                              )),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Checkbox(
                                                                              activeColor: darkBlueColor,
                                                                              side: const BorderSide(width: 0.7),
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                                                                              value: promotion,
                                                                              onChanged: (val) {
                                                                                setState(() {
                                                                                  promotion = val!;
                                                                                });
                                                                              }),
                                                                          Text(
                                                                              staticTextTranslate('  Promotion'),
                                                                              style: TextStyle(
                                                                                fontSize: getMediumFontSize,
                                                                              )),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: Container(
                                                    height: 63,
                                                    width: double.maxFinite,
                                                    color:
                                                        const Color(0xffdddfe8),
                                                    child: Row(
                                                      children: [
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        SizedBox(
                                                          height: 42,
                                                          width: 173,
                                                          child: ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                  side: const BorderSide(
                                                                      width:
                                                                          0.5,
                                                                      color: Colors
                                                                          .grey),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              3))),
                                                              onPressed: () {
                                                                showDiscardChangesDialog(
                                                                    context);
                                                              },
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  const Icon(
                                                                      Icons
                                                                          .cancel_outlined,
                                                                      color: Colors
                                                                          .black),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Text(
                                                                    staticTextTranslate(
                                                                        'Cancel'),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            getMediumFontSize,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
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
                                                                  backgroundColor:
                                                                      darkBlueColor,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5))),
                                                              onPressed:
                                                                  () async {
                                                                if (formKey
                                                                    .currentState!
                                                                    .validate()) {
                                                                  setState(() {
                                                                    loading =
                                                                        true;
                                                                  });
                                                                  await FbUserGroupDbService(
                                                                          context:
                                                                              context)
                                                                      .addUpdateUserGroup([
                                                                    UserGroupData(
                                                                        createdDate: widget.edit && widget.selectedRowData != null
                                                                            ? widget
                                                                                .selectedRowData!.createdDate
                                                                            : DateTime
                                                                                .now(),
                                                                        createdBy: widget.edit && widget.selectedRowData != null
                                                                            ? widget
                                                                                .selectedRowData!.createdBy
                                                                            : widget
                                                                                .userData.username,
                                                                        docId: widget.edit && widget.selectedRowData != null
                                                                            ? widget
                                                                                .selectedRowData!.docId
                                                                            : getRandomString(
                                                                                20),
                                                                        name:
                                                                            groupName!,
                                                                        description:
                                                                            groupDiscription!,
                                                                        employees:
                                                                            employees,
                                                                        registers:
                                                                            registers,
                                                                        groups:
                                                                            groups,
                                                                        salesReceipt:
                                                                            salesReceipt,
                                                                        vendors:
                                                                            vendors,
                                                                        reports:
                                                                            reports,
                                                                        departments:
                                                                            department,
                                                                        settings:
                                                                            settings,
                                                                        inventory:
                                                                            inventory,
                                                                        purchaseVoucher:
                                                                            purchaseVoucher,
                                                                        customers:
                                                                            customers,
                                                                        receipt:
                                                                            receipt,
                                                                        formerZout:
                                                                            formerZout,
                                                                        adjustment:
                                                                            adjustment,
                                                                        backupReset:
                                                                            backupReset,
                                                                        promotion:
                                                                            promotion)
                                                                  ]);

                                                                  Navigator.pop(
                                                                      context,
                                                                      true);

                                                                  setState(() {
                                                                    loading =
                                                                        false;
                                                                  });
                                                                }
                                                              },
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  const Icon(
                                                                    Iconsax
                                                                        .archive,
                                                                    size: 20,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Text(
                                                                      staticTextTranslate(
                                                                          'Save'),
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            getMediumFontSize,
                                                                      )),
                                                                ],
                                                              )),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
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
}
