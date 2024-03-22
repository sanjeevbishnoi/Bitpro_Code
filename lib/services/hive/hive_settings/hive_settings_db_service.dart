import 'dart:io';
import 'package:bitpro_hive/model/store_data.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HiveSettingsDbService {
  Future addUpdateTab1SettingsData({required String companyName}) async {
    var box = Hive.box('bitpro_app');

    var userSettingData = await box.get('user_settings_data');
    if (userSettingData != null) {
      userSettingData['companyName'] = companyName;

      await box.put('user_settings_data', userSettingData);
    }
  }

  Future addUpdateTab2SettingsData(
      {required receiptTitleEng,
      required receiptTitleArb,
      required receiptFotterEng,
      required receiptFotterArb,
      required String tagHeight,
      required String tagWidth,
      required String selectedReceiptTemplate}) async {
    var box = Hive.box('bitpro_app');
    await box.put('user_printing_settings', {
      'receiptTitleEng': receiptTitleEng,
      'receiptTitleArb': receiptTitleArb,
      'receiptFotterEng': receiptFotterEng,
      'receiptFotterArb': receiptFotterArb,
      'tagHeight': tagHeight,
      'tagWidth': tagWidth,
      'selectedReceiptTemplate': selectedReceiptTemplate
    });
  }

  Future addUpdateTab3SettingsData({
    required taxPercentage,
  }) async {
    var box = Hive.box('bitpro_app');

    await box.put('user_taxes_settings', {
      'taxPercentage': taxPercentage,
    });
  }

  Future<String> uploadImage({required File file}) async {
    //Add Device Image Url
    var p =
        await getApplicationSupportDirectory(); // C:\Users\team\AppData\Roaming\com.example\bitpro_hive

    File imgDirectory = File('${p.path}/images/settings/companyLogo.png');

    try {
      await imgDirectory.create(recursive: true);
    } catch (e) {}

    await file.copy(imgDirectory.path);

    return imgDirectory.path;
  }
}
