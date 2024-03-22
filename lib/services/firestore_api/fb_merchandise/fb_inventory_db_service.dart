import 'dart:convert';
import 'dart:io';
import 'package:bitpro_hive/model/department_data.dart';
import 'package:bitpro_hive/model/vendor_data.dart';
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_merchandise_db_service/inventory_db_service.dart';
import 'package:bitpro_hive/wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:bitpro_hive/model/inventory_data.dart';
import 'package:bitpro_hive/shared/toast.dart';
import 'package:http/http.dart' as http;

class FbInventoryDbService {
  final String collectionName = 'Merchandise Inventory';
  final BuildContext context;
  FbInventoryDbService({
    required this.context,
  });

  Future addUpdateInventoryData(
      {required List<InventoryData> inventoryDataLst,
      bool onlyFb = false}) async {
    if (onlyFb == false) {
      //if backend setup is skipped then add data in hive

      for (var d in inventoryDataLst) {
        await HiveInventoryDbService().addEditInventoryData(
            createdDate: d.createdDate,
            createdBy: d.createdBy,
            barcode: d.barcode,
            cost: d.cost,
            description: d.description,
            docId: d.docId,
            itemCode: d.itemCode,
            margin: d.margin,
            ohQtyForDifferentStores: d.ohQtyForDifferentStores,
            price: d.price,
            priceWT: d.priceWT,
            proImgUrl: d.productImg,
            // productImg:,
            productName: d.productName,
            productPriceCanChange: d.productPriceCanChange,
            selectedDepartmentId: d.selectedDepartmentId,
            selectedVendorId: d.selectedVendorId);
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
        for (InventoryData inv in inventoryDataLst) {
          var url = Uri.parse(
            '$kBaseUrl/$collectionName/${inv.docId}?key=$apiKey',
          );

          var response = await http.patch(url,
              body: jsonEncode({
                "fields": {
                  "docId": {"stringValue": inv.docId},
                  "itemCode": {"stringValue": inv.itemCode},
                  "selectedVendorId": {"stringValue": inv.selectedVendorId},
                  "productName": {"stringValue": inv.productName},
                  "selectedDepartmentId": {
                    "stringValue": inv.selectedDepartmentId
                  },
                  "cost": {"stringValue": inv.cost},
                  "description": {"stringValue": inv.description},
                  "price": {"stringValue": inv.price},
                  "margin": {"stringValue": inv.margin},
                  "priceWT": {"stringValue": inv.priceWT},
                  "productImg": {"stringValue": inv.productImg},
                  "barcode": {"stringValue": inv.barcode},
                  "createdDate": {"stringValue": inv.createdDate.toString()},
                  "createdBy": {"stringValue": inv.createdBy},
                  "ohQtyForDifferentStores": {
                    "mapValue": {
                      "fields": {
                        for (var k in inv.ohQtyForDifferentStores.keys)
                          k: {'integerValue': inv.ohQtyForDifferentStores[k]}
                      }
                    }
                  },
                  "productPriceCanChange": {
                    "booleanValue": inv.productPriceCanChange
                  },
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

            return await addUpdateInventoryData(
                inventoryDataLst: inventoryDataLst);
          } else {
            showToast(body['error']['message'], context);
            return false;
          }
        }
      }
    } catch (e) {
      //updating add/update error status
      print('inventory add/update error : ${e.toString()}');
      var box = Hive.box('bitpro_app');
      var d = await box.get('FbAddUpdateErrorStatus') ?? {};
      d['isMerchandiseInventoryDataUpdate'] = false;
      await box.put('FbAddUpdateErrorStatus', d);
    }
  }

  Future<List<InventoryData>> fetchAllInventoryData() async {
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
            List<InventoryData> inventoryDataLst = [];

            for (var d in body['documents'] ?? []) {
              Map ohQtyForDifferentStores = {
                if (d['fields']['ohQtyForDifferentStores']['mapValue']
                    .isNotEmpty)
                  for (var k in d['fields']['ohQtyForDifferentStores']
                          ['mapValue']['fields']
                      .keys)
                    k: d['fields']['ohQtyForDifferentStores']['mapValue']
                        ['fields'][k]['integerValue']
              };

              // print('ohQtyForDifferentStores');
              // print(d['fields']['ohQtyForDifferentStores']['mapValue']);
              // print(ohQtyForDifferentStores);

              inventoryDataLst.add(InventoryData(
                docId: d['fields']['docId']['stringValue'],
                itemCode: d['fields']['itemCode']['stringValue'],
                selectedVendorId: d['fields']['selectedVendorId']
                    ['stringValue'],
                productName: d['fields']['productName']['stringValue'],
                selectedDepartmentId: d['fields']['selectedDepartmentId']
                    ['stringValue'],
                cost: d['fields']['cost']['stringValue'],
                description: d['fields']['description']['stringValue'],
                price: d['fields']['price']['stringValue'],
                margin: d['fields']['margin']['stringValue'],
                priceWT: d['fields']['priceWT']['stringValue'],
                productImg: d['fields']['productImg']['stringValue'],
                barcode: d['fields']['barcode']['stringValue'],
                createdDate:
                    DateTime.parse(d['fields']['createdDate']['stringValue']),
                createdBy: d['fields']['createdBy']['stringValue'],
                ohQtyForDifferentStores: ohQtyForDifferentStores,
                productPriceCanChange: d['fields']['productPriceCanChange']
                    ['booleanValue'],
              ));
            }

            //updating data in hive
            var box = Hive.box('bitpro_app');

            await box.put('Merchandise Inventory',
                {for (var i in inventoryDataLst) i.docId: i.toMap()});

            return inventoryDataLst;
          } else if (response.statusCode == 401 &&
              body['error']['message'] ==
                  'Missing or invalid authentication.') {
            await FirebaseService(context: context).resetIdToken();

            return await fetchAllInventoryData();
          } else {
            showToast(body['error']['message'], context);
          }
        }
      } catch (e) {
        //updating fetch error status
        print('inventory fetch error : ${e.toString()}');
        var box = Hive.box('bitpro_app');
        var d = await box.get('FbFetchErrorStatus') ?? {};
        d['isMerchandiseInventoryDataUpdate'] = false;
        await box.put('FbFetchErrorStatus', d);
      }
    }

    //Hive Fetch : On Fb Error or Backend setup skipted
    List<InventoryData> inventoryDataLst =
        await HiveInventoryDbService().fetchAllInventoryData();

    return inventoryDataLst;
  }
}
