import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bitpro_hive/model/inventory_data.dart';
import 'package:bitpro_hive/shared/toast.dart';

import '../hive_user_db_service.dart';

class HiveInventoryDbService {
  Future addEditInventoryData(
      {String? itemCode,
      String? selectedVendorId,
      String? productName,
      String? selectedDepartmentId,
      String? cost,
      String? description,
      String? price,
      String? margin,
      String? priceWT,
      File? productImg,
      required DateTime createdDate,
      required String createdBy,
      String? docId,
      String? barcode,
      Map? ohQtyForDifferentStores,
      String? proImgUrl,
      bool? productPriceCanChange}) async {
    var box = Hive.box('bitpro_app');

    Map merchandiseInventory = box.get('Merchandise Inventory') ?? {};

    String productImgUrl = productImg != null
        ? await uploadImage(
            file: productImg, fileName: docId ?? getRandomString(20))
        : proImgUrl ?? '';
    InventoryData inventoryData = InventoryData(
        docId: docId ?? '',
        itemCode: itemCode ?? "",
        selectedVendorId: selectedVendorId ?? '',
        productName: productName ?? '',
        selectedDepartmentId: selectedDepartmentId ?? '',
        cost: cost ?? '0',
        description: description ?? '',
        price: price ?? '0',
        margin: margin ?? '',
        priceWT: priceWT ?? '',
        productImg: productImgUrl,
        barcode: barcode ?? '',
        createdDate: createdDate,
        createdBy: createdBy,
        productPriceCanChange: productPriceCanChange ?? false,
        ohQtyForDifferentStores: ohQtyForDifferentStores ?? {}
        // ohQty: ohQty ?? '0'
        );

    String dId = inventoryData.docId;
    merchandiseInventory[dId] = inventoryData.toMap();
    await box.put('Merchandise Inventory', merchandiseInventory);
  }

  updateInventoryOhQuantity(
      Map<String, int> excelData, BuildContext context) async {
    var box = Hive.box('bitpro_app');

    Map merchandiseInventory = box.get('Merchandise Inventory') ?? {};

    for (var d in excelData.keys) {
      merchandiseInventory[d]['ohQty'] = excelData[d].toString();
    }

    await box.put('Merchandise Inventory', merchandiseInventory);
    showToast('Data updated successfully', context);
  }

  Future<String> uploadImage(
      {required File file, required String fileName}) async {
    var p =
        await getApplicationSupportDirectory(); // C:\Users\team\AppData\Roaming\com.example\bitpro_hive

    File imgDirectory =
        File('${p.path}/images/merchandise_inventory/$fileName.png');

    try {
      await imgDirectory.create(recursive: true);
    } catch (e) {}

    await file.copy(imgDirectory.path);

    return imgDirectory.path;
  }

  Future<List<InventoryData>> fetchAllInventoryData() async {
    var box = Hive.box('bitpro_app');
    Map? merchandiseInventory = box.get('Merchandise Inventory');
    // box.delete('Merchandise Inventory');
    if (merchandiseInventory == null) return [];
    // print(merchandiseInventory);
    return merchandiseInventory.keys.map((k) {
      var ud = merchandiseInventory[k];

      return InventoryData.fromMap(ud);
    }).toList();
  }
}
