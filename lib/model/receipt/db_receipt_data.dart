// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class DbReceiptData {
  String receiptNo;
  String createdBy;
  String selectedCustomerID;
  String discountPercentage;
  String discountValue;
  DateTime createdDate;
  String totalQty;

  List<dynamic> selectedItems;

  String taxPer;
  String taxValue;

  String docId;
  String receiptType;
  String referenceNo;
  String selectedStoreDocId;

  String receiptTotal;
  String receiptDue;
  String receiptBalance;
  Map<dynamic, dynamic> allPaymentMethodAmountsInfo;
  DbReceiptData(
      {required this.receiptNo,
      required this.receiptTotal,
      required this.createdBy,
      required this.selectedCustomerID,
      required this.discountPercentage,
      required this.discountValue,
      required this.createdDate,
      required this.totalQty,
      required this.selectedItems,
      required this.taxPer,
      required this.taxValue,
      required this.docId,
      required this.receiptType,
      required this.referenceNo,
      required this.receiptDue,
      required this.receiptBalance,
      required this.selectedStoreDocId,
      required this.allPaymentMethodAmountsInfo});

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'receiptNo': receiptNo});
    result.addAll({'createdBy': createdBy});
    result.addAll({'selectedCustomerID': selectedCustomerID});
    result.addAll({'discountPercentage': discountPercentage});
    result.addAll({'discountValue': discountValue});
    result.addAll({'createdDate': createdDate.millisecondsSinceEpoch});
    result.addAll({'totalQty': totalQty});
    result.addAll({'selectedItems': selectedItems});
    result.addAll({'taxPer': taxPer});
    result.addAll({'taxValue': taxValue});
    result.addAll({'docId': docId});
    result.addAll({'receiptType': receiptType});
    result.addAll({'referenceNo': referenceNo});
    result.addAll({'selectedStoreDocId': selectedStoreDocId});

    result.addAll({'receiptTotal': receiptTotal});
    result.addAll({'receiptDue': receiptDue});
    result.addAll({'receiptBalance': receiptBalance});
    result.addAll({'allPaymentMethodAmountsInfo': allPaymentMethodAmountsInfo});
    return result;
  }

  factory DbReceiptData.fromMap(Map<dynamic, dynamic> map) {
    return DbReceiptData(
        receiptNo: map['receiptNo'] ?? '',
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
        docId: map['docId'] ?? '',
        receiptType: map['receiptType'] ?? 'Regular',
        referenceNo: map['referenceNo'] ?? '',
        selectedStoreDocId: map['selectedStoreDocId'],
        //
        receiptTotal: map['receiptTotal'] ?? '',
        receiptDue: map['receiptDue'] ?? '',
        receiptBalance: map['receiptBalance'] ?? '',
        allPaymentMethodAmountsInfo: map['allPaymentMethodAmountsInfo'] ?? {});
  }

  String toJson() => json.encode(toMap());

  factory DbReceiptData.fromJson(String source) =>
      DbReceiptData.fromMap(json.decode(source));
}
