import 'package:bitpro_hive/shared/global_variables/font_sizes.dart';
import 'package:bitpro_hive/shared/global_variables/static_text_translate.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class OnPageButton extends StatelessWidget {
  final Function() onPressed;
  final IconData icon;
  final String label;

  const OnPageButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: const LinearGradient(
              end: Alignment.bottomCenter,
              colors: [
                Color(0xff092F53),
                Color(0xff284F70),
              ],
              begin: Alignment.topCenter)),
      height: 42,
      width: 173,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3))),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Icon(
                icon,
                size: 20,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(staticTextTranslate(label),
                  style: TextStyle(
                    fontSize: getMediumFontSize,
                  )),
            ],
          )),
    );
  }
}
