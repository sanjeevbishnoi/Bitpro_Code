// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class DbReceiptData {
  String receiptNo;
  String subTotal;
  String createdBy;
  String selectedCustomerID;
  String discountPercentage;
  String discountValue;
  DateTime createdDate;
  String totalQty;

  List<dynamic> selectedItems;

  String taxPer;
  String taxValue;

  ReceiptTendor tendor;
  String docId;
  String receiptType;
  String referenceNo;

  String selectedStoreDocId;
  DbReceiptData(
      {required this.receiptNo,
      required this.subTotal,
      required this.createdBy,
      required this.selectedCustomerID,
      required this.discountPercentage,
      required this.discountValue,
      required this.createdDate,
      required this.totalQty,
      required this.selectedItems,
      required this.taxPer,
      required this.taxValue,
      required this.tendor,
      required this.docId,
      required this.receiptType,
      required this.referenceNo,
      required this.selectedStoreDocId});

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'receiptNo': receiptNo});
    result.addAll({'subTotal': subTotal});
    result.addAll({'createdBy': createdBy});
    result.addAll({'selectedCustomerID': selectedCustomerID});
    result.addAll({'discountPercentage': discountPercentage});
    result.addAll({'discountValue': discountValue});
    result.addAll({'createdDate': createdDate.millisecondsSinceEpoch});
    result.addAll({'totalQty': totalQty});
    result.addAll({'selectedItems': selectedItems});
    result.addAll({'taxPer': taxPer});
    result.addAll({'taxValue': taxValue});
    result.addAll({'tendor': tendor.toMap()});
    result.addAll({'docId': docId});
    result.addAll({'receiptType': receiptType});
    result.addAll({'referenceNo': referenceNo});
    result.addAll({'selectedStoreDocId': selectedStoreDocId});
    return result;
  }

  // Map<String, dynamic> toMapNewFirebase() {
  //   final result = <String, dynamic>{};

  //   result.addAll({'receiptNo': receiptNo});
  //   result.addAll({'subTotal': subTotal});
  //   result.addAll({'createdBy': createdBy});
  //   result.addAll({'selectedCustomerID': selectedCustomerID});
  //   result.addAll({'discountPercentage': discountPercentage});
  //   result.addAll({'discountValue': discountValue});
  //   result.addAll({'createdDate': createdDate.millisecondsSinceEpoch});
  //   result.addAll({'totalQty': totalQty});
  //   result.addAll({'selectedItems': selectedItems});
  //   result.addAll({'taxPer': taxPer});
  //   result.addAll({'taxValue': taxValue});
  //   result.addAll({'tendor': tendor.toMap()});
  //   result.addAll({'docId': docId});
  //   result.addAll({'receiptType': receiptType});
  //   result.addAll({'referenceNo': referenceNo});
  //   result.addAll({'selectedStoreDocId': selectedStoreDocId});
  //   return result;
  // }

  factory DbReceiptData.fromMap(Map<dynamic, dynamic> map) {
    return DbReceiptData(
        receiptNo: map['receiptNo'] ?? '',
        subTotal: map['subTotal'] ?? '',
        createdBy: map['createdBy'] ?? '',
        selectedCustomerID: map['selectedCustomerID'] ?? '',
        discountPercentage: map['discountPercentage'] ?? '',
        discountValue: map['discountValue'] ?? '',
        createdDate: DateTime.tryParse(map['createdDate'].toString()) ??
            DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int),
        totalQty: map['totalQty'] ?? '',
        selectedItems: List<dynamic>.from(map['selectedItems']),
        taxPer: map['taxPer'] ?? '',
        taxValue: map['taxValue'] ?? '',
        tendor: ReceiptTendor.fromMap(map['tendor']),
        docId: map['docId'] ?? '',
        receiptType: map['receiptType'] ?? 'Regular',
        referenceNo: map['referenceNo'] ?? '',
        selectedStoreDocId: map['selectedStoreDocId']);
  }

  String toJson() => json.encode(toMap());

  factory DbReceiptData.fromJson(String source) =>
      DbReceiptData.fromMap(json.decode(source));
}

class ReceiptTendor {
  String cash;
  String credit;
  String creditCard;
  String remainingAmount;
  String balance;
  ReceiptTendor({
    required this.cash,
    required this.credit,
    required this.creditCard,
    required this.remainingAmount,
    required this.balance,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'cash': cash});
    result.addAll({'credit': credit});
    result.addAll({'creditCard': creditCard});
    result.addAll({'remainingAmount': remainingAmount});
    result.addAll({'balance': balance});

    return result;
  }

  factory ReceiptTendor.fromMap(Map<dynamic, dynamic> map) {
    return ReceiptTendor(
      cash: map['cash'] ?? '0',
      credit: map.containsKey('credit') ? map['credit'] ?? '0' : '0',
      creditCard: map['creditCard'] ?? '0',
      remainingAmount: map['remainingAmount'] ?? '0',
      balance: map['balance'] ?? '0',
    );
  }

  String toJson() => json.encode(toMap());

  factory ReceiptTendor.fromJson(String source) =>
      ReceiptTendor.fromMap(json.decode(source));
}
