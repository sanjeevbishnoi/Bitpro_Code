import 'package:hive/hive.dart';
import 'package:bitpro_hive/model/user_group_data.dart';

class HiveUserGroupDbService {
  Future<void> addEditUserGroup(UserGroupData userGroupData) async {
    var box = Hive.box('bitpro_app');

    Map userGroups = box.get('UserGroups') ?? {};

    String dId = userGroupData.docId;

    userGroups[dId] = userGroupData.toMap();

    await box.put('UserGroups', userGroups);
  }

  Future<List<UserGroupData>> fetchAllUserGroups() async {
    var box = Hive.box('bitpro_app');

    Map userGroups = box.get('UserGroups') ?? {};

    return userGroups.values.map((v) {
      return UserGroupData.fromMap(v);
    }).toList();
  }
}
