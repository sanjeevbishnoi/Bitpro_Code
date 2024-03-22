import 'dart:convert';

class VendorData {
  String docId;
  String vendorName;
  String emailAddress;
  String vendorId;
  String address1;
  String phone1;
  String address2;
  String phone2;
  String vatNumber;
  DateTime createdDate;
  String createdBy;
  String openingBalance;

  VendorData({
    required this.docId,
    required this.vendorName,
    required this.emailAddress,
    required this.vendorId,
    required this.address1,
    required this.phone1,
    required this.address2,
    required this.phone2,
    required this.vatNumber,
    required this.createdDate,
    required this.createdBy,
    required this.openingBalance,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'docId': docId});
    result.addAll({'vendorName': vendorName});
    result.addAll({'emailAddress': emailAddress});
    result.addAll({'vendorId': vendorId});
    result.addAll({'address1': address1});
    result.addAll({'phone1': phone1});
    result.addAll({'address2': address2});
    result.addAll({'phone2': phone2});
    result.addAll({'vatNumber': vatNumber});
    result.addAll({'createdDate': createdDate.toString()});
    result.addAll({'createdBy': createdBy});
    result.addAll({'openingBalance': openingBalance});
    return result;
  }

  factory VendorData.fromMap(Map<dynamic, dynamic> map) {
    
    return VendorData(
        docId: map['docId'] ?? '',
        vendorName: map['vendorName'] ?? '',
        emailAddress: map['emailAddress'] ?? '',
        vendorId: map['vendorId'] ?? '',
        address1: map['address1'] ?? '',
        phone1: map['phone1'] ?? '',
        address2: map['address2'] ?? '',
        phone2: map['phone2'] ?? '',
        vatNumber: map['vatNumber'] ?? '',
        createdDate:   DateTime.tryParse(map['createdDate'].toString())??
            DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int),
       
        createdBy: map['createdBy'] ?? '',
        openingBalance: map['openingBalance'] ?? '0');
  }

  String toJson() => json.encode(toMap());

  factory VendorData.fromJson(String source) =>
      VendorData.fromMap(json.decode(source));
}
