import 'package:bitpro_hive/services/firestore_api/fb_sales/fb_receipt_db_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:bitpro_hive/model/receipt/db_receipt_data.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/services/firestore_api/fb_sales/fb_register_db_serivce.dart';

class HiveRegisterDbService {
  final BuildContext context;
  HiveRegisterDbService({
    required this.context,
  });

  openRegister(UserData userData) async {
    var box = Hive.box('bitpro_app');
    Map users = box.get('Users') ?? {};

    users[userData.docId] = {
      'firstName': userData.firstName,
      'lastName': userData.lastName,
      'userRole': userData.userRole,
      'username': userData.username,
      'password': userData.password,
      'employeeId': userData.employeeId,
      'maxDiscount': userData.maxDiscount,
      'createdBy': userData.createdBy,
      'createdDate': userData.createdDate.toString(),
      'docId': userData.docId,
      'openRegister': DateTime.now().toString(),
    };
    await box.put('Users', users);

    await box.put('user_data', {
      'firstName': userData.firstName,
      'lastName': userData.lastName,
      'userRole': userData.userRole,
      'username': userData.username,
      'password': userData.password,
      'employeeId': userData.employeeId,
      'maxDiscount': userData.maxDiscount,
      'createdBy': userData.createdBy,
      'createdDate': userData.createdDate.toString(),
      'docId': userData.docId,
      'openRegister': DateTime.now().toString(),
    });
  }

  closeRegister(UserData userData) async {
    var box = Hive.box('bitpro_app');
    Map users = box.get('Users') ?? {};

    users[userData.docId] = {
      'firstName': userData.firstName,
      'lastName': userData.lastName,
      'userRole': userData.userRole,
      'username': userData.username,
      'password': userData.password,
      'employeeId': userData.employeeId,
      'maxDiscount': userData.maxDiscount,
      'createdBy': userData.createdBy,
      'createdDate': userData.createdDate.toString(),
      'docId': userData.docId,
      'openRegister': null,
    };
    await box.put('Users', users);

    await box.put('user_data', {
      'firstName': userData.firstName,
      'lastName': userData.lastName,
      'userRole': userData.userRole,
      'username': userData.username,
      'password': userData.password,
      'employeeId': userData.employeeId,
      'maxDiscount': userData.maxDiscount,
      'createdBy': userData.createdBy,
      'createdDate': userData.createdDate.toString(),
      'docId': userData.docId,
      'openRegister': null,
    });
  }

  Future<List<DbReceiptData>> closeRegisterData(
      String username, DateTime openRegisterDate) async {
    List<DbReceiptData> receiptLst =
        await FbReceiptDbService(context: context).fetchAllReceiptData();

    List<DbReceiptData> dbReceiptData =
        receiptLst.where((element) => element.createdBy == username).toList();

    return dbReceiptData
        .where(
            (element) => openRegisterDate.compareTo(element.createdDate) == -1)
        .toList();
  }
}
