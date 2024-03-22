import 'package:barcode_image/barcode_image.dart';
import 'package:bitpro_hive/shared/custom_top_nav_bar.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:bitpro_hive/shared/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';
import '../../shared/global_variables/font_sizes.dart';
import '../../shared/global_variables/static_text_translate.dart';

import '../../shared/templates/tag/print_tag.dart';

class InventoryTagSize extends StatefulWidget {
  @override
  State<InventoryTagSize> createState() => _InventoryTagSizeState();
}

class _InventoryTagSizeState extends State<InventoryTagSize> {
  late double headerFontSize;
  late double productIdFontSize;
  late double productNameFontSize;
  late double priceFontSize;
  late double barcodeHeight;
  late double barcodeWidth;
  late double sizedboxHeight;

  late double pageWidth;
  late double pageHeight;
  late double marginTop;
  late double marginBottom;
  late double marginLeft;
  late double marginRight;

  late bool enablePrice;
  late bool enableProdId;
  late String customHeader;
  late double spaceAfterProdId;
  late double spaceAfterProdName;
  late String priceAnnotation;
  late double sizeAfterPrice;

  @override
  void initState() {
    super.initState();

    initSize();
  }

  initSize() {
    var box = Hive.box('bitpro_app');

    Map? data = box.get('inventory_tag_size');
    //for restting the data if new field not available
    if (data != null && data['enablePrice'] == null) {
      box.delete('inventory_tag_size');
      data = null;
    }
    if (data != null) {
      headerFontSize = data['headerFontSize'];
      productIdFontSize = data['productIdFontSize'];
      productNameFontSize = data['productNameFontSize'];
      priceFontSize = data['priceFontSize'];
      barcodeWidth = data['barcodeWidth'];
      barcodeHeight = data['barcodeHeight'];

      sizedboxHeight = data['sizedboxHeight'];
      pageWidth = data['pageWidth'];
      pageHeight = data['pageHeight'];
      marginTop = data['marginTop'];
      marginBottom = data['marginBottom'];
      marginLeft = data['marginLeft'];
      marginRight = data['marginRight'];

      enablePrice = data['enablePrice'];
      enableProdId = data['enableProdId'];
      customHeader = data['customHeader'];
      spaceAfterProdId = data['spaceAfterProdId'];
      spaceAfterProdName = data['spaceAfterProdName'];
      priceAnnotation = data['priceAnnotation'];
      sizeAfterPrice = data['sizeAfterPrice'];
    } else {
      setDefaultSize();
    }
  }

  setDefaultSize() {
    headerFontSize = 10;
    productIdFontSize = 8;
    productNameFontSize = 8;
    priceFontSize = 8;
    barcodeHeight = 30;
    barcodeWidth = 50;
    sizedboxHeight = 0;
    // sizedboxWidth = 300;
    pageWidth = 2;
    pageHeight = 1;
    marginTop = 4;
    marginBottom = 4;
    marginLeft = 4;
    marginRight = 4;
    //
    enablePrice = true;
    enableProdId = true;
    customHeader = 'Store Name';
    spaceAfterProdId = 16;
    spaceAfterProdName = 7;
    priceAnnotation = 'SR';
    sizeAfterPrice = 21;
  }

