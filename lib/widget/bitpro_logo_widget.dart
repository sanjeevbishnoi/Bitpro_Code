import 'package:flutter/material.dart';
import '../shared/global_variables/color.dart';
import '../shared/global_variables/font_sizes.dart';

Widget getBitproLogo() {
  return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Container(
        height: 50,
        width: 140,
        decoration: BoxDecoration(
            color: getBitproLogoColor, borderRadius: BorderRadius.circular(5)),
        alignment: Alignment.center,
        child:  Text(
          'BitPro',
          style: TextStyle(
              color: const Color.fromARGB(255, 255, 255, 255),
              fontSize: bitproLogoFontSize,
              fontWeight: FontWeight.w700),
        ),
      ));
}
