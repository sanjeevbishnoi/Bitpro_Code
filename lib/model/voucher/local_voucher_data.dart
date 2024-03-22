import 'dart:convert';

class LocalVoucherData {
  String barcode;
  String itemCode;
  String productName;
 
  String qty;
  String cost;
  String price;
  String priceWt;
  String extCost;
  LocalVoucherData({
  
    required this.barcode,
    required this.itemCode,
    required this.productName,
    required this.qty,
    required this.cost,
    required this.price,
    required this.priceWt,
    required this.extCost,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'barcode': barcode});
    result.addAll({'itemCode': itemCode});
    result.addAll({'productName': productName});
    result.addAll({'qty': qty});
    result.addAll({'cost': cost});
    result.addAll({'price': price});
    result.addAll({'priceWt': priceWt});
    result.addAll({'extCost': extCost});

    return result;
  }

  factory LocalVoucherData.fromMap(Map<dynamic, dynamic> map) {
    return LocalVoucherData(
     barcode: map['barcode'] ?? '',
      itemCode: map['itemCode'] ?? '',
      productName: map['productName'] ?? '',
      qty: map['qty'] ?? '',
      cost: map['cost'] ?? '',
      price: map['price'] ?? '',
      priceWt: map['priceWt'] ?? '',
      extCost: map['extCost'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory LocalVoucherData.fromJson(String source) =>
      LocalVoucherData.fromMap(json.decode(source));
}
