import 'package:hive/hive.dart';
import 'package:bitpro_hive/model/vendor_payment_data.dart';

class HiveVendorPaymentDbService {
  Future addVendorPaymentData(
      DateTime createdDate,
      String documentNo,
      String docId,
      String vendorId,
      String paymentType,
      double amount,
      String comment) async {
    var box = Hive.box('bitpro_app');

    Map vendors = box.get('Merchandise Vendors Payments') ?? {};

    VendorPaymentData vendorPaymentData = VendorPaymentData(
        documentNo: documentNo,
        docId: docId,
        vendorId: vendorId,
        createdDate: createdDate,
        amount: amount,
        comment: comment,
        paymentType: paymentType);

    String dId = vendorPaymentData.docId;

    vendors[dId] = vendorPaymentData.toMap();
    await box.put('Merchandise Vendors Payments', vendors);
  }

  Future<List<VendorPaymentData>> fetchAllVendorsPaymentData() async {
    var box = Hive.box('bitpro_app');
    Map? vendorPaymentData = box.get('Merchandise Vendors Payments');
    if (vendorPaymentData == null) return [];
    return vendorPaymentData.keys.map((k) {
      var ud = vendorPaymentData[k];

      return VendorPaymentData.fromMap(ud);
    }).toList();
  }
}
