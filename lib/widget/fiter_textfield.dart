import 'package:bitpro_hive/shared/global_variables/static_text_translate.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterTextField extends StatelessWidget {
  final Function() onPressed;
  final Widget icon;
  final String hintText ;
  final Function(String val)? onChanged;
  final TextEditingController? controller;
  const FilterTextField({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.onChanged,
    required this.hintText,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      height: 32,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 0.5),
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(5)),
      padding: const EdgeInsets.only(right: 10, bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            padding: const EdgeInsets.only(top: 3),
            onPressed: onPressed,
            splashRadius: 1,
            icon: icon,
          ),
          Flexible(
            child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: staticTextTranslate(hintText),
                  hintStyle: GoogleFonts.roboto(color: Colors.grey[600]),
                  contentPadding: const EdgeInsets.only(bottom: 15, right: 5),
                  border: InputBorder.none,
                  
                  
                ),
                onChanged: onChanged,),
          ),
          
        ],
      ),
    );
  }
}
