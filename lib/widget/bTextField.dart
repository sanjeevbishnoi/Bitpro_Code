import 'package:bitpro_hive/shared/global_variables/font_sizes.dart';
import 'package:bitpro_hive/shared/global_variables/static_text_translate.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BTextField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final Function(String input) onChanged;
  final String? Function(String?)? validator;
  final bool autovalidate;
  final double fieldWidth; 
  final AutovalidateMode autovalidateMode;
  final int textFieldHeight;
  final double boxHeigt;
  final bool textFieldReadOnly;
  final TextEditingController? controller;
  final WidgetBuilder? noItemsBuilder;
  const BTextField(
      {super.key,
      required this.label,
      required this.initialValue,
      required this.onChanged,
      this.validator,
      this.autovalidate = false,
      this.fieldWidth =240,
      this.autovalidateMode = AutovalidateMode.disabled,
      this.textFieldHeight = 1,
      this.boxHeigt = 35,
      this.textFieldReadOnly = false,
      this.controller,
      this.noItemsBuilder,
      });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          staticTextTranslate(label),
          style: GoogleFonts.roboto(
            fontSize: 16,
          ),
        ),
        SizedBox(
          height: boxHeigt,
          width: fieldWidth,
          child: TextFormField(
            
            controller: controller,
            readOnly: textFieldReadOnly,
            initialValue: initialValue,
            maxLines: textFieldHeight,
            style: GoogleFonts.roboto(
              height: 1.5,
              fontSize: getMediumFontSize + 2,
            ),
            decoration: const InputDecoration(
                fillColor: Colors.white,
                filled: true,
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                border: OutlineInputBorder()),
            onChanged: onChanged,
          ),
        )
      ],
    );
  }
}
