


import 'package:excel/excel.dart';
import 'package:bitpro_hive/model/inventory_data.dart';

import '../../../model/voucher/local_voucher_data.dart';

Map<String, dynamic> localVoucherDataFromExcel(
    Excel excel, List<InventoryData> inventorylst) {
  int? barcodeIndex;
  int? qtyIndex;
  int? costIndex;
  int? priceWtIndex;

  List<LocalVoucherData> localVoucherDataLst = [];

  int dublicate = 0;

  for (var table in excel.tables.keys) {
    for (int j = 0; j < excel.tables[table]!.rows.length; j++) {
      var row = excel.tables[table]!.rows.elementAt(j);
      if (j == 0) {
        for (int i = 0; i < row.length; i++) {
          if (row.elementAt(i) != null) {
            var d = row.elementAt(i)!.value.toString().toLowerCase();

            switch (d) {
              case 'barcode':
                barcodeIndex = i;
                break;
              case 'qty':
                qtyIndex = i;
                break;
              case 'cost':
                costIndex = i;
                break;
              case 'price':
                priceWtIndex = i;
                break;
            }
          }
        }
      } else {
        // print(barcodeIndex);
        // print(qtyIndex);
        // print(costIndex);
        // print(priceWtIndex);

        if (barcodeIndex != null && row.elementAt(barcodeIndex) != null) {
          if (localVoucherDataLst.indexWhere((ele) =>
                  ele.barcode ==
                  row.elementAt(barcodeIndex!)!.value.toString()) !=
              -1) {
            dublicate++;
          } else {
            int i = inventorylst.indexWhere((ele) =>
                ele.barcode == row.elementAt(barcodeIndex!)!.value.toString());
            if (i != -1) {
              InventoryData inventoryData = inventorylst.elementAt(i);
              String cost =
                  costIndex == null || row.elementAt(costIndex) == null
                      ? inventoryData.cost
                      : row.elementAt(costIndex)!.value.toString();
              String priceWt =
                  priceWtIndex == null || row.elementAt(priceWtIndex) == null
                      ? inventoryData.priceWT
                      : row.elementAt(priceWtIndex)!.value.toString();
              String qty = qtyIndex == null || row.elementAt(qtyIndex) == null
                  ? '1'
                  : row.elementAt(qtyIndex)!.value.toString();
              localVoucherDataLst.add(LocalVoucherData(
                barcode: inventoryData.barcode,
                price: inventoryData.price,
                priceWt: priceWt,
                cost: cost,
                qty: qty,
                extCost: (double.parse(cost) * double.parse(qty)).toString(),
                itemCode: inventoryData.itemCode,
                productName: inventoryData.productName,
              ));
            }
          }
        }
      }
    }
  }

  return {'dublicate': dublicate, 'localVoucherDataLst': localVoucherDataLst};
}
