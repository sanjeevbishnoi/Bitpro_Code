
import 'dart:convert';
import 'package:bitpro_hive/model/voucher/db_voucher_data.dart';

class VendorPaymentData {
  String docId;
  String vendorId;
  String paymentType;
  double amount;
  DateTime createdDate;
  String comment;
  String documentNo;
  VendorPaymentData({
    required this.docId,
    required this.vendorId,
    required this.paymentType,
    required this.amount,
    required this.createdDate,
    required this.comment,
    required this.documentNo,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'docId': docId,
      'vendorId': vendorId,
      'paymentType': paymentType,
      'amount': amount,
      'createdDate': createdDate.millisecondsSinceEpoch,
      'comment': comment,
      'documentNo': documentNo,
    };
  }

  factory VendorPaymentData.fromMap(Map<dynamic, dynamic> map) {
    return VendorPaymentData(
      docId: map['docId'] as String,
      vendorId: map['vendorId'] as String,
      paymentType: map['paymentType'] as String,
      amount: map['amount'] as double,
      createdDate:
         DateTime.tryParse(map['createdDate'].toString())??
            DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int),
       
      comment: map['comment'] as String,
      documentNo: map['documentNo'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory VendorPaymentData.fromJson(String source) =>
      VendorPaymentData.fromMap(json.decode(source) as Map<String, dynamic>);
}

class VendorPaymentTempModel {
  DateTime dateTime;
  VendorPaymentData? vendorPaymentData;
  DbVoucherData? dbVoucherData;
  VendorPaymentTempModel({
    required this.dateTime,
    this.vendorPaymentData,
    this.dbVoucherData,
  });
}
