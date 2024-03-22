import 'package:bitpro_hive/services/firestore_api/fb_merchandise/fb_vendor_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:flutter/material.dart';
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

  var formKey = GlobalKey<FormState>();
  bool loading = false;

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
                          showDiscardChangesDialog(context);
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
                            Iconsax.building,
                            size: 17,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            staticTextTranslate('Vendor'),
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
                              child: loading
                                  ? showLoading()
                                  : Column(
                                      children: [
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: Form(
                                              key: formKey,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(22.0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        staticTextTranslate(
                                                            'Vendor Details'),
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
                                                          width: 93,
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  darkBlueColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8)),
                                                        ),
                                                        Flexible(
                                                          child: Container(
                                                            height: 1,
                                                            width: double
                                                                .maxFinite,
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .grey[300],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
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
                                                          width: 280,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  staticTextTranslate(
                                                                      'Vendor Name'),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        getMediumFontSize -
                                                                            1,
                                                                  )),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              TextFormField(
                                                                initialValue:
                                                                    vendorName,
                                                                validator:
                                                                    ((value) {
                                                                  if (value!
                                                                      .isEmpty) {
                                                                    return staticTextTranslate(
                                                                        'Enter vendor name');
                                                                  }
                                                                  return null;
                                                                }),
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
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
                                                                        setState(
                                                                            () {
                                                                  vendorName =
                                                                      val;
                                                                }),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                          width: 30,
                                                        ),
                                                        SizedBox(
                                                          width: 280,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                      staticTextTranslate(
                                                                          'Email Address'),
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            getMediumFontSize -
                                                                                1,
                                                                      )),
                                                                  Text(
                                                                    ' ${staticTextTranslate("(optional)")}',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            getSmallFontSize,
                                                                        color: Colors
                                                                            .grey),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              TextFormField(
                                                                initialValue:
                                                                    emailAddress,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
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
                                                                        setState(
                                                                            () {
                                                                  emailAddress =
                                                                      val;
                                                                }),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    ButtonBar(
                                                      alignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          width: 280,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  staticTextTranslate(
                                                                      'Vendor Id'),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        getMediumFontSize -
                                                                            1,
                                                                  )),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              TextFormField(
                                                                initialValue:
                                                                    vendorId,
                                                                autovalidateMode:
                                                                    AutovalidateMode
                                                                        .onUserInteraction,
                                                                enabled: false,
                                                                validator:
                                                                    ((value) {
                                                                  if (value!
                                                                      .isEmpty) {
                                                                    return staticTextTranslate(
                                                                        'Enter vendor id');
                                                                  } else if ((widget
                                                                              .edit &&
                                                                          widget.selectedRowData!.vendorId !=
                                                                              value) ||
                                                                      !widget
                                                                          .edit) {
                                                                    if (widget
                                                                        .vendorDataLst
                                                                        .where((e) =>
                                                                            e.vendorId ==
                                                                            value)
                                                                        .isNotEmpty) {
                                                                      return staticTextTranslate(
                                                                          'ID is already in use');
                                                                    }
                                                                  }
                                                                  return null;
                                                                }),
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
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
                                                                        setState(
                                                                            () {
                                                                  vendorId =
                                                                      val;
                                                                }),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                          width: 30,
                                                        ),
                                                        SizedBox(
                                                          width: 280,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                      staticTextTranslate(
                                                                          'Address 01'),
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            getMediumFontSize -
                                                                                1,
                                                                      )),
                                                                  Text(
                                                                    ' ${staticTextTranslate("(optional)")}',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            getSmallFontSize,
                                                                        color: Colors
                                                                            .grey),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              TextFormField(
                                                                initialValue:
                                                                    address1,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
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
                                                                        setState(
                                                                            () {
                                                                  address1 =
                                                                      val;
                                                                }),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    ButtonBar(
                                                      alignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          width: 280,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                      staticTextTranslate(
                                                                          'Phone 01'),
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            getMediumFontSize -
                                                                                1,
                                                                      )),
                                                                  Text(
                                                                    ' ${staticTextTranslate("(optional)")}',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            getSmallFontSize,
                                                                        color: Colors
                                                                            .grey),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              TextFormField(
                                                                initialValue:
                                                                    phone1,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
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
                                                                        setState(
                                                                            () {
                                                                  phone1 = val;
                                                                }),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                          width: 30,
                                                        ),
                                                        SizedBox(
                                                          width: 280,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                      staticTextTranslate(
                                                                          'Address 02'),
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            getMediumFontSize -
                                                                                1,
                                                                      )),
                                                                  Text(
                                                                    ' ${staticTextTranslate("(optional)")}',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            getSmallFontSize,
                                                                        color: Colors
                                                                            .grey),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              TextFormField(
                                                                initialValue:
                                                                    address2,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
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
                                                                        setState(
                                                                            () {
                                                                  address2 =
                                                                      val;
                                                                }),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    ButtonBar(
                                                      alignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          width: 280,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                      staticTextTranslate(
                                                                          'Phone 02'),
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            getMediumFontSize -
                                                                                1,
                                                                      )),
                                                                  Text(
                                                                    ' ${staticTextTranslate("(optional)")}',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            getSmallFontSize,
                                                                        color: Colors
                                                                            .grey),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              TextFormField(
                                                                initialValue:
                                                                    phone2,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
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
                                                                        setState(
                                                                            () {
                                                                  phone2 = val;
                                                                }),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                          width: 30,
                                                        ),
                                                        SizedBox(
                                                          width: 280,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                      staticTextTranslate(
                                                                          'VAT Number'),
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            getMediumFontSize -
                                                                                1,
                                                                      )),
                                                                  Text(
                                                                    ' ${staticTextTranslate("(optional)")}',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            getSmallFontSize,
                                                                        color: Colors
                                                                            .grey),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                              TextFormField(
                                                                initialValue:
                                                                    vatNumber,
                                                                maxLines: 1,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
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
                                                                        setState(
                                                                            () {
                                                                  vatNumber =
                                                                      val;
                                                                }),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: SizedBox(
                                                        width: 280,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                staticTextTranslate(
                                                                    'Opening Balance'),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      getMediumFontSize -
                                                                          1,
                                                                )),
                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                            TextFormField(
                                                              initialValue:
                                                                  openingBalance,
                                                              validator: (val) {
                                                                if (val !=
                                                                        null &&
                                                                    double.tryParse(
                                                                            val) ==
                                                                        null) {
                                                                  return staticTextTranslate(
                                                                      'Enter a valid number');
                                                                }
                                                                return null;
                                                              },
                                                              autovalidateMode:
                                                                  AutovalidateMode
                                                                      .onUserInteraction,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      getMediumFontSize +
                                                                          2,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                              decoration: const InputDecoration(
                                                                  isDense: true,
                                                                  contentPadding:
                                                                      EdgeInsets.symmetric(
                                                                          vertical:
                                                                              10,
                                                                          horizontal:
                                                                              15),
                                                                  border:
                                                                      OutlineInputBorder()),
                                                              onChanged:
                                                                  (val) =>
                                                                      setState(
                                                                          () {
                                                                openingBalance =
                                                                    val;
                                                              }),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            height: 62,
                                            width: double.maxFinite,
                                            color: const Color(0xffdddfe8),
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
                                                          backgroundColor:
                                                              Colors.white,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4))),
                                                      onPressed: () {
                                                        showDiscardChangesDialog(
                                                            context);
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Image.asset(
                                                            'assets/icons/cross-circle.png',
                                                            height: 20,
                                                          ),
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
                                                                  BorderRadius
                                                                      .circular(
                                                                          4))),
                                                      onPressed: () async {
                                                        if (formKey
                                                            .currentState!
                                                            .validate()) {
                                                          setState(() {
                                                            loading = true;
                                                          });

                                                          await FbVendorDbService(
                                                                  context:
                                                                      context)
                                                              .addUpdateVendorData([
                                                            VendorData(
                                                                docId: widget.edit && widget.selectedRowData != null
                                                                    ? widget
                                                                        .selectedRowData!
                                                                        .docId
                                                                    : getRandomString(
                                                                        20),
                                                                vendorName:
                                                                    vendorName!,
                                                                vendorId:
                                                                    vendorId!,
                                                                emailAddress:
                                                                    emailAddress ??
                                                                        '',
                                                                address1:
                                                                    address1 ??
                                                                        '',
                                                                phone1: phone1 ??
                                                                    '',
                                                                address2:
                                                                    address2 ??
                                                                        '',
                                                                phone2: phone2 ??
                                                                    '',
                                                                vatNumber: vatNumber ??
                                                                    '',
                                                                createdDate: widget.edit && widget.selectedRowData != null
                                                                    ? widget
                                                                        .selectedRowData!
                                                                        .createdDate
                                                                    : DateTime
                                                                        .now(),
                                                                createdBy: widget.edit &&
                                                                        widget.selectedRowData !=
                                                                            null
                                                                    ? widget
                                                                        .selectedRowData!
                                                                        .createdBy
                                                                    : widget
                                                                        .userData
                                                                        .username,
                                                                openingBalance:
                                                                    openingBalance ?? '0')
                                                          ]);

                                                          Navigator.pop(
                                                              context, true);
                                                        }
                                                        setState(() {
                                                          loading = false;
                                                        });
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Icon(
                                                            Iconsax.archive,
                                                            size: 20,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                              staticTextTranslate(
                                                                  'Save'),
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
