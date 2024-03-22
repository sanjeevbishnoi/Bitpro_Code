import 'package:bitpro_hive/model/department_data.dart';
import 'package:bitpro_hive/model/vendor_data.dart';
import 'package:bitpro_hive/widget/string_related/get_random_barcode_string.dart';
import 'package:excel/excel.dart';
import 'package:hive/hive.dart';
import 'package:bitpro_hive/home/purchase/purchase_page.dart';
import '../../../model/inventory_data.dart';

//inventory update quantity

Map<String, dynamic> inventoryUpdateQuantityFromExcel(
    Excel excel, List<InventoryData> oldInventorylst) {
  int? barcodeIndex;
  int? ohQtyIndex;

  // List<InventoryData> inventoryDataLst = [];
  int itemsfound = 0;
  int itemsNotFound = 0;

  Map<String, int> udpatedQuantityData = {};

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
              case 'quantity':
                ohQtyIndex = i;
                break;
            }
          }
        }
      } else if (barcodeIndex != null &&
          row.elementAt(barcodeIndex) != null &&
          ohQtyIndex != null &&
          row.elementAt(ohQtyIndex) != null) {
        String excelBarcode = row.elementAt(barcodeIndex)!.value.toString();
        int excelQuantity =
            int.tryParse(row.elementAt(ohQtyIndex)!.value.toString()) ?? 0;
        if (oldInventorylst.indexWhere((ele) => ele.barcode == excelBarcode) ==
            -1) {
          itemsNotFound++;
        } else {
          itemsfound++;

          String docId = oldInventorylst
              .elementAt(oldInventorylst
                  .indexWhere((ele) => ele.barcode == excelBarcode))
              .docId;
          udpatedQuantityData[docId] = excelQuantity;
        }
      }
    }
  }
  return {
    'itemsFound': itemsfound,
    'itemsNotFound': itemsNotFound,
    'udpatedQuantityData': udpatedQuantityData
  };
}

//inventory import
Map<String, dynamic> inventoryDataFromExcel(
    Excel excel,
    String createdBy,
    List<InventoryData> oldInventorylst,
    List<VendorData> allVendorDataLst,
    List<DepartmentData> allDepartmentDataLst) {
  // int? barcodeIndex;
  int? productNameIndex;
  int? costIndex;
  int? priceIndex;
  int? priceWtIndex;
  int? marginIndex;
  int? descriptionIndex;
  int? productImgIndex;
  int? departmentIdIndex;
  int? vendorIdIndex;

  List<InventoryData> inventoryDataLst = [];
  int dublicateInLst = 0;
  int dublicateInOldData = 0;
  int wrongVendorIdOrDepartmentId = 0;
  for (var table in excel.tables.keys) {
    for (int j = 0; j < excel.tables[table]!.rows.length; j++) {
      var row = excel.tables[table]!.rows.elementAt(j);
      if (j == 0) {
        for (int i = 0; i < row.length; i++) {
          if (row.elementAt(i) != null) {
            var d = row.elementAt(i)!.value.toString().toLowerCase();

            switch (d) {
              // case 'barcode':
              //   barcodeIndex = i;
              //   break;
              case 'productname':
                productNameIndex = i;
                break;
              case 'cost':
                costIndex = i;
                break;
              case 'price':
                priceIndex = i;
                break;
              case 'pricewt':
                priceWtIndex = i;
                break;
              case 'margin':
                marginIndex = i;
                break;
              case 'description':
                descriptionIndex = i;
                break;
              case 'productimgurl':
                productImgIndex = i;
                break;
              case 'vendorid':
                vendorIdIndex = i;
                break;
              case 'departmentid':
                departmentIdIndex = i;
                break;
            }
          }
        }
      } else if (productNameIndex != null &&
          row.elementAt(productNameIndex) != null &&
          vendorIdIndex != null &&
          row.elementAt(vendorIdIndex) != null &&
          departmentIdIndex != null &&
          row.elementAt(departmentIdIndex) != null) {
        if (allVendorDataLst.indexWhere((element) =>
                    element.vendorId ==
                    row.elementAt(vendorIdIndex!)!.value.toString()) ==
                -1 ||
            allDepartmentDataLst.indexWhere((element) =>
                    element.departmentId ==
                    row.elementAt(departmentIdIndex!)!.value.toString()) ==
                -1) {
          wrongVendorIdOrDepartmentId++;
        } else {
          String priceWt = '0';
          String price = '0';

          if (priceWtIndex != null &&
              row.elementAt(priceWtIndex) != null &&
              row.elementAt(priceWtIndex)!.value.toString().isNotEmpty) {
            try {
              priceWt = row.elementAt(priceWtIndex)!.value.toString();
            } catch (e) {}
            price = calculatePrice(priceWt);
          } else if (priceIndex != null &&
              row.elementAt(priceIndex) != null &&
              row.elementAt(priceIndex)!.value.toString().isNotEmpty) {
            try {
              price = row.elementAt(priceIndex)!.value.toString();
            } catch (e) {}
            priceWt = calculatePriceWt(price);
          }

          inventoryDataLst.add(InventoryData(
              docId: '',
              barcode: randomBarcodeGenerate(),
              itemCode: '',
              productName: row.elementAt(productNameIndex)!.value.toString(),
              selectedVendorId: row.elementAt(vendorIdIndex)!.value.toString(),
              selectedDepartmentId:
                  row.elementAt(departmentIdIndex)!.value.toString(),
              productImg: productImgIndex == null ||
                      row.elementAt(productImgIndex) == null
                  ? ''
                  : row.elementAt(productImgIndex)!.value.toString(),
              description: descriptionIndex == null ||
                      row.elementAt(descriptionIndex) == null
                  ? ''
                  : row.elementAt(descriptionIndex)!.value.toString(),
              margin: marginIndex == null || row.elementAt(marginIndex) == null
                  ? ''
                  : row.elementAt(marginIndex)!.value.toString(),
              createdBy: createdBy,
              createdDate: DateTime.now(),
              cost: costIndex == null || row.elementAt(costIndex) == null
                  ? '0'
                  : row.elementAt(costIndex)!.value.toString().isEmpty
                      ? '0'
                      : row.elementAt(costIndex)!.value.toString(),
              price: price,
              priceWT: priceWt,
              ohQtyForDifferentStores: {},
              productPriceCanChange: false));
        }
      }
    }
  }
  return {
    'wrongVendorIdOrDepartmentId': wrongVendorIdOrDepartmentId,
    'inventoryDataLst': inventoryDataLst
  };
}

String calculatePriceWt(String pr) {
  double p = double.parse(pr);
  String tax = '10';
  var box = Hive.box('bitpro_app');
  Map? userTaxesData = box.get('user_taxes_settings');

  if (userTaxesData != null) {
    tax = userTaxesData['taxPercentage'];
  }
  double texPer = double.tryParse(tax) ?? 0;

  return ((p * (1 + (texPer / 100)))).toStringAsFixed(2);
}

String calculatePrice(String prWt) {
  double p = double.parse(prWt);
  String tax = '10';
  var box = Hive.box('bitpro_app');
  Map? userTaxesData = box.get('user_taxes_settings');

  if (userTaxesData != null) {
    tax = userTaxesData['taxPercentage'];
  }
  double texPer = double.tryParse(tax) ?? 0;

  return (p - (p / (1 + (100 / texPer)))).toStringAsFixed(2);
}
