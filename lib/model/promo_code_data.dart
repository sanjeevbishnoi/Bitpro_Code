import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class PromoData {
  String promoNo;

  DateTime startDate;
  DateTime endDate;

  String barcode;
  String percentage;
  String docId;
  PromoData({
    required this.promoNo,
    required this.startDate,
    required this.endDate,
    required this.barcode,
    required this.percentage,
    required this.docId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'promoNo': promoNo,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'barcode': barcode,
      'percentage': percentage,
      'docId': docId,
    };
  }

  factory PromoData.fromMap(Map<dynamic, dynamic> map) {
    return PromoData(
      promoNo: map['promoNo'] as String,
      startDate: DateTime.tryParse(map['startDate'].toString()) ??
          DateTime.fromMillisecondsSinceEpoch(map['startDate'] as int),
      endDate: DateTime.tryParse(map['endDate'].toString()) ??
          DateTime.fromMillisecondsSinceEpoch(map['endDate'] as int),
      barcode: map['barcode'] as String,
      percentage: map['percentage'] as String,
      docId: map['docId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory PromoData.fromJson(String source) =>
      PromoData.fromMap(json.decode(source) as Map<String, dynamic>);
}
