import 'dart:convert';
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_merchandise_db_service/vendor_payment_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_merchandise_db_service/vendors_db_service.dart';
import 'package:bitpro_hive/shared/toast.dart';
import 'package:bitpro_hive/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:bitpro_hive/model/vendor_payment_data.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class FbVendorPaymentDbService {
  final String collectionName = 'Merchandise Vendors Payments';
  final BuildContext context;
  FbVendorPaymentDbService({
    required this.context,
  });
  Future addVendorPaymentData(List<VendorPaymentData> vendorPaymentDataLst,
      {bool onlyFb = false}) async {
    if (onlyFb == false) {
      //if backend setup is skipped then add data in hive

      for (var d in vendorPaymentDataLst) {
        await HiveVendorPaymentDbService().addVendorPaymentData(
            d.createdDate,
            d.documentNo,
            d.docId,
            d.vendorId,
            d.paymentType,
            d.amount,
            d.comment);
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
        for (var v in vendorPaymentDataLst) {
          var url = Uri.parse(
            '$kBaseUrl/$collectionName/${v.docId}?key=$apiKey',
          );

          var response = await http.patch(url,
              body: jsonEncode({
                "fields": {
                  "docId": {"stringValue": v.docId},
                  "vendorId": {"stringValue": v.vendorId},
                  "paymentType": {"stringValue": v.paymentType},
                  "amount": {"doubleValue": v.amount.toString()},
                  "createdDate": {"stringValue": v.createdDate.toString()},
                  "comment": {"stringValue": v.comment},
                  "documentNo": {"stringValue": v.documentNo},
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

            return await addVendorPaymentData(vendorPaymentDataLst);
          } else {
            showToast(body['error']['message'], context);
            return false;
          }
        }
      }
    } catch (e) {
      //updating add/update error status
      print('vendor payment add/update error : ${e.toString()}');
      var box = Hive.box('bitpro_app');
      var d = await box.get('FbAddUpdateErrorStatus') ?? {};
      d['isMerchandiseVendorsPaymentsDataUpdate'] = false;
      await box.put('FbAddUpdateErrorStatus', d);
    }
  }

  Future<List<VendorPaymentData>> fetchAllVendorsPaymentData() async {
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
            List<VendorPaymentData> vendorPaymentDataLst = [];

            for (var d in body['documents'] ?? []) {
              vendorPaymentDataLst.add(VendorPaymentData(
                docId: d['fields']['docId']['stringValue'],
                createdDate:
                    DateTime.parse(d['fields']['createdDate']['stringValue']),
                amount: double.parse(
                    d['fields']['amount']['doubleValue'].toString()),
                comment: d['fields']['comment']['stringValue'],
                documentNo: d['fields']['documentNo']['stringValue'],
                paymentType: d['fields']['paymentType']['stringValue'],
                vendorId: d['fields']['vendorId']['stringValue'],
              ));
            }

            //updating data in hive
            var box = Hive.box('bitpro_app');
            await box.put('Merchandise Vendors Payments',
                {for (var v in vendorPaymentDataLst) v.docId: v.toMap()});

            return vendorPaymentDataLst;
          } else if (response.statusCode == 401 &&
              body['error']['message'] ==
                  'Missing or invalid authentication.') {
            await FirebaseService(context: context).resetIdToken();

            return await fetchAllVendorsPaymentData();
          } else {
            showToast(body['error']['message'], context);
          }
        }
      } catch (e) {
        //updating fetch error status
        print('vendor payment fetch error : ${e.toString()}');
        var box = Hive.box('bitpro_app');
        var d = await box.get('FbFetchErrorStatus') ?? {};
        d['isMerchandiseVendorsPaymentsDataUpdate'] = false;
        await box.put('FbFetchErrorStatus', d);
      }
    }

    //Hive Fetch : On Fb Error or Backend setup skipted
    List<VendorPaymentData> vendorPaymentDataLst =
        await HiveVendorPaymentDbService().fetchAllVendorsPaymentData();

    return vendorPaymentDataLst;
  }
}
