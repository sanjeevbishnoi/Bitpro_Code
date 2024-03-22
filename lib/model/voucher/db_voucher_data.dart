// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class DbVoucherData {
  String voucherNo;

  String vendor;
  String qtyRecieved;
  String voucherTotal;

  String createdBy;

  List<dynamic> selectedItems;
  String tax;
  String discountPercentage;
  String discountValue;
  String purchaseInvoice;
  String purchaseInvoiceDate;
  String note;
  DateTime createdDate;
  String docId;
  String voucherType;
  String selectedStoreDocId;
  DbVoucherData(
      {required this.voucherNo,
      required this.vendor,
      required this.qtyRecieved,
      required this.voucherTotal,
      required this.createdBy,
      required this.selectedItems,
      required this.tax,
      required this.discountPercentage,
      required this.discountValue,
      required this.purchaseInvoice,
      required this.purchaseInvoiceDate,
      required this.note,
      required this.createdDate,
      required this.docId,
      required this.voucherType,
      required this.selectedStoreDocId});

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'voucherNo': voucherNo});

    result.addAll({'vendor': vendor});
    result.addAll({'qtyRecieved': qtyRecieved});
    result.addAll({'voucherTotal': voucherTotal});
    result.addAll({'createdBy': createdBy});
    result.addAll({'selectedItems': selectedItems});
    result.addAll({'tax': tax});
    result.addAll({'discountPercentage': discountPercentage});
    result.addAll({'discountValue': discountValue});
    result.addAll({'purchaseInvoice': purchaseInvoice});
    result.addAll({'purchaseInvoiceDate': purchaseInvoiceDate});
    result.addAll({'note': note});
    result.addAll({'createdDate': createdDate.millisecondsSinceEpoch});
    result.addAll({'docId': docId});
    result.addAll({'voucherType': voucherType});
    result.addAll({'selectedStoreDocId': selectedStoreDocId});
    return result;
  }

  // Map<String, dynamic> toMapNewFirebase() {
  //   final result = <String, dynamic>{};

  //   result.addAll({'voucherNo': voucherNo});

  //   result.addAll({'vendor': vendor});
  //   result.addAll({'qtyRecieved': qtyRecieved});
  //   result.addAll({'voucherTotal': voucherTotal});
  //   result.addAll({'createdBy': createdBy});
  //   result.addAll(
  //       {'selectedItems': selectedItems.map((e) => e.toMap()).toList()});
  //   result.addAll({'tax': tax});
  //   result.addAll({'discountPercentage': discountPercentage});
  //   result.addAll({'discountValue': discountValue});
  //   result.addAll({'purchaseInvoice': purchaseInvoice});
  //   result.addAll({'purchaseInvoiceDate': purchaseInvoiceDate});
  //   result.addAll({'note': note});
  //   result.addAll({'createdDate': createdDate.millisecondsSinceEpoch});
  //   result.addAll({'docId': docId});
  //   result.addAll({'voucherType': voucherType});
  //   result.addAll({'selectedStoreDocId': selectedStoreDocId});
  //   return result;
  // }

  factory DbVoucherData.fromMap(Map<dynamic, dynamic> map) {
    return DbVoucherData(
        voucherType: map['voucherType'] ?? '',
        voucherNo: map['voucherNo'] ?? '',
        vendor: map['vendor'] ?? '',
        qtyRecieved: map['qtyRecieved'] ?? '',
        voucherTotal: map['voucherTotal'] ?? '',
        createdBy: map['createdBy'] ?? '',
        selectedItems: List<dynamic>.from(map['selectedItems']),
        tax: map['tax'] ?? '',
        discountPercentage: map['discountPercentage'] ?? '',
        discountValue: map['discountValue'] ?? '',
        purchaseInvoice: map['purchaseInvoice'] ?? '',
        purchaseInvoiceDate: map['purchaseInvoiceDate'] ?? '',
        note: map['note'] ?? '',
        createdDate: DateTime.tryParse(map['createdDate'].toString()) ??
            DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int),
        docId: map['docId'] ?? '',
        selectedStoreDocId: map['selectedStoreDocId'] ?? {});
  }

  String toJson() => json.encode(toMap());

  factory DbVoucherData.fromJson(String source) =>
      DbVoucherData.fromMap(json.decode(source));
}
