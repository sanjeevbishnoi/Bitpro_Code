import 'dart:convert';
import 'package:bitpro_hive/services/hive/hive_merchandise_db_service/vendors_db_service.dart';
import 'package:bitpro_hive/shared/toast.dart';
import 'package:bitpro_hive/wrapper.dart';
import 'package:http/http.dart' as http;
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:bitpro_hive/model/vendor_data.dart';

class FbVendorDbService {
  final String collectionName = 'Merchandise Vendors';
  final BuildContext context;
  FbVendorDbService({
    required this.context,
  });

  Future addUpdateVendorData(List<VendorData> vendorDataLst,
      {bool onlyFb = false}) async {
    if (onlyFb == false) {
      //if backend setup is skipped then add data in hive

      for (var d in vendorDataLst) {
        await HiveVendorDbService().addVendorData(
            d.createdDate,
            d.docId,
            d.createdBy,
            d.vendorName,
            d.emailAddress,
            d.vendorId,
            d.address1,
            d.phone1,
            d.address2,
            d.phone2,
            d.vatNumber,
            d.openingBalance);
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
        for (var v in vendorDataLst) {
          var url = Uri.parse(
            '$kBaseUrl/$collectionName/${v.docId}?key=$apiKey',
          );

          var response = await http.patch(url,
              body: jsonEncode({
                "fields": {
                  "createdBy": {"stringValue": v.createdBy},
                  "createdDate": {"stringValue": v.createdDate.toString()},
                  "docId": {"stringValue": v.docId},
                  "vendorName": {"stringValue": v.vendorName},
                  "emailAddress": {"stringValue": v.emailAddress},
                  "vendorId": {"stringValue": v.vendorId},
                  "address1": {"stringValue": v.address1},
                  "phone1": {"stringValue": v.phone1},
                  "address2": {"stringValue": v.address2},
                  "phone2": {"stringValue": v.phone2},
                  "vatNumber": {"stringValue": v.vatNumber},
                  "openingBalance": {"stringValue": v.openingBalance},
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

            return await addUpdateVendorData(vendorDataLst);
          } else {
            showToast(body['error']['message'], context);
            return false;
          }
        }
      }
    } catch (e) {
      //updating add/update error status
      print('vendor add/update error : ${e.toString()}');
      var box = Hive.box('bitpro_app');
      var d = await box.get('FbAddUpdateErrorStatus') ?? {};
      d['isMerchandiseVendorsDataUpdate'] = false;
      await box.put('FbAddUpdateErrorStatus', d);
    }
  }

  Future<List<VendorData>> fetchAllVendorsData() async {
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
            List<VendorData> vendorDataLst = [];

            for (var d in body['documents'] ?? []) {
              vendorDataLst.add(VendorData(
                docId: d['fields']['docId']['stringValue'],
                createdDate:
                    DateTime.parse(d['fields']['createdDate']['stringValue']),
                createdBy: d['fields']['createdBy']['stringValue'],
                address1: d['fields']['address1']['stringValue'],
                address2: d['fields']['address2']['stringValue'],
                emailAddress: d['fields']['emailAddress']['stringValue'],
                openingBalance: d['fields']['openingBalance']['stringValue'],
                phone1: d['fields']['phone1']['stringValue'],
                phone2: d['fields']['phone2']['stringValue'],
                vatNumber: d['fields']['vatNumber']['stringValue'],
                vendorId: d['fields']['vendorId']['stringValue'],
                vendorName: d['fields']['vendorName']['stringValue'],
              ));
            }

            //updating data in hive
            var box = Hive.box('bitpro_app');
            await box.put('Merchandise Vendors',
                {for (var v in vendorDataLst) v.docId: v.toMap()});

            return vendorDataLst;
          } else if (response.statusCode == 401 &&
              body['error']['message'] ==
                  'Missing or invalid authentication.') {
            await FirebaseService(context: context).resetIdToken();

            return await fetchAllVendorsData();
          } else {
            showToast(body['error']['message'], context);
          }
        }
      } catch (e) {
        //updating fetch error status
        print('vendor fetch error : ${e.toString()}');
        var box = Hive.box('bitpro_app');
        var d = await box.get('FbFetchErrorStatus') ?? {};
        d['isMerchandiseVendorsDataUpdate'] = false;
        await box.put('FbFetchErrorStatus', d);
      }
    }

    //Hive Fetch : On Fb Error or Backend setup skipted
    List<VendorData> vendorLst =
        await HiveVendorDbService().fetchAllVendorsData();

    return vendorLst;
  }
}
