import 'package:bitpro_hive/home/sales/customer/sideMenuButton.dart';
import 'package:bitpro_hive/services/firestore_api/fb_merchandise/fb_vendor_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:bitpro_hive/widget/bTextField.dart';
import 'package:bitpro_hive/widget/onpage_button.dart';
import 'package:bitpro_hive/widget/onpage_panel.dart';
import 'package:bitpro_hive/widget/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/model/vendor_data.dart';
import 'package:bitpro_hive/shared/dialogs/discard_changes_dialog.dart';
import 'package:bitpro_hive/shared/loading.dart';
import '../../../shared/custom_top_nav_bar.dart';
import '../../../shared/global_variables/font_sizes.dart';
import '../../../shared/global_variables/static_text_translate.dart';

class VendorCreateEditPage extends StatefulWidget {
  final UserData userData;
  final bool edit;
  final VendorData? selectedRowData;
  final List<VendorData> vendorDataLst;
  final String newVendorId;
  const VendorCreateEditPage(
      {Key? key,
      required this.userData,
      this.edit = false,
      this.selectedRowData,
      required this.vendorDataLst,
      required this.newVendorId})
      : super(key: key);

  @override
  State<VendorCreateEditPage> createState() => _VendorCreateEditPageState();
}

class _VendorCreateEditPageState extends State<VendorCreateEditPage> {
  String? vendorName;
  String? emailAddress;
  String? vendorId;
  String? address1;
  String? phone1;
  String? address2;
  String? phone2;
  String? vatNumber;
  String? openingBalance = '0';

  bool loading = false;

  Color cColor = Colors.red;
  IconData cIcon = Icons.warning;

  @override
  void initState() {
    super.initState();
    if (widget.edit && widget.selectedRowData != null) {
      vendorName = widget.selectedRowData!.vendorName;
      emailAddress = widget.selectedRowData!.emailAddress;
      vendorId = widget.selectedRowData!.vendorId;
      address1 = widget.selectedRowData!.address1;
      phone1 = widget.selectedRowData!.phone1;
      address2 = widget.selectedRowData!.address2;
      phone2 = widget.selectedRowData!.phone2;
      vatNumber = widget.selectedRowData!.vatNumber;
      openingBalance = widget.selectedRowData!.openingBalance;
      cColor = Colors.green;
      cIcon = Icons.done;
    } else {
      vendorId = widget.newVendorId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return customTopNavBar(
      Scaffold(
        backgroundColor: homeBgColor,
        body: SafeArea(
          child: Column(
            children: [
              const TopBar(pageName: 'Vendor'),
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
                            : Row(
                              children: [
                                OnPagePanel(
                                  widht: 450,
                                    columnForTextField: Column(
                                      children: [
                                        BTextField(
                                          textFieldReadOnly: true,
                                          label: 'Vendor Id',
                                          initialValue: vendorId,
                                          validator: ((value) {
                                            if (value!.isEmpty) {
                                              return staticTextTranslate(
                                                  'Enter vendor id');
                                            } else if ((widget.edit &&
                                                    widget.selectedRowData!
                                                            .vendorId !=
                                                        value) ||
                                                !widget.edit) {
                                              if (widget.vendorDataLst
                                                  .where((e) => e.vendorId == value)
                                                  .isNotEmpty) {
                                                return staticTextTranslate(
                                                    'ID is already in use');
                                              }
                                            }
                                            return null;
                                          }),
                                          onChanged: (val) => setState(() {
                                            vendorId = val;
                                          }),
                                          autovalidateMode:
                                              AutovalidateMode.onUserInteraction,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: BTextField(
                                                bradius: 0,

                                                fieldWidth: 205,
                                                label: 'Vendor Name',
                                                initialValue: vendorName,
                                                onChanged: (val) => setState(() {
                                                  if (val.isEmpty) {
                                                    cColor = Colors.red;
                                                    cIcon = Icons.warning;
                                                  } else {
                                                    cColor = Colors.green;
                                                    cIcon = Icons.done;
                                                  }
                                                  vendorName = val;
                                                }),
                                                autovalidateMode: AutovalidateMode
                                                    .onUserInteraction,
                                              ),
                                            ),
                                            Container(
                                              width: 35,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                  color: cColor,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topRight: Radius.circular(4),
                                                    bottomRight: Radius.circular(4),
                                                  )),
                                              child: Icon(
                                                cIcon,
                                                color: Colors.white,
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        BTextField(
                                          label: 'Email Address',
                                          initialValue: emailAddress,
                                          onChanged: (val) => setState(() {
                                            emailAddress = val;
                                          }),
                                          autovalidateMode:
                                              AutovalidateMode.onUserInteraction,
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        BTextField(
                                          label: 'Address 01',
                                          initialValue: address1,
                                          onChanged: (val) => setState(() {
                                            address1 = val;
                                          }),
                                          autovalidateMode:
                                              AutovalidateMode.onUserInteraction,
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        BTextField(
                                          label: 'Address 02',
                                          initialValue: address2,
                                          onChanged: (val) => setState(() {
                                            address2 = val;
                                          }),
                                          autovalidateMode:
                                              AutovalidateMode.onUserInteraction,
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        BTextField(
                                          label: 'Phone 01',
                                          initialValue: phone1,
                                          onChanged: (val) => setState(() {
                                            phone1 = val;
                                          }),
                                          autovalidateMode:
                                              AutovalidateMode.onUserInteraction,
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
                                          autovalidateMode:
                                              AutovalidateMode.onUserInteraction,
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
                                          autovalidateMode:
                                              AutovalidateMode.onUserInteraction,
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        BTextField(
                                          label: 'Opening Balance',
                                          initialValue: openingBalance,
                                          validator: (val) {
                                            if (val != null &&
                                                double.tryParse(val) == null) {
                                              return staticTextTranslate(
                                                  'Enter a valid number');
                                            }
                                            return null;
                                          },
                                          onChanged: (val) => setState(() {
                                            openingBalance = val;
                                          }),
                                          autovalidateMode:
                                              AutovalidateMode.onUserInteraction,
                                        ),
                                      ],
                                    ),
                                    rowForButton: Row(
                                      children: [
                                        OnPageButton(
                                          icon: Iconsax.archive,
                                          label: 'Save',
                                          onPressed: () => onTapSaveButton(),
                                        ),
                                      ],
                                    ),
                                    topLabel: 'Vendor Details'),
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
      ),
    );
  }

  onTapSaveButton() async {
    if (vendorName != null && vendorName!.isNotEmpty) {
      setState(() {
        loading = true;
      });

      await FbVendorDbService(context: context).addUpdateVendorData([
        VendorData(
            docId: widget.edit && widget.selectedRowData != null
                ? widget.selectedRowData!.docId
                : getRandomString(20),
            vendorName: vendorName!,
            vendorId: vendorId!,
            emailAddress: emailAddress ?? '',
            address1: address1 ?? '',
            phone1: phone1 ?? '',
            address2: address2 ?? '',
            phone2: phone2 ?? '',
            vatNumber: vatNumber ?? '',
            createdDate: widget.edit && widget.selectedRowData != null
                ? widget.selectedRowData!.createdDate
                : DateTime.now(),
            createdBy: widget.edit && widget.selectedRowData != null
                ? widget.selectedRowData!.createdBy
                : widget.userData.username,
            openingBalance: openingBalance ?? '0')
      ]);

      Navigator.pop(context, true);
    }
  }
}
