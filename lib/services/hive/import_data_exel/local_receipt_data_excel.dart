import 'package:excel/excel.dart';
import 'package:bitpro_hive/model/inventory_data.dart';
import 'package:bitpro_hive/model/receipt/local_receipt_data.dart';

Map<String, dynamic> localReceiptDataFromExcel(
    Excel excel, List<InventoryData> inventorylst) {
  int? barcodeIndex;
  int? qtyIndex;

  int? priceWtIndex;

  List<LocalReceiptData> localVoucherDataLst = [];

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

              String priceWt =
                  priceWtIndex == null || row.elementAt(priceWtIndex) == null
                      ? inventoryData.priceWT
                      : row.elementAt(priceWtIndex)!.value.toString();
              String qty = qtyIndex == null || row.elementAt(qtyIndex) == null
                  ? '1'
                  : row.elementAt(qtyIndex)!.value.toString();
              localVoucherDataLst.add(LocalReceiptData(
                cost: inventoryData.cost,
                barcode: inventoryData.barcode,
                total: (double.parse(priceWt) * double.parse(qty)).toString(),
                orgPrice: priceWt,
                discountValue: '0',
                discountPercentage: '0',
                priceWt: priceWt,
                qty: qty,
                itemCode: inventoryData.itemCode,
                productName: inventoryData.productName,
                // price: inventoryData.price
              ));
            }
          }
        }
      }
    }
  }

  return {'dublicate': dublicate, 'localVoucherDataLst': localVoucherDataLst};
}
