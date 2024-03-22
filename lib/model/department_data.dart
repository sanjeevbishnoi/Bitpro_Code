import 'dart:convert';

class DepartmentData {
  String docId;
  String departmentName;
  String departmentId;

  DateTime createdDate;
  String createdBy;
  DepartmentData({
    required this.docId,
    required this.departmentName,
    required this.departmentId,
    required this.createdDate,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'docId': docId});
    result.addAll({'departmentName': departmentName});
    result.addAll({'departmentId': departmentId});
    result.addAll({'createdDate': createdDate.toString()});
    result.addAll({'createdBy': createdBy});

    return result;
  }

  factory DepartmentData.fromMap(Map<dynamic, dynamic> map) {
    return DepartmentData(
      docId: map['docId'] ?? '',
      departmentName: map['departmentName'] ?? '',
      departmentId: map['departmentId'] ?? '',
      createdDate:   DateTime.tryParse(map['createdDate'].toString())??
            DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int),
      createdBy: map['createdBy'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory DepartmentData.fromJson(String source) =>
      DepartmentData.fromMap(json.decode(source));
}
