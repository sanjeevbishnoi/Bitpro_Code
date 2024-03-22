import 'dart:convert';

import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_sales_db_service/hive_promo_code_db_serice.dart';
import 'package:bitpro_hive/shared/toast.dart';
import 'package:bitpro_hive/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:bitpro_hive/model/promo_code_data.dart';
import 'package:http/http.dart' as http;

class FbPromoDbService {
  final String collectionName = 'Promotion Data Lst';
  final BuildContext context;
  FbPromoDbService({
    required this.context,
  });
  Future addUpdatePromoData(List<PromoData> promoDataLst,
      {bool onlyFb = false}) async {
    if (onlyFb == false) {
      //if backend setup is skipped then add data in hive

      for (var d in promoDataLst) {
        await HivePromoDbService().addPromoData(d);
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
        for (PromoData p in promoDataLst) {
          var url = Uri.parse(
            '$kBaseUrl/$collectionName/${p.docId}?key=$apiKey',
          );

          var response = await http.patch(url,
              body: jsonEncode({
                "fields": {
                  "docId": {"stringValue": p.docId},
                  "promoNo": {"stringValue": p.promoNo},
                  "startDate": {"stringValue": p.startDate.toString()},
                  "endDate": {"stringValue": p.endDate.toString()},
                  "barcode": {"stringValue": p.barcode},
                  "percentage": {"stringValue": p.percentage},
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

            return await addUpdatePromoData(promoDataLst);
          } else {
            showToast(body['error']['message'], context);
            return false;
          }
        }
      }
    } catch (e) {
      //updating add/update error status
      print('promo code add/update error : ${e.toString()}');
      var box = Hive.box('bitpro_app');
      var d = await box.get('FbAddUpdateErrorStatus') ?? {};
      d['isPromotionDataUpdate'] = false;
      await box.put('FbAddUpdateErrorStatus', d);
    }
  }

  Future<List<PromoData>> fetchPromoData() async {
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
            List<PromoData> promoDataLst = [];

            for (var d in body['documents'] ?? []) {
              promoDataLst.add(PromoData(
                docId: d['fields']['docId']['stringValue'],
                startDate:
                    DateTime.parse(d['fields']['startDate']['stringValue']),
                endDate:
                    DateTime.parse(d['fields']['startDate']['stringValue']),
                barcode: d['fields']['barcode']['stringValue'],
                percentage: d['fields']['percentage']['stringValue'],
                promoNo: d['fields']['promoNo']['stringValue'],
              ));
            }

            //updating data in hive
            var box = Hive.box('bitpro_app');
            await box.put('Promotion Data Lst',
                {for (var p in promoDataLst) p.docId: p.toMap()});

            return promoDataLst;
          } else if (response.statusCode == 401 &&
              body['error']['message'] ==
                  'Missing or invalid authentication.') {
            await FirebaseService(context: context).resetIdToken();

            return await fetchPromoData();
          } else {
            showToast(body['error']['message'], context);
          }
        }
      } catch (e) {
        //updating fetch error status
        print('promo fetch error : ${e.toString()}');
        var box = Hive.box('bitpro_app');
        var d = await box.get('FbFetchErrorStatus') ?? {};
        d['isPromotionDataUpdate'] = false;
        await box.put('FbFetchErrorStatus', d);
      }
    }
    //Hive Fetch : On Fb Error or Backend setup skipted
    List<PromoData> promoDataLst = await HivePromoDbService().fetchPromoData();
    return promoDataLst;
  }

  Future deleteAllPromoData(List<PromoData> promoDataLst) async {
    //if backend setup is skipped then add data in hive

    await HivePromoDbService().deleteAllPromoData();

    if (globalIsFbSetupSkipted) return;
    try {
      for (PromoData d in promoDataLst) {
        Map<String, String>? res =
            await FirebaseService(context: context).getFirebaseBaseUrl();

        if (res != null) {
          String kBaseUrl = res['kBaseUrl']!;
          String apiKey = res['apiKey']!;
          String idToken = res['idToken']!;
          var url = Uri.parse(
            '$kBaseUrl/$collectionName/${d.docId}?key=$apiKey',
          );

          var response = await http
              .delete(url, headers: {'Authorization': 'Bearer $idToken'});

          var body = jsonDecode(response.body);

          print(body);
        }
      }
    } catch (e) {}
  }
}
