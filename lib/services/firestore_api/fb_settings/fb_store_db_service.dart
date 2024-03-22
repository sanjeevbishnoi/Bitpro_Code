import 'dart:convert';
import 'dart:io';

import 'package:bitpro_hive/model/store_data.dart';
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_settings/hive_store_db_service.dart';
import 'package:bitpro_hive/shared/toast.dart';
import 'package:bitpro_hive/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class FbStoreDbService {
  final String collectionName = 'Stores Data';
  final BuildContext context;
  FbStoreDbService({
    required this.context,
  });

  Future addStoreData(List<StoreData> storeDataLst,
      {bool onlyFb = false}) async {
    if (onlyFb == false) {
      //if backend setup is skipped then add data in hive

      for (var k in storeDataLst) {
        await HiveStoreDbService().addStoreData(k);
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
        for (StoreData s in storeDataLst) {
          var url = Uri.parse(
            '$kBaseUrl/$collectionName/${s.docId}?key=$apiKey',
          );

          var response = await http.patch(url,
              body: jsonEncode({
                "fields": {
                  "docId": {"stringValue": s.docId},
                  "storeCode": {"stringValue": s.storeCode},
                  "storeName": {"stringValue": s.storeName},
                  "address1": {"stringValue": s.address1},
                  "address2": {"stringValue": s.address2},
                  "phone1": {"stringValue": s.phone1},
                  "phone2": {"stringValue": s.phone2},
                  "vatNumber": {"stringValue": s.vatNumber},
                  "priceLevel": {"stringValue": s.priceLevel},
                  "logoPath": {"stringValue": s.logoPath},
                  "bankName": {"stringValue": s.bankName},
                  "email": {"stringValue": s.email},
                  "ibanAccountNumber": {"stringValue": s.ibanAccountNumber},
                  "workstationInfo": {
                    "arrayValue": {
                      "values": s.workstationInfo
                          .map((e) => {'integerValue': e})
                          .toList()
                    }
                  }
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

            return await addStoreData(storeDataLst);
          } else {
            showToast(body['error']['message'], context);
            return false;
          }
        }
      }
    } catch (e) {
      //updating add/update error status
      print('store add/update error : ${e.toString()}');
      var box = Hive.box('bitpro_app');
      var d = await box.get('FbAddUpdateErrorStatus') ?? {};
      d['isStoresDataUpdate'] = false;
      await box.put('FbAddUpdateErrorStatus', d);
    }
  }

  Future<List<StoreData>> fetchAllStoresData() async {
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
          print(url);

          var response = await http
              .get(url, headers: {'Authorization': 'Bearer $idToken'});

          var body = jsonDecode(response.body);
          // print(body);
          // print(response.statusCode);
          if (response.statusCode == 200) {
            List<StoreData> storesDataLst = [];

            for (var d in body['documents'] ?? []) {
              print(d['fields']['workstationInfo']['arrayValue']);
              storesDataLst.add(StoreData(
                docId: d['fields']['docId']['stringValue'],
                storeCode: d['fields']['storeCode']['stringValue'],
                storeName: d['fields']['storeName']['stringValue'],
                address1: d['fields']['address1']['stringValue'],
                address2: d['fields']['address2']['stringValue'],
                phone1: d['fields']['phone1']['stringValue'],
                phone2: d['fields']['phone2']['stringValue'],
                vatNumber: d['fields']['vatNumber']['stringValue'],
                priceLevel: d['fields']['priceLevel']['stringValue'],
                logoPath: d['fields']['logoPath']['stringValue'],
                bankName: d['fields']['bankName']['stringValue'],
                email: d['fields']['email']['stringValue'],
                ibanAccountNumber: d['fields']['ibanAccountNumber']
                    ['stringValue'],
                workstationInfo:
                    d['fields']['workstationInfo']['arrayValue'] == null ||
                            d['fields']['workstationInfo']['arrayValue'].isEmpty
                        ? []
                        : d['fields']['workstationInfo']['arrayValue']['values']
                                .map((e) => e['integerValue'])
                                .toList() ??
                            [],
              ));
            }
            print(storesDataLst.length);
            //updating data in hive
            var box = Hive.box('bitpro_app');
            await box.put('Stores Data',
                {for (var s in storesDataLst) s.docId: s.toMap()});

            return storesDataLst;
          } else if (response.statusCode == 401 &&
              body['error']['message'] ==
                  'Missing or invalid authentication.') {
            await FirebaseService(context: context).resetIdToken();

            return await fetchAllStoresData();
          } else {
            showToast(body['error']['message'], context);
          }
        }
      } catch (e) {
        //updating fetch error status
        print('store fetch error : ${e.toString()}');
        var box = Hive.box('bitpro_app');
        var d = await box.get('FbFetchErrorStatus') ?? {};
        d['isStoresDataUpdate'] = false;
        await box.put('FbFetchErrorStatus', d);
      }
    }

    //Hive Fetch : On Fb Error or Backend setup skipted
    List<StoreData> storeDataLst =
        await HiveStoreDbService().fetchAllStoresData();

    return storeDataLst;
  }

  Future<String> uploadImage(
      {required File file, required String fileName}) async {
    var p =
        await getApplicationSupportDirectory(); // C:\Users\team\AppData\Roaming\com.example\bitpro_hive

    File imgDirectory = File('${p.path}/images/stores/$fileName.png');

    try {
      await imgDirectory.create(recursive: true);
    } catch (e) {}

    await file.copy(imgDirectory.path);

    return imgDirectory.path;
  }
}
