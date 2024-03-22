import 'package:bitpro_hive/shared/global_variables/font_sizes.dart';
import 'package:bitpro_hive/shared/global_variables/static_text_translate.dart';
import 'package:flutter/material.dart';

class SideMenuButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final Function() buttonFunction;
  const SideMenuButton(
      {super.key,
      required this.label,
      required this.iconPath,
      required this.buttonFunction});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 170,
      child: TextButton(
        style: TextButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              iconPath,
              width: 20,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(staticTextTranslate(label),
                style: TextStyle(
                    fontSize: getMediumFontSize,
                    color: Color.fromARGB(255, 255, 255, 255))),
          ],
        ),
        onPressed: buttonFunction,
      ),
    );
  }
}
