import 'dart:convert';

class LocalReceiptData {
  String barcode;
  String itemCode;
  String productName;
  String qty;
  String orgPrice;
  String discountValue;
  String discountPercentage;
  String priceWt;
  String total;
  String cost;
  LocalReceiptData({
    required this.barcode,
    required this.itemCode,
    required this.productName,
    required this.qty,
    required this.orgPrice,
    required this.discountValue,
    required this.discountPercentage,
    required this.priceWt,
    required this.total,
    required this.cost,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'barcode': barcode});
    result.addAll({'itemCode': itemCode});
    result.addAll({'productName': productName});
    result.addAll({'qty': qty});
    result.addAll({'orgPrice': orgPrice});
    result.addAll({'discountPercentage': discountPercentage});
    result.addAll({'discountValue': discountValue});
    result.addAll({'priceWt': priceWt});
    result.addAll({'total': total});
    result.addAll({'cost': cost});
    // result.addAll({'price': price});

    return result;
  }

  factory LocalReceiptData.fromMap(Map<String, dynamic> map) {
    return LocalReceiptData(
      barcode: map['barcode'] ?? '',
      itemCode: map['itemCode'] ?? '',
      productName: map['productName'] ?? '',
      qty: map['qty'] ?? '',
      orgPrice: map['orgPrice'] ?? '',
      discountPercentage: map['discountPercentage'] ?? '',
      discountValue: map['discountValue'] ?? '',
      priceWt: map['priceWt'] ?? '',
      total: map['total'] ?? '',
      cost: map['cost'] ?? '',
      // price: map['price'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory LocalReceiptData.fromJson(String source) =>
      LocalReceiptData.fromMap(json.decode(source));
}
