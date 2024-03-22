import 'dart:convert';

import 'package:bitpro_hive/services/hive/hive_user_db_service.dart';
import 'package:bitpro_hive/shared/toast.dart';
import 'package:bitpro_hive/wrapper.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:flutter/material.dart';
import 'package:bitpro_hive/model/user_data.dart';

class FbUserDbService {
  final String collectionName = 'Users';
  final BuildContext context;
  FbUserDbService({
    required this.context,
  });

  Future<UserData?> loginUser(String username, String password) async {
    //if backend setup is skipped then add data in hive
    if (globalIsFbSetupSkipted) {
      UserData? userData = await HiveUserDbService().login(username, password);

      return userData;
    }

    //if backend setup is not skipped then add data in firebase
    try {
      Map<String, String>? res =
          await FirebaseService(context: context).getFirebaseBaseUrl();

      if (res != null) {
        String kBaseUrl = res['kBaseUrl']!;
        String apiKey = res['apiKey']!;
        String idToken = res['idToken']!;
        var url = Uri.parse(
          '$kBaseUrl/:runQuery',
        );

        var response = await http.post(url,
            body: jsonEncode({
              "structuredQuery": {
                "from": [
                  {"collectionId": "Users", "allDescendants": false}
                ],
                "where": {
                  "compositeFilter": {
                    "op": "AND",
                    "filters": [
                      {
                        "fieldFilter": {
                          "field": {"fieldPath": "username"},
                          "op": "EQUAL",
                          "value": {"stringValue": username}
                        }
                      },
                      {
                        "fieldFilter": {
                          "field": {"fieldPath": "password"},
                          "op": "EQUAL",
                          "value": {"stringValue": password}
                        }
                      }
                    ],
                  }
                }
              }
            }),
            headers: {'Authorization': 'Bearer $idToken'});

        var body = jsonDecode(response.body);

        if (response.statusCode == 200) {
          // print(await response.stream.bytesToString());
          for (var d in body) {
            if (d['document'] != null) {
              DateTime? openRegisterDateTime;
              var doc = d['document'];
              try {
                openRegisterDateTime = DateTime.tryParse(
                    doc['fields']['openRegister']['stringValue']);
              } catch (e) {}
              return UserData(
                docId: doc['fields']['docId']['stringValue'],
                createdDate:
                    DateTime.parse(doc['fields']['createdDate']['stringValue']),
                openRegister: openRegisterDateTime,
                createdBy: doc['fields']['createdBy']['stringValue'],
                employeeId: doc['fields']['employeeId']['stringValue'],
                firstName: doc['fields']['firstName']['stringValue'],
                lastName: doc['fields']['lastName']['stringValue'],
                maxDiscount: doc['fields']['maxDiscount']['stringValue'],
                password: doc['fields']['password']['stringValue'],
                userRole: doc['fields']['userRole']['stringValue'],
                username: doc['fields']['username']['stringValue'],
              );
            }
          }
        } else if (response.statusCode == 401 &&
            body['error']['message'] == 'Missing or invalid authentication.') {
          await FirebaseService(context: context).resetIdToken();

          return await loginUser(username, password);
        } else {
          showToast(body['error']['message'], context);
        }
      }
    } catch (e) {
      showToast('Error : Cannot connect with Backend', context);
    }
  }

  addUpdateUser(List<UserData> userDataLst, {bool onlyFb = false}) async {
    if (onlyFb == false) {
      //if backend setup is skipped then add data in hive
      for (var d in userDataLst) {
        await HiveUserDbService().addEditUser(d);
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
        for (UserData user in userDataLst) {
          var url = Uri.parse(
            '$kBaseUrl/$collectionName/${user.docId}?key=$apiKey',
          );

          var response = await http.patch(url,
              body: jsonEncode({
                "fields": {
                  "firstName": {"stringValue": user.firstName},
                  "lastName": {"stringValue": user.lastName},
                  "username": {"stringValue": user.username},
                  "employeeId": {"stringValue": user.employeeId},
                  "password": {"stringValue": user.password},
                  "userRole": {"stringValue": user.userRole},
                  "maxDiscount": {"stringValue": user.maxDiscount},
                  "createdBy": {"stringValue": user.createdBy},
                  "docId": {"stringValue": user.docId},
                  "createdDate": {"stringValue": user.createdDate.toString()},
                  "openRegister": {
                    if (user.openRegister == null) "nullValue": "NULL_VALUE",
                    if (user.openRegister != null)
                      "stringValue": user.openRegister.toString()
                  },
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

            return await addUpdateUser(userDataLst);
          } else {
            showToast(body['error']['message'], context);
            return false;
          }
        }
      }
    } catch (e) {
      //updating add/update error status
      print('user add/update error : ${e.toString()}');
      var box = Hive.box('bitpro_app');
      var d = await box.get('FbAddUpdateErrorStatus') ?? {};
      d['isUsersDataUpdate'] = false;
      await box.put('FbAddUpdateErrorStatus', d);
    }
  }

  Future<List<UserData>> fetchAllUserData() async {
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
            List<UserData> userDataLst = [];

            for (var d in body['documents'] ?? []) {
              DateTime? openRegisterDateTime;

              try {
                openRegisterDateTime = DateTime.tryParse(
                    d['fields']['openRegister']['stringValue']);
              } catch (e) {}
              userDataLst.add(UserData(
                docId: d['fields']['docId']['stringValue'],
                createdDate:
                    DateTime.parse(d['fields']['createdDate']['stringValue']),
                openRegister: openRegisterDateTime,
                createdBy: d['fields']['createdBy']['stringValue'],
                employeeId: d['fields']['employeeId']['stringValue'],
                firstName: d['fields']['firstName']['stringValue'],
                lastName: d['fields']['lastName']['stringValue'],
                maxDiscount: d['fields']['maxDiscount']['stringValue'],
                password: d['fields']['password']['stringValue'],
                userRole: d['fields']['userRole']['stringValue'],
                username: d['fields']['username']['stringValue'],
              ));
            }

            //updating data in hive
            var box = Hive.box('bitpro_app');
            await box
                .put('Users', {for (var u in userDataLst) u.docId: u.toMap()});

            return userDataLst;
          } else if (response.statusCode == 401 &&
              body['error']['message'] ==
                  'Missing or invalid authentication.') {
            await FirebaseService(context: context).resetIdToken();

            return await fetchAllUserData();
          } else {
            showToast(body['error']['message'], context);
          }
        }
      } catch (e) {
        //updating fetch error status
        print('user fetch error : ${e.toString()}');
        var box = Hive.box('bitpro_app');
        var d = await box.get('FbFetchErrorStatus') ?? {};
        d['isUsersDataUpdate'] = false;
        await box.put('FbFetchErrorStatus', d);
      }
    }

    //Hive Fetch : On Fb Error or Backend setup skipted
    List<UserData> userDataLst = await HiveUserDbService().fetchAllUserData();
    return userDataLst;
  }
}
