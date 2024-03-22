import 'package:bitpro_hive/model/store_data.dart';
import 'package:bitpro_hive/services/firestore_api/fb_settings/fb_store_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_settings/hive_store_db_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:bitpro_hive/shared/global_variables/font_sizes.dart';
import 'package:bitpro_hive/shared/loading.dart';
import 'package:bitpro_hive/shared/global_variables/static_text_translate.dart';
import '../../../shared/custom_top_nav_bar.dart';
import '../../../shared/dialogs/discard_changes_dialog.dart';

class AddEditStore extends StatefulWidget {
  final bool editData;
  final StoreData? storeData;
  final List<StoreData> storeDataLst;
  const AddEditStore(
      {super.key,
      this.editData = false,
      this.storeData,
      required this.storeDataLst});

  @override
  State<AddEditStore> createState() => _AddEditStoreState();
}

class _AddEditStoreState extends State<AddEditStore> {
  String? storeCode;
  String? storeName;
  String? address1;
  String? address2;
  String? phone1;
  String? phone2;
  String? vatNumber;
  String? priceLevel;
  String? email;
  String? ibanAccountNumber;
  String? bankName;
  var formKey = GlobalKey<FormState>();
  bool loading = false;
  File? productImage;
  final GlobalKey _menuKey = GlobalKey();

