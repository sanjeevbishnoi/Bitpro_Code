import 'package:bitpro_hive/shared/custom_top_nav_bar.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:bitpro_hive/shared/global_variables/static_text_translate.dart';
import 'package:flutter/material.dart';

import 'global_variables/font_sizes.dart';

showLoading({bool withScaffold = false}) {
  Widget loadingbody = Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CupertinoActivityIndicator(radius: 15),
        const SizedBox(
          height: 20,
        ),
        Text(
          staticTextTranslate('Loading ...'),
          style: TextStyle(fontSize: appLodingTextSize),
        )
      ],
    ),
  );

  return withScaffold
      ? customTopNavBar(
          Scaffold(backgroundColor: homeBgColor, body: loadingbody))
      : loadingbody;
}
