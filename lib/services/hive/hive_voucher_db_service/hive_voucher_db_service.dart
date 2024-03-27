import 'package:hive/hive.dart';
import 'package:bitpro_hive/model/voucher/db_voucher_data.dart';
import 'package:bitpro_hive/model/inventory_data.dart';

class HiveVoucherDbService {
  addVoucher(
      {required DbVoucherData voucherData,
      required List<InventoryData> allInventoryDataLst}) async {
    var box = Hive.box('bitpro_app');

    for (var v in voucherData.selectedItems) {
      int i = allInventoryDataLst.indexWhere((e) => e.barcode == v['barcode']);
      if (i != -1) {
        //old ohQty of selected store
        int oldOhQty = int.tryParse(
                (allInventoryDataLst.elementAt(i).ohQtyForDifferentStores[
                            voucherData.selectedStoreDocId] ??
                        0)
                    .toString()) ??
            0;

        int newOhQty = voucherData.voucherType == 'Regular'
            ? oldOhQty + int.parse(v['qty'])
            : oldOhQty - int.parse(v['qty']);
        // int ohQty = voucherData.voucherType == 'Regular'
        //     ? int.parse(allInventoryDataLst.elementAt(i).ohQty) +
        //         int.parse(v['qty'])
        //     : int.parse(allInventoryDataLst.elementAt(i).ohQty) -
        //         int.parse(v['qty']);

        InventoryData d = allInventoryDataLst.elementAt(i);
        // d.ohQty = ohQty.toString();
        //updating oh quantity
        allInventoryDataLst
                .elementAt(i)
                .ohQtyForDifferentStores[voucherData.selectedStoreDocId] =
            newOhQty.toString();
        d.cost = v['cost'].toString();
        d.price = v['price'].toString();
        d.priceWT = v['priceWt'].toString();

        String dId = allInventoryDataLst.elementAt(i).docId;
        Map merchandisInventory = box.get('Merchandise Inventory') ?? {};
        merchandisInventory[dId] = d.toMap();
        await box.put('Merchandise Inventory', merchandisInventory);
      }
    }

    String dId = voucherData.docId;
    Map purchaseVoucher = box.get('Purchase Voucher') ?? {};
    purchaseVoucher[dId] = voucherData.toMap();

    await box.put('Purchase Voucher', purchaseVoucher);
  }

  Future<List<DbVoucherData>> fetchAllVoucherData() async {
    var box = Hive.box('bitpro_app');
    Map? purchaseVoucher = box.get('Purchase Voucher');
    if (purchaseVoucher == null) return [];

    return purchaseVoucher.values.map((v) {
      return DbVoucherData.fromMap(v);
    }).toList();
  }
}
