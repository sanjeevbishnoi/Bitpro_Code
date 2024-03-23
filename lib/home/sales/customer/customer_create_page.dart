import 'package:bitpro_hive/home/sales/customer/sideMenuButton.dart';
import 'package:bitpro_hive/services/firestore_api/fb_sales/fb_customer_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:bitpro_hive/widget/bTextField.dart';
import 'package:bitpro_hive/widget/onpage_button.dart';
import 'package:bitpro_hive/widget/onpage_panel.dart';
import 'package:bitpro_hive/widget/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bitpro_hive/model/customer_data.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/shared/custom_top_nav_bar.dart';
import 'package:bitpro_hive/shared/dialogs/discard_changes_dialog.dart';
import 'package:bitpro_hive/shared/loading.dart';
import '../../../shared/global_variables/static_text_translate.dart';

class CustomerCreateEditPage extends StatefulWidget {
  final UserData userData;
  final bool edit;
  final CustomerData? selectedRowData;
  final List<CustomerData> customerDataLst;
  final bool hideCustomTab;
  final String newCustomerId;
  const CustomerCreateEditPage(
      {super.key,
      required this.userData,
      this.edit = false,
      this.selectedRowData,
      this.hideCustomTab = false,
      required this.customerDataLst,
      required this.newCustomerId});

  @override
  State<CustomerCreateEditPage> createState() => _CustomerCreateEditPageState();
}

class _CustomerCreateEditPageState extends State<CustomerCreateEditPage> {
  String? customerId;
  String? customerName;

