import 'dart:convert';
import 'package:bitpro_hive/services/hive/hive_sales_db_service/hive_former_z_out_db_service.dart';
import 'package:bitpro_hive/wrapper.dart';
import 'package:http/http.dart' as http;
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:bitpro_hive/shared/toast.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:bitpro_hive/model/former_z_out_data.dart';

class FbFormerZOutDbService {
  final String collectionName = 'Former Z Out';
  final BuildContext context;
  FbFormerZOutDbService({
    required this.context,
  });

  addUpdateFormerZOutReceipt(List<FormerZOutData> formerZOutDataLst,
      {bool onlyFb = false}) async {
    if (onlyFb == false) {
      //if backend setup is skipped then add data in hive

      for (var f in formerZOutDataLst) {
        await HiveFormerZOutDbService().addFormerZOutReceipt(f);
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
        for (FormerZOutData f in formerZOutDataLst) {
          var url = Uri.parse(
            '$kBaseUrl/$collectionName/${f.docId}?key=$apiKey',
          );

          var response = await http.patch(url,
              body: jsonEncode({
                "fields": {
                  "docId": {"stringValue": f.docId},
                  "formerZoutNo": {"stringValue": f.formerZoutNo},
                  "total": {"stringValue": f.total},
                  "cashierName": {"stringValue": f.cashierName},
                  "overShort": {"stringValue": f.overShort},
                  "totalCashOnSystem": {"stringValue": f.totalCashOnSystem},
                  "totalCashEntered": {"stringValue": f.totalCashEntered},
                  "totalCashDifferences": {
                    "stringValue": f.totalCashDifferences
                  },
                  "totalNCDifferences": {"stringValue": f.totalNCDifferences},
                  "openDate": {"stringValue": f.openDate},
                  "closeDate": {"stringValue": f.closeDate},
                  "creditCardTotalInSystem": {
                    "stringValue": f.creditCardTotalInSystem
                  },
                  "creditCardTotal": {"stringValue": f.creditCardTotal},
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

            return await addUpdateFormerZOutReceipt(formerZOutDataLst);
          } else {
            showToast(body['error']['message'], context);
            return false;
          }
        }
      }
    } catch (e) {
      //updating add/update error status
      print('former z out add/update error : ${e.toString()}');
      var box = Hive.box('bitpro_app');
      var d = await box.get('FbAddUpdateErrorStatus') ?? {};
      d['isFormerZOutDataUpdate'] = false;
      await box.put('FbAddUpdateErrorStatus', d);
    }
  }

  Future<List<FormerZOutData>> fetchAllFormerZoutData() async {
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
            List<FormerZOutData> formerZOutDataLst = [];

            for (var d in body['documents'] ?? []) {
              formerZOutDataLst.add(FormerZOutData(
                docId: d['fields']['docId']['stringValue'],
                formerZoutNo: d['fields']['formerZoutNo']['stringValue'],
                total: d['fields']['total']['stringValue'],
                cashierName: d['fields']['cashierName']['stringValue'],
                overShort: d['fields']['overShort']['stringValue'],
                totalCashOnSystem: d['fields']['totalCashOnSystem']
                    ['stringValue'],
                totalCashEntered: d['fields']['totalCashEntered']
                    ['stringValue'],
                totalCashDifferences: d['fields']['totalCashDifferences']
                    ['stringValue'],
                totalNCDifferences: d['fields']['totalNCDifferences']
                    ['stringValue'],
                openDate: d['fields']['openDate']['stringValue'],
                closeDate: d['fields']['closeDate']['stringValue'],
                creditCardTotalInSystem: d['fields']['creditCardTotalInSystem']
                    ['stringValue'],
                creditCardTotal: d['fields']['creditCardTotal']['stringValue'],
              ));
            }

            //updating data in hive
            var box = Hive.box('bitpro_app');
            await box.put('Former Z Out',
                {for (var f in formerZOutDataLst) f.docId: f.toMap()});

            return formerZOutDataLst;
          } else if (response.statusCode == 401 &&
              body['error']['message'] ==
                  'Missing or invalid authentication.') {
            await FirebaseService(context: context).resetIdToken();

            return await fetchAllFormerZoutData();
          } else {
            showToast(body['error']['message'], context);
          }
        }
      } catch (e) {
        //updating fetch error status
        print('former z out fetch error : ${e.toString()}');
        var box = Hive.box('bitpro_app');
        var d = await box.get('FbFetchErrorStatus') ?? {};
        d['isFormerZOutDataUpdate'] = false;
        await box.put('FbFetchErrorStatus', d);
      }
    }

    //Hive Fetch : On Fb Error or Backend setup skipted
    List<FormerZOutData> formerZoutDataLst =
        await HiveFormerZOutDbService().fetchAllFormerZoutData();

    return formerZoutDataLst;
  }

  // Future<String> getNewZoutNo() async {
  //   var box = Hive.box('bitpro_app');
  //   Map? fLst = box.get('Former Z Out');
  //   if (fLst == null) return '10000';
  //   List<FormerZOutData> lst = fLst.values.map((v) {
  //     return FormerZOutData.fromMap(v);
  //   }).toList();

  //   lst.sort((a, b) => a.formerZoutNo.compareTo(b.formerZoutNo));

  //   return (int.parse(lst.last.formerZoutNo) + 1).toString();
  // }
}
