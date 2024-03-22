import 'dart:convert';

import 'package:bitpro_hive/model/receipt/local_receipt_data.dart';
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_merchandise/fb_inventory_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_sales_db_service/hive_receipt_db_service.dart';
import 'package:bitpro_hive/shared/toast.dart';
import 'package:bitpro_hive/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:bitpro_hive/model/inventory_data.dart';
import 'package:bitpro_hive/model/receipt/db_receipt_data.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class FbReceiptDbService {
  final String collectionName = 'Sale Receipts';
  final BuildContext context;
  FbReceiptDbService({
    required this.context,
  });

  addUpdateReceipt(
      {required List<DbReceiptData> receiptDataLst,
      required List<InventoryData> allInventoryDataLst,
      bool onlyFb = false}) async {
    if (onlyFb == false) {
      //if backend setup is skipped then add data in hive

      for (var k in receiptDataLst) {
        print('k.receiptNo');
        print(k.receiptNo);
        await HiveReceiptDbService().addReceipt(
            allInventoryDataLst: allInventoryDataLst, dbReceiptData: k);
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
        for (DbReceiptData k in receiptDataLst) {
          //updating inventory on hand quantity
          for (var v in k.selectedItems) {
            int i = allInventoryDataLst
                .indexWhere((e) => e.barcode == v['barcode']);
            if (i != -1) {
              InventoryData inventoryData = allInventoryDataLst.elementAt(i);
              //old ohQty of selected store
              int oldOhQty = int.tryParse(inventoryData
                      .ohQtyForDifferentStores[k.selectedStoreDocId]
                      .toString()) ??
                  0;

              int newOhQty = k.receiptType == 'Regular'
                  ? oldOhQty - int.parse(v['qty'])
                  : oldOhQty + int.parse(v['qty']);
              print('newOhQty $newOhQty');
              print('oldOhQty $oldOhQty');

              //updating oh quantity
              inventoryData.ohQtyForDifferentStores[k.selectedStoreDocId] =
                  newOhQty.toString();

              //updating inventory data, with new ohQty of selected store
              await FbInventoryDbService(context: context)
                  .addUpdateInventoryData(
                      inventoryDataLst: [allInventoryDataLst.elementAt(i)]);
            }
          }
          var url = Uri.parse(
            '$kBaseUrl/$collectionName/${k.docId}?key=$apiKey',
          );

          var response = await http.patch(url,
              body: jsonEncode({
                "fields": {
                  "createdBy": {"stringValue": k.createdBy},
                  "createdDate": {"stringValue": k.createdDate.toString()},
                  "docId": {"stringValue": k.docId},
                  "receiptNo": {"stringValue": k.receiptNo},
                  "subTotal": {"stringValue": k.subTotal},
                  "selectedCustomerID": {"stringValue": k.selectedCustomerID},
                  "discountPercentage": {"stringValue": k.discountPercentage},
                  "discountValue": {"stringValue": k.discountValue},
                  "totalQty": {"stringValue": k.totalQty},
                  "selectedItems": {
                    "arrayValue": {
                      "values": [
                        for (var item in k.selectedItems)
                          {
                            "mapValue": {
                              "fields": {
                                'barcode': {"stringValue": item['barcode']},
                                'itemCode': {"stringValue": item['itemCode']},
                                'productName': {
                                  "stringValue": item['productName']
                                },
                                'qty': {"stringValue": item['qty']},
                                'orgPrice': {"stringValue": item['orgPrice']},
                                'discountValue': {
                                  "stringValue": item['discountValue']
                                },
                                'discountPercentage': {
                                  "stringValue": item['discountPercentage']
                                },
                                'priceWt': {"stringValue": item['priceWt']},
                                'total': {"stringValue": item['total']},
                                'cost': {"stringValue": item['cost']}
                              }
                            }
                          }
                      ]
                    }
                  },
                  "taxPer": {"stringValue": k.taxPer},
                  "taxValue": {"stringValue": k.taxValue},
                  "tendor": {
                    "mapValue": {
                      "fields": {
                        "cash": {"stringValue": k.tendor.cash},
                        "credit": {"stringValue": k.tendor.credit},
                        "creditCard": {"stringValue": k.tendor.creditCard},
                        "remainingAmount": {
                          "stringValue": k.tendor.remainingAmount
                        },
                        "balance": {"stringValue": k.tendor.balance},
                      }
                    }
                  },
                  "receiptType": {"stringValue": k.receiptType},
                  "referenceNo": {"stringValue": k.referenceNo},
                  "selectedStoreDocId": {"stringValue": k.selectedStoreDocId},
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

            return await addUpdateReceipt(
                receiptDataLst: receiptDataLst,
                allInventoryDataLst: allInventoryDataLst);
          } else {
            showToast(body['error']['message'], context);
            return false;
          }
        }
      }
    } catch (e) {
      //updating add/update error status
      print('receipt add/update error : ${e.toString()}');
      var box = Hive.box('bitpro_app');
      var d = await box.get('FbAddUpdateErrorStatus') ?? {};
      d['isSaleReceiptsDataUpdate'] = false;
      await box.put('FbAddUpdateErrorStatus', d);
    }
  }

  Future<List<DbReceiptData>> fetchAllReceiptData() async {
    if (globalIsFbSetupSkipted == false) {
      //Firebase Fetch
      // try {
      Map<String, String>? res =
          await FirebaseService(context: context).getFirebaseBaseUrl();

      if (res != null) {
        String kBaseUrl = res['kBaseUrl']!;
        String apiKey = res['apiKey']!;
        String idToken = res['idToken']!;
        var url = Uri.parse(
          '$kBaseUrl/$collectionName?key=$apiKey',
        );

        var response =
            await http.get(url, headers: {'Authorization': 'Bearer $idToken'});

        var body = jsonDecode(response.body);

        if (response.statusCode == 200) {
          List<DbReceiptData> receiptDataLst = [];

          for (var d in body['documents'] ?? []) {
            receiptDataLst.add(DbReceiptData(
              docId: d['fields']['docId']['stringValue'],
              createdDate:
                  DateTime.parse(d['fields']['createdDate']['stringValue']),
              createdBy: d['fields']['createdBy']['stringValue'],
              receiptNo: d['fields']['receiptNo']['stringValue'],
              subTotal: d['fields']['subTotal']['stringValue'],
              selectedCustomerID: d['fields']['selectedCustomerID']
                  ['stringValue'],
              discountPercentage: d['fields']['discountPercentage']
                  ['stringValue'],
              discountValue: d['fields']['discountValue']['stringValue'],
              totalQty: d['fields']['totalQty']['stringValue'],
              selectedItems: d['fields']['selectedItems']['arrayValue']
                      ['values']
                  .map((e) => {
                        'barcode': e['mapValue']['fields']['barcode']
                            ['stringValue'],
                        'itemCode': e['mapValue']['fields']['itemCode']
                            ['stringValue'],
                        'productName': e['mapValue']['fields']['productName']
                            ['stringValue'],
                        'qty': e['mapValue']['fields']['qty']['stringValue'],
                        'orgPrice': e['mapValue']['fields']['orgPrice']
                            ['stringValue'],
                        'discountValue': e['mapValue']['fields']
                            ['discountValue']['stringValue'],
                        'discountPercentage': e['mapValue']['fields']
                            ['discountPercentage']['stringValue'],
                        'priceWt': e['mapValue']['fields']['priceWt']
                            ['stringValue'],
                        'total': e['mapValue']['fields']['total']
                            ['stringValue'],
                        'cost': e['mapValue']['fields']['cost']['stringValue'],
                      })
                  .toList(),
              taxPer: d['fields']['taxPer']['stringValue'],
              taxValue: d['fields']['taxValue']['stringValue'],
              tendor: ReceiptTendor(
                cash: d['fields']['tendor']['mapValue']['fields']['cash']
                    ['stringValue'],
                credit: d['fields']['tendor']['mapValue']['fields']['credit']
                    ['stringValue'],
                creditCard: d['fields']['tendor']['mapValue']['fields']
                    ['creditCard']['stringValue'],
                remainingAmount: d['fields']['tendor']['mapValue']['fields']
                    ['remainingAmount']['stringValue'],
                balance: d['fields']['tendor']['mapValue']['fields']['balance']
                    ['stringValue'],
              ),
              receiptType: d['fields']['receiptType']['stringValue'],
              referenceNo: d['fields']['referenceNo']['stringValue'],
              selectedStoreDocId: d['fields']['selectedStoreDocId']
                  ['stringValue'],
            ));
          }

          //updating data in hive
          var box = Hive.box('bitpro_app');
          await box.put('Sale Receipts',
              {for (var r in receiptDataLst) r.docId: r.toMap()});

          return receiptDataLst;
        } else if (response.statusCode == 401 &&
            body['error']['message'] == 'Missing or invalid authentication.') {
          await FirebaseService(context: context).resetIdToken();

          return await fetchAllReceiptData();
        } else {
          showToast(body['error']['message'], context);
        }
      }
      // } catch (e) {
      //   //updating fetch error status
      //   print('receipt fetch error : ${e.toString()}');
      //   var box = Hive.box('bitpro_app');
      //   var d = await box.get('FbFetchErrorStatus') ?? {};
      //   d['isSaleReceiptsDataUpdate'] = false;
      //   await box.put('FbFetchErrorStatus', d);
      // }
    }

    //Hive Fetch : On Fb Error or Backend setup skipted
    List<DbReceiptData> receiptDataLst =
        await HiveReceiptDbService().fetchAllReceiptData();

    return receiptDataLst;
  }
}
