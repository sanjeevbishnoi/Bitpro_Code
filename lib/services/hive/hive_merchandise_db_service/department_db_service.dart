import 'package:hive/hive.dart';
import 'package:bitpro_hive/model/department_data.dart';

class HiveDepartmentDbService {
  Future addDepartmentData(
    String createdBy,
    DateTime createdDate,
    String? docId,
    String? id,
    String? name,
  ) async {
    var box = Hive.box('bitpro_app');

    Map userGroups = box.get('Merchandise Departments') ?? {};
    DepartmentData departmentData = DepartmentData(
        docId: docId ?? '',
        departmentName: name ?? '',
        departmentId: id ?? '',
        createdDate: createdDate,
        createdBy: createdBy);
    String dId = departmentData.docId;

    userGroups[dId] = departmentData.toMap();
    await box.put('Merchandise Departments', userGroups);
  }

  Future<List<DepartmentData>> fetchAllDepartmentsData() async {
    var box = Hive.box('bitpro_app');
    Map? departments = box.get('Merchandise Departments');
    if (departments == null) return [];
    return departments.keys.map((k) {
      var ud = departments[k];

      return DepartmentData.fromMap(ud);
    }).toList();

    // var qs = await FirebaseFirestore.instance
    //     .collection('Merchandise Departments')
    //     .get();

    // return qs.docs.map((d) {
    //   return DepartmentData(
    //       docId: d.id,
    //       createdDate: DateTime.parse(d.get('createdDate')),
    //       createdBy: d.get('createdBy'),
    //       departmentId: d.get('departmentId'),
    //       departmentName: d.get('departmentName'));
    // }).toList();
  }
}
