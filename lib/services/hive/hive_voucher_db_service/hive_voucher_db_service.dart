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
        // await FirebaseFirestore.instance
        //     .collection('Merchandise Inventory')
        //     .doc(allInventoryDataLst.elementAt(i).docId)
        //     .set({
        //   'itemCode': d.itemCode,
        //   'selectedVendorId': d.selectedVendorId,
        //   'productName': d.productName,
        //   'selectedDepartmentId': d.selectedDepartmentId,
        //   'cost': v['cost'].toString(),
        //   'description': d.description,
        //   'price': v['price'].toString(),
        //   'margin': d.margin,
        //   'priceWT': v['priceWt'].toString(),
        //   'productImgUrl': d.productImg,
        //   'createdDate': d.createdDate.toString(),
        //   'createdBy': d.createdBy,
        //   'barcode': d.barcode,
        //   'ohQty': ohQty.toString(),
        // });
      }
    }

    String dId = voucherData.docId;
    Map purchaseVoucher = box.get('Purchase Voucher') ?? {};
    purchaseVoucher[dId] = voucherData.toMap();

    await box.put('Purchase Voucher', purchaseVoucher);

    // await FirebaseFirestore.instance
    //     .collection('Purchase Voucher')
    //     .doc()
    //     .set(voucherData.toMap());
  }

  Future<List<DbVoucherData>> fetchAllVoucherData() async {
    var box = Hive.box('bitpro_app');
    Map? purchaseVoucher = box.get('Purchase Voucher');
    if (purchaseVoucher == null) return [];

    return purchaseVoucher.values.map((v) {
      return DbVoucherData.fromMap(v);
    }).toList();
    // var qs =
    //     await FirebaseFirestore.instance.collection('Purchase Voucher').get();

    // return qs.docs.map((d) {
    //   return DbVoucherData(
    //       createdDate:
    //           DateTime.fromMillisecondsSinceEpoch(d.get('createdDate')),
    //       selectedItems: d.get('selectedItems'),
    //       discountPercentage: d.get('discountPercentage'),
    //       discountValue: d.get('discountValue'),
    //       note: d.get('note'),
    //       tax: d.get('tax'),
    //       voucherNo: d.get('voucherNo'),
    //       type: d.get('type'),
    //       vendor: d.get('vendor'),
    //       qtyRecieved: d.get('qtyRecieved'),
    //       voucherTotal: d.get('voucherTotal'),
    //       purchaseInvoice: d.get('purchaseInvoice'),
    //       purchaseInvoiceDate: d.get('purchaseInvoiceDate'),
    //       createdBy: d.get('createdBy'));
    // }).toList();
  }
}