  String? address1;
  String? address2;
  String? phone1;
  String? phone2;
  String? email;
  String? openingBalance = '0';
  String? vatNumber;
  String? companyName;
  var formKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.edit && widget.selectedRowData != null) {
      customerId = widget.selectedRowData!.customerId;
      customerName = widget.selectedRowData!.customerName;

      address1 = widget.selectedRowData!.address1;
      address2 = widget.selectedRowData!.address2;
      phone1 = widget.selectedRowData!.phone1;
      phone2 = widget.selectedRowData!.phone2;
      email = widget.selectedRowData!.email;
      vatNumber = widget.selectedRowData!.vatNo;
      companyName = widget.selectedRowData!.companyName;
      openingBalance = widget.selectedRowData!.openingBalance;
    } else {
      customerId = widget.newCustomerId;
    }
  }

  Color cColor = Colors.red;
  IconData cIcon = Icons.warning;

  @override
  Widget build(BuildContext context) {
    if (widget.hideCustomTab) {
      return childBody();
    }

    return customTopNavBar(childBody());
  }

  childBody() {
    return Scaffold(
      backgroundColor: homeBgColor,
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(pageName: 'Customer'),
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
                            buttonFunction: () async {
                              if (formKey.currentState!.validate()) {
                                setState(() {
                                  loading = true;
                                });

                                await FbCustomerDbService(context: context)
                                    .addCustomerData([
                                  CustomerData(
                                      docId: widget.edit &&
                                              widget.selectedRowData != null
                                          ? widget.selectedRowData!.docId
                                          : getRandomString(20),
                                      createdDate: widget.edit &&
                                              widget.selectedRowData != null
                                          ? widget.selectedRowData!.createdDate
                                          : DateTime.now(),
                                      address1: address1 ?? '',
                                      address2: address2 ?? '',
                                      companyName: companyName ?? '',
                                      createdBy: widget.userData.username,
                                      customerId: customerId ?? '',
                                      customerName: customerName ?? '',
                                      email: email ?? '',
                                      phone1: phone1 ?? '',
                                      phone2: phone2 ?? '',
                                      vatNo: vatNumber ?? '',
                                      openingBalance: openingBalance ?? '0')
                                ]);

                                // await CustomerDbService()
                                //     .addCustomerData(
                                //   CustomerData(
                                //       docId: widget.edit && widget.selectedRowData != null
                                //           ? widget
                                //               .selectedRowData!
                                //               .docId
                                //           : getRandomString(
                                //               20),
                                //       createdDate: widget.edit && widget.selectedRowData != null
                                //           ? widget
                                //               .selectedRowData!
                                //               .createdDate
                                //           : DateTime
                                //               .now(),
                                //       address1:
                                //           address1 ??
                                //               '',
                                //       address2:
                                //           address2 ??
                                //               '',
                                //       companyName:
                                //           companyName ??
                                //               '',
                                //       createdBy: widget
                                //           .userData
                                //           .username,
                                //       customerId:
                                //           customerId ??
                                //               '',
                                //       customerName:
                                //           customerName ??
                                //               '',
                                //       email:
                                //           email ?? '',
                                //       phone1: phone1 ??
                                //           '',
                                //       phone2: phone2 ??
                                //           '',
                                //       vatNo:
                                //           vatNumber ??
                                //               '',
                                //       openingBalance:
                                //           openingBalance ??
                                //               '0'),
                                // );
                                Navigator.pop(context, true);
                              }
                            },
                          )
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
                          Expanded(
                            child: loading
                                ? showLoading()
                                : OnPagePanel(
                                    columnForTextField: Column(
                                      children: [
                                        BTextField(
                                          textFieldReadOnly: true,
                                          label: 'Customer Id',
                                          initialValue: customerId,
                                          validator: ((value) {
                                            if (value!.isEmpty) {
                                              return staticTextTranslate(
                                                  'Enter customer id');
                                            } else if ((widget.edit &&
                                                    widget.selectedRowData!
                                                            .customerId !=
                                                        value) ||
                                                !widget.edit) {
                                              if (widget.customerDataLst
                                                  .where((e) =>
                                                      e.customerId == value)
                                                  .isNotEmpty) {
                                                return staticTextTranslate(
                                                    'ID is already in use');
                                              }
                                            }
                                            return null;
                                          }),
                                          onChanged: (val) => setState(() {
                                            customerId = val;
                                          }),
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: BTextField(
                                                fieldWidth: 205,
                                                label: 'Customer Name',
                                                initialValue: customerName,
                                                validator: ((value) {
                                                  if (value!.isEmpty) {
                                                    return staticTextTranslate(
                                                        'Enter customer name');
                                                  }
                                                  return null;
                                                }),
                                                onChanged: (val) =>
                                                    setState(() {
                                                  if (val.isEmpty) {
                                                    cColor = Colors.red;
                                                    cIcon = Icons.warning;
                                                  } else {
                                                    cColor = Colors.green;
                                                    cIcon = Icons.done;
                                                  }
                                                  customerName = val;
                                                }),
                                              ),
                                            ),
                                            Container(
                                              width: 35,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                  color: cColor,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(4),
                                                    bottomRight:
                                                        Radius.circular(4),
                                                  )),
                                              child: Icon(
                                                cIcon,
                                                color: Colors.white,
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        BTextField(
                                          textFieldHeight: 3,
                                          label: 'Address 1',
                                          initialValue: address1,
                                          onChanged: (val) => setState(() {
                                            address1 = val;
                                          }),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        BTextField(
                                          label: 'Address 2',
                                          initialValue: address2,
                                          onChanged: (val) => setState(() {
                                            address2 = val;
                                          }),
                                        ),
                                        const SizedBox(
                                          height: 50,
                                        ),
                                        BTextField(
                                          label: 'Phone 01',
                                          initialValue: phone1,
                                          onChanged: (val) => setState(() {
                                            phone1 = val;
                                          }),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        BTextField(
                                          label: 'Phone 02',
                                          initialValue: phone2,
                                          onChanged: (val) => setState(() {
                                            phone2 = val;
                                          }),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        BTextField(
                                          label: 'Email',
                                          initialValue: email,
                                          onChanged: (val) => setState(() {
                                            email = val;
                                          }),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        BTextField(
                                          label: 'VAT Number',
                                          initialValue: vatNumber,
                                          onChanged: (val) => setState(() {
                                            vatNumber = val;
                                          }),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        BTextField(
                                          label: 'Company Name',
                                          initialValue: companyName,
                                          onChanged: (val) => setState(() {
                                            companyName = val;
                                          }),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        BTextField(
                                          label: 'Opening balance',
                                          initialValue: openingBalance,
                                          onChanged: (val) => setState(() {
                                            openingBalance = val;
                                          }),
                                          validator: (val) {
                                            if (val != null &&
                                                double.tryParse(val) == null) {
                                              return staticTextTranslate(
                                                  'Enter a valid number');
                                            }
                                            return null;
                                          },
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                        ),
                                      ],
                                    ),
                                    rowForButton: Row(
                                      children: [
                                        OnPageButton(
                                          icon: Iconsax.archive,
                                          label: 'Save',
                                          onPressed: () async {
                                            if (formKey.currentState!
                                                .validate()) {
                                              setState(() {
                                                loading = true;
                                              });

                                              await FbCustomerDbService(
                                                      context: context)
                                                  .addCustomerData([
                                                CustomerData(
                                                    docId: widget.edit &&
                                                            widget.selectedRowData !=
                                                                null
                                                        ? widget
                                                            .selectedRowData!
                                                            .docId
                                                        : getRandomString(20),
                                                    createdDate: widget.edit &&
                                                            widget.selectedRowData !=
                                                                null
                                                        ? widget
                                                            .selectedRowData!
                                                            .createdDate
                                                        : DateTime.now(),
                                                    address1: address1 ?? '',
                                                    address2: address2 ?? '',
                                                    companyName:
                                                        companyName ?? '',
                                                    createdBy: widget
                                                        .userData.username,
                                                    customerId:
                                                        customerId ?? '',
                                                    customerName:
                                                        customerName ?? '',
                                                    email: email ?? '',
                                                    phone1: phone1 ?? '',
                                                    phone2: phone2 ?? '',
                                                    vatNo: vatNumber ?? '',
                                                    openingBalance:
                                                        openingBalance ?? '0')
                                              ]);

                                              // await CustomerDbService()
                                              //     .addCustomerData(
                                              //   CustomerData(
                                              //       docId: widget.edit && widget.selectedRowData != null
                                              //           ? widget
                                              //               .selectedRowData!
                                              //               .docId
                                              //           : getRandomString(
                                              //               20),
                                              //       createdDate: widget.edit && widget.selectedRowData != null
                                              //           ? widget
                                              //               .selectedRowData!
                                              //               .createdDate
                                              //           : DateTime
                                              //               .now(),
                                              //       address1:
                                              //           address1 ??
                                              //               '',
                                              //       address2:
                                              //           address2 ??
                                              //               '',
                                              //       companyName:
                                              //           companyName ??
                                              //               '',
                                              //       createdBy: widget
                                              //           .userData
                                              //           .username,
                                              //       customerId:
                                              //           customerId ??
                                              //               '',
                                              //       customerName:
                                              //           customerName ??
                                              //               '',
                                              //       email:
                                              //           email ?? '',
                                              //       phone1: phone1 ??
                                              //           '',
                                              //       phone2: phone2 ??
                                              //           '',
                                              //       vatNo:
                                              //           vatNumber ??
                                              //               '',
                                              //       openingBalance:
                                              //           openingBalance ??
                                              //               '0'),
                                              // );
                                              Navigator.pop(context, true);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    topLabel: 'Customer Details'),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
