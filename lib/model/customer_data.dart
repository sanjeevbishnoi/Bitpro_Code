import 'dart:convert';

class CustomerData {
  String customerId;
  String customerName;
  String address1;
  String address2;
  String phone1;
  String phone2;
  String email;
  String vatNo;
  String companyName;
  DateTime createdDate;
  String createdBy;
  String docId;
  String openingBalance;
  CustomerData({
    required this.customerId,
    required this.customerName,
    required this.address1,
    required this.address2,
    required this.phone1,
    required this.phone2,
    required this.email,
    required this.vatNo,
    required this.companyName,
    required this.createdDate,
    required this.createdBy,
    required this.docId,
    required this.openingBalance,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'customerId': customerId});
    result.addAll({'customerName': customerName});
    result.addAll({'address1': address1});
    result.addAll({'address2': address2});
    result.addAll({'phone1': phone1});
    result.addAll({'phone2': phone2});
    result.addAll({'email': email});
    result.addAll({'vatNo': vatNo});
    result.addAll({'companyName': companyName});
    result.addAll({'createdDate': createdDate.toString()});
    result.addAll({'createdBy': createdBy});
    result.addAll({'docId': docId});
    result.addAll({'openingBalance': openingBalance});

    return result;
  }

  factory CustomerData.fromMap(Map<dynamic, dynamic> map) {
    return CustomerData(
        customerId: map['customerId'] ?? '',
        customerName: map['customerName'] ?? '',
        address1: map['address1'] ?? '',
        address2: map['address2'] ?? '',
        phone1: map['phone1'] ?? '',
        phone2: map['phone2'] ?? '',
        email: map['email'] ?? '',
        vatNo: map['vatNo'] ?? '',
        companyName: map['companyName'] ?? '',
        createdDate:  DateTime.tryParse(map['createdDate'].toString())??
            DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int),
        createdBy: map['createdBy'] ?? '',
        docId: map['docId'] ?? '',
        openingBalance: map['openingBalance'] ?? '0');
  }

  String toJson() => json.encode(toMap());

  factory CustomerData.fromJson(String source) =>
      CustomerData.fromMap(json.decode(source));
}
