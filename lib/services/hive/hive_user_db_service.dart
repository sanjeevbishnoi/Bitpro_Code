import 'dart:math';
import 'package:bitpro_hive/model/store_data.dart';
import 'package:bitpro_hive/services/hive/hive_settings/hive_store_db_service.dart';
import 'package:bitpro_hive/shared/constant_data.dart';
import 'package:hive/hive.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/model/user_group_data.dart';
import 'package:bitpro_hive/services/hive/hive_user_group_db_service.dart';

class HiveUserDbService {
  addEditUser(UserData employeeData) async {
    var box = Hive.box('bitpro_app');
    Map users = box.get('Users') ?? {};

    users[employeeData.docId] = employeeData.toMap();

    await box.put('Users', users);
  }

  Future<UserData?> login(String username, String password) async {
    var box = Hive.box('bitpro_app');

    //login for other users
    Map users = box.get('Users') ?? {};
    List<UserData> userDataLst =
        users.values.map((e) => UserData.fromMap(e)).toList();
    int i = userDataLst.indexWhere((element) =>
        element.username == username && element.password == password);
    if (i != -1) {
      await box.put('user_data', userDataLst.elementAt(i).toMap());
      return userDataLst.elementAt(i);
    }

    //if user is admin
    if (users.isEmpty && username == 'admin' && password == 'admin') {
      Map? ud = box.get('user_data');
      if (ud == null) {
        String docId = getRandomString(20);
        UserData ud = UserData.fromMap({
          'firstName': 'ad',
          'lastName': '',
          'userRole': 'Admin',
          'username': 'admin',
          'password': 'admin',
          'employeeId': '1100000001',
          'maxDiscount': '0',
          'createdBy': 'system',
          'createdDate': DateTime.now().toString(),
          'docId': docId,
          'openRegister': null
        });
        await box.put('user_data', ud.toMap());
        Map users = box.get('Users') ?? {};

        users[docId] = ud.toMap();
        await box.put('Users', users);

        // creating first group
        await HiveUserGroupDbService().addEditUserGroup(UserGroupData(
            backupReset: true,
            adjustment: true,
            createdBy: 'system',
            createdDate: DateTime.now(),
            customers: true,
            departments: true,
            description: 'full access',
            docId: docId,
            employees: true,
            formerZout: true,
            groups: true,
            inventory: true,
            name: 'Admin',
            purchaseVoucher: true,
            receipt: true,
            registers: true,
            reports: true,
            salesReceipt: true,
            settings: true,
            vendors: true,
            promotion: true));

        //creating first store
        String storeDocId = getRandomString(20);
        await HiveStoreDbService().addStoreData(StoreData(
            docId: storeDocId,
            storeCode: '1',
            storeName: 'Store 1',
            address1: '',
            address2: '',
            phone1: '',
            phone2: '',
            vatNumber: '',
            logoPath: '',
            workstationInfo: [],
            bankName: '',
            email: '',
            ibanAccountNumber: '',
            priceLevel: ''));

        await box.put('user_settings_data', {
          'companyName': '',
          'selectedStoreCode': 1,
          'workstationNumber': 1
        });
        //receipt
        await box.put('payment_type_list', {
          PaymentMethodKey().cash: 1,
          PaymentMethodKey().creditCard: 1,
          PaymentMethodKey().tamara: 1,
          PaymentMethodKey().tabby: 1
        });

        return ud;
      } else {
        return UserData.fromMap(ud);
      }
    }
    return null;
  }

  Future<List<UserData>> fetchAllUserData() async {
    var box = Hive.box('bitpro_app');
    Map? users = box.get('Users');
    if (users == null) return [];
    return users.keys.map((k) {
      var ud = users[k];

      return UserData.fromMap(ud);
    }).toList();
  }

  // Future<bool> checkUsernameExist(String username) async {
  //   var box = Hive.box('bitpro_app');
  //   Map? users = box.get('Users');
  //   if (users == null) return false;
  //   List<UserData> u = users.keys.map((k) {
  //     var ud = users[k];

  //     return UserData.fromMap(ud);
  //   }).toList();

  //   var l = u.where((element) => element.username == username).toList();

  //   if (l.isNotEmpty) {
  //     return true;
  //   }
  //   return false;
  // }
}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
