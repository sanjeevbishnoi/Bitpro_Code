// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:math';

import 'package:bitpro_hive/firebase_backend_setup/workstation_setup.dart';
import 'package:bitpro_hive/model/customer_data.dart';
import 'package:bitpro_hive/model/customer_payment_data.dart';
import 'package:bitpro_hive/model/department_data.dart';
import 'package:bitpro_hive/model/former_z_out_data.dart';
import 'package:bitpro_hive/model/inventory_data.dart';
import 'package:bitpro_hive/model/promo_code_data.dart';
import 'package:bitpro_hive/model/receipt/db_receipt_data.dart';
import 'package:bitpro_hive/model/store_data.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/model/user_group_data.dart';
import 'package:bitpro_hive/model/vendor_data.dart';
import 'package:bitpro_hive/model/vendor_payment_data.dart';
import 'package:bitpro_hive/model/voucher/db_voucher_data.dart';
import 'package:bitpro_hive/services/firestore_api/fb_merchandise/fb_department_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_merchandise/fb_inventory_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_merchandise/fb_vendor_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_merchandise/fb_vendor_payment_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_sales/fb_customer_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_sales/fb_customer_payment_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_sales/fb_former_z_out_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_sales/fb_promo_code_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_sales/fb_receipt_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_settings/fb_settings_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_settings/fb_store_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_user_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_vouchers/fb_voucher_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_merchandise_db_service/department_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_merchandise_db_service/inventory_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_merchandise_db_service/vendor_payment_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_merchandise_db_service/vendors_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_sales_db_service/hive_customer_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_sales_db_service/hive_customer_payment_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_sales_db_service/hive_former_z_out_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_sales_db_service/hive_promo_code_db_serice.dart';
import 'package:bitpro_hive/services/hive/hive_sales_db_service/hive_receipt_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_settings/hive_settings_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_settings/hive_store_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_user_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_user_group_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_voucher_db_service/hive_voucher_db_service.dart';
import 'package:bitpro_hive/services/providers/fetching_data_provider.dart';
import 'package:bitpro_hive/shared/toast.dart';
import 'package:bitpro_hive/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:bitpro_hive/services/firestore_api/fb_user_group_db_service.dart';
import 'package:provider/provider.dart';

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

class FirebaseService {
  var box = Hive.box('bitpro_app');

  final BuildContext context;
  FirebaseService({
    required this.context,
  });

  Future<String?> checkApiKeyAuthIsCorrect(
      {required String apiKey,
      required String projectId,
      required String databaseName,
      bool ismergeDatabase = false,
      bool ischangeDatabase = false}) async {
    print(ismergeDatabase);
    var url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey',
    );

    var response =
        await http.post(url, body: jsonEncode({"returnSecureToken": true}));

    var body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      //getting idToken and refersh token
      String idToken = body['idToken'];
      String refreshToken = body['refreshToken'];

      //checking projectId and databasename is correct
      String kBaseUrl =
          'https://firestore.googleapis.com/v1/projects/$projectId/databases/$databaseName/documents';

      var url = Uri.parse(
        '$kBaseUrl/Stores Data?key=$apiKey',
      );
      var response =
          await http.get(url, headers: {'Authorization': 'Bearer $idToken'});

