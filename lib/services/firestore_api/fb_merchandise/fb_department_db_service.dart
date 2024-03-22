import 'dart:convert';
import 'package:bitpro_hive/services/hive/hive_merchandise_db_service/department_db_service.dart';
import 'package:bitpro_hive/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:bitpro_hive/model/department_data.dart';
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:bitpro_hive/shared/toast.dart';

class FbDepartmentDbService {
  final String collectionName = 'Merchandise Departments';
  final BuildContext context;
  FbDepartmentDbService({
    required this.context,
  });

  Future<void> addUpdateDepartmentData(List<DepartmentData> departmentDataLst,
      {bool onlyFb = false}) async {
    if (onlyFb == false) {
      //if backend setup is skipped then add data in hive

      for (var d in departmentDataLst) {
        await HiveDepartmentDbService().addDepartmentData(d.createdBy,
            d.createdDate, d.docId, d.departmentId, d.departmentName);
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
        for (DepartmentData dep in departmentDataLst) {
          var url = Uri.parse(
            '$kBaseUrl/$collectionName/${dep.docId}?key=$apiKey',
          );

          var response = await http.patch(url,
              body: jsonEncode({
                "fields": {
                  "createdBy": {"stringValue": dep.createdBy},
                  "createdDate": {"stringValue": dep.createdDate.toString()},
                  "departmentId": {"stringValue": dep.departmentId},
                  "departmentName": {"stringValue": dep.departmentName},
                  "docId": {"stringValue": dep.docId},
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

            return await addUpdateDepartmentData(departmentDataLst);
          } else {
            showToast(body['error']['message'], context);
          }
        }
      }
    } catch (e) {
      //updating add_error_status
      print('department add/update error : ${e.toString()}');
      var box = Hive.box('bitpro_app');
      var d = await box.get('FbAddUpdateErrorStatus') ?? {};
      d['isMerchandiseDepartmentsDataUpdate'] = false;
      await box.put('FbAddUpdateErrorStatus', d);
    }
  }

  Future<List<DepartmentData>> fetchAllDepartmentsData() async {
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
            List<DepartmentData> departmentDataLst = [];

            for (var d in body['documents'] ?? []) {
              departmentDataLst.add(DepartmentData(
                  docId: d['fields']['docId']['stringValue'],
                  departmentName: d['fields']['departmentName']['stringValue'],
                  departmentId: d['fields']['departmentId']['stringValue'],
                  createdDate:
                      DateTime.parse(d['fields']['createdDate']['stringValue']),
                  createdBy: d['fields']['createdBy']['stringValue']));
            }

            //updating data in hive
            var box = Hive.box('bitpro_app');
            await box.put('Merchandise Departments',
                {for (var d in departmentDataLst) d.docId: d.toMap()});

            return departmentDataLst;
          } else if (response.statusCode == 401 &&
              body['error']['message'] ==
                  'Missing or invalid authentication.') {
            await FirebaseService(context: context).resetIdToken();

            return await fetchAllDepartmentsData();
          } else {
            showToast(body['error']['message'], context);
          }
        }
      } catch (e) {
        //updating fetch error status
        print('department fetch error : ${e.toString()}');
        var box = Hive.box('bitpro_app');
        var d = await box.get('FbFetchErrorStatus') ?? {};
        d['isMerchandiseDepartmentsDataUpdate'] = false;
        await box.put('FbFetchErrorStatus', d);
      }
    }

    //Hive Fetch : On Fb Error or Backend setup skipted
    List<DepartmentData> departmentDataLst =
        await HiveDepartmentDbService().fetchAllDepartmentsData();

    return departmentDataLst;
  }
}
