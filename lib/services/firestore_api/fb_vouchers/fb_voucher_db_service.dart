import 'dart:convert';
import 'package:bitpro_hive/model/voucher/local_voucher_data.dart';
import 'package:bitpro_hive/services/hive/hive_voucher_db_service/hive_voucher_db_service.dart';
import 'package:bitpro_hive/wrapper.dart';
import 'package:http/http.dart' as http;
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/fb_merchandise/fb_inventory_db_service.dart';
import 'package:bitpro_hive/shared/toast.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:bitpro_hive/model/voucher/db_voucher_data.dart';
import 'package:bitpro_hive/model/inventory_data.dart';

class FbVoucherDbService {
  final String collectionName = 'Purchase Voucher';
  final BuildContext context;
  FbVoucherDbService({
    required this.context,
  });

  addUpdateVoucher(
      {required List<DbVoucherData> voucherDataLst,
      required List<InventoryData> allInventoryDataLst,
      bool onlyFb = false}) async {
    if (onlyFb == false) {
      //if backend setup is skipped then add data in hive
      for (var k in voucherDataLst) {
        await HiveVoucherDbService().addVoucher(
            allInventoryDataLst: allInventoryDataLst, voucherData: k);
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
        for (var voucher in voucherDataLst) {
          for (var selectedItem in voucher.selectedItems) {
            int i = allInventoryDataLst
                .indexWhere((e) => e.barcode == selectedItem['barcode']);
            if (i != -1) {
              InventoryData inventoryData = allInventoryDataLst.elementAt(i);
              //old ohQty of selected store
              int oldOhQty = int.tryParse(inventoryData
                      .ohQtyForDifferentStores[voucher.selectedStoreDocId]
                      .toString()) ??
                  0;

              int newOhQty = voucher.voucherType == 'Regular'
                  ? oldOhQty - int.parse(selectedItem['qty'])
                  : oldOhQty + int.parse(selectedItem['qty']);
              print('newOhQty $newOhQty');
              print('oldOhQty $oldOhQty');

              //updating oh quantity
              inventoryData
                      .ohQtyForDifferentStores[voucher.selectedStoreDocId] =
                  newOhQty.toString();

              //updating inventory data, with new ohQty of selected store
              await FbInventoryDbService(context: context)
                  .addUpdateInventoryData(
                      inventoryDataLst: [allInventoryDataLst.elementAt(i)]);
            }
          }

          var url = Uri.parse(
            '$kBaseUrl/$collectionName/${voucher.docId}?key=$apiKey',
          );

          var response = await http.patch(url,
              body: jsonEncode({
                "fields": {
                  "createdBy": {"stringValue": voucher.createdBy},
                  "createdDate": {
                    "stringValue": voucher.createdDate.toString()
                  },
                  "docId": {"stringValue": voucher.docId},
                  "voucherNo": {"stringValue": voucher.voucherNo},
                  "vendor": {"stringValue": voucher.vendor},
                  "qtyRecieved": {"stringValue": voucher.qtyRecieved},
                  "voucherTotal": {"stringValue": voucher.voucherTotal},
                  "selectedItems": {
                    "arrayValue": {
                      "values": [
                        for (var item in voucher.selectedItems)
                          {
                            "mapValue": {
                              "fields": {
                                'barcode': {"stringValue": item['barcode']},
                                'qty': {"stringValue": item['qty']},
                                'cost': {"stringValue": item['cost']},
                                'price': {"stringValue": item['price']},
                              }
                            }
                          }
                      ]
                    }
                  },
                  "tax": {"stringValue": voucher.tax},
                  "discountPercentage": {
                    "stringValue": voucher.discountPercentage
                  },
                  "discountValue": {"stringValue": voucher.discountValue},
                  "purchaseInvoice": {"stringValue": voucher.purchaseInvoice},
                  "purchaseInvoiceDate": {
                    "stringValue": voucher.purchaseInvoiceDate
                  },
                  "note": {"stringValue": voucher.note},
                  "voucherType": {"stringValue": voucher.voucherType},
                  "selectedStoreDocId": {
                    "stringValue": voucher.selectedStoreDocId
                  },
                }
              }),
              headers: {'Authorization': 'Bearer $idToken'});

          var body = jsonDecode(response.body);

          if (response.statusCode == 200) {
            print('voucher added succesfully');
          } else if (response.statusCode == 401 &&
              body['error']['message'] ==
                  'Missing or invalid authentication.') {
            await FirebaseService(context: context).resetIdToken();

            return await addUpdateVoucher(
                voucherDataLst: voucherDataLst,
                allInventoryDataLst: allInventoryDataLst);
          } else {
            print(body['error']['message']);
            showToast(body['error']['message'], context);
            return false;
          }
        }
      }
    } catch (e) {
      //updating add/update error status
      print('voucher add/update error : ${e.toString()}');
      var box = Hive.box('bitpro_app');
      var d = await box.get('FbAddUpdateErrorStatus') ?? {};
      d['isPurchaseVoucherDataUpdate'] = false;
      await box.put('FbAddUpdateErrorStatus', d);
    }
  }

