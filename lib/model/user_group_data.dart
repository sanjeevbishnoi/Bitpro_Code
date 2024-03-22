// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserGroupData {
  String docId;
  String createdBy;
  DateTime createdDate;
  String name;
  String description;
  bool employees;
  bool registers;
  bool groups;
  bool salesReceipt;
  bool vendors;
  bool reports;
  bool departments;
  bool settings;
  bool inventory;
  bool purchaseVoucher;
  bool customers;
  bool receipt;
  bool formerZout;
  bool adjustment;
  bool backupReset;
  bool promotion;
  UserGroupData(
      {required this.docId,
      required this.createdBy,
      required this.createdDate,
      required this.name,
      required this.description,
      required this.employees,
      required this.registers,
      required this.groups,
      required this.salesReceipt,
      required this.vendors,
      required this.reports,
      required this.departments,
      required this.settings,
      required this.inventory,
      required this.purchaseVoucher,
      required this.customers,
      required this.receipt,
      required this.formerZout,
      required this.adjustment,
      required this.backupReset,
      required this.promotion});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'docId': docId,
      'createdBy': createdBy,
      'createdDate': createdDate.millisecondsSinceEpoch,
      'name': name,
      'discription': description,
      'employees': employees,
      'registers': registers,
      'groups': groups,
      'salesReceipt': salesReceipt,
      'vendors': vendors,
      'reports': reports,
      'departments': departments,
      'settings': settings,
      'inventory': inventory,
      'purchaseVoucher': purchaseVoucher,
      'customers': customers,
      'receipt': receipt,
      'formerZout': formerZout,
      'adjustment': adjustment,
      'backupReset': backupReset,
      'promotion': promotion
    };
  }

  factory UserGroupData.fromMap(Map<dynamic, dynamic> map) {
  
    return UserGroupData(
        docId: map['docId'] ?? "",
        createdBy: map['createdBy'] ?? "",
        createdDate:
        DateTime.tryParse(map['createdDate'].toString())??
            DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int),
        name: map['name'] ?? "",
        description: map['discription'] ?? "",
        employees: map['employees'] ?? true,
        registers: map['registers'] ?? true,
        groups: map['groups'] ?? true,
        salesReceipt: map['salesReceipt'] ?? true,
        vendors: map['vendors'] ?? true,
        reports: map['reports'] ?? true,
        departments: map['departments'] ?? true,
        settings: map['settings'] ?? true,
        inventory: map['inventory'] ?? true,
        purchaseVoucher: map['purchaseVoucher'] ?? true,
        customers: map['customers'] ?? true,
        receipt: map['receipt'] ?? true,
        formerZout: map['formerZout'] ?? true,
        adjustment: map['adjustment'] ?? true,
        backupReset: map['backupReset'] ?? true,
        promotion: map['promotion'] ?? true);
  }

  String toJson() => json.encode(toMap());

  factory UserGroupData.fromJson(String source) =>
      UserGroupData.fromMap(json.decode(source) as Map<String, dynamic>);
}
