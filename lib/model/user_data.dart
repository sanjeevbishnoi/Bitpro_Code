class UserData {
  String firstName;
  String lastName;
  String username;
  String employeeId;
  String password;
  String userRole;
  String maxDiscount;
  String createdBy;
  String docId;
  DateTime createdDate;
  DateTime? openRegister;
  UserData({
    required this.openRegister,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.employeeId,
    required this.password,
    required this.userRole,
    required this.maxDiscount,
    required this.createdBy,
    required this.docId,
    required this.createdDate,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'firstName': firstName});
    result.addAll({'lastName': lastName});
    result.addAll({'username': username});
    result.addAll({'employeeId': employeeId});
    result.addAll({'password': password});
    result.addAll({'userRole': userRole});
    result.addAll({'maxDiscount': maxDiscount});
    result.addAll({'createdBy': createdBy});
    result.addAll({'docId': docId});
    result.addAll({'createdDate': createdDate.toString()});
    // result.addAll({'userSettings': userSettings});
    // result.addAll({'userPrintingSettings': userPrintingSettings});
    // result.addAll({'userTaxesSettings': userTaxesSettings});
    result.addAll({
      'openRegister': openRegister == null ? null : openRegister.toString()
    });

    return result;
  }

  factory UserData.fromMap(Map<dynamic, dynamic> map) {
    return UserData(
        firstName: map['firstName'] ?? '',
        lastName: map['lastName'] ?? '',
        username: map['username'] ?? '',
        employeeId: map['employeeId'] ?? '',
        password: map['password'] ?? '',
        userRole: map['userRole'] ?? '',
        maxDiscount: map['maxDiscount'] ?? '',
        createdBy: map['createdBy'] ?? '',
        docId: map['docId'] ?? '',
        createdDate: DateTime.tryParse(map['createdDate'].toString())??
            DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int),
        // userSettings: Map<dynamic, dynamic>.from(map['userSettings'] ?? {}),
        // userPrintingSettings:
        //     Map<dynamic, dynamic>.from(map['userPrintingSettings'] ?? {}),
        // userTaxesSettings:
        //     Map<dynamic, dynamic>.from(map['userTaxesSettings'] ?? {}),
        openRegister: DateTime.tryParse(map['openRegister'] ?? ''));
  }
}
