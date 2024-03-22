import 'dart:convert';
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_settings/hive_settings_db_service.dart';
import 'package:bitpro_hive/shared/toast.dart';
import 'package:bitpro_hive/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class FbSettingsDbService {
  final String collectionName = 'Settings Data';
  final BuildContext context;
  FbSettingsDbService({
    required this.context,
  });

  Future addUpdateSettingsData(
      {required String companyName,
      required String taxPercentage,
      bool onlyFb = false}) async {
    if (onlyFb == false) {
      //if backend setup is skipped then add data in hive

      await HiveSettingsDbService().addUpdateTab1SettingsData(
        companyName: companyName,
      );
      await HiveSettingsDbService()
          .addUpdateTab3SettingsData(taxPercentage: taxPercentage);

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
        var url = Uri.parse(
          '$kBaseUrl/$collectionName/settings_data?key=$apiKey',
        );

        var response = await http.patch(url,
            body: jsonEncode({
              "fields": {
                "companyName": {"stringValue": companyName},
                "taxPercentage": {"stringValue": taxPercentage},
              }
            }),
            headers: {'Authorization': 'Bearer $idToken'});

        var body = jsonDecode(response.body);

        if (response.statusCode == 200) {
          // print(await response.stream.bytesToString());
        } else if (response.statusCode == 401 &&
            body['error']['message'] == 'Missing or invalid authentication.') {
          await FirebaseService(context: context).resetIdToken();

          return await addUpdateSettingsData(
              companyName: companyName, taxPercentage: taxPercentage);
        } else {
          showToast(body['error']['message'], context);
          return false;
        }
      }
    } catch (e) {
      //updating add/update error status
      print('setting add/update error : ${e.toString()}');
      var box = Hive.box('bitpro_app');
      var d = await box.get('FbAddUpdateErrorStatus') ?? {};
      d['isSettingsDataUpdate'] = false;
      await box.put('FbAddUpdateErrorStatus', d);
    }
  }

  Future<Map<String, dynamic>?> fetchSettingData() async {
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
            Map<String, dynamic>? storesDataLst;

            for (var d in body['documents'] ?? []) {
              storesDataLst = {
                'companyName': d['fields']['companyName']['stringValue'],
                'taxPercentage': d['fields']['taxPercentage']['stringValue'],
              };
            }

            //updating data in hive
            if (storesDataLst != null) {
              await HiveSettingsDbService().addUpdateTab1SettingsData(
                companyName: storesDataLst['companyName'],
              );
              await HiveSettingsDbService().addUpdateTab3SettingsData(
                  taxPercentage: storesDataLst['taxPercentage']);
            }

            return storesDataLst;
          } else if (response.statusCode == 401 &&
              body['error']['message'] ==
                  'Missing or invalid authentication.') {
            await FirebaseService(context: context).resetIdToken();

            return await fetchSettingData();
          } else {
            showToast(body['error']['message'], context);
          }
        }
      } catch (e) {
        //updating fetch error status
        print('store fetch error : ${e.toString()}');
        var box = Hive.box('bitpro_app');
        var d = await box.get('FbFetchErrorStatus') ?? {};
        d['isSettingsDataUpdate'] = false;
        await box.put('FbFetchErrorStatus', d);
      }
    }

    //Hive Fetch : On Fb Error or Backend setup skipted
    var box = Hive.box('bitpro_app');
    var userSettingData = await box.get('user_settings_data');
    var userTaxesSettings = await box.get('user_taxes_settings');

    return {
      'companyName':
          userSettingData == null ? '' : userSettingData['companyName'],
      'taxPercentage':
          userTaxesSettings == null ? 15 : userTaxesSettings['taxPercentage']
    };
  }
}
