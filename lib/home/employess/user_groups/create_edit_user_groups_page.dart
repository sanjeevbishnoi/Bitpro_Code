import 'package:bitpro_hive/home/sales/customer/sideMenuButton.dart';
import 'package:bitpro_hive/services/firestore_api/fb_user_group_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:bitpro_hive/widget/bTextField.dart';
import 'package:bitpro_hive/widget/onpage_button.dart';
import 'package:bitpro_hive/widget/onpage_panel.dart';
import 'package:bitpro_hive/widget/top_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
          child: Column(
            children: [
              const TopBar(pageName: 'User Group'),
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
                            SideMenuButton(
                              label: 'Back',
                              iconPath: 'assets/icons/back.png',
                              buttonFunction: () {
                                showDiscardChangesDialog(context);
                              },
                            ),
                            SideMenuButton(
                                label: 'Save',
                                iconPath: 'assets/icons/save.png',
                                buttonFunction: () => onTapSaveButton())
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 0,
                      ),
                      Expanded(
                        child: loading
                            ? showLoading()
                            : Form(
                                key: formKey,
                                child: OnPagePanel(
                                    columnForTextField: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        BTextField(
                                          label: 'Group Name',
                                          initialValue: groupName,
                                          validator: (value) => value!.isEmpty
                                              ? staticTextTranslate(
                                                  'Enter group name')
                                              : null,
                                          onChanged: (val) => setState(() {
                                            groupName = val;
                                          }),
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        BTextField(
                                          label: 'Group Description',
                                          initialValue: groupDiscription,
                                          validator: (value) => value!.isEmpty
                                              ? staticTextTranslate(
                                                  'Enter group description')
                                              : null,
                                          onChanged: (val) => setState(() {
                                            groupDiscription = val;
                                          }),
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Flexible(
                                          child: Text(
                                            staticTextTranslate(
                                                '  All active permission can be assigned to this Group.'),
                                            style: TextStyle(
                                              fontSize: getMediumFontSize - 1,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        TextButton(
                                            onPressed: () {
                                              employees = true;

                                              registers = true;
                                              groups = true;
                                              salesReceipt = true;
                                              vendors = true;
                                              reports = true;
                                              department = true;
                                              settings = true;

                                              inventory = true;

                                              purchaseVoucher = true;

                                              customers = true;
                                              receipt = true;
                                              formerZout = true;
                                              adjustment = true;
                                              backupReset = true;
                                              promotion = true;

                                              setState(() {});
                                            },
                                            child: Text(
                                              'Select All',
                                              style: TextStyle(
                                                fontSize: getMediumFontSize - 1,
                                              ),
                                            )),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        SizedBox(
                                          width: 470,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Checkbox(
                                                            activeColor:
                                                                darkBlueColor,
                                                            side:
                                                                const BorderSide(
                                                                    width: 0.7),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4)),
                                                            value: employees,
                                                            onChanged: (val) {
                                                              setState(() {
                                                                employees =
                                                                    val!;
                                                              });
                                                            }),
                                                        Text(
                                                            staticTextTranslate(
                                                                '  Employees'),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  getMediumFontSize,
                                                            )),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Checkbox(
                                                            activeColor:
                                                                darkBlueColor,
                                                            side:
                                                                const BorderSide(
                                                                    width: 0.7),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            3)),
                                                            value: groups,
                                                            onChanged: (val) {
                                                              setState(() {
                                                                groups = val!;
                                                              });
                                                            }),
                                                        Text(
                                                            staticTextTranslate(
                                                                '  Groups'),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  getMediumFontSize,
                                                            )),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Checkbox(
                                                            activeColor:
                                                                darkBlueColor,
                                                            side:
                                                                const BorderSide(
                                                                    width: 0.7),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            3)),
                                                            value: vendors,
                                                            onChanged: (val) {
                                                              setState(() {
                                                                vendors = val!;
                                                              });
                                                            }),
                                                        Text(
                                                            staticTextTranslate(
                                                                '  Vendors'),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  getMediumFontSize,
                                                            )),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Checkbox(
                                                            activeColor:
                                                                darkBlueColor,
                                                            side:
                                                                const BorderSide(
                                                                    width: 0.7),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            3)),
                                                            value: department,
                                                            onChanged: (val) {
                                                              setState(() {
                                                                department =
                                                                    val!;
                                                              });
                                                            }),
                                                        Text(
                                                            staticTextTranslate(
                                                                '  Departments'),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  getMediumFontSize,
                                                            )),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Checkbox(
                                                            activeColor:
                                                                darkBlueColor,
                                                            side:
                                                                const BorderSide(
                                                                    width: 0.7),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            3)),
                                                            value: inventory,
                                                            onChanged: (val) {
                                                              setState(() {
                                                                inventory =
                                                                    val!;
                                                              });
                                                            }),
                                                        Text(
                                                            staticTextTranslate(
                                                                '  Inventory'),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  getMediumFontSize,
                                                            )),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Checkbox(
                                                            activeColor:
                                                                darkBlueColor,
                                                            side:
                                                                const BorderSide(
                                                                    width: 0.7),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            3)),
                                                            value: customers,
                                                            onChanged: (val) {
                                                              setState(() {
                                                                customers =
                                                                    val!;
                                                              });
                                                            }),
                                                        Text(
                                                            staticTextTranslate(
                                                                '  Customers'),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  getMediumFontSize,
                                                            )),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Checkbox(
                                                            activeColor:
                                                                darkBlueColor,
                                                            side:
                                                                const BorderSide(
                                                                    width: 0.7),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            3)),
                                                            value: formerZout,
                                                            onChanged: (val) {
                                                              setState(() {
                                                                formerZout =
                                                                    val!;
                                                              });
                                                            }),
                                                        Text(
                                                            staticTextTranslate(
                                                                '  Former Z Out'),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  getMediumFontSize,
                                                            )),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Checkbox(
                                                            activeColor:
                                                                darkBlueColor,
                                                            side:
                                                                const BorderSide(
                                                                    width: 0.7),
                                                            shape: RoundedRectangleBorder(
                                                                side:
                                                                    const BorderSide(
                                                                        width:
                                                                            0.7),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            3)),
                                                            value: backupReset,
                                                            onChanged: (val) {
                                                              setState(() {
                                                                backupReset =
                                                                    val!;
                                                              });
                                                            }),
                                                        Text(
                                                            staticTextTranslate(
                                                                '  Backup & Reset'),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  getMediumFontSize,
                                                            )),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Checkbox(
                                                            activeColor:
                                                                darkBlueColor,
                                                            side:
                                                                const BorderSide(
                                                                    width: 0.7),
                                                            shape: RoundedRectangleBorder(
                                                                side:
                                                                    const BorderSide(
                                                                        width:
                                                                            0.7),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            3)),
                                                            value: registers,
                                                            onChanged: (val) {
                                                              setState(() {
                                                                registers =
                                                                    val!;
                                                              });
                                                            }),
                                                        Text(
                                                            staticTextTranslate(
                                                                '  Registers'),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  getMediumFontSize,
                                                            )),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Checkbox(
                                                            activeColor:
                                                                darkBlueColor,
                                                            side:
                                                                const BorderSide(
                                                                    width: 0.7),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            3)),
                                                            value: salesReceipt,
                                                            onChanged: (val) {
                                                              setState(() {
                                                                salesReceipt =
                                                                    val!;
                                                              });
                                                            }),
                                                        Text(
                                                            staticTextTranslate(
                                                                '  Sales Receipt'),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  getMediumFontSize,
                                                            )),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Checkbox(
                                                            activeColor:
                                                                darkBlueColor,
                                                            side:
                                                                const BorderSide(
                                                                    width: 0.7),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            3)),
                                                            value: reports,
                                                            onChanged: (val) {
                                                              setState(() {
                                                                reports = val!;
                                                              });
                                                            }),
                                                        Text(
                                                            staticTextTranslate(
                                                                '  Reports'),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  getMediumFontSize,
                                                            )),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Checkbox(
                                                            activeColor:
                                                                darkBlueColor,
                                                            side:
                                                                const BorderSide(
                                                                    width: 0.7),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            3)),
                                                            value: settings,
                                                            onChanged: (val) {
                                                              setState(() {
                                                                settings = val!;
                                                              });
                                                            }),
                                                        Text(
                                                            staticTextTranslate(
                                                                '  Settings'),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  getMediumFontSize,
                                                            )),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Checkbox(
                                                            activeColor:
                                                                darkBlueColor,
                                                            side:
                                                                const BorderSide(
                                                                    width: 0.7),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            3)),
                                                            value:
                                                                purchaseVoucher,
                                                            onChanged: (val) {
                                                              setState(() {
                                                                purchaseVoucher =
                                                                    val!;
                                                              });
                                                            }),
                                                        Text(
                                                            staticTextTranslate(
                                                                '  Purchase voucher'),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  getMediumFontSize,
                                                            )),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Checkbox(
                                                            activeColor:
                                                                darkBlueColor,
                                                            side:
                                                                const BorderSide(
                                                                    width: 0.7),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            3)),
                                                            value: receipt,
                                                            onChanged: (val) {
                                                              setState(() {
                                                                receipt = val!;
                                                              });
                                                            }),
                                                        Text(
                                                            staticTextTranslate(
                                                                '  Receipt'),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  getMediumFontSize,
                                                            )),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Checkbox(
                                                            activeColor:
                                                                darkBlueColor,
                                                            side:
                                                                const BorderSide(
                                                                    width: 0.7),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            3)),
                                                            value: adjustment,
                                                            onChanged: (val) {
                                                              setState(() {
                                                                adjustment =
                                                                    val!;
                                                              });
                                                            }),
                                                        Text(
                                                            staticTextTranslate(
                                                                '  Adjustment'),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  getMediumFontSize,
                                                            )),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Checkbox(
                                                            activeColor:
                                                                darkBlueColor,
                                                            side:
                                                                const BorderSide(
                                                                    width: 0.7),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            3)),
                                                            value: promotion,
                                                            onChanged: (val) {
                                                              setState(() {
                                                                promotion =
                                                                    val!;
                                                              });
                                                            }),
                                                        Text(
                                                            staticTextTranslate(
                                                                '  Promotion'),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  getMediumFontSize,
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
                                    rowForButton: Row(
                                      children: [
                                        OnPageButton(
                                          icon: Iconsax.archive,
                                          label: 'Save',
                                          onPressed: onTapSaveButton,
                                        ),
                                      ],
                                    ),
                                    topLabel: 'User Group Details'),
                              ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  onTapSaveButton() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });
      await FbUserGroupDbService(context: context).addUpdateUserGroup([
        UserGroupData(
            createdDate: widget.edit && widget.selectedRowData != null
                ? widget.selectedRowData!.createdDate
                : DateTime.now(),
            createdBy: widget.edit && widget.selectedRowData != null
                ? widget.selectedRowData!.createdBy
                : widget.userData.username,
            docId: widget.edit && widget.selectedRowData != null
                ? widget.selectedRowData!.docId
                : getRandomString(20),
            name: groupName!,
            description: groupDiscription!,
            employees: employees,
            registers: registers,
            groups: groups,
            salesReceipt: salesReceipt,
            vendors: vendors,
            reports: reports,
            departments: department,
            settings: settings,
            inventory: inventory,
            purchaseVoucher: purchaseVoucher,
            customers: customers,
            receipt: receipt,
            formerZout: formerZout,
            adjustment: adjustment,
            backupReset: backupReset,
            promotion: promotion)
      ]);

      Navigator.pop(context, true);

      setState(() {
        loading = false;
      });
    }
  }
}
