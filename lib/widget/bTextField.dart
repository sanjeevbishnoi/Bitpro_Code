import 'package:bitpro_hive/shared/global_variables/font_sizes.dart';
import 'package:bitpro_hive/shared/global_variables/static_text_translate.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BTextField extends StatelessWidget {
  final String label;
  
  final double bradius;
  final String? initialValue;
  final Function(String input) onChanged;
  final String? Function(String?)? validator;
  final bool autovalidate;
  final double fieldWidth;
  final AutovalidateMode autovalidateMode;
  final int textFieldHeight;
  // final double boxHeigt;
  final bool textFieldReadOnly;
  final TextEditingController? controller;
  final WidgetBuilder? noItemsBuilder;
  // final bool enabled;
  final bool autoFoucs;

  final bool obscureText;
  const BTextField({
    super.key,
    required this.label,
    this.initialValue,
    required this.onChanged,
    this.validator,
    this.autovalidate = false,
    this.autoFoucs = false,
    // this.enabled = true,
    this.fieldWidth = 240,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.textFieldHeight = 1,
    // this.boxHeigt = 35,
    this.textFieldReadOnly = false,
    this.obscureText = false,
    this.controller,
    this.noItemsBuilder,
    this.bradius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            staticTextTranslate(label),
            style: GoogleFonts.roboto(
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(
          // height: boxHeigt,
          width: fieldWidth,
          child: TextFormField(
            autofocus: autoFoucs,
            obscureText: obscureText,
            // enabled: enabled,
            controller: controller,
            readOnly: textFieldReadOnly,
            autovalidateMode: autovalidateMode,
            initialValue: initialValue,
            maxLines: textFieldHeight,
            style: GoogleFonts.roboto(
              height: 1.41,
              fontSize: getMediumFontSize + 2,
            ),
            validator: validator,
            decoration:  InputDecoration(
                fillColor: Colors.white,
                filled: true,
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 5, ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 0.3),
                  
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(bradius),
                        topRight: Radius.circular(bradius),
                        bottomLeft: Radius.circular(4),
                        topLeft: Radius.circular(4)
                        ),
                        ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 0.3),
                  
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(bradius),
                        topRight: Radius.circular(bradius),
                        bottomLeft: Radius.circular(4),
                        topLeft: Radius.circular(4)
                        ),
                        ),
                        ),
            onChanged: onChanged,
          ),
        )
      ],
    );
  }
}
