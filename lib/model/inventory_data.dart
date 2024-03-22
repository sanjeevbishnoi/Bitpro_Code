import 'dart:convert';

class InventoryData {
  String docId;
  String itemCode;
  String selectedVendorId;
  String productName;
  String selectedDepartmentId;
  String cost;
  String description;
  String price;
  String margin;
  String priceWT;
  String productImg;
  String barcode;
  DateTime createdDate;
  String createdBy;
  Map ohQtyForDifferentStores;
  bool productPriceCanChange;

  InventoryData({
    required this.docId,
    required this.itemCode,
    required this.selectedVendorId,
    required this.productName,
    required this.selectedDepartmentId,
    required this.cost,
    required this.description,
    required this.price,
    required this.margin,
    required this.priceWT,
    required this.productImg,
    required this.barcode,
    required this.createdDate,
    required this.createdBy,
    required this.ohQtyForDifferentStores,
    required this.productPriceCanChange,
    String? proImgUrl,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'docId': docId});
    result.addAll({'itemCode': itemCode});
    result.addAll({'selectedVendorId': selectedVendorId});
    result.addAll({'productName': productName});
    result.addAll({'selectedDepartmentId': selectedDepartmentId});
    result.addAll({'cost': cost});
    result.addAll({'description': description});
    result.addAll({'price': price});
    result.addAll({'margin': margin});
    result.addAll({'priceWT': priceWT});
    result.addAll({'productImg': productImg});
    result.addAll({'barcode': barcode});
    result.addAll({'createdDate': createdDate.toString()});
    result.addAll({'createdBy': createdBy});
    result.addAll({'ohQtyForDifferentStores': ohQtyForDifferentStores});
    result.addAll({'productPriceCanChange': productPriceCanChange});

    return result;
  }

  factory InventoryData.fromMap(Map<dynamic, dynamic> map) {
    return InventoryData(
      docId: map['docId'] ?? '',
      itemCode: map['itemCode'] ?? '',
      selectedVendorId: map['selectedVendorId'] ?? '',
      productName: map['productName'] ?? '',
      selectedDepartmentId: map['selectedDepartmentId'] ?? '',
      cost: map['cost'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? '',
      margin: map['margin'] ?? '',
      priceWT: map['priceWT'] ?? '',
      productImg: map['productImg'] ?? '',
      barcode: map['barcode'] ?? '',
      createdDate: DateTime.tryParse(map['createdDate'].toString()) ??
          DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int),
      createdBy: map['createdBy'] ?? '',
      ohQtyForDifferentStores: map['ohQtyForDifferentStores'] ?? {},
      productPriceCanChange: map['productPriceCanChange'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory InventoryData.fromJson(String source) =>
      InventoryData.fromMap(json.decode(source));
}
