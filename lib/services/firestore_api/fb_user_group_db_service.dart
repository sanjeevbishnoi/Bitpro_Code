import 'dart:convert';

import 'package:bitpro_hive/services/hive/hive_user_group_db_service.dart';
import 'package:bitpro_hive/shared/toast.dart';
import 'package:bitpro_hive/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:hive/hive.dart';
import 'package:bitpro_hive/model/user_group_data.dart';

class FbUserGroupDbService {
  final String collectionName = 'User Groups';
  final BuildContext context;
  FbUserGroupDbService({
    required this.context,
  });

  Future<void> addUpdateUserGroup(List<UserGroupData> userGroupDataLst,
      {bool onlyFb = false}) async {
    if (onlyFb == false) {
      //if backend setup is skipped then add data in hive
      for (var d in userGroupDataLst) {
        await HiveUserGroupDbService().addEditUserGroup(d);
      }
      if (globalIsFbSetupSkipted) return;
    }
    //if backend setup is not skipped then add data in firebase
    try {
      Map<String, String>? res =
          await FirebaseService(context: context).getFirebaseBaseUrl();

      if (res != null) {
        String kBaseUrl = res['kBaseUrl']!;
        String apiKey = res['apiKey']!;
        String idToken = res['idToken']!;

        for (UserGroupData userGroup in userGroupDataLst) {
          var url = Uri.parse(
            '$kBaseUrl/$collectionName/${userGroup.docId}?key=$apiKey',
          );

          var response = await http.patch(url,
              body: jsonEncode({
                "fields": {
                  "createdBy": {"stringValue": userGroup.createdBy},
                  "createdDate": {
                    "stringValue": userGroup.createdDate.toString()
                  },
                  "docId": {"stringValue": userGroup.docId},
                  "name": {"stringValue": userGroup.name},
                  "description": {"stringValue": userGroup.description},
                  "employees": {"booleanValue": userGroup.employees},
                  "registers": {"booleanValue": userGroup.registers},
                  "groups": {"booleanValue": userGroup.groups},
                  "salesReceipt": {"booleanValue": userGroup.salesReceipt},
                  "vendors": {"booleanValue": userGroup.vendors},
                  "reports": {"booleanValue": userGroup.reports},
                  "departments": {"booleanValue": userGroup.departments},
                  "settings": {"booleanValue": userGroup.settings},
                  "inventory": {"booleanValue": userGroup.inventory},
                  "purchaseVoucher": {
                    "booleanValue": userGroup.purchaseVoucher
                  },
                  "customers": {"booleanValue": userGroup.customers},
                  "receipt": {"booleanValue": userGroup.receipt},
                  "formerZout": {"booleanValue": userGroup.formerZout},
                  "adjustment": {"booleanValue": userGroup.adjustment},
                  "backupReset": {"booleanValue": userGroup.backupReset},
                  "promotion": {"booleanValue": userGroup.promotion},
                }
              }),
              headers: {'Authorization': 'Bearer $idToken'});

          var body = jsonDecode(response.body);

          if (response.statusCode == 200) {
            // print(await response.stream.bytesToString());
          } else if (response.statusCode == 401 &&
              body['error']['message'] ==
                  'Missing or invalid authentication.') {
            await FirebaseService(context: context).resetIdToken();

            return await addUpdateUserGroup(userGroupDataLst);
          } else {
            showToast(body['error']['message'], context);
            // return false;
          }
        }
      }
    } catch (e) {
      //updating add/udpate error status
      print('user group add/update error : ${e.toString()}');
      var box = Hive.box('bitpro_app');
      var d = await box.get('FbAddUpdateErrorStatus') ?? {};
      d['isUserGroupsDataUpdate'] = false;
      await box.put('FbAddUpdateErrorStatus', d);
    }
  }

  Future<List<UserGroupData>> fetchAllUserGroups() async {
    if (globalIsFbSetupSkipted == false) {
      //Firebase Fetch
      try {
        Map<String, String>? res =
            await FirebaseService(context: context).getFirebaseBaseUrl();

        if (res != null) {
          String kBaseUrl = res['kBaseUrl']!;
          String apiKey = res['apiKey']!;
          String idToken = res['idToken']!;
          var url = Uri.parse(
            '$kBaseUrl/$collectionName?key=$apiKey',
          );

          var response = await http
              .get(url, headers: {'Authorization': 'Bearer $idToken'});

          var body = jsonDecode(response.body);

          if (response.statusCode == 200) {
            List<UserGroupData> userDataLst = [];

            for (var d in body['documents'] ?? []) {
              userDataLst.add(UserGroupData(
                docId: d['fields']['docId']['stringValue'],
                createdDate:
                    DateTime.parse(d['fields']['createdDate']['stringValue']),
                createdBy: d['fields']['createdBy']['stringValue'],
                name: d['fields']['name']['stringValue'],
                description: d['fields']['description']['stringValue'],
                departments: d['fields']['departments']['booleanValue'],
                adjustment: d['fields']['adjustment']['booleanValue'],
                backupReset: d['fields']['backupReset']['booleanValue'],
                customers: d['fields']['customers']['booleanValue'],
                employees: d['fields']['employees']['booleanValue'],
                formerZout: d['fields']['formerZout']['booleanValue'],
                groups: d['fields']['groups']['booleanValue'],
                inventory: d['fields']['inventory']['booleanValue'],
                promotion: d['fields']['promotion']['booleanValue'],
                purchaseVoucher: d['fields']['purchaseVoucher']['booleanValue'],
                receipt: d['fields']['receipt']['booleanValue'],
                registers: d['fields']['registers']['booleanValue'],
                reports: d['fields']['reports']['booleanValue'],
                salesReceipt: d['fields']['salesReceipt']['booleanValue'],
                settings: d['fields']['settings']['booleanValue'],
                vendors: d['fields']['vendors']['booleanValue'],
              ));
            }

            //updating data in hive
            var box = Hive.box('bitpro_app');
            await box.put(
                'UserGroups', {for (var u in userDataLst) u.docId: u.toMap()});

            return userDataLst;
          } else if (response.statusCode == 401 &&
              body['error']['message'] ==
                  'Missing or invalid authentication.') {
            await FirebaseService(context: context).resetIdToken();

            return await fetchAllUserGroups();
          } else {
            showToast(body['error']['message'], context);
          }
        }
      } catch (e) {
        //updating fetch error status
        print('usergroup fetch error : ${e.toString()} ${e.hashCode}');
        var box = Hive.box('bitpro_app');
        var d = await box.get('FbFetchErrorStatus') ?? {};
        d['isUserGroupsDataUpdate'] = false;
        await box.put('FbFetchErrorStatus', d);
      }
    }

    //Hive Fetch : On Fb Error or Backend setup skipted
    List<UserGroupData> userGroupDataLst =
        await HiveUserGroupDbService().fetchAllUserGroups();

    return userGroupDataLst;
  }
}
