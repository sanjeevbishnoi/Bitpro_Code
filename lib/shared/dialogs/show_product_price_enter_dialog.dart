import 'package:flutter/material.dart';
import 'package:bitpro_hive/shared/global_variables/static_text_translate.dart';

import '../global_variables/font_sizes.dart';

showProductPriceEnterDialog({context, required String productPriceWt}) async {
  String price = productPriceWt;
  final controller = TextEditingController();
  controller.text = price;
  controller.selection = TextSelection(
    baseOffset: 0,
    extentOffset: price.length,
  );
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  return showDialog(
      context: context,
      builder: (context2) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(width: 0.2, color: Colors.grey)),
          title: Text(
            staticTextTranslate('Please enter a price'),
            style: TextStyle(fontSize: getMediumFontSize),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              // initialValue: price,
              style: const TextStyle(),
              onChanged: (val) {
                price = val;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,

              validator: (value) =>
                  value == null || double.tryParse(value) == null
                      ? 'Please enter a valid number'
                      : value.isEmpty
                          ? 'Please enter the price'
                          : null,
              onFieldSubmitted: (val) {
                Navigator.pop(context2, val);
              },
            ),
          ),
          actions: [
            SizedBox(
              height: 42,
              width: 173,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      side: const BorderSide(width: 0.1, color: Colors.grey),
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4))),
                  onPressed: () {
                    Navigator.pop(context2, price);
                  },
                  child: Text(staticTextTranslate('Cancel'),
                      style: TextStyle(
                          fontSize: getMediumFontSize, color: Colors.black))),
            ),
            SizedBox(
              height: 42,
              width: 173,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(width: 0.1, color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context2, price);
                    }
                  },
                  child: Text(
                    staticTextTranslate('Submit'),
                    style: TextStyle(
                      fontSize: getMediumFontSize,
                      color: Colors.white,
                    ),
                  )),
            ),
          ],
        );
      });
}