  Future<List<DbVoucherData>> fetchAllVoucherData() async {
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
            List<DbVoucherData> voucherDataLst = [];

            for (var d in body['documents'] ?? []) {
              List<dynamic> lst = d['fields']['selectedItems']['arrayValue']
                      ['values']
                  .map((e) => {
                        'barcode': e['mapValue']['fields']['barcode']
                            ['stringValue'],
                        'qty': e['mapValue']['fields']['qty']['stringValue'],
                        'cost': e['mapValue']['fields']['cost']['stringValue'],
                        'price': e['mapValue']['fields']['price']['stringValue']
                      })
                  .toList();
              voucherDataLst.add(DbVoucherData(
                docId: d['fields']['docId']['stringValue'],
                createdDate:
                    DateTime.parse(d['fields']['createdDate']['stringValue']),
                createdBy: d['fields']['createdBy']['stringValue'],
                discountPercentage: d['fields']['discountPercentage']
                    ['stringValue'],
                discountValue: d['fields']['discountValue']['stringValue'],
                selectedItems: lst,
                selectedStoreDocId: d['fields']['selectedStoreDocId']
                    ['stringValue'],
                note: d['fields']['note']['stringValue'],
                purchaseInvoice: d['fields']['purchaseInvoice']['stringValue'],
                purchaseInvoiceDate: d['fields']['purchaseInvoiceDate']
                    ['stringValue'],
                qtyRecieved: d['fields']['qtyRecieved']['stringValue'],
                tax: d['fields']['tax']['stringValue'],
                vendor: d['fields']['vendor']['stringValue'],
                voucherNo: d['fields']['voucherNo']['stringValue'],
                voucherTotal: d['fields']['voucherTotal']['stringValue'],
                voucherType: d['fields']['voucherType']['stringValue'],
              ));
            }

            //updating data in hive
            var box = Hive.box('bitpro_app');
            await box.put('Purchase Voucher',
                {for (var v in voucherDataLst) v.docId: v.toMap()});

            return voucherDataLst;
          } else if (response.statusCode == 401 &&
              body['error']['message'] ==
                  'Missing or invalid authentication.') {
            await FirebaseService(context: context).resetIdToken();

            return await fetchAllVoucherData();
          } else {
            showToast(body['error']['message'], context);
          }
        }
      } catch (e) {
        //updating fetch error status
        print('voucher fetch error : ${e.toString()}');
        var box = Hive.box('bitpro_app');
        var d = await box.get('FbFetchErrorStatus') ?? {};
        d['isPurchaseVoucherDataUpdate'] = false;
        await box.put('FbFetchErrorStatus', d);
      }
    }

    //Hive Fetch : On Fb Error or Backend setup skipted
    List<DbVoucherData> voucherDataLst =
        await HiveVoucherDbService().fetchAllVoucherData();

    return voucherDataLst;
  }
}
