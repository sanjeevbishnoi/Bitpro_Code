import 'dart:io';

import 'package:bitpro_hive/model/store_data.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HiveStoreDbService {
  Future<int> getWorkstationNumber() async {
    var box = Hive.box('bitpro_app');
    var userSettingData = await box.get('user_settings_data');

    int workstationNumber = userSettingData['workstationNumber'];

    return workstationNumber;
  }

  Future<int> getSelectedStoreCode() async {
    var box = Hive.box('bitpro_app');
    var userSettingData = await box.get('user_settings_data');

    int selectedStoreCode = userSettingData['selectedStoreCode'];

    return selectedStoreCode;
  }

  Future<StoreData> getSelectedStoreData() async {
    var box = Hive.box('bitpro_app');
    var userSettingData = await box.get('user_settings_data');
    int selectedStoreCode = userSettingData['selectedStoreCode'];

    var storeDataList = await HiveStoreDbService().fetchAllStoresData();
    if (storeDataList.any((e) => e.storeCode == selectedStoreCode.toString())) {
      return storeDataList.elementAt(storeDataList.indexWhere(
          (element) => element.storeCode == selectedStoreCode.toString()));
    } else {
      //if store not found, automtaically make first store as default store
      userSettingData!['selectedStoreCode'] = storeDataList.first.storeCode;
      await box.put('user_settings_data', userSettingData);
      return storeDataList.first;
    }
  }

  Future addStoreData(StoreData storeData) async {
    var box = Hive.box('bitpro_app');

    Map allStoresData = box.get('Stores Data') ?? {};

    String dId = storeData.docId;
    allStoresData[dId] = storeData.toMap();

    await box.put('Stores Data', allStoresData);
  }

  Future<List<StoreData>> fetchAllStoresData() async {
    var box = Hive.box('bitpro_app');

    Map? stores = box.get('Stores Data');
    if (stores == null) return [];
    return stores.keys.map((k) {
      var ud = stores[k];

      return StoreData.fromMap(ud);
    }).toList();
  }

  Future<String> uploadImage(
      {required File file, required String fileName}) async {
    var p =
        await getApplicationSupportDirectory(); // C:\Users\team\AppData\Roaming\com.example\bitpro_hive

    File imgDirectory = File('${p.path}/images/stores/$fileName.png');

    try {
      await imgDirectory.create(recursive: true);
    } catch (e) {}

    await file.copy(imgDirectory.path);

    return imgDirectory.path;
  }
}
