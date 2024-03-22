
import 'package:flutter/material.dart';
import 'package:bitpro_hive/shared/global_variables/static_text_translate.dart';

import '../global_variables/font_sizes.dart';

showDiscountOverLimitDialog(context, double maxDiscount) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(
              '${staticTextTranslate("Discount over the limit, Max Discount : ")} ${maxDiscount.toStringAsFixed(2)}%',
              style: TextStyle(fontSize: getMediumFontSize),
            ),
            actions: [
              
              TextButton(
                  autofocus: true,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    staticTextTranslate('ok'),
                    style: TextStyle(fontSize: getMediumFontSize),
                  ))
            ],
          ));
}