      // bitpro-multi-store
      var body2 = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // success
        var box = Hive.box('bitpro_app');
        if (ismergeDatabase == false) {
          await box.put('firebase_backend_data', {
            'setupSkipped': false,
            'workstationSetupDone': false,
            'projectId': projectId,
            'apiKey': apiKey,
            'databaseName': databaseName,
            'idToken': body['idToken'],
            'refreshToken': body['refreshToken']
          });
          if (ischangeDatabase) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => Wrapper(),
                ),
                (route) => false);
          }
        } else {
          //merging database
          //updating default store id in hive
          var userSettingData = await box.get('user_settings_data');

          await box.put('user_settings_data', {
            'companyName': userSettingData['companyName'],
            'selectedStoreCode': userSettingData['selectedStoreCode'],
            'workstationNumber': userSettingData['workstationNumber'],
          });

          await box.put('showFirstFbDataMergingDialog', true);
          await box.put('firebase_backend_data', {
            'setupSkipped': false,
            'workstationSetupDone': true,
            'projectId': projectId,
            'apiKey': apiKey,
            'databaseName': databaseName,
            'idToken': body['idToken'],
            'refreshToken': body['refreshToken']
          });

          //merge hive data with firebase
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => Wrapper(),
          ));
        }
      } else {
        //failure
        String errorMsg = 'Unknown error happend, try again later.';
        try {
          errorMsg = 'Error : ' + body2['error']['message'];
        } catch (e) {}

        return errorMsg;
      }
    } else {
      String errorMsg = 'Unknown error happend, try again later.';
      try {
        errorMsg = 'Error : ' + body['error']['message'];
      } catch (e) {}

      return errorMsg;
    }
    return null;
  }

  Future<bool> resetIdToken() async {
    var b = await box.get('firebase_backend_data');
    String apiKey = b['apiKey']!;
    String refreshToken = b['refreshToken'];
    var url = Uri.parse(
      'https://securetoken.googleapis.com/v1/token?key=$apiKey',
    );
    var response = await http.post(url,
        body: jsonEncode(
            {'grant_type': 'refresh_token', 'refresh_token': refreshToken}));
    var body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      String newRefreshToken = body['refresh_token'];
      String newIdToken = body['id_token'];
      b['refreshToken'] = newRefreshToken;
      b['idToken'] = newIdToken;

      print('New id token');
      //updating new tokens in hive
      await box.put('firebase_backend_data', b);
    } else {
      showToast(body['error']['message'], context);
    }
    return false;
  }

  Future<Map<String, String>?> getFirebaseBaseUrl() async {
    var b = await box.get('firebase_backend_data');

    if (b != null) {
      String projectId = b['projectId']; //'bitpro-multi-store';
      String databaseName = b['databaseName']; //'(default)';
      String key = b['apiKey']; //"AIzaSyCyn78qz2Ql_lAfdNl9nFSpjkcOVQ_V5TA";
      String idToken = b['idToken'];

      String kUrl =
          'https://firestore.googleapis.com/v1/projects/$projectId/databases/$databaseName/documents';

      return {'kBaseUrl': kUrl, 'apiKey': key, 'idToken': idToken};
    }
    return null;
  }

  Future updateHiveDataWithFirebase() async {
    var box = Hive.box('bitpro_app');
    final providerFeching =
        Provider.of<FetchingDataProvider>(context, listen: false);
    providerFeching.progressValue = 0;
    providerFeching.fetching = true;
    //Users
    //fetching and updating userGroup data into hive
    List<UserGroupData> allUserGroupData =
        await FbUserGroupDbService(context: context).fetchAllUserGroups();
    // await box.put(
    //     'UserGroups', allUserGroupData.map((e) => e.toMap()).toList());
    providerFeching.progressValue = 0.07;
    //fetching and updating users data into hive
    List<UserData> allUsersData =
        await FbUserDbService(context: context).fetchAllUserData();
    // await box.put('Users', allUsersData.map((e) => e.toMap()).toList());
    providerFeching.progressValue = 0.14;
    //Vocuher
    //fetching and updating Purchase Voucher data into hive
    List<DbVoucherData> allVoucherData =
        await FbVoucherDbService(context: context).fetchAllVoucherData();
    // await box.put('Purchase Voucher',
    //     allVoucherData.map((e) => e.toMapNewFirebase()).toList());
    providerFeching.progressValue = 0.21;
    //Setting
    //fetching and updating store data into hive
    List<StoreData> allStoreData =
        await FbStoreDbService(context: context).fetchAllStoresData();
    // await box.put('Stores Data', allStoreData.map((e) => e.toMap()).toList());
    providerFeching.progressValue = 0.28;
    //fetching and updating settings data into hive
    Map<String, dynamic>? resData =
        await FbSettingsDbService(context: context).fetchSettingData();
    // if (resData != null) {
    //   //updating company name and tax percentage
    //   var userSettingData = await box.get('user_settings_data');
    //   userSettingData['companyName'] = resData['companyName'];
    //   await box.put('user_settings_data', userSettingData);

    //   await box.put(
    //       'user_taxes_settings', {'taxPercentage': resData['taxPercentage']});
    // }
    providerFeching.progressValue = 0.35;
    //Sales
    // FbRegisterDbService(context: context).

    //fetching and updating dbReceipt data into hive
    List<DbReceiptData> allDbReceiptData =
        await FbReceiptDbService(context: context).fetchAllReceiptData();
    print(allDbReceiptData.length);
    // await box.put('Sale Receipts',
    //     allDbReceiptData.map((e) => e.toMapNewFirebase()).toList());
    providerFeching.progressValue = 0.42;
    //fetching and updating promotion data into hive
    List<PromoData> allPromoDataList =
        await FbPromoDbService(context: context).fetchPromoData();
    // await box.put(
    //     'Promotion Data Lst', allPromoDataList.map((e) => e.toMap()).toList());
    providerFeching.progressValue = 0.49;
    //fetching and updating formerZOut data into hive
    List<FormerZOutData> allFormerZOutDataLst =
        await FbFormerZOutDbService(context: context).fetchAllFormerZoutData();
    // await box.put(
    //     'Former Z Out', allFormerZOutDataLst.map((e) => e.toMap()).toList());
    providerFeching.progressValue = 0.56;
    //fetching and updating customer payment data into hive
    List<CustomerPaymentData> allCustomerPaymentDataLst =
        await FbCustomerPaymentDbService(context: context)
            .fetchAllCustomerPaymentData();
    // await box.put('Sales Customer Payments Data',
    //     allCustomerPaymentDataLst.map((e) => e.toMap()).toList());
    providerFeching.progressValue = 0.63;
    //fetching and updating sales customer data into hive
    List<CustomerData> allCustomerDataLst =
        await FbCustomerDbService(context: context).fetchAllCustomersData();
    // await box.put('Sales Customer Data',
    //     allCustomerDataLst.map((e) => e.toMap()).toList());
    providerFeching.progressValue = 0.70;
    //Merchandise
    //fetching and updating vendorPayment data into hive
    List<VendorPaymentData> allVendorPaymentDataLst =
        await FbVendorPaymentDbService(context: context)
            .fetchAllVendorsPaymentData();
    // await box.put('Merchandise Vendors Payments',
    //     allVendorPaymentDataLst.map((e) => e.toMap()).toList());
    providerFeching.progressValue = 0.77;
    //fetching and updating vendor data into hive
    List<VendorData> allVendorDataLst =
        await FbVendorDbService(context: context).fetchAllVendorsData();
    // await box.put(
    //     'Merchandise Vendors', allVendorDataLst.map((e) => e.toMap()).toList());
    providerFeching.progressValue = 0.84;
    //fetching and updating inventory data into hive
    List<InventoryData> allInventoryDatalst =
        await FbInventoryDbService(context: context).fetchAllInventoryData();
    // await box.put('Merchandise Inventory',
    //     allInventoryDatalst.map((e) => e.toMap()).toList());
    providerFeching.progressValue = 0.91;
    //fetching and updating merchandise department data into hive
    List<DepartmentData> allDepartmentDataLst =
        await FbDepartmentDbService(context: context).fetchAllDepartmentsData();
    // await box.put('Merchandise Departments',
    //     allDepartmentDataLst.map((e) => e.toMap()).toList());
    providerFeching.progressValue = 0.1;
    providerFeching.fetching = false;
    print('all data fetched & updated');
  }

  Future mergeHiveDataWithFirebase() async {
    var box = Hive.box('bitpro_app');

    //Users
    //fetching and updating userGroup data into FB
    List<UserGroupData> userGroupData =
        await HiveUserGroupDbService().fetchAllUserGroups();
    if (userGroupData.isNotEmpty) {
      await FbUserGroupDbService(context: context)
          .addUpdateUserGroup(userGroupData, onlyFb: true);
    }

    //fetching and updating users data into into FB
    List<UserData> allUsersData = await HiveUserDbService().fetchAllUserData();
    if (allUsersData.isNotEmpty) {
      await FbUserDbService(context: context)
          .addUpdateUser(allUsersData, onlyFb: true);
    }

    //Setting
    //fetching and updating store data into hive
    List<StoreData> allStoreData =
        await HiveStoreDbService().fetchAllStoresData();
    if (allStoreData.isNotEmpty) {
      await FbStoreDbService(context: context)
          .addStoreData(allStoreData, onlyFb: true);
    }

    //fetching and updating settings data into hive

    //getting company name and tax percentage
    var res1 = await box.get('user_settings_data');
    var res2 = await box.get('user_taxes_settings') ?? {};
    await FbSettingsDbService(context: context).addUpdateSettingsData(
        companyName: res1['companyName'],
        taxPercentage: res2['taxPercentage'] == null
            ? res2['taxPercentage'].toString()
            : '15',
        onlyFb: false);

    //Merchandise
    //fetching and updating vendorPayment data into hive
    List<VendorPaymentData> allVendorPaymentDataLst =
        await HiveVendorPaymentDbService().fetchAllVendorsPaymentData();
    if (allVendorPaymentDataLst.isNotEmpty) {
      await FbVendorPaymentDbService(context: context)
          .addVendorPaymentData(allVendorPaymentDataLst, onlyFb: true);
    }

    //fetching and updating vendor data into hive
    List<VendorData> allVendorDataLst =
        await HiveVendorDbService().fetchAllVendorsData();
    if (allVendorDataLst.isNotEmpty) {
      await FbVendorDbService(context: context)
          .addUpdateVendorData(allVendorDataLst, onlyFb: true);
    }

    //fetching and updating inventory data into hive
    List<InventoryData> allInventoryDatalst =
        await HiveInventoryDbService().fetchAllInventoryData();
    if (allInventoryDatalst.isNotEmpty) {
      await FbInventoryDbService(context: context).addUpdateInventoryData(
          inventoryDataLst: allInventoryDatalst, onlyFb: true);
    }

    //fetching and updating merchandise department data into hive
    List<DepartmentData> allDepartmentDataLst =
        await HiveDepartmentDbService().fetchAllDepartmentsData();
    if (allDepartmentDataLst.isNotEmpty) {
      await FbDepartmentDbService(context: context)
          .addUpdateDepartmentData(allDepartmentDataLst, onlyFb: true);
    }

    //Vocuher
    //fetching and updating Purchase Voucher data into hive
    List<DbVoucherData> allVoucherDataLst =
        await HiveVoucherDbService().fetchAllVoucherData();
    if (allVoucherDataLst.isNotEmpty) {
      await FbVoucherDbService(context: context).addUpdateVoucher(
          voucherDataLst: allVoucherDataLst,
          allInventoryDataLst: allInventoryDatalst,
          onlyFb: true);
    }

    //Sales
    // FbRegisterDbService(context: context).

    //fetching and updating dbReceipt data into hive
    List<DbReceiptData> allDbReceiptData =
        await HiveReceiptDbService().fetchAllReceiptData();

    if (allDbReceiptData.isNotEmpty) {
      await FbReceiptDbService(context: context).addUpdateReceipt(
          receiptDataLst: allDbReceiptData,
          allInventoryDataLst: allInventoryDatalst,
          onlyFb: true);
    }

    //fetching and updating promotion data into hive
    List<PromoData> allPromoDataList =
        await HivePromoDbService().fetchPromoData();
    if (allPromoDataList.isNotEmpty) {
      await FbPromoDbService(context: context)
          .addUpdatePromoData(allPromoDataList, onlyFb: true);
    }

    //fetching and updating formerZOut data into hive
    List<FormerZOutData> allFormerZOutDataLst =
        await HiveFormerZOutDbService().fetchAllFormerZoutData();
    if (allFormerZOutDataLst.isNotEmpty) {
      await FbFormerZOutDbService(context: context)
          .addUpdateFormerZOutReceipt(allFormerZOutDataLst, onlyFb: true);
    }

    //fetching and updating customer payment data into hive
    List<CustomerPaymentData> allCustomerPaymentDataLst =
        await HiveCustomerPaymentDbService().fetchAllCustomerPaymentData();
    if (allCustomerPaymentDataLst.isNotEmpty) {
      await FbCustomerPaymentDbService(context: context)
          .addCustomerPaymentData(allCustomerPaymentDataLst, onlyFb: true);
    }

    //fetching and updating sales customer data into hive
    List<CustomerData> allCustomerDataLst =
        await HiveCustomerDbService().fetchAllCustomersData();
    if (allCustomerDataLst.isNotEmpty) {
      await FbCustomerDbService(context: context)
          .addCustomerData(allCustomerDataLst, onlyFb: true);
    }

    print('all data merged');
  }
}
