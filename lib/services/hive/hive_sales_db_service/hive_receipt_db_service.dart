import 'package:hive/hive.dart';
import 'package:bitpro_hive/model/inventory_data.dart';
import 'package:bitpro_hive/model/receipt/db_receipt_data.dart';

class HiveReceiptDbService {
  addReceipt(
      {required DbReceiptData dbReceiptData,
      required List<InventoryData> allInventoryDataLst}) async {
    var box = Hive.box('bitpro_app');
    //updating inventory on hand quantity
    for (var v in dbReceiptData.selectedItems) {
      int i = allInventoryDataLst.indexWhere((e) => e.barcode == v['barcode']);
      if (i != -1) {
        InventoryData inventoryData = allInventoryDataLst.elementAt(i);
        //old ohQty of selected store
        int oldOhQty = int.tryParse(inventoryData
                .ohQtyForDifferentStores[dbReceiptData.selectedStoreDocId]
                .toString()) ??
            0;

        int newOhQty = dbReceiptData.receiptType == 'Regular'
            ? oldOhQty - int.parse(v['qty'])
            : oldOhQty + int.parse(v['qty']);

        //updating oh quantity
        inventoryData
                .ohQtyForDifferentStores[dbReceiptData.selectedStoreDocId] =
            newOhQty.toString();

        //saving the inventory data
        Map merchandisInventory = box.get('Merchandise Inventory') ?? {};
        merchandisInventory[inventoryData.docId] = inventoryData.toMap();
        await box.put('Merchandise Inventory', merchandisInventory);
      }
    }

    String dId = dbReceiptData.docId;
    Map salesReceipts = box.get('Sale Receipts') ?? {};
    salesReceipts[dId] = dbReceiptData.toMap();

    await box.put('Sale Receipts', salesReceipts);
  }

  Future<List<DbReceiptData>> fetchAllReceiptData() async {
    var box = Hive.box('bitpro_app');
    Map? salesReceipts = box.get('Sale Receipts');

    if (salesReceipts == null) return [];

    return salesReceipts.values.map((v) {
      return DbReceiptData.fromMap(v);
    }).toList();
  }
}
