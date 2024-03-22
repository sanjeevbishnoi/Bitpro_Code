import 'dart:convert';

class PromotionData {
  String percentage;
  String barcode;
  PromotionData({
    required this.percentage,
    required this.barcode,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'percentage': percentage});
    result.addAll({'barcode': barcode});

    return result;
  }

  factory PromotionData.fromMap(Map<dynamic, dynamic> map) {
    return PromotionData(
      percentage: map['percentage'] ?? '',
      barcode: map['barcode'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory PromotionData.fromJson(String source) =>
      PromotionData.fromMap(json.decode(source));
}