  // bool productPriceCanChange = false;
  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    if (widget.editData && widget.storeData != null) {
      storeCode = widget.storeData!.storeCode;
      storeName = widget.storeData!.storeName;
      address1 = widget.storeData!.address1;
      address2 = widget.storeData!.address2;
      phone1 = widget.storeData!.phone1;
      phone2 = widget.storeData!.phone2;
      vatNumber = widget.storeData!.vatNumber;
      priceLevel = widget.storeData!.priceLevel;
    } else {
      storeCode = ((int.tryParse(widget.storeDataLst.last.storeCode) ?? 0) + 1)
          .toString();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return customTopNavBar(Scaffold(
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
                    height: 15,
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
                      height: 10,
                    ),
                    SizedBox(
                      height: 35,
                      width: 370,
                      child: Row(children: [
                        const SizedBox(width: 10),
                        const Icon(Iconsax.d_square, size: 19),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          staticTextTranslate('Store'),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        )
                      ]),
                    ),
                    const SizedBox(
                      height: 0,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 675,
                            height: MediaQuery.of(context).size.height - 100,
                            child: Card(
                                shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                        width: 0.5, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5)),
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
                                                  padding: const EdgeInsets.all(
                                                      22.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          staticTextTranslate(
                                                              'General Details'),
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
                                                            width: 100,
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
                                                                          .grey[
                                                                      400],
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
                                                                        'Store Code'),
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
                                                                      storeCode,
                                                                  autovalidateMode:
                                                                      AutovalidateMode
                                                                          .onUserInteraction,
                                                                  enabled:
                                                                      false,
                                                                  validator:
                                                                      ((value) {
                                                                    if (value!
                                                                        .isEmpty) {
                                                                      return staticTextTranslate(
                                                                          'Enter store code');
                                                                    } else if (widget.editData ==
                                                                            false &&
                                                                        widget.storeDataLst.any((element) =>
                                                                            element.storeCode ==
                                                                            value)) {
                                                                      return staticTextTranslate(
                                                                          'Store code is already in use');
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
                                                                              5),
                                                                      border:
                                                                          OutlineInputBorder()),
                                                                  onChanged: (val) =>
                                                                      setState(
                                                                          () {
                                                                    storeCode =
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
                                                                Text(
                                                                    staticTextTranslate(
                                                                        'Store Name'),
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
                                                                      storeName,
                                                                  autovalidateMode:
                                                                      AutovalidateMode
                                                                          .onUserInteraction,
                                                                  validator:
                                                                      (value) {
                                                                    if (value!
                                                                        .isEmpty) {
                                                                      return staticTextTranslate(
                                                                          'Enter store name');
                                                                    }
                                                                    return null;
                                                                  },
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
                                                                              5),
                                                                      border:
                                                                          OutlineInputBorder()),
                                                                  onChanged: (val) =>
                                                                      setState(
                                                                          () {
                                                                    storeName =
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
                                                                        'Address 1'),
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
                                                                              5),
                                                                      border:
                                                                          OutlineInputBorder()),
                                                                  onChanged: (val) =>
                                                                      setState(
                                                                          () {
                                                                    address1 =
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
                                                                Text(
                                                                    staticTextTranslate(
                                                                        'Address 2'),
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
                                                                      address2,
                                                                  autovalidateMode:
                                                                      AutovalidateMode
                                                                          .onUserInteraction,
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
                                                                              5),
                                                                      border:
                                                                          OutlineInputBorder()),
                                                                  onChanged: (val) =>
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
                                                                Text(
                                                                    staticTextTranslate(
                                                                        'Phone 1'),
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
                                                                      phone1,
                                                                  autovalidateMode:
                                                                      AutovalidateMode
                                                                          .onUserInteraction,
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
                                                                              5),
                                                                      border:
                                                                          OutlineInputBorder()),
                                                                  onChanged: (val) =>
                                                                      setState(
                                                                          () {
                                                                    phone1 =
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
                                                                Text(
                                                                    staticTextTranslate(
                                                                        'Phone 2 '),
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          getMediumFontSize -
                                                                              1,
                                                                    )),
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                                SizedBox(
                                                                  child:
                                                                      TextFormField(
                                                                    initialValue:
                                                                        phone2,
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
                                                                                5),
                                                                        border:
                                                                            OutlineInputBorder()),
                                                                    onChanged: (val) =>
                                                                        setState(
                                                                            () {
                                                                      phone2 =
                                                                          val;
                                                                    }),
                                                                  ),
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
                                                                        'VAT number'),
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          getMediumFontSize -
                                                                              1,
                                                                    )),
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                                SizedBox(
                                                                  child:
                                                                      TextFormField(
                                                                    initialValue:
                                                                        vatNumber,
                                                                    autovalidateMode:
                                                                        AutovalidateMode
                                                                            .onUserInteraction,
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
                                                                                5),
                                                                        border:
                                                                            OutlineInputBorder()),
                                                                    onChanged: (val) =>
                                                                        setState(
                                                                            () {
                                                                      vatNumber =
                                                                          val;
                                                                    }),
                                                                  ),
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
                                                                            'Price Level '),
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              getMediumFontSize - 1,
                                                                        )),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                                SizedBox(
                                                                  child:
                                                                      TextFormField(
                                                                    initialValue:
                                                                        priceLevel,
                                                                    autovalidateMode:
                                                                        AutovalidateMode
                                                                            .onUserInteraction,
                                                                    maxLines: 1,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                    onChanged:
                                                                        (val) {
                                                                      setState(
                                                                          () {
                                                                        priceLevel =
                                                                            val;
                                                                      });
                                                                    },
                                                                    decoration: const InputDecoration(
                                                                        isDense:
                                                                            true,
                                                                        contentPadding: EdgeInsets.symmetric(
                                                                            vertical:
                                                                                10,
                                                                            horizontal:
                                                                                5),
                                                                        border:
                                                                            OutlineInputBorder()),
                                                                  ),
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
                                                                        'Account Number'),
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          getMediumFontSize -
                                                                              1,
                                                                    )),
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                                SizedBox(
                                                                  child:
                                                                      TextFormField(
                                                                    initialValue:
                                                                        ibanAccountNumber,
                                                                    autovalidateMode:
                                                                        AutovalidateMode
                                                                            .onUserInteraction,
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
                                                                                5),
                                                                        border:
                                                                            OutlineInputBorder()),
                                                                    onChanged: (val) =>
                                                                        setState(
                                                                            () {
                                                                      ibanAccountNumber =
                                                                          val;
                                                                    }),
                                                                  ),
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
                                                                            'Bank Name '),
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              getMediumFontSize - 1,
                                                                        )),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                                SizedBox(
                                                                  child:
                                                                      TextFormField(
                                                                    initialValue:
                                                                        bankName,
                                                                    autovalidateMode:
                                                                        AutovalidateMode
                                                                            .onUserInteraction,
                                                                    maxLines: 1,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                    onChanged:
                                                                        (val) {
                                                                      setState(
                                                                          () {
                                                                        bankName =
                                                                            val;
                                                                      });
                                                                    },
                                                                    decoration: const InputDecoration(
                                                                        isDense:
                                                                            true,
                                                                        contentPadding: EdgeInsets.symmetric(
                                                                            vertical:
                                                                                10,
                                                                            horizontal:
                                                                                5),
                                                                        border:
                                                                            OutlineInputBorder()),
                                                                  ),
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
                                                                        'Email'),
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          getMediumFontSize -
                                                                              1,
                                                                    )),
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                                SizedBox(
                                                                  child:
                                                                      TextFormField(
                                                                    initialValue:
                                                                        email,
                                                                    autovalidateMode:
                                                                        AutovalidateMode
                                                                            .onUserInteraction,
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
                                                                                5),
                                                                        border:
                                                                            OutlineInputBorder()),
                                                                    onChanged: (val) =>
                                                                        setState(
                                                                            () {
                                                                      email =
                                                                          val;
                                                                    }),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 20,
                                                            width: 30,
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                        width: 30,
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
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
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
                                                              height: 18,
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
                                                            String productImgPath = productImage !=
                                                                    null
                                                                ? await FbStoreDbService(context: context).uploadImage(
                                                                    file:
                                                                        productImage!,
                                                                    fileName: widget.storeData !=
                                                                            null
                                                                        ? widget
                                                                            .storeData!
                                                                            .docId
                                                                        : getRandomString(
                                                                            20))
                                                                : widget.storeData !=
                                                                        null
                                                                    ? widget
                                                                        .storeData!
                                                                        .logoPath
                                                                    : '';

                                                            await FbStoreDbService(
                                                                    context:
                                                                        context)
                                                                .fetchAllStoresData();

                                                            await FbStoreDbService(
                                                                    context:
                                                                        context)
                                                                .addStoreData([
                                                              StoreData(
                                                                  bankName:
                                                                      bankName ??
                                                                          '',
                                                                  email: email ??
                                                                      '',
                                                                  ibanAccountNumber:
                                                                      ibanAccountNumber ??
                                                                          '',
                                                                  workstationInfo: [],
                                                                  docId: widget.editData && widget.storeData != null
                                                                      ? widget
                                                                          .storeData!
                                                                          .docId
                                                                      : getRandomString(
                                                                          20),
                                                                  storeCode:
                                                                      storeCode!,
                                                                  storeName:
                                                                      storeName!,
                                                                  address1:
                                                                      address1 ??
                                                                          '',
                                                                  address2:
                                                                      address2 ??
                                                                          '',
                                                                  phone1:
                                                                      phone1 ??
                                                                          '',
                                                                  phone2:
                                                                      phone2 ??
                                                                          '',
                                                                  vatNumber:
                                                                      vatNumber ??
                                                                          '',
                                                                  priceLevel:
                                                                      priceLevel ??
                                                                          '',
                                                                  logoPath:
                                                                      productImgPath)
                                                            ]);
                                                            Navigator.pop(
                                                                context, true);
                                                          }
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
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      getMediumFontSize,
                                                                )),
                                                          ],
                                                        )),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      )),
                          ),
                          SizedBox(
                            width: 280,
                            height: 280,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      width: 0.5, color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4)),
                              elevation: 0,
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, bottom: 22.0, left: 22, right: 10),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              staticTextTranslate(
                                                  'Product Image'),
                                              style: TextStyle(
                                                fontSize: getMediumFontSize,
                                              )),
                                          PopupMenuButton(
                                              splashRadius: 1,
                                              key: _menuKey,
                                              itemBuilder: (_) =>
                                                  <PopupMenuItem<String>>[
                                                    if (productImage != null)
                                                      PopupMenuItem<String>(
                                                          value: 'change',
                                                          child: Text(
                                                              staticTextTranslate(
                                                                  'Change Image'),
                                                              style: TextStyle(
                                                                fontSize:
                                                                    getMediumFontSize,
                                                              ))),
                                                    if (productImage == null)
                                                      PopupMenuItem<String>(
                                                          value: 'upload',
                                                          child: Text(
                                                              staticTextTranslate(
                                                                  'Upload Image'),
                                                              style: TextStyle(
                                                                fontSize:
                                                                    getMediumFontSize,
                                                              ))),
                                                    if (productImage != null)
                                                      PopupMenuItem<String>(
                                                          value: 'cancel',
                                                          child: Text(
                                                              staticTextTranslate(
                                                                  'Cancel Image'),
                                                              style: TextStyle(
                                                                fontSize:
                                                                    getMediumFontSize,
                                                              ))),
                                                  ],
                                              icon: Image.asset(
                                                'assets/icons/menu-dots-vertical.png',
                                                height: 20,
                                              ),
                                              onSelected: (val) async {
                                                if (val == 'cancel') {
                                                  productImage = null;
                                                  setState(() {});
                                                } else if (val == 'upload' ||
                                                    val == 'change') {
                                                  FilePickerResult? result =
                                                      await FilePicker.platform
                                                          .pickFiles(
                                                              allowMultiple:
                                                                  false,
                                                              dialogTitle:
                                                                  staticTextTranslate(
                                                                      'Product Image'),
                                                              type: FileType
                                                                  .image);

                                                  if (result != null) {
                                                    productImage = File(result
                                                        .files.first.path!);
                                                    setState(() {});
                                                  }
                                                }
                                              }),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            height: 5,
                                            width: 93,
                                            decoration: BoxDecoration(
                                                color: darkBlueColor,
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                          ),
                                          Flexible(
                                            child: Container(
                                              height: 1,
                                              width: double.maxFinite,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 0,
                                      ),
                                      if ((widget.editData &&
                                              widget.storeData != null &&
                                              widget.storeData!.logoPath
                                                  .isNotEmpty) &&
                                          productImage == null)
                                        if (File(widget.storeData!.logoPath)
                                            .existsSync())
                                          Image.file(
                                            File(widget.storeData!.logoPath),
                                            width: 270,
                                            height: 195,
                                            fit: BoxFit.contain,
                                          ),
                                      if (productImage != null)
                                        Image.file(
                                          productImage!,
                                          width: 270,
                                          height: 195,
                                          fit: BoxFit.contain,
                                        ),
                                      if (!widget.editData &&
                                          productImage == null)
                                        SizedBox(
                                          width: 270,
                                          height: 195,
                                          child: Icon(Icons.image,
                                              size: 100,
                                              color: Colors.grey.shade200),
                                        )
                                    ]),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
