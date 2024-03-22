import 'package:hive/hive.dart';
import 'package:bitpro_hive/model/vendor_data.dart';

class HiveVendorDbService {
  Future addVendorData(
      DateTime createdDate,
      String? docId,
      String createdBy,
      String? vendorName,
      String? emailAddress,
      String? vendorId,
      String? address1,
      String? phone1,
      String? address2,
      String? phone2,
      String? vatNumber,
      String? openingBalance) async {
    var box = Hive.box('bitpro_app');

    Map vendors = box.get('Merchandise Vendors') ?? {};

    VendorData vendorData = VendorData(
        docId: docId ?? '',
        vendorName: vendorName ?? '',
        emailAddress: emailAddress ?? '',
        vendorId: vendorId ?? '',
        address1: address1 ?? '',
        phone1: phone1 ?? '',
        address2: address2 ?? '',
        phone2: phone2 ?? '',
        vatNumber: vatNumber ?? '',
        createdDate: createdDate,
        createdBy: createdBy,
        openingBalance: openingBalance ?? '0');

    String dId = vendorData.docId;

    vendors[dId] = vendorData.toMap();
    await box.put('Merchandise Vendors', vendors);
  }

  Future<List<VendorData>> fetchAllVendorsData() async {
    var box = Hive.box('bitpro_app');
    Map? vendors = box.get('Merchandise Vendors');
    if (vendors == null) return [];

    return vendors.keys.map((k) {
      var ud = vendors[k];

      return VendorData.fromMap(ud);
    }).toList();
  }
}
