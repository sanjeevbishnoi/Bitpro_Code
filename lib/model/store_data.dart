import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class StoreData {
  String docId;
  String storeCode;
  String storeName;
  String address1;
  String address2;
  String phone1;
  String phone2;
  String vatNumber;
  String priceLevel;
  String logoPath;
  List workstationInfo;

  String email;
  String ibanAccountNumber;
  String bankName;
  StoreData(
      {required this.docId,
      required this.storeCode,
      required this.storeName,
      required this.address1,
      required this.address2,
      required this.phone1,
      required this.phone2,
      required this.vatNumber,
      required this.priceLevel,
      required this.logoPath,
      required this.email,
      required this.bankName,
      required this.ibanAccountNumber,
      required this.workstationInfo});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'docId': docId,
      'storeCode': storeCode,
      'storeName': storeName,
      'address1': address1,
      'address2': address2,
      'phone1': phone1,
      'phone2': phone2,
      'vatNumber': vatNumber,
      'priceLevel': priceLevel,
      'logoPath': logoPath,
      'workstationInfo': workstationInfo,
      'email': email,
      'bankName': bankName,
      'ibanAccountNumber': ibanAccountNumber,
    };
  }

  factory StoreData.fromMap(Map<dynamic, dynamic> map) {
    return StoreData(
        docId: map['docId'] as String,
        storeCode: map['storeCode'] as String,
        storeName: map['storeName'] as String,
        address1: map['address1'] as String,
        address2: map['address2'] as String,
        phone1: map['phone1'] as String,
        phone2: map['phone2'] as String,
        vatNumber: map['vatNumber'] as String,
        priceLevel: map['priceLevel'] as String,
        logoPath: map['logoPath'] as String,
        bankName: map['bankName'] as String,
        email: map['email'] as String,
        ibanAccountNumber: map['ibanAccountNumber'] as String,
        workstationInfo: map['workstationInfo']);
  }

  String toJson() => json.encode(toMap());

  factory StoreData.fromJson(String source) =>
      StoreData.fromMap(json.decode(source) as Map<String, dynamic>);
}
