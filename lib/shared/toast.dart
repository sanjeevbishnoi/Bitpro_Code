import 'package:flutter/material.dart';
import 'package:flutter_toastr/flutter_toastr.dart';

import 'global_variables/font_sizes.dart';

showToast(
  String text,
  BuildContext context,
) {
  FlutterToastr.show(text, context,
      backgroundRadius: 12,
      textStyle: TextStyle(fontSize: appToastFontSize,color: Colors.white),
      duration: FlutterToastr.lengthLong,
      position: FlutterToastr.bottom);
}
