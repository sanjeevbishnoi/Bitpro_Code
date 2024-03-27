import 'package:bitpro_hive/services/firestore_api/fb_sales/fb_receipt_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_user_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_sales_db_service/hive_register_db_service.dart';
import 'package:bitpro_hive/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:bitpro_hive/model/receipt/db_receipt_data.dart';
import 'package:bitpro_hive/model/user_data.dart';

class FbRegisterDbService {
  final BuildContext context;
  FbRegisterDbService({
    required this.context,
  });

  openRegister(UserData userData) async {
    //hive
    await HiveRegisterDbService(context: context).openRegister(userData);

    if (globalIsFbSetupSkipted) return;

    //firebase
    userData.openRegister = DateTime.now();
    await FbUserDbService(context: context).addUpdateUser([userData]);
  }

  closeRegister(UserData userData) async {
    //hive
    await HiveRegisterDbService(context: context).closeRegister(userData);

    if (globalIsFbSetupSkipted) return;

    //firebase
    userData.openRegister = null;
    await FbUserDbService(context: context).addUpdateUser([userData]);
  }
}
