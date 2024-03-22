import 'dart:convert';

import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_sales_db_service/hive_customer_db_service.dart';
import 'package:bitpro_hive/shared/toast.dart';
import 'package:bitpro_hive/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:bitpro_hive/model/customer_data.dart';
import 'package:http/http.dart' as http;

class FbCustomerDbService {
  final String collectionName = 'Sales Customer Data';
  final BuildContext context;
  FbCustomerDbService({
    required this.context,
  });
  Future addCustomerData(List<CustomerData> customerDataLst,
      {bool onlyFb = false}) async {
    if (onlyFb == false) {
      //if backend setup is skipped then add data in hive

      for (var d in customerDataLst) {
        await HiveCustomerDbService().addCustomerData(d);
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
        for (CustomerData cus in customerDataLst) {
          var url = Uri.parse(
            '$kBaseUrl/$collectionName/${cus.docId}?key=$apiKey',
          );

          var response = await http.patch(url,
              body: jsonEncode({
                "fields": {
                  "createdBy": {"stringValue": cus.createdBy},
                  "createdDate": {"stringValue": cus.createdDate.toString()},
                  "docId": {"stringValue": cus.docId},
                  "customerId": {"stringValue": cus.customerId},
                  "customerName": {"stringValue": cus.customerName},
                  "address1": {"stringValue": cus.address1},
                  "address2": {"stringValue": cus.address2},
                  "phone1": {"stringValue": cus.phone1},
                  "phone2": {"stringValue": cus.phone2},
                  "email": {"stringValue": cus.email},
                  "vatNo": {"stringValue": cus.vatNo},
                  "companyName": {"stringValue": cus.companyName},
                  "openingBalance": {"stringValue": cus.openingBalance},
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

            return await addCustomerData(customerDataLst);
          } else {
            showToast(body['error']['message'], context);
            return false;
          }
        }
      }
    } catch (e) {
      //updating add/update error status
      print('customer add/update error : ${e.toString()}');
      var box = Hive.box('bitpro_app');
      var d = await box.get('FbAddUpdateErrorStatus') ?? {};
      d['isSalesCustomerDataUpdate'] = false;
      await box.put('FbAddUpdateErrorStatus', d);
    }
  }

  Future<List<CustomerData>> fetchAllCustomersData() async {
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
            List<CustomerData> customerDataLst = [];

            for (var d in body['documents'] ?? []) {
              customerDataLst.add(CustomerData(
                docId: d['fields']['docId']['stringValue'],
                createdDate:
                    DateTime.parse(d['fields']['createdDate']['stringValue']),
                createdBy: d['fields']['createdBy']['stringValue'],
                address1: d['fields']['address1']['stringValue'],
                address2: d['fields']['address2']['stringValue'],
                companyName: d['fields']['companyName']['stringValue'],
                customerId: d['fields']['customerId']['stringValue'],
                customerName: d['fields']['customerName']['stringValue'],
                email: d['fields']['email']['stringValue'],
                openingBalance: d['fields']['openingBalance']['stringValue'],
                phone1: d['fields']['phone1']['stringValue'],
                phone2: d['fields']['phone2']['stringValue'],
                vatNo: d['fields']['vatNo']['stringValue'],
              ));
            }

            //updating data in hive
            var box = Hive.box('bitpro_app');
            await box.put('Sales Customer Data',
                {for (var c in customerDataLst) c.docId: c.toMap()});

            return customerDataLst;
          } else if (response.statusCode == 401 &&
              body['error']['message'] ==
                  'Missing or invalid authentication.') {
            await FirebaseService(context: context).resetIdToken();

            return await fetchAllCustomersData();
          } else {
            showToast(body['error']['message'], context);
          }
        }
      } catch (e) {
        //updating fetch error status
        print('customer fetch error : ${e.toString()}');
        var box = Hive.box('bitpro_app');
        var d = await box.get('FbFetchErrorStatus') ?? {};
        d['isSalesCustomerDataUpdate'] = false;
        await box.put('FbFetchErrorStatus', d);
      }
    }

    //Hive Fetch : On Fb Error or Backend setup skipted
    List<CustomerData> customerDataLst =
        await HiveCustomerDbService().fetchAllCustomersData();

    return customerDataLst;
  }
}
