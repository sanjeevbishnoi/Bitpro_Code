import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bitpro_hive/shared/global_variables/static_text_translate.dart';
import '../global_variables/font_sizes.dart';

showDiscardChangesDialog(context, {bool receipt = false}) {
  return showDialog(
      context: context,
      builder: (context2) {
        return Dialog(
            backgroundColor: homeBgColor,
            child: SizedBox(
                height: 200,
                width: 370,
                child: Column(children: [
                  Container(
                    // height: 55,
                    width: double.maxFinite,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4)),
                        gradient: LinearGradient(
                            end: Alignment.bottomCenter,
                            colors: [
                              Color.fromARGB(255, 66, 66, 66),
                              Color.fromARGB(255, 0, 0, 0),
                            ],
                            begin: Alignment.topCenter)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Iconsax.danger,
                            size: 20, color: Colors.white),
                        const SizedBox(
                          width: 15,
                        ),
                        Text(
                          staticTextTranslate('Discard Changes'),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: getMediumFontSize + 5),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                      child: SizedBox(
                    height: 5,
                  )),
                  Text(
                      staticTextTranslate(
                          'Are you sure you want to discard all changes?'),
                      style: TextStyle(fontSize: getMediumFontSize)),
                  const Expanded(
                      child: SizedBox(
                    height: 5,
                  )),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                          width: double.maxFinite,
                          decoration: const BoxDecoration(
                              color: Color(0xffdddfe8),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(6),
                                  bottomRight: Radius.circular(6))),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                height: 42,
                                width: 173,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        side: const BorderSide(
                                            width: 0.1, color: Colors.grey),
                                        backgroundColor: Colors.grey[100],
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4))),
                                    onPressed: () {
                                      Navigator.pop(context2);
                                    },
                                    child: Text(staticTextTranslate('Cancel'),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: getMediumFontSize))),
                              ),
                              SizedBox(
                                height: 42,
                                width: 173,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      side: const BorderSide(
                                          width: 0.1, color: Colors.grey),
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context2);
                                      Navigator.pop(context, receipt);
                                    },
                                    child: Text(
                                      staticTextTranslate('Discard'),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: getMediumFontSize),
                                    )),
                              ),
                            ],
                          ))),
                ])));
      });
}
