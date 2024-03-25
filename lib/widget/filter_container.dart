import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:bitpro_hive/shared/global_variables/static_text_translate.dart';

import 'package:flutter/material.dart';

class FilterContainer extends StatelessWidget {
  final List<Widget> fiterFields;
  final Widget? trailingWidget;
  const FilterContainer(
      {super.key, required this.fiterFields, this.trailingWidget});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4), topRight: Radius.circular(4)),
          gradient: LinearGradient(
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 180, 180, 180),
                Color.fromARGB(255, 105, 105, 105),
              ],
              begin: Alignment.topCenter)),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: ButtonBarSuper(
                buttonTextTheme: ButtonTextTheme.primary,
                wrapType: WrapType.fit,
                wrapFit: WrapFit.min,
                alignment: engSelectedLanguage
                    ? WrapSuperAlignment.left
                    : WrapSuperAlignment.right,
                lineSpacing: 20,
                children: fiterFields,
              ),
            ),
            if (trailingWidget != null) trailingWidget!
          ],
        ),
      ),
    );
  }
}
