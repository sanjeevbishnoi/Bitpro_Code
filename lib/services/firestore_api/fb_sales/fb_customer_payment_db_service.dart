import 'dart:convert';
import 'package:bitpro_hive/services/hive/hive_sales_db_service/hive_customer_payment_db_service.dart';
import 'package:bitpro_hive/shared/toast.dart';
import 'package:bitpro_hive/wrapper.dart';
import 'package:http/http.dart' as http;
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:bitpro_hive/model/customer_payment_data.dart';

class FbCustomerPaymentDbService {
  final String collectionName = 'Sales Customer Payments Data';
  final BuildContext context;
  FbCustomerPaymentDbService({
    required this.context,
  });

  Future addCustomerPaymentData(List<CustomerPaymentData> customerPaymentData,
      {bool onlyFb = false}) async {
    if (onlyFb == false) {
      //if backend setup is skipped then add data in hive

      for (var d in customerPaymentData) {
        await HiveCustomerPaymentDbService().addCustomerPaymentData(
            d.createdDate,
            d.documentNo,
            d.docId,
            d.customerId,
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
        for (CustomerPaymentData c in customerPaymentData) {
          var url = Uri.parse(
            '$kBaseUrl/$collectionName/${c.docId}?key=$apiKey',
          );

          var response = await http.patch(url,
              body: jsonEncode({
                "fields": {
                  "createdDate": {"stringValue": c.createdDate.toString()},
                  "docId": {"stringValue": c.docId},
                  "customerId": {"stringValue": c.customerId},
                  "paymentType": {"stringValue": c.paymentType},
                  "amount": {"doubleValue": c.amount},
                  "comment": {"stringValue": c.comment},
                  "documentNo": {"stringValue": c.documentNo},
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

            return await addCustomerPaymentData(customerPaymentData);
          } else {
            showToast(body['error']['message'], context);
            return false;
          }
        }
      }
    } catch (e) {
      //updating add/udpate error status
      print('customer paytment add/update error : ${e.toString()}');
      var box = Hive.box('bitpro_app');
      var d = await box.get('FbAddUpdateErrorStatus') ?? {};
      d['isSalesCustomerPaymentsDataUpdate'] = false;
      await box.put('FbAddUpdateErrorStatus', d);
    }
  }

  Future<List<CustomerPaymentData>> fetchAllCustomerPaymentData() async {
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
            List<CustomerPaymentData> customerPaymentDataLst = [];

            for (var d in body['documents'] ?? []) {
              customerPaymentDataLst.add(CustomerPaymentData(
                docId: d['fields']['docId']['stringValue'],
                createdDate:
                    DateTime.parse(d['fields']['createdDate']['stringValue']),
                amount: double.tryParse(
                        d['fields']['amount']['doubleValue'].toString()) ??
                    0,
                comment: d['fields']['comment']['stringValue'],
                documentNo: d['fields']['documentNo']['stringValue'],
                paymentType: d['fields']['paymentType']['stringValue'],
                customerId: d['fields']['customerId']['stringValue'],
              ));
            }

            //updating data in hive
            var box = Hive.box('bitpro_app');
            await box.put('Sales Customer Payments Data',
                {for (var c in customerPaymentDataLst) c.docId: c.toMap()});

            return customerPaymentDataLst;
          } else if (response.statusCode == 401 &&
              body['error']['message'] ==
                  'Missing or invalid authentication.') {
            await FirebaseService(context: context).resetIdToken();

            return await fetchAllCustomerPaymentData();
          } else {
            showToast(body['error']['message'], context);
          }
        }
      } catch (e) {
        //updating fetch error status
        print('customer payment fetch error : ${e.toString()}');
        var box = Hive.box('bitpro_app');
        var d = await box.get('FbFetchErrorStatus') ?? {};
        d['isSalesCustomerPaymentsDataUpdate'] = false;
        await box.put('FbFetchErrorStatus', d);
      }
    }

    //Hive Fetch : On Fb Error or Backend setup skipted
    List<CustomerPaymentData> customerDataLst =
        await HiveCustomerPaymentDbService().fetchAllCustomerPaymentData();

    return customerDataLst;
  }
}
