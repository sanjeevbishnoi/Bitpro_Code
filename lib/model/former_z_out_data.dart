import 'dart:convert';

class FormerZOutData {
  String formerZoutNo;
  String total;
  String cashierName;
  String overShort;
  String totalCashOnSystem;
  String totalCashEntered;
  String totalCashDifferences;
  String totalNCDifferences;
  String openDate;
  String closeDate;
  String creditCardTotalInSystem;
  String creditCardTotal;
  String docId;

  FormerZOutData({
    required this.formerZoutNo,
    required this.total,
    required this.cashierName,
    required this.overShort,
    required this.totalCashOnSystem,
    required this.totalCashEntered,
    required this.totalCashDifferences,
    required this.totalNCDifferences,
    required this.openDate,
    required this.closeDate,
    required this.creditCardTotalInSystem,
    required this.creditCardTotal,
    required this.docId,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'formerZoutNo': formerZoutNo});
    result.addAll({'total': total});
    result.addAll({'cashierName': cashierName});
    result.addAll({'overShort': overShort});
    result.addAll({'totalCashOnSystem': totalCashOnSystem});
    result.addAll({'totalCashEntered': totalCashEntered});
    result.addAll({'totalCashDifferences': totalCashDifferences});
    result.addAll({'totalNCDifferences': totalNCDifferences});
    result.addAll({'openDate': openDate});
    result.addAll({'closeDate': closeDate});
    result.addAll({'creditCardTotalInSystem': creditCardTotalInSystem});
    result.addAll({'creditCardTotal': creditCardTotal});
    result.addAll({'docId': docId});

    return result;
  }

  factory FormerZOutData.fromMap(Map<dynamic, dynamic> map) {
    return FormerZOutData(
      formerZoutNo: map['formerZoutNo'] ?? '',
      total: map['total'] ?? '',
      cashierName: map['cashierName'] ?? '',
      overShort: map['overShort'] ?? '',
      totalCashOnSystem: map['totalCashOnSystem'] ?? '',
      totalCashEntered: map['totalCashEntered'] ?? '',
      totalCashDifferences: map['totalCashDifferences'] ?? '',
      totalNCDifferences: map['totalNCDifferences'] ?? '',
      openDate: map['openDate'] ?? '',
      closeDate: map['closeDate'] ?? '',
      creditCardTotalInSystem: map['creditCardTotalInSystem'] ?? '',
      creditCardTotal: map['creditCardTotal'] ?? '',
      docId: map['docId'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory FormerZOutData.fromJson(String source) =>
      FormerZOutData.fromMap(json.decode(source));
}