  @override
  Widget build(BuildContext context) {
    return customTopNavBar(
      Scaffold(
        backgroundColor: homeBgColor,
        body: SafeArea(
          child: Container(
            color: homeBgColor,
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Scrollbar(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 0,
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 0,
                        ),
                        SizedBox(
                          height: 30,
                          width: 500,
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
                                        color: const Color.fromARGB(
                                            255, 0, 0, 0))),
                              ],
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              padding:
                                  const EdgeInsets.only(left: 10, bottom: 10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      width: 0.5, color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4)),
                              child: Column(children: [
                                SizedBox(
                                  width: 500,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Column(
                                              children: [
                                                Text(
                                                  staticTextTranslate(
                                                      'Tag Width (In)'),
                                                  style: TextStyle(
                                                    fontSize:
                                                        getMediumFontSize - 1,
                                                    color: Colors.grey[800],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                SizedBox(
                                                  width: 120,
                                                  child: TextFormField(
                                                      initialValue: pageWidth
                                                          .toString(),
                                                      autovalidateMode:
                                                          AutovalidateMode
                                                              .onUserInteraction,
                                                      validator: (val) {
                                                        if (val!.isEmpty ||
                                                            double.tryParse(
                                                                    val) ==
                                                                null ||
                                                            double.tryParse(
                                                                    val) ==
                                                                0 ||
                                                            double.tryParse(
                                                                    val)!
                                                                .isNegative) {
                                                          return staticTextTranslate(
                                                              'Enter a valid number');
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
                                                                          8,
                                                                      horizontal:
                                                                          15),
                                                          border:
                                                              OutlineInputBorder()),
                                                      onChanged: (val) {
                                                        if (val.isNotEmpty &&
                                                            double.tryParse(
                                                                    val) !=
                                                                null &&
                                                            double.tryParse(
                                                                    val) !=
                                                                0 &&
                                                            !double.tryParse(
                                                                    val)!
                                                                .isNegative) {
                                                          setState(() {
                                                            pageWidth =
                                                                double.parse(
                                                                    val);
                                                          });
                                                        }
                                                      }),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  staticTextTranslate(
                                                      'Tag Height (In)'),
                                                  style: TextStyle(
                                                    fontSize:
                                                        getMediumFontSize - 1,
                                                    color: Colors.grey[800],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                SizedBox(
                                                  width: 120,
                                                  child: TextFormField(
                                                      initialValue: pageHeight
                                                          .toString(),
                                                      autovalidateMode:
                                                          AutovalidateMode
                                                              .onUserInteraction,
                                                      validator: (val) {
                                                        if (val!.isEmpty ||
                                                            double.tryParse(
                                                                    val) ==
                                                                null ||
                                                            double.tryParse(
                                                                    val) ==
                                                                0 ||
                                                            double.tryParse(
                                                                    val)!
                                                                .isNegative) {
                                                          return staticTextTranslate(
                                                              'Enter a valid number');
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
                                                                          8,
                                                                      horizontal:
                                                                          15),
                                                          border:
                                                              OutlineInputBorder()),
                                                      onChanged: (val) {
                                                        if (val.isNotEmpty &&
                                                            double.tryParse(
                                                                    val) !=
                                                                null &&
                                                            double.tryParse(
                                                                    val) !=
                                                                0 &&
                                                            !double.tryParse(
                                                                    val)!
                                                                .isNegative) {
                                                          setState(() {
                                                            pageHeight =
                                                                double.parse(
                                                                    val);
                                                          });
                                                        }
                                                      }),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Checkbox(
                                                    value: enablePrice,
                                                    onChanged:
                                                        (bool? newValue) {
                                                      setState(() {
                                                        enablePrice =
                                                            newValue ?? true;
                                                      });
                                                    }),
                                                const Text('Enable Price'),
                                              ],
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Column(
                                              children: [
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  staticTextTranslate(
                                                      'Header font size'),
                                                  style: TextStyle(
                                                    fontSize:
                                                        getMediumFontSize - 1,
                                                    color: Colors.grey[800],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                SizedBox(
                                                  width: 120,
                                                  height: 30,
                                                  child: TextFormField(
                                                      initialValue:
                                                          headerFontSize
                                                              .toString(),
                                                      autovalidateMode:
                                                          AutovalidateMode
                                                              .onUserInteraction,
                                                      validator: (val) {
                                                        if (val!.isEmpty ||
                                                            double.tryParse(
                                                                    val) ==
                                                                null ||
                                                            double.tryParse(
                                                                    val) ==
                                                                0 ||
                                                            double.tryParse(
                                                                    val)!
                                                                .isNegative) {
                                                          return staticTextTranslate(
                                                              'Enter a valid number');
                                                        }
                                                        return null;
                                                      },
                                                      style: const TextStyle(
                                                          fontSize: 14),
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
                                                                null &&
                                                            double.tryParse(
                                                                    val) !=
                                                                0 &&
                                                            !double.tryParse(
                                                                    val)!
                                                                .isNegative) {
                                                          setState(() {
                                                            headerFontSize =
                                                                double.parse(
                                                                    val);
                                                          });
                                                        }
                                                      }),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  'Custom Header',
                                                  style: TextStyle(
                                                    fontSize:
                                                        getMediumFontSize - 1,
                                                    color: Colors.grey[800],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                SizedBox(
                                                    width: 240,
                                                    height: 30,
                                                    child: TextFormField(
                                                      initialValue:
                                                          customHeader,
                                                      onChanged: (val) {
                                                        setState(() {
                                                          customHeader = val;
                                                        });
                                                      },
                                                      validator: (val) => val ==
                                                                  null ||
                                                              val.isEmpty
                                                          ? 'Please enter a value'
                                                          : null,
                                                      style: const TextStyle(
                                                          fontSize: 14),
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
                                                    )),
                                              ],
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  staticTextTranslate(
                                                      'Prod. id font size'),
                                                  style: TextStyle(
                                                    fontSize:
                                                        getMediumFontSize - 1,
                                                    color: Colors.grey[800],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                SizedBox(
                                                  width: 120,
                                                  child: TextFormField(
                                                      initialValue:
                                                          productIdFontSize
                                                              .toString(),
                                                      autovalidateMode:
                                                          AutovalidateMode
                                                              .onUserInteraction,
                                                      validator: (val) {
                                                        if (val!.isEmpty ||
                                                            double.tryParse(
                                                                    val) ==
                                                                null ||
                                                            double.tryParse(
                                                                    val) ==
                                                                0 ||
                                                            double.tryParse(
                                                                    val)!
                                                                .isNegative) {
                                                          return staticTextTranslate(
                                                              'Enter a valid number');
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
                                                                          8,
                                                                      horizontal:
                                                                          15),
                                                          border:
                                                              OutlineInputBorder()),
                                                      onChanged: (val) {
                                                        if (val.isNotEmpty &&
                                                            double.tryParse(
                                                                    val) !=
                                                                null &&
                                                            double.tryParse(
                                                                    val) !=
                                                                0 &&
                                                            !double.tryParse(
                                                                    val)!
                                                                .isNegative) {
                                                          setState(() {
                                                            productIdFontSize =
                                                                double.parse(
                                                                    val);
                                                          });
                                                        }
                                                      }),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  'Space from top',
                                                  style: TextStyle(
                                                    fontSize:
                                                        getMediumFontSize - 1,
                                                    color: Colors.grey[800],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                SizedBox(
                                                    width: 120,
                                                    height: 30,
                                                    child: TextFormField(
                                                      initialValue:
                                                          spaceAfterProdId
                                                              .toString(),
                                                      onChanged: (val) {
                                                        if (double.tryParse(
                                                                val) !=
                                                            null) {
                                                          setState(() {
                                                            spaceAfterProdId =
                                                                double.parse(
                                                                    val);
                                                          });
                                                        }
                                                      },
                                                      validator: (val) {
                                                        if (val!.isEmpty ||
                                                            double.tryParse(
                                                                    val) ==
                                                                null ||
                                                            double.tryParse(
                                                                    val) ==
                                                                0 ||
                                                            double.tryParse(
                                                                    val)!
                                                                .isNegative) {
                                                          return staticTextTranslate(
                                                              'Enter a valid number');
                                                        }
                                                        return null;
                                                      },
                                                      style: const TextStyle(
                                                          fontSize: 14),
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
                                                    )),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Checkbox(
                                                    value: enableProdId,
                                                    onChanged:
                                                        (bool? newValue) {
                                                      setState(() {
                                                        enableProdId =
                                                            newValue ?? true;
                                                      });
                                                    }),
                                                const Text('Enabled'),
                                              ],
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  staticTextTranslate(
                                                      'Prod. name f size'),
                                                  style: TextStyle(
                                                    fontSize:
                                                        getMediumFontSize - 1,
                                                    color: Colors.grey[800],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                SizedBox(
                                                  width: 120,
                                                  child: TextFormField(
                                                      initialValue:
                                                          productNameFontSize
                                                              .toString(),
                                                      autovalidateMode:
                                                          AutovalidateMode
                                                              .onUserInteraction,
                                                      validator: (val) {
                                                        if (val!.isEmpty ||
                                                            double.tryParse(
                                                                    val) ==
                                                                null ||
                                                            double.tryParse(
                                                                    val) ==
                                                                0 ||
                                                            double.tryParse(
                                                                    val)!
                                                                .isNegative) {
                                                          return staticTextTranslate(
                                                              'Enter a valid number');
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
                                                                          8,
                                                                      horizontal:
                                                                          15),
                                                          border:
                                                              OutlineInputBorder()),
                                                      onChanged: (val) {
                                                        if (val.isNotEmpty &&
                                                            double.tryParse(
                                                                    val) !=
                                                                null &&
                                                            double.tryParse(
                                                                    val) !=
                                                                0 &&
                                                            !double.tryParse(
                                                                    val)!
                                                                .isNegative) {
                                                          setState(() {
                                                            productNameFontSize =
                                                                double.parse(
                                                                    val);
                                                          });
                                                        }
                                                      }),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  'Space from top',
                                                  style: TextStyle(
                                                    fontSize:
                                                        getMediumFontSize - 1,
                                                    color: Colors.grey[800],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                SizedBox(
                                                    width: 120,
                                                    height: 30,
                                                    child: TextFormField(
                                                      initialValue:
                                                          spaceAfterProdName
                                                              .toString(),
                                                      onChanged: (val) {
                                                        if (double.tryParse(
                                                                val) !=
                                                            null) {
                                                          setState(() {
                                                            spaceAfterProdName =
                                                                double.parse(
                                                                    val);
                                                          });
                                                        }
                                                      },
                                                      validator: (val) {
                                                        if (val!.isEmpty ||
                                                            double.tryParse(
                                                                    val) ==
                                                                null ||
                                                            double.tryParse(
                                                                    val) ==
                                                                0 ||
                                                            double.tryParse(
                                                                    val)!
                                                                .isNegative) {
                                                          return staticTextTranslate(
                                                              'Enter a valid number');
                                                        }
                                                        return null;
                                                      },
                                                      style: const TextStyle(
                                                          fontSize: 14),
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
                                                    )),
                                              ],
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  staticTextTranslate(
                                                      'Price f size'),
                                                  style: TextStyle(
                                                    fontSize:
                                                        getMediumFontSize - 1,
                                                    color: Colors.grey[800],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                SizedBox(
                                                  width: 120,
                                                  child: TextFormField(
                                                      initialValue:
                                                          priceFontSize
                                                              .toString(),
                                                      autovalidateMode:
                                                          AutovalidateMode
                                                              .onUserInteraction,
                                                      validator: (val) {
                                                        if (val!.isEmpty ||
                                                            double.tryParse(
                                                                    val) ==
                                                                null ||
                                                            double.tryParse(
                                                                    val) ==
                                                                0 ||
                                                            double.tryParse(
                                                                    val)!
                                                                .isNegative) {
                                                          return staticTextTranslate(
                                                              'Enter a valid number');
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
                                                                          8,
                                                                      horizontal:
                                                                          15),
                                                          border:
                                                              OutlineInputBorder()),
                                                      onChanged: (val) {
                                                        if (val.isNotEmpty &&
                                                            double.tryParse(
                                                                    val) !=
                                                                null &&
                                                            double.tryParse(
                                                                    val) !=
                                                                0 &&
                                                            !double.tryParse(
                                                                    val)!
                                                                .isNegative) {
                                                          setState(() {
                                                            priceFontSize =
                                                                double.parse(
                                                                    val);
                                                          });
                                                        }
                                                      }),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Column(
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      'Price Annotation',
                                                      style: TextStyle(
                                                        fontSize:
                                                            getMediumFontSize -
                                                                1,
                                                        color: Colors.grey[800],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    SizedBox(
                                                        width: 120,
                                                        height: 30,
                                                        child: TextFormField(
                                                          initialValue:
                                                              priceAnnotation,
                                                          onChanged: (val) {
                                                            setState(() {
                                                              priceAnnotation =
                                                                  val;
                                                            });
                                                          },
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14),
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
                                                        )),
                                                  ],
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      'Space from top',
                                                      style: TextStyle(
                                                        fontSize:
                                                            getMediumFontSize -
                                                                1,
                                                        color: Colors.grey[800],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    SizedBox(
                                                        width: 120,
                                                        height: 30,
                                                        child: TextFormField(
                                                          initialValue:
                                                              sizeAfterPrice
                                                                  .toString(),
                                                          onChanged: (val) {
                                                            if (double.tryParse(
                                                                    val) !=
                                                                null) {
                                                              sizeAfterPrice =
                                                                  double.parse(
                                                                      val);
                                                              setState(() {});
                                                            }
                                                          },
                                                          validator: (val) {
                                                            if (val!.isEmpty ||
                                                                double.tryParse(
                                                                        val) ==
                                                                    null ||
                                                                double.tryParse(
                                                                        val) ==
                                                                    0 ||
                                                                double.tryParse(
                                                                        val)!
                                                                    .isNegative) {
                                                              return staticTextTranslate(
                                                                  'Enter a valid number');
                                                            }
                                                            return null;
                                                          },
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14),
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
                                                        )),
                                                  ],
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          staticTextTranslate(
                                              'Barcode Width - Height'),
                                          style: TextStyle(
                                            fontSize: getMediumFontSize - 1,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 120,
                                              child: TextFormField(
                                                  initialValue:
                                                      barcodeWidth.toString(),
                                                  autovalidateMode:
                                                      AutovalidateMode
                                                          .onUserInteraction,
                                                  validator: (val) {
                                                    if (val!.isEmpty ||
                                                        double.tryParse(val) ==
                                                            null ||
                                                        double.tryParse(val) ==
                                                            0 ||
                                                        double.tryParse(val)!
                                                            .isNegative) {
                                                      return staticTextTranslate(
                                                          'Enter a valid number');
                                                    }
                                                    return null;
                                                  },
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                  decoration: const InputDecoration(
                                                      isDense: true,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 8,
                                                              horizontal: 15),
                                                      border:
                                                          OutlineInputBorder()),
                                                  onChanged: (val) {
                                                    if (val.isNotEmpty &&
                                                        double.tryParse(val) !=
                                                            null &&
                                                        double.tryParse(val) !=
                                                            0 &&
                                                        !double.tryParse(val)!
                                                            .isNegative) {
                                                      setState(() {
                                                        barcodeWidth =
                                                            double.parse(val);
                                                      });
                                                    }
                                                  }),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            SizedBox(
                                              width: 120,
                                              child: TextFormField(
                                                  initialValue:
                                                      barcodeHeight.toString(),
                                                  autovalidateMode:
                                                      AutovalidateMode
                                                          .onUserInteraction,
                                                  validator: (val) {
                                                    if (val!.isEmpty ||
                                                        double.tryParse(val) ==
                                                            null ||
                                                        double.tryParse(val) ==
                                                            0 ||
                                                        double.tryParse(val)!
                                                            .isNegative) {
                                                      return staticTextTranslate(
                                                          'Enter a valid number');
                                                    }
                                                    return null;
                                                  },
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                  decoration: const InputDecoration(
                                                      isDense: true,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 8,
                                                              horizontal: 15),
                                                      border:
                                                          OutlineInputBorder()),
                                                  onChanged: (val) {
                                                    if (val.isNotEmpty &&
                                                        double.tryParse(val) !=
                                                            null &&
                                                        double.tryParse(val) !=
                                                            0 &&
                                                        !double.tryParse(val)!
                                                            .isNegative) {
                                                      setState(() {
                                                        barcodeHeight =
                                                            double.parse(val);
                                                      });
                                                    }
                                                  }),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        // Text(
                                        //   staticTextTranslate(
                                        //       'Sizedbox Height'),
                                        //   style: TextStyle(
                                        //     fontSize: getMediumFontSize - 1,
                                        //     color: Colors.grey[800],
                                        //   ),
                                        // ),
                                        // const SizedBox(
                                        //   height: 5,
                                        // ),
                                        // const SizedBox(
                                        //   width: 5,
                                        // ),
                                        // SizedBox(
                                        //   width: 120,
                                        //   child: TextFormField(
                                        //       initialValue:
                                        //           sizedboxHeight.toString(),
                                        //       autovalidateMode: AutovalidateMode
                                        //           .onUserInteraction,
                                        //       validator: (val) {
                                        //         if (val!.isEmpty ||
                                        //             double.tryParse(val) ==
                                        //                 null ||
                                        //             double.tryParse(val)!
                                        //                 .isNegative) {
                                        //           return staticTextTranslate(
                                        //               'Enter a valid number');
                                        //         }
                                        //         return null;
                                        //       },
                                        //       style:
                                        //           const TextStyle(fontSize: 16),
                                        //       decoration: const InputDecoration(
                                        //           isDense: true,
                                        //           contentPadding:
                                        //               EdgeInsets.symmetric(
                                        //                   vertical: 8,
                                        //                   horizontal: 15),
                                        //           border: OutlineInputBorder()),
                                        //       onChanged: (val) {
                                        //         if (val.isNotEmpty &&
                                        //             double.tryParse(val) !=
                                        //                 null &&
                                        //             double.tryParse(val) != 0 &&
                                        //             !double.tryParse(val)!
                                        //                 .isNegative) {
                                        //           setState(() {
                                        //             sizedboxHeight =
                                        //                 double.parse(val);
                                        //           });
                                        //         }
                                        //       }),
                                        // ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          staticTextTranslate(
                                              'Margin Top - Bottom'),
                                          style: TextStyle(
                                            fontSize: getMediumFontSize - 1,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 120,
                                              child: TextFormField(
                                                  initialValue:
                                                      marginTop.toString(),
                                                  autovalidateMode:
                                                      AutovalidateMode
                                                          .onUserInteraction,
                                                  validator: (val) {
                                                    if (val!.isEmpty ||
                                                        double.tryParse(val) ==
                                                            null ||
                                                        double.tryParse(val) ==
                                                            0 ||
                                                        double.tryParse(val)!
                                                            .isNegative) {
                                                      return staticTextTranslate(
                                                          'Enter a valid number');
                                                    }
                                                    return null;
                                                  },
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                  decoration: const InputDecoration(
                                                      isDense: true,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 8,
                                                              horizontal: 15),
                                                      border:
                                                          OutlineInputBorder()),
                                                  onChanged: (val) {
                                                    if (val.isNotEmpty &&
                                                        double.tryParse(val) !=
                                                            null &&
                                                        double.tryParse(val) !=
                                                            0 &&
                                                        !double.tryParse(val)!
                                                            .isNegative) {
                                                      setState(() {
                                                        marginTop =
                                                            double.parse(val);
                                                      });
                                                    }
                                                  }),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            SizedBox(
                                              width: 120,
                                              child: TextFormField(
                                                  initialValue:
                                                      marginBottom.toString(),
                                                  autovalidateMode:
                                                      AutovalidateMode
                                                          .onUserInteraction,
                                                  validator: (val) {
                                                    if (val!.isEmpty ||
                                                        double.tryParse(val) ==
                                                            null ||
                                                        double.tryParse(val) ==
                                                            0 ||
                                                        double.tryParse(val)!
                                                            .isNegative) {
                                                      return staticTextTranslate(
                                                          'Enter a valid number');
                                                    }
                                                    return null;
                                                  },
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                  decoration: const InputDecoration(
                                                      isDense: true,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 8,
                                                              horizontal: 15),
                                                      border:
                                                          OutlineInputBorder()),
                                                  onChanged: (val) {
                                                    if (val.isNotEmpty &&
                                                        double.tryParse(val) !=
                                                            null &&
                                                        double.tryParse(val) !=
                                                            0 &&
                                                        !double.tryParse(val)!
                                                            .isNegative) {
                                                      setState(() {
                                                        marginBottom =
                                                            double.parse(val);
                                                      });
                                                    }
                                                  }),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          staticTextTranslate(
                                              'Margin Left - Right'),
                                          style: TextStyle(
                                            fontSize: getMediumFontSize - 1,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 120,
                                              child: TextFormField(
                                                  initialValue:
                                                      marginLeft.toString(),
                                                  autovalidateMode:
                                                      AutovalidateMode
                                                          .onUserInteraction,
                                                  validator: (val) {
                                                    if (val!.isEmpty ||
                                                        double.tryParse(val) ==
                                                            null ||
                                                        double.tryParse(val) ==
                                                            0 ||
                                                        double.tryParse(val)!
                                                            .isNegative) {
                                                      return staticTextTranslate(
                                                          'Enter a valid number');
                                                    }
                                                    return null;
                                                  },
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                  decoration: const InputDecoration(
                                                      isDense: true,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 8,
                                                              horizontal: 15),
                                                      border:
                                                          OutlineInputBorder()),
                                                  onChanged: (val) {
                                                    if (val.isNotEmpty &&
                                                        double.tryParse(val) !=
                                                            null &&
                                                        double.tryParse(val) !=
                                                            0 &&
                                                        !double.tryParse(val)!
                                                            .isNegative) {
                                                      setState(() {
                                                        marginLeft =
                                                            double.parse(val);
                                                      });
                                                    }
                                                  }),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            SizedBox(
                                              width: 120,
                                              child: TextFormField(
                                                  initialValue:
                                                      marginRight.toString(),
                                                  autovalidateMode:
                                                      AutovalidateMode
                                                          .onUserInteraction,
                                                  validator: (val) {
                                                    if (val!.isEmpty ||
                                                        double.tryParse(val) ==
                                                            null ||
                                                        double.tryParse(val) ==
                                                            0 ||
                                                        double.tryParse(val)!
                                                            .isNegative) {
                                                      return staticTextTranslate(
                                                          'Enter a valid number');
                                                    }
                                                    return null;
                                                  },
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                  decoration: const InputDecoration(
                                                      isDense: true,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 8,
                                                              horizontal: 15),
                                                      border:
                                                          OutlineInputBorder()),
                                                  onChanged: (val) {
                                                    if (val.isNotEmpty &&
                                                        double.tryParse(val) !=
                                                            null &&
                                                        double.tryParse(val) !=
                                                            0 &&
                                                        !double.tryParse(val)!
                                                            .isNegative) {
                                                      setState(() {
                                                        marginRight =
                                                            double.parse(val);
                                                      });
                                                    }
                                                  }),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 50,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        ),
                      ]),
                  const SizedBox(
                    width: 15,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 0,
                        width: 30,
                      ),
                      Text(
                        staticTextTranslate('Preview'),
                        style: TextStyle(
                          fontSize: getMediumFontSize + 4,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 0.5),
                            borderRadius: BorderRadius.circular(4)),
                        width: MediaQuery.of(context).size.width > 1250
                            ? MediaQuery.of(context).size.width - 1000
                            : 700,
                        height: MediaQuery.of(context).size.width > 1250
                            ? MediaQuery.of(context).size.width - 1000
                            : 700,
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 80,
                              width: 150,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey, width: 0.5),
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.white),
                              padding: EdgeInsets.fromLTRB(marginLeft,
                                  marginTop, marginRight, marginBottom),
                              child: Stack(children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      customHeader,
                                      style:
                                          TextStyle(fontSize: headerFontSize),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  top: spaceAfterProdName,
                                  child: Text(
                                    'Product Name',
                                    style: TextStyle(
                                        fontSize: productNameFontSize),
                                  ),
                                ),
                                if (enableProdId)
                                  Positioned(
                                    top: spaceAfterProdId,
                                    child: Text(
                                      'Product Id',
                                      style: TextStyle(
                                          fontSize: productIdFontSize),
                                    ),
                                  ),
                                if (enablePrice)
                                  Positioned(
                                      top: sizeAfterPrice,
                                      child: Text(
                                        '$priceAnnotation : 10.00',
                                        style:
                                            TextStyle(fontSize: priceFontSize),
                                      )),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.string(buildBarcode(
                                          Barcode.code128(
                                              useCode128B: false,
                                              useCode128C: false),
                                          '10666046',
                                          filename: 'code-128a',
                                          height: barcodeHeight,
                                          width: barcodeWidth)),
                                    ],
                                  ),
                                )
                              ]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                              height: 42,
                              width: 174,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: darkBlueColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4))),
                                onPressed: () async {
                                  var box = Hive.box('bitpro_app');

                                  await box.put('test_inventory_tag_size', {
                                    'headerFontSize': headerFontSize,
                                    'productIdFontSize': productIdFontSize,
                                    'productNameFontSize': productNameFontSize,
                                    'priceFontSize': priceFontSize,
                                    'barcodeWidth': barcodeWidth,
                                    'barcodeHeight': barcodeHeight,
                                    'sizedboxHeight': sizedboxHeight,
                                    'pageWidth': pageWidth,
                                    'pageHeight': pageHeight,
                                    'marginTop': marginTop,
                                    'marginBottom': marginBottom,
                                    'marginLeft': marginLeft,
                                    'marginRight': marginRight,
                                    //
                                    'enablePrice': enablePrice,
                                    'enableProdId': enableProdId,
                                    'customHeader': customHeader,
                                    'spaceAfterProdId': spaceAfterProdId,
                                    'spaceAfterProdName': spaceAfterProdName,
                                    'priceAnnotation': priceAnnotation,
                                    'sizeAfterPrice': sizeAfterPrice
                                  });
                                  // ignore: use_build_context_synchronously
                                  printTag(
                                      null,
                                      1,
                                      'normal_copy',
                                      [
                                        PrintTagData(
                                            barcodeValue: '10001',
                                            itemCode: '210002255',
                                            productName: 'Product Name',
                                            priceWt: '10.00',
                                            docQty: 0,
                                            onHandQty: 0)
                                      ],
                                      context);
                                },
                                child: Text(
                                  staticTextTranslate('Print Test'),
                                  style: TextStyle(
                                    fontSize: getMediumFontSize,
                                  ),
                                ),
                              )),
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
                                            BorderRadius.circular(4))),
                                onPressed: () async {
                                  var box = Hive.box('bitpro_app');

                                  await box.put('inventory_tag_size', {
                                    'headerFontSize': headerFontSize,
                                    'productIdFontSize': productIdFontSize,
                                    'productNameFontSize': productNameFontSize,
                                    'priceFontSize': priceFontSize,
                                    'barcodeWidth': barcodeWidth,
                                    'barcodeHeight': barcodeHeight,
                                    'sizedboxHeight': sizedboxHeight,
                                    'pageWidth': pageWidth,
                                    'pageHeight': pageHeight,
                                    'marginTop': marginTop,
                                    'marginBottom': marginBottom,
                                    'marginLeft': marginLeft,
                                    'marginRight': marginRight,
                                    //
                                    'enablePrice': enablePrice,
                                    'enableProdId': enableProdId,
                                    'customHeader': customHeader,
                                    'spaceAfterProdId': spaceAfterProdId,
                                    'spaceAfterProdName': spaceAfterProdName,
                                    'priceAnnotation': priceAnnotation,
                                    'sizeAfterPrice': sizeAfterPrice
                                  });
                                  showToast('Saved', context);
                                },
                                child: Text(
                                  staticTextTranslate('Save'),
                                  style: TextStyle(
                                    fontSize: getMediumFontSize,
                                  ),
                                ),
                              ))
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
