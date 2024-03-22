import 'dart:convert';
import 'package:bitpro_hive/model/receipt/db_receipt_data.dart';

class CustomerPaymentData {
  String docId;
  String customerId;
  String paymentType;
  double amount;
  DateTime createdDate;
  String comment;
  String documentNo;
  CustomerPaymentData({
    required this.docId,
    required this.customerId,
    required this.paymentType,
    required this.amount,
    required this.createdDate,
    required this.comment,
    required this.documentNo,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'docId': docId,
      'customerId': customerId,
      'paymentType': paymentType,
      'amount': amount,
      'createdDate': createdDate.millisecondsSinceEpoch,
      'comment': comment,
      'documentNo': documentNo,
    };
  }

  factory CustomerPaymentData.fromMap(Map<dynamic, dynamic> map) {
    return CustomerPaymentData(
      docId: map['docId'] as String,
      customerId: map['customerId'] as String,
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

  factory CustomerPaymentData.fromJson(String source) =>
      CustomerPaymentData.fromMap(json.decode(source) as Map<String, dynamic>);
}

class CustomerPaymentTempModel {
  DateTime dateTime;
  CustomerPaymentData? customerPaymentData;
  DbReceiptData? dbReceiptData;
  CustomerPaymentTempModel({
    required this.dateTime,
    this.customerPaymentData,
    this.dbReceiptData,
  });
}
